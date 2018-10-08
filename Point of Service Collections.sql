select

 arpb_pay.tx_id as 'Payment ID'
,upper(sa.name) as 'Region'
,loc.rpt_grp_three as 'Location'
,dep.rpt_grp_two as 'Department'
,date.year_month as 'Year-Month'
,cast(arpb_pay.post_date as date) as 'Post Date'
,arpb_pay.amount as 'Payment Amount'
,loc.gl_prefix + ' - ' + dep.gl_prefix as 'Full Gl'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'

from 
arpb_transactions arpb_pay
left join clarity_loc loc on loc.loc_id = arpb_pay.loc_id
left join clarity_dep dep on dep.department_id = arpb_pay.department_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_eap eap on eap.proc_id = arpb_pay.proc_id
left join date_dimension date on date.calendar_dt = arpb_pay.post_date

where
post_date >= '1/1/2017'
and tx_type_c = 2 -- payments
and loc.rpt_grp_ten in (1,11,13,16,17,18,19)
and dep.department_id not in ('13104134','19101110','19000001','18104110','19390070','17109101','11102101','16104001') -- exclude billing offices
and eap.proc_code in ('1000','1001','1002','1006','1015','1016','6008')
and arpb_pay.void_date is null

order by tx_id
/*
Copayment – 1001
Patient Payment – 1000
Pre – Payment – 1002
Collection Payment – 1006
Clear Balance Payment – 1015
Clear Balance Payment Reversal – 1016
Account Payment Reversal - 6008
*/


