/**********************************************************************************************************
DEPARTMENT
**********************************************************************************************************/

SELECT
 CLARITY_DEP.DEPARTMENT_ID
,CLARITY_DEP.DEPARTMENT_NAME
,CLARITY_DEP.SPECIALTY_DEP_C
,CLARITY_DEP.SPECIALTY
,CLARITY_DEP.GL_PREFIX AS DEPARTMENT_GL
,CLARITY_LOC.GL_PREFIX AS LOCATION_GL

FROM
CLARITY_DEP
LEFT JOIN CLARITY_LOC ON CLARITY_LOC.LOC_ID = CLARITY_DEP.REV_LOC_ID

/**********************************************************************************************************
LOCATION
**********************************************************************************************************/

SELECT 
 CLARITY_LOC.LOC_ID
,CASE WHEN LOC_ID = 19 THEN 'KENTUCKY' ELSE CLARITY_LOC.LOC_NAME END AS LOC_NAME
,CLARITY_LOC.LOCATION_GROUP
,CLARITY_LOC.POS_TYPE
,CLARITY_LOC.LOCATION_ABBR
,CLARITY_LOC.SERV_AREA_ID
 
FROM CLARITY_LOC

/**********************************************************************************************************
PLAN
**********************************************************************************************************/

SELECT
 CLARITY_EPP.BENEFIT_PLAN_ID
,CLARITY_EPP.BENEFIT_PLAN_NAME
,COALESCE(CLARITY_EPP.RPT_GRP_TWO,'SELF PAY') AS FINANCIAL_CLASS
,COALESCE(CLARITY_EPP.RPT_GRP_ONE,'SELF PAY') AS ORIGINAL_PAYOR

FROM CLARITY_EPP

/**********************************************************************************************************
PAYOR
**********************************************************************************************************/

SELECT 
 CLARITY_EPM.PAYOR_ID
,CLARITY_EPM.PAYOR_NAME
,CLARITY_EPM.FINANCIAL_CLASS
,CLARITY_FC.FINANCIAL_CLASS_NAME
,CLARITY_EPM.PRODUCT_TYPE
,CLARITY_EPM.ADDR_LINE_1
,CLARITY_EPM.ADDR_LINE_2
,CLARITY_EPM.CITY
,CLARITY_EPM.STATE_C
,CLARITY_EPM.COUNTY_C
,CLARITY_EPM.ZIP_CODE
,CLARITY_EPM.PHONE

 FROM   
 CLARITY_EPM
 LEFT JOIN CLARITY_FC ON CLARITY_FC.FINANCIAL_CLASS = CLARITY_EPM.FINANCIAL_CLASS

 /**********************************************************************************************************
POS
**********************************************************************************************************/

SELECT 
 CLARITY_POS.POS_ID
,CASE WHEN POS_ID = 19 THEN 'KENTUCKY' ELSE CLARITY_POS.POS_NAME END AS POS_NAME
,CLARITY_POS.POS_GROUP 
,CLARITY_POS.POS_TYPE 
,CLARITY_POS.ADDRESS_LINE_1 
,CLARITY_POS.ADDRESS_LINE_2 
,CLARITY_POS.CITY
,CLARITY_POS.STATE_C
,CLARITY_POS.ZIP
,CLARITY_POS.AREA_CODE 
,CLARITY_POS.PHONE

FROM CLARITY_POS

/**********************************************************************************************************
PROCEDURE
**********************************************************************************************************/

SELECT 
 CLARITY_EAP.PROC_ID 
,CLARITY_EAP.PROC_NAME 
,CLARITY_EAP.PROC_CODE 
,CLARITY_EAP.IS_ACTIVE_YN

 FROM CLARITY_EAP

 /**********************************************************************************************************
RMC
**********************************************************************************************************/

SELECT 
 CLARITY_RMC.REMIT_CODE_ID
,CLARITY_RMC.REMIT_CODE_NAME 
,CLARITY_RMC.RPT_GROUP_C
,CLARITY_RMC.RPT_GROUP_TITLE 
,CLARITY_RMC.REMIT_CODE_GROUP_C 
 FROM CLARITY_RMC

 /**********************************************************************************************************
SERVICE AREA
**********************************************************************************************************/

