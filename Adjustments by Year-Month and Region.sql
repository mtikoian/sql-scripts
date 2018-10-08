--Adjustments with adjustment code for 2016, 2017, and Jan 2018 broken down by month by region

select
 date.YEAR_MONTH as 'MONTH'
,upper(sa.name) as 'REGION'
,eap.PROC_CODE as 'ADJUSTMENT CODE'
,eap.PROC_NAME as 'ADJUSTMENT DESCRIPTION'
,sum(arpb_tx.amount)*-1 as 'AMOUNT'
from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join ARPB_TX_VOID void on void.TX_ID = arpb_tx.TX_ID
where arpb_tx.tx_type_c = 3
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and arpb_tx.POST_DATE between '1/1/2016' and '01/31/2018'
and void.TX_ID is null

group by date.YEAR_MONTH, sa.NAME, eap.PROC_CODE, eap.PROC_NAME

order by date.YEAR_MONTH, sa.NAME, eap.PROC_CODE, eap.PROC_NAME