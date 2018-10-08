
select 
loc.loc_name as 'Location'
,dep.department_name as 'Department'
,fc.name as 'Current FC'
,cast(acct.account_id as varchar) + ' - ' + acct.account_name as 'Account'
,case when detail_type = 60 then 'Debit AR'
      when detail_type = 60 and amount < 0 then 'Debit AR - Credit Balance'
	  when detail_type = 61 then 'Credit AR'
	  end as 'AR Type'
,age.pat_aging_days
,case when age.pat_aging_days is not null and pat_aging_days <= 30 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) <= 30 then amount else 0 end as '0 - 30' 
,case when age.pat_aging_days is not null and pat_aging_days between 31 and 60 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 31 and datediff(dd,age.orig_post_date, age.post_date) <= 60 then amount else 0 end as '31 - 60' 
,case when age.pat_aging_days is not null and pat_aging_days between 61 and 90 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 61 and datediff(dd,age.orig_post_date, age.post_date) <= 90 then amount else 0 end as '61 - 90' 
,case when age.pat_aging_days is not null and pat_aging_days between 91 and 120 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 91 and datediff(dd,age.orig_post_date, age.post_date) <= 120  then amount else 0 end as '91 - 120' 
,case when age.pat_aging_days is not null and pat_aging_days between 121 and 180 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 121 and datediff(dd,age.orig_post_date, age.post_date) <= 180  then amount else 0 end as '121 - 180' 
,case when age.pat_aging_days is not null and pat_aging_days between 181 and 270 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 181 and datediff(dd,age.orig_post_date, age.post_date) <= 270  then amount else 0 end as '181 - 270' 
,case when age.pat_aging_days is not null and pat_aging_days between 271 and 365 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 271 and datediff(dd,age.orig_post_date, age.post_date) <= 365  then amount else 0 end as '271 - 365' 
,case when age.pat_aging_days is not null and pat_aging_days >= 366 then amount
	  when age.pat_aging_days is null and datediff(dd,age.orig_post_date, age.post_date) >= 366 then amount else 0 end as '>= 366' 
,age.amount as 'Total'

from clarity_tdl_age age
left join zc_fin_class fc on fc.fin_class_c = age.cur_fin_class
left join clarity_dep dep on dep.department_id = age.dept_id
left join clarity_loc loc on loc.loc_id = age.loc_id
left join account acct on acct.account_id = age.account_id
left join arpb_tx_moderate atm on atm.tx_id = age.tx_id
where age.serv_area_id = 1312
and tdl_extract_date = '2/1/2017'
and fc.name = 'self-pay'
