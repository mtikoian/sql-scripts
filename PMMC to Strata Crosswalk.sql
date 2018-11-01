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
--arpb_tx.SERVICE_DATE >= '1/1/2017'
--and arpb_tx.SERVICE_DATE <= '12/31/2017'
--and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
 arpb_tx.TX_TYPE_C = 1 -- CHARGES
--and arpb_tx.VOID_DATE is null -- EXCLUDE VOIDS
and arpb_tx.TX_ID in 
(
174168267
,174168764
,174169279
,172982398
,173092694
,173102913
,173993835
,173993836
,172916509
,173042673
,175447107
,175447108
,175447110
,175447112
,175447117
,173004389
,173004395
,173004396
,173004410
,173152043
,173353373
,175877388
,175877389
,175877390
,173028242
,173408474
,173588372
,173407227
)

order by
 arpb_tx.TX_ID