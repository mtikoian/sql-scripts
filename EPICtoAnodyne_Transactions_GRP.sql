--STEP 1
if object_id('SSIS.dbo.TMP_CLARITY_EAP_OT') is not null
begin
    drop table SSIS.dbo.TMP_CLARITY_EAP_OT
end

SELECT 
	A.PROC_ID, 
	A.CONTACT_DATE AS BEGIN_CONTACT_DATE,
	CASE WHEN LEAD(A.CONTACT_DATE) OVER (PARTITION BY A.PROC_ID ORDER BY A.PROC_ID, A.CONTACT_DATE, A.CONTACT_DATE_REAL) IS NOT NULL THEN
		LEAD(A.CONTACT_DATE) OVER (PARTITION BY A.PROC_ID ORDER BY A.PROC_ID, A.CONTACT_DATE, A.CONTACT_DATE_REAL)
		ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
	END AS END_CONTACT_DATE,
	A.RVU_WORK_COMPON
INTO SSIS.dbo.TMP_CLARITY_EAP_OT
FROM Clarity.dbo.CLARITY_EAP_OT A


--STEP 2
if object_id('SSIS.dbo.TMP_EAP_RVU_PER_MOD') is not null
begin
    drop table SSIS.dbo.TMP_EAP_RVU_PER_MOD
end

SELECT       
	B.PROC_ID, 
	B.RVU_PER_MOD,
    B.CONTACT_DATE AS BEGIN_CONTACT_DATE,
    CASE WHEN LEAD(B.CONTACT_DATE) OVER (PARTITION BY B.PROC_ID, B.RVU_PER_MOD ORDER BY B.PROC_ID, B.RVU_PER_MOD, B.CONTACT_DATE, B.CONTACT_DATE_REAL) IS NOT NULL THEN
        LEAD(B.CONTACT_DATE) OVER (PARTITION BY B.PROC_ID, B.RVU_PER_MOD ORDER BY B.PROC_ID, B.RVU_PER_MOD, B.CONTACT_DATE, B.CONTACT_DATE_REAL)
        ELSE DATEADD(dd,1,CAST(GETDATE() AS DATE))
    END AS END_CONTACT_DATE,
    B.RVU_PER_MOD_WORK
INTO SSIS.dbo.TMP_EAP_RVU_PER_MOD
FROM Clarity.dbo.EAP_RVU_PER_MOD B


--STEP 3
IF OBJECT_ID('SSIS.dbo.TMP_MOD_OVERRIDE') IS NOT NULL
BEGIN
	DROP TABLE SSIS.dbo.TMP_MOD_OVERRIDE
END

/* This CTE gives us the most recent Line Item Override for each Modifier. */
;WITH MOD_OVERRIDE_MAXLINE (MODIFIER_ID, LINE)
AS
(
	SELECT MODIFIER_ID, MAX(LINE) AS LINE
	FROM Clarity.dbo.CL_MOD_OVERRIDE
	GROUP BY MODIFIER_ID
)

SELECT MO.MODIFIER_ID, CM.EXTERNAL_ID, CM.MODIFIER_NAME, MO.LINE, MO.RVU_CHG_PCT_OVRD, 
		CASE WHEN MO.RVU_CHG_PCT_OVRD IS NOT NULL THEN 1.00 + (MO.RVU_CHG_PCT_OVRD/100)
		ELSE 1.00
		END AS MOD_PCT
INTO SSIS.dbo.TMP_MOD_OVERRIDE
FROM Clarity.dbo.CL_MOD_OVERRIDE MO
JOIN MOD_OVERRIDE_MAXLINE MOM ON MOM.MODIFIER_ID = MO.MODIFIER_ID AND MOM.LINE = MO.LINE
JOIN Clarity.dbo.CLARITY_MOD CM ON CM.MODIFIER_ID = MO.MODIFIER_ID
WHERE MO.RVU_CHG_PCT_OVRD IS NOT NULL


--STEP 4
if object_id('SSIS.dbo.TMP_TRANS') is not null
begin
    drop table SSIS.dbo.TMP_TRANS
end

DECLARE @BPOSTDT DATETIME, @EPOSTDT DATETIME
DECLARE @BEXTDT DATETIME, @EEXTDT DATETIME

