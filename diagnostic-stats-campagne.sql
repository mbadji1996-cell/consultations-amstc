-- ============================================================
-- DIAGNOSTIC - d'où vient l'écart entre les chiffres affichés
--
-- Le bandeau public d'amstc.org, le bilan PDF de campagne et l'onglet
-- Statistiques ne comptent PAS la même chose. Cette requête met les
-- trois définitions côte à côte pour une campagne donnée : on voit alors
-- lequel des chiffres est juste, et pourquoi ils diffèrent.
--
-- MODE D'EMPLOI : remplacez l'identifiant ci-dessous par celui de la
-- campagne à vérifier (celui du champ « Campagne consultations liée »
-- dans le CMS), puis exécutez dans le Studio de l'instance CONSULTATIONS.
--
-- Aucune écriture : cette requête ne fait que lire et compter.
-- ============================================================

with c as (
  select cs.*
    from public.consultations cs
    join public.sites s on s.id = cs.site_id
   where s.campagne_id = '95af9ed0-96d8-4df1-9b69-8a2884832289'::uuid   -- <== l'identifiant de la campagne
)
select
  -- 1. Ce que compte l'onglet Statistiques : une LIGNE = une consultation.
  count(*)                                                    as consultations,

  -- 2. Ce que comptent le bandeau public et le bilan PDF : un MALADE.
  --    Deux consultations d'un même patient (suivi, référence) ne font
  --    qu'un malade dès que patient_id est renseigné.
  count(distinct coalesce(patient_id::text, id::text))        as malades_distincts,

  -- L'écart entre les deux = les consultations de suivi.
  count(*) - count(distinct coalesce(patient_id::text, id::text)) as consultations_de_suivi,

  -- 3. Le sexe : le dénominateur réel des pourcentages affichés.
  count(*) filter (where sexe = 'M')                          as hommes,
  count(*) filter (where sexe = 'F')                          as femmes,
  count(*) filter (where sexe = 'M' or sexe = 'F')            as sexe_renseigne,
  count(*) filter (where sexe is null or sexe not in ('M','F')) as sexe_manquant,

  -- 4. L'âge : le bandeau écarte les âges hors 0-120 ; s'il y a des
  --    valeurs aberrantes, la moyenne « brute » s'en ressent.
  count(*) filter (where age is not null)                     as age_renseigne,
  round(avg(age) filter (where age between 0 and 120))        as age_moyen_borne,
  round(avg(age) filter (where age is not null))              as age_moyen_brut,
  count(*) filter (where age is not null and (age < 0 or age > 120)) as ages_aberrants,

  -- 5. Ordonnances : une consultation avec au moins un médicament.
  count(*) filter (
    where jsonb_typeof(to_jsonb(medicaments)) = 'array'
      and jsonb_array_length(to_jsonb(medicaments)) > 0
  )                                                            as ordonnances,

  -- 6. Consultations rattachées à AUCUN site : invisibles partout.
  --    (Ce compte porte sur toute la base, pas sur la campagne.)
  (select count(*) from public.consultations where site_id is null) as sans_site_toutes_campagnes,

  -- 7. Le total de la base, toutes campagnes : au-delà de 1500, l'onglet
  --    Statistiques sous-compte (il ne charge que les 1500 dernières
  --    lignes avant de filtrer par campagne).
  (select count(*) from public.consultations)                 as total_base_toutes_campagnes
from c;

-- Détail des valeurs de « sexe » réellement présentes : si l'on trouve
-- autre chose que M, F et null (« Masculin », « m », « H »…), ces fiches
-- sont comptées nulle part dans la répartition.
select coalesce(sexe, '(vide)') as valeur_sexe, count(*) as nombre
  from public.consultations cs
  join public.sites s on s.id = cs.site_id
 where s.campagne_id = '95af9ed0-96d8-4df1-9b69-8a2884832289'::uuid
 group by 1 order by 2 desc;
