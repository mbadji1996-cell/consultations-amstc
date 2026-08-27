-- =====================================================================
-- Actes réalisés hors consultation
-- =====================================================================
-- Sur le terrain, tout ne passe pas par une fiche. Au Gamou de Tivaouane
-- 2026, l'équipe de Cité Dabakh a réalisé environ 25 pansements et 17 mises
-- en observation sans enregistrer les patients : l'option « acte » n'existait
-- pas encore dans l'application.
--
-- Ces actes ont bien eu lieu et doivent figurer au bilan. Mais créer 42 fiches
-- patients pour les compter inventerait 42 personnes qui n'ont jamais existé,
-- gonflerait le nombre de consultations et fausserait durablement l'âge moyen,
-- la répartition par sexe et les diagnostics. Sur un dossier médical, ce serait
-- une falsification, même faite de bonne foi.
--
-- D'où cette table : un simple comptage, rattaché à une campagne et à un site,
-- sans aucune donnée patient. Le bilan additionne ces actes à ceux relevés sur
-- les consultations, en indiquant clairement la part de chacun.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- Nécessite public.is_admin(), défini par rls_stock_admin.sql.
-- =====================================================================

create table if not exists public.actes_hors_consultation (
  id          uuid primary key default gen_random_uuid(),
  campagne_id uuid not null references public.campagnes(id) on delete cascade,
  site_id     uuid references public.sites(id) on delete set null,
  acte        text not null,
  nombre      integer not null default 0 check (nombre >= 0),
  note        text,
  saisi_par   text,        -- nom figé au moment de la saisie
  saisi_le    timestamptz not null default now()
);

-- Le bilan lit toujours ces lignes par campagne.
create index if not exists actes_hors_consultation_campagne_idx
  on public.actes_hors_consultation (campagne_id);

-- Un même acte ne doit exister qu'une fois par site et par campagne : on
-- corrige un comptage, on ne l'empile pas.
create unique index if not exists actes_hors_consultation_unique_idx
  on public.actes_hors_consultation (campagne_id, coalesce(site_id, '00000000-0000-0000-0000-000000000000'::uuid), lower(trim(acte)));

alter table public.actes_hors_consultation enable row level security;

-- Lecture ouverte aux comptes connectés : ces chiffres alimentent le tableau
-- de bord et le bilan, et ne contiennent aucune donnée patient.
drop policy if exists "actes_hors_lecture" on public.actes_hors_consultation;
create policy "actes_hors_lecture"
  on public.actes_hors_consultation
  for select to authenticated using (true);

-- Écriture réservée à l'administrateur : c'est un chiffre de bilan, pas une
-- donnée de soin saisie au fil de l'eau.
drop policy if exists "actes_hors_insertion"   on public.actes_hors_consultation;
drop policy if exists "actes_hors_maj"         on public.actes_hors_consultation;
drop policy if exists "actes_hors_suppression" on public.actes_hors_consultation;

create policy "actes_hors_insertion"
  on public.actes_hors_consultation
  for insert to authenticated with check (public.is_admin());

create policy "actes_hors_maj"
  on public.actes_hors_consultation
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "actes_hors_suppression"
  on public.actes_hors_consultation
  for delete to authenticated using (public.is_admin());

-- --------------------------------------------------------------------
-- Les actes du Gamou de Tivaouane 2026, à Cité Dabakh
-- --------------------------------------------------------------------
-- Chiffres communiqués par l'équipe, patients non enregistrés.
do $$
declare
  v_camp uuid;
  v_site uuid;
begin
  select id into v_camp from public.campagnes
   where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
  if v_camp is null then
    raise notice 'Campagne du Gamou introuvable : les comptages ne sont pas insérés.';
    return;
  end if;
  select id into v_site from public.sites
   where campagne_id = v_camp and nom = 'Cité Dabakh';

  insert into public.actes_hors_consultation (campagne_id, site_id, acte, nombre, note, saisi_par)
  values
    (v_camp, v_site, 'Pansement', 25,
     'Réalisés pendant le Gamou 2026 ; patients non enregistrés (option « acte » inexistante à l''époque).',
     'Reprise du registre papier'),
    (v_camp, v_site, 'Mise en observation', 17,
     'Réalisées pendant le Gamou 2026 ; patients non enregistrés (option « acte » inexistante à l''époque).',
     'Reprise du registre papier')
  on conflict do nothing;   -- relançable sans créer de doublon
end $$;
