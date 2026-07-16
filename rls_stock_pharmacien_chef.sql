-- ============================================================================
-- RLS : restreindre l'écriture sur stock_medicaments au pharmacien en chef
-- À exécuter dans Supabase → SQL Editor
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ÉTAPE 1 — Inspecter les politiques existantes sur stock_medicaments
-- (à faire AVANT toute chose, pour connaître les noms réels à supprimer :
--  une politique permissive déjà en place laissée active annule les nouvelles
--  restrictions, car les politiques RLS d'une même commande se combinent en OU)
-- ----------------------------------------------------------------------------
select policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname = 'public'
  and tablename = 'stock_medicaments';


-- ----------------------------------------------------------------------------
-- ÉTAPE 2 — Supprimer les anciennes politiques d'écriture (INSERT/UPDATE/DELETE)
-- Remplacez "nom_de_la_politique" par les noms réels obtenus à l'étape 1.
-- Ne touchez PAS aux politiques de lecture (SELECT) : elles doivent rester
-- ouvertes à tous les pharmaciens (+ admin) du site pour l'onglet Stock en
-- lecture seule et pour la vérification de disponibilité en Délivrances.
-- ----------------------------------------------------------------------------
-- drop policy if exists "nom_de_la_politique_insert" on stock_medicaments;
-- drop policy if exists "nom_de_la_politique_update" on stock_medicaments;
-- drop policy if exists "nom_de_la_politique_delete" on stock_medicaments;


-- ----------------------------------------------------------------------------
-- ÉTAPE 3 — Nouvelles politiques : seul le pharmacien en chef du site peut
-- ajouter, modifier ou supprimer un article de son site.
-- ----------------------------------------------------------------------------
alter table stock_medicaments enable row level security;

create policy "stock_insert_pharmacien_chef"
on stock_medicaments
for insert
to authenticated
with check (
  exists (
    select 1 from sites s
    where s.id = stock_medicaments.site_id
      and s.pharmacien_chef_id = auth.uid()
  )
);

create policy "stock_update_pharmacien_chef"
on stock_medicaments
for update
to authenticated
using (
  exists (
    select 1 from sites s
    where s.id = stock_medicaments.site_id
      and s.pharmacien_chef_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from sites s
    where s.id = stock_medicaments.site_id
      and s.pharmacien_chef_id = auth.uid()
  )
);

create policy "stock_delete_pharmacien_chef"
on stock_medicaments
for delete
to authenticated
using (
  exists (
    select 1 from sites s
    where s.id = stock_medicaments.site_id
      and s.pharmacien_chef_id = auth.uid()
  )
);

-- ----------------------------------------------------------------------------
-- Vérification après coup : reconnecté en tant que pharmacien NON chef d'un
-- site, une tentative d'insert/update/delete sur stock_medicaments doit
-- échouer avec une erreur RLS ("new row violates row-level security policy").
-- Reconnecté en tant que pharmacien en chef, les mêmes actions doivent
-- fonctionner normalement.
-- ----------------------------------------------------------------------------
