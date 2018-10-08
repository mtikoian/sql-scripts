select distinct
eap.PROC_CODE [CDMNumber]
,eap.PROC_NAME [CodeDescription]
,eap_eff.EFF_FROM_DATE [ActiveDate]
,' ' [PayerCode]
,' ' [PatientType]
,eap_ot.CPT_CODE [CPT]
,fsp.PROC_MOD_ID
,1 [Multiplier]
,eap.UB_REV_CODE_ID [RevCode]
,fsp.UNIT_CHARGE_AMOUNT [Charge]
,fsp.PROC_ID
,fsp.FEE_SCHEDULE_ID
,fsp.PROC_CODE

from (select fsp.UNIT_CHARGE_AMOUNT, fsp.PROC_ID, fsp.LINE, fsp.CONTACT_DATE, fsp.PROC_MOD_ID, fsp.FEE_SCHEDULE_ID, fsp.PROC_CODE
	from (select fsp.unit_charge_amount, fsp.proc_id, ROW_NUMBER() over(PARTITION BY proc_id ORDER BY contact_date desc) AS LINE, fsp.CONTACT_DATE, fsp.PROC_MOD_ID, fsp.FEE_SCHEDULE_ID,
					fsp.PROC_CODE
					from CLARITY_FSC_PROC fsp) fsp where fsp.LINE=1
					) fsp
left outer join CLARITY_EAP eap on eap.PROC_ID = fsp.PROC_ID
left outer join CLARITY_EAP_EFF_DT eap_eff on eap_eff.PROC_ID = eap.PROC_ID
left outer join CLARITY_EAP_OT eap_ot on eap_ot.PROC_ID = fsp.PROC_ID 
										and eap_ot.CONTACT_DATE = fsp.CONTACT_DATE 
--where fsp.CONTACT_DATE between 
/*
select * from CLARITY_FSC_PROC where proc_id = 23084
select * from CLARITY_EAP where PROC_ID =23084
select * from CLARITY_EAP_EFF_DT where PROC_ID =23084
select * from CLARITY_EAP_OT where PROC_ID = 23084
*/
