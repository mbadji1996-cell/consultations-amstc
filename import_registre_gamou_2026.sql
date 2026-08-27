-- =====================================================================
-- Import du registre papier — Gamou de Tivaouane 2026
-- =====================================================================
-- 108 consultations relevées sur les registres papier des trois sites,
-- transcrites depuis 51 photographies puis complétées par les listes de
-- diagnostics fournies par les équipes.
--
--   Cité Dabakh ................  8
--   Hôpital Mame Abdou .........  79
--   Hôpital Seydil Hadji Malick   21
--
-- CONVENTION : un tiret « - » signale une donnée qui n'a pas été notée sur le
-- registre. Ce n'est pas un oubli de saisie : l'information n'existe pas. Les
-- fiches concernées apparaissent dans l'application avec le badge « Fiche
-- incomplète » et la liste des champs à compléter.
--
-- L'âge et le sexe font exception : leurs colonnes n'acceptent pas de texte,
-- ils restent donc vides. Un âge noté autrement qu'en années (« 16 mois »)
-- est reporté en clair dans les antécédents pour ne pas être perdu.
--
-- Les consultations importées portent un numéro préfixé « AMSTC-G26- » : elles
-- sont ainsi reconnaissables d'un coup d'oeil, et le garde-fou anti-doublon s'y
-- appuie pour ne jamais réimporter — sans gêner les consultations saisies
-- normalement sur ce compte, qui restent intactes.
--
-- Le script retrouve seul le compte, la campagne et les sites : rien à renseigner.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

do $$
declare
  v_agent  uuid;
  v_camp   uuid;
  v_dabakh uuid;
  v_mame   uuid;
  v_seydil uuid;
  v_deja   int;
