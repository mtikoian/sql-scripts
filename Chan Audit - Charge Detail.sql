DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('7/1/2017')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('12/31/2017');

with charges as
(

select
 date.YEAR_MONTH
,tdl.ORIG_SERVICE_DATE
,tdl.POST_DATE
,sa.RPT_GRP_TEN  as REGION_ID
,sa.name as REGION_NAME
,loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,dep.SPECIALTY
,tdl.TX_ID
,pat.PAT_NAME
,pat.BIRTH_DATE
,pat.SSN
,ser_bill.PROV_ID as BILL_PROV_ID
,ser_bill.PROV_NAME as BILL_PROV_NAME
,ser_bill_2.NPI as BILL_PROV_NPI
,ser_perf.PROV_ID as PERF_PROV_ID
,ser_perf.PROV_NAME as PERF_PROV_NAME
,ser_perf_2.NPI as PERF_PROV_NPI
,eap.PROC_CODE
,eap.PROC_NAME
,tdl.MODIFIER_ONE
,tdl.MODIFIER_TWO
,tdl.MODIFIER_THREE
,tdl.MODIFIER_FOUR
,epm.PAYOR_NAME
,fc.FINANCIAL_CLASS_NAME
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
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_SER_2 ser_bill_2 on ser_bill_2.PROV_ID = ser_bill.PROV_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = tdl.PERFORMING_PROV_ID
left join CLARITY_SER_2 ser_perf_2 on ser_perf_2.PROV_ID = ser_perf.PROV_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = tdl.ORIGINAL_FIN_CLASS
where tdl.DETAIL_TYPE in (1)
and sa.RPT_GRP_TEN in (18,19)
and tdl.POST_DATE between @start_date and @end_date
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
where detail_type in (20,21) -- CHARGES MATCHED TO PAYMENT
group by 
 tdl.TX_ID
)

select 
 coalesce(charges.YEAR_MONTH,'') as YEAR_MONTH
,cast(charges.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,cast(charges.POST_DATE as date) as POST_DATE
,coalesce(charges.REGION_ID,'') as REGION_ID
,coalesce(upper(charges.REGION_NAME),'') as REGION
,LOC_ID as LOCATION_ID
,coalesce(charges.LOC_NAME,'') as LOCATION_NAME
,DEPARTMENT_ID as DEPARTMENT_ID
,coalesce(charges.DEPARTMENT_NAME,'') as DEPARTMENT
,coalesce(upper(charges.SPECIALTY),'') as SPECIALTY
,charges.TX_ID as CHARGE_ID
,charges.PAT_NAME as PATIENT_NAME
,cast(charges.BIRTH_DATE as date) as DOB
,charges.SSN as SSN
,coalesce(charges.BILL_PROV_ID,'') as BILLING_PROVIDER_ID
,coalesce(charges.BILL_PROV_NAME,'') as BILLING_PROVIDER_NAME
,coalesce(charges.BILL_PROV_NPI,'') as BILLING_PROVIDER_NPI
,coalesce(charges.PERF_PROV_ID,'') as PERFORMING_PROVIDER_ID
,coalesce(charges.PERF_PROV_NAME,'') as PERFORMING_PROVIDER_NAME
,coalesce(charges.PERF_PROV_NPI,'') as PERFORMING_PROVIDER_NPI
,coalesce('[' + charges.PROC_CODE + ']','') as CPT
,coalesce(charges.PROC_NAME,'') as CPT_DESCRIPTION
,coalesce(charges.MODIFIER_ONE,'') as MODIFIER_ONE
,coalesce(charges.MODIFIER_TWO,'') as MODIFIER_TWO
,coalesce(charges.MODIFIER_THREE,'') as MODIFIER_THREE
,coalesce(charges.MODIFIER_FOUR,'') as MODIFIER_FOUR
,coalesce(charges.PAYOR_NAME,'') as ORIGINAL_PAYOR
,coalesce(charges.FINANCIAL_CLASS_NAME,'') as ORIGINAL_FINANCIAL_CLASS
,coalesce(sum(charges.PROCEDURE_QUANTITY),0) as UNTIS
,coalesce(sum(charges.AMOUNT),0) as CHARGES
,coalesce(sum(payments.PAYMENTS),0) as PAYMENTS
,coalesce(sum(payments.ADJUSTMENTS),0) as ADJUSTMENTS
,coalesce(sum(charges.OUTSTANDING_AMT),0) as OUTSTANDING_AMT
from charges
left join payments on payments.TX_ID = charges.TX_ID

group by 
 charges.YEAR_MONTH
,charges.ORIG_SERVICE_DATE
,charges.POST_DATE
,charges.REGION_ID
,charges.REGION_NAME
,charges.LOC_ID
,charges.LOC_NAME
,charges.DEPARTMENT_ID
,charges.DEPARTMENT_NAME
,charges.SPECIALTY
,charges.TX_ID
,charges.PAT_NAME
,charges.BIRTH_DATE
,charges.SSN
,charges.BILL_PROV_ID
,charges.BILL_PROV_NAME
,charges.BILL_PROV_NPI
,charges.PERF_PROV_ID
,charges.PERF_PROV_NAME
,charges.PERF_PROV_NPI
,charges.PROC_CODE
,charges.PROC_NAME
,charges.MODIFIER_ONE
,charges.MODIFIER_TWO
,charges.MODIFIER_THREE
,charges.MODIFIER_FOUR
,charges.PAYOR_NAME
,charges.FINANCIAL_CLASS_NAME

order by 
 charges.YEAR_MONTH
,charges.ORIG_SERVICE_DATE
,charges.POST_DATE
,charges.REGION_ID
,charges.REGION_NAME
,charges.LOC_ID
,charges.LOC_NAME
,charges.DEPARTMENT_ID
,charges.DEPARTMENT_NAME
,charges.SPECIALTY
,charges.TX_ID
,charges.PAT_NAME
,charges.BIRTH_DATE
,charges.SSN
,charges.BILL_PROV_ID
,charges.BILL_PROV_NAME
,charges.BILL_PROV_NPI
,charges.PERF_PROV_ID
,charges.PERF_PROV_NAME
,charges.PERF_PROV_NPI
,charges.PROC_CODE
,charges.PROC_NAME
,charges.MODIFIER_ONE
,charges.MODIFIER_TWO
,charges.MODIFIER_THREE
,charges.MODIFIER_FOUR
,charges.PAYOR_NAME
,charges.FINANCIAL_CLASS_NAME
