-- =====================================================================
-- Analyse de fin de campagne — Gamou de Tivaouane 2026
-- =====================================================================
-- Ces trois textes sont la synthèse du débriefing anonyme de l'équipe
-- médicale : 34 réponses recueillies du 28 août 2026, sur une soixantaine
-- d'intervenants mobilisés.
--
-- Ils remplissent les champs bilan_difficultes, bilan_besoins et
-- bilan_recommandations de la campagne, et sont repris tels quels dans la
-- dernière page du rapport PDF et Word.
--
-- Les verbatims ne sont ni cités ni attribués : le formulaire était anonyme,
-- et c'est cette garantie qui a permis de recueillir les remarques les plus
-- utiles. Les chiffres cités sont donnés en effectifs bruts (« 27 sur 34 »)
-- et non en pourcentages seuls : un pourcentage sur 34 répondants laisserait
-- croire à une précision que l'échantillon ne porte pas.
--
-- PRÉREQUIS : rls_bilan_campagne.sql doit avoir été exécuté.
--
-- Vous pouvez aussi saisir ces textes à la main dans l'application :
-- onglet Campagnes > Détails > Analyse de fin de campagne > Enregistrer.
-- Faire l'un ou l'autre, pas besoin des deux.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Relançable sans risque.
-- =====================================================================

update public.campagnes set

bilan_difficultes =
'Un débriefing anonyme a recueilli 34 réponses auprès de l''équipe médicale, soit environ six intervenants sur dix.

La rupture de médicaments domine largement : 27 répondants sur 34 la citent, loin devant toute autre difficulté. Les produits nommément manquants sont la vitamine C, en rupture dès la première journée et citée par 8 répondants ; les antiparasitaires albendazole et mébendazole, épuisés le soir de la deuxième journée (6 mentions) ; les antihistaminiques et les inhibiteurs de la pompe à protons (4 chacun) ; les antihypertenseurs et le paracétamol injectable (3 chacun). La rupture d''antihypertenseurs est survenue alors qu''une urgence hypertensive était prise en charge, avec une tension systolique relevée à 19.

Le matériel de diagnostic de base vient ensuite (14 répondants sur 34) et obtient la note la plus basse de l''évaluation, 2,8 sur 5. Thermomètres, tensiomètres, glucomètres et balances étaient en nombre insuffisant, au point que des équipes ont dû attendre qu''un appareil se libère pour poursuivre leurs consultations. Un site ne disposait que d''un seul tensiomètre fonctionnel et d''aucune balance.

Le transport et l''évacuation constituent la troisième difficulté. Le dispositif de référence est jugé insuffisant ou très insuffisant par 9 des 17 praticiens qui y ont eu recours, et n''obtient qu''une seule note favorable. Un patient a été transféré vers un hôpital dans un véhicule non médicalisé, et du personnel a rejoint son site à pied, faute de moyen de transport.

L''affluence a pesé surtout pendant la consultation elle-même (13 réponses) et aux heures de pointe (10). L''emplacement des urgences, installées sous les tentes des postes médicaux avancés, a été jugé inadapté par plusieurs praticiens, de même que l''absence d''espace fermé garantissant la confidentialité des entretiens.

Un point d''organisation a enfin été signalé avec insistance : des étudiants de sixième année ont consulté deux journées durant sans encadrement senior et sans rotation entre les sites, alors que les praticiens confirmés étaient regroupés ailleurs. La remarque porte moins sur la charge de travail que sur la perte d''une occasion de formation.',

bilan_besoins =
'Chaque répondant devait désigner au plus trois priorités, ce qui donne un classement et non une liste de souhaits.

Augmentation du stock de médicaments : 22 répondants sur 34.
Matériel et médicaments d''urgence : 17 sur 34.
Moyens de transport et d''évacuation : 15 sur 34.
Renforcement du personnel paramédical (infirmiers, sages-femmes) : 7 sur 34, à égalité avec l''amélioration des locaux.
Renforcement du personnel médical et organisation des équipes : 5 sur 34 chacun.
Matériel de diagnostic, moyens de communication entre les sites et système informatisé de collecte : 4 sur 34 chacun.

Ces trois premières priorités se retrouvent dans les réponses libres. Cinq répondants demandent explicitement la mise à disposition d''une ambulance médicalisée, deux réclament un espace dédié aux mises en observation, et un site signale un manque d''eau potable pour les équipes.

Sur la collecte des données, l''information que l''équipe souhaite le mieux voir renseignée est le devenir du patient — domicile, observation, référence ou évacuation — citée par 11 répondants sur 34, devant les médicaments effectivement dispensés (8) et le diagnostic (7). Le système de collecte lui-même obtient une note de 3,6 sur 5, et 19 répondants sur 32 déclarent n''avoir jamais ou rarement eu de mal à renseigner les fiches.',

bilan_recommandations =
'1. Constituer un stock tampon sur les produits qui ont rompu, et suivre les sorties en temps réel pendant la campagne. Les six familles concernées sont connues : vitamine C, antiparasitaires (albendazole, mébendazole), antihistaminiques, inhibiteurs de la pompe à protons, antihypertenseurs et paracétamol injectable. La vitamine C étant partie dès le premier jour, son volume doit être révisé en priorité.

2. Doter chaque box de consultation d''un thermomètre, d''un tensiomètre et d''un glucomètre en propre. Le partage d''appareils entre box a directement ralenti les consultations.

3. Disposer d''une ambulance médicalisée pendant toute la durée de la couverture, pour l''évacuation des patients comme pour le déplacement des équipes entre les sites. C''est la demande la plus explicitement formulée du débriefing.

4. Installer les urgences et les mises en observation dans un espace dédié, distinct des tentes de consultation, et prévoir des box fermés garantissant la confidentialité des entretiens.

5. Organiser l''encadrement des étudiants en binôme avec un praticien confirmé, et mettre en place une rotation entre les sites. La couverture est aussi un temps de formation : l''équipe le demande explicitement.

6. Renseigner systématiquement le devenir du patient sur chaque fiche. C''est l''information la plus réclamée par l''équipe, et celle qui manque aujourd''hui pour mesurer ce que la couverture a réellement produit.

7. Reconduire le dispositif. Les 34 répondants se prononcent pour sa reconduction : 23 avec quelques améliorations, 9 avec une réorganisation importante, 2 en l''état. Aucun avis défavorable.'

where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';

-- Contrôle : les trois champs doivent être renseignés.
select nom,
       length(bilan_difficultes)     as difficultes,
       length(bilan_besoins)         as besoins,
       length(bilan_recommandations) as recommandations
  from public.campagnes
 where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
