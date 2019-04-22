/*
Need claims data for what claims were sent to a generic coverage for both PB and HB for a rolling 12 month look back, report sent on a quarterly basis. 

Generic plans:
350101
999901
400201
400101
400001
4333001
4334001
8
3999319
3999318
3999320
3999099

we will need the plan ID, plan name, payer ID, payer name and the free text fields for coverage name, address, city, state, zip. It would be good to have a count of the claims that we sent to each free text address but I'm assuming because it's free text, the chance that they are the same each time is slim.
*/

declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 
 tdl.ACCOUNT_ID
,tdl.INVOICE_NUMBER
,cast(tdl.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,cast(tdl.POST_DATE as date) as CLAIM_RUN_DATE
,tdl.CUR_PLAN_ID as PLAN_ID
,epp.BENEFIT_PLAN_NAME as PLAN_NAME
,epm.PAYOR_NAME
,cvg2.ORG_FOR_CLM_SUBMIT as COVERAGE_NAME
,cvg.CVG_ADDR1 as CVG_ADDRESS1
,cvg.CVG_ADDR2 as CVG_ADDRESS2
,cvg.CVG_CITY 
,zs.ABBR as CVG_STATE
,cvg.CVG_ZIP
,zdt.NAME as TYPE
,sum(tdl.BILL_CLAIM_AMOUNT) as CLAIM_AMOUNT


from CLARITY_TDL_TRAN tdl
left join ZC_DETAIL_TYPE zdt on zdt.DETAIL_TYPE = tdl.DETAIL_TYPE
left join CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = tdl.CUR_PLAN_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.CUR_PAYOR_ID
left join COVERAGE cvg on cvg.COVERAGE_ID = tdl.CUR_CVG_ID
left join COVERAGE_2 cvg2 on cvg2.CVG_ID = cvg.COVERAGE_ID
left join ZC_STATE zs on zs.STATE_C = cvg.STATE_C

where tdl.DETAIL_TYPE = 50 -- insurance claims
and tdl.POST_DATE >= @start_date
and tdl.POST_DATE <= @end_date
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and tdl.CUR_PLAN_ID in 
(350101
,999901
,400201
,400101
,400001
,4333001
,4334001
,8
,3999319
,3999318
,3999320
,3999099
)


--and tdl.INVOICE_NUMBER = 'MT231209234'

group by
 tdl.ACCOUNT_ID
,tdl.INVOICE_NUMBER
,tdl.ORIG_SERVICE_DATE
,tdl.POST_DATE
,tdl.CUR_PLAN_ID
,epp.BENEFIT_PLAN_NAME
,epm.PAYOR_NAME
,cvg2.ORG_FOR_CLM_SUBMIT
,cvg.CVG_ADDR1
,cvg.CVG_ADDR2
,cvg.CVG_CITY
,zs.ABBR
,cvg.CVG_ZIP
,zdt.NAME

order by
 tdl.ACCOUNT_ID
,tdl.INVOICE_NUMBER
,tdl.POST_DATE
,tdl.CUR_PLAN_ID
,epp.BENEFIT_PLAN_NAME
,epm.PAYOR_NAME
,cvg2.ORG_FOR_CLM_SUBMIT
,cvg.CVG_ADDR1
,cvg.CVG_ADDR2
,cvg.CVG_CITY
,zs.ABBR
,cvg.CVG_ZIP
,zdt.NAME