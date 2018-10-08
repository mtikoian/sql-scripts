-->>>>>>>>  Calculation for Final Denial  <<<<<<<<<<<
declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-6') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 
	
case when loc.loc_id in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105','13116') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121'
						,'19120','19127') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133'  
						,'19119','19121','19122','19123','19124','19128','19129','19130','19131') then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end as 'REGION'
,date.year_month as 'Year-Month'
,date.month_name as 'Month'

,sum(case when eap_match.proc_code in ('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036') then tdl.amount end)*-1 as 'FINAL DENIAL'

from clarity_tdl_tran tdl
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on department_id = tdl.dept_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join zc_orig_fin_class fc on fc.original_fin_class = tdl.original_fin_class
left join date_dimension date on date.calendar_dt_str = tdl.post_date

where
tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and loc.loc_id in ('11106','11124','11149' -- SPRINGFILED
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138' -- CINCINNATI
,'13104','13105','13116' -- YOUNGSTOWN
,'16102','16103','16104' -- LIMA
,'17105','17106','17107','17108','17109','17110','17112','17113' -- LORAIN
,'18120','18121',
	'19120','19127' -- DEFIANCE
,'18101','18102','18103','18104','18105','18130','18131','18132','18133',
	'19119','19121','19122','19123','19124','19128','19129','19130','19131' -- TOLEDO 
,'19101','19102','19106' -- KENTUCKY
,'131201','131202' -- SUMMA
)

group by
case when loc.loc_id in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105','13116') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121'
						,'19120','19127') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133'  
						,'19119','19121','19122','19123','19124','19128','19129','19130','19131') then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end
	,date.year_month
    ,date.month_name
