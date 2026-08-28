-- =====================================================================
-- Gamou de Tivaouane 2026 : 4 infirmiers mobilisés
-- =====================================================================
-- Aucun des 4 infirmiers mobilisés sur la campagne n'avait de compte dans
-- l'application : ils ne saisissaient pas de consultations. Le rapport, qui
-- compte les effectifs d'après les comptes rattachés à la campagne, affichait
-- donc 0 infirmier.
--
-- Ce script déclare le chiffre réel. Les autres professions ne sont PAS
-- déclarées : elles gardent leur comptage automatique, qui était juste.
--
-- Ce script est une alternative à la saisie dans l'application (onglet
-- Campagnes > Détails > Effectifs mobilisés > Enregistrer). Faire l'un ou
-- l'autre, pas besoin des deux.
--
-- PRÉREQUIS : rls_effectifs_declares.sql doit avoir été exécuté.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Relançable sans risque.
-- =====================================================================

update public.campagnes
   set effectifs_declares = coalesce(effectifs_declares, '{}'::jsonb)
                            || jsonb_build_object('infirmier', 4)
 where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';

-- Contrôle : doit renvoyer {"infirmier": 4}
select nom, effectifs_declares
  from public.campagnes
 where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
