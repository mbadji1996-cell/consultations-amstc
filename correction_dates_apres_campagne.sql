-- =====================================================================
-- Rattacher les saisies différées à la dernière journée de consultation
-- =====================================================================
-- Une consultation enregistrée après la fin des consultations est une reprise
-- différée - registre papier repris le lendemain, fiche oubliée - et non un soin
-- donné ce jour-là. Tant qu'elle porte sa date de saisie, le rapport annonce des
-- journées d'activité qui n'ont jamais eu lieu : le Gamou 2026 affichait des
-- consultations les 26 et 27 août alors que les sites avaient fermé le 25.
--
-- L'application applique désormais cette règle à l'enregistrement. Ce script
-- corrige ce qui est déjà en base.
--
-- LA RÉFÉRENCE, pour chaque campagne : la dernière JOURNÉE DE CONSULTATION
-- déclarée sur sa fiche (rubrique « Journées de consultation »). À défaut, sa
-- date de fin. Une campagne qui n'a ni l'une ni l'autre n'est pas touchée :
-- mieux vaut une date de saisie qu'une date inventée.
--
-- L'HEURE EST CONSERVÉE : une consultation saisie à 16h35 le 27 devient le 25 à
-- 16h35. On ne connaît pas l'heure réelle du soin, mais la conserver garde
-- l'ordre relatif des saisies dans la journée.
--
-- CE QUI N'EST PAS TOUCHÉ : tout ce qui tombe le dernier jour ou avant. Les
-- consultations antérieures à la campagne non plus - une date trop ancienne est
-- une erreur de saisie d'un autre genre, que ce script signale sans y toucher.
--
-- À exécuter dans Supabase : Dashboard > SQL Editor > New query.
-- Relançable sans risque : après un premier passage, plus aucune ligne ne
-- correspond au critère.
-- =====================================================================

do $$
declare
  r          record;
  v_dernier  date;
  v_deplace  int;
  v_total    int := 0;
  v_avant    int;
begin
  for r in
    select c.id, c.nom, c.date_debut, c.date_fin, c.jours_consultation
      from public.campagnes c
  loop
    -- Dernière journée déclarée, sinon date de fin de la campagne.
    select max((j->>'date')::date) into v_dernier
      from jsonb_array_elements(
             case when jsonb_typeof(r.jours_consultation) = 'array'
                  then r.jours_consultation else '[]'::jsonb end) as j
     where j->>'date' is not null and j->>'date' <> '';

    if v_dernier is null then
      v_dernier := r.date_fin;
    end if;

    if v_dernier is null then
      raise notice '% : ni journées déclarées ni date de fin, campagne ignorée.', r.nom;
      continue;
    end if;

    update public.consultations c
       set created_at = c.created_at
                      - (date_trunc('day', (c.created_at at time zone 'UTC'))
                         - (v_dernier::timestamp))
      from public.sites s
     where s.id = c.site_id
       and s.campagne_id = r.id
       and (c.created_at at time zone 'UTC')::date > v_dernier;
    get diagnostics v_deplace = row_count;
    v_total := v_total + v_deplace;

    if v_deplace > 0 then
      raise notice '% : % consultation(s) rattachée(s) au %.', r.nom, v_deplace, v_dernier;
    end if;

    -- Signalement sans modification : une consultation antérieure au début de la
    -- campagne est une erreur d'un autre genre, qu'un rattachement masquerait.
    if r.date_debut is not null then
      select count(*) into v_avant
        from public.consultations c
        join public.sites s on s.id = c.site_id
       where s.campagne_id = r.id
         and (c.created_at at time zone 'UTC')::date < r.date_debut;
      if v_avant > 0 then
        raise notice 'ATTENTION - % : % consultation(s) datent d''AVANT le début de la campagne. À vérifier dans l''application, ce script n''y touche pas.', r.nom, v_avant;
      end if;
    end if;
  end loop;

  raise notice 'Total rattaché : % consultation(s).', v_total;
end $$;

-- Contrôle après exécution : répartition des dates, campagne par campagne.
select k.nom,
       date(c.created_at at time zone 'UTC') as jour,
       count(*) as consultations
  from public.consultations c
  join public.sites s     on s.id = c.site_id
  join public.campagnes k on k.id = s.campagne_id
 group by k.nom, date(c.created_at at time zone 'UTC')
 order by k.nom, jour;
