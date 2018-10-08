SELECT
*
,CASE WHEN SERV_AREA_ID NOT IN (11,13,16,17,18,19,21) THEN NULL
      WHEN DETAIL_TYPE = 10 AND ORIG_POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
      WHEN DETAIL_TYPE = 1 AND POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
      ELSE SUB_ADJWRVU
      END AS 'Adjusted wRVU'
,RVU_WORK + RVU_OVERHEAD + RVU_MALPRACTICE as 'Total RVU'
 
FROM

(

SELECT

/*CHARGES*/
 CASE WHEN t.DETAIL_TYPE IN (1) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END AS 'CHARGE AMOUNT'  
,case when t.detail_type in (1,10) and month(t.post_date) = month(t.orig_service_date) then t.amount else 0 end as 'CURRENT CHARGE AMOUNT'  
,(CASE WHEN t.DETAIL_TYPE IN (1,10) THEN t.AMOUNT ELSE 0 END) - (case when t.detail_type in (1,10) and month(t.post_date) = month(t.orig_service_date) then t.amount else 0 end)  as 'LATE CHARGE AMOUNT'  
,CASE WHEN t.DETAIL_TYPE IN (10) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'VOID AMOUNT'
,CASE WHEN t.DETAIL_TYPE IN (1,10) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'NET CHARGE AMOUNT'
,case when detail_type in (1,10) then t.PROCEDURE_QUANTITY else 0 end as 'CHARGE COUNT'

/*PAYMENTS*/
,CASE WHEN t.DETAIL_TYPE IN (2,5,11,20,22,32,33) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'PAYMENT AMOUNT'
,CASE WHEN t.DETAIL_TYPE IN (5,20,22) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'MATCHED PAYMENT AMOUNT'
,CASE WHEN t.DETAIL_TYPE IN (2,11,32,33) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'UNDISTRIBUTED PAYMENT AMOUNT'
,case when t.detail_type in (2,5,11,20,22,32,33) then t.patient_amount else 0 end as 'PATIENT PAYMENTS'
,case when t.detail_type in (2,5,11,20,22,32,33) then t.insurance_amount else 0 end as 'INSURANCE PAYMENTS'

/*ADJUSTMENTS*/
,CASE WHEN t.DETAIL_TYPE IN (3,4,6,12,13,21,23,30,31) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'ADJUSTMENT AMOUNT'
,CASE WHEN t.DETAIL_TYPE IN (4,13,30,31) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'UNDIST ADJUSTMENT AMT'

/*CREDIT ADJUSTMENTS*/
,case when t.detail_type in (4,6,13,21,23,30,31) then t.active_ar_amount else 0 end as 'CREDIT ADJUSTMENT AMOUNT'
,CASE WHEN t.DETAIL_TYPE IN (6,21,23) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'MATCHED CREDIT ADJUSTMENT AMOUNT'
,case when t.detail_type in (21,23) and eap_match.gl_num_debit = 'Admin' then t.amount
      when t.detail_type in (4,13,30,31) and eap.gl_num_debit = 'Admin' then t.amount
	  when t.detail_type in (6) and eap.gl_num_credit = 'Admin' then t.amount
	  else 0 end as 'CREDIT ADJUSTMENT - ADMIN'        
,case when t.detail_type in (21,23) and eap_match.gl_num_debit = 'CHARITY' then t.amount
      when t.detail_type in (4,13,30,31) and eap.gl_num_debit = 'CHARITY' then t.amount
	  when t.detail_type in (6) and eap.gl_num_credit = 'CHARITY' then t.amount
	  else 0 end as  'CREDIT ADJUSTMENT - CHARITY'      
,case when t.detail_type in (21,23) and eap_match.gl_num_debit = 'CONTRA' then t.amount
      when t.detail_type in (4,13,30,31) and eap.gl_num_debit = 'CONTRA' then t.amount
	  when t.detail_type in (6) and eap.gl_num_credit = 'CONTRA' then t.amount
	  else 0 end as 'CREDIT ADJUSTMENT - CONTRACTUALS'    
,case when t.detail_type in (21,23) and eap_match.gl_num_debit = 'BAD' then t.amount
      when t.detail_type in (4,13,30,31) and eap.gl_num_debit = 'BAD' then t.amount
	  when t.detail_type in (4,21) and eap_match.gl_num_debit = 'BAD DEBT RECOVERY' then t.amount
	  when t.detail_type in (6) and eap.gl_num_credit = 'BADRECOVERY' then t.amount
	  else 0 end  as 'CREDIT ADJUSTMENT - BAD DEBT'
,case when t.detail_type in (21,23) and (eap_match.gl_num_debit is null or eap_match.gl_num_debit not in ('CONTRA','CHARITY','ADMIN','BADRECOVERY','BAD') and eap.gl_num_debit not in ('BAD DEBT RECOVERY')) then t.amount
	  when t.detail_type in (4,13,30,31) and (eap.gl_num_debit is null or eap.gl_num_debit not in ('CONTRA','CHARITY','ADMIN','BAD DEBT RECOVERY','BADRECOVERY','BAD')) then t.amount
	  when t.detail_type in (6) and (eap.gl_num_credit is null or eap.gl_num_credit not in ('CONTRA','CHARITY','ADMIN','BAD DEBT RECOVERY','BADRECOVERY','BAD')) then t.amount
	  else 0 end as 'CREDIT ADJUSTMENT - OTHER'

/*DEBIT ADJUSTMENTS*/
,CASE WHEN t.DETAIL_TYPE IN (3,12) THEN t.ACTIVE_AR_AMOUNT ELSE 0 END as 'DEBIT ADJUSTMENT AMOUNT'
,case when t.detail_type in (3,12) and t.credit_gl_num = 'REFUND' then t.amount else 0 end as 'DEBIT ADJUSTMENT - REFUND'          
,case when t.detail_type in (3,12) and (eap.gl_num_debit is null or eap.gl_num_credit <> 'REFUND') then t.amount else 0 end as 'DEBIT ADJUSTMENT - OTHER'

/*NET CHANGE IN AR*/
,case when t.amount is null then 0 
	  when detail_type in (1,10,11,12,13,2,20,21,22,23,3,30,31,32,33,4,5,6) then t.amount end as 'NET CHANGE AR'

/*TRANSACTION TYPE*/
,case when t.detail_type in (3,5,6,12) then 'Debit' when t.detail_type in (2,4,11,13) then 'Credit' else 'Other' end as 'Tran_Type'

/*POSTING TYPE*/
,case when t.detail_type in (2,3,4) then 'Posted' when t.detail_type in (11,12,13) then 'Void' when t.detail_type in (5,6) then 'Reversal' else 'Other' end as 'Posting_Type'

,case when t.detail_type = 5 then 'Debit' else 'Credit' end as 'Debit/Credit'

,t.detail_type,
t.POST_DATE, 
t.ORIG_POST_DATE, 
t.ORIG_SERVICE_DATE, 
t.TX_ID, 
t.MATCH_TRX_ID, 
t.ACCOUNT_ID, 
t.PAT_ID, 
t.AMOUNT, 
t.PATIENT_AMOUNT, 
t.INSURANCE_AMOUNT, 
t.RELATIVE_VALUE_UNIT, 
t.CUR_PAYOR_ID, 
t.CUR_PLAN_ID, 
t.performing_prov_id,
t.billing_provider_id ,
t.ORIGINAL_PAYOR_ID, 
t.ORIGINAL_PLAN_ID,  
t.ORIGINAL_FIN_CLASS,
t.PROCEDURE_QUANTITY, 
t.proc_id,
t.MODIFIER_ONE, 
t.MODIFIER_TWO, 
t.MODIFIER_THREE, 
t.MODIFIER_FOUR, 
t.DX_ONE_ID, 
t.DX_TWO_ID, 
t.DX_THREE_ID, 
t.DX_FOUR_ID, 
t.DX_FIVE_ID, 
t.DX_SIX_ID, 
t.serv_area_id,
t.loc_id,
t.dept_id,
t.POS_ID, 
t.INVOICE_NUMBER, 
t.CLM_CLAIM_ID, 
t.PAT_AGING_DAYS, 
t.INS_AGING_DAYS, 
t.ACTION_PAYOR_ID, 
t.REASON_CODE_ID, 
t.USER_ID, 
t.TX_NUM, 
t.INT_PAT_ID, 
t.WORKSTATION_ID,
CLARITY_LWS.WORKSTATION_NAME,
CASHDWR_INFO.CDW_ID,
CASHDWR_INFO.CDW_NAME,
ARPB_TX_MODERATE.RECONCILIATION_NUM,
t.POSTING_BATCH_NUM,
t.ORIG_REF_NUM,
ACCOUNT.ACCOUNT_NAME,

/*WORK RVU*/
CASE WHEN t.POST_DATE < '2016-01-01' THEN coalesce(t.RVU_WORK,0) * COALESCE(t.PROCEDURE_QUANTITY,0)
     WHEN t.MODIFIER_ONE = '26' OR t.MODIFIER_TWO = '26' OR t.MODIFIER_THREE = '26' OR t.MODIFIER_FOUR = '26' THEN COALESCE(mod26.RVU_PER_MOD_WORK, ot.RVU_WORK_COMPON, 0.00) * COALESCE(t.PROCEDURE_QUANTITY,0)
     WHEN t.MODIFIER_ONE = 'TC' OR t.MODIFIER_TWO = 'TC' OR t.MODIFIER_THREE = 'TC' OR t.MODIFIER_FOUR = 'TC' THEN COALESCE(modtc.RVU_PER_MOD_WORK, ot.RVU_WORK_COMPON, 0.00) * COALESCE(t.PROCEDURE_QUANTITY,0)
  WHEN COALESCE(ot.RVU_WORK_COMPON,0) > 0 then COALESCE(ot.RVU_WORK_COMPON,0) * COALESCE(t.PROCEDURE_QUANTITY,0)
     ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
     END AS RVU_WORK,
coalesce(t.RVU_OVERHEAD,0) * procedure_quantity as rvu_overhead,
coalesce(t.RVU_MALPRACTICE,0) * procedure_quantity as rvu_malpractice,
t.RVU_PROC_UNITS,
t.REFERRAL_SOURCE_ID, 
t.REFERRAL_ID, 
t.MATCH_PAYOR_ID, 
t.VISIT_NUMBER, 
t.CHARGE_SLIP_NUMBER, 

/*Adjusted Work RVU*/
/* ONLY CONSIDER CHARGES (1) AND VOIDED CHARGES (10) FOR ADJUSTED WRVU (SUB_RVU) */
CASE t.DETAIL_TYPE

/* 1 = CHARGES */
WHEN 1 THEN   
CASE 
      /* PRE 4/1/2014 FORMULA.  BASICALLY SAME AS POST 4/1/2014 EXCEPT FEWER CPT CODE EXCEPTIONS. */
      WHEN t.POST_DATE < '2014-04-01' THEN
      CASE 
      WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474') OR t.CPT_CODE IS NULL) THEN 
      CASE 
      WHEN COALESCE(t.RVU_WORK,0) > 0 THEN t.RVU_WORK * COALESCE(t.PROCEDURE_QUANTITY,0)
      ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
      END
      ELSE 0
      END

      /* USE POST 4/1/2014 FORMULA WHEN POST_DATE > 3/31/14 AND LESS THAN 2016. */
      WHEN t.POST_DATE >= '2014-04-01' AND t.POST_DATE < '2016-01-01' THEN
      CASE 
      WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR t.CPT_CODE IS NULL) THEN 
      CASE 
      WHEN COALESCE(t.RVU_WORK,0) > 0 THEN t.RVU_WORK * COALESCE(t.PROCEDURE_QUANTITY,0)
      ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
      END
      ELSE 0
      END 

      /*  NOTE:  For 1/1/2016 and beyond, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
      final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
      */
      ELSE
      CASE 
      WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR t.CPT_CODE IS NULL) THEN 
      CASE
      WHEN COALESCE(t.RVU_WORK,0) > 0 THEN COALESCE(t.RVU_WORK,0) * COALESCE(t.PROCEDURE_QUANTITY,0)
      ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
      END
      ELSE 0
      END
      END 

