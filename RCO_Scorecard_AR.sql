declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 
*
from

(select 
	
case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end as 'REGION'
,loc.loc_name as 'LOCATION'
,dep.department_name as 'DEPARTMENT'
,date.monthname_year as 'MONTH'

-->>>>>>>>  Calculation for Self Pay AR Aging > 90 Days  <<<<<<<<<<<
,sum(case when age.detail_type = 60 and age.post_date - age.orig_post_date > 90 then age.patient_amount end) as 'PATIENT AR > 90'

-->>>>>>>>  Calculation for Total Self Pay AR  <<<<<<<<<<<
,sum(case when age.detail_type = 60 then age.patient_amount end) as 'TOTAL SELF PAY AR'

-->>>>>>>>  Calculation for Insurance AR Aging > 90 Days  <<<<<<<<<<<
,sum(case when age.detail_type = 60 and post_date - age.orig_post_date > 90 then age.insurance_amount end) as 'INSURANCE AR > 90'

-->>>>>>>>  Calculation for Insurance Pay AR  <<<<<<<<<<<
,sum(case when age.detail_type = 60 then age.insurance_amount end) as 'INSURANCE PAY AR'

from clarity_tdl_age age
left join clarity_loc loc on loc.loc_id = age.loc_id
left join clarity_dep dep on dep.department_id = age.dept_id
left join v_cube_d_billing_dates date on date.calendar_dt_str = age.post_date

where 
age.post_date >= @start_date
and age.post_date <= @end_date
and loc.loc_id in ('11106','11124' -- SPRINGFILED
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138' -- CINCINNATI
,'13104','13105' -- YOUNGSTOWN
,'16102','16103','16104' -- LIMA
,'17105','17106','17107','17108','17109','17110','17112','17113' -- LORAIN
,'18120','18121' -- DEFIANCE
,'18101','18102','18103','18104','18105','18130','18131','18132','18133' -- TOLEDO 
,'18110' -- TOLEDO MRG
,'19101','19102','19106' -- KENTUCKY
,'19107','19108','19116','19118' -- KENTUCKY - OTHER ENTITIES
)

group by
	case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA' 
	end
	,loc.loc_name
	,dep.department_name
	,date.monthname_year

)as sub

order by region, month