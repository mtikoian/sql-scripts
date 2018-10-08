
select distinct
	sa.serv_area_id
	,sa.serv_area_name
	,int_pat_id
	,pat_mrn_id
	,pat_name
	,zc_race.name as 'patient_race'
	,zc_ethnic.name as 'ethnic_group'
	,lang.name as 'language'
	
from clarity_tdl_tran tdl
left join patient pat on tdl.int_pat_id = pat.pat_id
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id
left join patient_race race on pat.pat_id = race.pat_id
left join zc_patient_race zc_race on race.patient_race_c = zc_race.patient_race_c
left join zc_ethnic_group zc_ethnic on pat.ethnic_group_c = zc_ethnic.ethnic_group_c
left join zc_language lang on pat.language_c = lang.language_c

where orig_service_date >= '2015-01-01'
and orig_service_date <= '2015-12-31'
and detail_type in (1)
and sa.serv_area_id in (21)

order by int_pat_id