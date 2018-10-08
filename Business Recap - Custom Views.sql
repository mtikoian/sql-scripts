select 

 upper(loc2.serv_area_name) as Region
,sum(case when detail_type in (1,10) then amount else 0 end) as Charges 
,sum(case when detail_type in (2,5,11,20,22,32,33) then amount else 0 end) as Payments 
,sum(case when detail_type in (3,12,4,6,13,21,23,30,31) then amount else 0 end) as Adjustments

from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join claritychputil.rpt.v_pb_location loc2 on loc2.loc_id = loc.rpt_grp_two

where detail_type in (1,2,3,4,5,6,10,11,12,13,20,21,22,23,30,31,32,33)
and loc.serv_area_id in (1,11,13,16,17,18,19,21,1312)
and post_date >= '4/1/2017'
and post_date <= '4/30/2017'

group by loc2.serv_area_name
order by loc2.serv_area_name
