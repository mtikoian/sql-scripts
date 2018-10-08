declare		@ReportDateOption as varchar(max)
			,@StartDate as date
            ,@EndDate as date

-- change to Crystal parameters

set @ReportDateOption= '{?ReportDateOption}'
--set @ReportDateOption= 'Custom Date Range'

set @StartDate = case  when @ReportDateOption= 'Yesterday' then cast(dateadd(dd,-1,getdate()) as date)
					 when @ReportDateOption= 'EPSI' then cast(dateadd(dd,-1,getdate()) as date)
					  when @ReportDateOption= 'Custom Date Range' then  {?StartDate}
					    when @ReportDateOption= 'TU' then cast(DATEADD(m,-1, Dateadd(d,1-DATEPART(d,getdate()),GETDATE())) as date) 
					
					  when @ReportDateOption= 'Last Full Month' then cast(DATEADD(m,-1, Dateadd(d,1-DATEPART(d,getdate()),GETDATE())) as date) 
					  when @ReportDateOption= 'Last Full Week' then cast(dateadd(dd,0, datediff(dd,0, dateadd(day,-1*datepart(weekday,getdate())+1,dateadd(week,-1,getdate())))) as date)
					  --when @ReportDateOption= 'Custom Date Range' then '6/1/2012'--  {?StartDate}
					  end
set @EndDate = case  when @ReportDateOption= 'Yesterday' then cast(dateadd(dd,+1,getdate()) as date)
					   when @ReportDateOption= 'EPSI' then cast('12/31/2099' as date)
					 when @ReportDateOption= 'Custom Date Range' then {?EndDate}
					  when @ReportDateOption= 'TU' then  cast(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))+1 as date)
					 when @ReportDateOption= 'Last Full Month' then cast(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)) as date)
					  when @ReportDateOption= 'Last Full Week' then cast(dateadd(dd,0, datediff(dd,0,  dateadd(day,7,dateadd(day,-1*datepart(weekday,getdate()),dateadd(week,-1,getdate()))))) as date)
					  --when @ReportDateOption= 'Custom Date Range' then  '6/30/2012'
					  end
SELECT bigdata.HSPCODE, bigdata.PatientType, bigdata.AdmitDate, bigdata.DischargeDate, bigdata.AdmitPhysician, 
                  bigdata.AttendingPhysician, bigdata.Surgeon, bigdata.DRG, bigdata.APDRG, bigdata.APRDRG, bigdata.MSDRG, bigdata.AdmitICDCode, bigdata.AdmitICDVerison, 
                  bigdata.DischargeStatus, bigdata.FinClass, bigdata.Payor, bigdata.TotalCharges, bigdata.BaseClass, bigdata.SBOTYpe, bigdata.PRIM_ENC_CSN_ID, 
                  bigdata.ACCT_ZERO_BAL_DT
