declare @post_date as date = EPIC_UTIL.EFN_DIN('mb') 

select 
service_date
,post_date
,tx_id
,service_area_id
,loc_id
,department_id
,billing_prov_id
,serv_provider_id
,title as 'tran_type'
,amount
from arpb_transactions arpb_tx
left join clarity_txtype tx_type on tx_type.tx_type = arpb_tx.tx_type_c
where service_area_id in (11,13,16,17,18,19)
and tx_type_c = 1
and post_date = @post_date
and service_date < post_date
and service_area_id in (11,13,16,17,18,19)
and void_date is null
order by tx_id
