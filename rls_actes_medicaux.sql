-- =====================================================================
-- Actes réalisés pendant la consultation (côté médecin)
-- =====================================================================
-- Le formulaire du médecin, du dentiste et du spécialiste permet désormais
-- de cocher les actes réalisés pendant la consultation (mise en observation,
-- pansement, ou un acte précisé librement), en plus du traitement prescrit.
--
-- Une seule colonne de texte suffit : la sélection est enregistrée sous la
-- forme "Pansement; Mise en observation", exactement comme les diagnostics
-- et les actes dentaires. Les statistiques savent re-scinder cette chaîne
-- pour compter chaque acte séparément - une consultation comportant deux
-- actes alimente donc les deux lignes du bilan, et non une catégorie
-- composite qui n'aurait aucun sens.
--
-- À ne pas confondre avec acte_infirmier, qui existe déjà et concerne
-- uniquement la prise en charge par un infirmier d'un patient qui lui a été
-- référé : ce sont deux moments et deux intervenants différents.
--
-- Aucune nouvelle règle de sécurité n'est nécessaire : la lecture et
-- l'écriture de cette colonne suivent celles des autres colonnes d'une
-- consultation, déjà couvertes par les policies en place.
--
-- SANS CE SCRIPT, l'application continue de fonctionner normalement : le
-- champ n'est envoyé à la base que si au moins un acte est réellement coché.
-- Tant qu'il n'est pas exécuté, seule CETTE fonctionnalité échoue - avec un
-- message explicite à l'écran.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- =====================================================================

alter table public.consultations
  add column if not exists actes_medicaux text;

-- Accélère le comptage des actes dans le tableau de bord et le bilan final.
-- L'index partiel ne porte que sur les consultations comportant réellement
-- un acte : elles sont minoritaires, l'index reste donc petit.
create index if not exists consultations_actes_medicaux_idx
  on public.consultations (actes_medicaux)
  where actes_medicaux is not null;
