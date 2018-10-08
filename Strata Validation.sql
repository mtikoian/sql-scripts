select 
Year_Month
,case when detail_type in (1,10) then 'Charges'
      when detail_Type in (2,5,11) then 'Payments'
	  when detail_type in (3,4,6,12,13) then 'Adjustments'
	  when detail_type in (20,22) then 'Matched Payments - Credit'
	  when detail_type in (32,33) then 'Matched Payments - Debit'
	  when detail_type in (21,23) then 'Match Adjustments - Credit'
	  when detail_type in (30,31) then 'Matched Adjustmetns - Debit'
	  end as 'Transaction Type'

,sum(Amount) as Amount
from clarity_tdl_tran tdl
left join date_dimension date on date.calendar_dt_str = tdl.post_date 
where post_date >= '1/1/2016'
and post_date <= '3/31/2017'
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.detail_type <= 33
group by year_month
,case when detail_type in (1,10) then 'Charges'
      when detail_Type in (2,5,11) then 'Payments'
	  when detail_type in (3,4,6,12,13) then 'Adjustments'
	  when detail_type in (20,22) then 'Matched Payments - Credit'
	  when detail_type in (32,33) then 'Matched Payments - Debit'
	  when detail_type in (21,23) then 'Match Adjustments - Credit'
	  when detail_type in (30,31) then 'Matched Adjustmetns - Debit'
	  end