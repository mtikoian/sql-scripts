declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
	 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, 19132,19133) then 'LIMA'
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	 when loc.loc_id in (18120,18121, 19120,19127) then 'TOLEDO'
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO'
	 when loc.loc_id in (18110,19126) then 'TOLEDO' 
	 when loc.loc_id in (19101,19102,19106,19107,19108,19116,19118) then 'KENTUCKY' 
	 end as REGION
,dd.year_month as 'YEAR_MONTH'
,dep.department_id as 'DEPARTMENT'
,sum(coalesce(enc.copay_collected,0)) as 'COPAY COLLECTED'
,sum(coalesce(enc.copay_due,0)) as 'COPAY EXPECTED'
,case when sum(coalesce(enc.copay_due,0)) is null then 0 else sum(coalesce(enc.copay_collected,0))/sum(coalesce(enc.copay_due,0)) end as 'COPAY PERCENT COLLECTED'

from pat_enc enc
left join clarity_dep dep on dep.department_id = enc.department_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join pat_enc_2 enc2 on enc2.pat_enc_csn_id = enc.pat_enc_csn_id
left join clarity_pos pos on pos.pos_id = enc2.visit_pos_id
left join clarity_ser ser on ser.prov_id = enc.visit_prov_id
left join clarity_prc prc on prc.prc_id = enc.appt_prc_id
left join date_dimension dd on dd.calendar_dt_str = enc.contact_date
left join v_sched_appt vsa on vsa.pat_enc_csn_id = enc.pat_enc_csn_id



where enc.appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= @start_date
and enc.contact_date <= @end_date
and prc.benefit_group in ('Office Visit','PB Copay','Copay')
and enc.copay_due > 0
and enc.pat_enc_csn_id <> 131850458
	and loc.loc_id in (11106,11124,11149 -- SPRINGFILED
	,11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138 -- CINCINNATI
	,13104,13105,13116,19142,19143,19144,19145 -- YOUNGSTOWN
	,16102,16103,16104,19132,19133 -- LIMA
	,17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141 -- LORAIN
	,18120,18121,19120,19127 -- DEFIANCE
	,18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19121,19122,19123,19124,19128,19129,19130,19131 -- TOLEDO
	,18110,19126 -- TOLEDO MRG
	,19101,19102,19106,19107,19108,19116,19118 -- KENTUCKY
	)
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
	 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, 19132,19133) then 'LIMA'
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	 when loc.loc_id in (18120,18121, 19120,19127) then 'TOLEDO'
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO'
	 when loc.loc_id in (18110,19126) then 'TOLEDO' 
	 when loc.loc_id in (19101,19102,19106,19107,19108,19116,19118) then 'KENTUCKY' 
	 end
,dd.year_month
,dep.department_id


order by
	 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, 19132,19133) then 'LIMA'
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	 when loc.loc_id in (18120,18121, 19120,19127) then 'TOLEDO'
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO'
	 when loc.loc_id in (18110,19126) then 'TOLEDO' 
	 when loc.loc_id in (19101,19102,19106,19107,19108,19116,19118) then 'KENTUCKY' 
	 end
,year_month
,dep.department_id