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
-- Les pharmaciens sont volontairement exclus : l'historique clinique ne
-- concerne pas leur périmètre (délivrances déjà visibles par ailleurs).
--
-- À exécuter une seule fois dans Supabase : Dashboard > SQL Editor > New query.
-- =====================================================================

create policy "consult_historique_patient_lecture"
on public.consultations
for select
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role = 'agent'
      and p.specialite <> 'pharmacien'
  )
);
