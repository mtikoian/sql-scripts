select
 distinct
 arpb_tx.TX_ID as ENCOUNTER_RECORD_NUMBER
,LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) as INVOICE_NUMBER
,upper(sa.NAME) as SERVICE_AREA
,cast(arpb_tx.SERVICE_DATE as date) as SERVICE_DATE

from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLAIM_STMNT_DATE csd on csd.TX_ID =  arpb_tx.TX_ID

where 
arpb_tx.SERVICE_DATE >= '1/1/2017'
and arpb_tx.SERVICE_DATE <= '12/31/2017'
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and arpb_tx.TX_TYPE_C = 1 -- CHARGES
and arpb_tx.VOID_DATE is null -- EXCLUDE VOIDS

order by
 arpb_tx.TX_ID