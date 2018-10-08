select 
 coalesce(pos_id,'') as 'POS_ID'
,coalesce(pos_name,'') as 'POS'
,coalesce(pos_type,'') as 'POS_TYPE'
,coalesce(address_line_1,'') as 'ADDR_LINE_1'
,coalesce(address_line_2,'') as 'ADDR_LINE_2'
,coalesce(city,'') as 'CITY'
,coalesce(state.ABBR,'') as 'STATE'
,coalesce(zip,'') as 'ZIP'
,service_area_id as 'SERVICE AREA'

from clarity_pos pos
left join zc_state state on state.state_c = pos.state_c
where record_status is null
and loc_type_c = 3
order by pos_id