declare @date as date = EPIC_UTIL.EFN_DIN('mb')


select 
case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO - MRG'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end as 'REGION'
,loc.loc_id as 'LOCATION ID'
,loc.loc_name as 'LOCATION NAME'
,dep.department_id as 'DEPARTMENT ID'
,dep.department_name as 'DEPARTMENT NAME'
,sum(patient_amount) as 'PATIENT AMOUNT'
,sum(insurance_amount) as 'INSURANCE AMOUNT'
,sum(amount) as 'TOTAL AMOUNT'

from 
clarity_tdl_age age
left join clarity_loc loc on loc.loc_id = age.loc_id
left join clarity_dep dep on dep.department_id = age.dept_id

where tdl_extract_date = @date
-- SPRINGFILED
and loc.loc_id in ('11106','11124') 
-- CINCINNATI
or loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138')
-- YOUNGSTOWN
or loc.loc_id in ('13104','13105')
-- LIMA
or loc.loc_id in ('16102','16103','16104')
-- LORAIN
or loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113')
-- DEFIANCE
or loc.loc_id in ('18120','18121')
-- TOLEDO 
or loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')
-- TOLEDO MRG
or loc.loc_id in ('18110')
-- KENTUCKY
or loc.loc_id in ('19101','19102','19106')
-- KENTUCKY - OTHER ENTITIES
or loc.loc_id in  ('19107','19108','19116','19118') 
-- SUMMA
or loc.loc_id in  ('131201','131202')

group by
 
   (
   case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO - MRG'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end
	 )
	,loc.loc_id
	,loc.loc_name
	,dep.department_id
	,dep.department_name

order by 

   (
   case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO - MRG'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end
	 )
	,department_name