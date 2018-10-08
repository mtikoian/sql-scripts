--post date, service date, service area, rev location, department, original payer, and original plan

select 
 cast(tdl.orig_service_date as date) as 'Service Date'
,sa.rpt_grp_ten as 'Service Area ID'
,upper(sa.name) as 'Service Area'
,loc.loc_id as 'Location ID'
,loc.loc_name as 'Location'
,dep.department_id as 'Department ID'
,dep.department_name as 'Department'
,epm.payor_id as 'Original Payor ID'
,epm.payor_name as 'Original Payor'
,epp.benefit_plan_id as 'Original Plan ID'
,epp.benefit_plan_name as 'Original Plan'
--,tdl.amount as 'Charge Amount'
--,tdl.detail_type as 'Detail Type'
,count(*) as 'Count of Charges > 0'

from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_epm epm on epm.payor_id = tdl.original_payor_id
left join clarity_epp epp on epp.benefit_plan_id = tdl.original_plan_id
left join arpb_tx_void void on void.tx_id = tdl.tx_id
where tdl.serv_area_id in (11,13,16,17,18,19) -- Mercy
and tdl.orig_service_date >= '1/1/2017'
and detail_type in (1,10) -- new charges
and void.tx_id is null
and amount <> 0

group by
 cast(tdl.orig_service_date as date)
,sa.rpt_grp_ten
,upper(sa.name)
,loc.loc_id
,loc.loc_name
,dep.department_id
,dep.department_name 
,epm.payor_id
,epm.payor_name
,epp.benefit_plan_id
,epp.benefit_plan_name 