/* 10 = VOIDED CHARGES */
WHEN 10 THEN  
CASE 
      /* PRE 4/1/2014 FORMULA.  BASICALLY SAME AS POST 4/1/2014 EXCEPT FEWER CPT CODE EXCEPTIONS. */
      WHEN t.ORIG_POST_DATE < '2014-04-01' THEN
      CASE 
      WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474') OR t.CPT_CODE IS NULL) THEN 
      CASE 
      WHEN COALESCE(t.RVU_WORK,0) > 0 THEN t.RVU_WORK * COALESCE(t.PROCEDURE_QUANTITY,0)
      ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
      END
      ELSE 0
      END

      /* USE ORIGINAL POST 4/1/2014 FORMULA WHEN ORIG_POST_DATE > 3/31/14 AND LESS THAN 2016. */
      WHEN t.ORIG_POST_DATE >= '2014-04-01' AND t.ORIG_POST_DATE < '2016-01-01' THEN
      CASE 
      WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR t.CPT_CODE IS NULL) THEN 
      CASE 
      WHEN COALESCE(t.RVU_WORK,0) > 0 THEN t.RVU_WORK * COALESCE(t.PROCEDURE_QUANTITY,0)
      ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
      END
      ELSE 0
      END 

      /*  NOTE:  For 1/1/2016 and beyond, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
      final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
*/
      ELSE
      CASE 
      WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR t.CPT_CODE IS NULL) THEN 
      CASE 
      WHEN COALESCE(t.RVU_WORK,0) > 0 THEN COALESCE(t.RVU_WORK,0) * COALESCE(t.PROCEDURE_QUANTITY,0)
      ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
      END
      ELSE 0
      END
      END 

