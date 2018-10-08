
select distinct
 sa.serv_area_name as 'Service Area'
,pat.pat_last_name as 'Last Name'
,pat.pat_first_name as 'First Name'
,pat.add_line_1 as 'Address 1'
,pat.add_line_2 as 'Address 2'
,pat.city as 'City'
,state.abbr as 'State'
,pat.zip as 'Zip'
,cast(pat.birth_date as date) as 'DOB'
,datediff(year, pat.birth_date, getdate()) as 'Age at Time of Service'
,sex.abbr as 'Gender'
,replace(pat.ssn,'-','') as 'SSN'
,coalesce(pat.email_address,'') as 'Email Address'
,lang.name as 'Language'
,pat_stat.name as 'Patient Status'

from arpb_transactions arpb
left join patient pat on pat.pat_id = arpb.patient_id
left join clarity_ser ser on ser.prov_id = arpb.billing_prov_id
left join clarity_loc loc on loc.loc_id = arpb.loc_id
left join clarity_dep dep on dep.department_id = arpb.department_id
left join clarity_sa sa on sa.serv_area_id = arpb.service_area_id
left join zc_state state on state.state_c = pat.state_c
left join zc_sex sex on sex.rcpt_mem_sex_c = pat.sex_c
left join zc_language lang on lang.language_c = pat.language_c
left join zc_patient_status pat_stat on pat_stat.patient_status_c = pat.pat_status_c

where sa.serv_area_id = --parameter
and post_date between '5/1/2017' and '8/31/2017'
and datediff(year, pat.birth_date, post_date) >= 18
and arpb.void_date is null
and (pat.pat_status_c = 1 or pat.pat_status_c is null) -- 1 = alive
 order by pat.pat_last_name