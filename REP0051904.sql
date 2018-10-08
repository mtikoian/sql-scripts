SELECT '10' AS HSPCODE, CLARITY_EAP.PROC_CODE AS CDMNumber, replace(convert(varchar(10),CLARITY_REPORT.Eap_from_date.EFF_FROM_DATE,101),'/','')  AS ActiveDate, '' AS PayerCode, '' AS PatientType, 
                  '' AS DeptName, '' AS DeptNumber, CLARITY_EAP.PROC_NAME AS CodeDescription, CLARITY_REPORT.eap_ot_hc.CPT_CODE AS CPT, 
                  EPIC_UTIL.EFN_PIECE(CLARITY_EAP.MODIFIER, ',', 1) AS CPTMod1, EPIC_UTIL.EFN_PIECE(CLARITY_EAP.MODIFIER, ',', 2) AS CPTMod2, 
                  EPIC_UTIL.EFN_PIECE(CLARITY_EAP.MODIFIER, ',', 3) AS CPTMod3, EPIC_UTIL.EFN_PIECE(CLARITY_EAP.MODIFIER, ',', 4) AS CPTMod4, '1' AS Multiplier, 
                  CL_UB_REV_CODE.REVENUE_CODE AS RevCode, CLARITY_REPORT.FSC_unique.UNIT_CHARGE_AMOUNT AS Charge, 
                  CLARITY_REPORT.FSC_unique.FEE_SCHEDULE_ID
FROM     CLARITY_REPORT.FSC_unique INNER JOIN
                  CLARITY_EAP ON CLARITY_REPORT.FSC_unique.PROC_ID = CLARITY_EAP.PROC_ID LEFT OUTER JOIN
                  CL_UB_REV_CODE ON CLARITY_EAP.UB_REV_CODE_ID = CL_UB_REV_CODE.UB_REV_CODE_ID LEFT OUTER JOIN
                  CLARITY_REPORT.eap_ot_hc ON CLARITY_REPORT.FSC_unique.PROC_ID = CLARITY_REPORT.eap_ot_hc.PROC_ID LEFT OUTER JOIN
                  CLARITY_REPORT.Eap_from_date ON CLARITY_REPORT.FSC_unique.PROC_ID = CLARITY_REPORT.Eap_from_date.PROC_ID
WHERE  (CLARITY_REPORT.FSC_unique.Rank = 1) AND (CLARITY_REPORT.eap_ot_hc.Rank = 1 OR
                  CLARITY_REPORT.eap_ot_hc.Rank IS NULL)
				  order by fee_schedule_id,clarity_eap.proc_code