/* DETAIL_TYPE not equal to 1 or 10 */
ELSE 0

END AS SUB_ADJWRVU


,case when t.modifier_one is null then 1
 when t.modifier_one = 'TC' then 0
 when t.modifier_one = '56' then .11
 when t.modifier_one = 'AS' then .16
 when t.modifier_one = '82' then .16
 when t.modifier_one= '81' then .16
 when t.modifier_one = '80' then .16
 when t.modifier_one = '55' then .20
 when t.modifier_one = '50' then 1.50
 when t.modifier_one = '51' then .50
 when t.modifier_one = '52' then .50
 when t.modifier_one = '53' then .50
 when t.modifier_one = '74' then .50
 when t.modifier_one = '62' then .625
 when t.modifier_one = '54' then .70
 when t.modifier_one = '22' then 1.25
 when t.modifier_one = '76' then .7
 when t.modifier_one = '78' then .7
 else 1 end as MOD_PCT1
,case when t.modifier_two is null then 1
 when t.modifier_two  = 'TC' then 0
 when t.modifier_two  = '56' then .11
 when t.modifier_two  = 'AS' then .16
 when t.modifier_two  = '82' then .16
 when t.modifier_two = '81' then .16
 when t.modifier_two = '80' then .16
 when t.modifier_two  = '55' then .20
 when t.modifier_two  = '50' then 1.50
 when t.modifier_two  = '51' then .50
 when t.modifier_two  = '52' then .50
 when t.modifier_two  = '53' then .50
 when t.modifier_two  = '74' then .50
 when t.modifier_two  = '62' then .625
 when t.modifier_two  = '54' then .70
 when t.modifier_two = '22' then 1.25
 when t.modifier_two = '76' then .7
 when t.modifier_two = '78' then .7
 else 1 end as MOD_PCT2
