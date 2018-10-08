DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

SELECT 
 arpb_tx.TX_ID as 'TRANSACTION ID'
,cast(arpb_tx.SERVICE_DATE as date) as 'SERVICE DATE'
,cast(arpb_tx.POST_DATE as date) as 'POST DATE'
,upper(sa.NAME) + ' [' + sa.RPT_GRP_TEN + ']' as 'REGION'
,loc.RPT_GRP_THREE + ' [' + loc.RPT_GRP_TWO + ']' as 'LOCATION'
,dep.RPT_GRP_TWO + ' [' + dep.RPT_GRP_ONE + ']' as 'DEPARTMENT'
,dep.SPECIALTY as 'SPECIALTY'
,eap.PROC_NAME + ' [' + cast(eap.PROC_CODE as varchar) + ']' as 'PROCEDURE'
,epm.PAYOR_NAME + ' [' + cast(epm.PAYOR_ID as varchar) + ']' as 'PAYOR'
,ser.PROV_NAME + ' [' + cast(ser.PROV_ID as varchar) + ']' as 'BILLING PROVIDER'
,emp.NAME + ' [' + cast(emp.USER_ID as varchar) + ']' as 'USER'
,zmds.NAME as 'MODULE'
,arpb_tx.AMOUNT as 'AMOUNT'

FROM ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.lOC_ID
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EPM epm on epm.PAYOR_ID = arpb_tx.PAYOR_ID
left join CLARITY_EMP emp on emp.USER_ID = arpb_tx.USER_ID
left join ZC_MTCH_DIST_SRC zmds on zmds.MTCH_TX_HX_DIST_C = arpb_tx.CREDIT_SRC_MODULE_C

WHERE loc.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and arpb_tx.TX_TYPE_C = 3
and arpb_tx.POST_DATE >= @start_date
and arpb_tx.POST_DATE <= @end_date

ORDER BY arpb_tx.TX_ID


