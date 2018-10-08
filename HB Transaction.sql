SELECT        htr.TX_ID AS TRANSACTION_ID, htr.HSP_ACCOUNT_ID AS HAR_ID, COALESCE (htr.BUCKET_ID, - 1) AS BUCKET_ID, COALESCE (htr.PROC_ID, - 1) 
                         AS PROCEDURE_ID, COALESCE (htr.REVENUE_LOC_ID, htr.SERV_AREA_ID, - 2) AS LOCATION_ID, COALESCE (htr.DEPARTMENT, - 1) AS DEPARTMENT_ID, 
                         CASE WHEN htr.tx_type_ha_c = 1 THEN COALESCE (htr.primary_plan_id, - 2) WHEN hlb.bkt_type_ha_c = 8 THEN COALESCE (htr2.plan_id, - 3) 
                         ELSE COALESCE (hlb.benefit_plan_id, - 2) END AS PLAN_ID, CASE WHEN htr.tx_type_ha_c = 1 THEN COALESCE (htr.primary_plan_id, - 2) 
                         ELSE COALESCE (harsnap.primary_plan_id, - 2) END AS PRIMARY_PLAN_ID, COALESCE (htr.BILLING_PROV_ID, '-1') AS BILLING_PROVIDER_ID, 
                         COALESCE (htr.PERFORMING_PROV_ID, '-1') AS SERVICE_PROVIDER_ID, COALESCE (htr.USER_ID, '-1') AS POSTING_USER_ID, COALESCE (htr.PAT_ENC_CSN_ID, 
                         - 1) AS PAT_ENC_CSN_ID, CASE WHEN htr.tx_type_ha_c <> 1 THEN - 2 ELSE COALESCE (htr.erx_id, - 1) END AS MEDICATION_ID, 
                         CASE WHEN htr.tx_type_ha_c <> 1 THEN '-2' ELSE COALESCE (htr.sup_id, '-1') END AS SUPPLY_ID, 
                         CASE WHEN htr.tx_type_ha_c <> 1 THEN '-2' ELSE COALESCE (htr.implant_id, '-1') END AS IMPLANT_ID, htr.TX_POST_DATE AS TRANSACTION_POST_DATE, 
                         htr.SERVICE_DATE, COALESCE (txtype.NAME, 'Unspecified Transaction Type') AS TRANSACTION_TYPE, 
                         CASE WHEN map.base_class_map_c = 1 THEN 'IP' ELSE 'OP' END AS IP_OP, COALESCE (cls.NAME, 'Unspecified Account Class') AS ACCOUNT_CLASS, 
                         COALESCE (base.NAME, 'Unspecified Account Base Class') AS ACCOUNT_BASE_CLASS, COALESCE (src.NAME, 'Unspecified Transaction Source') 
                         AS TRANSACTION_SOURCE, CASE WHEN htr.extern_ar_flag_yn = 'Y' THEN 'External Agency AR' WHEN (htr.bad_debt_flag_yn = 'Y' OR
                         hlb.bkt_type_ha_c = 5) THEN 'Bad Debt' ELSE 'Active AR' END AS COLLECTION_STATUS, CASE WHEN htr.collection_agency IS NULL 
                         THEN 'No Collection Agency Assigned' ELSE COALESCE (agncy.coll_agency_name, 'Unknown Collection Agency') END AS COLLECTION_AGENCY, 
                         COALESCE (htr.GL_CREDIT_NUM, 'Unspecified GL Credit Number') AS GL_CREDIT_NUMBER, COALESCE (htr.GL_DEBIT_NUM, 'Unspecified GL Debit Number') 
                         AS GL_DEBIT_NUMBER, CASE WHEN htr.tx_type_ha_c <> 1 THEN 'Non-charge Transaction' ELSE COALESCE (bcc.cost_center_name + ' [' + bcc.cost_center_code + ']',
                          'Unspecified Cost Center') END AS COST_CENTER, 
                         CASE WHEN htr.tx_type_ha_c <> 1 THEN 'Non-charge Transaction' ELSE COALESCE (rate.cost_center_name + ' [' + rate.cost_center_code + ']', 
                         'Unspecified Rate Center') END AS RATE_CENTER, CASE WHEN htr.tx_type_ha_c <> 1 THEN 'Non-charge Transaction' ELSE COALESCE (UPPER(htr.hcpcs_code), 
                         UPPER(htr.cpt_code), 'Unspecified CPT/HCPCS Code') END AS CPT_HCPCS_CODE, 
                         CASE WHEN htr.tx_type_ha_c <> 1 THEN 'Non-charge Transaction' ELSE COALESCE (rev.revenue_code, 'Unspecified Revenue Code') END AS REVENUE_CODE, 
                         CASE WHEN htr.tx_type_ha_c <> 1 THEN 'Non-charge Transaction' ELSE COALESCE (rev.revenue_code + ' - ' + rev.revenue_code_name, 
                         'Unspecified Revenue Code') END AS REVENUE_CODE_DISPLAY_NAME, 
                         CASE WHEN htr.tx_type_ha_c <> 2 THEN 'Non-payment Transaction' ELSE COALESCE (pmtsrc.name, 'Unspecified Payment Source') END AS PAYMENT_SOURCE, 
                         CASE WHEN htr.is_refund_adj_yn = 'Y' THEN 'Yes' ELSE 'No' END AS IS_REFUND_ADJ_YN, 
                         CASE WHEN htr.is_system_adj_yn = 'Y' THEN 'Yes' ELSE 'No' END AS IS_SYSTEM_ADJ_YN, 
                         CASE WHEN htr.is_late_charge_yn = 'Y' THEN 'Yes' ELSE 'No' END AS IS_LATE_CHARGE_YN, 
                         CASE WHEN hlb.bkt_type_ha_c = 8 THEN 'Yes' ELSE 'No' END AS IS_UNDISTRIBUTED_PAYMENT_YN, COALESCE (htr.TX_AMOUNT, 0) AS TRANSACTION_AMOUNT, 
                         COALESCE (htr.QUANTITY, 0) AS TRANSACTION_QUANTITY, COALESCE (htr.RVU, 0) AS RVU_TOTAL, COALESCE (htr.RVU_MLPRACT, 0) AS RVU_MALPRACTICE, 
                         COALESCE (htr.RVU_OVERHEAD, 0) AS RVU_OVERHEAD, COALESCE (htr.RVU_WORK, 0) AS RVU_WORK, 
                         CASE WHEN htr.tx_type_ha_c = 1 THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS CHARGES, CASE WHEN htr.tx_type_ha_c = 2 THEN COALESCE (htr.tx_amount, 
                         0) ELSE 0 END AS PAYMENTS, CASE WHEN htr.tx_type_ha_c IN (3, 4) AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) 
                         ELSE 0 END AS ADJUSTMENTS, CASE WHEN htr.tx_type_ha_c = 4 AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) 
                         ELSE 0 END AS CREDIT_ADJUSTMENTS, CASE WHEN htr.tx_type_ha_c = 3 AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) 
                         ELSE 0 END AS DEBIT_ADJUSTMENTS, CASE WHEN htr.tx_type_ha_c = 2 AND hlb.bkt_type_ha_c NOT IN (1, 4, 5) THEN COALESCE (htr.tx_amount, 0) 
                         ELSE 0 END AS INSURANCE_PAYMENTS, CASE WHEN htr.tx_type_ha_c = 2 AND hlb.bkt_type_ha_c = 4 THEN COALESCE (htr.tx_amount, 0) 
                         ELSE 0 END AS PATIENT_PAYMENTS, CASE WHEN htr.tx_type_ha_c = 2 AND (hlb.bkt_type_ha_c = 5 OR
                         htr.bad_debt_flag_yn = 'Y') THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS BAD_DEBT_PAYMENTS, CASE WHEN htr.tx_type_ha_c = 2 AND 
                         hlb.bkt_type_ha_c = 8 THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS UNDISTRIBUTED_PAYMENTS, CASE WHEN htr.tx_type_ha_c IN (3, 4) AND 
                         htr.is_system_adj_yn IS NULL AND hlb.bkt_type_ha_c NOT IN (1, 4, 5) THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS INSURANCE_ADJUSTMENTS, 
                         CASE WHEN htr.tx_type_ha_c IN (3, 4) AND htr.is_system_adj_yn IS NULL AND hlb.bkt_type_ha_c = 4 AND (htr.bad_debt_flag_yn IS NULL OR
                         htr.bad_debt_flag_yn <> 'Y') THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS PATIENT_ADJUSTMENTS, CASE WHEN htr.tx_type_ha_c IN (3, 4) AND 
                         (hlb.bkt_type_ha_c = 5 OR
                         htr.bad_debt_flag_yn = 'Y') AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS BAD_DEBT_ADJUSTMENTS, 
                         CASE WHEN htr.tx_type_ha_c IN (3, 4) AND hlb.bkt_type_ha_c = 8 THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS UNDISTRIBUTED_ADJUSTMENTS, 
                         CASE WHEN htr.tx_type_ha_c IN (3, 4) AND htr.is_refund_adj_yn = 'Y' AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) 
                         ELSE 0 END AS REFUND_ADJUSTMENTS, CASE WHEN htr.tx_type_ha_c IN (3, 4) AND htr.is_refund_adj_yn = 'Y' AND htr.is_system_adj_yn IS NULL AND 
                         hlb.bkt_type_ha_c NOT IN (1, 4, 5) THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS INSURANCE_REFUND_ADJUSTMENTS, CASE WHEN htr.tx_type_ha_c IN (3, 4) 
                         AND htr.is_refund_adj_yn = 'Y' AND hlb.bkt_type_ha_c = 4 AND (htr.bad_debt_flag_yn IS NULL OR
                         htr.bad_debt_flag_yn <> 'Y') AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS PATIENT_REFUND_ADJUSTMENTS, 
                         CASE WHEN htr.tx_type_ha_c IN (3, 4) AND htr.is_refund_adj_yn = 'Y' AND (hlb.bkt_type_ha_c = 5 OR
                         htr.bad_debt_flag_yn = 'Y') AND htr.is_system_adj_yn IS NULL THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS BAD_DEBT_REFUND_ADJUSTMENTS, 
                         CASE WHEN (hlb.bkt_type_ha_c IS NULL OR
                         hlb.bkt_type_ha_c <> 5) AND htr.bad_debt_flag_yn IS NULL THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS AR_ACTIVITY, CASE WHEN (hlb.bkt_type_ha_c = 5 OR
                         htr.bad_debt_flag_yn = 'Y') THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS BAD_DEBT_ACTIVITY, CASE WHEN htr.is_system_adj_yn = 'Y' AND 
                         (hlb.bkt_type_ha_c = 5 OR
                         htr.bad_debt_flag_yn = 'Y') THEN COALESCE (htr.tx_amount, 0) ELSE 0 END AS BAD_DEBT_TRANSFERS, 
                         CASE WHEN htr.tx_type_ha_c = 1 THEN 1 ELSE 0 END AS CHARGE_COUNT, CASE WHEN htr.tx_type_ha_c = 1 AND htr.orig_repost_tx_id IS NULL AND 
                         htr.orig_rev_tx_id IS NULL AND htr.chg_cred_orig_id IS NULL AND htr.late_crctn_orig_id IS NULL THEN 1 ELSE 0 END AS ORIGINAL_CHARGE_COUNT, 
                         CASE WHEN htr.tx_type_ha_c = 1 THEN CASE WHEN datediff(d, htr.service_date, htr.tx_post_date) > 0 THEN datediff(d, htr.service_date, htr.tx_post_date) 
                         ELSE 0 END ELSE 0 END AS CHARGE_LAG_DAYS, CASE WHEN htr.tx_type_ha_c = 1 AND htr.orig_repost_tx_id IS NULL AND htr.orig_rev_tx_id IS NULL AND 
                         htr.chg_cred_orig_id IS NULL AND htr.late_crctn_orig_id IS NULL THEN CASE WHEN datediff(d, htr.service_date, htr.tx_post_date) > 0 THEN datediff(d, 
                         htr.service_date, htr.tx_post_date) ELSE 0 END ELSE 0 END AS ORIGINAL_CHARGE_LAG_DAYS, 
                         CASE WHEN htr.tx_type_ha_c = 2 THEN 1 ELSE 0 END AS PAYMENT_COUNT, CASE WHEN htr.tx_type_ha_c IN (3, 4) THEN 1 ELSE 0 END AS ADJUSTMENT_COUNT, 
                         CASE WHEN htr.tx_type_ha_c = 3 THEN 1 ELSE 0 END AS CREDIT_ADJUSTMENT_COUNT, 
                         CASE WHEN htr.tx_type_ha_c = 4 THEN 1 ELSE 0 END AS DEBIT_ADJUSTMENT_COUNT, CASE WHEN htr.tx_type_ha_c = 1 THEN COALESCE (epp.payor_id, - 2) 
                         WHEN hlb.bkt_type_ha_c = 8 THEN CASE WHEN htr.tx_type_ha_c = 2 THEN COALESCE (htr.payor_id, - 2) ELSE COALESCE (htr.payor_id, - 3) 
                         END ELSE COALESCE (hlb.payor_id, - 2) END AS PAYOR_ID, CASE WHEN htr.tx_type_ha_c = 1 THEN COALESCE (epp.payor_id, - 2) 
                         ELSE COALESCE (harsnap.primary_PAYOR_id, - 2) END AS PRIMARY_PAYOR_ID, COALESCE (dep.REV_LOC_ID, - 2) 
                         AS SERVICE_DEPARTMENT_LOCATION_ID