,case when t.modifier_three is null then 1
 when t.modifier_three = 'TC' then 0
 when t.modifier_three= '56' then .11
 when t.modifier_three = 'AS' then .16
 when t.modifier_three = '82' then .16
 when t.modifier_three = '81' then .16
 when t.modifier_three = '80' then .16
 when t.modifier_three = '55' then .20
 when t.modifier_three = '50' then 1.50
 when t.modifier_three = '51' then .50
 when t.modifier_three = '52' then .50
 when t.modifier_three = '53' then .50
 when t.modifier_three = '74' then .50
 when t.modifier_three = '62' then .625
 when t.modifier_three = '54' then .70
 when t.modifier_three = '22' then 1.25
 when t.modifier_three = '76' then .7
 when t.modifier_three = '78' then .7
 else 1 end as MOD_PCT3
,case when t.modifier_four is null then 1
 when t.modifier_four = 'TC' then 0
 when t.modifier_four = '56' then .11
 when t.modifier_four = 'AS' then .16
 when t.modifier_four = '82' then .16
 when t.modifier_four = '81' then .16
 when t.modifier_four = '80' then .16
 when t.modifier_four = '55' then .20
 when t.modifier_four = '50' then 1.50
 when t.modifier_four = '51' then .50
 when t.modifier_four = '52' then .50
 when t.modifier_four = '53' then .50
 when t.modifier_four = '74' then .50
 when t.modifier_four = '62' then .625
 when t.modifier_four = '54' then .70
 when t.modifier_four = '22' then 1.25
 when t.modifier_four = '76' then .7
 when t.modifier_four = '78' then .7
 else 1 end as MOD_PCT4
 
