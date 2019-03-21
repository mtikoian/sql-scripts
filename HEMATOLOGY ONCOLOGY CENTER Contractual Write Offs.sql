select 
 tdl.ACCOUNT_ID as 'ACCOUNT ID'
,acct.ACCOUNT_NAME as 'ACCOUNT NAME'
,tdl.TX_ID as 'CHG ID'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'DATE OF SERVICE'
,eap.PROC_CODE as 'PROC CODE'
,eap.PROC_NAME as 'PROC DESC'
,tdl.ORIG_AMT as 'ORIG_AMT'
,tdl.MATCH_TRX_ID as 'CREDIT ADJ ID'
,cast(tdl.POST_DATE as date) as 'POST DATE'
,tdl.AMOUNT as 'CREDIT ADJ AMT'
,epm.PAYOR_ID as 'ACTION PAYOR ID'
,epm.PAYOR_NAME as 'ACTION PAYOR'
,epp.BENEFIT_PLAN_ID as 'ACTION PLAN ID'
,epp.BENEFIT_PLAN_NAME as 'ACTION PLAN'

from CLARITY_TDL_TRAN tdl
left join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ACTION_PAYOR_ID
left join CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = tdl.ACTION_PLAN_ID

where tdl.SERV_AREA_ID = 17003
and tdl.MATCH_PROC_ID = 10226
and tdl.DETAIL_TYPE = 21 -- Charge matched to Credit Adjustment

order by tdl.AMOUNT desc
