/* PRIOR TO TOLEDO CONSOLIDATION */

select 
 acct.account_id 
,case when acct.serv_area_id = 11 then 6308
	  when acct.serv_area_id = 13 then 6199
	  when acct.serv_area_id = 16 then 6499
	  when acct.serv_area_id = 17 then 6099
	  when acct.serv_area_id = 18 then 6799
	  when acct.serv_area_id = 19 then 6699
	  else 'Unknown' end as 'PFM_CODE'

from account acct

where 
acct.serv_area_id in (11, 13, 16, 17, 18, 19)
and acct.account_type_c <> '4' -- exclude clearing accounts

order by 
acct.account_id


/* POST TOLEDO CONSOLIDATION */

select 
 acct.account_id 
,case when acct.serv_area_id = 11 then 6308
	  when acct.serv_area_id = 13 then 6199
	  when acct.serv_area_id = 16 then 6499
	  when acct.serv_area_id = 17 then 6099
	  when acct.serv_area_id = 18 then 6799
	  when acct.serv_area_id = 19 then 1111
	  else 'Unknown' end as 'PFM_CODE'

from account acct

where 
acct.serv_area_id in (11, 13, 16, 17, 18, 19)
and acct.account_type_c <> '4' -- exclude clearing accounts

order by 
acct.account_id