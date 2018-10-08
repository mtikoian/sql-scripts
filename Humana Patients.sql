select 

[First Name]
,[Middle Initial]
,[Last Name]
,DOB
,[Address 1]
,[Address 2]
,City
,State
,ZIP
,payor_name as 'Payor'

from 

(

select distinct pat.pat_id
,pat_first_name as 'First Name'
,pat_middle_name as 'Middle Initial'
,pat_last_name as 'Last Name'
,birth_date as 'DOB'
,add_line_1 as 'Address 1'
,add_line_2 as 'Address 2'
,pat2.city as City
,state.name as 'State'
,zip
,payor_name

from pat_acct_cvg pat
left join clarity_epm epm on pat.payor_id = epm.payor_id
left join patient pat2 on pat.pat_id = pat2.pat_id
left join zc_state state on pat2.state_c = state.state_c
where serv_area_id = 1600
and payor_name like '%Humana%'
)a

order by [Last Name], [First Name]

