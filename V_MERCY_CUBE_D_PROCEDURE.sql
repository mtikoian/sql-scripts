
SELECT
   eap.PROC_ID,
   eap.PROC_NAME,
   coalesce(eap.PROC_CODE,'Unspecified Procedure Code') as 'Procedure Code',
   coalesce(eap.PROC_CODE,'Unspecified Procedure Code') +  ' - ' + eap.PROC_NAME as 'Display Name',
   --eap.PROC_NAME + ' [' + coalesce(eap.PROC_CODE,'Unspecified Procedure Code') + ']',
   coalesce(edp.PROC_CAT_NAME,'Unspecified Procedure Category'),
   coalesce(typ.NAME,'Unspecified Procedure Type'),
   CASE
      WHEN eap.TYPE_C <> 1 THEN 'Non-charge Procedure'
      ELSE coalesce(cat.NAME,cat2.NAME,'Unspecified Billing Category')   
   END,
   CASE
      WHEN eap.TYPE_C <> 1 THEN 'Non-charge Procedure'
      ELSE coalesce(rev.revenue_code,'Unspecified Revenue Code')
   END,
   CASE
      WHEN eap.TYPE_C <> 3 THEN 'Non-adjustment Procedure'
      ELSE coalesce(adjcat.NAME,'Unspecified Adjustment Category')
   END,
   coalesce(deb.NAME,'Unspecified Debit or Credit'),
   coalesce(epg.PROC_GROUP_NAME,'Unspecified Procedure Group'),
   coalesce(spin.NAME,'Self-Pay')
FROM [CLARITY]..CLARITY_EAP eap
LEFT OUTER JOIN [CLARITY]..CLARITY_EAP_2 eap2 ON eap.PROC_ID = eap2.PROC_ID
LEFT OUTER JOIN [CLARITY]..EDP_PROC_CAT_INFO edp ON eap.PROC_CAT_ID = edp.PROC_CAT_ID
LEFT OUTER JOIN [CLARITY]..ZC_PROCEDURE_TYPE typ ON eap.TYPE_C = typ.PROC_TYPE
LEFT OUTER JOIN [CLARITY]..ZC_BILLING_CAT cat ON eap.BILLING_CAT_C = cat.BILLING_CAT_C
LEFT OUTER JOIN [CLARITY]..ZC_BILLING_CAT cat2 ON edp.BILLING_CAT_C = cat2.BILLING_CAT_C
LEFT OUTER JOIN [CLARITY]..CL_UB_REV_CODE rev ON eap.UB_REV_CODE_ID = rev.UB_REV_CODE_ID
LEFT OUTER JOIN [CLARITY]..ZC_ADJUSTMENT_CAT adjcat ON eap2.ADJUSTMENT_CAT_C = adjcat.ADJUSTMENT_CAT_C
LEFT OUTER JOIN [CLARITY]..ZC_DEBIT_OR_CREDIT deb ON eap.DEBIT_OR_CREDIT_C= deb.DEBIT_OR_CREDIT_C
LEFT OUTER JOIN [CLARITY]..CLARITY_EPG epg ON eap.PROC_GROUP_ID = epg.PROC_GROUP_ID
LEFT OUTER JOIN [CLARITY]..ZC_SELF_INS spin ON eap.SELF_INS_C = spin.SELF_INS_C
UNION ALL
SELECT
   -1,
   'Unspecified Procedure',
   'Unspecified Procedure Code',
   'Unspecified Procedure',
   'Unspecified Procedure Category',
   'Unspecified Procedure Type',
   'Unspecified Billing Category',
   'Unspecified Revenue Code',
   'Unspecified Adjustment Category',
   'Unspecified Debit or Credit',
   'Unspecified Procedure Group',
   'Unspecified Indicator'
UNION ALL
SELECT
   -2,
   'Non-payment Procedure',
   'Non-payment Procedure Code',
   'Non-payment Procedure',
   'Non-payment Procedure Category',
   'Non-payment Procedure Type',
   'Non-payment Billing Category',
   'Non-payment Revenue Code',
   'Non-payment Adjustment Category',
   'Non-payment Debit or Credit',
   'Non-payment Procedure Group',
   'Non-payment Indicator'
UNION ALL
SELECT
   -3,
   'Non-charge Procedure',
   'Non-charge Procedure Code',
   'Non-charge Procedure',
   'Non-charge Procedure Category',
   'Non-charge Procedure Type',
   'Non-charge Procedure Billing Category',
   'Non-charge Procedure Revenue Code',
   'Non-charge Procedure Adjustment Category',
   'Non-charge Procedure Debit or Credit',
   'Non-charge Procedure Procedure Group',
   'Non-charge Indicator'
UNION ALL
SELECT
   -4,
   'Non-credit Adjustment Procedure',
   'Non-credit Adjustment Procedure Code',
   'Non-credit Adjustment Procedure',
   'Non-credit Adjustment Procedure Category',
   'Non-credit Adjustment Procedure Type',
   'Non-credit Adjustment Procedure Billing Category',
   'Non-credit Adjustment Procedure Revenue Code',
   'Non-credit Adjustment Procedure Adjustment Category',
   'Non-credit Adjustment Procedure Debit or Credit',
   'Non-credit Adjustment Procedure Procedure Group',
   'Non-credit Adjustment Indicator'
UNION ALL
SELECT
   -5,
   'Non-debit Adjustment Procedure',
   'Non-debit Adjustment Procedure Code',
   'Non-debit Adjustment Procedure',
   'Non-debit Adjustment Procedure Category',
   'Non-debit Adjustment Procedure Type',
   'Non-debit Adjustment Procedure Billing Category',
   'Non-debit Adjustment Procedure Revenue Code',
   'Non-debit Adjustment Procedure Adjustment Category',
   'Non-debit Adjustment Procedure Debit or Credit',
   'Non-debit Adjustment Procedure Procedure Group',
   'Non-debit Adjustment Indicator'



GO


