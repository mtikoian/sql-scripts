select 
service_area_nm_wid as 'Region'
,loc_nm_wid as 'Location'
,dept_nm_wid as 'Department'
,pos_nm_wid as 'Place of Service'
,service_dttm as 'Service Date'
,eap.proc_code + ' [' + eap.proc_name + ']' as 'Procedure'
,payor_nm_wid as 'Payor'
,plan_nm_wid as 'Plan'
,prov_nm_wid as 'Provider'
,payment_tx_id as 'Payment ID'
,eob_allowed_amount as 'Allowed Amount'

from v_arpb_reimbursement var
left join clarity_eap eap on eap.proc_id = var.proc_id
where cpt_code in ('99411','99412','99078','98961','98962','99406','99407')
and service_dttm >= '1/1/2017'
and var.service_area_id = 11
