--declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

declare @start_date as date = EPIC_UTIL.EFN_DIN('4/19/2017')
declare @end_date as date = EPIC_UTIL.EFN_DIN('4/26/2017')

select  *,
			   CASE
              WHEN SERV_AREA_ID = 1312 THEN NULL
              WHEN DETAIL_TYPE = 10 AND ORIG_POST_DATE < '2016-01-01' THEN SUB_ADJWRVU  * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
              WHEN DETAIL_TYPE = 1 AND POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
              ELSE SUB_ADJWRVU
       END    AS ADJ_WRVU
	   ,rvu_work + rvu_overhead + rvu_malpractice as TOTAL_RVU
	
from

(

Select distinct 

 convert(varchar(18),pt.PAT_MRN_ID) as Medical_Record_Number
,ctt.tx_id as Encounter_Record_Number
,case when loc.gl_prefix = '6010' and dep.gl_prefix = '800000' then '6051'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '405000' then '6710'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '410365' then '6760'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '440000' then '6770'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '468000' then '6760'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '471351' then '6770'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '430370' then '6752'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '642000' then '6770'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '792396' then '6760'
 	  when loc.gl_prefix = '6749' and dep.gl_prefix = '427351' then '6734'
	  when loc.gl_prefix = '6734' and dep.department_id = '18105107' then '6770'
	  when loc.gl_prefix = '6734' and dep.department_id = '18101151' then '6760'
	  when loc.gl_prefix = '6734' and dep.department_id = '18103116' then '6710'
	  when loc.gl_prefix = '6734' and dep.department_id = '18102102' then '6740'
	  else cast(loc.gl_prefix as varchar) end as Entity_Code
,convert(varchar(8),ctt.LOC_ID) as Location_ID
,case when dep.department_id = '18101257' and ctt.billing_provider_id = '1733188' then '793387'
      when dep.department_id = '19390163' and ctt.billing_provider_id = '1733188' then '793387'
	  when loc.gl_prefix = '6321' and (credit_gl_num in ('Admin', 'Contra', 'Bad', 'BadRecovery', 'Charity', 'Legacy Recovery', 'Legacy Contractual') 
		   or debit_gl_num in ('Admin', 'Contra', 'Bad', 'BadRecovery', 'Charity', 'Legacy Recovery', 'Legacy Contractual')) then '848000' 
	  else cast(dep.gl_prefix as varchar) end as Department_Code
,convert(varchar(18),dep.gl_prefix) as Charge_Department --CLARITY_DEP
,eap.proc_code as Charge_Code
,ctt.CPT_CODE as Billed_CPT_Code
,coalesce(ctt.MODIFIER_ONE,'') as Charge_Modifer_Code_One
,coalesce(ctt.MODIFIER_TWO,'') as Charge_Modifer_Code_Two
,coalesce(ctt.MODIFIER_THREE,'') as Charge_Modifer_Code_Three
,coalesce(ctt.MODIFIER_FOUR,'') as Charge_Modifer_Code_Four
,ctt.PROCEDURE_QUANTITY as PROCEDURE_QUANTITY
,ctt.AMOUNT as Charge_Amount
,cast(ctt.CPT_CODE as varchar) + '-' + cast(ser.provider_type_c as varchar) + '-' + case when pos.pos_type_c = 11 then '1' else '0' end + '-' + coalesce(cast(ctt.MODIFIER_ONE as varchar),'xx') + '-' + coalesce(cast(ctt.MODIFIER_TWO as varchar),'xx') + '-' + coalesce(cast(ctt.MODIFIER_THREE as varchar),'xx') + '-' + coalesce(cast(ctt.MODIFIER_FOUR as varchar),'xx') as Activity_code
,ctt.BILLING_PROVIDER_ID as Order_Physician_Code
,ctt.PERFORMING_PROV_ID as Performing_Physician_Code
,CONVERT(VARCHAR(10), ctt.ORIG_SERVICE_DATE, 112) as Service_Date
,CONVERT(VARCHAR(10), ctt.POST_DATE, 112) as Post_Date
,ser.prov_type as Provider_Type
,(coalesce(ctt.RVU_MALPRACTICE,0) * procedure_quantity) as RVU_MALPRACTICE
,(coalesce(ctt.RVU_OVERHEAD,0) * procedure_quantity) as RVU_OVERHEAD
,CASE
              WHEN ctt.POST_DATE < '2016-01-01' THEN (coalesce(ctt.RVU_WORK,0) * COALESCE(ctt.PROCEDURE_QUANTITY,0))                                 
			  WHEN ctt.MODIFIER_ONE = '26' OR ctt.MODIFIER_TWO = '26' OR ctt.MODIFIER_THREE = '26' OR ctt.MODIFIER_FOUR = '26' THEN (COALESCE(mod26.RVU_PER_MOD_WORK, ot.RVU_WORK_COMPON, 0.00) * COALESCE(ctt.PROCEDURE_QUANTITY,0))
              WHEN ctt.MODIFIER_ONE = 'TC' OR ctt.MODIFIER_TWO = 'TC' OR ctt.MODIFIER_THREE = 'TC' OR ctt.MODIFIER_FOUR = 'TC' THEN (COALESCE(modtc.RVU_PER_MOD_WORK, ot.RVU_WORK_COMPON, 0.00) * COALESCE(ctt.PROCEDURE_QUANTITY,0))
			  WHEN COALESCE(ot.RVU_WORK_COMPON,0) > 0 then (COALESCE(ot.RVU_WORK_COMPON,0) * COALESCE(ctt.PROCEDURE_QUANTITY,0))
			  ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
       END AS RVU_WORK
--Adjusted Work RVU
/*Adjusted Work RVU*/
/* ONLY CONSIDER CHARGES (1) AND VOIDED CHARGES (10) FOR ADJUSTED WRVU (SUB_RVU) */
       ,CASE ctt.DETAIL_TYPE

              /* 1 = CHARGES */
              WHEN 1 THEN          

                     CASE 
                           /* PRE 4/1/2014 FORMULA.  BASICALLY SAME AS POST 4/1/2014 EXCEPT FEWER CPT CODE EXCEPTIONS. */
                           WHEN ctt.POST_DATE < '2014-04-01' THEN
                                  CASE 
                                         WHEN (ctt.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474') OR ctt.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(ctt.RVU_WORK,0) > 0 THEN (ctt.RVU_WORK * COALESCE(ctt.PROCEDURE_QUANTITY,0))
                                                       ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END

                           /* USE POST 4/1/2014 FORMULA WHEN POST_DATE > 3/31/14 AND LESS THAN 2016. */
                           WHEN ctt.POST_DATE >= '2014-04-01' AND ctt.POST_DATE < '2016-01-01' THEN
                                  CASE 
                                         WHEN (ctt.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR ctt.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(ctt.RVU_WORK,0) > 0 THEN (ctt.RVU_WORK * COALESCE(ctt.PROCEDURE_QUANTITY,0))
                                                       ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END 

                           /*  NOTE:  For 1/1/2016 and beyond, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
                                  final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
                           */
                           ELSE
                                  CASE 
                                         WHEN (ctt.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR ctt.CPT_CODE IS NULL) THEN 
                                                CASE
                                                       WHEN COALESCE(ctt.RVU_WORK,0) > 0 THEN (COALESCE(ctt.RVU_WORK,0) * COALESCE(ctt.PROCEDURE_QUANTITY,0))
                                                       ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END
                           END 

              /* 10 = VOIDED CHARGES */
              WHEN 10 THEN  
                     CASE 
                           /* PRE 4/1/2014 FORMULA.  BASICALLY SAME AS POST 4/1/2014 EXCEPT FEWER CPT CODE EXCEPTIONS. */
                           WHEN ctt.ORIG_POST_DATE < '2014-04-01' THEN
                                  CASE 
                                         WHEN (ctt.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474') OR ctt.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(ctt.RVU_WORK,0) > 0 THEN (ctt.RVU_WORK * COALESCE(ctt.PROCEDURE_QUANTITY,0))
                                                       ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END

                           /* USE ORIGINAL POST 4/1/2014 FORMULA WHEN ORIG_POST_DATE > 3/31/14 AND LESS THAN 2016. */
                           WHEN ctt.ORIG_POST_DATE >= '2014-04-01' AND ctt.ORIG_POST_DATE < '2016-01-01' THEN
                                  CASE 
                                         WHEN (ctt.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR ctt.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(ctt.RVU_WORK,0) > 0 THEN (ctt.RVU_WORK * COALESCE(ctt.PROCEDURE_QUANTITY,0))
                                                       ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END 

                           /*  NOTE:  For 1/1/2016 and beyond, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
                                  final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
                            */
                           ELSE
                                  CASE 
                                         WHEN (ctt.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR ctt.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(ctt.RVU_WORK,0) > 0 THEN (COALESCE(ctt.RVU_WORK,0) * COALESCE(ctt.PROCEDURE_QUANTITY,0))
                                                       ELSE COALESCE(ctt.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END
                           END 

              /* DETAIL_TYPE not equal to 1 or 10 */
              ELSE 0

              END AS SUB_ADJWRVU

,convert(varchar(18),ctt.account_id) as Guarantor_Account_ID 
,ctt.POS_ID as Place_of_Service
,ctt.original_payor_id as Original_Payor
,ctt.cur_payor_id as Current_Payor
--Charge ICD10 DX 1
    ,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_one_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '2' --2	ICD-10-CM
	  ) as Charge_ICD10_DX_1
--Charge ICD10 DX 2
    ,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_two_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '2' --2	ICD-10-CM
	  ) as Charge_ICD10_DX_2
--Charge ICD10 DX 3
    ,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_three_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '2' --2	ICD-10-CM
	  ) as Charge_ICD10_DX_3
--Charge ICD10 DX 4
    ,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_four_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '2' --2	ICD-10-CM
	  ) as Charge_ICD10_DX_4
--Charge ICD9 DX 1
    ,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_one_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '1' --1	ICD-9-CM
	  ) as Charge_ICD9_DX_1
--Charge ICD9 DX 2
,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_two_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '1' --1	ICD-9-CM
	  ) as Charge_ICD9_DX_2
--Charge ICD9 DX 3
,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_three_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '1' --1	ICD-9-CM
	  ) as Charge_ICD9_DX_3
