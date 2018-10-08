SELECT *
FROM

(SELECT case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end as "Market",
                     sum(Case When ("CLARITY_TDL_Tran"."DETAIL_TYPE" = 1 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 10) and
              ("CLARITY_TDL_TRAN"."CPT_CODE">='96150' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='96154' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='90800' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='90884' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='90886' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='90899' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99024' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99069' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99071' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99079' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99081' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99144' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99146' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99149' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99151' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99172' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99174' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99291' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99293' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99359' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE">='99375' AND "CLARITY_TDL_TRAN"."CPT_CODE"<='99480' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='99361' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='99373' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0402' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0406' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0407' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0408' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0409' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0438' OR 
                "CLARITY_TDL_TRAN"."CPT_CODE"='G0439')
              then
                           "CLARITY_TDL_TRAN"."PROCEDURE_QUANTITY" end) as "CHP Visits",

-->>>>>>>>  Calculation for Total Charges  <<<<<<<<<<<

              SUM(case when("CLARITY_TDL_Tran"."DETAIL_TYPE" = 1 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 10)
                     Then "CLARITY_TDL_tran"."AMOUNT"
              end) AS "Total Charges",

-->>>>>>>>  Calculation for Net Revenue  <<<<<<<<<<<
			sum(case when("CLARITY_TDL_Tran"."DETAIL_TYPE" = 1 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 10  or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 3 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 12
															   or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 4 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 6 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 13 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 21
															   or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 23 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 30 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 31)
                     Then "CLARITY_TDL_tran"."AMOUNT"
                end) as "Net Rev",



--Displays new debit adjustments, debit adjustment voids, and credit adjustment reversals.

-- The following detail types are significant
--  3 - New debit adjustment
-- 12 - Voided debit adjustment

-->>>>>>>>  Calculation for Payments  <<<<<<<<<<<

              SUM(case when("CLARITY_TDL_Tran"."DETAIL_TYPE" = 2 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 5 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 11 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 20 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 22 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 32 or "CLARITY_TDL_Tran"."DETAIL_TYPE" = 33)
                     Then "CLARITY_TDL_tran"."AMOUNT"
              end)*-1 AS "Total Payments",

-->>>>>>>>  Calculation for Bad Debt  <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 21 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 23) and "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'BAD') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 4 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 13 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 30 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 31) and "CLARITY_EAP"."GL_NUM_DEBIT" = 'BAD') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            When("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 4 and "CLARITY_EAP"."GL_NUM_DEBIT" = 'BAD DEBT RECOVERY') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            When("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 6 and "CLARITY_EAP"."GL_NUM_CREDIT" = 'BADRECOVERY') then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End)*-1 as "Bad Debt",

-->>>>>>>>  Calculation for Charity  <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 21 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 23) and "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'CHARITY') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 4 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 13 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 30 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 31) and "CLARITY_EAP"."GL_NUM_DEBIT" = 'CHARITY') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            When("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 6 and "CLARITY_EAP"."GL_NUM_CREDIT" = 'CHARITY') then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End)*-1 as "Charity",

-->>>>>>>>  Calculation for Admin  <<<<<<<<<<<

sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 21 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 23) and "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'ADMIN') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 4 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 13 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 30 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 31) and "CLARITY_EAP"."GL_NUM_DEBIT" = 'ADMIN') then "CLARITY_TDL_TRAN"."AMOUNT" 
                            When("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 6 and "CLARITY_EAP"."GL_NUM_CREDIT" = 'ADMIN') then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End)*-1 as "Admin",

-->>>>>>>>  Calculation for 1st Denial - Duplicate <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Duplicate') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Duplicate",

-->>>>>>>>  Calculation for 1st Denial - Eligibility/Registration <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Eligibility/Registration') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Eligibility/Registration",

-->>>>>>>>  Calculation for 1st Denial - Authorization <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Authorization') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Authorization",

-->>>>>>>>  Calculation for 1st Denial - Enrollment <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Enrollment') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Enrollment",

-->>>>>>>>  Calculation for 1st Denial - NonCovered <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Non-Covered') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Non Covered",

-->>>>>>>>  Calculation for 1st Denial - Past Timely Filing <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Past Timely Filing') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Past Timely Filing",

-->>>>>>>>  Calculation for 1st Denial - Additional Documentation <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 44) and "ZC_RMC_CODE_CAT"."NAME" = 'Additional Documentation Needed') then "CLARITY_TDL_TRAN"."ACTION_AMOUNT" 
                            End) as "1st Denial - Additional Documentation Needed",


