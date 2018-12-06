select 

 dep.DEPARTMENT_ID 'DEPARTMENT ID'
,dep.DEPARTMENT_NAME 'DEPARTMENT NAME'
,dep.RPT_GRP_ONE 'DEPARTMENT ID GROUPER'
,dep.RPT_GRP_TWO 'DEPARTMENT NAME GROUPER'
,dep.GL_PREFIX
,sa.RPT_GRP_TEN as 'REGION ID'
,upper(sa.NAME) as 'REGION'
,case when loc.RPT_GRP_TEN = '19' then '13687'
      when loc.RPT_GRP_TEN = '17' then '11728'
	  when loc.LOC_ID in ('18120','19120','18121','19127') then '17223, 11598'
	  when loc.RPT_GRP_TEN = '18' then '11598'
	  when loc.RPT_GRP_TEN = '16' then '11732'
	  when loc.RPT_GRP_TEN = '13' then '11729'
	  when loc.LOC_ID = '11106' then '11588'
	  when loc.LOC_ID in ('11101','11102','11106','11115','11123','11124','11132') then '11730'
	  end as 'CLIENT ID'
from clarity_dep dep
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join zc_loc_rpt_grp_10 sa on sa.RPT_GRP_TEN= loc.RPT_GRP_TEN
where 
dep.DEPARTMENT_ID in
(19390389

)
order by dep.RPT_GRP_ONE
