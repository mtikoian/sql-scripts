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
,sum(appt.copay_collected) as 'COPAY COLLECTED'
,sum(appt.copay_due) as 'COPAY DUE'

from v_sched_appt appt 
inner join pat_enc enc on enc.pat_enc_csn_id = appt.pat_enc_csn_id   
inner join v_cube_d_billing_dates date on date.calendar_dt = appt.contact_date
left join clarity_dep dep on dep.department_id = appt.department_id
left join clarity_ser ser_visit on ser_visit.prov_id = appt.prov_id
left join clarity_prc prc on prc.prc_id = appt.prc_id
left join clarity_emp emp_copay on emp_copay.user_id = appt.copay_user_id
left join pat_enc_3 enc3 on enc3.pat_enc_csn = appt.pat_enc_csn_id
left join v_coverage_payor_plan cov on (appt.contact_date>=cov.eff_date and appt.contact_date <= term_date) and appt.coverage_id = cov.coverage_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join clarity_emp emp_checkin on emp_checkin.user_id = enc.checkin_user_id
left join clarity_ser ser_pcp on ser_pcp.prov_id = enc.pcp_prov_id

where   
enc.appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= @start_date
and enc.contact_date <= @end_date
and prc.benefit_group in ('Office Visit','PB Copay','Copay')
and enc.copay_due > 0
and enc.pat_enc_csn_id <> 131850458
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

and appt.loc_id not in ('11104','11105','18101','11110') 
and appt.department_id not in ('13105161','13105154','13105187','13105174','1301192','13101186','13101187','13101191','13103116','13103164','13103165','13103166','131031161','16102050','16106108','16106112','16107104','16108104','16109113','16109115','16111101','16102042','16102043','16102028')

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

) as copay

order by region, month
