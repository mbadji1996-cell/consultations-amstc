-- ============================================================
-- NETTOYAGE des données de test du direct du Gamou
-- (contrepartie de donnees-test-gamou.sql)
--
-- Supprime les 18 consultations factices et le site de test, rien
-- d'autre. À exécuter une fois le test des bandeaux validé, et dans
-- tous les cas AVANT le 24 août pour que le direct parte de zéro.
--
-- À exécuter : Studio de l'instance CONSULTATIONS > SQL Editor > Run.
-- ============================================================

delete from public.consultations
 where prenom = 'TEST-GAMOU' and nom = 'À SUPPRIMER';

delete from public.sites
 where nom = 'SITE TEST GAMOU - À SUPPRIMER';

-- Contrôle : tout doit être revenu à zéro.
select public.stats_campagne_publique('95af9ed0-96d8-4df1-9b69-8a2884832289');
