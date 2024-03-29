select 
 ucl.UCL_ID
,zsf.NAME as 'SYSTEM_FLAG'
,ucl.CHARGE_SESSION_ID
,pac2.TAR_ID
,eap_orig.PROC_CODE as 'ORIG PROCEDURE CODE'
,eap_orig.PROC_NAME as 'ORIG PROCEDURE DESC'
,eap.PROC_CODE as 'NEW PROCEDURE CODE'
,eap.PROC_NAME as 'NEW PROCEDURE DESC'
from CLARITY_UCL ucl
left join ZC_SYSTEM_FLAG zsf on zsf.SYSTEM_FLAG_C = ucl.SYSTEM_FLAG_C 
left join CLARITY_EAP eap on eap.PROC_ID = ucl.PROCEDURE_ID
left join ZC_CHG_DESTINATION zcd on zcd.CHG_DESTINATION_C = ucl.CHG_DESTINATION_C
left join PRE_AR_CHG_2 pac2 on pac2.CHRG_ROUTER_SRC_ID = ucl.UCL_ID
left join X_CLARITY_UCL xcu on xcu.UCL_ID = ucl.UCL_ID
left join CLARITY_EAP eap_orig on eap_orig.PROC_ID = xcu.ORIG_PROCEDURE_ID
where ucl.UCL_ID in (202258556,202258557,202258558,202258559)
and ucl.CHG_DESTINATION_C = 8 -- RESOLUTE PROFESSIONAL BILLING
and ucl.SYSTEM_FLAG_C in (2,3) -- DELETED and MODIFIED
order by ucl.UCL_ID
