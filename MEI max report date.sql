SELECT a.[PAT_MRN]
      ,[PAT_NAME]
      ,[ENC_TYPE]
      ,[CONTACT_DATE]
      ,[PAT_ENC_CSN_ID]
      ,[REPORT_DATE]
      ,[ENC_CLOSED_YN]
      ,[LOS_PROC_CODE]
      ,[SPECIALTY]
      ,[DEPARTMENT_NAME]
      ,[VISIT_PROVIDER]
      ,[CLOSE_PROVIDER]
      ,[ENC_TYPE_TITLE]
      ,[CHARGE_SLIP_NUMBER]
      ,[APPT STATUS]
      ,[SERV_AREA_ID]
      ,[DAYS]
      ,[AGE]
  FROM [Rpt].[CHPIT_CLARITY_MEI]  a
  INNER JOIN 
	(SELECT pat_mrn, max(report_date) as max_date
	from [Rpt].[CHPIT_CLARITY_MEI] 
	group by pat_mrn) a2
	on a2.pat_mrn = a.PAT_MRN
	and a2.max_date = a.REPORT_DATE
order by report_date, pat_mrn