--Charge ICD9 DX 4
,(select ref_bill_code
	  from clarity_edg edg
	  where ctt.dx_four_id=edg.dx_id
	  and edg.REF_BILL_CODE_SET_C= '1' --1	ICD-9-CM
	  ) as Charge_ICD9_DX_4
,ctt.tx_id as Transaction_Number
,ctt.pat_enc_csn_id as CSN
, CONVERT(VARCHAR(10), ctt.ORIG_POST_DATE, 112) as Original_Post_Date
,case when detail_type = 1 then '0' when detail_type = 10 then 1 end as Void_Flag
,'Epic' as Source_System
,ctt.serv_area_id as Service_Area

--MODIFIER PERCENTAGES
,case when ctt.modifier_one is null then 1
	when ctt.modifier_one = 'TC' then 0
	when ctt.modifier_one = '56' then .11
	when ctt.modifier_one = 'AS' then .16
	when ctt.modifier_one = '82' then .16
	when ctt.modifier_one= '81' then .16
	when ctt.modifier_one = '80' then .16
	when ctt.modifier_one = '55' then .20
	when ctt.modifier_one = '50' then 1.50
	when ctt.modifier_one = '51' then .50
	when ctt.modifier_one = '52' then .50
	when ctt.modifier_one = '53' then .50
	when ctt.modifier_one = '74' then .50
	when ctt.modifier_one = '62' then .625
	when ctt.modifier_one = '54' then .70
	when ctt.modifier_one = '22' then 1.25
	when ctt.modifier_one = '76' then .7
	when ctt.modifier_one = '78' then .7
	else 1 end as MOD_PCT1
