/**
 * =====================================================================
 * Débriefing de l'équipe médicale — Gamou de Tivaouane 2026
 * =====================================================================
 * Ce script crée automatiquement le formulaire complet dans Google Forms :
 * 18 questions, 7 sections, les options, les réglages d'anonymat et
 * l'affichage conditionnel de la question 16.
 *
 * COMMENT L'UTILISER
 *   1. Aller sur https://script.google.com  (compte Google de l'AMSTC)
 *   2. « Nouveau projet »
 *   3. Effacer tout le contenu de l'éditeur, coller CE fichier à la place
 *   4. Cliquer sur « Enregistrer » (icône disquette)
 *   5. Choisir la fonction « creerFormulaireDebriefing » puis « Exécuter »
 *   6. Google demande une autorisation : « Examiner les autorisations » →
 *      choisir le compte → « Paramètres avancés » → « Accéder à ... »
 *      Cet avertissement est normal : Google le montre pour tout script
 *      personnel non publié. Le script ne fait qu'écrire dans votre Drive.
 *   7. En bas, le journal d'exécution affiche deux liens :
 *      - le lien À PARTAGER avec l'équipe (WhatsApp)
 *      - le lien d'ÉDITION, pour relire et corriger le formulaire
 *
 * Le formulaire est créé dans « Mon Drive ». Relancer le script crée un
 * NOUVEAU formulaire, il n'écrase pas le précédent.
 * =====================================================================
 */

