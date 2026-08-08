-- ============================================================
-- DONNÉES DE TEST - Direct du Gamou (bandeau Événement phare)
--
-- But : vérifier AVANT le 24 août que la chaîne complète fonctionne :
-- consultations saisies -> stats_campagne_publique -> tuiles de chiffres
-- sur amstc.org et consultations-amstc.org.
--
-- Ce script crée un site de test rattaché à la campagne liée dans le CMS
-- et y insère 18 consultations factices, toutes marquées TEST-GAMOU.
-- Attendu ensuite sur les bandeaux (dans les 2 minutes) :
--   Malades consultés : 18 - Âge moyen : 33 ans
--   Hommes / Femmes : 56% / 44% - Ordonnances délivrées : 12
--
-- APRÈS le test, exécutez donnees-test-gamou-nettoyage.sql pour tout
-- retirer. Rien d'autre n'est touché.
--
-- À exécuter : Studio de l'instance CONSULTATIONS
-- (api.consultations-amstc.org) > SQL Editor > coller > Run.
-- ============================================================

do $$
declare
  v_campagne uuid := '95af9ed0-96d8-4df1-9b69-8a2884832289'; -- Gamou (CMS)
  v_site     uuid;
  v_agent    uuid;
  i          int;
begin
  if not exists (select 1 from public.campagnes where id = v_campagne) then
    raise exception 'Campagne % introuvable : vérifiez l''ID dans le CMS.', v_campagne;
  end if;

  select id into v_agent from public.profiles limit 1;
  if v_agent is null then
    raise exception 'Aucun profil sur cette instance pour servir d''agent de test.';
  end if;

  insert into public.sites (nom, campagne_id, actif)
  values ('SITE TEST GAMOU - À SUPPRIMER', v_campagne, true)
  returning id into v_site;

  for i in 1..18 loop
    insert into public.consultations
      (agent_id, site_id, prenom, nom, sexe, age,
       motifs, signes, diagnostic, conduite,
       medicaments, type_consultation, delivre, refere_traite, created_at)
    values
      (v_agent, v_site, 'TEST-GAMOU', 'À SUPPRIMER',
       case when i % 9 < 5 then 'M' else 'F' end,          -- 10 hommes, 8 femmes
       5 + (i * 7) % 61,                                    -- âges variés 5..65
       'Données de test du direct', 'test', 'test', 'test',
       case when i <= 12
         then '[{"nom": "Paracétamol 500mg", "quantite": 1}]'::jsonb  -- 12 ordonnances
         else '[]'::jsonb
       end,
       'medecine', false, false,
       now() - (i || ' minutes')::interval);
  end loop;

  raise notice 'Site de test % créé avec 18 consultations.', v_site;
end;
$$;

-- Contrôle immédiat : doit renvoyer 18 malades, 12 ordonnances.
select public.stats_campagne_publique('95af9ed0-96d8-4df1-9b69-8a2884832289');