,case when ctt.modifier_two is null then 1
	when ctt.modifier_two  = 'TC' then 0
	when ctt.modifier_two  = '56' then .11
	when ctt.modifier_two  = 'AS' then .16
	when ctt.modifier_two  = '82' then .16
	when ctt.modifier_two = '81' then .16
	when ctt.modifier_two = '80' then .16
	when ctt.modifier_two  = '55' then .20
	when ctt.modifier_two  = '50' then 1.50
	when ctt.modifier_two  = '51' then .50
	when ctt.modifier_two  = '52' then .50
	when ctt.modifier_two  = '53' then .50
	when ctt.modifier_two  = '74' then .50
	when ctt.modifier_two  = '62' then .625
	when ctt.modifier_two  = '54' then .70
	when ctt.modifier_two = '22' then 1.25
	when ctt.modifier_two = '76' then .7
	when ctt.modifier_two = '78' then .7
	else 1 end as MOD_PCT2
,case when ctt.modifier_three is null then 1
	when ctt.modifier_three = 'TC' then 0
	when ctt.modifier_three= '56' then .11
	when ctt.modifier_three = 'AS' then .16
	when ctt.modifier_three = '82' then .16
	when ctt.modifier_three = '81' then .16
	when ctt.modifier_three = '80' then .16
	when ctt.modifier_three = '55' then .20
	when ctt.modifier_three = '50' then 1.50
	when ctt.modifier_three = '51' then .50
	when ctt.modifier_three = '52' then .50
	when ctt.modifier_three = '53' then .50
	when ctt.modifier_three = '74' then .50
	when ctt.modifier_three = '62' then .625
	when ctt.modifier_three = '54' then .70
	when ctt.modifier_three = '22' then 1.25
	when ctt.modifier_three = '76' then .7
	when ctt.modifier_three = '78' then .7
	else 1 end as MOD_PCT3
