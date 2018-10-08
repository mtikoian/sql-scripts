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



SELECT 10 AS HSPCODE, REPLACE(CONVERT(varchar(10), HSP_ACCT_CPT_CODES.CPT_CODE_DATE, 101), '/', '') AS ServiceDate, 
                  HSP_ACCT_CPT_CODES.CPT_CODE AS CPT, EPIC_UTIL.EFN_PIECE(HSP_ACCT_CPT_CODES.CPT_MODIFIERS, ',', 1) AS [Modifier 1], 
                  EPIC_UTIL.EFN_PIECE(HSP_ACCT_CPT_CODES.CPT_MODIFIERS, ',', 2) AS [Modifier 2], EPIC_UTIL.EFN_PIECE(HSP_ACCT_CPT_CODES.CPT_MODIFIERS, ',', 3) 
                  AS [Modifier 3], EPIC_UTIL.EFN_PIECE(HSP_ACCT_CPT_CODES.CPT_MODIFIERS, ',', 4) AS [Modifier 4], HSP_ACCT_CPT_CODES.PX_REV_CODE_ID AS RevCode, 
                  0 AS Charge, 0 AS Quantity
FROM     HSP_ACCT_CPT_CODES INNER JOIN
                  PAT_ENC_HSP ON HSP_ACCT_CPT_CODES.HSP_ACCOUNT_ID = PAT_ENC_HSP.HSP_ACCOUNT_ID INNER JOIN
            clarity_report.hsp_account_exclude_LPPI as      HSP_ACCOUNT ON HSP_ACCT_CPT_CODES.HSP_ACCOUNT_ID = HSP_ACCOUNT.HSP_ACCOUNT_ID INNER JOIN
  (
SELECT transunion_do_pick.PRIM_ENC_CSN_ID
FROM     (SELECT CAST(HSP_ACCOUNT_2.PRIM_ENC_CSN_ID AS varchar(12)) AS PRIM_ENC_CSN_ID
                  FROM     clarity_report.hsp_account_exclude_LPPI AS HSP_ACCOUNT_2 LEFT OUTER JOIN
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




                  transunion_longrun ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = transunion_longrun.PRIM_ENC_CSN_ID


--WHERE  (cast(HSP_ACCOUNT.acct_close_date as date) >= @startdate) AND (cast(HSP_ACCOUNT.acct_close_date as date)<= @enddate)