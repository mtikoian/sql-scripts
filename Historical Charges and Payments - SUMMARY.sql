DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('9/1/2015')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('12/31/2015');

with charges as
(

select
 date.YEAR_MONTH
,sa.name as REGION
,dep.DEPARTMENT_NAME
,dep.SPECIALTY
,tdl.TX_ID
,ser.PROV_NAME
,eap.PROC_CODE
,eap.PROC_NAME
,epm.PAYOR_NAME
,tdl.AMOUNT
,arpb_tx.OUTSTANDING_AMT
,tdl.PROCEDURE_QUANTITY

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.ORIG_SERVICE_DATE
left join ARPB_TX_VOID void on void.TX_ID = tdl.TX_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
where tdl.DETAIL_TYPE in (1)
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and tdl.ORIG_SERVICE_DATE between @start_date and @end_date
and tdl.AMOUNT <> 0
and void.TX_ID is null
--and tdl.TX_ID = 193000880
),

payments as
(
select 
 tdl.TX_ID
,sum(case when tdl.detail_type = 20 then tdl.AMOUNT else 0 end)*-1 as PAYMENTS
,sum(case when tdl.detail_type = 21 then tdl.AMOUNT else 0 end)*-1 as ADJUSTMENTS
from charges
inner join CLARITY_TDL_TRAN tdl on tdl.TX_ID = charges.TX_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.CUR_PAYOR_ID
where detail_type in (20,21) -- CHARGES MATCHED TO PAYMENT
group by 
 tdl.TX_ID
)

select 
 coalesce(charges.YEAR_MONTH,'') as YEAR_MONTH
,coalesce(upper(charges.REGION),'') as REGION
,coalesce(charges.DEPARTMENT_NAME,'') as DEPARTMENT
,coalesce(upper(charges.SPECIALTY),'') as SPECIALTY
,coalesce(charges.PROV_NAME,'') as BILLING_PROVIDER
,coalesce('[' + charges.PROC_CODE + ']','') as CPT
,coalesce(charges.PROC_NAME,'') as CPT_DESCRIPTION
,coalesce(charges.PAYOR_NAME,'') as ORIGINAL_PAYOR
,coalesce(sum(charges.AMOUNT),0) as CHARGES
,coalesce(sum(charges.PROCEDURE_QUANTITY),0) as UNTIS
,coalesce(sum(payments.PAYMENTS),0) as PAYMENTS
,coalesce(sum(payments.ADJUSTMENTS),0) as ADJUSTMENTS
,coalesce(sum(charges.OUTSTANDING_AMT),0) as OUTSTANDING_AMT
from charges
left join payments on payments.TX_ID = charges.TX_ID

group by 
 charges.YEAR_MONTH
,charges.REGION
,charges.DEPARTMENT_NAME
,charges.SPECIALTY
,charges.PROV_NAME
,charges.PROC_CODE
,charges.PROC_NAME
,charges.PAYOR_NAME

order by 
 charges.YEAR_MONTH
,charges.REGION
,charges.DEPARTMENT_NAME
,charges.SPECIALTY
,charges.PROV_NAME
,charges.PROC_CODE
,charges.PROC_NAME
,charges.PAYOR_NAME