-->>>>>>>>  Calculation for Final Denial  <<<<<<<<<<<

              sum(case when(("CLARITY_EAP_MATCH"."PROC_CODE" = '4017'  or "CLARITY_EAP_MATCH"."PROC_CODE" = '4018' or "CLARITY_EAP_MATCH"."PROC_CODE" = '4019' or "CLARITY_EAP_MATCH"."PROC_CODE" = '4020' or "CLARITY_EAP_MATCH"."PROC_CODE" = '4021') ) then "CLARITY_TDL_TRAN"."AMOUNT" 
                            End)*-1 as "Final Denial",


-->>>>>>>>  Calculation for Cash Patient CoPay  <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 11 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 12 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 13 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 2 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 3 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 4 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 5 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 6) and (("CLARITY_TDL_TRAN"."DEBIT_GL_NUM"='CASH') or ("CLARITY_TDL_TRAN"."CREDIT_GL_NUM"='CASH')) and ("CLARITY_EAP"."PROC_NAME"='CO-PAYMENT (ACCOUNT)')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End)*-1 as "Cash Patient CoPay",

-->>>>>>>>  Calculation for Total Patient Cash Posting  <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 11 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 12 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 13 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 2 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 3 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 4 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 5 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 6) and (("CLARITY_TDL_TRAN"."DEBIT_GL_NUM"='CASH') or ("CLARITY_TDL_TRAN"."CREDIT_GL_NUM"='CASH')) and ("CLARITY_EAP"."PROC_NAME"='CO-PAYMENT (ACCOUNT)' or "CLARITY_EAP"."PROC_NAME"='PATIENT PAYMENT (ACCOUNT)')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End)*-1 as "Total Patient Cash Posting",

-->>>>>>>>  Calculation for Payor Mix - BX Managed  <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='BX Managed')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "BX Mgd Charges",

-->>>>>>>>  Calculation for Payor Mix - BX Traditional  <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='BX Traditional')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "BX Trd Charges",

-->>>>>>>>  Calculation for Payor Mix - Commercial <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Commercial')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Commercial Charges",

-->>>>>>>>  Calculation for Payor Mix - Managed Care <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Managed Care')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Managed Care Charges",

-->>>>>>>>  Calculation for Payor Mix - Medicaid <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Medicaid')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Medicaid Charges",

-->>>>>>>>  Calculation for Payor Mix - Medicaid Mgd <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Medicaid Managed')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Medicaid Mgd Charges",

-->>>>>>>>  Calculation for Payor Mix - Medicare <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Medicare')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Medicare Charges",

-->>>>>>>>  Calculation for Payor Mix - Medicare Mgd <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Medicare Managed')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Medicare Mdg Charges",

-->>>>>>>>  Calculation for Payor Mix - Other <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Other')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Other Charges",

-->>>>>>>>  Calculation for Payor Mix - Self Pay <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and ("ZC_ORIG_FIN_CLASS"."NAME"='Self-pay')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Self Pay Charges",

-->>>>>>>>  Calculation for Payor Mix - Worker's Comp Pay <<<<<<<<<<<

              sum(case when(("CLARITY_TDL_TRAN"."DETAIL_TYPE" = 1 or "CLARITY_TDL_TRAN"."DETAIL_TYPE" = 10) and (left("ZC_ORIG_FIN_CLASS"."NAME",6)='Worker')) then "CLARITY_TDL_TRAN"."AMOUNT" 
                  End) as "Workers Comp Charges"


