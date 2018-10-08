declare @start_date as date = EPIC_UTIL.EFN_DIN('8/28/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('3/31/2018')

select
 date.year_month_str as 'Year-Month'
,ser_perf.prov_name as 'Performing Provider'
,fc.name as 'Original Financial Class'
,sum(case when detail_type in (1,10) then amount else 0 end) as 'Charge'
,sum(case when detail_type in (2,5,11,20,22,32,33) then amount else 0 end) as 'Payment'
,sum(case when detail_type in (2,5,11,20,22,32,33) then patient_amount else 0 end) as 'Patient Payment'
,sum(case when detail_type in (2,5,11,20,22,32,33) then insurance_amount else 0 end) as 'Insurance Payment'
,sum(case when detail_type in (4,6,13,21,23,30,31) then amount else 0 end) as 'Credit Adjustment'
,sum(case when detail_type in (3,12) then amount else 0 end) as 'Debit Adjustment'
,sum(tdl.amount) as 'Net Change in AR'

from clarity.dbo.clarity_tdl_tran tdl
left join clarity.dbo.clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity.dbo.clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity.dbo.zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity.dbo.clarity_pos pos on pos.pos_id = tdl.pos_id
left join clarity.dbo.clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity.dbo.clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity.dbo.clarity_ser ser_bill on ser_bill.prov_id = tdl.billing_provider_id
left join clarity.dbo.clarity_ser ser_perf on ser_perf.prov_id = tdl.performing_prov_id
left join clarity.dbo.clarity_epm epm on epm.payor_id = tdl.original_payor_id
left join clarity.dbo.zc_fin_class fc on fc.fin_class_c = tdl.original_fin_class
left join clarity.dbo.date_dimension date on date.calendar_dt_str = tdl.post_date

where 
detail_type in (1,10,11,12,13,2,20,21,22,23,3,30,31,32,33,4,5,6) 
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and post_date >= @start_date
and post_date <= @end_date
and ser_perf.prov_id in (
 '1645149'
,'12010121'
,'1751371'
,'1680887'
,'1003204'
,'1659977'
,'1658363'
,'1004208'
,'1000404'
,'1644197'
,'1005545'
,'1005698'
,'1010615'
,'1713892'
,'1006356'
,'1006705'
,'1644006'
,'1007279'
,'1007660'
,'1602936'
,'1008490'
,'1658545'
,'1008788'
,'1639044'
,'1000690'
,'1009641'
,'1675085'
,'1740710'
,'1000734'
,'1010044'
)


group by 
 date.year_month_str
,ser_perf.prov_name
,fc.name

order by 
 date.year_month_str
,ser_perf.prov_name
,fc.name