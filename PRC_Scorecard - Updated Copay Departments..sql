declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 
declare @12month as date = EPIC_UTIL.EFN_DIN('mb-13') ;

-->>>>>>>>  DECLARE MERCY REGIONS <<<<<<<<<<<
with region as
(
select *
from
(
select 

case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,1114,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
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


copay as
(select 
region
,sum(enc.copay_collected) as 'COPAY COLLECTED'
,sum(enc.copay_due) as 'COPAY DUE'

from pat_enc enc
left join clarity_dep dep on dep.department_id = enc.department_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join clarity_prc prc on prc.prc_id = enc.appt_prc_id
inner join region on region.loc_id = loc.loc_id

where appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= @start_date
and enc.contact_date <= @end_date
and prc.benefit_group in ('Office Visit','PB Copay','Copay')
and enc.copay_due > 0
and enc.pat_enc_csn_id <> 131850458
and dep.department_id not in (
 19290028
,19290022
,11101323
,11101447
,11101321
,11101501
,11101448
,11101322
,11106145
,11106141
,18101244
,19390123
)

group by
region
)

select 
 copay.[REGION]
,copay.[COPAY COLLECTED]
,copay.[COPAY DUE]

from copay

order by copay.[REGION]