begin
  -- 1) Le compte qui portera ces consultations
  select id into v_agent from public.profiles
   where lower(email) = lower('presseinfosamstc@gmail.com');
  if v_agent is null then
    raise exception 'Compte introuvable pour presseinfosamstc@gmail.com. Créez-le et activez-le avant de relancer.';
  end if;

  -- 2) La campagne
  select id into v_camp from public.campagnes where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
  if v_camp is null then
    raise exception 'Campagne introuvable : Couverture Médicale du Gamou de Tivaouane 2026';
  end if;

  -- 3) Les trois sites de cette campagne
  select id into v_dabakh from public.sites where campagne_id = v_camp and nom = 'Cité Dabakh';
  select id into v_mame   from public.sites where campagne_id = v_camp and nom = 'Hôpital Mame Abdou';
  select id into v_seydil from public.sites where campagne_id = v_camp and nom = 'Hôpital Seydil Hadji Malick';
  if v_dabakh is null or v_mame is null or v_seydil is null then
    raise exception 'Site manquant dans la campagne (Cité Dabakh / Hôpital Mame Abdou / Hôpital Seydil Hadji Malick). Vérifiez les noms exacts dans l''onglet Campagnes.';
  end if;

  -- 4) La colonne des actes doit exister : l'import s'appuie dessus
  if not exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'consultations'
                    and column_name = 'actes_medicaux') then
    raise exception 'Colonne actes_medicaux absente : exécutez d''abord rls_actes_medicaux.sql, puis relancez cet import.';
  end if;

  -- 5) Garde-fou : ne jamais importer deux fois
  -- On ne compte QUE les lignes de CET import, reconnaissables à leur numéro
  -- « AMSTC-G26- ». Une consultation saisie normalement sur ce compte ne doit pas
  -- empêcher l'import : c'est un vrai dossier patient, elle reste intacte.
  select count(*) into v_deja from public.consultations
   where agent_id = v_agent and numero_consultation like 'AMSTC-G26-%';
  if v_deja > 0 then
    raise exception 'Import déjà effectué : % consultation(s) portent déjà le numéro AMSTC-G26-. Rien n''a été modifié.', v_deja;
  end if;

  -- 6) L'import
  insert into public.consultations
    (id, numero_consultation, patient_id, agent_id, site_id, medecin_nom,
     type_consultation, created_at, prenom, nom, age, sexe, adresse,
     telephone_patient, motifs, signes, diagnostic, conduite, actes_medicaux, medicaments)
  values
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Dr Moustapha Ndiaye', 'generaliste', '2026-08-25 12:00:00+00', 'Seynabou', 'Drone (?)', 21, null, '-', null, '-', '-', '-', 'Spasfon 2cp x2/j ; Ciprofloxacine 500 1cp x2/j 7j ; Azithromycine 500 1cp/j 3j', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', 'Ndèye Astou', 'Diop', 76, null, '-', null, '-', '-', '-', 'Paracétamol 1g ; (?) ; (?) 10mg au coucher ; Voltarène emulgel', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', 'Ndèye', 'Ndiaye', 18, null, '-', null, '-', '-', '-', 'Bena (?) 1g 1cp x3/j ; Amoxicilline 500mg 1cp x3/j', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Dr Moustapha Ndiaye', 'generaliste', '2026-08-25 12:00:00+00', 'Fatou', 'Diop', 12, null, '-', null, '-', '-', '-', 'Litacold sachet 1s x3/j ; Bodex 500mg ; Vitamine C', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', 'Astou', 'Diouf', null, null, '-', null, '-', '-', '-', 'Paracétamol 1g ; Rhinomycine (?) 1cp x2/j 5j ; Vitamine C', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', 'Ramata', 'Diaw', null, null, '-', null, '-', '-', '-', 'Paracétamol 500 2cp x3/j ; Ibuprofène 400 1cp x2/j ; Vitamine C', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Registre papier Gamou 2026', 'generaliste', '2026-08-25 12:00:00+00', 'Khadi', 'Diallo', null, null, '-', null, '-', '-', '-', 'Rapiden 2cp x2/j ; Vitamine C 1cp/j', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_dabakh, 'Dr Ndèye Mariétou Danfakha', 'generaliste', '2026-08-25 12:00:00+00', 'Khady', 'Diop', 20, null, '-', null, '-', '-', '-', 'Lysoflam pommade ; Spasfon 2cp x2/j ; Acéclofénac 100 1cp/j', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Diouf', 'generaliste', now(), 'Aïda', 'DIA', 26, 'F', 'Louga', '77 439 40 71', '-', '-', '-', 'Genpar ; Restrivar (?) ; Kit perfuseur', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Ndèye Fatou', 'NDIAYE', null, null, 'Golf Sud', null, '-', '-', '-', 'Tanganil 1cp x2/j ; UPSA-C 1cp/j', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Aïda (?)', 'THIAM', 41, null, 'Dakar', '75 362 74 09', '-', '-', '-', 'Amoxicilline-Ac.clav ; Flagyl ; Xylase 1g', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Fatou', 'NGuirane', 19, 'F', '-', null, 'Douleur abdominale aiguë, vomissements, diarrhée', 'Douleur épigastrique ; tachycardie', 'TIAC', 'Oméprazole ; Tiorfan ; Paracétamol', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Amy', 'NDAO', null, 'F', 'Kaffrine', '77 872 56 30', 'Traumatisme fermé main droite', 'Douleur à la supination', 'Fracture des 2 os de la main', 'Transféré en orthopédie', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Aïcha', 'Ndong', 19, 'F', 'Keur Massar', '78 218 34 17', 'Céphalées, algies diffuses', 'Congestion nasale ; odynophagie', 'Syndrome grippal', 'Rapidex 2cp x3 ; Vitamine C', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Anta', 'Hanne', 26, 'F', 'Mandia (?)', '78 663 51 15', 'Céphalées, rhinorrhée, fièvre, algies diffuses', 'Sensibilité abdominale ; myalgie', 'Syndrome grippal ou accès palustre ?', 'Perfalgan + Restivar ; GE + NFS', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Mareme', 'Ndoye', 46, 'F', 'Grand Mbao', '77 185 96 75', 'Épigastralgie déclenchée par les repas', 'Sensibilité épigastrique', 'Syndrome ulcéreux', 'Bolus IPP puis relais per os ; FOGD', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Mane', 'NDOYE', 23, 'F', 'Ouakam', '77 641 13 02', 'Douleur thoracique, dyspnée, épigastralgie', 'Tachycardie ; muqueuses pâles', 'Syndrome anémique', 'NFS, GSRH, ECG ; fer ; antalgique', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Farguèye', 'Dieng', 24, 'F', 'Dakar', '77 804 84 15', 'RGO', 'Sensibilité épigastrique', 'RGO', 'Gastrisol (?) ; Oméprazole 20', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Nassogui', 'Ndiaye', 25, 'M', 'Yenne (?)', '77 384 86 58', 'Douleur abdominale aiguë, vomissement, céphalées', 'Douleur épigastrique ; tachycardie', 'TIAC', 'SG 5% ; Perfalgan ; Spasmo-Apotel, Tiorfan', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Nadou', 'Diatta', 18, null, 'Mbour (?)', '78 180 59 42', 'Céphalées, douleur abdominale, nausées', 'Douleur fosse iliaque droite', 'Douleur abdominale (GEA)', 'Écho normale ; Spasfon + Diclop', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Woly', 'Ngom', 25, 'M', 'Diamdiou (?)', '76 801 33 50', 'Traumatisme ouvert pied gauche', 'Plaie linéaire profonde', 'Plaie', 'SAT + VAT ; Amoxicilline-ac. clav.', 'Mise en observation; Pansement', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'Aminata', 'DIENE (Dièye ?)', 32, 'F', 'Yeumbeul', '77 731 29 22', 'Algies diffuses, céphalées', 'Sans particularité', 'Syndrome grippal', 'Aptaflu ; Vitamine C', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Ibrahima', 'Ba', 25, null, 'Tivaouane', '77 342 59 06', 'Lomboscialtalgie', 'Lasègue (+)', 'Lomboscialtalgie L4-L5', 'Prednisolone 20 ; TDM rachis lombaire', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Ndèye Mariétou Danfakha', 'generaliste', now(), 'El Hadji Mor', 'Mbaye', null, 'M', 'Louga', '78 049 37 11', 'Douleur abdominale, 3 épisodes de diarrhée', 'Douleur épigastrique', 'Entérite / syndrome grippal', 'IPP + antispasmodique', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ndèye Fatou', '-', 26, 'F', 'Thiaroye (?)', '76 527 30 49', '-', '-', '-', 'Kit perfusion ; Genpar 1g IV ; SG 5%', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Rokhaya', 'DIOP', 63, 'F', 'Diakhao (?)', '77 221 12 42', '-', '-', '-', 'SAT ; compresses ; bande Velpeau', 'Mise en observation; Pansement', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Seynabou', 'SECK', 60, 'F', '-', '78 597 94 12', '-', '-', '-', 'Xylaa 1g ; Azithromycine 500 ; UPSA-C', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Moulaye', 'Seck', 26, 'M', 'Kelle (?)', null, 'Bilan de santé', '-', 'Bilan', 'NFS, CRP, bilan lipidique, HbA1c, iono', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Daouda', 'Cissé', 18, 'M', 'Yène', '77 744 79 88', '-', '-', '-', 'Astaph ; Xylaa 500mg', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Fam (?)', 'Diagne (?)', 18, 'F', 'Thiaroye', '78 537 40 61', '-', '-', '-', 'Astaph ; Xylaa 1g', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Maïmouna', 'DIENG', 24, 'F', 'Diourbel', '77 137 22 30', '-', '-', '-', 'Anthrim GH ; Diclop ; UPSA-C', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Dr Mouhamed Badji', 'generaliste', now(), 'Ibou', 'Ndiaye', 36, null, 'Mbour', '77 955 44 72', '-', '-', '-', 'Miorel ; Vasogel ; Doucothymol ; Xylaa 1g', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ndeye', 'Diop', null, null, '-', null, '-', '-', 'Acidocétose diabétique', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Samba', 'Sarr', 34, null, '-', null, '-', '-', 'Syndrome coronarien', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Anta', 'Teuw', null, null, '-', null, '-', '-', 'Insuffisance cardiaque', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Yaye Mbaye', 'Niang', 16, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ndoya', 'Sarr', 28, null, '-', null, '-', '-', 'Gastro-entérite aiguë', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Maman', 'Diop', null, null, '-', null, '-', '-', 'SRIS', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Aïcha', 'Niang', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Sophie', 'Sarr', 56, null, '-', null, '-', '-', 'Urgence hypertensive', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), 'Mignane', 'Faye', 23, null, '-', null, '-', '-', 'Suspicion de paludisme grave', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Appendicite', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Appendicite', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Appendicite', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Fracture du bassin', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Fracture du bassin', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Fracture de la tête humérale', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Panaris', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'SJPU avec souffrance rénale', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Acidocétose', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Hystérie', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Pneumonie dyspnéisante', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Contusion du bassin', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Paludisme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Traumatisme fermé cheville gauche', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Traumatisme fermé cheville droite', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Traumatisme fermé jambe droite', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Piqûre de scorpion', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Grippe', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Dermohypodermite bactérienne non nécrosante', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Dermohypodermite bactérienne non nécrosante', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Traumatisme thoracique', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Crise d''asthme', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Hystérie', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Rétention aiguë d''urine', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Diabète décompensé en acidocétose', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_mame, 'Registre papier Gamou 2026', 'generaliste', now(), '-', '-', null, null, '-', null, '-', '-', 'Thrombose veineuse profonde', '-', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Papa Malick', 'Diouf', 43, null, 'Rufisque', null, 'Fatigue', 'Muqueuses pâles anictériques', '-', 'ATG ; Stimol ; NFS', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ousmane', 'Ka', 58, null, 'PIRE', null, 'Algies diffuses, lésions vésiculeuses', 'Lésions groupées avant-bras droit et dos, prurigineuses', '-', 'Paracétamol ; Vitamine C ; antihistaminique', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Diagne', 'Cissé', 27, null, 'Rufisque', null, 'Céphalées, rhinorrhée limpide', 'Tachycardie ; sensibilité épaules', 'Syndrome grippal', 'ATG puis relais per os', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Saliou', 'N''Guer', 18, null, 'Tivaouane', null, 'Douleur fosse lombaire bilatérale', 'Sans particularité', '-', 'ATG / AINS ; TDM abdominale, ECBU', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Modou (?)', 'Ndiaye', 73, null, 'PIRE', null, 'Vertiges, bourdonnements d''oreilles', 'Arythmie auscultatoire ; PA 198/121', '-', 'ECG ; protocole Loxen ; fond d''œil, ETT', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Issa', 'Bâ', 4, null, 'PIRE', null, 'Impotence fonctionnelle MS gauche depuis 3 ans', 'Déficit moteur MS gauche', 'Trauma ancien épaule gauche', 'ATG ; TDM rachis cervical', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Mbaye', 'Samb', 9, null, 'Mbour', null, 'Douleur abdominale péri-ombilicale', 'Sensibilité sans défense', '-', 'Viscéralgine ; Albendazole ; écho', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Thiao', 'Nguingue', 19, null, 'Tivaouane', null, 'Douleur abdominale, diarrhée, vomissements, toux', 'GEA ; condensation pulmonaire', 'GEA + condensation pulmonaire', 'Rapidex, ATB, Smecta ; Rx thorax', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ramata', 'Bâ', 60, null, 'Ndoula', null, 'Traumatisme ouvert coude gauche (AVP)', 'Plaie 3cm ; tuméfaction coude gauche', 'Plaie + dermabrasion', 'Suture ; ATG-ATB ; SAT-VAT ; Rx', 'Suture; Pansement', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Amy', 'Sarr', 15, null, 'PIRE', null, 'Douleur hypogastrique, leucorrhées', 'Tachycardie auscultatoire', 'Infection uro-génitale ?', 'ATG ; Prazol Kit ; fer', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'El Hadj', 'Sall', 40, null, 'PIRE', null, 'Algies diffuses, diarrhée', '-', 'Syndrome grippal', 'Antipyrétique / multivitamines', 'Mise en observation', '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ndèye Bator', 'Touré', 13, null, 'Cité Fadia', null, 'Diarrhée', 'Muqueuses pâles, pas d''œdème', '-', 'Perfalgan ; Smecta ; Flagyl ; SRO', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Mouhamadou Elimane', 'Ly', null, null, '-', null, 'Tuméfaction sous-mandibulaire', 'Tuméfaction ferme sans collection', '-', 'ATG ; NFS, CRP ; Efferalgan sirop', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Penda', 'Sow', 33, null, '-', null, 'Céphalées, flou visuel', 'Sans particularité', '-', 'ATG + consultation', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Deba', 'Dia', 4, null, 'Ndakou (?)', null, 'Algies diffuses, ballonnement abdominal, constipation', '-', 'Parasitose intestinale', 'Paracétamol + Vitamine C ; Flunarizine (?) ; Métronidazole', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Sokhna (?)', 'Nguer Sall', null, null, 'Keur Sall', null, 'Poids 58 kg ; TA 140/55 ; FC 71', '-', '-', '-', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Ababacar (?)', 'Khadr Diouf', null, null, 'Keur Sala', null, 'Douleur abdominale', '-', '-', 'Spasfon ; Albendazole (?)', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Cheikh', 'Sadbou Sène', null, null, 'Tivaouane', null, 'T 36,2 ; TA 197/18 (?) ; FC 57', '-', 'Syndrome grippal', 'Amoxicilline-ac. clav. ; Paracétamol ; Vitamine C', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Fama', 'Diop', 44, null, 'Keur Ladre (?)', null, 'TA 190/171 (?) ; FC 85 ; T 37', '-', '-', '-', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Maguette', 'Nguer', null, null, 'Keur Sala', null, 'Algies diffuses, toux sèche ; TA 146/85 ; FC 63 ; SpO2 98%', '-', 'HTA', 'Bilan HTA : NFS, ECG, fond d''œil, créatinine', null, '[]'::jsonb),
  (gen_random_uuid(), 'AMSTC-G26-'||upper(substring(gen_random_uuid()::text,1,8)), gen_random_uuid(), v_agent, v_seydil, 'Registre papier Gamou 2026', 'generaliste', now(), 'Maguette', 'Sène (?)', null, null, '-', null, '-', '-', '-', '-', null, '[]'::jsonb);

  raise notice 'Import terminé : % consultations.', 108;
end $$;

-- Âges notés autrement qu'en années, conservés en clair :
update public.consultations set antecedents = 'Âge noté sur le registre : 16 mois'
 where prenom = 'Mouhamadou Elimane' and nom = 'Ly' and antecedents is null;
update public.consultations set antecedents = 'Âge noté sur le registre : 99 (?)'
 where prenom = 'Cheikh' and nom = 'Sadbou Sène' and antecedents is null;
update public.consultations set antecedents = 'Âge noté sur le registre : 25 (?)'
 where prenom = 'Maguette' and nom = 'Sène (?)' and antecedents is null;
