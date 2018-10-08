/*Patient List by Encounters for Vascular Professional*/

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

from 

(

select distinct pat.pat_id
,pat_first_name as 'First Name'
,pat_middle_name as 'Middle Initial'
,pat_last_name as 'Last Name'
,birth_date as 'DOB'
,add_line_1 as 'Address 1'
,add_line_2 as 'Address 2'
,city as City
,state.name as 'State'
,zip

from pat_enc enc
left join patient pat on enc.pat_id = pat.pat_id
left join zc_state state on pat.state_c = state.state_c
where serv_area_id = 1600
)a

order by [Last Name], [First Name]

