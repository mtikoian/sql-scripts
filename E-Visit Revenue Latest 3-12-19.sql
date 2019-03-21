select 
sum(tdl.AMOUNT) * -1 as 'Matched Payments'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID

where tdl.DETAIL_TYPE in (20) -- Payments > Charges
and eap.PROC_CODE in ('99444','98969')
and tdl.ORIG_POST_DATE >= '3/1/2018'
and tdl.ORIG_POST_DATE <= '3/31/2018'
and loc.RPT_GRP_TEN in (11)
and arpb_tx.OUTSTANDING_AMT = 0

