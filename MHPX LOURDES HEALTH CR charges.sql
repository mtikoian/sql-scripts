select
 arpb_tx.TX_ID
,dep.DEPARTMENT_NAME
,cast(arpb_tx.SERVICE_DATE as date) SERVICE_DATE
,cast(arpb_tx.POST_DATE as date) POST_DATE
,cast(arpb_tx.VOID_DATE as date) as VOID_DATE
,acct.ACCOUNT_ID
,acct.ACCOUNT_NAME
,pat.PAT_MRN_ID
,pat.PAT_NAME
,eap.PROC_CODE
,eap.PROC_NAME
,edg.CURRENT_ICD10_LIST
,arpb_tx.MODIFIER_ONE
,arpb_tx.MODIFIER_TWO
,ser.PROV_ID BILLING_PROVIDER_ID
,ser.PROV_NAME BILLING_PROVIDER
,serv.PROV_ID SERVICE_PROVIDER_ID
,serv.PROV_NAME SERVICE_PROVIDER
,arpb_tx.RVU_WORK
,arpb_tx.RVU_MALPRACTICE
,arpb_tx.RVU_OVERHEAD
,arpb_tx.RVU_TOTAL
,arpb_tx.AMOUNT

from ARPB_TRANSACTIONS arpb_tx 
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = arpb_tx.ACCOUNT_ID
left join PATIENT pat on pat.PAT_ID = arpb_tx.PATIENT_ID
left join CLARITY_SER serv on serv.PROV_ID = arpb_tx.SERV_PROVIDER_ID
left join CLARITY_EDG edg on edg.DX_ID = arpb_tx.PRIMARY_DX_ID

where arpb_tx.DEPARTMENT_ID = 19390387
and arpb_tx.SERVICE_DATE <= '2/19/2019'
and arpb_tx.TX_TYPE_C = 1

order by arpb_tx.SERVICE_DATE, arpb_tx.TX_ID

