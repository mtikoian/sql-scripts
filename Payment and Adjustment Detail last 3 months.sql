--2. Adjustments and Payments with code for the past 3 months with transaction detail included

select
 coalesce(date.YEAR_MONTH,'') as YEAR_MONTH
,coalesce(upper(sa.name),'') as REGION
,coalesce(dep.DEPARTMENT_NAME,'') as DEPARTMENT_NAME
,coalesce(dep.SPECIALTY,'') as SPECIALTY
,coalesce(ser.PROV_NAME,'') as BILLING_PROVIDER
,coalesce('[' + eap.PROC_CODE + ']','') as TRANSACTION_CODE
,coalesce(eap.PROC_NAME,'') as TRANSACTION_DESCRIPTION
,coalesce(cast(epm.PAYOR_ID as nvarchar),'') as PAYOR_ID
,coalesce(epm.PAYOR_NAME,'') as PAYOR_NAME
,coalesce(fc.FINANCIAL_CLASS_NAME,'') as FINANCIAL_CLASS
,sum(tdl.amount)*-1 as AMOUNT
from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.POST_DATE
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.CUR_PAYOR_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = epm.FINANCIAL_CLASS
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
where tdl.DETAIL_TYPE in (20)
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and tdl.POST_DATE between '01/01/2017' and '12/31/2017'
and tdl.AMOUNT <> 0

group by 
  date.YEAR_MONTH
 ,sa.NAME
 ,dep.DEPARTMENT_NAME
 ,dep.SPECIALTY
 ,ser.PROV_NAME
 ,eap.PROC_CODE
 ,eap.PROC_NAME
  ,epm.PAYOR_ID
 ,epm.PAYOR_NAME
 ,fc.FINANCIAL_CLASS_NAME

order by 
  date.YEAR_MONTH
 ,sa.NAME
 ,dep.DEPARTMENT_NAME
 ,dep.SPECIALTY
 ,ser.PROV_NAME
 ,eap.PROC_CODE
 ,eap.PROC_NAME
 ,epm.PAYOR_ID
 ,epm.PAYOR_NAME
 ,fc.FINANCIAL_CLASS_NAME

