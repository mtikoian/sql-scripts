DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('wb-53')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('t-1')

insert into claritychputil.rpt.pb_open_encounters

SELECT
 cast(date.YEAR_MONTH as nvarchar(10)) as 'Year-Month'
,case when loc.rpt_grp_two in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_ten in ('11') then 'CINCINNATI'
	 when loc.rpt_grp_ten in ('13') then 'YOUNGSTOWN'
	 when loc.rpt_grp_ten in ('16') then 'LIMA'
	 when loc.rpt_grp_ten in ('17') then 'LORAIN'
	 when loc.rpt_grp_two in ('18120','18121') then 'DEFIANCE'
	 when loc.rpt_grp_ten in ('18')  then 'TOLEDO'
	 when loc.rpt_grp_ten in ('19') then 'KENTUCKY' 
	 when loc.rpt_grp_ten in ('1') then 'MERCY HEALTH' 
	 else 'UNKNOWN REGION'
	 end as 'Region'
,case when loc.rpt_grp_three is null then 'UNKNOWN LOCATION'
	else upper(loc.rpt_grp_three) + ' [' + loc.rpt_grp_two + ']' end as 'Location'
,case when dep.rpt_grp_two is null then 'UNKNOWN DEPARTMENT' 
	else upper(dep.rpt_grp_two) + ' [' + dep.rpt_grp_one + ']' end as 'Department'
--,cast(date.CALENDAR_DT_STR as date) as 'Contact Date'
,CONVERT(VARCHAR(10),enc.CONTACT_DATE, 101) as 'Contact Date'
,zdet.NAME as 'Encounter Type'
,pat.PAT_NAME + ' [' + pat.PAT_MRN_ID + ']' as 'Patient'
--,cast(pat.BIRTH_DATE as date) as 'Birth Date'
,CONVERT(VARCHAR(10),pat.BIRTH_DATE, 101) as 'Birth Date'
,zas.NAME as 'Appt Status'
,ser.PROV_NAME as 'Visit Provider'
,enc.PAT_ENC_CSN_ID as 'Encounter ID'
,enc.CONTACT_COMMENT 'Comment'
,epm.PAYOR_NAME 'Payor'
,case when datediff(d,enc.contact_date,getdate()) < 8 then 'Under 8 Days'
	  when datediff(d,enc.contact_date,getdate()) < 31 then '8 - 30 Days'
      when datediff(d,enc.contact_date,getdate()) < 91 then '31 - 90 Days'
	  else '91 days or over' end as 'Time Bucket'
,convert(varchar(10),getdate(),101) as 'Run Date'
      
FROM Clarity.dbo.PAT_ENC enc
left join Clarity.dbo.CLARITY_SER ser on ser.PROV_ID = enc.VISIT_PROV_ID
left join Clarity.dbo.CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join Clarity.dbo.ZC_DISP_ENC_TYPE zdet on zdet.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join Clarity.dbo.PATIENT pat on pat.PAT_ID = enc.PAT_ID
left join Clarity.dbo.COVERAGE cov on cov.COVERAGE_ID = enc.COVERAGE_ID
left join Clarity.dbo.CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join Clarity.dbo.ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join Clarity.dbo.CLARITY_EPM epm on epm.PAYOR_ID = cov.PAYOR_ID
left join Clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT = enc.CONTACT_DATE
left join Clarity.dbo.ZC_APPT_STATUS zas on zas.APPT_STATUS_C = enc.APPT_STATUS_C


WHERE
enc.APPT_STATUS_C not in (4,5)
and enc.ENC_CLOSED_YN = 'N'
and enc.ENC_TYPE_C in ('11','119','121','2','202','2100','21004','21005','210177','2102','210230000',
'210370001','2501','283','51','62','69','72','76','81','91','1000','1001','1003','101','108','1200',
'1201','1214','201','2101','2502')
and enc.CONTACT_DATE >= @start_date
and enc.CONTACT_DATE <= @end_date
and enc.PAT_ENC_CSN_ID not in (46191210,46192722)
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)

order by enc.CONTACT_DATE desc