SELECT 
CLARITY_SA.SERV_AREA_ID
,CASE WHEN CLARITY_SA.SERV_AREA_ID = 19 THEN 'KENTUCKY' ELSE CLARITY_SA.SERV_AREA_NAME END AS SERV_AREA_NAME 
,CASE WHEN CLARITY_SA.SERV_AREA_ID = 19 THEN 'KYIN' ELSE CLARITY_SA.SERV_AREA_ABBR END AS SERV_AREA_ABBR
FROM CLARITY_SA
WHERE CLARITY_SA.SERV_AREA_ID NOT IN (291,292) -- SAME SERV_AREA_NAME

/**********************************************************************************************************
PROVIDER
**********************************************************************************************************/

SELECT 
CLARITY_SER.PROV_ID
,CLARITY_SER.PROV_NAME
,CLARITY_SER.PROV_TYPE
,CLARITY_SER.IS_RESIDENT 
,CLARITY_SER_2.NPI
,CLARITY_SER.CLINICIAN_TITLE 
,CLARITY_SER.ACTIVE_STATUS
,CLARITY_SER.SER_REF_SRCE_ID
,ZC_SER_RPT_GRP_8.NAME as 'AMA_SPECIALTY'
,ZC_SER_RPT_GRP_9.NAME as 'AMA_SUB_SPECIALTY'
,CRED_SPEC.NAME AS 'CREDENTIALED SPECIALTY'
FROM
CLARITY_SER
LEFT JOIN CLARITY_SER_2 ON CLARITY_SER.PROV_ID=CLARITY_SER_2.PROV_ID
LEFT JOIN ZC_SER_RPT_GRP_8 ON ZC_SER_RPT_GRP_8.RPT_GRP_EIGHT = CLARITY_SER.RPT_GRP_EIGHT
LEFT JOIN ZC_SER_RPT_GRP_9 ON ZC_SER_RPT_GRP_9.RPT_GRP_NINE = CLARITY_SER.RPT_GRP_NINE
LEFT JOIN CLARITY_SER_SPEC ON CLARITY_SER_SPEC.PROV_ID = CLARITY_SER.PROV_ID AND CLARITY_SER_SPEC.LINE = 1
LEFT JOIN ZC_SPECIALTY CRED_SPEC ON CRED_SPEC.SPECIALTY_C = CLARITY_SER_SPEC.SPECIALTY_C

/**********************************************************************************************************
DIAGNOSIS
**********************************************************************************************************/

SELECT
 DX_ID
,DX_NAME
,ICD9_CODE
FROM CLARITY_EDG
WHERE ICD9_CODE IS NOT NULL

UNION

SELECT 
 DX_ID
,DX_NAME
,LEFT(REF_BILL_CODE,20)
FROM CLARITY_EDG
LEFT JOIN ZC_EDG_CODE_SET ON ZC_EDG_CODE_SET.EDG_CODE_SET_C = CLARITY_EDG.REF_BILL_CODE_SET_C
WHERE REF_BILL_CODE_SET_C = 2


/**********************************************************************************************************
GUARANTOR
**********************************************************************************************************/

SELECT 
 ACCOUNT.ACCOUNT_ID
,ACCOUNT.ACCOUNT_NAME
,ACCOUNT.BILLING_ADDRESS_1
,ACCOUNT.BILLING_ADDRESS_2
,ACCOUNT.CITY
,ZC_STATE.NAME as STATE_NAME
,ACCOUNT.ZIP
,ACCOUNT.ACCOUNT_TYPE_C

FROM
ACCOUNT
LEFT JOIN ZC_STATE ON ACCOUNT.STATE_C = ZC_STATE.STATE_C
LEFT JOIN ZC_ACCOUNT_TYPE ON ACCOUNT.ACCOUNT_TYPE_C = ZC_ACCOUNT_TYPE.ACCOUNT_TYPE_C

/**********************************************************************************************************
PATIENT
**********************************************************************************************************/

