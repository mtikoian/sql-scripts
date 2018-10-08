declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select
,sa.rpt_grp_ten as 'Service Area ID'
,sa.name as 'Service Area Name'
,loc.rpt_grp_two as 'Location ID'
,loc.rpt_grp_three as 'Location Name'
,dep.rpt_grp_one as 'Department ID'
,dep.rpt_grp_two as 'Department Name'
,dep.specialty as 'Specialty'
,cast(loc.gl_prefix as varchar) + ' - ' + cast(dep.gl_prefix as varchar) as 'Full GL Number'
,pos.rpt_grp_one as 'Place of Service ID'
,pos.rpt_grp_two as 'Place of Service Name'
,epm.payor_name + ' - ' + cast(epm.payor_id as varchar) as 'Original Payor'
,fc.name + ' - ' + cast(fc.fin_class_c as varchar) as 'Original Financial Class'
,sum(case when detail_type in (1,10) and month(tdl.post_date) = month(tdl.orig_service_date) then amount else 0 end) as 'Current Charges'
,sum(case when detail_type in (1,10) then amount else 0 end) - sum(case when detail_type in (1,10) and month(tdl.post_date) = month(tdl.orig_service_date) then amount else 0 end) as 'Late Charges'
,sum(case when detail_type in (1,10) then amount else 0 end) as 'Charges'
,sum(case when detail_type in (2,5,11,20,22,32,33) then amount else 0 end) as 'Payments'
,sum(case when detail_type in (2,5,11,20,22,32,33) then patient_amount else 0 end) as 'Patient Payments'
,sum(case when detail_type in (2,5,11,20,22,32,33) then insurance_amount else 0 end) as 'Insurance Payments'
,sum(case when detail_type in (4,6,13,21,23,30,31) then amount else 0 end) as 'Credit Adjustments'
,sum(case when detail_type in (3,12) then amount else 0 end) as 'Debit Adjustments'
,sum(tdl.amount) as 'Net Change in AR'

from clarity_tdl_tran tdl
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_ser ser_bill on ser_bill.prov_id = tdl.billing_provider_id
left join clarity_ser ser_perf on ser_perf.prov_id = tdl.performing_prov_id
left join clarity_epm epm on epm.payor_id = tdl.original_payor_id
left join zc_fin_class fc on fc.fin_class_c = tdl.original_fin_class

where 
detail_type in (1,10,11,12,13,2,20,21,22,23,3,30,31,32,33,4,5,6) 
and post_date >= @start_date
and post_date <= @end_date

group by 
 tdl.serv_area_id
,sa.rpt_grp_ten
,sa.name
,loc.loc_id
,loc.loc_name
,loc.rpt_grp_two
,loc.rpt_grp_three
,dep.department_id
,dep.department_name
,dep.rpt_grp_one
,dep.rpt_grp_two
,dep.specialty
,loc.gl_prefix
,dep.gl_prefix
,pos.pos_id
,pos.pos_name
,pos.rpt_grp_one
,pos.rpt_grp_two
,epm.payor_id
,epm.payor_name
,fc.fin_class_c
,fc.name

order by 
 sa.rpt_grp_ten
,sa.name
,loc.rpt_grp_two
,loc.rpt_grp_three
,dep.rpt_grp_one
,dep.rpt_grp_two
,dep.specialty
,loc.gl_prefix
,dep.gl_prefix
,pos.pos_id
,pos.pos_name
,pos.rpt_grp_one
,pos.rpt_grp_two
,epm.payor_id
,epm.payor_name
,fc.fin_class_c
,fc.name