-- =====================================================================
-- Identifiant patient stable
-- =====================================================================
-- Jusqu'ici, retrouver l'historique d'un patient reposait uniquement sur une
-- correspondance approximative de nom/téléphone (voir rls_historique_patient.sql) -
-- fragile pour une population itinérante, parfois non-identifiée administrativement,
-- dont le nom peut être orthographié différemment d'un site à l'autre.
--
-- Cette colonne donne à chaque patient un identifiant permanent (généré côté app à
-- sa première consultation, repris tel quel à chaque visite suivante - référencement,
-- "Reprendre ce dossier" depuis l'historique, ou scan du QR de sa fiche imprimée).
-- Les anciennes consultations (avant cette fonctionnalité) auront ce champ vide :
-- elles restent consultables par la recherche nom/téléphone existante, simplement
-- sans le lien direct par identifiant.
--
-- Aucune nouvelle règle de sécurité n'est nécessaire : la lecture est déjà couverte
-- par les policies existantes (propre site pour un agent, tous sites pour la policy
-- "consult_historique_patient_lecture"), et l'écriture passe par le même chemin que
-- toutes les autres colonnes d'une consultation (INSERT par son auteur).
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

alter table public.consultations
  add column if not exists patient_id uuid;

-- Accélère la recherche "Reprendre ce dossier" / le scan du QR (recherche exacte par
-- égalité, contrairement à la recherche nom/téléphone qui utilise déjà un index texte).
create index if not exists consultations_patient_id_idx on public.consultations (patient_id);
