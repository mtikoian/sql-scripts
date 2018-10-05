select
*
from
(
select 
 arpb_tx.TX_ID
,arpb_tx.SERVICE_DATE
,arpb_tx.POST_DATE
,convert(date,getdate()) as TODAY
,datediff(day,arpb_tx.POST_DATE,'6/21/2018 00:00:00') as DAYS_OUTSTANDING
,arpb_tx.SERVICE_AREA_ID
,loc.RPT_GRP_TEN
,sa.NAME as 'RPT_GRP_TEN_NAME'
,arpb_tx.PAYOR_ID as CURRENT_PAYOR_ID
,epm.PAYOR_NAME as CURRENT_PAYOR
,arpb_tx.INSURANCE_AMT
,arpb_tx.OUTSTANDING_AMT
from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EPM epm on epm.PAYOR_ID = arpb_tx.PAYOR_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
 where arpb_tx.INSURANCE_AMT > 0
 and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
 and arpb_tx.TX_TYPE_C = 1
 )a

 where a.DAYS_OUTSTANDING >  365
 order by a.TX_ID