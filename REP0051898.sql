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


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT '10' AS HSPCODE, HSP_ACCT_DX_LIST.HSP_ACCOUNT_ID AS PCN, clarity_edg.REF_BILL_CODE AS ICDCode,

case when REF_BILL_CODE_SET_C = 1 then 
 '9' else '10' end  AS ICDVersion, 
 
 
 'D' AS ICDCodeType, 
                  HSP_ACCT_DX_LIST.LINE AS PrimaryPosition
FROM     HSP_ACCT_DX_LIST INNER JOIN
                  clarity_edg ON HSP_ACCT_DX_LIST.DX_ID = clarity_edg.DX_ID INNER JOIN
                  HSP_ACCOUNT ON HSP_ACCT_DX_LIST.HSP_ACCOUNT_ID = HSP_ACCOUNT.HSP_ACCOUNT_ID INNER JOIN
                  PAT_ENC_HSP ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID INNER JOIN
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
                                         HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IS NULL) AND (ISNULL(HSP_ACCOUNT_1.ACCT_ZERO_BAL_DT, '12/31/2099') >@enddate)
                       GROUP BY HSP_ACCOUNT_1.PRIM_ENC_CSN_ID) AS transunion_donot_pick ON 
                  transunion_do_pick.PRIM_ENC_CSN_ID = transunion_donot_pick.PRIM_ENC_CSN_ID
WHERE  (transunion_donot_pick.PRIM_ENC_CSN_ID IS NULL)
group by transunion_do_pick.PRIM_ENC_CSN_ID) as    
				 
				 
				 
				  transunion_longrun ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = transunion_longrun.PRIM_ENC_CSN_ID
/*WHERE 
/* (cast(HSP_ACCOUNT.acct_close_date as date) >= @startdate) AND (cast(HSP_ACCOUNT.acct_close_date as date) <= @enddate) */

(clarity_edg.LINE = 1)*/
union all

SELECT '10' AS HSPCODE, HSP_ACCT_PX_LIST.HSP_ACCOUNT_ID AS PCN, CL_ICD_PX.REF_BILL_CODE AS asICDCode,

case when REF_BILL_CODE_SET_C = 1 then
'9' else '10' end AS ICDVersion, 'P' AS ICDCodeType, 
                  HSP_ACCT_PX_LIST.LINE AS PrimaryPosition
FROM     HSP_ACCT_PX_LIST INNER JOIN
     clarity_report.hsp_account_exclude_LPPI as            HSP_ACCOUNT ON HSP_ACCT_PX_LIST.HSP_ACCOUNT_ID = HSP_ACCOUNT.HSP_ACCOUNT_ID INNER JOIN
                  PAT_ENC_HSP ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID INNER JOIN
                  CL_ICD_PX ON HSP_ACCT_PX_LIST.FINAL_ICD_PX_ID = CL_ICD_PX.ICD_PX_ID INNER JOIN
(
SELECT transunion_do_pick.PRIM_ENC_CSN_ID
FROM     (SELECT CAST(HSP_ACCOUNT_2.PRIM_ENC_CSN_ID AS varchar(12)) AS PRIM_ENC_CSN_ID
                  FROM      clarity_report.hsp_account_exclude_LPPI as  HSP_ACCOUNT_2 LEFT OUTER JOIN
                                    HSP_ACCT_SBO AS HSP_ACCT_SBO_2 ON HSP_ACCOUNT_2.HSP_ACCOUNT_ID = HSP_ACCT_SBO_2.HSP_ACCOUNT_ID
                  WHERE   (HSP_ACCT_SBO_2.SBO_HAR_TYPE_C IN (0, 2, 3) OR
                                    HSP_ACCT_SBO_2.SBO_HAR_TYPE_C IS NULL) AND (HSP_ACCOUNT_2.ACCT_ZERO_BAL_DT >= @startdate) AND 
                                    (HSP_ACCOUNT_2.ACCT_ZERO_BAL_DT <= @enddate)) AS transunion_do_pick FULL OUTER JOIN
                      (SELECT CAST(HSP_ACCOUNT_1.PRIM_ENC_CSN_ID AS VARCHAR(12)) AS PRIM_ENC_CSN_ID
                       FROM       clarity_report.hsp_account_exclude_LPPI as  HSP_ACCOUNT_1 LEFT OUTER JOIN
                                         HSP_ACCT_SBO AS HSP_ACCT_SBO_1 ON HSP_ACCOUNT_1.HSP_ACCOUNT_ID = HSP_ACCT_SBO_1.HSP_ACCOUNT_ID
                       WHERE   (HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IN (0, 2, 3) OR
                                         HSP_ACCT_SBO_1.SBO_HAR_TYPE_C IS NULL) AND (ISNULL(HSP_ACCOUNT_1.ACCT_ZERO_BAL_DT, '12/31/2099') > @enddate)
                       GROUP BY HSP_ACCOUNT_1.PRIM_ENC_CSN_ID) AS transunion_donot_pick ON 
                  transunion_do_pick.PRIM_ENC_CSN_ID = transunion_donot_pick.PRIM_ENC_CSN_ID
WHERE  (transunion_donot_pick.PRIM_ENC_CSN_ID IS NULL)
group by transunion_do_pick.PRIM_ENC_CSN_ID) as 



                  transunion_longrun ON HSP_ACCOUNT.PRIM_ENC_CSN_ID = transunion_longrun.PRIM_ENC_CSN_ID
/*WHERE  (CAST(HSP_ACCOUNT.acct_close_date AS date) >= @startdate) AND (CAST(HSP_ACCOUNT.acct_close_date AS date) <= @enddate)*/