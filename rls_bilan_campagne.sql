-- =====================================================================
-- Devenir du patient, suivi des explorations, analyse de campagne
-- =====================================================================
-- Le rapport de campagne ne pouvait produire ni la page « Examens et
-- explorations », ni la page « Devenir », ni la page « Analyse et
-- recommandations » : les données n'existaient pas.
--
-- Ce qui manquait, précisément :
--
--   1. DEVENIR. On savait dire qu'un patient avait été référé ou mis en
--      observation, mais rien sur les autres : retour à domicile,
--      hospitalisation, évacuation. Le champ devient une liste fermée, pour
--      que les chiffres soient additionnables - un texte libre ne l'aurait
--      pas été.
--
--   2. EXPLORATIONS. Le champ existant ne dit que ce qui a été DEMANDÉ. On
--      ajoute donc : l'examen a-t-il été réalisé, quel résultat, et ce
--      résultat est-il anormal. C'est cette dernière information qui permet
--      de compter les anomalies dépistées - l'indicateur qui intéresse un
--      partenaire.
--
--   3. ANALYSE DE CAMPAGNE. Difficultés rencontrées, besoins constatés et
--      recommandations ne se calculent pas : ils s'écrivent. Trois champs
--      libres sur la campagne, saisis depuis l'onglet Campagnes et repris
--      tels quels dans le rapport.
--
-- Ces colonnes resteront vides pour les campagnes déjà passées : elles n'ont
-- pas été collectées sur le moment, et le rapport les traite comme telles
-- plutôt que d'inventer des valeurs. Elles seront complètes dès la prochaine
-- édition.
--
-- Aucune nouvelle règle de sécurité n'est nécessaire : ces colonnes suivent
-- celles de leur table, déjà couvertes par les policies en place.
--
-- SANS CE SCRIPT, l'application continue de fonctionner : chaque champ n'est
-- envoyé à la base que s'il est réellement renseigné.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- =====================================================================

-- --------------------------------------------------------------------
-- 1) Devenir du patient
-- --------------------------------------------------------------------
alter table public.consultations
  add column if not exists devenir text;

-- Index partiel : seules les consultations dont le devenir est renseigné sont
-- comptées dans le bilan, et elles seront longtemps minoritaires.
create index if not exists consultations_devenir_idx
  on public.consultations (devenir)
  where devenir is not null;

-- --------------------------------------------------------------------
-- 2) Suivi des explorations
-- --------------------------------------------------------------------
alter table public.consultations
  add column if not exists exploration_faite boolean;

alter table public.consultations
  add column if not exists exploration_resultat text;

-- Vrai quand le résultat est pathologique. C'est ce drapeau qui permet de
-- compter les anomalies dépistées, sans avoir à interpréter un texte libre.
alter table public.consultations
  add column if not exists exploration_anormale boolean;

-- --------------------------------------------------------------------
-- 3) Analyse et recommandations, au niveau de la campagne
-- --------------------------------------------------------------------
alter table public.campagnes
  add column if not exists bilan_difficultes text;

alter table public.campagnes
  add column if not exists bilan_besoins text;

alter table public.campagnes
  add column if not exists bilan_recommandations text;
