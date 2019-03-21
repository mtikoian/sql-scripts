declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-3')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
 date.year_month_str as 'Year-Month'
,case when loc.loc_id in (11106,11124,11149,19147) then 'SPRINGFIELD'
      when loc.loc_id in (18120,18121,19120,19127) then 'DEFIANCE'
      else upper(sa.name) end  as 'Region'
,cast(enc.contact_date as date) as 'Contact Date'
,enc_type.name as 'Encounter Type'
,dep.department_name as 'Department'
,zps.name as 'POS Type'
,pat.pat_id as 'Patient ID'
--,pat.pat_name as 'Patient'
--,cast(pat.birth_date as date) as 'DOB'
,datediff(year,pat.birth_date,enc.contact_date) as 'Age at Encounter'
--,case when pat.email_address like '%none%' or pat.email_address like '%noemail%' then '' else coalesce(pat.email_address,'') end as 'Email Address'
,case when pat.email_address is null or pat.email_address like '%none%' or pat.email_address like '%noemail%' then '' else 'YES' end as 'Email Address'
,coalesce(no_email.name,'') as 'No Email Reason'
,case when no_email.name is null then 'NO' else 'YES' end as 'No Email Reason Yes or No'
,emp_appt.name as 'Appt Entry User'     
,emp_check.name as 'Checkin User'
--,enc.pat_enc_csn_id
--,REG_HX_EVENT_C
--,REG_HX_USER_ID
,coalesce(cast(epm.payor_id as varchar),'4') as 'Payor ID'
,coalesce(epm.payor_name,'SELF-PAY') as 'Payor Name'
,coalesce(fc.name,'SELF-PAY') as 'Financial Class'
,pat.email_address as 'Email Address'

from 
pat_enc enc
left join pat_enc_2 enc2 on enc2.pat_enc_csn_id = enc.pat_enc_csn_id
left join clarity_pos pos on pos.pos_id = enc2.visit_pos_id
left join clarity_dep dep on dep.department_id = enc.department_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join patient pat on pat.pat_id = enc.pat_id
left join patient_4 pat4 on pat4.pat_id = pat.pat_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join zc_no_email_reason no_email on no_email.no_email_reason_c = pat4.no_email_reason_c
left join zc_disp_enc_type enc_type on enc_type.disp_enc_type_c = enc.enc_type_c
left join clarity_emp emp_appt on emp_appt.user_id = enc.appt_entry_user_id
left join clarity_emp emp_check on emp_check.user_id = enc.checkin_user_id
--left join reg_hx rh on rh.reg_hx_open_pat_csn = enc.pat_enc_csn_id     
left join clarity_epm epm on epm.payor_id = enc.visit_epm_id
left join zc_financial_class fc on fc.financial_class = epm.financial_class
left join date_dimension date on date.calendar_dt = enc.contact_date
left join zc_pos_type zps on zps.pos_type_c = pos.pos_type_c


where 
pos.pos_type_c in (11,72) -- office, rural health clinic
and enc.contact_date >= @start_date
and enc.contact_date <= @end_date
and loc.rpt_grp_ten in (1,11,13,16,17,18,19)
and loc.loc_id not in (19108) -- excluded location 19108 on 2/24/18
order by enc.contact_date