-- =====================================================================
-- Historique patient (recherche tous sites/campagnes confondus)
-- =====================================================================
-- Aujourd'hui, un médecin/dentiste/spécialiste ne voit (très probablement)
-- que les consultations de son propre site via les règles de sécurité (RLS)
-- déjà en place. La nouvelle recherche "Historique patient" a besoin de
-- pouvoir retrouver un patient même vu sur un AUTRE site, lors d'une autre
-- campagne (continuité des soins pour les patients qui reviennent).
--
-- Cette policy est purement ADDITIVE : elle élargit ce qu'un praticien peut
-- LIRE (jamais modifier), sans toucher aux règles déjà en place (RLS combine
-- plusieurs policies SELECT avec un "OU" - celle-ci n'en retire aucune).
-- Les pharmaciens ET les infirmiers sont volontairement exclus : ni l'un ni
-- l'autre n'ont l'onglet "Historique patient" dans l'app (délivrances déjà
-- visibles ailleurs pour le pharmacien ; l'infirmier ne doit voir QUE les
-- patients qui lui sont référés, jamais l'historique complet d'un patient).
--
-- CORRECTIF (à ré-exécuter même si vous avez déjà lancé une version
-- précédente de ce script) : la toute première version de cette policy
-- n'excluait que "pharmacien", oubliant "infirmier" - un compte Infirmier
-- pouvait donc lire l'historique clinique complet de tous les sites, ce qui
-- contredit son périmètre voulu. Le "drop policy if exists" ci-dessous rend
-- ce script sûr à relancer.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

drop policy if exists "consult_historique_patient_lecture" on public.consultations;

create policy "consult_historique_patient_lecture"
on public.consultations
for select
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role = 'agent'
      and p.specialite not in ('pharmacien', 'infirmier')
  )
);