from CLARITY.dbo.clarity_tdl_tran t
LEFT OUTER JOIN 
(select *
from 
(
  (SELECT a.PROC_ID, 
      a.RVU_PER_MOD,
a.CONTACT_DATE AS BEGIN_CONTACT_DATE,
CASE WHEN LEAD(a.CONTACT_DATE) OVER (PARTITION BY a.PROC_ID, a.RVU_PER_MOD ORDER BY a.PROC_ID, a.RVU_PER_MOD,a.CONTACT_DATE) IS NOT NULL THEN
      LEAD(a.CONTACT_DATE) OVER (PARTITION BY a.PROC_ID, a.RVU_PER_MOD ORDER BY a.PROC_ID, a.RVU_PER_MOD, a.CONTACT_DATE)
      ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
END AS END_CONTACT_DATE,
a.RVU_PER_MOD_WORK
FROM (SELECT DISTINCT ERPM.PROC_ID, ERPM.RVU_PER_MOD, ERPM.CONTACT_DATE, ERPM.RVU_PER_MOD_WORK FROM CLARITY.dbo.EAP_RVU_PER_MOD ERPM where rvu_per_mod = '26') a)) mod26 
     where begin_contact_date <> end_contact_date) mod26 ON mod26.PROC_ID = t.PROC_ID AND mod26.RVU_PER_MOD = '26' AND t.ORIG_POST_DATE >= mod26.BEGIN_CONTACT_DATE AND t.ORIG_POST_DATE < mod26.END_CONTACT_DATE

LEFT OUTER JOIN 
(select *
from 
(
  (SELECT B.PROC_ID, 
      B.RVU_PER_MOD,
B.CONTACT_DATE AS BEGIN_CONTACT_DATE,
CASE WHEN LEAD(B.CONTACT_DATE) OVER (PARTITION BY B.PROC_ID, B.RVU_PER_MOD ORDER BY B.PROC_ID, B.RVU_PER_MOD,B.CONTACT_DATE) IS NOT NULL THEN
      LEAD(B.CONTACT_DATE) OVER (PARTITION BY B.PROC_ID, B.RVU_PER_MOD ORDER BY B.PROC_ID, B.RVU_PER_MOD, B.CONTACT_DATE)
      ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
END AS END_CONTACT_DATE,
B.RVU_PER_MOD_WORK
FROM (SELECT DISTINCT ERPM.PROC_ID, ERPM.RVU_PER_MOD, ERPM.CONTACT_DATE, ERPM.RVU_PER_MOD_WORK FROM CLARITY.dbo.EAP_RVU_PER_MOD ERPM where rvu_per_mod = 'TC') b)) modtc 
        where begin_contact_date <> end_contact_date) modtc ON modtc.PROC_ID = t.PROC_ID AND modtc.RVU_PER_MOD = 'TC' AND t.ORIG_POST_DATE >= modtc.BEGIN_CONTACT_DATE AND t.ORIG_POST_DATE < modtc.END_CONTACT_DATE

LEFT OUTER JOIN 
(select *
from 
(
(SELECT c.PROC_ID, 
     c.contact_date_real,
c.CONTACT_DATE AS BEGIN_CONTACT_DATE,
CASE WHEN LEAD(c.CONTACT_DATE) OVER (PARTITION BY c.PROC_ID ORDER BY c.PROC_ID, c.CONTACT_DATE) IS NOT NULL THEN
      LEAD(c.CONTACT_DATE) OVER (PARTITION BY c.PROC_ID ORDER BY c.PROC_ID, c.CONTACT_DATE)
      ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
END AS END_CONTACT_DATE,
c.RVU_WORK_COMPON
FROM (SELECT DISTINCT CEO.PROC_ID, contact_date_real, CEO.CONTACT_DATE, CEO.RVU_WORK_COMPON FROM Clarity.dbo.CLARITY_EAP_OT CEO) c))ot
     where begin_contact_date <> end_contact_date) ot ON ot.PROC_ID = t.PROC_ID AND t.POST_DATE >= ot.BEGIN_CONTACT_DATE AND t.POST_DATE < ot.END_CONTACT_DATE

LEFT JOIN CLARITY_EAP eap_match on eap_match.proc_id = t.match_proc_id
LEFT JOIN CLARITY_EAP eap on eap.proc_id = t.proc_id
LEFT JOIN CLARITY_LWS on CLARITY_LWS.WORKSTATION_ID = t.WORKSTATION_ID
LEFT JOIN CASHDWR_DEPOSIT_TXS on CASHDWR_DEPOSIT_TXS.TRANSACTION_ID = t.TX_ID
LEFT JOIN CASHDWR_INFO on CASHDWR_INFO.CDW_ID = CASHDWR_DEPOSIT_TXS.CDW_ID
LEFT JOIN ARPB_TX_MODERATE on ARPB_TX_MODERATE.TX_ID = t.TX_ID
LEFT JOIN ACCOUNT on ACCOUNT.ACCOUNT_ID = t.ACCOUNT_ID

where t.post_date >= '1/1/2011'
and t.post_date <= '1/2/2011'
and t.detail_type <39
and tran_type <=3
)trans