declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

select  *,
			   CASE
              WHEN SERV_AREA_ID = 1312 THEN NULL
              WHEN DETAIL_TYPE = 10 AND ORIG_POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
              WHEN DETAIL_TYPE = 1 AND POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
              ELSE SUB_ADJWRVU
       END    AS ADJ_WRVU
	   ,rvu_work + rvu_overhead + rvu_malpractice as TOTAL_RVU
	  ,@start_date as START_DATE
	   ,@end_date as END_DATE
	
from

(

select  
       
	   t.DETAIL_TYPE, 
       t.POST_DATE, 
       t.ORIG_POST_DATE, 
       t.ORIG_SERVICE_DATE, 
	   enc.APPT_TIME,
       t.TX_ID, 
       t.TRAN_TYPE, 
       t.MATCH_TRX_ID, 
       t.ACCOUNT_ID, 
       t.PAT_ID, 
       t.AMOUNT, 
       t.PATIENT_AMOUNT, 
       t.INSURANCE_AMOUNT, 
       t.RELATIVE_VALUE_UNIT, 
       t.CUR_PAYOR_ID, 
       t.CUR_PLAN_ID, 
       t.PROC_ID, 
       t.PERFORMING_PROV_ID, 
	   perf.PROV_ID as PERF_PROV_ID,
	   perf.PROV_NAME as PERF_PROV_NAME,
       t.BILLING_PROVIDER_ID, 
	   bill.PROV_ID as BILL_PROV_ID,
	   bill.PROV_NAME as BILL_PROV_NAME,
       t.ORIGINAL_PAYOR_ID, 
	   orig_epm.PAYOR_ID,
       orig_epm.PAYOR_NAME,
       t.ORIGINAL_PLAN_ID,  
	   t.ORIGINAL_FIN_CLASS,
	   fin.FIN_CLASS_C,
	   fin.name as ORIG_FIN_CLASS_NAME,
       t.PROCEDURE_QUANTITY, 
       t.CPT_CODE, 
	   eap.PROC_NAME,
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
       t.SERV_AREA_ID as SERVICE_AREA_ID, 
	   sa.SERV_AREA_ID,
	   sa.SERV_AREA_NAME,
       t.LOC_ID as LOCATION_ID, 
	   loc.LOC_ID,
	   loc.LOC_NAME,
	   loc.GL_PREFIX as LOC_GL_PREFIX,
       t.DEPT_ID as DEPARTMENT_ID, 
	   dep.DEPARTMENT_ID as DEPT_ID,
	   dep.DEPARTMENT_NAME as DEPT_NAME,
	   dep.SPECIALTY,
	   dep.GL_PREFIX as DEP_GL_PREFIX,
       t.POS_ID as PLACE_OF_SERVICE_ID, 
	   pos.POS_ID,
	   pos.POS_NAME,
	   pos.POS_TYPE,
       t.INVOICE_NUMBER, 
       t.CLM_CLAIM_ID, 
       t.PAT_AGING_DAYS, 
       t.INS_AGING_DAYS, 
       t.ACTION_PAYOR_ID, 
       t.REASON_CODE_ID, 
       LEFT(t.USER_ID,18) as USER_ID, 
       t.TX_NUM, 
       t.INT_PAT_ID, 


	   /*WORK RVU*/
	  CASE
              WHEN t.POST_DATE < '2016-01-01' THEN coalesce(t.RVU_WORK,0) * COALESCE(t.PROCEDURE_QUANTITY,0)                                   
              
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
,case when t.modifier_one is null then 1
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
  (SELECT       a.PROC_ID, 
                    a.RVU_PER_MOD,
                     a.CONTACT_DATE AS BEGIN_CONTACT_DATE,
                     CASE WHEN LEAD(a.CONTACT_DATE) OVER (PARTITION BY a.PROC_ID, a.RVU_PER_MOD ORDER BY a.PROC_ID, a.RVU_PER_MOD,a.CONTACT_DATE, A.CONTACT_DATE_REAL) IS NOT NULL THEN
                           LEAD(a.CONTACT_DATE) OVER (PARTITION BY a.PROC_ID, a.RVU_PER_MOD ORDER BY a.PROC_ID, a.RVU_PER_MOD, a.CONTACT_DATE, A.CONTACT_DATE_REAL)
                           ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
                     END AS END_CONTACT_DATE,
                     a.RVU_PER_MOD_WORK
       FROM (SELECT DISTINCT ERPM.PROC_ID, ERPM.RVU_PER_MOD,ERPM.CONTACT_DATE_REAL, ERPM.CONTACT_DATE, ERPM.RVU_PER_MOD_WORK FROM CLARITY.dbo.EAP_RVU_PER_MOD ERPM where rvu_per_mod = '26') a)) mod26 
			         where begin_contact_date <> end_contact_date) mod26 ON mod26.PROC_ID = t.PROC_ID AND mod26.RVU_PER_MOD = '26' AND t.ORIG_POST_DATE >= mod26.BEGIN_CONTACT_DATE AND t.ORIG_POST_DATE < mod26.END_CONTACT_DATE

