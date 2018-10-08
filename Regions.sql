/* 7,861 rows on 1/19/19*/

select 
 
 --IDENTIFY SERVICE AREA--
 case when sa.serv_area_id in (11,13,16,17,18,19) then '19'
      else sa.serv_area_id end as 'SERV_AREA_ID'
,case when sa.serv_area_id in (11,13,16,17,18,19) then 'MERCY HEALTH'
      else upper(sa.serv_area_name) end as 'SERV_AREA_NAME'

 --IDENTIFY REGION--
,region.rpt_grp_ten as 'REGION_ID'
,case when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11106,11149,11124,11132,11138) then 'CINCINNATI'
	  when loc.loc_id in (13104,13105,13116) then 'YOUNGSTOWN'
      when loc.loc_id in (16102,16013,16104,19132,19133,19134) then 'LIMA'
	  when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	  when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19128,19129,19130,19131,19121,19122,19123,19124,18110,18120,18121,19120,19127) then 'TOLEDO'
	  when loc.loc_id in (19000) then 'MH BILLING OFFICE'
	  when loc.loc_id in (19101,19102,19106,19107,19118,19108,19116) then 'KENTUCKY'
	  when loc.loc_id in (21101,21102,21104) then 'HEALTHSPAN'
	  when loc.loc_id in (13201,13202) then 'SUMMA'
 else upper(region.name)
 end as 'REGION_NAME'

 --IDENTIFY MARKET--
 ,region.rpt_grp_ten as 'MARKET_ID' 
 ,case when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151) then 'CINCINNATI'
	   when loc.loc_id in (11106,11149,11124) then ' SPRINGFGIELD'
	   when loc.loc_id in (13104,13105,13116) then 'YOUNGSTOWN'
	   when loc.loc_id in (16102,16013,16104,19132,19133,19134) then 'LIMA'
	   when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	   when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19128,19129,19130,19131,19121,19122,19123,19124) then 'TOLEDO'
	   when loc.loc_id in (18110) then 'MRG'
	   when loc.loc_id in (18120,18121,19120,19127) then 'DEFIANCE'
	   when loc.loc_id in (19000) then 'MH BILLING OFFICE'
	   when loc.loc_id in (19101,19102,19106) then 'KENTUCKY'
	   when loc.loc_id in (19107,19118,19108,19116) then 'KENTUCKY - OTHER ENTITIES'
	   when loc.loc_id in (21101,21102,21104) then 'HEALTHSPAN'  
	   when loc.loc_id in (13201,13202) then 'SUMMA'
  else upper(region.name)
  end as 'MARKET_NAME'

--LOCATIONS''
,loc.loc_id as 'LOCATION_ID'
,upper(loc.loc_name) as 'LOCATION_NAME'
,loc.gl_prefix as 'LOCATION_GL'
,loc.rpt_grp_six  as 'LOCATIONG GRP 6'

--DEPARTMENTS''
,dep.department_id as 'DEPARTMENT_ID'
,upper(dep.department_name) as 'DEPARTMENT_NAME'
,dep.gl_prefix as 'DEPARTMENT_GL'

from clarity_loc loc
left join clarity_dep dep on dep.rev_loc_id = loc.loc_id
left join zc_loc_rpt_grp_10 region on region.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_sa sa on sa.serv_area_id = loc.serv_area_id


where loc.rpt_grp_six = 100
and sa.serv_area_id <> 21
order by sa.serv_area_id, loc.loc_id  asc