SELECT 
 PATIENT.PAT_ID
,PATIENT.PAT_LAST_NAME 
,PATIENT.PAT_FIRST_NAME 
,PATIENT.PAT_MIDDLE_NAME 
,PATIENT.ZIP
,PATIENT.BIRTH_DATE 
,PATIENT.PAT_MRN_ID 
,PATIENT.CITY
,ZC_COUNTY.NAME as COUNTY_NAME 
,ZC_STATE.NAME as STATE_NAME
,PATIENT.CUR_PRIM_LOC_ID
,ZC_SEX.NAME AS SEX
,PATIENT.ADD_LINE_1
,PATIENT.ADD_LINE_2
,PATIENT.PAT_STATUS
,left(PATIENT.CUR_PRIM_LOC_ID,2) as SERVICE_AREA
 
FROM
PATIENT 
LEFT OUTER JOIN ZC_COUNTY ON PATIENT.COUNTY_C = ZC_COUNTY.COUNTY_C
LEFT OUTER JOIN ZC_STATE ON PATIENT.STATE_C = ZC_STATE.STATE_C
LEFT OUTER JOIN ZC_SEX ON PATIENT.SEX_C = ZC_SEX.INTERNAL_ID
WHERE PATIENT.PAT_ID LIKE '[A-Z]%'

/**********************************************************************************************************
PATIENT_ENCOUNTER
**********************************************************************************************************/

SELECT 
 PAT_ID
,PAT_ENC_CSN_ID
,CONTACT_DATE
,COPAY_DUE
,COPAY_COLLECTED

FROM PAT_ENC

/**********************************************************************************************************
REFERRAL SOURCE
**********************************************************************************************************/

SELECT 
 REFERRAL_SOURCE.REFERRING_PROV_ID
,REFERRAL_SOURCE.EPIC_REF_SOURCE_ID

FROM REFERRAL_SOURCE

/**********************************************************************************************************
STATE
**********************************************************************************************************/

SELECT 
 ZC_STATE.STATE_C
,ZC_STATE.NAME
,ZC_STATE.TITLE
,ZC_STATE.ABBR
 
FROM ZC_STATE

/**********************************************************************************************************
Date	
**********************************************************************************************************/

SELECT
 CALENDAR_DT
,DAY_OF_WEEK
,WEEK_NUMBER
,MONTH_NUMBER
,MONTH_NAME
,MONTHNAME_YEAR
,QUARTER_STR
,YEAR
,YEAR_MONTH_STR

FROM DATE_DIMENSION
WHERE YEAR >= '2011'
AND CALENDAR_DT <= GETDATE()

/**********************************************************************************************************
Charges
**********************************************************************************************************/

SELECT   
 CLARITY_TDL_TRAN.DETAIL_TYPE 