FROM     (SELECT '10' AS HSPCODE, PATIENT.PAT_MRN_ID AS MRN, HSP_ACCOUNT.HSP_ACCOUNT_ID AS PCN, REPLACE(CONVERT(varchar(10), PATIENT.BIRTH_DATE, 101), '/', '') AS DOB, 
                  LEFT(ZC_SEX.ABBR, 1) AS Gender, LEFT(ZC_ACCT_BASECLS_HA.ABBR, 1) AS PatientType, REPLACE(CONVERT(varchar(10), PAT_ENC_HSP.HOSP_ADMSN_TIME, 101), '/', 
                  '') AS AdmitDate, REPLACE(CONVERT(varchar(10), PAT_ENC_HSP.HOSP_DISCH_TIME, 101), '/', '') AS DischargeDate, COALESCE (admitnpi.NPI, hspadmnpi.NPI, 
                  admitnpi.PROV_ID) AS AdmitPhysician, COALESCE (hspattendnpi.NPI, attendnpi.NPI, HSP_ACCOUNT.ATTENDING_PROV_ID) AS AttendingPhysician, 
                  COALESCE (CLARITY_REPORT.surgery_surgeon.NPI, CLARITY_REPORT.surgery_surgeon.NPI) AS Surgeon, CASE WHEN CLARITY_DRG.DRG_NUMBER IS NULL 
                  THEN '- 1' ELSE CLARITY_DRG.DRG_NUMBER END AS DRG, '- 1' AS APDRG, CASE WHEN APRDRG.DRG_NUMBER IS NULL 
                  THEN '- 1' ELSE APRDRG.DRG_NUMBER END AS APRDRG, CASE WHEN MSDRG.DRG_NUMBER IS NULL THEN '- 1' ELSE MSDRG.DRG_NUMBER END AS MSDRG, 
                 -- CLARITY_EDG.ICD9_CODE AS AdmitICDCode
                  CLARITY_EDG.REF_BILL_CODE AS AdmitICDCode                  
                  , '9' AS AdmitICDVerison, PAT_ENC_HSP.DISCH_DISP_C AS DischargeStatus, ZC_FIN_CLASS.NAME AS FinClass, 
                  CLARITY_REPORT.coverage_1.PAYOR_NAME AS Payor, HSP_ACCOUNT.TOT_CHGS AS TotalCharges, ZC_ACCT_BASECLS_HA.NAME AS BaseClass, 
                  ZC_SBO_HAR_TYPE.NAME AS SBOTYpe, HSP_ACCOUNT.PRIM_ENC_CSN_ID, HSP_ACCOUNT.ACCT_ZERO_BAL_DT
FROM     ZC_ACCT_BASECLS_HA RIGHT OUTER JOIN
                  CLARITY_REPORT.tu_drg_HB AS MSDRG RIGHT OUTER JOIN
                  CLARITY_EDG RIGHT OUTER JOIN
                  CLARITY_SER_2 AS hspadmnpi RIGHT OUTER JOIN
                  HSP_ACCOUNT LEFT OUTER JOIN
                  HSP_ACCT_ADMIT_DX ON HSP_ACCOUNT.HSP_ACCOUNT_ID = HSP_ACCT_ADMIT_DX.HSP_ACCOUNT_ID ON 
                  hspadmnpi.PROV_ID = HSP_ACCOUNT.ADM_PROV_ID LEFT OUTER JOIN
                  CLARITY_SER_2 AS hspattendnpi ON HSP_ACCOUNT.ATTENDING_PROV_ID = hspattendnpi.PROV_ID LEFT OUTER JOIN
                  ZC_FIN_CLASS ON HSP_ACCOUNT.ACCT_FIN_CLASS_C = ZC_FIN_CLASS.FIN_CLASS_C ON CLARITY_EDG.DX_ID = HSP_ACCT_ADMIT_DX.ADMIT_DX_ID ON 
                  MSDRG.HSP_ACCOUNT_ID = HSP_ACCOUNT.HSP_ACCOUNT_ID LEFT OUTER JOIN
                  CLARITY_REPORT.tu_drg_HB AS APRDRG ON HSP_ACCOUNT.HSP_ACCOUNT_ID = APRDRG.HSP_ACCOUNT_ID ON 
                  ZC_ACCT_BASECLS_HA.ACCT_BASECLS_HA_C = HSP_ACCOUNT.ACCT_BASECLS_HA_C LEFT OUTER JOIN
                  CLARITY_DRG ON HSP_ACCOUNT.FINAL_DRG_ID = CLARITY_DRG.DRG_ID LEFT OUTER JOIN
                  CLARITY_REPORT.coverage_1 ON HSP_ACCOUNT.HSP_ACCOUNT_ID = CLARITY_REPORT.coverage_1.HSP_ACCOUNT_ID LEFT OUTER JOIN
                  CLARITY_REPORT.surgery_surgeon RIGHT OUTER JOIN
                  PAT_ENC_HSP INNER JOIN
                  PATIENT ON PAT_ENC_HSP.PAT_ID = PATIENT.PAT_ID ON CLARITY_REPORT.surgery_surgeon.PAT_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID LEFT OUTER JOIN
                  CLARITY_SER_2 AS admitnpi ON PAT_ENC_HSP.ADMISSION_PROV_ID = admitnpi.PROV_ID LEFT OUTER JOIN
                  CLARITY_SER_2 AS surgnpi RIGHT OUTER JOIN
                  PAT_SURG_DATA ON surgnpi.PROV_ID = PAT_SURG_DATA.CS_SURG_PROC_ID RIGHT OUTER JOIN
                  PAT_OR_ADM_LINK ON PAT_SURG_DATA.PAT_ENC_CSN_ID = PAT_OR_ADM_LINK.OR_LINK_CSN ON 
                  PAT_ENC_HSP.PAT_ENC_CSN_ID = PAT_OR_ADM_LINK.PAT_ENC_CSN_ID LEFT OUTER JOIN
                  ZC_SEX ON PATIENT.SEX_C = ZC_SEX.RCPT_MEM_SEX_C ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID LEFT OUTER JOIN
                  CLARITY_SER_2 AS attendnpi RIGHT OUTER JOIN
                  CLARITY_REPORT.Pat_attnd2 ON attendnpi.PROV_ID = CLARITY_REPORT.Pat_attnd2.PROV_ID ON 
                  PAT_ENC_HSP.PAT_ENC_CSN_ID = CLARITY_REPORT.Pat_attnd2.PAT_ENC_CSN_ID LEFT OUTER JOIN
                  HSP_ACCT_SBO ON HSP_ACCOUNT.HSP_ACCOUNT_ID = HSP_ACCT_SBO.HSP_ACCOUNT_ID LEFT OUTER JOIN
                  ZC_SBO_HAR_TYPE ON HSP_ACCT_SBO.SBO_HAR_TYPE_C = ZC_SBO_HAR_TYPE.SBO_HAR_TYPE_C
WHERE  (CLARITY_REPORT.surgery_surgeon.Rank = 1 OR
                  CLARITY_REPORT.surgery_surgeon.Rank IS NULL) AND (CLARITY_REPORT.Pat_attnd2.Rank = 1 OR
                  CLARITY_REPORT.Pat_attnd2.Rank IS NULL) AND (APRDRG.Rank = 1 OR
                  APRDRG.Rank IS NULL) AND (APRDRG.ID_TYPE_name like '%apr%' OR
                  APRDRG.ID_TYPE_name IS NULL) AND (MSDRG.ID_TYPE_name like '%ms%'OR
                  MSDRG.ID_TYPE_name IS NULL) AND (MSDRG.Rank = 1 OR
                  MSDRG.Rank IS NULL) AND (HSP_ACCT_ADMIT_DX.LINE = 1 OR
                  HSP_ACCT_ADMIT_DX.LINE IS NULL)) AS bigdata INNER JOIN
				  (
SELECT transunion_do_pick.PRIM_ENC_CSN_ID
FROM     (SELECT CAST(HSP_ACCOUNT_2.PRIM_ENC_CSN_ID AS varchar(12)) AS PRIM_ENC_CSN_ID
                  FROM      HSP_ACCOUNT AS HSP_ACCOUNT_2 LEFT OUTER JOIN
                                    HSP_ACCT_SBO AS HSP_ACCT_SBO_2 ON HSP_ACCOUNT_2.HSP_ACCOUNT_ID = HSP_ACCT_SBO_2.HSP_ACCOUNT_ID
                  WHERE   (HSP_ACCT_SBO_2.SBO_HAR_TYPE_C IN (0, 2, 3) OR
                                    HSP_ACCT_SBO_2.SBO_HAR_TYPE_C IS NULL) AND (HSP_ACCOUNT_2.ACCT_ZERO_BAL_DT >= @startdate) AND 
                                    (HSP_ACCOUNT_2.ACCT_ZERO_BAL_DT <= @enddate)) AS transunion_do_pick FULL OUTER JOIN
                      (SELECT CAST(HSP_ACCOUNT_1.PRIM_ENC_CSN_ID AS VARCHAR(12)) AS PRIM_ENC_CSN_ID
                       FROM      HSP_ACCOUNT AS HSP_ACCOUNT_1 LEFT OUTER JOIN
                                         HSP_ACCT_SBO AS HSP_ACCT_SBO_1 ON HSP_ACCOUNT_1.HSP_ACCOUNT_ID = HSP_ACCT_SBO_1.HSP_ACCOUNT_ID
                       WHERE   (HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IN (0, 2, 3) OR
                                         HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IS NULL) AND (ISNULL(HSP_ACCOUNT_1.ACCT_ZERO_BAL_DT, '12/31/2099') > @enddate)
                       GROUP BY HSP_ACCOUNT_1.PRIM_ENC_CSN_ID) AS transunion_donot_pick ON 
                  transunion_do_pick.PRIM_ENC_CSN_ID = transunion_donot_pick.PRIM_ENC_CSN_ID
WHERE  (transunion_donot_pick.PRIM_ENC_CSN_ID IS NULL)
group by transunion_do_pick.PRIM_ENC_CSN_ID) as 

                transunion_longrun ON bigdata.PRIM_ENC_CSN_ID = transunion_longrun.PRIM_ENC_CSN_ID