select
 tx_id as 'Charge ID'
,cast(tdl.orig_service_date as date) as 'Service Dat'
,cast(tdl.post_date as date) as 'Payment\Adj Post Date'
,dep.department_id as 'Department ID'
,dep.department_name as 'Department Name'
,det.name as 'Detail Type'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,tdl.amount as 'Amount'

from clarity_tdl_tran tdl
left join zc_detail_type det on det.detail_type = tdl.detail_type
left join clarity_eap eap on eap.proc_id = tdl.match_proc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
where tdl.detail_type in (20,21)
and dept_id = 17107102
and post_date > = '11/1/2016'

order by tx_id 