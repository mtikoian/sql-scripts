DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

--DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
--DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select
 LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) as 'INVOICE NUMBER'
,tdl.TX_ID as 'CHARGE ID'
,tdl.MATCH_TRX_ID as 'TRANSACTION ID'
,loc.GL_PREFIX + 'P'  as 'FACILITY ID'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE DATE'
,cast(tdl.POST_DATE as date) as 'POSTING DATE'
,eap.PROC_CODE as 'POSTING CODE'
,ztt.NAME as 'TRANSACTION TYPE'
,left(eap_chg.PROC_CODE,5) as 'CPT CODE'
,left(tdl.MODIFIER_ONE,2) as 'MODIFIER ONE'
,left(tdl.MODIFIER_TWO,2) as 'MODIFIER TWO'
,left(tdl.MODIFIER_THREE,2) as 'MODIFIER THREE'
,left(tdl.MODIFIER_FOUR,2) as 'MODIFIER FOUR'
,arpb_tx.ORIGINAL_EPM_ID as 'PAYER ID'
,case when arpb_tx.IPP_CROSSOVR_PMT_YN = 'Y' then cov.PLAN_ID
      when tdl.ACTION_PLAN_ID is not null then tdl.ACTION_PLAN_ID 
	  else arpb_tx2.CVG_PLAN_ON_PMT_ID end as 'PLAN ID'
,tdl.PERFORMING_PROV_ID as 'PERFORMING PROVIDER ID'
,tdl.BILLING_PROVIDER_ID as 'BILLING PROVIDER ID'
,tdl.AMOUNT*-1 as 'AMOUNT'
,arpb_tx.IPP_CROSSOVR_PMT_YN

from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLAIM_STMNT_DATE csd on csd.TX_ID = tdl.TX_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_EAP eap_chg on eap_chg.PROC_ID = tdl.PROC_ID
left join ZC_TRAN_TYPE ztt on ztt.TRAN_TYPE = tdl.MATCH_TX_TYPE
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.MATCH_TRX_ID
left join ARPB_TRANSACTIONS2 arpb_tx2 on arpb_tx2.TX_ID = arpb_tx.TX_ID
left join COVERAGE cov on cov.COVERAGE_ID = tdl.ACTION_CVG_ID

where tdl.DETAIL_TYPE in (20,21)
and tdl.ORIG_SERVICE_DATE >= '1/1/2017'
and tdl.POST_DATE >= @start_date
and tdl.POST_DATE <= @end_date
and csd.LAST_INVOICE_NUM is not null

and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and tdl.AMOUNT <> 0
and dep.GL_PREFIX not in ('6327')

--and tdl.DEPT_ID not in (19102101,19102102,19102105,19102103,19102104,17110102,19290068,17110101,19290020,11106133)	-- exclude Rural Health
--and tdl.tx_id = 162986714
--and tdl.MATCH_TRX_ID = 156602642 -- credit adjustment
--and tdl.MATCH_TRX_ID = 155864056 -- crossover payments
--and tdl.MATCH_TRX_ID = 174977291
--and tdl.action_plan_id is null
--and eap.PROC_CODE = '2000'
--and tdl.MATCH_TRX_ID = 193917765

--and LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) in
--('17867735'
--,'20176780'
--,'20176781'
--,'20323258'
--,'20323259'
--,'20323299'
--,'20323336'
--,'20323359'
--,'20323634'
--,'20323637'
--)

order by [invoice number]