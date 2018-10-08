SELECT "CLARITY_LOC"."GL_PREFIX"+' - '+"CLARITY_LOC"."LOC_NAME" as 'Location ID',
            "CLARITY_SA"."GL_PREFIX"+'-'+"CLARITY_DEP"."GL_PREFIX"+''+"CLARITY_DEP"."DEPARTMENT_NAME" as 'Full GL Dept',
            "CLARITY_DEP"."DEPARTMENT_NAME",
            Case When left("ZC_FINANCIAL_CLASS"."Name",6)='Worker' then 'Other'
            --"CLARITY_TDL_TRAN"."ORIGINAL_FIN_CLASS" is null then '*** NO ORIG FC ***'
            --    else When "ZC_FINANCIAL_CLASS"."FINANCIAL_CLASS" then '*** UNKNOWN FC ***'
            --    else When left("ZC_FINANCIAL_CLASS"."Name",6)='Worker' then 'Other'
            else "ZC_FINANCIAL_CLASS"."NAME"
            end AS 'Orig FC',
            '',
--          "ARPB_TRANSACTIONS"."SERVICE_DATE",
--          CONVERT(VARCHAR(7), "ARPB_TRANSACTIONS"."SERVICE_DATE", 120) AS [YYYY-MM],
            sum(Case When ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 1 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 3)
                  Then "ARPB_TRANSACTIONS"."AMOUNT"
                  Else 0
            End) as "Current Charge",
            sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 5 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 20 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 22)
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End) as "Matched Payments",
            sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'CONTRA'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End) as "Matched Contractuals",
            (sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'CONTRA'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End)/sum(Case When ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 1 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 3)
                  Then "ARPB_TRANSACTIONS"."AMOUNT"
                  Else 0
            End))*-100 as 'CA %',
            sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'BAD'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End) as "Matched Bad Debt",
            (sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'BAD'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End)/sum(Case When ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 1 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 3)
                  Then "ARPB_TRANSACTIONS"."AMOUNT"
                  Else 0
            End))*-100 as 'BD %',
            sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'CHARITY'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End) as "Matched Charity",
            (sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'CHARITY'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End)/sum(Case When ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 1 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 3)
                  Then "ARPB_TRANSACTIONS"."AMOUNT"
                  Else 0
            End))*-100 as 'Charity %',
            sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'ADMIN'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End) as "Matched Admin",
            (sum(Case when ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 6 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 21 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 23) and
                                 "CLARITY_EAP_MATCH"."GL_NUM_DEBIT" = 'ADMIN'
                  Then "CLARITY_TDL_TRAN_MATCH"."AMOUNT"
                  Else 0
            End)/sum(Case When ("CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 1 or 
                                 "CLARITY_TDL_TRAN_MATCH"."DETAIL_TYPE" = 3)
                  Then "ARPB_TRANSACTIONS"."AMOUNT"
                  Else 0
            End))*-100 as 'Admin %',
            SUM("ARPB_TRANSACTIONS"."OUTSTANDING_AMT") as 'Outstanding Balance'


FROM   (((((((("Clarity"."dbo"."CLARITY_TDL_TRAN" "CLARITY_TDL_TRAN" 
            INNER JOIN "Clarity"."dbo"."CLARITY_TDL_TRAN" "CLARITY_TDL_TRAN_MATCH" ON "CLARITY_TDL_TRAN"."TX_ID"="CLARITY_TDL_TRAN_MATCH"."TX_ID") 
            LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_LOC" "CLARITY_LOC" ON "CLARITY_TDL_TRAN"."LOC_ID"="CLARITY_LOC"."LOC_ID") 
            LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" "CLARITY_DEP" ON "CLARITY_TDL_TRAN"."DEPT_ID"="CLARITY_DEP"."DEPARTMENT_ID") 
            LEFT OUTER JOIN "Clarity"."dbo"."ARPB_TRANSACTIONS" "ARPB_TRANSACTIONS" ON "CLARITY_TDL_TRAN"."TX_ID"="ARPB_TRANSACTIONS"."TX_ID") 
            LEFT OUTER JOIN "Clarity"."dbo"."ZC_FINANCIAL_CLASS" "ZC_FINANCIAL_CLASS" ON "CLARITY_TDL_TRAN"."ORIGINAL_FIN_CLASS"="ZC_FINANCIAL_CLASS"."FINANCIAL_CLASS") 
            LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SA" "CLARITY_SA" ON "CLARITY_TDL_TRAN"."SERV_AREA_ID"="CLARITY_SA"."SERV_AREA_ID") 
            LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_EAP" "CLARITY_EAP_MATCH" ON "CLARITY_TDL_TRAN_MATCH"."MATCH_PROC_ID"="CLARITY_EAP_MATCH"."PROC_ID")
            INNER JOIN "Clarity"."dbo"."DATE_DIMENSION" "DATE_DIMENSION" ON "ARPB_TRANSACTIONS"."SERVICE_DATE"="DATE_DIMENSION"."CALENDAR_DT")  
 WHERE  ("ARPB_TRANSACTIONS"."SERVICE_DATE">= '01/01/2014' AND "ARPB_TRANSACTIONS"."SERVICE_DATE"< '9/1/2014') AND
            "ARPB_TRANSACTIONS"."DEBIT_CREDIT_FLAG"=1 AND 
             "ARPB_TRANSACTIONS"."AMOUNT">0 AND 
             "ARPB_TRANSACTIONS"."VOID_DATE" IS  NULL  AND
            "ARPB_TRANSACTIONS"."OUTSTANDING_AMT"=0 AND 
             "CLARITY_TDL_TRAN"."DETAIL_TYPE"=1 AND 
             "ARPB_TRANSACTIONS"."SERVICE_AREA_ID"=18 --and
            --year(GETDATE()) = year("DATE_DIMENSION"."YEAR_BEGIN_DT")
            
 GROUP BY "CLARITY_TDL_TRAN"."SERV_AREA_ID",
             "CLARITY_LOC"."GL_PREFIX"+' - '+"CLARITY_LOC"."LOC_NAME",
             "CLARITY_SA"."GL_PREFIX"+'-'+"CLARITY_DEP"."GL_PREFIX"+''+"CLARITY_DEP"."DEPARTMENT_NAME",
             "CLARITY_DEP"."DEPARTMENT_NAME",
              "ZC_FINANCIAL_CLASS"."NAME"

ORDER BY "CLARITY_TDL_TRAN"."SERV_AREA_ID",
             "CLARITY_LOC"."GL_PREFIX"+' - '+"CLARITY_LOC"."LOC_NAME",
             "CLARITY_SA"."GL_PREFIX"+'-'+"CLARITY_DEP"."GL_PREFIX"+''+"CLARITY_DEP"."DEPARTMENT_NAME",
             "CLARITY_DEP"."DEPARTMENT_NAME",
              "ZC_FINANCIAL_CLASS"."NAME"
