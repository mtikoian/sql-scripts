/*Need a Detail report for SRMG Urbana FM & Peds (11106133) where Medicaid and Managed Medicaid is the Primary Payor.  
Need Charge, Payment, and EOB - allowed, 
Need Patient Name, ID, CPT Code and Description, Department, Payor, DOS  Run for service dates 06-01-17 to 07-30-18. 
Please assign to Dustin Plowman to work with Tina
*/
with charges as
(
select 
 arpb_tx.TX_ID as 'CHARGE ETR'
,cast(arpb_tx.SERVICE_DATE as date) as 'SERVICE DATE'
,pat.PAT_NAME as 'PATIENT NAME'
,cast(pat.PAT_MRN_ID as varchar) as 'PATIENT MRN'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'
,dep.DEPARTMENT_ID as 'DEPARTMENT ID'
,dep.DEPARTMENT_NAME as 'DEPARTMENT NAME'
,fc.FINANCIAL_CLASS_NAME as 'ORIG FINANCIAL CLASS'
,arpb_tx.AMOUNT as 'CHARGE AMOUNT'

from ARPB_TRANSACTIONS arpb_tx
left join PATIENT pat on pat.PAT_ID = arpb_tx.PATIENT_ID--
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = arpb_tx.ORIGINAL_FC_C

where arpb_tx.DEPARTMENT_ID = 11106133  -- SRMG Urbana FM & Peds
and arpb_tx.SERVICE_DATE >= '6/1/2017'
and arpb_tx.SERVICE_DATE <= '7/30/2018'
and arpb_tx.TX_TYPE_C = 1 -- Charges
and arpb_tx.VOID_DATE is null
and arpb_tx.ORIGINAL_FC_C in (3,102) -- Medicaid and Managed Medicaid
and arpb_tx.AMOUNT <> 0
),

payments as
(select 
 tdl.TX_ID 
,epm.PAYOR_NAME as 'PAYOR'
,eob.CVD_AMT as 'ALLOWED AMOUNT'
,tdl.AMOUNT *-1 as 'PAYMENT AMOUNT'
from charges 
left join CLARITY_TDL_TRAN tdl on tdl.TX_ID = charges.[CHARGE ETR]
left join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ACTION_PAYOR_ID
where tdl.DETAIL_TYPE = 20 -- charges matched to payments
and tdl.ACTION_FIN_CLASS in (3,102)
)

select *
from charges
left join payments on payments.TX_ID = charges.[CHARGE ETR]
--where charges.TX_ID = 210677695
order by charges.[CHARGE ETR]