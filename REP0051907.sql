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


SELECT  10 AS HSPCODE, REPLACE(CONVERT(varchar(10), HSP_ACCOUNT.ACCT_BILLED_DATE, 101), '/', '') AS [Final Bill Date], 
                  MAX(CLARITY_REPORT.coverage_1.BENEFIT_PLAN_NAME + ' [' + CAST(CLARITY_REPORT.coverage_1.BENEFIT_PLAN_ID AS varchar(10)) + ']') AS InsurancePlan1, 
                  MAX(CLARITY_REPORT.coverage_2.BENEFIT_PLAN_NAME + ' [' + CAST(CLARITY_REPORT.coverage_2.BENEFIT_PLAN_ID AS varchar(10)) + ']') AS InsurancePlan2, 
                  HSP_ACCOUNT.TOT_CHGS - SUM(CASE WHEN bkt_type_ha_c IN (2, 6) AND BKT_STS_HA_C = 5 THEN EXP_NA_WOFF_AMT ELSE 0 END) AS [Expected Reimbursement], 
                  HSP_ACCOUNT.TOT_CHGS AS TotalCharges, HSP_ACCOUNT.TOT_PMTS AS TotalPayments, SUM(CASE WHEN BKT_TYPE_HA_C <> 4 AND 
                  BKT_STS_HA_C = 5 THEN HSP_BUCKET.PAYMENT_TOTAL ELSE 0 END) AS TotalInsurancePayments, SUM(CASE WHEN BKT_TYPE_HA_C = 4 AND 
                  BKT_STS_HA_C = 5 THEN HSP_BUCKET.PAYMENT_TOTAL ELSE 0 END) AS TotalPatientPaymeents, HSP_ACCOUNT.TOT_ADJ AS TotalAdjustments, 
                  SUM(CASE WHEN BKT_TYPE_HA_C <> 4 AND BKT_STS_HA_C = 5 THEN HSP_BUCKET.CURRENT_BALANCE ELSE 0 END) AS CurrentInsuranceBalance, 
                  SUM(CASE WHEN BKT_TYPE_HA_C = 4 AND BKT_STS_HA_C = 5 THEN HSP_BUCKET.CURRENT_BALANCE ELSE 0 END) AS CurrentPatientBalance, 
                  HSP_ACCOUNT.TOT_ACCT_BAL AS TotalAccountBalance
FROM  clarity_report.hsp_account_exclude_LPPI as   HSP_ACCOUNT INNER JOIN
                  HSP_BUCKET ON HSP_ACCOUNT.HSP_ACCOUNT_ID = HSP_BUCKET.HSP_ACCOUNT_ID INNER JOIN
                  PATIENT ON HSP_ACCOUNT.PAT_ID = PATIENT.PAT_ID INNER JOIN
                  PAT_ENC_HSP ON HSP_ACCOUNT.HSP_ACCOUNT_ID = PAT_ENC_HSP.HSP_ACCOUNT_ID INNER JOIN
(
SELECT transunion_do_pick.PRIM_ENC_CSN_ID
FROM     (SELECT CAST(HSP_ACCOUNT_2.PRIM_ENC_CSN_ID AS varchar(12)) AS PRIM_ENC_CSN_ID
                  FROM      clarity_report.hsp_account_exclude_LPPI AS HSP_ACCOUNT_2 LEFT OUTER JOIN
                                    HSP_ACCT_SBO AS HSP_ACCT_SBO_2 ON HSP_ACCOUNT_2.HSP_ACCOUNT_ID = HSP_ACCT_SBO_2.HSP_ACCOUNT_ID
                  WHERE   (HSP_ACCT_SBO_2.SBO_HAR_TYPE_C IN (0, 2, 3) OR
                                    HSP_ACCT_SBO_2.SBO_HAR_TYPE_C IS NULL) AND (HSP_ACCOUNT_2.ACCT_ZERO_BAL_DT >= @startdate) AND 
                                    (HSP_ACCOUNT_2.ACCT_ZERO_BAL_DT <= @enddate)) AS transunion_do_pick FULL OUTER JOIN
                      (SELECT CAST(HSP_ACCOUNT_1.PRIM_ENC_CSN_ID AS VARCHAR(12)) AS PRIM_ENC_CSN_ID
                       FROM      clarity_report.hsp_account_exclude_LPPI AS HSP_ACCOUNT_1 LEFT OUTER JOIN
                                         HSP_ACCT_SBO AS HSP_ACCT_SBO_1 ON HSP_ACCOUNT_1.HSP_ACCOUNT_ID = HSP_ACCT_SBO_1.HSP_ACCOUNT_ID
                       WHERE   (HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IN (0, 2, 3) OR
                                         HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IS NULL) AND (ISNULL(HSP_ACCOUNT_1.ACCT_ZERO_BAL_DT, '12/31/2099') > @enddate)
                       GROUP BY HSP_ACCOUNT_1.PRIM_ENC_CSN_ID) AS transunion_donot_pick ON 
                  transunion_do_pick.PRIM_ENC_CSN_ID = transunion_donot_pick.PRIM_ENC_CSN_ID
WHERE  (transunion_donot_pick.PRIM_ENC_CSN_ID IS NULL)
group by transunion_do_pick.PRIM_ENC_CSN_ID) as    




                transunion_longrun ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = transunion_longrun.PRIM_ENC_CSN_ID LEFT OUTER JOIN
                  ZC_STATE ON HSP_ACCOUNT.GUAR_STATE_C = ZC_STATE.STATE_C LEFT OUTER JOIN
                  CLARITY_REPORT.coverage_1 ON HSP_ACCOUNT.HSP_ACCOUNT_ID = CLARITY_REPORT.coverage_1.HSP_ACCOUNT_ID LEFT OUTER JOIN
                  CLARITY_REPORT.coverage_2 ON HSP_ACCOUNT.HSP_ACCOUNT_ID = CLARITY_REPORT.coverage_2.HSP_ACCOUNT_ID
--WHERE  (cast(HSP_ACCOUNT.acct_close_date as date) >= @startdate) AND (cast(HSP_ACCOUNT.acct_close_date  AS DATE)<= @enddate)
GROUP BY PAT_ENC_HSP.PAT_ENC_CSN_ID, HSP_ACCOUNT.HSP_ACCOUNT_NAME, HSP_ACCOUNT.TOT_ACCT_BAL, HSP_ACCOUNT.TOT_ADJ, HSP_ACCOUNT.TOT_CHGS, 
                  HSP_ACCOUNT.TOT_PMTS, CLARITY_REPORT.coverage_1.BENEFIT_PLAN_NAME, CLARITY_REPORT.coverage_2.BENEFIT_PLAN_ID, PATIENT.SSN, 
                  PATIENT.PAT_FIRST_NAME, PATIENT.PAT_MIDDLE_NAME, PATIENT.PAT_LAST_NAME, HSP_ACCOUNT.GUAR_DOB, HSP_ACCOUNT.GUAR_SSN, 
                  HSP_ACCOUNT.GUAR_ADDR_1, HSP_ACCOUNT.GUAR_ADDR_2, HSP_ACCOUNT.GUAR_CITY, HSP_ACCOUNT.GUAR_ZIP, HSP_ACCOUNT.ACCT_BILLED_DATE, 
                  HSP_ACCOUNT.GUAR_NAME, ZC_STATE.ABBR, hsp_account.hsp_account_id