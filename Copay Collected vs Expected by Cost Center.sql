declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 


select 
 loc.region as 'REGION'
,loc.gl_prefix + ' - ' + dep.gl_prefix as 'COST CENTER'
,dd.year_month as 'YEAR_MONTH'
,sum(coalesce(enc.copay_collected,0)) as 'COPAY COLLECTED'
,sum(coalesce(enc.copay_due,0)) as 'COPAY EXPECTED'
,case when sum(coalesce(enc.copay_due,0)) is null then 0 else sum(coalesce(enc.copay_collected,0))/sum(coalesce(enc.copay_due,0)) end as 'COPAY PERCENT COLLECTED'

from pat_enc enc
left join clarity_dep dep on dep.department_id = enc.department_id
inner join claritychputil.rpt.v_pb_rev_cycle_locations loc on loc_id = dep.rev_loc_id
left join pat_enc_2 enc2 on enc2.pat_enc_csn_id = enc.pat_enc_csn_id
left join clarity_pos pos on pos.pos_id = enc2.visit_pos_id
left join clarity_ser ser on ser.prov_id = enc.visit_prov_id
left join clarity_prc prc on prc.prc_id = enc.appt_prc_id
left join date_dimension dd on dd.calendar_dt_str = enc.contact_date
left join v_sched_appt vsa on vsa.pat_enc_csn_id = enc.pat_enc_csn_id



where enc.appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= @startdate
and enc.contact_date <= @enddate
and prc.benefit_group in ('Office Visit','PB Copay','Copay')
and enc.copay_due > 0
and enc.pat_enc_csn_id <> 131850458
and dep.department_id not in
(11101450,
11104101,
11105102,
11107101,
11107119,
11107147,
11108120,
11108135,
11108140,
11108145,
11108162,
11108164,
11110110,
11110122,
11110143,
11111122,
11114118,
11114129,
11114133,
11114152,
11115000,
11115001,
11117102,
11121001,
11121003,
11139001,
11140001,
11101408,
11104103,
11146001,
11101185
)
and (ser.prov_id not in
('1100199',
'1007831',
'1000645',
'1000242',
'1005602',
'1008668',
'1008696',
'1000732',
'1611492',
'1000045',
'1009542'
) or ser.prov_id is null)

group by 
region
,loc.gl_prefix + ' - ' + dep.gl_prefix
,dd.year_month

order by 
year_month
,region
,loc.gl_prefix + ' - ' + dep.gl_prefix