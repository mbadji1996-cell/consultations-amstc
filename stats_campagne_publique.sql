-- ============================================================
-- Statistiques publiques d'une campagne, pour le bandeau « Événement
-- phare » des accueils d'amstc.org et de consultations-amstc.org.
--
-- Le CMS d'amstc.org enregistre l'ID d'une campagne (champ « Campagne
-- consultations liée ») ; les deux bandeaux appellent alors cette
-- fonction avec la clé anon pour afficher, en direct, quatre agrégats :
-- malades consultés, âge moyen, répartition des sexes, ordonnances.
--
-- Sécurité : SECURITY DEFINER pour passer outre la RLS de la table
-- consultations, mais la fonction ne renvoie QUE des agrégats calculés -
-- aucune ligne, aucun nom, aucun identifiant patient. C'est le même
-- niveau d'information que ce que l'association publie déjà dans ses
-- bilans. Une campagne inexistante renvoie simplement des zéros.
--
-- À exécuter une seule fois : Studio de l'instance CONSULTATIONS
-- (api.consultations-amstc.org) > SQL Editor > coller > Run.
-- ============================================================

create or replace function public.stats_campagne_publique(p_campagne_id uuid)
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object(
    -- Malades distincts : les consultations d'un même patient (suivi,
    -- référence) ne comptent qu'une fois quand patient_id est renseigné.
    'malades', count(distinct coalesce(c.patient_id::text, c.id::text)),
    'age_moyen', round(avg(c.age) filter (where c.age is not null and c.age between 0 and 120)),
    'hommes', count(*) filter (where c.sexe = 'M'),
    'femmes', count(*) filter (where c.sexe = 'F'),
    -- Une ordonnance = une consultation avec au moins un médicament.
    'ordonnances', count(*) filter (
      where jsonb_typeof(to_jsonb(c.medicaments)) = 'array'
        and jsonb_array_length(to_jsonb(c.medicaments)) > 0
    )
  )
  from public.consultations c
  join public.sites s on s.id = c.site_id
  where s.campagne_id = p_campagne_id;
$$;

-- Lecture publique assumée : agrégats uniquement (voir en-tête).
grant execute on function public.stats_campagne_publique(uuid) to anon, authenticated;
