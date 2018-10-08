declare		@ReportDateOption as varchar(max)
			,@StartDate as date
            ,@EndDate as date

-- modified Last Full Month date to run 2nd of the previous month to 1st of current

set @ReportDateOption= '{?ReportDateOption}'
--set @ReportDateOption= 'Last Full Month'

set @StartDate = case --when @ReportDateOption= 'Last Full Month' then cast(DATEADD(m,-1, Dateadd(d,1-DATEPART(d,getdate()),GETDATE())) as date) 
					  when @ReportDateOption= 'Last Full Month' then cast(DATEADD(DAY,1,DATEADD(m,-1, Dateadd(d,1-DATEPART(d,getdate()),GETDATE()))) as date) 
					  when @ReportDateOption= 'Last Full Week' then cast(dateadd(dd,0, datediff(dd,0, dateadd(day,-1*datepart(weekday,getdate())+1,dateadd(week,-1,getdate())))) as date)
					  when @ReportDateOption= 'Yesterday' then cast(dateadd(dd,-1,getdate()) as date)
					  when @ReportDateOption= 'Custom Date Range' then {?StartDate}
					  --when @ReportDateOption= 'Custom Date Range' then '7/1/2014'--  {?StartDate}
					  end
set @EndDate = case --when @ReportDateOption= 'Last Full Month' then cast(DATEADD(ms, -3, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)) as date)
					 when @ReportDateOption= 'Last Full Month' then cast(DATEADD(DAY,1,DATEADD(ms, -3, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))) as date)
					  when @ReportDateOption= 'Last Full Week' then cast(dateadd(dd,0, datediff(dd,0,  dateadd(day,7,dateadd(day,-1*datepart(weekday,getdate()),dateadd(week,-1,getdate()))))) as date)
					  when @ReportDateOption= 'Yesterday' then cast(dateadd(dd,-1,getdate()) as date)
					  when @ReportDateOption= 'Custom Date Range' then  {?EndDate}
					  --when @ReportDateOption= 'Custom Date Range' then  '10/31/2014'
					  end;

select ser.PROV_NAME
		,ser.PROV_ID
		,npi.IDENTITY_ID NPI
		,sp.NAME
		,@StartDate StartDate
		,@EndDate EndDate
from CLARITY_SER ser
inner join CLARITY_SER_2 ser2
	on ser2.PROV_ID=ser.PROV_ID
inner JOIN IDENTITY_SER_ID  npi
	ON ser.PROV_ID=npi.PROV_ID AND npi.IDENTITY_TYPE_ID=60 -- NPI
LEFT OUTER JOIN CLARITY_SER_SPEC spec
	on spec.PROV_ID=ser.PROV_ID and spec.LINE=1
LEFT OUTER JOIN ZC_SPECIALTY sp
	on sp.SPECIALTY_C=spec.SPECIALTY_C

where cast(ser2.RECORD_CREATION_DT as date) between @StartDate and @EndDate