FROM            dbo.HSP_TRANSACTIONS AS htr INNER JOIN
                         dbo.HSP_TRANSACTIONS_2 AS htr2 ON htr.TX_ID = htr2.TX_ID LEFT OUTER JOIN
                         dbo.HSP_HAR_SNAPSHOT AS harsnap ON htr.HSP_ACCOUNT_ID = harsnap.HSP_ACCOUNT_ID AND harsnap.SNAP_START_DATE <= htr.TX_POST_DATE AND 
                         harsnap.SNAP_END_DATE >= htr.TX_POST_DATE LEFT OUTER JOIN
                         dbo.ZC_ACCT_CLASS_HA AS cls ON htr.ACCT_CLASS_HA_C = cls.ACCT_CLASS_HA_C LEFT OUTER JOIN
                         dbo.ZC_TX_TYPE_HA AS txtype ON htr.TX_TYPE_HA_C = txtype.TX_TYPE_HA_C LEFT OUTER JOIN
                         dbo.HSP_BUCKET AS hlb ON htr.BUCKET_ID = hlb.BUCKET_ID LEFT OUTER JOIN
                         dbo.ZC_TX_SOURCE_HA AS src ON htr.TX_SOURCE_HA_C = src.TX_SOURCE_HA_C LEFT OUTER JOIN
                         dbo.CL_COL_AGNCY AS agncy ON htr.COLLECTION_AGENCY = agncy.COL_AGNCY_ID LEFT OUTER JOIN
                         dbo.CL_COST_CNTR AS bcc ON htr.COST_CNTR_ID = bcc.COST_CNTR_ID LEFT OUTER JOIN
                         dbo.ZC_PAYMENT_SRC_HA AS pmtsrc ON htr.PAYMENT_SRC_HA_C = pmtsrc.PAYMENT_SRC_HA_C LEFT OUTER JOIN
                         dbo.HSD_BASE_CLASS_MAP AS map ON htr.ACCT_CLASS_HA_C = map.ACCT_CLASS_MAP_C LEFT OUTER JOIN
                         dbo.ZC_ACCT_BASECLS_HA AS base ON map.BASE_CLASS_MAP_C = base.ACCT_BASECLS_HA_C LEFT OUTER JOIN
                         dbo.CL_UB_REV_CODE AS rev ON htr.UB_REV_CODE_ID = rev.UB_REV_CODE_ID LEFT OUTER JOIN
                         dbo.CL_COST_CNTR AS rate ON htr2.RATE_CNTR_ID = rate.COST_CNTR_ID LEFT OUTER JOIN
                         dbo.CLARITY_EPP AS epp ON htr.PRIMARY_PLAN_ID = epp.BENEFIT_PLAN_ID LEFT OUTER JOIN
                         dbo.CLARITY_DEP AS dep ON htr.DEPARTMENT = dep.DEPARTMENT_ID
WHERE        (htr.TX_POST_DATE >= '2012-01-01')