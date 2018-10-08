declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-13') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-2') 


select
year_month
,case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133','18110')  then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 end as 'REGION'
,sum(amount) as 'Bad Debt'
from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join zc_detail_type type on type.detail_type = tdl.detail_type
left join date_dimension dd on dd.calendar_dt_str = tdl.post_date
left join clarity_loc loc on loc.loc_id = tdl.loc_id
where post_date >= @start_date
and post_date <= @end_date
and loc.loc_id in (
'11106','11124'--SPRINGFIELD-- 
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138' --CINCINNATI
,'13104','13105' --YOUNGSTOWN--
,'16102','16103','16104'--LIMA--
,'17105','17106','17107','17108','17109','17110','17112','17113'--LORAIN--
,'18120','18121'--DEFIANCE--
,'18101','18102','18103','18104','18105','18130','18131','18132','18133','18110'--TOLEDO--
,'19101','19102','19106')--KENTUCKY
and (gl_num_debit in ('bad','badrecovery')
or gl_num_credit in ('bad','badrecovery'))
and tdl.detail_type <= 13

group by 
	case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133','18110')  then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	end
,year_month

order by 
case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133','18110')  then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	end
,year_month


