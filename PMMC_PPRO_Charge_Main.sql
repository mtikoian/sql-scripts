DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

--DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-2')
--DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-2')

select 

 LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1) as 'INVOICE NUMBER'
,tdl.TX_ID as 'CHARGE ID'
,loc.GL_PREFIX + 'P'  as 'FACILITY ID'
,loc.LOC_ID as 'ORGANIZATIONAL CODE'
,loc.LOC_ID as 'REVENUE LOCATION ID'
,coalesce(loc.GL_PREFIX,'0') +  coalesce(dep.GL_PREFIX,'0') + '-' + coalesce(cast(dep.DEPARTMENT_ID as nvarchar),'0') as 'COST CENTER CODE'
,pos.POS_ID as 'POS ID'
,pos.POS_TYPE_C as 'POS TYPE'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE DATE'
,cast(tdl.POST_DATE as date) as 'POST_DATE'
,cast(csd.FIRST_CLM_DATE as date) as 'FIRST CLAIM DATE'
,left(eap.PROC_CODE,5) as 'CPT CODE'
,edg1.CURRENT_ICD10_LIST as 'DIAGNOSIS ONE'
,edg2.CURRENT_ICD10_LIST as 'DIAGNOSIS TWO'
,edg3.CURRENT_ICD10_LIST as 'DIAGNOSIS THREE'
,edg4.CURRENT_ICD10_LIST as 'DIAGNOSIS FOUR'
,edg5.CURRENT_ICD10_LIST as 'DIAGNOSIS FIVE'
,edg6.CURRENT_ICD10_LIST as 'DIAGNOSIS SIX'
,left(tdl.MODIFIER_ONE,2) as 'MODIFIER ONE'
,left(tdl.MODIFIER_TWO,2) as 'MODIFIER TWO'
,left(tdl.MODIFIER_THREE,2) as 'MODIFIER THREE'
,left(tdl.MODIFIER_FOUR,2) as 'MODIFIER FOUR'
,tdl.PERFORMING_PROV_ID as 'PERFORMING PROVIDER ID'
,tdl.BILLING_PROVIDER_ID as 'BILLING PROVIDER ID'
,case when tdl.DETAIL_TYPE = 10 then 0 
	  when atm.TYPE_OF_SERVICE_C = 7 then datediff(minute, tat.START_TIME, tat.END_TIME) else tdl.PROCEDURE_QUANTITY end as 'UNITS'
,case when tdl.DETAIL_TYPE = 10 then 0 else tdl.AMOUNT end as 'AMOUNT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLAIM_STMNT_DATE csd on csd.TX_ID = tdl.TX_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_EDG edg1 on edg1.DX_ID = tdl.DX_ONE_ID
left join CLARITY_EDG edg2 on edg2.DX_ID = tdl.DX_TWO_ID
left join CLARITY_EDG edg3 on edg3.DX_ID = tdl.DX_THREE_ID
left join CLARITY_EDG edg4 on edg4.DX_ID = tdl.DX_FOUR_ID
left join CLARITY_EDG edg5 on edg5.DX_ID = tdl.DX_FIVE_ID
left join CLARITY_EDG edg6 on edg6.DX_ID = tdl.DX_SIX_ID
left join CLARITY_POS pos on pos.POS_ID = tdl.POS_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join ARPB_TX_MODERATE atm on atm.TX_ID = tdl.TX_ID
left join TX_ANES_TIMES tat on tat.tx_id = tdl.tx_id

where tdl.DETAIL_TYPE in (1,10)
and arpb_tx.SERVICE_DATE >= '1/1/2017'
and arpb_tx.UPDATE_DATE >= @start_date 
and arpb_tx.UPDATE_DATE < @end_date
and csd.LAST_INVOICE_NUM is not null
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and dep.GL_PREFIX not in ('6327')

--and tdl.DEPT_ID not in 
--	(19102101,19102102,19102105,19102103,19102104,17110102,19290068,17110101,19290020,11106133)	-- exclude Rural Health


order by LEFT(csd.LAST_INVOICE_NUM, LEN(csd.LAST_INVOICE_NUM) - 1), tdl.TX_ID