FROM   ((((((((("Clarity"."dbo"."CLARITY_TDL_Tran"  
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_EAP" "CLARITY_EAP_MATCH" ON "CLARITY_TDL_tran"."MATCH_PROC_ID"="CLARITY_EAP_MATCH"."PROC_ID")
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_EAP" ON "CLARITY_TDL_Tran"."PROC_ID"="CLARITY_EAP"."PROC_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_LOC" ON "CLARITY_TDL_Tran"."LOC_ID"="CLARITY_LOC"."LOC_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SA"  ON "CLARITY_TDL_Tran"."SERV_AREA_ID"="CLARITY_SA"."SERV_AREA_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" ON "CLARITY_TDL_Tran"."DEPT_ID"="CLARITY_DEP"."DEPARTMENT_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_RMC" ON "CLARITY_TDL_tran"."REASON_CODE_ID"="CLARITY_RMC"."REMIT_CODE_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."ZC_RMC_CODE_CAT" ON "CLARITY_RMC"."CODE_CAT_C"="ZC_RMC_CODE_CAT"."RMC_CODE_CAT_C")
                          LEFT OUTER JOIN "Clarity"."dbo"."ZC_ORIG_FIN_CLASS" ON "CLARITY_TDL_Tran"."ORIGINAL_FIN_CLASS"="ZC_ORIG_FIN_CLASS"."ORIGINAL_FIN_CLASS"))

WHERE  ("CLARITY_TDL_Tran"."SERV_AREA_ID"<22) AND 
              ("CLARITY_TDL_Tran"."POST_DATE">={ts '2015-04-01 00:00:00'} AND 
               "CLARITY_TDL_Tran"."POST_date"<={ts '2015-04-30 00:00:00'})

GROUP BY (case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end)

)as Main,

(SELECT case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end as "Market",

-->>>>>>>>  Calculation for Self Pay AR Aging > 90 Days  <<<<<<<<<<<

		sum(case when(("CLARITY_TDL_AGE"."DETAIL_TYPE" = 60) and ("CLARITY_TDL_AGE"."POST_DATE" - "CLARITY_TDL_AGE"."ORIG_POST_DATE"> 90)) then "CLARITY_TDL_AGE"."PATIENT_AMOUNT" 
				 End) as "Patient AR > 90",

-->>>>>>>>  Calculation for Total Self Pay AR  <<<<<<<<<<<

		sum(case when(("CLARITY_TDL_AGE"."DETAIL_TYPE" = 60)) then "CLARITY_TDL_AGE"."PATIENT_AMOUNT" 
				 End) as "Total Self Pay AR",

-->>>>>>>>  Calculation for Insurance AR Aging > 90 Days  <<<<<<<<<<<

		sum(case when(("CLARITY_TDL_AGE"."DETAIL_TYPE" = 60) and ("CLARITY_TDL_AGE"."POST_DATE" - "CLARITY_TDL_AGE"."ORIG_POST_DATE"> 90)) then "CLARITY_TDL_AGE"."INSURANCE_AMOUNT" 
				 End) as "Insurance AR > 90",

-->>>>>>>>  Calculation for Insurance Pay AR  <<<<<<<<<<<

		sum(case when(("CLARITY_TDL_AGE"."DETAIL_TYPE" = 60)) then "CLARITY_TDL_AGE"."INSURANCE_AMOUNT" 
				 End) as "Insurance Pay AR"



FROM   ((("Clarity"."dbo"."CLARITY_TDL_Age"
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_LOC" ON "CLARITY_TDL_AGE"."LOC_ID"="CLARITY_LOC"."LOC_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SA"  ON "CLARITY_TDL_AGE"."SERV_AREA_ID"="CLARITY_SA"."SERV_AREA_ID") 
                           LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" ON "CLARITY_TDL_age"."DEPT_ID"="CLARITY_DEP"."DEPARTMENT_ID") 


WHERE  ("CLARITY_TDL_AGE"."SERV_AREA_ID"<22) AND 
              ("CLARITY_TDL_AGE"."POST_DATE">={ts '2015-04-01 00:00:00'} AND 
               "CLARITY_TDL_AGE"."POST_date"<={ts '2015-04-30 00:00:00'})

GROUP BY (case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end)

)as sub,

(SELECT 
		Case
			when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
			when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
			when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
		end as "Market",
		 sum("V_SCHED_APPT"."COPAY_COLLECTED") as "CoPay Collected",
		 sum("V_SCHED_APPT"."COPAY_DUE") as "CoPay Due"
		  
 FROM   ((((((((((("Clarity"."dbo"."V_SCHED_APPT" "V_SCHED_APPT" INNER JOIN "Clarity"."dbo"."PAT_ENC" "PAT_ENC" ON "V_SCHED_APPT"."PAT_ENC_CSN_ID"="PAT_ENC"."PAT_ENC_CSN_ID") INNER JOIN "Clarity"."dbo"."DATE_DIMENSION" "DATE_DIMENSION" ON "V_SCHED_APPT"."CONTACT_DATE"="DATE_DIMENSION"."CALENDAR_DT") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" "CLARITY_DEP" ON "V_SCHED_APPT"."DEPARTMENT_ID"="CLARITY_DEP"."DEPARTMENT_ID") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SER" "CLARITY_SER_visit_prov" ON "V_SCHED_APPT"."PROV_ID"="CLARITY_SER_visit_prov"."PROV_ID") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_PRC" "CLARITY_PRC" ON "V_SCHED_APPT"."PRC_ID"="CLARITY_PRC"."PRC_ID") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_EMP" "CLARITY_EMP_copay_user" ON "V_SCHED_APPT"."COPAY_USER_ID"="CLARITY_EMP_copay_user"."USER_ID") LEFT OUTER JOIN "Clarity"."dbo"."PAT_ENC_3" "PAT_ENC_3" ON "V_SCHED_APPT"."PAT_ENC_CSN_ID"="PAT_ENC_3"."PAT_ENC_CSN") LEFT OUTER JOIN "Clarity"."dbo"."V_COVERAGE_PAYOR_PLAN" "V_COVERAGE_PAYOR_PLAN" ON (("V_SCHED_APPT"."CONTACT_DATE">="V_COVERAGE_PAYOR_PLAN"."EFF_DATE") AND ("V_SCHED_APPT"."CONTACT_DATE"<="V_COVERAGE_PAYOR_PLAN"."TERM_DATE")) AND ("V_SCHED_APPT"."COVERAGE_ID"="V_COVERAGE_PAYOR_PLAN"."COVERAGE_ID")) LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_LOC" "CLARITY_LOC" ON "CLARITY_DEP"."REV_LOC_ID"="CLARITY_LOC"."LOC_ID") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SA" "CLARITY_SA" ON "CLARITY_DEP"."SERV_AREA_ID"="CLARITY_SA"."SERV_AREA_ID") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_EMP" "CLARITY_EMP_checkin_user" ON "PAT_ENC"."CHECKIN_USER_ID"="CLARITY_EMP_checkin_user"."USER_ID") LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SER" "CLARITY_SER_pcp_prov" ON "PAT_ENC"."PCP_PROV_ID"="CLARITY_SER_pcp_prov"."PROV_ID"

 WHERE  ("V_SCHED_APPT"."APPT_STATUS_C"=2 OR "V_SCHED_APPT"."APPT_STATUS_C"=6) AND 
		("V_SCHED_APPT"."CONTACT_DATE">={ts '2015-04-01 00:00:00'} AND 
		"V_SCHED_APPT"."CONTACT_DATE"<={ts '2015-04-30 00:00:01'}) AND 
		"CLARITY_DEP"."SERV_AREA_ID"<30 and ("V_SCHED_APPT"."COPAY_DUE" <> 0) and 
		("V_SCHED_APPT"."LOC_ID" <> '11108' and "V_SCHED_APPT"."LOC_ID" <> '11114111' and "V_SCHED_APPT"."LOC_ID" <> '13103' and "V_SCHED_APPT"."LOC_ID" <> '18101'and "V_SCHED_APPT"."LOC_ID" <> '11110'and "V_SCHED_APPT"."LOC_ID" <> '18106' and "V_SCHED_APPT"."LOC_ID" <> '13101' and "V_SCHED_APPT"."LOC_ID" <> '18111' and "V_SCHED_APPT"."LOC_ID" <> '13102'and "V_SCHED_APPT"."LOC_ID" <> '11107'and "V_SCHED_APPT"."LOC_ID" <> '11130'and "V_SCHED_APPT"."LOC_ID" <> '11129'and "V_SCHED_APPT"."LOC_ID" <> '16101'and "V_SCHED_APPT"."LOC_ID" <> '18107'and "V_SCHED_APPT"."LOC_ID" <> '18108'and "V_SCHED_APPT"."LOC_ID" <> '18109'and "V_SCHED_APPT"."LOC_ID" <> '18112'and "V_SCHED_APPT"."LOC_ID" <> '18113'and "V_SCHED_APPT"."LOC_ID" <> '118117'and "V_SCHED_APPT"."LOC_ID" <> '18118'and "V_SCHED_APPT"."LOC_ID" <> '19104')

  GROUP BY (case
			when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
			when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
			when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
			when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
		end)
) as copay,

( -- NOTE:   This SQL must be ran as close to the 1st as possible.  It can only report a point in time.
 
 SELECT 
		Case
			when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '13' then 'Youngstown Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '16' then 'Lima Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '17' then 'Lorain Market'
			when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
			when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '18' then 'Toledo Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '19' then 'Kentucky Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '21' then 'Healthspan Market'
		end as "Market",
--		"PAT_ENC"."CONTACT_DATE",

-->>>>>>>>  Calculation for Open Encounters < 8 days  <<<<<<<<<<<
		sum(Case
			When datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})<7 Then 1
		End) as "<7 Days",

-->>>>>>>>  Calculation for Open Encounters 7 - 30 days  <<<<<<<<<<<
		sum(Case
			When datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})>6 and datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})<31 Then 1
		End) as "7 - 30 Days",

-->>>>>>>>  Calculation for Open Encounters 31 - 90 days  <<<<<<<<<<<
		sum(Case
			When datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})>30 and datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})<91 Then 1
		End) as "31 - 90 Days",

-->>>>>>>>  Calculation for Open Encounters 91 - 365 days  <<<<<<<<<<<
		sum(Case
			When datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})>90 and datediff(day,"PAT_ENC"."CONTACT_DATE",{ts '2015-04-30 00:00:01'})<366 Then 1
		End) as "91 - 365 Days"



 FROM   (((("Clarity"."dbo"."PAT_ENC" "PAT_ENC" LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SER" "CLARITY_SER" ON "PAT_ENC"."VISIT_PROV_ID"="CLARITY_SER"."PROV_ID") 
												LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" "CLARITY_DEP" ON "PAT_ENC"."DEPARTMENT_ID"="CLARITY_DEP"."DEPARTMENT_ID") 
												LEFT OUTER JOIN "Clarity"."dbo"."ZC_DISP_ENC_TYPE" "ZC_DISP_ENC_TYPE" ON "PAT_ENC"."ENC_TYPE_C"="ZC_DISP_ENC_TYPE"."DISP_ENC_TYPE_C") 
												LEFT OUTER JOIN "Clarity"."dbo"."PATIENT" "PATIENT" ON "PAT_ENC"."PAT_ID"="PATIENT"."PAT_ID") 
												LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_LOC" "CLARITY_LOC" ON "CLARITY_DEP"."REV_LOC_ID"="CLARITY_LOC"."LOC_ID"
 WHERE  "CLARITY_LOC"."SERV_AREA_ID"<=21 AND 
		"PAT_ENC"."ENC_CLOSED_YN"='n' AND 
		("PAT_ENC"."ENC_TYPE_C"='1000' OR "PAT_ENC"."ENC_TYPE_C"='1001' OR "PAT_ENC"."ENC_TYPE_C"='1003' OR "PAT_ENC"."ENC_TYPE_C"='101' OR "PAT_ENC"."ENC_TYPE_C"='108' OR "PAT_ENC"."ENC_TYPE_C"='1200' OR "PAT_ENC"."ENC_TYPE_C"='1201' OR "PAT_ENC"."ENC_TYPE_C"='1201' OR "PAT_ENC"."ENC_TYPE_C"='1214' OR "PAT_ENC"."ENC_TYPE_C"='201' OR "PAT_ENC"."ENC_TYPE_C"='2101' OR "PAT_ENC"."ENC_TYPE_C"='2502') AND 
		("PAT_ENC"."CONTACT_DATE">={ts '2014-04-01 00:00:00'} AND 
		 "PAT_ENC"."CONTACT_DATE"<={ts '2015-04-30 00:00:01'}) AND  
		NOT ("PAT_ENC"."APPT_STATUS_C"=4 OR "PAT_ENC"."APPT_STATUS_C"=5)
 --ORDER BY "CLARITY_LOC"."SERV_AREA_ID", "CLARITY_DEP"."DEPARTMENT_NAME", "CLARITY_SER"."PROV_NAME"
 
 GROUP BY (Case
			when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '13' then 'Youngstown Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '16' then 'Lima Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '17' then 'Lorain Market'
			when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
			when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '18' then 'Toledo Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '19' then 'Kentucky Market'
			when "CLARITY_LOC"."SERV_AREA_ID" = '21' then 'Healthspan Market'
		end)
) as ENC,

( SELECT 
		case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end as "Market", 

-->>>>>>>>  Calculation for Total Charge Lag Days  <<<<<<<<<<<

		sum(datediff(day,"ARPB_TRANSACTIONS"."SERVICE_DATE","ARPB_TRANSACTIONS"."POST_DATE")) as "Total Charge Lag Days",

-->>>>>>>>  Calculation for Distinct count Lag Charges  <<<<<<<<<<<

		Count("ARPB_TRANSACTIONS"."Account_ID") as "Distinct count Lag Charges",

-->>>>>>>>  Calculation for Lag Days  <<<<<<<<<<<

		sum(datediff(day,"ARPB_TRANSACTIONS"."SERVICE_DATE","ARPB_TRANSACTIONS"."POST_DATE"))/Count("ARPB_TRANSACTIONS"."Account_ID") as "Lag Days"

 FROM   (("Clarity"."dbo"."ARPB_TRANSACTIONS" "ARPB_TRANSACTIONS" INNER JOIN "Clarity"."dbo"."CLARITY_LOC" "CLARITY_LOC" ON "ARPB_TRANSACTIONS"."LOC_ID"="CLARITY_LOC"."LOC_ID") 
																  INNER JOIN "Clarity"."dbo"."CLARITY_SA" "CLARITY_SA" ON "ARPB_TRANSACTIONS"."SERVICE_AREA_ID"="CLARITY_SA"."SERV_AREA_ID") 
																  LEFT OUTER JOIN "Clarity"."dbo"."ARPB_TX_VOID" "ARPB_TX_VOID" ON "ARPB_TRANSACTIONS"."TX_ID"="ARPB_TX_VOID"."TX_ID"
 WHERE  "ARPB_TX_VOID"."OLD_ETR_ID" IS  NULL  AND "ARPB_TRANSACTIONS"."AMOUNT"<>0 AND 
		("ARPB_TRANSACTIONS"."POST_DATE">={ts '2015-04-01 00:00:00'} AND 
		 "ARPB_TRANSACTIONS"."POST_DATE"<={ts '2015-04-30 00:00:01'}) AND 
		"ARPB_TRANSACTIONS"."TX_TYPE_C"=1 AND 
		"ARPB_TRANSACTIONS"."SERVICE_AREA_ID"<30

 GROUP BY (case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end)
) as "Lag"

,

( SELECT 
		case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end as "Market", 

-->>>>>>>>  Calculation for Total Charge Review Days  <<<<<<<<<<<

		sum(datediff(day, V_ARPB_CHG_REVIEW_WQ.ENTRY_DATE, V_ARPB_CHG_REVIEW_WQ.EXIT_DATE)) as "Total Charge Review Days",

-->>>>>>>>  Calculation for Distinct count Lag Charges  <<<<<<<<<<<

		Count("ARPB_TRANSACTIONS"."Account_ID") as "Distinct count Lag Charges",

-->>>>>>>>  Calculation for Lag Days  <<<<<<<<<<<

		sum(datediff(day, V_ARPB_CHG_REVIEW_WQ.ENTRY_DATE, V_ARPB_CHG_REVIEW_WQ.EXIT_DATE))/Count("ARPB_TRANSACTIONS"."Account_ID") as "Review Days"

 
 FROM ARPB_TRANSACTIONS ARPB_TRANSACTIONS 
 LEFT OUTER JOIN (select loc_id, loc_name from CLARITY_LOC) CLARITY_LOC ON ARPB_TRANSACTIONS.LOC_ID=CLARITY_LOC.LOC_ID
 LEFT OUTER JOIN (select proc_id,proc_code,proc_cat_id,proc_name from CLARITY_EAP) CLARITY_EAP ON ARPB_TRANSACTIONS.PROC_ID=CLARITY_EAP.PROC_ID
 LEFT OUTER JOIN (select proc_cat_id,proc_cat_name from EDP_PROC_CAT_INFO) EDP_PROC_CAT_INFO ON CLARITY_EAP.PROC_CAT_ID=EDP_PROC_CAT_INFO.PROC_CAT_ID
 LEFT OUTER JOIN (select pos_type_c,pos_id,pos_name from CLARITY_POS) CLARITY_POS ON ARPB_TRANSACTIONS.POS_ID=CLARITY_POS.POS_ID
 LEFT OUTER JOIN ZC_POS_TYPE ZC_POS_TYPE ON CLARITY_POS.POS_TYPE_C=ZC_POS_TYPE.POS_TYPE_C
 LEFT OUTER JOIN (select specialty_dep_c,department_id,department_name from CLARITY_DEP) CLARITY_DEP ON ARPB_TRANSACTIONS.DEPARTMENT_ID=CLARITY_DEP.DEPARTMENT_ID
 LEFT OUTER JOIN ZC_SPECIALTY_DEP ZC_SPECIALTY_DEP ON CLARITY_DEP.SPECIALTY_DEP_C=ZC_SPECIALTY_DEP.SPECIALTY_DEP_C
 LEFT OUTER JOIN (select prov_id,prov_name from CLARITY_SER) BILLING_PROVIDER ON ARPB_TRANSACTIONS.BILLING_PROV_ID=BILLING_PROVIDER.PROV_ID
 LEFT OUTER JOIN (select prov_id,prov_name from CLARITY_SER) SERVICE_PROVIDER ON ARPB_TRANSACTIONS.SERV_PROVIDER_ID=SERVICE_PROVIDER.PROV_ID
 LEFT OUTER JOIN (select serv_area_id,serv_area_name from CLARITY_SA) CLARITY_SA ON ARPB_TRANSACTIONS.SERVICE_AREA_ID=CLARITY_SA.SERV_AREA_ID
 LEFT OUTER JOIN ARPB_TRANSACTIONS2 ARPB_TRANSACTIONS2 ON ARPB_TRANSACTIONS.TX_ID=ARPB_TRANSACTIONS2.TX_ID
 LEFT OUTER JOIN (select fin_div_id,fin_div_nm from FIN_DIV) FIN_DIV ON ARPB_TRANSACTIONS2.FIN_DIV_ID=FIN_DIV.FIN_DIV_ID
 LEFT OUTER JOIN (select fin_subdiv_id,fin_subdiv_nm from FIN_SUBDIV) FIN_SUBDIV ON ARPB_TRANSACTIONS2.FIN_SUBDIV_ID=FIN_SUBDIV.FIN_SUBDIV_ID
 LEFT OUTER JOIN (select bill_area_id,record_name from BILL_AREA) BILL_AREA ON ARPB_TRANSACTIONS.BILL_AREA_ID=BILL_AREA.BILL_AREA_ID
 LEFT OUTER JOIN ARPB_TX_MODERATE ARPB_TX_MODERATE ON ARPB_TX_MODERATE.TX_ID=ARPB_TRANSACTIONS.TX_ID /*need this to get TAR id to link to CR view */
 LEFT OUTER JOIN V_ARPB_CHG_REVIEW_WQ V_ARPB_CHG_REVIEW_WQ ON ARPB_TX_MODERATE.SOURCE_TAR_ID=V_ARPB_CHG_REVIEW_WQ.TAR_ID
 LEFT OUTER JOIN CLARITY_UCL CLARITY_UCL ON ARPB_TRANSACTIONS.CHG_ROUTER_SRC_ID=CLARITY_UCL.UCL_ID
 LEFT OUTER JOIN ZC_CHG_SOURCE_UCL ZC_CHG_SOURCE_UCL ON CLARITY_UCL.CHARGE_SOURCE_C=ZC_CHG_SOURCE_UCL.chg_source_ucl_c
 LEFT OUTER JOIN ZC_CHRG_SOURCE_TAR ZC_CHRG_SOURCE_TAR ON V_ARPB_CHG_REVIEW_WQ.SOURCE_C=ZC_CHRG_SOURCE_TAR.CHARGE_SOURCE_C
 LEFT OUTER JOIN DATE_DIMENSION dt on dt.CALENDAR_DT=ARPB_TRANSACTIONS.POST_DATE
 LEFT OUTER JOIN DATE_DIMENSION dts on dts.CALENDAR_DT=ARPB_TRANSACTIONS.SERVICE_DATE
LEFT OUTER JOIN ARPB_TX_VOID ARPB_TX_VOID ON ARPB_TX_VOID.TX_ID=ARPB_TRANSACTIONS.TX_ID
 
WHERE  ARPB_TRANSACTIONS.TX_TYPE_C=1 
and (ARPB_TX_VOID.OLD_ETR_ID IS NULL and ARPB_TX_VOID.REPOSTED_ETR_ID IS NULL and ARPB_TX_VOID.REPOST_TYPE_C IS NULL and ARPB_TX_VOID.RETRO_CHARGE_ID IS NULL)
--and '{?Service or Post Date}'='Service Date'
--and ARPB_TRANSACTIONS.SERVICE_DATE between EPIC_UTIL.EFN_DIN('{?StartDate}') AND EPIC_UTIL.EFN_DIN('{?EndDate}')
and
("ARPB_TRANSACTIONS"."SERVICE_AREA_ID" <30) and
("ARPB_TRANSACTIONS"."SERVICE_DATE">={ts '2015-04-01 00:00:00'} AND 
               "ARPB_TRANSACTIONS"."SERVICE_DATE"<={ts '2015-04-30 00:00:00'})

 GROUP BY (case
                     when "CLARITY_LOC"."LOC_ID" = '11106' then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end)
) as "Review",



(  SELECT 
		case
                     when "CLARITY_DEP"."REV_LOC_ID" = '11106' then 'Springfield Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18121' then 'Defiance Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end as "Market", 

		sum(1) as "Total Encounter",

		sum(case when "ZC_REG_STATUS"."NAME"='Verified' then 1 end) as "Verified"



 FROM   ((((("Clarity"."dbo"."PAT_ENC" "PAT_ENC" INNER JOIN "Clarity"."dbo"."PAT_ENC_2" "PAT_ENC_2" ON ("PAT_ENC"."PAT_ENC_CSN_ID"="PAT_ENC_2"."PAT_ENC_CSN_ID") AND ("PAT_ENC"."CONTACT_DATE"="PAT_ENC_2"."CONTACT_DATE")) 
												 INNER JOIN "Clarity"."dbo"."ZC_APPT_STATUS" "ZC_APPT_STATUS" ON "PAT_ENC"."APPT_STATUS_C"="ZC_APPT_STATUS"."APPT_STATUS_C") 
												 LEFT OUTER JOIN "Clarity"."dbo"."PATIENT" "PATIENT" ON "PAT_ENC"."PAT_ID"="PATIENT"."PAT_ID") 
												 LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" "CLARITY_DEP" ON "PAT_ENC"."DEPARTMENT_ID"="CLARITY_DEP"."DEPARTMENT_ID") 
												 LEFT OUTER JOIN "Clarity"."dbo"."VERIFICATION" "VERIFICATION" ON "PAT_ENC_2"."ENC_VERIFICATION_ID"="VERIFICATION"."RECORD_ID") 
												 LEFT OUTER JOIN "Clarity"."dbo"."ZC_REG_STATUS" "ZC_REG_STATUS" ON "VERIFICATION"."VERIF_STATUS_C"="ZC_REG_STATUS"."REG_STATUS_C"
 
 WHERE  ("CLARITY_DEP"."REV_LOC_ID"=11101 OR "CLARITY_DEP"."REV_LOC_ID"=11102 OR "CLARITY_DEP"."REV_LOC_ID"=11103 OR "CLARITY_DEP"."REV_LOC_ID"=11104 OR "CLARITY_DEP"."REV_LOC_ID"=11105 OR "CLARITY_DEP"."REV_LOC_ID"=11106 OR "CLARITY_DEP"."REV_LOC_ID"=11124 OR "CLARITY_DEP"."REV_LOC_ID"=11132 OR "CLARITY_DEP"."REV_LOC_ID"=11138 OR "CLARITY_DEP"."REV_LOC_ID"=13104 OR "CLARITY_DEP"."REV_LOC_ID"=13105 OR "CLARITY_DEP"."REV_LOC_ID"=16102 OR "CLARITY_DEP"."REV_LOC_ID"=16103 OR "CLARITY_DEP"."REV_LOC_ID"=17105 OR "CLARITY_DEP"."REV_LOC_ID"=17106 OR "CLARITY_DEP"."REV_LOC_ID"=17110 OR "CLARITY_DEP"."REV_LOC_ID"=18101 OR "CLARITY_DEP"."REV_LOC_ID"=18102 OR "CLARITY_DEP"."REV_LOC_ID"=18103 OR "CLARITY_DEP"."REV_LOC_ID"=18104 OR "CLARITY_DEP"."REV_LOC_ID"=18105 OR "CLARITY_DEP"."REV_LOC_ID"=18120 OR "CLARITY_DEP"."REV_LOC_ID"=18121 OR "CLARITY_DEP"."REV_LOC_ID"=19101 OR "CLARITY_DEP"."REV_LOC_ID"=19102 OR "CLARITY_DEP"."REV_LOC_ID"=19105 OR "CLARITY_DEP"."REV_LOC_ID"=19106 OR "CLARITY_DEP"."REV_LOC_ID"=19107 OR "CLARITY_DEP"."REV_LOC_ID"=19108 OR "CLARITY_DEP"."REV_LOC_ID"=21101 OR "CLARITY_DEP"."REV_LOC_ID"=21102 OR "CLARITY_DEP"."REV_LOC_ID"=21103 OR "CLARITY_DEP"."REV_LOC_ID"=21104 OR "CLARITY_DEP"."REV_LOC_ID"=11114111) AND ("PAT_ENC"."SERV_AREA_ID"=11 OR "PAT_ENC"."SERV_AREA_ID"=13 OR "PAT_ENC"."SERV_AREA_ID"=16 OR "PAT_ENC"."SERV_AREA_ID"=17 OR "PAT_ENC"."SERV_AREA_ID"=18 OR "PAT_ENC"."SERV_AREA_ID"=19 OR "PAT_ENC"."SERV_AREA_ID"=20 OR "PAT_ENC"."SERV_AREA_ID"=21) AND ("PAT_ENC"."APPT_STATUS_C"=2 OR "PAT_ENC"."APPT_STATUS_C"=6) AND 
		("PAT_ENC"."CONTACT_DATE">={ts '2015-04-01 00:00:00'} AND 
		 "PAT_ENC"."CONTACT_DATE"<={ts '2015-04-30 00:00:01'}) AND 
		("PAT_ENC"."ENC_TYPE_C"='1000' OR "PAT_ENC"."ENC_TYPE_C"='1001' OR "PAT_ENC"."ENC_TYPE_C"='1003' OR "PAT_ENC"."ENC_TYPE_C"='101' OR "PAT_ENC"."ENC_TYPE_C"='108' OR "PAT_ENC"."ENC_TYPE_C"='11' OR "PAT_ENC"."ENC_TYPE_C"='1200' OR "PAT_ENC"."ENC_TYPE_C"='1201' OR "PAT_ENC"."ENC_TYPE_C"='121' OR "PAT_ENC"."ENC_TYPE_C"='1214' OR "PAT_ENC"."ENC_TYPE_C"='2' OR "PAT_ENC"."ENC_TYPE_C"='201' OR "PAT_ENC"."ENC_TYPE_C"='21005' OR "PAT_ENC"."ENC_TYPE_C"='210177' OR "PAT_ENC"."ENC_TYPE_C"='2102' OR "PAT_ENC"."ENC_TYPE_C"='2501' OR "PAT_ENC"."ENC_TYPE_C"='2502' OR "PAT_ENC"."ENC_TYPE_C"='283' OR "PAT_ENC"."ENC_TYPE_C"='49' OR "PAT_ENC"."ENC_TYPE_C"='50' OR "PAT_ENC"."ENC_TYPE_C"='51' OR "PAT_ENC"."ENC_TYPE_C"='81')
 
-- ORDER BY "PAT_ENC"."SERV_AREA_ID", "CLARITY_DEP"."REV_LOC_ID", "PATIENT"."PAT_MRN_ID"

GROUP BY 
		 Case
                     when "CLARITY_DEP"."REV_LOC_ID" = '11106' then 'Springfield Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '11' then 'Cincinnati Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '13' then 'Youngstown Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18121' then 'Defiance Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '19' then 'Kentucky Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end

) as "Ver"


where main.market = sub.market and main.market = copay.market and main.market = ENC.market and main.market = Lag.market  and main.market = Ver.market  and main.market = Review.market

