-- =====================================================================
-- Référence vers un hôpital ou une structure externe
-- =====================================================================
-- Jusqu'ici, référer un patient signifiait forcément l'orienter vers un
-- CONFRÈRE PRÉSENT SUR LE SITE : la colonne refere_vers_id pointe vers le
-- compte utilisateur de ce praticien.
--
-- Or un praticien doit aussi pouvoir orienter un patient vers une structure
-- extérieure à la campagne (hôpital, centre de santé), qui n'a évidemment
-- aucun compte dans l'application. Un identifiant de compte ne peut pas
-- accueillir ce nom : d'où cette colonne de texte libre, distincte.
--
-- Les deux formes s'excluent : une consultation référée vers un hôpital a
-- refere_vers_id à NULL, et inversement. Une référence vers l'extérieur
-- n'apparaît donc dans la boîte "patients référés" de personne, ce qui est
-- exactement le comportement voulu.
--
-- Aucune nouvelle règle de sécurité n'est nécessaire : la lecture et
-- l'écriture de cette colonne suivent exactement celles des autres colonnes
-- d'une consultation, déjà couvertes par les policies en place.
--
-- SANS CE SCRIPT, l'application continue de fonctionner normalement : le
-- champ n'est envoyé à la base que si une référence vers un hôpital est
-- réellement saisie. Tant qu'il n'est pas exécuté, seule CETTE
-- fonctionnalité échoue - avec un message explicite à l'écran.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Ce script peut être relancé sans risque.
-- =====================================================================

alter table public.consultations
  add column if not exists refere_hopital text;

-- Accélère le calcul du taux de référencement, qui filtre sur cette colonne
-- en plus de refere_vers_id. L'index partiel ne porte que sur les lignes
-- réellement référées vers l'extérieur : elles sont minoritaires, l'index
-- reste donc petit.
create index if not exists consultations_refere_hopital_idx
  on public.consultations (refere_hopital)
  where refere_hopital is not null;
