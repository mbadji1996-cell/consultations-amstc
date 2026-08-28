-- =====================================================================
-- Références déclarées à la main
-- =====================================================================
-- Le bilan ne compte comme référence que l'orientation d'un patient vers une
-- structure extérieure : hôpital, centre de santé, service spécialisé. Orienter
-- un patient vers un confrère présent sur le site est un mouvement interne à
-- l'équipe, qui n'apprend rien sur la prise en charge - le patient reste dans la
-- campagne et sa consultation est déjà comptée.
--
-- Ces références extérieures n'étaient connues que par le champ refere_hopital
-- d'une fiche de consultation. Or il en existe qui n'ont jamais eu de fiche :
-- un patient orienté directement depuis l'accueil, une évacuation décidée dans
-- l'urgence, un afflux où l'on a orienté sans enregistrer. Elles ont eu lieu,
-- elles comptent, et rien ne permettait de les déclarer.
--
-- Plutôt que de créer une seconde table identique, on ajoute une catégorie à
-- celle des actes hors consultation : même structure - un intitulé, un site
-- facultatif, un nombre -, mêmes règles de sécurité, même écran de saisie.
-- Une ligne de catégorie « reference » porte en intitulé la structure de
-- destination, et non un acte.
--
-- L'index d'unicité est refait pour inclure la catégorie : « Hôpital régional »
-- doit pouvoir exister comme destination de référence sans entrer en collision
-- avec un acte du même nom.
--
-- SANS CE SCRIPT, l'application continue de fonctionner : la rubrique
-- Références reste vide et le bilan ne compte que les références portées par
-- une fiche de consultation.
--
-- PRÉREQUIS : rls_actes_hors_consultation.sql doit avoir été exécuté.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- =====================================================================

alter table public.actes_hors_consultation
  add column if not exists categorie text not null default 'acte';

-- Deux valeurs seulement : au-delà, le bilan ne saurait plus dans quel total
-- ranger une ligne.
alter table public.actes_hors_consultation
  drop constraint if exists actes_hors_consultation_categorie_check;
alter table public.actes_hors_consultation
  add constraint actes_hors_consultation_categorie_check
  check (categorie in ('acte', 'reference'));

-- L'ancien index ignorait la catégorie : il aurait interdit une référence
-- portant le même intitulé qu'un acte, sur le même site.
drop index if exists public.actes_hors_consultation_unique_idx;
create unique index if not exists actes_hors_consultation_unique_idx
  on public.actes_hors_consultation
     (campagne_id,
      coalesce(site_id, '00000000-0000-0000-0000-000000000000'::uuid),
      categorie,
      lower(trim(acte)));

-- Contrôle après exécution : répartition des lignes existantes.
-- Toutes doivent être en 'acte' au premier passage.
select categorie, count(*) as lignes, sum(nombre) as total
  from public.actes_hors_consultation
 group by categorie
 order by categorie;
