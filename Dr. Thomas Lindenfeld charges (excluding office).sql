/*
Need a report pulling all of Dr Thomas Lindenfeld 's 2017 charges (excluding office) -1005685
Need columns....Provider, Month of Transaction, CPT and Description, Place of Service, Place of Service Type, charges, units, and EAF 8925 (POS Report grouper six)
Need today if all possible. Please assign to Clarity PB Team. 
*/

select 
ser.prov_id as 'BILLING PROVIDER ID'
,ser.prov_name as 'BILLING PROVIDER'
,cast(arpb_tx.service_date as date) as 'SERVICE DATE'
,eap.proc_code as 'PROCEDURE CODE'
,eap.proc_name as 'PROCEDURE DESC'
,pos.pos_id as 'POS ID'
,pos.pos_name as 'POS'
,coalesce(pos.pos_type,'') as 'POS TYPE'
,coalesce(pos_grp.name,'') as 'POS RPT GRP 6'
,arpb_tx.amount as 'CHG AMT'
,arpb_tx.procedure_quantity as 'PROCEDURE QTY'
from arpb_transactions arpb_tx
left join arpb_tx_void void on void.tx_id = arpb_tx.tx_id
left join clarity_pos pos on pos.pos_id = arpb_tx.pos_id
left join clarity_ser ser on ser.prov_id = arpb_tx.billing_prov_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join ZC_POS_RPT_GRP_6 pos_grp on pos_grp.rpt_grp_six = pos.rpt_grp_six
where service_date >= '1/1/2017'
and service_date <= '12/31/2017'
and billing_prov_id = '1005685' -- Dr. Thomas Lindenfeld
and tx_type_c = 1 -- charges 
and void.tx_id is null -- exclude voids
and pos.pos_type <> 'office'