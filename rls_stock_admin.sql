-- =====================================================================
-- Stock de médicaments : autoriser l'administrateur à ajouter et modifier
-- =====================================================================
-- Jusqu'ici, seul le pharmacien en chef d'un site pouvait faire évoluer le
-- stock de CE site (politiques stock_insertion_chef / stock_maj_chef /
-- stock_suppression_chef, voir rls_stock_pharmacien_chef.sql). L'administrateur
-- n'avait qu'une vue en lecture seule, y compris depuis l'interface.
--
-- Ce script ajoute à l'administrateur le droit d'ajouter, modifier et retirer
-- des articles, sur TOUS les sites. Utile notamment avant une campagne, quand
-- aucun pharmacien en chef n'est encore désigné : sans cela, personne ne peut
-- constituer le stock initial.
--
-- IMPORTANT - ce script est purement ADDITIF : il ne touche pas aux politiques
-- existantes du pharmacien en chef, qui continuent de fonctionner à
-- l'identique. PostgreSQL combine les politiques "permissive" d'une même
-- commande avec un OU logique : une écriture est acceptée si l'utilisateur est
-- le pharmacien en chef du site OU s'il est administrateur.
--
-- La lecture n'a pas besoin d'être modifiée : la politique stock_lecture
-- autorise déjà l'administrateur.
--
-- Ce script est sûr à relancer (create or replace / drop policy if exists).
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

-- Même forme que is_chief_pharmacien : SECURITY DEFINER pour pouvoir lire
-- profiles sans dépendre des politiques de lecture de cette table, et
-- search_path figé (bonne pratique obligatoire avec SECURITY DEFINER, sinon un
-- schéma malveillant placé devant public pourrait détourner la fonction).
-- Le compte doit être actif : désactiver un administrateur lui retire donc
-- aussi, immédiatement, le droit d'écrire sur le stock.
create or replace function public.is_admin()
  returns boolean
  language sql
  stable
  security definer
  set search_path to 'public'
as $$
  select exists(
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin' and actif
  );
$$;

drop policy if exists "stock_insertion_admin"   on public.stock_medicaments;
drop policy if exists "stock_maj_admin"         on public.stock_medicaments;
drop policy if exists "stock_suppression_admin" on public.stock_medicaments;

create policy "stock_insertion_admin"
  on public.stock_medicaments
  for insert
  to authenticated
  with check (public.is_admin());

create policy "stock_maj_admin"
  on public.stock_medicaments
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "stock_suppression_admin"
  on public.stock_medicaments
  for delete
  to authenticated
  using (public.is_admin());

-- Vérification après exécution : on doit voir les trois politiques "..._chef"
-- ET les trois nouvelles "..._admin" coexister.
--
--   select policyname, cmd from pg_policies
--   where schemaname = 'public' and tablename = 'stock_medicaments'
--   order by cmd, policyname;
