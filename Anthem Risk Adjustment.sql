drop table #temp 

select 
distinct
ac.RequestID
,ac.MemberName
,ac.DOB
,ac.AllProviders
,ac.Project
,ac.Region
,ac.ProjectDOS
,ac.TotalRequests
--,ac.RequestsW/DoS
,ac.[Due Date]
--,cast(tdl.orig_service_date as date) as 'Service Date'
,arpb_tx.service_date as 'Service Date'

into #temp

from claritychputil.rpt.anthem_toledo ac
inner join clarity.dbo.patient pat on pat.pat_last_name = ac.[Last Name] and pat.pat_first_name = ac.[First Name] and pat.birth_date = ac.[DOB]
left join clarity.dbo.arpb_transactions arpb_tx on arpb_tx.patient_id = pat.pat_id
left join clarity.dbo.clarity_epm epm on epm.payor_id = arpb_tx.original_epm_id
--left join clarity.dbo.clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join clarity.dbo.zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten

where arpb_tx.tx_type_c = 1 -- charges
and arpb_tx.service_date >= '2016-01-01 00:00:00'
and sa.rpt_grp_ten = 18
--and original_epm_id in (1005, 3010) -- ANTHEM MEDICARE, ANTHEM
--and ac.requestid = 'A643-161224'
and arpb_tx.void_date is null
;

select distinct 
               FQ.RequestID
              ,fq.MemberName
              ,convert(varchar(10),fq.dob,101) as 'DOB'
              ,fq.AllProviders
              ,fq.Project
              ,fq.Region
              ,fq.ProjectDOS
              ,convert(varchar(10), fq.[Due Date],101) as 'Due Date'
              ,Stuff((SELECT distinct concat(',', convert(varchar(10), sq.[service date], 101), ' ')
          FROM #temp as SQ
                where Sq.RequestID = fq.RequestID
         FOR XML PATH('')), 1, 1, '')
               as 'Service Date(s)'
from   
              #temp as FQ
                        
order by membername