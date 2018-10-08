declare @date as date = EPIC_UTIL.EFN_DIN('mb')
declare @start_date as date = EPIC_UTIL.EFN_DIN('mb')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me')


select 
case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LandAIN'
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
,age.int_pat_id
,patient_amount as 'PATIENT AMOUNT'
,age.tdl_extract_date

from 
clarity_tdl_age age
left join clarity_loc loc on loc.loc_id = age.loc_id
left join clarity_dep dep on dep.department_id = age.dept_id
inner join 
(select 
distinct pat_id
from pat_enc enc
left join clarity_loc loc on loc.loc_id = enc.primary_loc_id
left join clarity_dep dep on dep.department_id = enc.department_id
where appt_status_c in (2,6) -- Arrived or Completed
and  contact_date >= @start_date
and contact_date <= @end_date
-- SPRINGFILED
and loc.loc_id in ('11106','11124'
-- CINCINNATI
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138'
-- YOUNGSTOWN
,'13104','13105'
-- LIMA
,'16102','16103','16104'
-- LandAIN
,'17105','17106','17107','17108','17109','17110','17112','17113'
-- DEFIANCE
,'18120','18121'
-- TOLEDO 
,'18101','18102','18103','18104','18105','18130','18131','18132','18133'
-- TOLEDO MRG
,'18110'
-- KENTUCKY
,'19101','19102','19106'
-- KENTUCKY - OTHER ENTITIES
,'19107','19108','19116','19118'
-- SUMMA
,'131201','131202')
) enc on enc.pat_id = age.int_pat_id

where age.tdl_extract_date = @date
and age.patient_amount > 0
-- SPRINGFILED
and loc.loc_id in ('11106','11124'
-- CINCINNATI
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138'
-- YOUNGSTOWN
,'13104','13105'
-- LIMA
,'16102','16103','16104'
-- LORAIN
,'17105','17106','17107','17108','17109','17110','17112','17113'
-- DEFIANCE
,'18120','18121'
-- TOLEDO 
,'18101','18102','18103','18104','18105','18130','18131','18132','18133'
-- TOLEDO MRG
,'18110'
-- KENTUCKY
,'19101','19102','19106'
-- KENTUCKY - OTHER ENTITIES
,'19107','19108','19116','19118'
-- SUMMA
,'131201','131202')
