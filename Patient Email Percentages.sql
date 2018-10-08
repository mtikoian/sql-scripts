--100,850
select 
 case when loc.rpt_grp_two in ('11106','11124','11149') then 'SPRINGFIELD'
      when loc.rpt_grp_two in ('18120','18121') then 'DEFIANCE'
      else upper(sa.name) end  as 'Region'
,cast(enc.contact_date as date) as 'Contact Date'
,enc_type.name as 'Encounter Type'
,dep.rpt_grp_two as 'Department'
,pat.pat_id as 'Patient ID'
,pat.pat_name as 'Patient'
,case when pat.email_address like '%none%' then '' else pat.email_address end as 'Email Address'
,no_email.name as 'No Email Reason'
,emp_appt.name as 'Appt Entry User'     
,emp_check.name as 'Checkin User'
--,enc.pat_enc_csn_id
--,REG_HX_EVENT_C
--,REG_HX_USER_ID
,epm.payor_id as 'Payor ID'
,epm.payor_name as 'Payor Name'
,fc.name as 'Financial Class'

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

where 
pos.pos_type_c = 11 -- office
and enc.contact_date >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE())-25, 0) -- 8/27
and enc.contact_date <= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE())-12, 0) -- 9/9
and loc.rpt_grp_ten in (1,11,13,16,17,18,19)


 --
