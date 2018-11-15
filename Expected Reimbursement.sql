select
arpb_tx.tx_id
,arpb_tx.SERVICE_DATE
,arpb_tx.post_date
,arpb_tx.TX_TYPE_C
,REIMB_CONTRACT_AMT
,EXP_REIMB_DYNAMIC
,EXPECTED_REIMB
from 
arpb_transactions arpb_tx
left join arpb_tx_moderate atm on atm.TX_ID = arpb_tx.TX_ID
where arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and REIMB_CONTRACT_AMT is not null
and arpb_tx.TX_ID = 230806964