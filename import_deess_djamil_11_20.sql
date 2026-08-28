-- =====================================================================
-- Registre papier DEESS Djamil — 25 août 2026, lignes 11 à 20
-- =====================================================================
-- Praticien : Ndéye Awa Diaham. Équipe Matin/Soir.
-- Source : photographie du registre COSKAS Santé, transcrite puis relue avec
-- l'équipe.
--
-- L'ALIGNEMENT DES LIGNES A ÉTÉ VÉRIFIÉ, et c'était le risque principal : sur
-- la photographie, le bloc âge / sexe / diagnostic paraît décalé d'une demi-ligne
-- par rapport aux noms, et un décalage d'une ligne aurait donné à chaque patient
-- le diagnostic de son voisin. Quatre traitements confirmés par l'équipe
-- recoupent le diagnostic de leur propre ligne - collyre auriculaire sur douleur
-- auriculaire, collyre ophtalmique sur douleur oculaire, TDR paludisme sur
-- céphalées fébriles, myorelaxant sur douleur rachidienne - ce qui écarte le
-- décalage.
--
-- CE QUI RESTE À VÉRIFIER dans l'application, fiche par fiche. Ces lectures sont
-- plausibles mais n'ont pas été confirmées ; elles sont importées telles quelles
-- plutôt que remplacées par un tiret, car une fiche sans nom ni âge ne se
-- retrouve pas :
--   AMSTC-DJ25-12  prénom « Adama », et « signes de diabète » dans le diagnostic
--   AMSTC-DJ25-13  adresse « Louga »
--   AMSTC-DJ25-14  patronyme « N'Keng » et âge 8 ans
--   AMSTC-DJ25-16  diagnostic « douleur auriculaire »
--   AMSTC-DJ25-17  âge 1 an
--   AMSTC-DJ25-19  diagnostic « douleur post-traumatique »
--
-- CE QUI EST ABSENT DU REGISTRE est marqué d'un tiret, jamais deviné :
--   AMSTC-DJ25-17 et 18  pas d'adresse notée
--   toutes les lignes  pas de motif de consultation, ni de téléphone
-- Ces fiches apparaîtront avec le signalement « incomplète » dans la liste des
-- consultations, ce qui permet de les compléter sans les chercher.
--
-- Les constantes notées au registre (tension, pouls, température) sont rangées
-- dans leurs champs propres et non dans le texte : elles alimentent ainsi les
-- statistiques.
--
-- LES LIGNES 1 À 10 DE CE REGISTRE NE SONT PAS DANS CE SCRIPT : la page
-- photographiée commence au numéro 11.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Relançable sans risque : un second passage est refusé.
-- =====================================================================

do $$
declare
  v_agent uuid;
  v_camp  uuid;
  v_site  uuid;
  v_n     int;
begin
  -- Le praticien, par son patronyme. On refuse d'avancer sur une correspondance
  -- ambiguë : rattacher des consultations au mauvais compte serait invisible.
  select count(*) into v_n from public.profiles where nom ilike '%Diaham%';
  if v_n = 0 then
    raise exception 'Aucun compte ne correspond à Ndéye Awa Diaham. Vérifiez l''orthographe du patronyme dans l''onglet Utilisateurs.';
  elsif v_n > 1 then
    raise exception '% comptes correspondent à « Diaham ». Précisez lequel avant d''importer.', v_n;
  end if;
  select id into v_agent from public.profiles where nom ilike '%Diaham%';

  select id into v_camp from public.campagnes
   where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
  if v_camp is null then
    raise exception 'Campagne du Gamou introuvable : rien n''a été importé.';
  end if;

  select id into v_site from public.sites
   where campagne_id = v_camp and nom ilike 'DEESS Djamil';
  if v_site is null then
    raise exception 'Site DEESS Djamil introuvable dans cette campagne : rien n''a été importé.';
  end if;

  if exists (select 1 from public.consultations
              where numero_consultation like 'AMSTC-DJ25-%') then
    raise exception 'Import déjà effectué : des consultations AMSTC-DJ25- existent déjà.';
  end if;

  insert into public.consultations
    (id, numero_consultation, patient_id, agent_id, site_id, medecin_nom,
     type_consultation, created_at, prenom, nom, age, sexe, adresse,
     telephone_patient, motifs, ta, fc, temperature, signes, diagnostic,
     conduite, medicaments)
  values
    (gen_random_uuid(), 'AMSTC-DJ25-11', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Baye Bara', 'Diop', 6, 'M', 'Ngaye', null, '-',
     null, null, null, '-',
     'Douleur thoracique ; asthme sans sifflement',
     'Antalgique ; consultation pédiatrique', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-12', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Adama', 'Faye', 50, 'F', 'Yène', null, '-',
     '19,1/10,4', 77, 36.8, '-',
     'Épigastralgie ; signes de diabète à explorer',
     'Reprendre la tension dans 10 minutes ; ECG ; surveillance', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-13', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Abdou Aziz', 'Ndiaye', 39, 'M', 'Louga', null, '-',
     '11,9/7,3', 78, 36.7, '-',
     'Algies diffuses', 'Vitamine C ; Paracétamol', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-14', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Ya Dièye', 'N''Keng', 8, 'F', 'Keur Massar', null, '-',
     null, null, null, 'Larmoiement, sécrétions purulentes',
     'Douleur oculaire avec sécrétions purulentes',
     'Levophta ; Clartec ; Albendazole ; consultation ophtalmologique', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-15', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Moustapha', 'Mbaye', 47, 'M', 'Guédiawaye', null, '-',
     '13/10', 65, null, 'Antécédent de chirurgie du rachis',
     'Douleur rachidienne', 'Myorelaxant ; Diclofénac', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-16', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Mouhamed', 'Mbaye', 22, 'M', 'Grand Yoff', null, '-',
     '12,2/8,6', 91, null, '-',
     'Douleur auriculaire', 'Otipax ; Litacold', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-17', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Abdou', 'Diop', 1, 'M', '-', null, '-',
     null, null, null, '-',
     'Lésions de brûlure évoluant depuis plus de 15 jours',
     'Fagic crème ; Paracétamol sirop', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-18', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Baye Serigne', 'Sène', 11, 'M', '-', null, '-',
     null, null, 36.5, '-',
     'Céphalées ; algies diffuses',
     'Perfalgan ; Restriva ; TDR paludisme', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-19', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Binta', 'Kébé', 56, 'F', 'Bargny', null, '-',
     '14/9', 104, null, '-',
     'Douleur post-traumatique', 'Diclofénac ; Amlodipine 10', '[]'::jsonb),

    (gen_random_uuid(), 'AMSTC-DJ25-20', gen_random_uuid(), v_agent, v_site,
     'Ndéye Awa Diaham', 'generaliste', '2026-08-25 12:00:00+00',
     'Mame Diarra', 'Fall', 22, 'F', 'Louga', null, '-',
     '12/7,5', null, 36.1, '-',
     'Macule prurigineuse', 'Griséofulvine', '[]'::jsonb);

  raise notice 'DEESS Djamil : 10 consultations importées (registre papier, lignes 11 à 20).';
end $$;

-- Contrôle : les dix fiches, dans l'ordre du registre.
select numero_consultation, prenom, nom, age, sexe, adresse, diagnostic, conduite
  from public.consultations
 where numero_consultation like 'AMSTC-DJ25-%'
 order by numero_consultation;
