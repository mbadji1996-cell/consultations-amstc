-- =====================================================================
-- Effectifs réellement mobilisés sur une campagne
-- =====================================================================
-- Le rapport comptait les effectifs à partir des COMPTES rattachés à la
-- campagne. C'est une approximation qui se tient pour les praticiens qui
-- saisissent leurs consultations, mais qui manque tous les autres : un
-- infirmier venu prêter main-forte sans compte, un renfort de dernière
-- minute, un bénévole. L'équipe affichée était donc systématiquement
-- inférieure à l'équipe réelle.
--
-- Cette colonne permet de déclarer les effectifs tels qu'ils ont été
-- mobilisés. Quand elle est renseignée, le rapport l'utilise et le dit ;
-- sinon il retombe sur le comptage des comptes, comme avant.
--
-- Format : un objet JSON par profession, par exemple
--   {"generaliste": 6, "dentiste": 2, "infirmier": 4, "pharmacien": 3}
-- Les professions absentes ou à zéro ne sont pas affichées.
--
-- Aucune nouvelle règle de sécurité n'est nécessaire : cette colonne suit
-- celles de la table campagnes, déjà couvertes par les policies en place.
--
-- SANS CE SCRIPT, l'application continue de fonctionner : la déclaration
-- n'est envoyée que si au moins un effectif est saisi.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- =====================================================================

alter table public.campagnes
  add column if not exists effectifs_declares jsonb;
