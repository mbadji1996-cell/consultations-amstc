-- =====================================================================
-- Le stock passe du SITE à la CAMPAGNE
-- =====================================================================
-- Le stock était tenu site par site. En pratique, une campagne dispose d'un
-- seul lot de médicaments que les équipes se répartissent sur le terrain :
-- éclater ce lot en autant de stocks que de sites obligeait à ressaisir les
-- mêmes articles partout et rendait tout décompte global impossible.
--
-- Un seul stock par campagne, donc. Et le "pharmacien en chef" suit le même
-- mouvement : il devient responsable de la campagne, plus d'un site.
--
-- CE SCRIPT MODIFIE DES DONNÉES EXISTANTES. Il est écrit pour être rejouable
-- sans dommage, mais faites une sauvegarde avant de le lancer (Supabase :
-- Database > Backups).
--
-- Ce qu'il fait, dans l'ordre :
--   1. ajoute la colonne campagne_id au stock et la remplit depuis le site ;
--   2. FUSIONNE les articles de même nom d'une même campagne en ADDITIONNANT
--      leurs quantités ;
--   3. supprime le stock des sites sans campagne (sites autonomes, mis de
--      côté pour l'instant) ;
--   4. déplace le pharmacien en chef du site vers la campagne ;
--   5. met à jour les droits d'écriture.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Nécessite public.is_admin(), défini par rls_stock_admin.sql : lancez
-- d'abord celui-là s'il ne l'a jamais été.
-- =====================================================================

-- --------------------------------------------------------------------
-- 1) Rattacher le stock à la campagne
-- --------------------------------------------------------------------
alter table public.stock_medicaments
  add column if not exists campagne_id uuid references public.campagnes(id) on delete cascade;

update public.stock_medicaments s
set campagne_id = si.campagne_id
from public.sites si
where s.site_id = si.id
  and s.campagne_id is null;

-- site_id devient facultatif : les nouveaux articles n'en auront plus.
-- La colonne est CONSERVÉE volontairement (voir la note en fin de script).
alter table public.stock_medicaments
  alter column site_id drop not null;

-- --------------------------------------------------------------------
-- 2) Fusionner les doublons en additionnant les quantités
-- --------------------------------------------------------------------
-- Comparaison sur le nom en minuscules et sans espaces superflus : "Paracétamol
-- 500mg" et "paracétamol 500mg " saisis sur deux sites sont bien le même article.
-- L'ordre compte : on additionne AVANT de supprimer, sinon la somme serait perdue.

update public.stock_medicaments s
set quantite = f.total
from (
  select campagne_id,
         lower(trim(nom))   as cle,
         sum(quantite)      as total,
         min(id::text)      as garder
  from public.stock_medicaments
  where campagne_id is not null
  group by campagne_id, lower(trim(nom))
) f
where s.id::text = f.garder
  and s.quantite is distinct from f.total;

delete from public.stock_medicaments s
using (
  select campagne_id,
         lower(trim(nom)) as cle,
         min(id::text)    as garder
  from public.stock_medicaments
  where campagne_id is not null
  group by campagne_id, lower(trim(nom))
) f
where s.campagne_id = f.campagne_id
  and lower(trim(s.nom)) = f.cle
  and s.id::text <> f.garder;

-- --------------------------------------------------------------------
-- 3) Écarter le stock des sites sans campagne
-- --------------------------------------------------------------------
-- Les "sites autonomes" sont mis de côté pour l'instant : leur stock n'a
-- aucune campagne à laquelle se rattacher. Les SITES eux-mêmes ne sont pas
-- supprimés - ils peuvent porter des consultations déjà enregistrées, qui
-- doivent rester intactes.
delete from public.stock_medicaments
where campagne_id is null;

create index if not exists stock_medicaments_campagne_idx
  on public.stock_medicaments (campagne_id);

-- --------------------------------------------------------------------
-- 4) Le pharmacien en chef passe du site à la campagne
-- --------------------------------------------------------------------
alter table public.campagnes
  add column if not exists pharmacien_chef_id uuid references public.profiles(id) on delete set null;

-- Reprise de l'existant : si des sites d'une campagne avaient un chef, le
-- premier d'entre eux devient chef de la campagne. À revérifier ensuite dans
-- l'application, une campagne n'ayant maintenant qu'un seul responsable.
update public.campagnes c
set pharmacien_chef_id = sub.chef
from (
  select s.campagne_id, min(s.pharmacien_chef_id::text)::uuid as chef
  from public.sites s
  where s.campagne_id is not null and s.pharmacien_chef_id is not null
  group by s.campagne_id
) sub
where c.id = sub.campagne_id
  and c.pharmacien_chef_id is null;

-- --------------------------------------------------------------------
-- 5) Droits d'écriture sur le stock
-- --------------------------------------------------------------------
-- search_path figé, obligatoire avec SECURITY DEFINER. Le compte doit être
-- actif : désactiver un pharmacien en chef lui retire aussitôt ce droit.
create or replace function public.is_chef_campagne(p_campagne_id uuid)
  returns boolean
  language sql
  stable
  security definer
  set search_path to 'public'
as $$
  select exists(
    select 1
    from public.campagnes c
    join public.profiles p on p.id = auth.uid()
    where c.id = p_campagne_id
      and c.pharmacien_chef_id = auth.uid()
      and p.actif
  );
$$;

drop policy if exists "stock_insertion_admin"   on public.stock_medicaments;
drop policy if exists "stock_maj_admin"         on public.stock_medicaments;
drop policy if exists "stock_suppression_admin" on public.stock_medicaments;
drop policy if exists "stock_insertion_chef"    on public.stock_medicaments;
drop policy if exists "stock_maj_chef"          on public.stock_medicaments;
drop policy if exists "stock_suppression_chef"  on public.stock_medicaments;

create policy "stock_insertion_chef"
  on public.stock_medicaments
  for insert
  to authenticated
  with check (public.is_admin() or public.is_chef_campagne(campagne_id));

create policy "stock_maj_chef"
  on public.stock_medicaments
  for update
  to authenticated
  using      (public.is_admin() or public.is_chef_campagne(campagne_id))
  with check (public.is_admin() or public.is_chef_campagne(campagne_id));

create policy "stock_suppression_chef"
  on public.stock_medicaments
  for delete
  to authenticated
  using (public.is_admin() or public.is_chef_campagne(campagne_id));

-- --------------------------------------------------------------------
-- NOTE - nettoyage différé, à ne lancer qu'une fois tout vérifié
-- --------------------------------------------------------------------
-- Deux colonnes ne servent plus à rien après cette migration :
--   stock_medicaments.site_id   et   sites.pharmacien_chef_id
-- Elles sont volontairement CONSERVÉES ici : les supprimer est irréversible,
-- et tant qu'elles restent en place vous pouvez vérifier que la répartition
-- des stocks et des responsables est correcte, voire revenir en arrière.
-- L'application ne les lit plus.
--
-- Une fois la vérification faite, ces deux lignes les retirent définitivement :
--
--   alter table public.stock_medicaments drop column if exists site_id;
--   alter table public.sites drop column if exists pharmacien_chef_id;
