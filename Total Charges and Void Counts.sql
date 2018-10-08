select date.year_month as 'post_month'
,case when detail_type in (1,10) and (post_date >= '2015-01-01 00:00:00' and post_date < '2015-07-01 00:00:00') then count(*) else 0 end as 'total charges'
,case when detail_type = 10 and orig_post_date < '2015-01-01 00:00:00' and post_date >= '2015-01-01 00:00:00'  then count(*) else 0 end as 'void_count'

from clarity_tdl_tran tdl
left join v_cube_d_billing_dates date on tdl.post_date = date.calendar_dt


where serv_area_id in (11,13,16,17,18,19,21,1302)


and (modifier_one in ('22','50','51','52','53','54','55','56','62','74','76','78','80','82','AS','TC')
or modifier_two in ('22','50','51','52','53','54','55','56','62','74','76','78','80','82','AS','TC'))

and (tdl.CPT_CODE NOT IN ('90460', '90461', '90471', '90472', '90473', '90474', '96360', '96365', '96401', '96413', '96415', '96420', '96422', '96423', 
'96425', '96440', '96446', '96450', '96542', '96361', '96366', '96367', '96368', '96369', '96370', '96371', '96372', '96373', '96374', '96375', '96376'
, '96379', '96402', '96405', '96406', '96409', '96411', '96416', '96417', '96523')
 OR tdl.CPT_CODE IS NULL)

 group by date.year_month, post_date, orig_post_date, detail_type
 order by date.year_month