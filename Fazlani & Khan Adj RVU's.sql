select PERF_PROV_ID as 'Provider ID',
	   PERF_PROV_NAME as 'Provider Name',
	   cpt_code as 'CPT',
	   coalesce(MODIFIER_ONE,'') as 'CPT Modifier 1', 
	   proc_name as 'Procedure Description',
	   year_month_str as 'Month of Transaction',
	   PROCEDURE_QUANTITY as 'Provider - Performing Units', 

			   CASE
              WHEN SERV_AREA_ID = 1312 THEN NULL
              WHEN DETAIL_TYPE = 10 AND ORIG_POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
              WHEN DETAIL_TYPE = 1 AND POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
              ELSE SUB_ADJWRVU
       END    AS 'Adj Work RVU',
	   detail_type as 'Detail Type'
	   ,tx_id as 'Transaction ID'
	   ,amount as 'Charge Amount'
	   ,orig_service_date as 'Original Service Date'
	   ,post_date as 'Post Date'

from

(

select  
       
	   t.DETAIL_TYPE, 
       t.POST_DATE, 
       t.PERFORMING_PROV_ID, 
	   perf.PROV_ID as PERF_PROV_ID,
	   perf.PROV_NAME as PERF_PROV_NAME,
       t.PROCEDURE_QUANTITY, 
       t.CPT_CODE, 
       t.MODIFIER_ONE, 
	   t.serv_area_id,
	   t.orig_post_date,
	   date.year_month_str,
	   eap.proc_name,
	   t.tx_id,
	   t.amount,
	   t.orig_service_date,

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


LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER perf on t.performing_prov_id = perf.prov_id
left join date_dimension date on date.calendar_dt = t.post_date
left join clarity_eap eap on eap.proc_id = t.proc_id

where 
detail_type in (1,10)
and perf.prov_id in ('1003206', '1000064')
)trans

order by tx_id