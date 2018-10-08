/*
Epic - needs reimbursement report ran for her
user needs to know what the top CPT codes are for her office
needs to know what they charge per CPT 
needs to know what is the top reimbursement for her office
*/

select 
 sa.serv_area_name as 'Service Area'
,cast(arpb_tx.service_date as date) as 'Service Date'
,cast(arpb_tx.post_date as date) as 'Post Date'
,arpb_tx.tx_id as 'Chg ID'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,arpb_tx.amount as 'Chg Amount'
from arpb_transactions arpb_tx
left join arpb_tx_void atv on atv.tx_id = arpb_tx.tx_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join clarity_sa sa on sa.serv_area_id = arpb_tx.service_area_id
where arpb_tx.service_area_id = 613
and arpb_tx.service_date >= '1/1/2017'
and service_date <= '12/31/2017'
and tx_type_c = 1 -- charges
and atv.tx_id is null -- exclude voids

order by arpb_tx.service_date asc