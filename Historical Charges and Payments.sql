DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1');

with charges as
(
select
 date.YEAR_MONTH as 'MONTH'
,upper(sa.name) as 'REGION'
,tdl.ACCOUNT_ID as 'ACCOUNT ID'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE DATE'
,cast(tdl.POST_DATE as date) as 'CHG POST DATE'
,tdl.TX_ID as 'CHG ID'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESCRIPTION'
,epm.PAYOR_ID as 'ORIGINAL PAYOR ID'
,epm.PAYOR_NAME as 'ORIGINAL PAYOR NAME'
,tdl.ORIG_AMT as 'CHARGE AMOUNT'
,arpb_tx.OUTSTANDING_AMT as 'OUTSTANDING AMOUNT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.ORIG_SERVICE_DATE
left join CLARITY_EAP eap_match on eap_match.PROC_ID = tdl.MATCH_PROC_ID
left join ARPB_TX_VOID void on void.TX_ID = tdl.TX_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
where tdl.DETAIL_TYPE in (1) -- CHARGES MATCHED TO PAYMENTS
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and tdl.ORIG_SERVICE_DATE between @start_date and @end_date
and tdl.AMOUNT <> 0
and void.TX_ID is null
and tdl.TX_ID = 193000880
),

payments as
(
select 
 tdl.tx_id as 'CHG ID'
,tdl.MATCH_TRX_ID as 'TRANSACTION ID'
,cast(tdl.POST_DATE as date) as 'TRANSACTION POST DATE'
,upper(type.NAME) as 'TRANSACTION TYPE'
,eap.PROC_CODE as 'TRANSACTION CODE'
,eap.PROC_NAME as 'TRANSACTION DESCRIPTION'
,epm.PAYOR_ID as 'TRANSACTION PAYOR ID'
,epm.PAYOR_NAME as 'TRANSACTION PAYOR NAME'
,tdl.AMOUNT as 'TRANSACTION AMOUNT'
from charges
left join CLARITY_TDL_TRAN tdl on tdl.TX_ID = charges.[CHG ID]
left join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.CUR_PAYOR_ID
left join ZC_TRAN_TYPE type on type.TRAN_TYPE = tdl.MATCH_TX_TYPE
where detail_type in (20,21) -- CHARGES MATCHED TO PAYMENT
)

select * 
from charges
left join payments on payments.[CHG ID] = charges.[CHG ID]

