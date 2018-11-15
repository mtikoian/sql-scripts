select 
 dep.DEPARTMENT_ID as 'DEPARTMENT ID'
,dep.DEPARTMENT_NAME as 'DEPARTMENT NAME'
,coalesce(dep.RPT_GRP_ONE,cast(dep.department_id as nvarchar)) as 'DEPARTMENT ID GROUPER'
,coalesce(dep.RPT_GRP_TWO,dep.department_name) as 'DEPARTMENT NAME GROUPER'
,sa.RPT_GRP_TEN as 'REGION ID'
,upper(sa.NAME) as 'REGION'
,case when loc.RPT_GRP_TEN = '19' then '13687'
      when loc.RPT_GRP_TEN = '17' then '11728'
	  when loc.LOC_ID in ('18120','19120','18121','19127') then '17223, 11598'
	  when loc.RPT_GRP_TEN = '18' then '11598'
	  when loc.RPT_GRP_TEN = '16' then '11732'
	  when loc.RPT_GRP_TEN = '13' then '11729'
	  when loc.LOC_ID in ('11106','11149','11124','19147') then '11588'
	  when loc.RPT_GRP_TEN = '11' then '11730'
	  end as 'CLIENT ID'
from clarity_dep dep
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join zc_loc_rpt_grp_10 sa on sa.RPT_GRP_TEN= loc.RPT_GRP_TEN
where loc.rpt_grp_six = 100
and dep.DEPARTMENT_NAME not like '%do not use%'
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)

order by dep.DEPARTMENT_ID