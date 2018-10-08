select distinct 
 tdl.account_id as 'Account ID'
 ,pat.pat_last_name as 'Patient Last Name'
,pat.pat_first_name as 'Patient First Name'
,pat.add_line_1 as 'Address 1'
,coalesce(pat.add_line_2,'') as 'Address 2'
,pat.city as 'City'
,state.name as 'State'
,pat.zip as 'Zip'
,pos.pos_name as 'Place of Service'
,ser.prov_name as 'Service Provider'


from 
clarity_tdl_tran tdl
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_ser ser on ser.prov_id = tdl.performing_prov_id
left join zc_state state on state.state_c = pat.state_c

where 
detail_type = 1 
and ser.prov_id = '1645244'
and pos.pos_name = 'Toledo Surgical Associates Inc'

order by account_id