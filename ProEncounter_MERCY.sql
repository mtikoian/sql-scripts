select
arpb.tx_id,
 coalesce(arpb.DEPARTMENT_ID,'') as 'ClinicCode' 
,coalesce(arpb.LOC_ID,'') as 'Facility'		
,coalesce(pos.POS_TYPE,'') as 'PlaceOfService'
,coalesce(pat.PAT_MRN_ID,'') as 'MedicalRecordNumber'
,coalesce(convert(varchar(20), arpb.PAT_ENC_CSN_ID),'') as 'EncounterNumber'
,coalesce(pat.BIRTH_DATE,'') as 'DOB'
,coalesce(zc_sex.NAME,'') as 'Gender'
,coalesce(arpb.SERVICE_DATE,'') as 'ServiceDate'
,coalesce(ser2_bill.NPI,'') as 'PhysicianNPI'
,coalesce(ser_bill.PROV_NAME,'') as 'PhysicianName'
,coalesce(spec.NAME,'') as 'PhysicianSpeciality'
,coalesce(fc.NAME,'') as 'FinClass'
,coalesce(epm.PAYOR_NAME,'') as 'Payer'
,coalesce(arpb.CPT_CODE,'') as 'CPT'
,coalesce(arpb.MODIFIER_ONE,'') as 'CPTMod1'
,coalesce(arpb.MODIFIER_TWO,'') as 'CPTMod2'
,coalesce(arpb.MODIFIER_THREE,'') as 'CPTMod3'
,coalesce(arpb.MODIFIER_FOUR,'') as 'CPTMod4'
,coalesce(edg1.DIAGNOSIS_CODE,'') as [PrimaryDiag]
,coalesce(edg2.DIAGNOSIS_CODE,'') as [Diag2]
,coalesce(edg3.DIAGNOSIS_CODE,'') as [Diag3]
,coalesce(edg4.DIAGNOSIS_CODE,'') as [Diag4]
,coalesce(arpb.AMOUNT,'') as 'Charge'
,coalesce(eap.PROC_CODE,'') as 'CDMNumber'
,coalesce(arpb.PROCEDURE_QUANTITY,'') as 'Units'


from ARPB_TRANSACTIONS arpb
inner join PATIENT pat on pat.PAT_ID = arpb.PATIENT_ID
left join ZC_SEX zc_sex on zc_sex.RCPT_MEM_SEX_C = pat.SEX_C
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = arpb.BILLING_PROV_ID
left join CLARITY_SER_2 ser2_bill on ser2_bill.PROV_ID = ser_bill.PROV_ID
left join ZC_SPECIALTY spec on spec.SPECIALTY_C = arpb.PROV_SPECIALTY_C
left join CLARITY_EAP eap on eap.PROC_ID = arpb.PROC_ID
left join CLARITY_EDG edg1 on edg1.DX_ID = arpb.PRIMARY_DX_ID
left join CLARITY_EDG edg2 on edg2.DX_ID = arpb.DX_TWO_ID
left join CLARITY_EDG edg3 on edg3.DX_ID = arpb.DX_THREE_ID
left join CLARITY_EDG edg4 on edg4.DX_ID = arpb.DX_FOUR_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = arpb.ORIGINAL_EPM_ID
left join ZC_FINANCIAL_CLASS fc on fc.FINANCIAL_CLASS = epm.FINANCIAL_CLASS
left join CLARITY_POS pos on arpb.POS_ID = pos.POS_ID
left join ARPB_TX_VOID arpb_void on arpb.TX_ID = arpb_void.TX_ID

where arpb.SERVICE_AREA_ID in (11,12,13,16,17,18,19)
and arpb.SERVICE_DATE >= '2016-03-01'
and arpb.TX_TYPE_C in (1)
and arpb.AMOUNT is not null
and arpb_void.TX_ID is null

order by tx_id