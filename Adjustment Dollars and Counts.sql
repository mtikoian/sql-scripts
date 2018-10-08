select 
 upper(sa.NAME) as 'REGION'
,eap.PROC_NAME + ' [' + eap.PROC_CODE + ']' as 'ADJUSTMENT'
,sum(arpb_tx.AMOUNT) * -1 as 'AMOUNT'
,count(arpb_tx.TX_ID) as 'COUNT'
from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID

where arpb_tx.TX_TYPE_C = 3 -- Adjustments
and arpb_tx.POST_DATE >= '1/1/2018'
and arpb_tx.POST_DATE <= '4/30/2018'
and sa.RPT_GRP_TEN = 13

group by 
 sa.NAME
,eap.PROC_NAME + ' [' + eap.PROC_CODE + ']'

order by 
 eap.PROC_NAME + ' [' + eap.PROC_CODE + ']'