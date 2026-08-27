-- =====================================================================
-- Correction : Mame Abdou aligné sur le résumé de garde (98 consultations)
-- =====================================================================
-- Le résumé de garde de Mame Abdou fait état de 98 consultations au total.
-- L'import initial en avait créé 79, dont 46 anonymes issues de listes de
-- diagnostics transmises avant ce résumé. Ces 46 lignes faisaient double
-- emploi : le résumé les recompte, et les additionner aurait porté Mame Abdou
-- à 177 consultations, soit près du double de la réalité.
--
-- Ce script remplace donc les 46 anonymes par 65 nouvelles, calculées à partir
-- du résumé de garde. Le total tombe exactement sur 98.
--
-- CE QUI EST CONSERVÉ : les 33 consultations identifiées (24 relevées sur les
-- photographies, 9 nommées par l'équipe). Elles portent un nom, souvent un âge
-- et un téléphone : c'est la donnée la plus précieuse, elle n'est pas touchée.
--
-- COMMENT LES 65 SONT CALCULÉES : pour chaque diagnostic du résumé, on retire
-- les consultations identifiées qui le portent déjà (18 correspondances
-- certaines : la lombosciatalgie est Ibrahima Ba, le syndrome coronarien est
-- Samba Sarr, etc.). Restent 15 fiches identifiées dont le diagnostic n'était
-- pas renseigné sur le document, donc introuvable dans le résumé : elles font
-- pourtant bien partie des 98. On a donc retiré 15 anonymes supplémentaires,
-- prises sur les postes les plus nombreux et les moins spécifiques (crise
-- d'asthme, algie diffuse, grippe) - le seul choix qui ne fabrique pas de
-- diagnostic précis pour un patient qui n'en a pas.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

do $$
declare
  v_agent uuid;
  v_camp  uuid;
  v_mame  uuid;
  v_suppr int;
begin
  select id into v_agent from public.profiles
   where lower(email) = lower('presseinfosamstc@gmail.com');
  select id into v_camp from public.campagnes
   where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
  select id into v_mame from public.sites
   where campagne_id = v_camp and nom = 'Hôpital Mame Abdou';
  if v_agent is null or v_mame is null then
    raise exception 'Compte ou site introuvable : rien n''a été modifié.';
  end if;

  -- 1) Retrait des seules lignes anonymes de l'import à Mame Abdou.
  --    Le filtre est volontairement strict : numéro d'import, site, ET nom et
  --    prénom réduits à un tiret. Aucune fiche nominative ne peut être touchée.
  delete from public.consultations
   where agent_id = v_agent
     and site_id = v_mame
     and numero_consultation like 'AMSTC-G26-%'
     and prenom = '-' and nom = '-';
  get diagnostics v_suppr = row_count;
  raise notice 'Anciennes lignes anonymes supprimées : %', v_suppr;

  -- 2) Les 65 consultations du résumé de garde
  insert into public.consultations
    (id, numero_consultation, patient_id, agent_id, site_id, medecin_nom,
     type_consultation, created_at, prenom, nom, age, sexe, adresse,
     telephone_patient, motifs, signes, diagnostic, conduite, actes_medicaux, medicaments)
  values
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Appendicite', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Appendicite', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Appendicite', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Fracture du bassin', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Fracture du bassin', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Fracture de la tête humérale', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Panaris', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'SJPU avec souffrance rénale', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Pneumonie dyspnéisante', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Contusion du bassin', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''hystérie', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''hystérie', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''hystérie', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''hystérie', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Crise d''hystérie', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme ouvert de la face', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Fracture-luxation de l''épaule', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme crânien', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme crânien', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme fermé du genou', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Polytraumatisme', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme ouvert du coude', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Fracture du poignet', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Fracture du fémur', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Entorse de la cheville', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Acidocétose', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Contusion de la jambe', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Thrombose veineuse profonde', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Rétention aiguë d''urine', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme thoracique', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Dermohypodermite bactérienne non nécrosante', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Dermohypodermite bactérienne non nécrosante', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme de la cheville', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Traumatisme de la cheville', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Piqûre de scorpion', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Urgence hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Urgence hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Poussée hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Poussée hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Poussée hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Poussée hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Poussée hypertensive', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Algie diffuse', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Algie diffuse', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Algie diffuse', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Algie diffuse', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Algie diffuse', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Épigastralgie / syndrome ulcéreux', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Épigastralgie / syndrome ulcéreux', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Épigastralgie / syndrome ulcéreux', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Épigastralgie / syndrome ulcéreux', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Épigastralgie / syndrome ulcéreux', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Hyperglycémie pure', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Hyperglycémie pure', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Hyperglycémie pure', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Suspicion de tuberculose pulmonaire', '-', 'Mise en observation', '[]'::jsonb),
    (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', '-', '-', null, null, '-', null, '-', '-', 'Polyarthrite rhumatoïde', '-', 'Mise en observation', '[]'::jsonb);

  raise notice 'Mame Abdou : 33 consultations identifiées + 65 du résumé = % au total.', 33 + 65;
end $$;

-- =====================================================================
-- Dépistages réalisés à Cité Dabakh (actes, sans fiche patient)
-- =====================================================================
do $$
declare
  v_camp uuid;
  v_site uuid;
begin
  select id into v_camp from public.campagnes
   where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
  select id into v_site from public.sites
   where campagne_id = v_camp and nom = 'Cité Dabakh';
  if v_camp is null then return; end if;

  insert into public.actes_hors_consultation (campagne_id, site_id, acte, nombre, note, saisi_par)
  values
    (v_camp, v_site, 'Dépistage : Diabète', 75,
     'Glycémies capillaires réalisées pendant le Gamou 2026 ; 6 hyperglycémies dépistées. Patients non enregistrés.',
     'Reprise du registre papier'),
    (v_camp, v_site, 'Dépistage : Hépatite B', 25,
     'TDR AgHBs réalisés pendant le Gamou 2026 ; 3 positifs, référés. Patients non enregistrés.',
     'Reprise du registre papier')
  on conflict do nothing;
end $$;
