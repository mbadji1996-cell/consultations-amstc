-- =====================================================================
-- Rôle Infirmier - patients référés uniquement
-- =====================================================================
-- Un infirmier ne voit que les consultations qui lui sont référées par un
-- confrère (déjà couvert par les règles existantes sur refere_vers_id, qui
-- ne dépendent pas du rôle/spécialité). Il ne manque que deux colonnes pour
-- enregistrer l'acte réalisé (pansement, mise en observation, surveillance...)
-- et la fonction dédiée pour les écrire en toute sécurité.
--
-- À exécuter une seule fois dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

alter table public.consultations
  add column if not exists acte_infirmier text,
  add column if not exists acte_infirmier_note text;

-- Écriture exclusivement via cette fonction : ne touche jamais qu'aux 3 colonnes
-- de l'acte, et uniquement sur les références destinées à l'infirmier connecté
-- (même principe de sécurité que mark_medicament_delivered / marquer_reference_traitee).
create or replace function enregistrer_acte_infirmier(
  p_consultation_id uuid,
  p_acte text,
  p_note text
)
returns void
language plpgsql
security definer
as $$
begin
  update public.consultations
  set acte_infirmier = p_acte,
      acte_infirmier_note = p_note,
      refere_traite = true
  where id = p_consultation_id
    and refere_vers_id = auth.uid();
end;
$$;
