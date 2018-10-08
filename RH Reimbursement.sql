/*
Departments – 17110101 MLOR Lagrange PC and 17110102 MLOR Wellington 19290020 and 19290068
Fin Class – Medicare, Managed Medicare, Medicaid, Managed Medicaid 
Service Date – Jan 1  2018 to Aug 31 2018

Columns – Patient, MRN, DOS, Procedure, Department, Provider, Payor, Charge, Payment, EOB Detail (allowed amount, deductible, copay, remit code)

Wendy - are you able to create a Service Now ticket for Dustin with this criteria? 
*/

select 
 tdl.TX_ID as CHARGE_ETR
,eob.TX_ID as PAYMENT_ETR
,cast(arpb_tx.POST_DATE as date) as PAYMENT_POST_DATE
,pat.PAT_MRN_ID
,pat.PAT_NAME
,cast(tdl.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,eap.PROC_CODE
,eap.PROC_NAME
,dep.DEPARTMENT_NAME
,ser.PROV_NAME
,fc.FINANCIAL_CLASS_NAME
,coalesce(tdl.ORIG_AMT,0) as CHARGE_AMT
,coalesce(eob.CVD_AMT,0) as CVD_AMT
,coalesce(eob.NONCVD_AMT,0) as NONCVD_AMT
,coalesce(eob.DED_AMT,0) as DED_AMT
,coalesce(eob.COPAY_AMT,0) as COPAY_AMT
,coalesce(eob.COINS_AMT,0) as COINS_AMT
,coalesce(eob.COB_AMT,0) as COB_AMT
,coalesce(eob.PAID_AMT,0) as PAID_AMT
,coalesce(rmc.REMIT_CODE_NAME,'') as REMIT_CODE

from CLARITY_TDL_TRAN tdl
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
inner join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = tdl.ACTION_FIN_CLASS
left join CLARITY_RMC rmc on rmc.REMIT_CODE_ID = eob.ACT_WIN_RMC_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = eob.TX_ID
left join ARPB_TRANSACTIONS arpb_chg on arpb_chg.TX_ID = tdl.TX_ID

where tdl.DETAIL_TYPE = 20
and tdl.DEPT_ID in (17110101,17110102,19290020,19290068)
and tdl.ORIG_SERVICE_DATE >= '1/1/2018'
and tdl.ORIG_SERVICE_DATE <= '8/31/2018'
and fc.FINANCIAL_CLASS_NAME in ('Medicare','Managed Medicare','Medicaid','Managed Medicaid')
and arpb_chg.VOID_DATE is null

order by tdl.TX_ID, arpb_tx.POST_DATE