,case when ctt.modifier_four is null then 1
	when ctt.modifier_four = 'TC' then 0
	when ctt.modifier_four = '56' then .11
	when ctt.modifier_four = 'AS' then .16
	when ctt.modifier_four = '82' then .16
	when ctt.modifier_four = '81' then .16
	when ctt.modifier_four = '80' then .16
	when ctt.modifier_four = '55' then .20
	when ctt.modifier_four = '50' then 1.50
	when ctt.modifier_four = '51' then .50
	when ctt.modifier_four = '52' then .50
	when ctt.modifier_four = '53' then .50
	when ctt.modifier_four = '74' then .50
	when ctt.modifier_four = '62' then .625
	when ctt.modifier_four = '54' then .70
	when ctt.modifier_four = '22' then 1.25
	when ctt.modifier_four = '76' then .7
	when ctt.modifier_four = '78' then .7
	else 1 end as MOD_PCT4

,ctt.serv_area_id
,ctt.orig_post_date
,ctt.detail_type

From CLARITY_TDL_TRAN ctt

	left outer join (select *
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
			         where begin_contact_date <> end_contact_date) mod26 ON mod26.PROC_ID = ctt.PROC_ID AND mod26.RVU_PER_MOD = '26' AND ctt.ORIG_POST_DATE >= mod26.BEGIN_CONTACT_DATE AND ctt.ORIG_POST_DATE < mod26.END_CONTACT_DATE

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
				    where begin_contact_date <> end_contact_date) modtc ON modtc.PROC_ID = ctt.PROC_ID AND modtc.RVU_PER_MOD = 'TC' AND ctt.ORIG_POST_DATE >= modtc.BEGIN_CONTACT_DATE AND ctt.ORIG_POST_DATE < modtc.END_CONTACT_DATE

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
					where begin_contact_date <> end_contact_date) ot ON ot.PROC_ID = ctt.PROC_ID AND ctt.POST_DATE >= ot.BEGIN_CONTACT_DATE AND ctt.POST_DATE < ot.END_CONTACT_DATE

left outer join CLARITY_EAP eap
	on ctt.proc_id=eap.PROC_ID
left outer join PATIENT pt
	on ctt.INT_PAT_ID = pt.PAT_ID	
left outer join clarity_loc loc on ctt.loc_id = loc.loc_id
left outer join clarity_ser ser on ser.prov_id = ctt.performing_prov_id
left outer join clarity_pos pos on pos.pos_id = ctt.pos_id
left join clarity_dep dep on dep.department_id = ctt.dept_id

where ctt.POST_DATE >= @start_date  --just run some dates for now
	and ctt.POST_DATE <= @end_date
	--and ctt.TRAN_TYPE = '1' --Charges
	and ctt.detail_type in ('1','10')  --Charges and Voids
	and ctt.serv_area_id in (11,13,16,17,18,19)

)trans

order by [Encounter_Record_Number]