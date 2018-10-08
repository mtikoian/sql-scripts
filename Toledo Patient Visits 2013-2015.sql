select 

*

from

(
select 

int_pat_id
,sum(a.[2013]) as '2013'
,sum(a.[2014]) as '2014'
,sum(a.[2015]) as '2015'

from 

(

select 

int_pat_id
,case when post_date >= '2013-01-01' and post_date < '2014-01-01' then PROCEDURE_QUANTITY else 0 end as '2013'
,case when post_date >= '2014-01-01' and post_date < '2015-01-01' then PROCEDURE_QUANTITY else 0 end as '2014'
,case when post_date >= '2015-01-01' and post_date < '2016-01-01' then PROCEDURE_QUANTITY else 0 end as '2015'

from CLARITY_TDL_TRAN 

where serv_area_id = 18
and post_date >= '2013-01-01'
and post_date < '2016-01-01'
and detail_type = 1

)a

group by a.int_pat_id


)b

where [2013] <> 0 
and [2014] <> 0 
and [2015] <>0

order by int_pat_id