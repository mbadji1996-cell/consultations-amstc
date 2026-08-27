-- =====================================================================
-- Ramener au 25 août les consultations datées des 26 et 27
-- =====================================================================
-- Le Gamou s'est tenu le 25 août 2026. Les consultations portant la date du
-- 26 ou du 27 ne correspondent pas à des soins donnés ces jours-là : ce sont
-- des enregistrements différés, saisis après coup à partir des registres
-- papier. Leur date de création reflétait donc le moment de la SAISIE, pas
-- celui de la consultation.
--
-- Ce script les ramène au 25 août, en conservant l'heure. Les consultations
-- datées du 24 ne sont pas touchées : ces documents portaient explicitement
-- cette date, ce sont de vraies consultations de la veille.
--
-- PÉRIMÈTRE : uniquement les trois sites de la campagne du Gamou. Aucune autre
-- campagne, aucun autre site n'est concerné.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Relançable sans risque : après un premier passage, plus aucune ligne ne
-- correspond au critère.
-- =====================================================================

do $$
declare
  v_camp   uuid;
  v_avant  int;
  v_apres  int;
  v_futur  int;
begin
  select id into v_camp from public.campagnes
   where nom = 'Couverture Médicale du Gamou de Tivaouane 2026';
  if v_camp is null then
    raise exception 'Campagne du Gamou introuvable : rien n''a été modifié.';
  end if;

  -- Combien de lignes sont concernées, avant de toucher quoi que ce soit
  select count(*) into v_avant
    from public.consultations c
    join public.sites s on s.id = c.site_id
   where s.campagne_id = v_camp
     and c.created_at >= '2026-08-26 00:00:00+00'
     and c.created_at <  '2026-08-28 00:00:00+00';
  raise notice 'Consultations datées des 26 et 27 août : %', v_avant;

  -- Décalage vers le 25, heure conservée : une consultation saisie à 16h35
  -- le 27 devient le 25 à 16h35. On ne connaît pas l'heure réelle du soin,
  -- mais la conserver garde l'ordre relatif des saisies.
  update public.consultations c
     set created_at = c.created_at
                    - (date_trunc('day', (c.created_at at time zone 'UTC'))
                       - '2026-08-25 00:00:00'::timestamp)
   from public.sites s
   where s.id = c.site_id
     and s.campagne_id = v_camp
     and c.created_at >= '2026-08-26 00:00:00+00'
     and c.created_at <  '2026-08-28 00:00:00+00';
  get diagnostics v_apres = row_count;
  raise notice 'Consultations ramenées au 25 août : %', v_apres;

  -- Signalement : une consultation postérieure au 27 est forcément une erreur
  -- de lecture du registre (date future). On l'indique sans y toucher.
  select count(*) into v_futur
    from public.consultations c
    join public.sites s on s.id = c.site_id
   where s.campagne_id = v_camp
     and c.created_at >= '2026-08-28 00:00:00+00';
  if v_futur > 0 then
    raise notice 'ATTENTION : % consultation(s) portent une date postérieure au 27 août. À vérifier dans l''application (probable erreur de lecture du registre manuscrit).', v_futur;
  end if;
end $$;

-- Contrôle après exécution : répartition des dates de la campagne.
select date(c.created_at) as jour, count(*) as consultations
  from public.consultations c
  join public.sites s on s.id = c.site_id
  join public.campagnes k on k.id = s.campagne_id
 where k.nom = 'Couverture Médicale du Gamou de Tivaouane 2026'
 group by date(c.created_at)
 order by jour;
