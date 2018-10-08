DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

--DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-2')
--DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-2')

select 
 distinct LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) as 'INVOICE NUMBER'
,min(tdl.TX_ID) as 'CHARGE ID'
,min(loc.GL_PREFIX + 'P')  as 'FACILITY ID'
,min(loc.LOC_ID) as 'REVENUE LOCATION ID'
,min(pat.PAT_LAST_NAME) as 'PATIENT LAST NAME'
,min(replace(replace(pat.PAT_MRN_ID,'<',''),'>','')) as 'PATIENT MRN'
,min(case when hacl.line = 1 then cvg.PAYOR_ID end) as 'PAYOR 1 ID'
,min(case when hacl.line = 2 then cvg.PAYOR_ID end) as 'PAYOR 2 ID'
,min(case when hacl.line = 3 then cvg.PAYOR_ID end) as 'PAYOR 3 ID'
,min(case when hacl.line = 4 then cvg.PAYOR_ID end) as 'PAYOR 4 ID'
,min(case when hacl.line = 1 then cvg.PLAN_ID end) as 'PLAN 1 ID'
,min(case when hacl.line = 2 then cvg.PLAN_ID end) as 'PLAN 2 ID'
,min(case when hacl.line = 3 then cvg.PLAN_ID end) as 'PLAN 3 ID'
,min(case when hacl.line = 4 then cvg.PLAN_ID end) as 'PLAN 4 ID'
,min(arpb_tx.SERVICE_DATE) as 'SERVICE DATE'
,min(pat.CITY) as 'CITY'
,min(pat.BIRTH_DATE) as 'BIRTH DATE'
,min(case when hacl.LINE = 1 then cvg.SUBSCR_NAME end) as 'SUBSCRIBER NAME'
,min(case when hacl.LINE = 1 then cvg.GROUP_NUM end) as 'GROUP NUMBER'
,min(case when hacl.LINE =1 then rel.NAME end) as 'RELATIONSHIP TO PATIENT'
,min(left(zms.ABBR,1)) as 'MARITAL STATUS OF PATIENT'
,min(sex.ABBR) as 'SEX OF PATIENT'
,min(pat.SSN) as 'SSN'
,min(state.ABBR) as 'STATE OF PATIENT'
,min(pat.ADD_LINE_1) as 'ADDRESS LINE 1'
,min(pat.ZIP) as 'ZIP'
,min(csd.FIRST_CLM_DATE) as 'FIRST CLAIM DATE'
,'' as 'CLAIM NUMBER'
,min(edg.CURRENT_ICD10_LIST) as 'PRIMARY DIAGNOSIS ID'
,'' as 'AGE OF PATIENT'
,min(case when hacl.LINE = 1 then cvg.SUBSCR_SSN end) as 'SUBSCRIBER NUMBER'
,min(arpb_tx.BILLING_PROV_ID) as 'BILLING PROVIDER ID'
,min(coalesce(loc.GL_PREFIX,'0') +  coalesce(dep.GL_PREFIX,'0') + '-' + coalesce(cast(dep.DEPARTMENT_ID as nvarchar),'0')) as 'COST CENTER CODE'
,min(loc.LOC_ID) as 'ORGANIZATIONAL CODE'
,min(case when hacl.LINE = 1 then cvg.SUBSCR_EMPLOYER_ID end) as 'EMPLOYER ID'
,'' as 'ENCOUNTER TYPE'
,min(arpb_tx.ORIGINAL_FC_C) as 'ORIGINAL FC'
,'' as 'OUTSIDE LAB CHARGES'
,min(pat.PAT_FIRST_NAME) as 'PATIENT FIRST NAME'
,min(left(pat.PAT_MIDDLE_NAME,1)) as 'PATIENT MIDDLE NAME'
,min(suffix.ABBR) as 'PATIENT SUFFIX'
--,ROW_NUMBER() OVER(PARTITION BY LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) ORDER BY tdl.tx_id asc) as Row#
,min(arpb_tx.UPDATE_DATE) as 'UPDATE DATE'

from CLARITY_TDL_TRAN tdl
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join CLAIM_STMNT_DATE csd on csd.TX_ID =  tdl.TX_ID
left join HSP_ACCT_CVG_LIST hacl on hacl.HSP_ACCOUNT_ID = tdl.HSP_ACCOUNT_ID
left join COVERAGE cvg on cvg.COVERAGE_ID = hacl.COVERAGE_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_EDG edg on edg.DX_ID = arpb_tx.PRIMARY_DX_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = arpb_tx.ACCOUNT_ID
left join ZC_GUAR_REL_TO_PAT rel on rel.GUAR_REL_TO_PAT_C = cvg.SUBSC_REL_TO_GUAR_C
left join PATIENT pat on pat.PAT_ID = arpb_tx.PATIENT_ID
left join ZC_SUFFIX suffix on suffix.SUFFIX_C = pat.PAT_NAME_SUFFIX_C 
left join ZC_MARITAL_STATUS zms on zms.MARITAL_STATUS_C = pat.MARITAL_STATUS_C
left join ZC_STATE state on state.STATE_C = pat.STATE_C
left join ZC_SEX sex on sex.RCPT_MEM_SEX_C = pat.SEX_C

where tdl.DETAIL_TYPE = 50 -- INSURANCE CLAIMS
and arpb_tx.SERVICE_DATE >= '1/1/2017'
and arpb_tx.UPDATE_DATE >= @start_date 
and arpb_tx.UPDATE_DATE < @end_date
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and csd.LAST_INVOICE_NUM is not null
and dep.GL_PREFIX not in ('6327')


--and arpb_tx.DEPARTMENT_ID not in -- EXCLUDE RURAL HEALTH
--	(19102101,19102102,19102105,19102103,19102104,17110102,19290068,17110101,19290020,11106133)

--and LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) = '17832455'

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

group by 
LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1)

order by 
LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1)