,CLARITY_TDL_TRAN.POST_DATE 
,CLARITY_TDL_TRAN.ORIG_POST_DATE 
,CLARITY_TDL_TRAN.ORIG_SERVICE_DATE 
,CLARITY_TDL_TRAN.TX_ID 
,CLARITY_TDL_TRAN.TRAN_TYPE  
,CLARITY_TDL_TRAN.MATCH_TRX_ID 
,CLARITY_TDL_TRAN.MATCH_TX_TYPE
,CLARITY_TDL_TRAN.MATCH_PROC_ID
,CLARITY_TDL_TRAN.MATCH_PROV_ID
,CLARITY_TDL_TRAN.MATCH_LOC_ID
,CLARITY_TDL_TRAN.ACCOUNT_ID 
,CLARITY_TDL_TRAN.PAT_ID 
,CLARITY_TDL_TRAN.AMOUNT 
,CLARITY_TDL_TRAN.PATIENT_AMOUNT 
,CLARITY_TDL_TRAN.INSURANCE_AMOUNT 
,CLARITY_TDL_TRAN.RELATIVE_VALUE_UNIT 
,CLARITY_TDL_TRAN.CUR_CVG_ID
,CLARITY_TDL_TRAN.CUR_PLAN_ID 
,CLARITY_TDL_TRAN.CUR_PAYOR_ID 
,CLARITY_TDL_TRAN.CUR_FIN_CLASS
,CLARITY_TDL_TRAN.PERFORMING_PROV_ID 
,CLARITY_TDL_TRAN.BILLING_PROVIDER_ID 
,CLARITY_TDL_TRAN.ORIGINAL_CVG_ID
,CLARITY_TDL_TRAN.ORIGINAL_PLAN_ID  
,CLARITY_TDL_TRAN.ORIGINAL_PAYOR_ID 
,CLARITY_TDL_TRAN.ORIGINAL_FIN_CLASS
,CLARITY_TDL_TRAN.PROC_ID 
,CLARITY_TDL_TRAN.PROCEDURE_QUANTITY 
,CLARITY_TDL_TRAN.CPT_CODE 
,CLARITY_TDL_TRAN.MODIFIER_ONE 
,CLARITY_TDL_TRAN.MODIFIER_TWO 
,CLARITY_TDL_TRAN.MODIFIER_THREE 
,CLARITY_TDL_TRAN.MODIFIER_FOUR 
,CLARITY_TDL_TRAN.DX_ONE_ID 
,CLARITY_TDL_TRAN.DX_TWO_ID 
,CLARITY_TDL_TRAN.DX_THREE_ID 
,CLARITY_TDL_TRAN.DX_FOUR_ID 
,CLARITY_TDL_TRAN.DX_FIVE_ID 
,CLARITY_TDL_TRAN.DX_SIX_ID 
,CLARITY_TDL_TRAN.SERV_AREA_ID 
,CLARITY_TDL_TRAN.LOC_ID 
,CLARITY_TDL_TRAN.DEPT_ID 
,CLARITY_TDL_TRAN.POS_ID 
,CLARITY_TDL_TRAN.INVOICE_NUMBER 
,CLARITY_TDL_TRAN.CLM_CLAIM_ID 
,CLARITY_TDL_TRAN.PAT_AGING_DAYS 
,CLARITY_TDL_TRAN.INS_AGING_DAYS
,CLARITY_TDL_TRAN.ACTION_CVG_ID 
,CLARITY_TDL_TRAN.ACTION_PLAN_ID
,CLARITY_TDL_TRAN.ACTION_PAYOR_ID 
,CLARITY_TDL_TRAN.ACTION_FIN_CLASS
,CLARITY_TDL_TRAN.DEBIT_GL_NUM
,CLARITY_TDL_TRAN.CREDIT_GL_NUM
,CLARITY_TDL_TRAN.REASON_CODE_ID 
,CLARITY_TDL_TRAN.USER_ID
,CLARITY_TDL_TRAN.TX_NUM 
,CLARITY_TDL_TRAN.ORIG_PRICE
,CLARITY_TDL_TRAN.INT_PAT_ID 
,CLARITY_TDL_TRAN.ORIG_AMT
,CLARITY_TDL_TRAN.PRIM_CARE_PROV
,CLARITY_TDL_TRAN.REFERRAL_ID
,CLARITY_TDL_TRAN.REFERRAL_SOURCE_ID
,CLARITY_TDL_TRAN.RVU_WORK
,CLARITY_TDL_TRAN.RVU_OVERHEAD
,CLARITY_TDL_TRAN.RVU_MALPRACTICE
,CLARITY_TDL_TRAN.PAT_ENC_CSN_ID
,CLARITY_TDL_TRAN.MATCH_PAYOR_ID

FROM CLARITY_TDL_TRAN

WHERE
CLARITY_TDL_TRAN.DETAIL_TYPE < 39
AND CLARITY_TDL_TRAN.TRAN_TYPE <=3
AND CLARITY_TDL_TRAN.SERV_AREA_ID in (11,13,16,17,18,19)
AND CLARITY_TDL_TRAN.POST_DATE <= '12/31/2011'


/**********************************************************************************************************
DETAIL TYPE
**********************************************************************************************************/

SELECT 
 DETAIL_TYPE
,TITLE AS 'DETAIL_TYPE_NAME'
FROM ZC_DETAIL_TYPE
WHERE DETAIL_TYPE < 39