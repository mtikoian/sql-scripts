declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');


-->>>>>>>>  DECLARE MERCY REGIONS <<<<<<<<<<<
with region as
(select *
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
where region is not null
),

net_collection as
(select
  Region.LOC_ID
 ,case when tdl.detail_type in (1,10) then tdl.amount end as 'TOTAL CHARGES'
 ,case when tdl.detail_type in (1,10,3,12,4,6,13,21,23,30,31) then tdl.amount end as 'NET REVENUE'
 ,case when tdl.detail_type in (2,5,11,20,22,32,33) then tdl.amount end *-1 as 'TOTAL PAYMENTS'
 ,case when tdl.detail_type <= 13 and (eap.gl_num_debit in ('bad','badrecovery') or eap.gl_num_credit in ('bad','badrecovery')) then tdl.amount end *-1 as 'BAD DEBT'
 ,case when tdl.detail_type <= 13 and (eap.gl_num_debit in ('charity') or eap.gl_num_credit in ('charity')) then tdl.amount end *-1 as 'CHARITY'
 --net collection is total payments/3 month net revenue average

from region
inner join CLARITY_TDL_TRAN tdl on tdl.LOC_ID = region.LOC_ID
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id

where
post_date >= @start_date
and tdl.post_date <= @end_date

),

ar as

(select 
  region.LOC_ID
 ,case when age.detail_type = 60 then age.patient_amount end as 'TOTAL SELF PAY AR'
 ,case when age.detail_type = 60 then age.insurance_amount end as 'INSURANCE PAY AR'
 ,cur_fc.name + ' [' + cur_fc.fin_class_c + ']' as 'Current FC'
 ,case when age.post_date - age.orig_post_date <= 30 then amount else 0 end as '0 - 30'
 ,case when age.post_date - age.orig_post_date >= 31 and age.post_date - age.orig_post_date <= 60 then amount else 0 end as '31 - 60'
 ,case when age.post_date - age.orig_post_date >= 61 and age.post_date - age.orig_post_date <= 90 then amount else 0 end as '61 - 90'
 ,case when age.post_date - age.orig_post_date >= 91 and age.post_date - age.orig_post_date <= 120 then amount else 0 end as '91 - 120'
 ,case when age.post_date - age.orig_post_date >= 121 and age.post_date - age.orig_post_date <= 180 then amount else 0 end as '121 - 180'
 ,case when age.post_date - age.orig_post_date >= 181 and age.post_date - age.orig_post_date <= 270 then amount else 0 end as '181 - 270'
 ,case when age.post_date - age.orig_post_date >= 271 and age.post_date - age.orig_post_date <= 365 then amount else 0 end as '271 - 365'
 ,case when age.post_date - age.orig_post_date > 365 then amount else 0 end as '+ 365'


from region
inner join clarity_tdl_age age on age.loc_id = region.loc_id
left join clarity.dbo.zc_fin_class cur_fc on cur_fc.fin_class_c = age.cur_fin_class

where 
age.post_date >= @start_date
and age.post_date <= @end_date

)

select REGION
 ,sum([total charges]) as TOTAL_CHARGES
 ,sum([total payments]) as TOTAL_PAYMENTS
 ,sum([net revenue]) as NET_REVENUE
 ,sum([bad debt]) as BAD_DEBT
 ,sum([charity]) as CHARITY
 ,sum([total self pay ar]) as TOTAL_SELF_PAY_AR
 ,sum([INSURANCE PAY AR]) as TOTAL_INSURANCE_PAY_AR
 ,[Current FC]
 ,sum([0 - 30]) as '0-30'
 --total ar (self pay plus insurance)
 --AR DAYS total ar/average daily total charges (total charges/days in previos 3 months) (currently average of average)


from region
left join net_collection on net_collection.loc_id = region.loc_id
left join ar on ar.loc_id = region.loc_id
group by region, [current fc]

--correct charge lag days

