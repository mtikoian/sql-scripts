declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

select distinct
coalesce(arpb.DEPARTMENT_ID,'') as [ClinicCode]
,coalesce(arpb.SERVICE_AREA_ID,'') as [HSPCODE]
,coalesce(pos.pos_type,'') as [PlaceOfService]
,coalesce(zc_sex.NAME,'') as [Gender]
,coalesce(arpb.SERVICE_DATE,'') as [ServiceDate]
,coalesce(ser2_bill.NPI,'') as [PhysicianNPI]
,coalesce(ser_bill.PROV_NAME,'') as [Physician Name]
,coalesce(zc_spec_bill.NAME,'') as [PhysicianSpecialty]
,coalesce(fc.FINANCIAL_CLASS_NAME,'') as [FinClass]
,coalesce(epm.PAYOR_NAME,'') as [Payer]
,coalesce(eap_ot.CPT_CODE,'') as [CPT]
,coalesce(arpb.MODIFIER_ONE,'') as [CPTMod1]
,coalesce(arpb.MODIFIER_TWO,'') as [CPTMod2]
,coalesce(arpb.MODIFIER_THREE,'') as [CPTMod3]
,coalesce(arpb.MODIFIER_FOUR,'') as [CPTMod4]
,coalesce(edg1.DIAGNOSIS_CODE,'') as [PrimaryDiag]
,coalesce(edg2.DIAGNOSIS_CODE,'') as [Diag2]
,coalesce(edg3.DIAGNOSIS_CODE,'') as [Diag3]
,coalesce(edg4.DIAGNOSIS_CODE,'') as [Diag4]
--,hsp_tx.TX_AMOUNT [Charge]
,coalesce(arpb.amount,'') as [arpb_amount]
,coalesce(eap.PROC_CODE,'') as [CDMNumber]
,coalesce(arpb.PROCEDURE_QUANTITY,'') as [Units]
--,arpb_mod.HOSP_ACCT_ID
,coalesce(arpb.ACCOUNT_ID,'') as  [Account ID]-- replaces HOSP_ACC_ID
from ARPB_TRANSACTIONS arpb
left outer join clarity_pos pos on pos.pos_id = arpb.pos_id
--inner join HSP_TRANSACTIONS hsp_tx on hsp_tx.TX_ID = arpb.TX_ID
left outer join ARPB_TX_MODERATE arpb_mod on arpb_mod.TX_ID = arpb.TX_ID
--left outer join HSP_ACCOUNT hsp_act on hsp_act.HSP_ACCOUNT_ID = arpb_mod.HOSP_ACCT_ID
inner join PATIENT pat on pat.PAT_ID = arpb.PATIENT_ID
left outer join ZC_PREF_PCP_SEX zc_sex on zc_sex.PREF_PCP_SEX_C = pat.SEX_C
left outer join CLARITY_SER ser_bill on ser_bill.PROV_ID = arpb.BILLING_PROV_ID
left outer join CLARITY_SER_2 ser2_bill on ser2_bill.PROV_ID = ser_bill.PROV_ID
left outer join CLARITY_SER_SPEC ser_bill_spec on ser_bill_spec.PROV_ID = ser_bill.PROV_ID and ser_bill_spec.line=1
left outer join ZC_SPECIALTY zc_spec_bill on zc_spec_bill.SPECIALTY_C = ser_bill_spec.SPECIALTY_C
left outer join CLARITY_EPM epm on epm.PAYOR_ID = arpb.ORIGINAL_EPM_ID
left outer join CLARITY_FC fc on fc.FINANCIAL_CLASS = epm.FINANCIAL_CLASS
left outer join CLARITY_EAP eap on eap.PROC_ID = arpb.PROC_ID
left outer join CLARITY_EAP_OT eap_ot on eap_ot.PROC_ID = eap.PROC_ID
left outer join CLARITY_EDG edg1 on edg1.DX_ID = arpb.PRIMARY_DX_ID
left outer join CLARITY_EDG edg2 on edg2.DX_ID = arpb.DX_TWO_ID
left outer join CLARITY_EDG edg3 on edg3.DX_ID = arpb.DX_THREE_ID
left outer join CLARITY_EDG edg4 on edg4.DX_ID = arpb.DX_FOUR_ID
left outer join ARPB_TX_VOID arpb_void on arpb.TX_ID = arpb_void.TX_ID

where --cast(hsp_act.ACCT_ZERO_BAL_DT as date) between @start_date and @end_date
arpb.POST_DATE between @start_date and @end_date
and arpb.TX_TYPE_C in(1)
and arpb.AMOUNT is not null
and arpb_void.TX_ID is null
--and hsp_act.SERV_AREA_ID in (11,13,16,17,18,19)
and arpb.SERVICE_AREA_ID in (11,13,16,17,18,19)

