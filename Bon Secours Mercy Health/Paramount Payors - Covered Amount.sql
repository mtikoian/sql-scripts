select
 --tdl.TDL_ID
 tdl.TX_ID as 'CHARGE_ID'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE_DATE'
,dep.SPECIALTY
,sl.NAME as 'SERVICE_LINE'
,tdl.MATCH_TRX_ID 'PAYMENT_ID'
,cast(pat.PAT_MRN_ID as nvarchar) as 'PAT_MRN_ID'
,pat.PAT_NAME
,eap.PROC_CODE
,eap.PROC_NAME
,tdl.MODIFIER_ONE
,tdl.MODIFIER_TWO
,tdl.MODIFIER_THREE
,tdl.MODIFIER_FOUR
,arpb_tx.PROCEDURE_QUANTITY
,arpb_tx.AMOUNT as 'CHARGE_AMT'
,eob.CVD_AMT
,tdl.BILLING_PROVIDER_ID
,ser.PROV_NAME as 'BILLING_PROVIDER'
,tdl.POS_ID
,pos.POS_NAME
,pos.POS_TYPE
,cvg.PAYOR_ID
,epm.PAYOR_NAME
,cvg.PLAN_ID
,epp.BENEFIT_PLAN_NAME as 'PLAN_NAME'

from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_POS pos on pos.POS_ID = tdl.POS_ID 
left join COVERAGE cvg on cvg.COVERAGE_ID = tdl.ORIGINAL_CVG_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join ZC_DEP_RPT_GRP_16 sl on sl.RPT_GRP_SIXTEEN_C = dep.RPT_GRP_SIXTEEN_C
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = cvg.PLAN_ID




where tdl.DETAIL_TYPE = 20
and loc.RPT_GRP_TEN = 18
and tdl.ORIG_SERVICE_DATE >= '1/1/2018'
and tdl.ORIG_SERVICE_DATE <= '04/30/2018'
and cvg.PAYOR_ID in (3721, 3722, 3723, 3419, 9005)
and arpb_tx.VOID_DATE is null

order by tdl.TDL_ID