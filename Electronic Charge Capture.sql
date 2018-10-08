declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
date.year_month as 'Year-Month'
,month_name as 'Month'
,sum(case when zcsl.CHG_SOURCE_UCL_C = 26 then 1 else 0 end) as 'Inpatient'
,count(*) as 'Total'
,cast(sum(case when zcsl.CHG_SOURCE_UCL_C = 26 then 1 else 0 end) as float)/cast(count(*) as float) as 'Utilization %'
-- loc.rpt_grp_ten as 'Service Area'
--,arpb_tx.tx_id as 'Charge ID'
--,ucl.ucl_id as 'UCL ID'
--,zcsl.name as 'Charge Source'
--,zps.name as 'POS Type'
--,pos.rpt_grp_two as 'POS Name'
--,post_date as 'Post Date'
--,eap.proc_name as'Procedure'
--,emp.name as 'User'
--,amount as 'Charge Amt'

from 
arpb_transactions arpb_tx 
left join clarity_ucl ucl on ucl.ucl_id = arpb_tx.CHG_ROUTER_SRC_ID
left join ZC_CHG_SOURCE_UCL zcsl on zcsl.CHG_SOURCE_UCL_C = ucl.CHARGE_SOURCE_C
left join clarity_pos pos on pos.pos_id = arpb_tx.pos_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join zc_pos_type zps on zps.pos_type_c = pos.pos_type_c
left join clarity_emp emp on emp.user_id = arpb_tx.user_id
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
left join date_dimension date on date.calendar_dt_str = arpb_tx.post_date


where tx_type_c = 1
and pos.pos_type_c in (21,22,23)
--and zcsl.name = 'epiccare'
and arpb_tx.post_date >= @start_date
and arpb_tx.post_date  <= @end_date
and arpb_tx.service_area_id in (11,13,16,17,18,19)
and ((zcsl.name is null) or (zcsl.CHG_SOURCE_UCL_C = 26) or (zcsl.CHG_SOURCE_UCL_C = 2 and pos.pos_type_c = 21))
and dep.rpt_grp_one not in ('19101115')
and pos.rpt_grp_six = 1 -- Mercy Facility

group by 
date.year_month
,month_name

order by 
date.year_month
,month_name