WITH first_entry_date AS (SELECT        TAR_ID, MIN(ACTIVITY_DATE) AS activity_date
                                                         FROM            dbo.PRE_AR_CHG_HX
                                                         WHERE        (ACTIVITY_C = 101)
                                                         GROUP BY TAR_ID)
    SELECT        tdl.TDL_ID, tdl.DETAIL_TYPE, tdl.TYPE, tdl.POST_DATE, tdl.ORIG_POST_DATE AS ORIGINAL_POST_DATE, tdl.ORIG_SERVICE_DATE AS SERVICE_DATE, 
                              tdl.TX_ID AS TRANSACTION_ID, tran_type.NAME AS TRANSACTION_TYPE, tdl.TYPE_OF_SERVICE, COALESCE (tdl.ACCOUNT_ID, - 1) AS ACCOUNT_ID, 
                              COALESCE (tdl.INT_PAT_ID, '-1') AS PATIENT_ID, COALESCE (tdl.CUR_PLAN_ID, - 1) AS CURRENT_BENEFIT_PLAN_ID, CASE WHEN (tdl.detail_type IN (1, 10, 20, 
                              21) OR
                              tdl.[ORIGINAL_PAYOR_ID] IS NULL) THEN COALESCE (tdl.[ORIGINAL_PLAN_ID], - 2) ELSE COALESCE (tdl.[ORIGINAL_PLAN_ID], - 1) 
                              END AS ORIGINAL_BENEFIT_PLAN_ID, COALESCE (tdl.PERFORMING_PROV_ID, '-1') AS SERVICE_PROVIDER_ID, COALESCE (tdl.BILLING_PROVIDER_ID, '-1') 
                              AS BILLING_PROVIDER_ID, CASE WHEN tdl.detail_type IN (1, 10, 20, 21) THEN COALESCE (tdl.[PROC_ID], - 1) ELSE - 3 END AS PROCEDURE_ID, 
                              COALESCE (tdl.DX_ONE_ID, - 1) AS PRIMARY_DIAGNOSIS_ID, COALESCE (tdl.DEPT_ID, - 1) AS DEPARTMENT_ID, COALESCE (tdl.LOC_ID, - 2) AS LOCATION_ID, 
                              COALESCE (tdl.POS_ID, - 3) AS PLACE_OF_SERVICE_ID, COALESCE (tdl.BILL_AREA_ID, - 1) AS BILL_AREA_ID, COALESCE (ucl.CHARGE_SOURCE_C, '8') 
                              AS CHARGE_SOURCE, tdl.MATCH_TRX_ID AS MATCH_TRANSACTION_ID, tdl.MATCH_TX_TYPE AS MATCH_TRANSACTION_TYPE, COALESCE (tdl.MATCH_LOC_ID, 
                              - 2) AS MATCH_LOCATION_ID, CASE WHEN tdl.detail_type IN (20, 21, 22, 23) THEN COALESCE (tdl.[MATCH_PAYOR_ID], - 1) 
                              ELSE COALESCE (tdl.ORIGINAL_PAYOR_ID, - 1) END AS MATCH_PAYOR_ID, CASE WHEN tdl.DETAIL_TYPE IN (2, 5, 11, 32, 33) THEN COALESCE (tdl.PROC_ID, - 1) 
                              WHEN tdl.DETAIL_TYPE IN (20, 22) AND (reversal_check.IS_REVERSED_C IS NULL AND arpb2_match.REVERSED_PMT_TX_ID IS NULL) 
                              THEN COALESCE (tdl.MATCH_PROC_ID, - 1) WHEN tdl.DETAIL_TYPE IN (20, 22) AND (reversal_check.IS_REVERSED_C IS NULL AND 
                              arpb2_match.REVERSED_PMT_TX_ID IS NOT NULL) THEN COALESCE (tdl.PROC_ID, - 1) WHEN tdl.DETAIL_TYPE IN (20, 22) AND 
                              (reversal_check.IS_REVERSED_C IS NOT NULL) THEN COALESCE (tdl.PROC_ID, - 1) ELSE - 2 END AS MATCH_PROCEDURE_ID, COALESCE (tdl.MATCH_PROV_ID, 
                              '-1') AS MATCH_PROVIDER_ID, tdl.ACTIVE_AR_AMOUNT AS AMOUNT, tdl.PATIENT_AMOUNT, tdl.INSURANCE_AMOUNT, CASE WHEN tdl.detail_type IN (1, 10) 
                              THEN tdl.[RELATIVE_VALUE_UNIT] ELSE 0 END AS RELATIVE_VALUE_UNIT, CASE WHEN tdl.detail_type IN (1, 10) 
                              THEN tdl.[RVU_WORK] * tdl.[PROCEDURE_QUANTITY] ELSE 0 END AS RVU_WORK, CASE WHEN tdl.detail_type IN (1, 10) 
                              THEN tdl.[RVU_OVERHEAD] * tdl.[PROCEDURE_QUANTITY] ELSE 0 END AS RVU_OVERHEAD, CASE WHEN tdl.detail_type IN (1, 10) 
                              THEN tdl.[RVU_MALPRACTICE] * tdl.[PROCEDURE_QUANTITY] ELSE 0 END AS RVU_MALPRACTICE, 
                              CASE WHEN tdl.DETAIL_TYPE = 1 THEN tdl.[RVU_PROC_UNITS] WHEN tdl.DETAIL_TYPE = 10 THEN tdl.[RVU_PROC_UNITS] * - 1 END AS RVU_PROC_UNITS, 
                              tdl.PROCEDURE_QUANTITY, CASE WHEN tdl.DETAIL_TYPE IN (1, 10) THEN CASE WHEN tdl.DETAIL_TYPE IN (1) 
                              THEN CASE WHEN CAST(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) 
                              < 0 THEN 0 ELSE CAST(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) END END WHEN tdl.DETAIL_TYPE IN (10) 
                              THEN CASE WHEN - CAST(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) 
                              < 0 THEN 0 ELSE - CAST(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) END END AS LAG_DAYS_SERVICE_TO_POST, NULL 
                              AS LAG_DAYS_SERVICE_TO_ENTRY, NULL AS LAG_DAYS_ENTRY_TO_POST, CASE WHEN tdl.detail_type IN (1) THEN COALESCE (tdl.ALLOWED_AMOUNT, 0) 
                              WHEN tdl.detail_type IN (10) THEN - 1 * COALESCE (tdl.ALLOWED_AMOUNT, 0) ELSE 0 END AS EXPECTED_AMOUNT, 0 AS ALLOWED_AMT, 
                              CASE WHEN tdl.DETAIL_TYPE IN (1) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS CHARGE_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (2, 5, 11, 20, 22, 32, 33) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS PAYMENT_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (5, 20, 22) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS MATCHED_PAYMENT_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (2, 11, 32, 33) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS UNDISTRIBUTED_PAYMENT_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (3, 4, 6, 12, 13, 21, 23, 30, 31) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS ADJUSTMENT_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (4, 6, 13, 21, 23, 30, 31) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS CREDIT_ADJUSTMENT_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (6, 21, 23) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS MATCH_CREDIT_ADJUSTMENT_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (4, 13, 30, 31) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS UNDIST_CREDIT_ADJUSTMENT_AMT, CASE WHEN tdl.DETAIL_TYPE IN (3, 12) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS DEBIT_ADJUSTMENT_AMOUNT, CASE WHEN tdl.detail_type IN (20, 21, 22, 23) 
                              THEN COALESCE (arpb_match.user_id, '-1') ELSE COALESCE (tdl.user_id, '-1') END AS USER_ID, COALESCE (tdl.CPT_CODE, 'Unspecified CPT Code') 
                              AS CPT_CODE, COALESCE (paysrc.NAME, 'Unspecified Payment Source') AS PAYMENT_SOURCE, COALESCE (ref.REF_PROVIDER_ID, '-1') 
                              AS REFERRAL_PROVIDER_ID, '' AS TDL_NAMECOLUMN, CASE WHEN tdl.DETAIL_TYPE IN (1, 10) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS NET_CHARGE_AMOUNT, CASE WHEN tdl.DETAIL_TYPE IN (10) 
                              THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END AS VOID_AMOUNT, tdl.TX_NUM AS TRANSACTION_NUMBER, 
                              CASE WHEN tdl.DETAIL_TYPE = 1 THEN 1 WHEN tdl.DETAIL_TYPE = 10 THEN - 1 ELSE 0 END AS CHARGE_COUNT, CASE WHEN TDL.DETAIL_TYPE IN (20, 21, 
                              22, 23) AND hx.AR_CLASS_C IN (3, 4) THEN TDL.ACTIVE_AR_AMOUNT ELSE 0 END AS ACTIVE_AR_IN_OUT, CASE WHEN TDL.DETAIL_TYPE IN (20, 22) 
                              THEN TDL.BAD_DEBT_AR_AMOUNT ELSE 0 END AS BAD_DEBT_PAYMENT, CASE WHEN TDL.DETAIL_TYPE IN (21, 23) AND (hx.AR_CLASS_C IS NULL OR
                              hx.AR_CLASS_C NOT IN (3, 4)) THEN TDL.BAD_DEBT_AR_AMOUNT ELSE 0 END AS BAD_DEBT_CREDIT_ADJUSTMENT, CASE WHEN TDL.DETAIL_TYPE IN (20, 
                              21, 22, 23) AND hx.AR_CLASS_C IN (3, 4) THEN TDL.BAD_DEBT_AR_AMOUNT ELSE 0 END AS BAD_DEBT_IN_OUT, CASE WHEN TDL.DETAIL_TYPE IN (20, 22) 
                              THEN TDL.EXTERNAL_AR_AMOUNT ELSE 0 END AS EXTERNAL_PAYMENT, CASE WHEN TDL.DETAIL_TYPE IN (21, 23) AND (hx.AR_CLASS_C IS NULL OR
                              hx.AR_CLASS_C NOT IN (3, 4)) THEN TDL.EXTERNAL_AR_AMOUNT ELSE 0 END AS EXTERNAL_CREDIT_ADJUSTMENT, CASE WHEN TDL.DETAIL_TYPE IN (20, 21, 
                              22, 23) AND hx.AR_CLASS_C IN (3, 4) THEN TDL.EXTERNAL_AR_AMOUNT ELSE 0 END AS EXTERNAL_AR_IN_OUT, CASE WHEN tdl.DETAIL_TYPE IN (1) AND 
                              (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) THEN CASE WHEN CAST(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) 
                              < 0 THEN 0 ELSE CAST(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) END END AS ORIGINAL_LAG_SERVICE_TO_POST, 
                              CASE WHEN tdl.DETAIL_TYPE IN (1) AND (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) 
                              THEN CASE WHEN CAST(fed.[ACTIVITY_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) 
                              < 0 THEN 0 ELSE CAST(fed.[ACTIVITY_DATE] - tdl.[ORIG_SERVICE_DATE] AS integer) END END AS ORIGINAL_LAG_SERVICE_TO_ENTRY, 
                              CASE WHEN tdl.DETAIL_TYPE IN (1) AND (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) 
                              THEN CASE WHEN CAST(tdl.[ORIG_POST_DATE] - fed.[ACTIVITY_DATE] AS integer) < 0 THEN 0 ELSE CAST(tdl.[ORIG_POST_DATE] - fed.[ACTIVITY_DATE] AS integer)
                               END END AS ORIGINAL_LAG_ENTRY_TO_POST, CASE WHEN tdl.DETAIL_TYPE = 1 AND (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) 
                              THEN 1 ELSE 0 END AS ORIGINAL_LAG_CHARGE_COUNT, COALESCE (tdl.ORIGINAL_PAYOR_ID, - 2) AS ORIGINAL_PAYOR_ID, CASE WHEN tdl.detail_type IN (20, 
                              21, 22, 23) THEN COALESCE (arpb_match.department_id, - 1) ELSE COALESCE (tdl.dept_id, - 1) END AS CREDIT_DEPARTMENT_ID, 
                              - 1.00 AS CREDIT_BENEFIT_PLAN_ID, CASE WHEN tdl.DETAIL_TYPE IN (4, 6, 13, 30, 31) THEN tdl.PROC_ID WHEN tdl.DETAIL_TYPE IN (21, 23) AND 
                              reversal_check.IS_REVERSED_C IS NULL THEN tdl.MATCH_PROC_ID WHEN tdl.DETAIL_TYPE IN (21, 23) AND reversal_check.IS_REVERSED_C IS NOT NULL 
                              THEN tdl.PROC_ID ELSE - 4 END AS CREDIT_ADJUSTMENT_PROCEDURE_ID, 
                              CASE WHEN tdl.detail_type = 1 THEN 'New Charge [1]' WHEN tdl.detail_type = 2 THEN 'New Payment [2]' WHEN tdl.detail_type = 3 THEN 'New Debit Adjustment [3]'
                               WHEN tdl.detail_type = 4 THEN 'New Credit Adjustment [4]' WHEN tdl.detail_type = 5 THEN 'Payment Reversal [5]' WHEN tdl.detail_type = 6 THEN 'Credit Adjustment Reversal [6]'
                               WHEN tdl.detail_type = 10 THEN 'Voided Charge [10]' WHEN tdl.detail_type = 11 THEN 'Voided Payment [11]' WHEN tdl.detail_type = 12 THEN 'Voided Debit Adjustment [12]'
                               WHEN tdl.detail_type = 13 THEN 'Voided Credit Adjustment [13]' WHEN tdl.detail_type = 20 THEN 'Match/Unmatch (Charge -> Payment) [20]' WHEN tdl.detail_type =
                               21 THEN 'Match/Unmatch (Charge -> Credit Adjustment) [21]' WHEN tdl.detail_type = 22 THEN 'Match/Unmatch (Debit Adjustment -> Payment) [22]' WHEN tdl.detail_type
                               = 23 THEN 'Match/Unmatch (Debit Adjustment -> Credit Adjustment) [23]' WHEN tdl.detail_type = 30 THEN 'Match/Unmatch (Credit Adjustment -> Charge) [30]' WHEN
                               tdl.detail_type = 31 THEN 'Match/Unmatch (Credit Adjustment -> Debit Adjustment) [31]' WHEN tdl.detail_type = 32 THEN 'Match/Unmatch (Payment -> Charge) [32]' WHEN
                               tdl.detail_type = 33 THEN 'Match/Unmatch (Payment -> Debit Adjustment) [33]' END AS DETAIL_TYPE_NAME, CASE WHEN tdl.detail_type IN (1, 3, 4) 
                              THEN 'Post' WHEN tdl.detail_type IN (2) AND tx2.REVERSED_PMT_TX_ID IS NULL THEN 'Post' WHEN tdl.detail_type IN (2) AND 
                              tx2.REVERSED_PMT_TX_ID IS NOT NULL THEN 'Void/Reversal' WHEN tdl.detail_type IN (5, 6, 10, 11, 12, 13) THEN 'Void/Reversal' WHEN tdl.detail_type IN (20, 
                              21, 22, 23) THEN 'Distribution - Service' WHEN tdl.detail_type IN (30, 31, 32, 33) THEN 'Distribution - Undistributed' END AS TYPE_NAME, 
                              CASE WHEN tdl.detail_type IN (3, 12, 22, 23) THEN COALESCE (tdl.proc_id, - 1) ELSE - 5 END AS DEBIT_ADJUSTMENT_PROCEDURE_ID, 
                              CASE WHEN tdl.detail_type IN (20, 21, 22, 23) THEN COALESCE (arpb_match.loc_id, - 2) ELSE COALESCE (tdl.loc_id, - 2) END AS CREDIT_LOCATION_ID
     FROM            dbo.CLARITY_TDL_TRAN AS tdl LEFT OUTER JOIN
                              dbo.ARPB_TRANSACTIONS AS tx ON tdl.TX_ID = tx.TX_ID LEFT OUTER JOIN
                              dbo.CLARITY_UCL AS ucl ON tx.CHG_ROUTER_SRC_ID = ucl.UCL_ID LEFT OUTER JOIN
                              dbo.ARPB_TX_MODERATE AS moderate ON tdl.TX_ID = moderate.TX_ID LEFT OUTER JOIN
                              dbo.ARPB_AGING_HISTORY AS hx ON hx.TX_ID = tdl.MATCH_TRX_ID AND tdl.POST_DATE >= hx.SNAP_START_DATE AND 
                              tdl.POST_DATE <= hx.SNAP_END_DATE LEFT OUTER JOIN
                              dbo.ARPB_TX_VOID AS void ON tdl.TX_ID = void.TX_ID LEFT OUTER JOIN
                              first_entry_date AS fed ON fed.TAR_ID = moderate.ORIGINATING_TAR_ID LEFT OUTER JOIN
                              dbo.ZC_PAYMENT_SOURCE AS paysrc ON tdl.PAYMENT_SOURCE_C = paysrc.PAYMENT_SOURCE_C LEFT OUTER JOIN
                              dbo.ARPB_TRANSACTIONS AS arpb_match ON tdl.MATCH_TRX_ID = arpb_match.TX_ID LEFT OUTER JOIN
                              dbo.ZC_TRAN_TYPE AS tran_type ON tdl.TRAN_TYPE = tran_type.TRAN_TYPE LEFT OUTER JOIN
                              dbo.ARPB_TRANSACTIONS2 AS tx2 ON tdl.TX_ID = tx2.TX_ID LEFT OUTER JOIN
                              dbo.ARPB_TRANSACTIONS2 AS arpb2_match ON arpb2_match.TX_ID = tdl.MATCH_TRX_ID LEFT OUTER JOIN
                              dbo.ARPB_TX_MATCH_HX AS match_hx ON tdl.TX_ID = match_hx.TX_ID AND tdl.MATCH_TRX_ID = match_hx.MTCH_TX_HX_ID AND 
                              match_hx.MTCH_TX_HX_UN_DT IS NULL AND tdl.ACTION_MATCH_LINE = match_hx.LINE LEFT OUTER JOIN
                              dbo.ARPB_TX_VOID AS reversal_check ON match_hx.MTCH_TX_HX_ID = reversal_check.TX_ID LEFT OUTER JOIN
                              dbo.REFERRAL_SOURCE AS ref ON ref.REFERRING_PROV_ID = tdl.REFERRAL_SOURCE_ID
     WHERE        (tdl.DETAIL_TYPE < 39) AND (tdl.TRAN_TYPE <= 3) AND (tdl.POST_DATE >= '2014-01-01')