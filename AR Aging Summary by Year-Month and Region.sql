declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('12/31/2017')

select 

 dd.year as 'Year'
,dd.year_month as 'Year-Month'
,case when loc.loc_id in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_ten in ('11') then 'CINCINNATI'
	 when loc.rpt_grp_ten in ('13') then 'YOUNGSTOWN'
	 when loc.rpt_grp_ten in ('16') then 'LIMA'
	 when loc.rpt_grp_ten in ('17') then 'LORAIN'
	 when loc.loc_id in ('18120','18121','19120','19127') then 'DEFIANCE'
	 when loc.rpt_grp_ten in ('18')  then 'TOLEDO'
	 when loc.rpt_grp_ten in ('19') then 'KENTUCKY' 
	 when loc.rpt_grp_ten in ('1') then 'MERCY HEALTH' 
	 else 'UNKNOWN REGION'
	 end as 'Region'
--,case when loc.loc_name is null then 'UNKNOWN LOCATION'
--	else upper(loc.loc_name) + ' [' + cast(loc.loc_id as nvarchar) + ']' end as 'Location'
--,loc.gl_prefix + ' - ' + loc.loc_name as 'Revenue Location'
--,loc.gl_prefix as 'Location GL'
--,case when dep.department_name is null then 'UNKNOWN DEPARTMENT' 
--	else upper(dep.department_name) + ' [' + cast(dep.department_id as nvarchar) + ']' end as 'Department'
--,sa.gl_prefix + ' - ' + dep.gl_prefix + ' - ' + dep.department_name as 'Full Department'
--,dep.gl_prefix as 'Department GL'
--,case when pos.pos_name is null then 'UNKNOWN PLACE OF SERVICE'
--	else upper(pos.pos_name) + ' [' + cast(pos.pos_id as nvarchar) + ']' end as 'Place of Service'
--,case when ser_bill.prov_name is null then 'UNKNOWN BILLING PROVIDER'
--	else ser_bill.prov_name + ' [' + cast(ser_bill.prov_id as varchar) + ']' end as 'Billing Provider'
--,case when ser_perf.prov_name is null then 'UNKNOWN SERVICE PROVIDER' 
--	else ser_perf.prov_name + ' [' + cast(ser_perf.prov_id as varchar) + ']' end as 'Service Provider'
--,epm_orig.payor_name + ' [' + cast(epm_orig.payor_id as varchar) + ']' as 'Original Payor'
--,epm_cur.payor_name + ' [' + cast(epm_cur.payor_id as varchar) + ']' as 'Current Payor'
--,orig_fc.name + ' [' + orig_fc.fin_class_c + ']' as 'Original FC'
--,orig_fc.name as 'Original Financial Class'
--,cur_fc.name + ' [' + cur_fc.fin_class_c + ']' as 'Current FC'
--,eap.proc_name + ' [' + eap.proc_code + ']' as 'Procedure'
--,case when age.amount > 0 and detail_type = 60 then 'Debit AR - Positive Debits'
--   when age.amount < 0 and detail_type = 60 then 'Debit AR - Credit Balance'
--   when detail_type = 61 then 'Credit AR'
----   when detail_type in  (60,61) then 'Combined AR'
--   end as 'AR Type'
,sum(case when age.post_date - age.orig_post_date <= 30 then amount else 0 end) as '0 - 30'
,sum(case when age.post_date - age.orig_post_date >= 31 and age.post_date - age.orig_post_date <= 60 then amount else 0 end) as '31 - 60'
,sum(case when age.post_date - age.orig_post_date >= 61 and age.post_date - age.orig_post_date <= 90 then amount else 0 end) as '61 - 90'
,sum(case when age.post_date - age.orig_post_date >= 91 and age.post_date - age.orig_post_date <= 120 then amount else 0 end) as '91 - 120'
,sum(case when age.post_date - age.orig_post_date >= 121 and age.post_date - age.orig_post_date <= 180 then amount else 0 end) as '121 - 180'
,sum(case when age.post_date - age.orig_post_date >= 181 and age.post_date - age.orig_post_date <= 270 then amount else 0 end) as '181 - 270'
,sum(case when age.post_date - age.orig_post_date >= 271 and age.post_date - age.orig_post_date <= 365 then amount else 0 end) as '271 - 365'
,sum(case when age.post_date - age.orig_post_date > 365 then amount else 0 end) as '+ 365'
,sum(age.amount) as 'Amount'

from clarity.dbo.clarity_tdl_age age
left join clarity.dbo.clarity_loc loc on loc.loc_id = age.loc_id
left join clarity.dbo.clarity_dep dep on dep.department_id = age.dept_id
left join clarity.dbo.zc_loc_rpt_grp_10 loc_grp on loc_grp.rpt_grp_ten = loc.rpt_grp_ten
left join clarity.dbo.clarity_pos pos on pos.pos_id = age.pos_id
left join clarity.dbo.clarity_ser ser_bill on ser_bill.prov_id = age.billing_provider_id
left join clarity.dbo.clarity_ser ser_perf on ser_perf.prov_id = age.performing_prov_id
left join clarity.dbo.zc_fin_class orig_fc on orig_fc.fin_class_c = age.original_fin_class
left join clarity.dbo.zc_fin_class cur_fc on cur_fc.fin_class_c = age.cur_fin_class
left join clarity.dbo.clarity_epm epm_cur on epm_cur.payor_id = age.cur_payor_id
left join clarity.dbo.clarity_epm epm_orig on epm_orig.payor_id = age.original_payor_id
left join clarity.dbo.account acct on acct.account_id = age.account_id
left join clarity.dbo.date_dimension dd on dd.calendar_dt_str = age.post_date
left join clarity.dbo.clarity_eap eap on eap.proc_id = age.proc_id
left join clarity.dbo.clarity_sa sa on sa.serv_area_id = loc.rpt_grp_ten

where loc_grp.rpt_grp_ten in (1,11,13,16,17,18,19)
and age.post_date >= @start_date
and age.post_date <= @end_date

group by
dd.year
,dd.year_month
,case when loc.loc_id in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_ten in ('11') then 'CINCINNATI'
	 when loc.rpt_grp_ten in ('13') then 'YOUNGSTOWN'
	 when loc.rpt_grp_ten in ('16') then 'LIMA'
	 when loc.rpt_grp_ten in ('17') then 'LORAIN'
	 when loc.loc_id in ('18120','18121','19120','19127') then 'DEFIANCE'
	 when loc.rpt_grp_ten in ('18')  then 'TOLEDO'
	 when loc.rpt_grp_ten in ('19') then 'KENTUCKY' 
	 when loc.rpt_grp_ten in ('1') then 'MERCY HEALTH' 
	 else 'UNKNOWN REGION' end

order by
dd.year
,dd.year_month
,case when loc.loc_id in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_ten in ('11') then 'CINCINNATI'
	 when loc.rpt_grp_ten in ('13') then 'YOUNGSTOWN'
	 when loc.rpt_grp_ten in ('16') then 'LIMA'
	 when loc.rpt_grp_ten in ('17') then 'LORAIN'
	 when loc.loc_id in ('18120','18121','19120','19127') then 'DEFIANCE'
	 when loc.rpt_grp_ten in ('18')  then 'TOLEDO'
	 when loc.rpt_grp_ten in ('19') then 'KENTUCKY' 
	 when loc.rpt_grp_ten in ('1') then 'MERCY HEALTH' 
	 else 'UNKNOWN REGION' end