SELECT  @BPOSTDT = '2/1/2016'
SELECT  @EPOSTDT = '2/1/2016 11:59:00 PM'
SELECT  @BEXTDT = '2/2/2016'
SELECT  @EEXTDT = '2/2/2016 11:59:00 PM'


SELECT 
	t.TDL_ID, 
	t.DETAIL_TYPE, 
	t.POST_DATE, 
	t.ORIG_POST_DATE, 
	t.ORIG_SERVICE_DATE, 
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
	t.BILLING_PROVIDER_ID, 
	t.ORIGINAL_PAYOR_ID, 
	t.ORIGINAL_PLAN_ID,   
	t.PROCEDURE_QUANTITY, 
	t.CPT_CODE, 
	t.MODIFIER_ONE, 
	t.MODIFIER_TWO, 
	t.MODIFIER_THREE, 
	t.MODIFIER_FOUR, 
	t.DX_ONE_ID, 
	t.DX_TWO_ID, 
	t.DX_THREE_ID, 
	t.DX_FOUR_ID, 
	t.DX_SIX_ID, 
	--t.SERV_AREA_ID
	loc2.serv_area_id as 'SERV_AREA_ID',
	--t.LOC_ID
	loc2.loc_id as 'LOC_ID', 
	--t.DEPT_ID, 
	dep2.dept_id as 'DEPT_ID',
	--t.POS_ID, 
	cast(pos.rpt_grp_one as numeric) as 'POS_ID',
	t.INVOICE_NUMBER, 
	t.CLM_CLAIM_ID, 
	t.PAT_AGING_DAYS, 
	t.INS_AGING_DAYS, 
	t.ACTION_PAYOR_ID, 
	t.REASON_CODE_ID, 
	LEFT(t.USER_ID,18) AS USER_ID, 
	t.TX_NUM, 
	t.INT_PAT_ID, 

	CASE 
		WHEN t.POST_DATE < '2016-01-01' THEN t.RVU_WORK
		WHEN t.MODIFIER_ONE = '26' OR t.MODIFIER_TWO = '26' OR t.MODIFIER_THREE = '26' OR t.MODIFIER_FOUR = '26' THEN COALESCE(mod26.RVU_PER_MOD_WORK, ot.RVU_WORK_COMPON, 0.00)
		WHEN t.MODIFIER_ONE = 'TC' OR t.MODIFIER_TWO = 'TC' OR t.MODIFIER_THREE = 'TC' OR t.MODIFIER_FOUR = 'TC' THEN COALESCE(modTC.RVU_PER_MOD_WORK, ot.RVU_WORK_COMPON, 0.00)
		ELSE COALESCE(ot.RVU_WORK_COMPON,0)
	END AS RVU_WORK,

	t.RVU_OVERHEAD, 
	t.RVU_MALPRACTICE, 
	t.REFERRAL_SOURCE_ID, 
	t.REFERRAL_ID, 
	t.MATCH_PAYOR_ID, 
	t.VISIT_NUMBER, 
	t.CHARGE_SLIP_NUMBER, 
	t.PERIOD,
	s.NAME AS CREDENTIALED_SPECIALTY,

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

                                /*  NOTE:  For 1/1/2016 through 4/30/17, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
                                  final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
                            */
                          WHEN t.ORIG_POST_DATE >= '2016-04-01' AND t.ORIG_POST_DATE < '2017-05-01' THEN
                                  CASE 
                                         WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR t.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(t.RVU_WORK,0) > 0 THEN COALESCE(t.RVU_WORK,0) * COALESCE(t.PROCEDURE_QUANTITY,0)
                                                       ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END
								  
						  /*  NOTE:  For 5/1/2017 and beyond added cpt codes 96521 and 96522, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
                                  final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
                            */
                          ELSE 
                                  CASE 
                                         WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96521','96522', '96523') OR t.CPT_CODE IS NULL) THEN 
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

                           /*  NOTE:  For 1/1/2016 through 4/30/17, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
                                  final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
                            */
                          WHEN t.ORIG_POST_DATE >= '2016-04-01' AND t.ORIG_POST_DATE < '2017-05-01' THEN
                                  CASE 
                                         WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523') OR t.CPT_CODE IS NULL) THEN 
                                                CASE 
                                                       WHEN COALESCE(t.RVU_WORK,0) > 0 THEN COALESCE(t.RVU_WORK,0) * COALESCE(t.PROCEDURE_QUANTITY,0)
                                                       ELSE COALESCE(t.RELATIVE_VALUE_UNIT,0)
                                                END
                                         ELSE 0
                                  END
								  
						  /*  NOTE:  For 5/1/2017 and beyond added cpt codes 96521 and 96522, do not use MULTIPLIERS in the ADJ WRVU calculation.  This calculation is done in the
                                  final SELECT below.  Multipliers are already worked into the RVU_WORK value after 2016.
                            */
                          ELSE 
                                  CASE 
                                         WHEN (t.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', '96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376', '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96521','96522', '96523') OR t.CPT_CODE IS NULL) THEN 
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

	COALESCE((SELECT m.MOD_PCT from SSIS.dbo.TMP_MOD_OVERRIDE m where m.EXTERNAL_ID = t.MODIFIER_ONE),1.00) AS MOD_PCT1,
	COALESCE((SELECT m.MOD_PCT from SSIS.dbo.TMP_MOD_OVERRIDE m where m.EXTERNAL_ID = t.MODIFIER_TWO),1.00) AS MOD_PCT2,
	COALESCE((SELECT m.MOD_PCT from SSIS.dbo.TMP_MOD_OVERRIDE m where m.EXTERNAL_ID = t.MODIFIER_THREE),1.00) AS MOD_PCT3,
	COALESCE((SELECT m.MOD_PCT from SSIS.dbo.TMP_MOD_OVERRIDE m where m.EXTERNAL_ID = t.MODIFIER_FOUR),1.00) AS MOD_PCT4

INTO SSIS.dbo.TMP_TRANS
FROM   Clarity.dbo.CLARITY_TDL_TRAN t
LEFT OUTER JOIN SSIS.dbo.TMP_EAP_RVU_PER_MOD mod26 ON mod26.PROC_ID = t.PROC_ID AND mod26.RVU_PER_MOD = '26' AND t.ORIG_POST_DATE >= mod26.BEGIN_CONTACT_DATE AND t.ORIG_POST_DATE < mod26.END_CONTACT_DATE AND mod26.BEGIN_CONTACT_DATE <> mod26.END_CONTACT_DATE
LEFT OUTER JOIN SSIS.dbo.TMP_EAP_RVU_PER_MOD modTC ON modTC.PROC_ID = t.PROC_ID AND modTC.RVU_PER_MOD = 'TC' AND t.ORIG_POST_DATE >= modTC.BEGIN_CONTACT_DATE AND t.ORIG_POST_DATE < modTC.END_CONTACT_DATE AND modTC.BEGIN_CONTACT_DATE <> modTC.END_CONTACT_DATE
LEFT OUTER JOIN Clarity.dbo.ZC_SPECIALTY s ON t.PROV_SPECIALTY_C = s.SPECIALTY_C
--ADDED Clarity.dbo.CLARITY_LOC
LEFT OUTER JOIN Clarity.dbo.CLARITY_LOC loc on loc.loc_id = t.loc_id
INNER JOIN claritychputil.rpt.v_pb_location loc2 on loc2.loc_id = loc.rpt_grp_two
--ADDED Clarity.dbo.CLARITY_DEP
LEFT OUTER JOIN Clarity.dbo.CLARITY_DEP dep on dep.department_id = t.dept_id
INNER JOIN claritychpUtil.rpt.v_pb_department dep2 on dep2.dept_id = dep.rpt_grp_one
--ADDED Clarity.dbo.CLARITY_LOC
LEFT OUTER JOIN CLARITY_POS pos on pos.pos_id = t.pos_id
LEFT OUTER JOIN SSIS.dbo.TMP_CLARITY_EAP_OT ot ON ot.PROC_ID = t.PROC_ID AND t.POST_DATE >= ot.BEGIN_CONTACT_DATE AND t.POST_DATE < ot.END_CONTACT_DATE AND ot.BEGIN_CONTACT_DATE <> ot.END_CONTACT_DATE

WHERE 
--t.SERV_AREA_ID IN (11, 13, 16, 17, 18, 19, 21, 1312)
--ADDED loc.rpt_grp_ten IN (11,13,16,17,18,19,21,1312)
loc2.serv_area_id IN (1,11,13,16,17,18,19,21,1312)
AND ((t.TDL_EXTRACT_DATE >= @BEXTDT AND t.TDL_EXTRACT_DATE <= @EEXTDT)
OR (t.POST_DATE >= @BPOSTDT AND t.POST_DATE <= @EPOSTDT))


--STEP 5
DECLARE @EPOSTDT DATETIME

SELECT @BPOSTDT = ?
SELECT @EPOSTDT = ?

;WITH TMP_TOTALS (Service_Area_Name, Charges, Payments, Adjustments)
AS
(
SELECT 
	--sa.SERV_AREA_NAME
	--added sa.NAME
	loc2.serv_area_name as 'SERV_AREA_NAME'
	,Charges = SUM(CASE WHEN t.DETAIL_TYPE IN (1,10) THEN t.AMOUNT ELSE 0 END)
	,Payments = SUM(CASE WHEN t.DETAIL_TYPE IN (2,5,11,20,22,32,33) THEN t.PATIENT_AMOUNT + t.INSURANCE_AMOUNT ELSE 0 END)
	,Adjustments = SUM(CASE WHEN t.DETAIL_TYPE IN (3,4,6,12,13,21,23,30,31) THEN t.AMOUNT ELSE 0 END)
FROM SSIS.dbo.CHPIT_tmp_Transactions_ForTotals t
JOIN CLARITY.dbo.CLARITY_LOC loc on loc.loc_id = t.loc_id
INNER JOIN claritychputil.rpt.v_pb_location loc2 on loc2.loc_id = loc.rpt_grp_two
WHERE t.POST_DATE >= @BPOSTDT AND t.POST_DATE <= @EPOSTDT
GROUP BY loc2.serv_area_name
)
SELECT *
FROM TMP_TOTALS
ORDER BY 1


--STEP 6
SELECT  
	TDL_ID, DETAIL_TYPE, POST_DATE, ORIG_POST_DATE, ORIG_SERVICE_DATE, TX_ID, TRAN_TYPE, MATCH_TRX_ID, ACCOUNT_ID, PAT_ID, AMOUNT,
	PATIENT_AMOUNT, INSURANCE_AMOUNT, RELATIVE_VALUE_UNIT, CUR_PAYOR_ID, CUR_PLAN_ID, PROC_ID, PERFORMING_PROV_ID, BILLING_PROVIDER_ID, 
	ORIGINAL_PAYOR_ID, ORIGINAL_PLAN_ID, PROCEDURE_QUANTITY, CPT_CODE, MODIFIER_ONE, MODIFIER_TWO, MODIFIER_THREE, MODIFIER_FOUR, 
	DX_ONE_ID, DX_TWO_ID, DX_THREE_ID, DX_FOUR_ID, DX_FIVE_ID, DX_SIX_ID, SERV_AREA_ID, LOC_ID, DEPT_ID, POS_ID, INVOICE_NUMBER, 
	CLM_CLAIM_ID, PAT_AGING_DAYS, INS_AGING_DAYS, ACTION_PAYOR_ID, REASON_CODE_ID, USER_ID, TX_NUM, INT_PAT_ID, RVU_WORK, RVU_OVERHEAD, 
	RVU_MALPRACTICE, REFERRAL_SOURCE_ID, REFERRAL_ID, MATCH_PAYOR_ID, VISIT_NUMBER, CHARGE_SLIP_NUMBER, PERIOD, CREDENTIALED_SPECIALTY, 

	--I'M ONLY INCLUDING THESE 5 FIELDS FOR TESTING
	--SUB_ADJWRVU, MOD_PCT1, MOD_PCT2, MOD_PCT3, MOD_PCT4,

	CASE
		WHEN SERV_AREA_ID = 1312 THEN 0.00
		WHEN DETAIL_TYPE = 10 AND ORIG_POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
		WHEN DETAIL_TYPE = 1 AND POST_DATE < '2016-01-01' THEN SUB_ADJWRVU * MOD_PCT1 * MOD_PCT2 * MOD_PCT3 * MOD_PCT4
		ELSE SUB_ADJWRVU
	END	AS ADJ_WRVU

FROM dbo.TMP_TRANS
