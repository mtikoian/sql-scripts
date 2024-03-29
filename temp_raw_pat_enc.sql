USE [XXXXX]
GO

SELECT [PAT_ID]
      ,[PAT_ENC_DATE_REAL]
      ,[PAT_ENC_CSN_ID]
      ,[CONTACT_DATE]
      ,[ENC_TYPE_C]
      ,[ENC_TYPE_TITLE]
      ,[AGE]
      ,[PCP_PROV_ID]
      ,[FIN_CLASS_C]
      ,[VISIT_PROV_ID]
      ,[VISIT_PROV_TITLE]
      ,[DEPARTMENT_ID]
      ,[BP_SYSTOLIC]
      ,[BP_DIASTOLIC]
      ,[TEMPERATURE]
      ,[PULSE]
      ,[WEIGHT]
      ,[HEIGHT]
      ,[RESPIRATIONS]
      ,[LMP_DATE]
      ,[LMP_OTHER_C]
      ,[HEAD_CIRCUMFERENCE]
      ,[ENC_CLOSED_YN]
      ,[ENC_CLOSED_USER_ID]
      ,[ENC_CLOSE_DATE]
      ,[LOS_PRIME_PROC_ID]
      ,[LOS_PROC_CODE]
      ,[LOS_MODIFIER1_ID]
      ,[LOS_MODIFIER2_ID]
      ,[LOS_MODIFIER3_ID]
      ,[LOS_MODIFIER4_ID]
      ,[CHKIN_INDICATOR_C]
      ,[CHKIN_INDICATOR_DT]
      ,[APPT_STATUS_C]
      ,[APPT_BLOCK_C]
      ,[APPT_TIME]
      ,[APPT_LENGTH]
      ,[APPT_MADE_DATE]
      ,[APPT_PRC_ID]
      ,[CHECKIN_TIME]
      ,[CHECKOUT_TIME]
      ,[ARVL_LST_DL_TIME]
      ,[ARVL_LST_DL_USR_ID]
      ,[APPT_ENTRY_USER_ID]
      ,[APPT_CANC_USER_ID]
      ,[APPT_CANCEL_DATE]
      ,[CHECKIN_USER_ID]
      ,[CANCEL_REASON_C]
      ,[APPT_SERIAL_NO]
      ,[HOSP_ADMSN_TIME]
      ,[HOSP_DISCHRG_TIME]
      ,[HOSP_ADMSN_TYPE_C]
      ,[NONCVRED_SERVICE_YN]
      ,[REFERRAL_REQ_YN]
      ,[REFERRAL_ID]
      ,[ACCOUNT_ID]
      ,[COVERAGE_ID]
      ,[AR_EPISODE_ID]
      ,[CLAIM_ID]
      ,[PRIMARY_LOC_ID]
      ,[CHARGE_SLIP_NUMBER]
      ,[VISIT_EPM_ID]
      ,[VISIT_EPP_ID]
      ,[VISIT_FC]
      ,[COPAY_DUE]
      ,[COPAY_COLLECTED]
      ,[COPAY_SOURCE_C]
      ,[COPAY_TYPE_C]
      ,[COPAY_REF_NUM]
      ,[COPAY_PMT_EXPL_C]
      ,[UPDATE_DATE]
      ,[SERV_AREA_ID]
      ,[HSP_ACCOUNT_ID]
      ,[ADM_FOR_SURG_YN]
      ,[SURGICAL_SVC_C]
      ,[INPATIENT_DATA_ID]
      ,[IP_EPISODE_ID]
      ,[APPT_QNR_ANS_ID]
      ,[ATTND_PROV_ID]
      ,[ORDERING_PROV_TEXT]
      ,[ES_ORDER_STATUS_C]
      ,[EXTERNAL_VISIT_ID]
      ,[CONTACT_COMMENT]
      ,[OUTGOING_CALL_YN]
      ,[DATA_ENTRY_PERSON]
      ,[IS_WALK_IN_YN]
      ,[CM_CT_OWNER_ID]
      ,[REFERRAL_SOURCE_ID]
      ,[SIGN_IN_TIME]
      ,[SIGN_IN_USER_ID]
      ,[APPT_TARGET_DATE]
      ,[WC_TPL_VISIT_C]
      ,[ROUTE_SUM_PRNT_YN]
      ,[CONSENT_TYPE_C]
      ,[PHONE_REM_STAT_C]
      ,[APPT_CONF_STAT_C]
      ,[APPT_CONF_PERS]
      ,[APPT_CONF_INST]
      ,[CANCEL_REASON_CMT]
      ,[ORDERING_PROV_ID]
      ,[BMI]
      ,[BSA]
      ,[AVS_PRINT_TM]
      ,[AVS_FIRST_USER_ID]
      ,[ENC_MED_FRZ_RSN_C]
      ,[WC_TPL_VISIT_CMT]
      ,[HOSP_LICENSE_C]
      ,[ACCREDITATION_C]
      ,[CERTIFICATION_C]
      ,[ENTITY_C]
      ,[EFFECTIVE_DATE_DT]
      ,[DISCHARGE_DATE_DT]
      ,[EFFECTIVE_DEPT_ID]
      ,[TOBACCO_USE_VRFY_YN]
      ,[PHON_CALL_YN]
      ,[PHON_NUM_APPT]
      ,[ENC_CLOSE_TIME]
      ,[COPAY_PD_THRU]
      ,[INTERPRETER_NEED_YN]
      ,[VST_SPECIAL_NEEDS_C]
      ,[INTRP_ASSIGNMENT_C]
      ,[ASGND_INTERP_TYPE_C]
      ,[INTERPRETER_VEND_C]
      ,[INTERPRETER_NAME]
      ,[CHECK_IN_KIOSK_ID]
      ,[BENEFIT_PACKAGE_ID]
      ,[BENEFIT_COMP_ID]
      ,[BEN_ADJ_TABLE_ID]
      ,[BEN_ADJ_FORMULA_ID]
      ,[BEN_ENG_SP_AMT]
      ,[BEN_ADJ_COPAY_AMT]
      ,[BEN_ADJ_METHOD_C]
      ,[DOWNTIME_CSN]
      ,[ENTRY_TIME]
      ,[ENC_CREATE_USER_ID]
      ,[ENC_INSTANT]
      ,[ED_ARRIVAL_KIOSK_ID]
  FROM [dbo].[pat_enc]
  WHERE (CAST(cONTACT_DATE AS DATETIME) >= DATEADD(yy,-2, CAST(FLOOR(CAST(DATEADD(dd,-(DAY(GETDATE()))+1,GETDATE()) AS FLOAT)) AS DATETIME))
	AND CAST(CONTACT_DATE AS DATETIME) < CAST(FLOOR(CAST(DATEADD(dd,-(DAY(GETDATE()))+1,GETDATE()) AS FLOAT)) AS DATETIME))

	GO


