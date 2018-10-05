/*I would need Region, Procedure Write Off Description and code, Provider, Payor, and Amount.*/

declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
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
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104,19132,19133,19134) then 'LIMA'
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	 when loc.loc_id in (18120,18121,19120,19127) then 'DEFIANCE'
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19128,19129,19130,19131,19121,19122,19123,19124)  then 'TOLEDO'
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (131201,131202) then 'SUMMA'
	 end as 'REGION'
,LOC.LOC_ID
,DEP.DEPARTMENT_ID
from CLARITY_LOC LOC
left join CLARITY_DEP dep on dep.rev_loc_id = loc.loc_id
where dep.rpt_grp_sixteen_c = '1'
)a

where a.region is not null

),

main as
(select 
REGION
,tdl.ORIG_SERVICE_DATE
,tdl.POST_DATE
,tdl.TX_ID
,eap_match.PROC_CODE
,eap_match.PROC_NAME
,ser.PROV_ID
,ser.PROV_NAME
,epm.PAYOR_NAME
,det.NAME as DETAIL_TYPE
,tdl.amount * -1 as AMOUNT
-->>>>>>>>  Calculation for Final Denial  <<<<<<<<<<<


from region
inner join clarity_tdl_tran tdl on tdl.DEPT_ID= region.DEPARTMENT_ID
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join zc_orig_fin_class fc on fc.original_fin_class = tdl.original_fin_class
left join clarity_ser ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ACTION_PAYOR_ID
left join ZC_DETAIL_TYPE det on det.DETAIL_TYPE = tdl.DETAIL_TYPE

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and eap_match.proc_code in ('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036')
)

select * from main
order by TX_ID