-- =====================================================================
-- Modifier une consultation déjà enregistrée, avec traçabilité
-- =====================================================================
-- Une consultation était définitive : la moindre faute de frappe imposait de
-- la supprimer et de tout ressaisir - avec, au passage, la perte du numéro
-- de consultation déjà remis au patient.
--
-- Elle devient modifiable par SON AUTEUR et par un ADMINISTRATEUR, sans
-- limite de temps. Mais sur un dossier médical, une modification silencieuse
-- serait pire que l'absence de modification : chaque changement est donc
-- enregistré ici, champ par champ, avec son auteur et sa date.
--
-- Ce que cette table conserve : pour chaque modification, QUI, QUAND, et
-- pour chaque champ touché sa valeur AVANT et APRÈS. On peut ainsi toujours
-- reconstituer ce qui avait été saisi initialement, même après plusieurs
-- modifications successives.
--
-- L'historique est volontairement en AJOUT SEUL : personne ne peut le
-- modifier ni le supprimer, pas même un administrateur. Un journal qu'on
-- pourrait réécrire ne prouverait rien.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- =====================================================================

-- --------------------------------------------------------------------
-- 1) La table d'historique
-- --------------------------------------------------------------------
create table if not exists public.consultations_modifications (
  id             uuid primary key default gen_random_uuid(),
  consultation_id uuid not null references public.consultations(id) on delete cascade,
  modifie_le     timestamptz not null default now(),
  modifie_par_id uuid,                 -- compte auteur de la modification
  modifie_par    text,                 -- son nom, figé au moment du changement :
                                       -- reste lisible même si le compte est supprimé plus tard
  changements    jsonb not null        -- [{champ, avant, apres}, ...]
);

-- La consultation d'un historique est presque toujours lue par consultation_id
-- et affichée du plus récent au plus ancien.
create index if not exists consultations_modifications_consult_idx
  on public.consultations_modifications (consultation_id, modifie_le desc);

alter table public.consultations_modifications enable row level security;

-- --------------------------------------------------------------------
-- 2) Qui peut écrire dans l'historique
-- --------------------------------------------------------------------
-- Insertion réservée à un utilisateur connecté, qui doit s'y déclarer sous sa
-- propre identité : impossible d'attribuer une modification à quelqu'un d'autre.
drop policy if exists "modifs_insertion" on public.consultations_modifications;
create policy "modifs_insertion"
  on public.consultations_modifications
  for insert
  to authenticated
  with check (modifie_par_id = auth.uid());

-- Lecture ouverte aux comptes connectés : la traçabilité n'a d'intérêt que si
-- elle est consultable. Aucune donnée clinique n'y figure au-delà de ce que le
-- lecteur peut déjà voir sur la consultation elle-même.
drop policy if exists "modifs_lecture" on public.consultations_modifications;
create policy "modifs_lecture"
  on public.consultations_modifications
  for select
  to authenticated
  using (true);

-- Aucune policy UPDATE ni DELETE n'est créée, volontairement : sans policy,
-- RLS refuse l'opération. L'historique est donc en ajout seul, y compris pour
-- un administrateur.

-- --------------------------------------------------------------------
-- 3) Qui peut modifier une consultation
-- --------------------------------------------------------------------
-- Son auteur (agent_id) ou un administrateur. Le compte doit être actif :
-- désactiver quelqu'un lui retire immédiatement ce droit.
drop policy if exists "consult_modification_auteur_ou_admin" on public.consultations;
create policy "consult_modification_auteur_ou_admin"
  on public.consultations
  for update
  to authenticated
  using (
    agent_id = auth.uid()
    or public.is_admin()
  )
  with check (
    agent_id = auth.uid()
    or public.is_admin()
  );

-- Note : public.is_admin() est défini par rls_stock_admin.sql. Si ce script
-- n'a jamais été exécuté, lancez-le d'abord - sinon la policy ci-dessus
-- échouera sur une fonction introuvable.