LEFT OUTER JOIN 
(select *
from 
(
  (SELECT       B.PROC_ID, 
                    B.RVU_PER_MOD,
                     B.CONTACT_DATE AS BEGIN_CONTACT_DATE,
                     CASE WHEN LEAD(B.CONTACT_DATE) OVER (PARTITION BY B.PROC_ID, B.RVU_PER_MOD ORDER BY B.PROC_ID, B.RVU_PER_MOD,B.CONTACT_DATE, B.CONTACT_DATE_REAL) IS NOT NULL THEN
                           LEAD(B.CONTACT_DATE) OVER (PARTITION BY B.PROC_ID, B.RVU_PER_MOD ORDER BY B.PROC_ID, B.RVU_PER_MOD, B.CONTACT_DATE, B.CONTACT_DATE_REAL)
                           ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
                     END AS END_CONTACT_DATE,
                     B.RVU_PER_MOD_WORK
       FROM (SELECT DISTINCT ERPM.PROC_ID, ERPM.RVU_PER_MOD, ERPM.CONTACT_DATE_REAL, ERPM.CONTACT_DATE, ERPM.RVU_PER_MOD_WORK FROM CLARITY.dbo.EAP_RVU_PER_MOD ERPM where rvu_per_mod = 'TC') b)) modtc 
				    where begin_contact_date <> end_contact_date) modtc ON modtc.PROC_ID = t.PROC_ID AND modtc.RVU_PER_MOD = 'TC' AND t.ORIG_POST_DATE >= modtc.BEGIN_CONTACT_DATE AND t.ORIG_POST_DATE < modtc.END_CONTACT_DATE

LEFT OUTER JOIN 
(select *
from 
(
(SELECT        c.PROC_ID, 
					c.contact_date_real,
                     c.CONTACT_DATE AS BEGIN_CONTACT_DATE,
                     CASE WHEN LEAD(c.CONTACT_DATE) OVER (PARTITION BY c.PROC_ID ORDER BY c.PROC_ID, c.CONTACT_DATE, C.CONTACT_DATE_REAL) IS NOT NULL THEN
                           LEAD(c.CONTACT_DATE) OVER (PARTITION BY c.PROC_ID ORDER BY c.PROC_ID, c.CONTACT_DATE, C.CONTACT_DATE_REAL)
                           ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
                     END AS END_CONTACT_DATE,
                     c.RVU_WORK_COMPON
       FROM (SELECT DISTINCT CEO.PROC_ID, CEO.CONTACT_DATE_REAL, CEO.CONTACT_DATE, CEO.RVU_WORK_COMPON FROM Clarity.dbo.CLARITY_EAP_OT CEO) c))ot
					where begin_contact_date <> end_contact_date) ot ON ot.PROC_ID = t.PROC_ID AND t.POST_DATE >= ot.BEGIN_CONTACT_DATE AND t.POST_DATE < ot.END_CONTACT_DATE

LEFT OUTER JOIN CLARITY.dbo.CLARITY_SA sa on t.serv_area_id = sa.serv_area_id
LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC loc on t.loc_id = loc.loc_id
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep on t.dept_id = dep.DEPARTMENT_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER bill on t.billing_provider_id = bill.prov_id
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER perf on t.performing_prov_id = perf.prov_id
LEFT OUTER JOIN CLARITY.dbo.ZC_FIN_CLASS fin on t.original_fin_class = fin.fin_class_c
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EAP eap on t.proc_id = eap.proc_id
LEFT OUTER JOIN CLARITY.dbo.PAT_ENC enc on t.pat_enc_csn_id = enc.pat_enc_csn_id
LEFT OUTER JOIN CLARITY.dbo.CLARITY_POS pos on t.pos_id = pos.pos_id
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EPM orig_epm on t.original_payor_id = orig_epm.payor_id

where post_date >= @start_date
and post_date <= @end_date
and cast(t.serv_area_id as nvarchar(20)) in ({?Service Area})
and detail_type in (1,10,20,21)
)trans