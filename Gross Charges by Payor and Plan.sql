select
 upper(sa.NAME) as REGION
,date.YEAR_MONTH
,coalesce(epm.PAYOR_NAME,'SELF-PAY') as PAYOR_NAME
,coalesce(epp.BENEFIT_PLAN_NAME,'') as BENEFIT_PLAN_NAME
,sum(case when tdl.DETAIL_TYPE in (1,10) then tdl.AMOUNT else 0 end) as CHARGES
,sum(case when tdl.DETAIL_TYPE in (20) then tdl.AMOUNT else 0 end) * -1 as PAYMENTS
,sum(case when tdl.DETAIL_TYPE in (20) then tdl.PATIENT_AMOUNT else 0 end) * -1 as PATIENT_PAYMENTS
,sum(case when tdl.DETAIL_TYPE in (20) then tdl.INSURANCE_AMOUNT else 0 end) * -1 as INSURANCE_PAYMENTS
,sum(case when tdl.DETAIL_TYPE in (21) then tdl.AMOUNT else 0 end) * -1 as CREDIT_ADJUSTMENTS
,sum(case when eap_match.PROC_CODE in ('3000') then tdl.AMOUNT else 0 end) * -1 as CONTRACTUAL_WRITEOFFS
,sum(case when eap_match.PROC_CODE in ('3010') then tdl.AMOUNT else 0 end) * -1 as SELF_PAY_DISCOUNTS
,sum(coalesce(arpb_tx.OUTSTANDING_AMT,0)) as OUTSTANDING_AMT
from CLARITY_TDL_TRAN tdl
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = tdl.ORIGINAL_PLAN_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID and tdl.DETAIL_TYPE = 1
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EAP eap_match on eap_match.PROC_ID = tdl.MATCH_PROC_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.ORIG_SERVICE_DATE
where tdl.DETAIL_TYPE in (1,10,20,21)
and tdl.ORIG_SERVICE_DATE between '01/01/2017' and '12/31/2017'
and sa.RPT_GRP_TEN in (11,13,16,17,18,19)
and tdl.AMOUNT <> 0
--and tdl.TX_ID = 152702196
group by
 sa.NAME
,date.YEAR_MONTH
,coalesce(epm.PAYOR_NAME,'SELF-PAY')
,coalesce(epp.BENEFIT_PLAN_NAME,'')

order by
 sa.NAME
,date.YEAR_MONTH
,coalesce(epm.PAYOR_NAME,'SELF-PAY')
,coalesce(epp.BENEFIT_PLAN_NAME,'')