function creerFormulaireDebriefing() {

  var form = FormApp.create(
    "Débriefing — Couverture médicale du Gamou de Tivaouane 2026");

  form.setDescription(
    "Vous avez participé à la couverture médicale du Gamou de Tivaouane 2026. "
  + "Ce questionnaire sert à préparer la prochaine édition et à documenter le "
  + "rapport de campagne.\n\n"
  + "Il est ANONYME : aucune adresse e-mail n'est enregistrée et aucune réponse "
  + "ne peut vous être attribuée. Répondez franchement, y compris sur ce qui n'a "
  + "pas fonctionné — c'est précisément ce que nous cherchons à corriger.\n\n"
  + "Comptez cinq minutes. Toutes les questions sont facultatives sauf les deux "
  + "premières. Merci pour votre engagement pendant ces journées.");

  // --- Anonymat. L'API a changé de nom ; on essaie les deux formes. ---
  try {
    form.setEmailCollectionType(FormApp.EmailCollectionType.DO_NOT_COLLECT);
  } catch (e) {
    try { form.setCollectEmail(false); } catch (e2) {
      Logger.log("ATTENTION : désactivez vous-même la collecte des e-mails "
               + "(Paramètres > Réponses > Collecter les adresses e-mail).");
    }
  }
  form.setProgressBar(true);
  form.setAllowResponseEdits(false);

  // ==================== SECTION 1 — Vous et votre poste ================
  // (la première section est celle du titre : pas de saut de page ici)

  form.addMultipleChoiceItem()
    .setTitle("Quel était votre rôle pendant la couverture ?")
    .setChoiceValues([
      "Médecin généraliste",
      "Médecin spécialiste",
      "Chirurgien-dentiste",
      "Pharmacien(ne)",
      "Infirmier(ère)",
      "Sage-femme",
      "Assistant(e) ou bénévole",
      "Coordination"])
    .showOtherOption(true)
    .setRequired(true);

  form.addCheckboxItem()
    .setTitle("Sur quel(s) site(s) avez-vous travaillé ?")
    .setChoiceValues([
      "Cité Dabakh",
      "DEESS Djamil",
      "Hôpital Mame Abdou",
      "Hôpital Seydil Hadji Malick",
      "Keur Sidy Ahmed",
      "Thiénouma"])
    .setRequired(true);

  // ==================== SECTION 2 — Comment cela s'est passé ===========
  form.addPageBreakItem()
    .setTitle("Comment cela s'est passé sur votre site")
    .setHelpText("Une seule question. Notez chaque point de 1 à 5.");

  form.addGridItem()
    .setTitle("Sur votre site, comment évaluez-vous chacun de ces points ?")
    .setHelpText("1 = très insuffisant · 3 = correct · 5 = excellent")
    .setRows([
      "Organisation générale",
      "Coordination entre les intervenants",
      "Répartition du personnel entre les sites",
      "Disponibilité du matériel médical",
      "Disponibilité des médicaments",
      "Conditions de travail sur le site",
      "Système de collecte des données"])
    .setColumns(["1", "2", "3", "4", "5"]);

  // ==================== SECTION 3 — Difficultés ========================
  form.addPageBreakItem().setTitle("Difficultés rencontrées");

  form.addCheckboxItem()
    .setTitle("Quelles difficultés avez-vous rencontrées ?")
    .setChoiceValues([
      "Aucune difficulté notable",
      "Personnel insuffisant",
      "Affluence des patients",
      "Matériel médical insuffisant",
      "Rupture ou insuffisance de médicaments",
      "Accès aux examens complémentaires",
      "Locaux inadaptés (espace, hygiène, eau, électricité)",
      "Logistique et transport",
      "Communication et coordination entre les équipes",
      "Orientation des patients à l'intérieur du site",
      "Prise en charge des urgences",
      "Référence ou évacuation vers l'hôpital"])
    .showOtherOption(true);

  form.addMultipleChoiceItem()
    .setTitle("À quel moment ces difficultés ont-elles le plus pesé ?")
    .setChoiceValues([
      "Avant la campagne, à la préparation",
      "À l'installation des sites",
      "Aux heures de forte affluence",
      "Pendant la consultation",
      "À la dispensation des médicaments",
      "Face aux urgences",
      "Au moment de référer ou d'évacuer un patient"])
    .showOtherOption(true);

  form.addParagraphTextItem()
    .setTitle("Décrivez la difficulté qui a le plus gêné la prise en charge "
            + "des patients, et son effet concret.")
    .setHelpText("Exemple attendu : « Un seul tensiomètre pour trois box, ce qui "
                + "a fait attendre les patients hypertendus jusqu'à quarante minutes. »");

  // ==================== SECTION 4 — Urgences et référence ==============
  form.addPageBreakItem().setTitle("Urgences et référence");

  form.addMultipleChoiceItem()
    .setTitle("Avez-vous été gêné(e) dans la prise en charge des urgences ?")
    .setChoiceValues([
      "Jamais", "Rarement", "Parfois", "Souvent", "Très souvent",
      "Je n'ai pris en charge aucune urgence"]);

  form.addMultipleChoiceItem()
    .setTitle("Comment évaluez-vous le dispositif de référence et d'évacuation "
            + "vers l'hôpital ?")
    .setChoiceValues([
      "1 — Très insuffisant",
      "2 — Insuffisant",
      "3 — Correct",
      "4 — Bon",
      "5 — Excellent",
      "Je n'y ai pas eu recours"]);

  // ==================== SECTION 5 — Médicaments et besoins =============
  form.addPageBreakItem().setTitle("Médicaments, matériel et besoins");

  form.addParagraphTextItem()
    .setTitle("Quels médicaments ou consommables vous ont manqué ?")
    .setHelpText("Citez-les nommément, même approximativement. Précisez si "
                + "possible le moment de la rupture.");

  var besoins = form.addCheckboxItem()
    .setTitle("Quels besoins sont prioritaires pour la prochaine édition ?")
    .setHelpText("Trois choix au maximum.")
    .setChoiceValues([
      "Renforcement du personnel médical",
      "Renforcement du personnel paramédical (infirmiers, sages-femmes)",
      "Augmentation du stock de médicaments",
      "Matériel de diagnostic",
      "Matériel et médicaments d'urgence",
      "Amélioration des locaux",
      "Moyens de transport et d'évacuation",
      "Moyens de communication entre les sites",
      "Organisation et répartition des équipes",
      "Signalétique et orientation des patients",
      "Système informatisé de collecte des données",
      "Formation du personnel"]);

  // Le plafond de 3 est ce qui transforme une liste de souhaits en un
  // classement de priorités. Sans lui, tout le monde coche tout.
  try {
    besoins.setValidation(
      FormApp.createCheckboxValidation().requireSelectAtMost(3).build());
  } catch (e) {
    Logger.log("ATTENTION : ajoutez vous-même la limite de 3 choix sur la "
             + "question des besoins (menu 3 points > Validation des réponses "
             + "> Sélectionner au maximum 3).");
  }

  // ==================== SECTION 6 — Collecte des données ===============
  form.addPageBreakItem().setTitle("Collecte des données");

  form.addMultipleChoiceItem()
    .setTitle("Avez-vous eu du mal à renseigner les fiches des patients ?")
    .setChoiceValues([
      "Jamais", "Rarement", "Parfois", "Souvent", "Très souvent",
      "Je n'ai pas rempli de fiches"]);

  form.addCheckboxItem()
    .setTitle("Quelles informations devraient être mieux collectées la "
            + "prochaine fois ?")
    .setChoiceValues([
      "Âge et sexe",
      "Motif de consultation",
      "Diagnostic",
      "Constantes (tension, glycémie, température)",
      "Actes réalisés",
      "Examens demandés et leurs résultats",
      "Médicaments effectivement dispensés",
      "Devenir du patient (domicile, observation, référence, évacuation)"])
    .showOtherOption(true);

  // ==================== SECTION 7 — Ce qu'il faut retenir ==============
  form.addPageBreakItem().setTitle("Ce qu'il faut retenir");

  form.addParagraphTextItem()
    .setTitle("Si une seule mesure pouvait être prise avant la prochaine "
            + "édition, laquelle aurait le plus d'effet ?")
    .setHelpText("Une seule mesure, la plus utile selon vous.");

  form.addMultipleChoiceItem()
    .setTitle("Faut-il reconduire ce dispositif l'année prochaine ?")
    .setChoiceValues([
      "Oui, tel quel",
      "Oui, avec quelques améliorations",
      "Oui, mais avec une réorganisation importante",
      "Non"]);

  // Question 15 : elle doit être la DERNIÈRE de sa section pour pouvoir
  // aiguiller vers une section différente selon la réponse.
  var casClinique = form.addMultipleChoiceItem()
    .setTitle("Avez-vous vu un cas clinique ou une situation qui mérite de "
            + "figurer dans le rapport ?");

  // ---- Section réservée à la description du cas (affichée si « Oui ») ----
  var pbCas = form.addPageBreakItem().setTitle("Situation clinique remarquable");

  form.addParagraphTextItem()
    .setTitle("Décrivez brièvement la situation.")
    .setHelpText("Ne donnez aucun élément permettant d'identifier le patient : "
               + "ni nom, ni téléphone, ni adresse, ni date précise. L'âge "
               + "approximatif, le sexe et le tableau clinique suffisent.");

  // ---- Dernière section, commune aux deux chemins ----
  var pbFin = form.addPageBreakItem().setTitle("Pour finir");

  form.addMultipleChoiceItem()
    .setTitle("Détenez-vous des registres papier ou des fiches qui n'ont pas "
            + "encore été saisis dans l'application ?")
    .setHelpText("Trois des six sites du Gamou n'ont pas encore été saisis. "
               + "Cette question sert à retrouver leurs registres.")
    .setChoiceValues([
      "Oui, je les ai en ma possession",
      "Oui, et je sais qui les détient",
      "Non",
      "Je ne sais pas"]);

  form.addTextItem().setTitle("Une remarque à ajouter ?");

  // L'aiguillage se règle maintenant : les deux sections cibles existent.
  casClinique.setChoices([
    casClinique.createChoice("Oui", pbCas),
    casClinique.createChoice("Non", pbFin)]);

  // ==================== Liens ==========================================
  var lien = form.getPublishedUrl();
  try { lien = form.shortenFormUrl(lien); } catch (e) {}

  Logger.log("-------------------------------------------------------------");
  Logger.log("Formulaire créé : " + form.getTitle());
  Logger.log("LIEN À PARTAGER (WhatsApp) : " + lien);
  Logger.log("LIEN D'ÉDITION             : " + form.getEditUrl());
  Logger.log("-------------------------------------------------------------");
}
