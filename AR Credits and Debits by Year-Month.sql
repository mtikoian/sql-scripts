declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2017') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') ;


-->>>>>>>>  DECLARE MERCY REGIONS <<<<<<<<<<<
with region as
(
select *
from
(
select 

case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,1114,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104,19132,19133,19134) then 'LIMA'
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	 when loc.loc_id in (18120,18121,19120,19127) then 'DEFIANCE'
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19128,19129,19130,19131,19121,19122,19123,19124)  then 'TOLEDO'
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (131201,131202) then 'SUMMA'
	 end as 'REGION'
,LOC.LOC_ID
from CLARITY_LOC LOC
)a

where a.region is not null

),



ar as

(select 
	
Region
-->>>>>>>>  Calculation for Self Pay AR Aging > 90 Days  <<<<<<<<<<<
,date.year_month
,sum(case when age.detail_type in (60,61) and age.post_date - age.orig_post_date > 90 then age.patient_amount end) as 'PATIENT AR > 90'

-->>>>>>>>  Calculation for Total Self Pay AR  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) then age.patient_amount end) as 'TOTAL SELF PAY AR'

-->>>>>>>>  Calculation for Insurance AR Aging > 90 Days  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) and post_date - age.orig_post_date > 90 then age.insurance_amount end) as 'INSURANCE AR > 90'

-->>>>>>>>  Calculation for Insurance Pay AR  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) then age.insurance_amount end) as 'INSURANCE PAY AR'

from region
inner join clarity_tdl_age age on age.loc_id = region.loc_id
left join clarity_loc loc on loc.loc_id = age.loc_id
left join clarity_dep dep on dep.department_id = age.dept_id
left join date_dimension date on date.calendar_dt = age.post_date

where 
age.post_date >= @start_date
and age.post_date <= @end_date


group by
region
,year_month

)
select 
 ar.REGION
,ar.YEAR_MONTH
,ar.[PATIENT AR > 90]
,ar.[TOTAL SELF PAY AR]
,ar.[INSURANCE AR > 90]
,ar.[INSURANCE PAY AR]

from ar
order by ar.region
,ar.YEAR_MONTH