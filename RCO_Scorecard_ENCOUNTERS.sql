declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 
	
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

-->>>>>>>>  Calculation for Open Encounters < 8 days  <<<<<<<<<<<
,sum(case when datediff(day,enc.contact_date, @end_date) < 8 then 1 end) as '< 8 Days'

-->>>>>>>>  Calculation for Open Encounters 8 - 30 days  <<<<<<<<<<<
,sum(case when datediff(day,enc.contact_date,@end_date) > 7 and datediff(day,enc.contact_date,@end_date) < 31 then 1 end) as '8 - 30 Days'

-->>>>>>>>  Calculation for Open Encounters 31 - 90 days  <<<<<<<<<<<
,sum(case when datediff(day,enc.contact_date,@end_date) > 30 and datediff(day,enc.contact_date,@end_date) < 91 then 1 end) as '31 - 90 Days'

-->>>>>>>>  Calculation for Open Encounters 91 - 365 days  <<<<<<<<<<<
,sum(case when datediff(day,enc.contact_date,@end_date) > 90 and datediff(day,enc.contact_date,@end_date) < 366 then 1 end) as '91 - 365 Days'

from pat_enc enc
left join clarity_ser ser on ser.prov_id = enc.visit_prov_id
left join clarity_dep dep on dep.department_id = enc.department-id
left join clarity.zc_disp_enc_type zdet on zdet.disp_enc_type_c = enc.enc_type_c
left join patient pat on pat.pat_id = enc.pat_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id

where enc.enc_closed_yn = 'n'
and enc.enc_type_c in ('1000','1001','1003','101','108','1200','1201','1214','201','2101','2502')
and enc.contact_date >= start_date
and enc.contact_date <= @end_date
and enc.appt_status not in ('4','5')

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
