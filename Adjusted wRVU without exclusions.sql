select sum(rvu_work)
from
(
select rvu_work * procedure_quantity as rvu_work
from clarity_tdl_tran
where detail_type in (1,10)
and serv_area_id = 17
and post_date >= '2016-01-01'
and post_date < = '2016-01-08'
)a

select sum(rvu_work)
from
(
select rvu_work * procedure_quantity as rvu_work
from clarity_tdl_tran
where detail_type in (1,10)
and serv_area_id = 17
and post_date >= '2016-01-09'
and post_date < = '2016-01-20'
)a

select sum(rvu_work)
from
(
select rvu_work * procedure_quantity as rvu_work
from clarity_tdl_tran
where detail_type in (1,10)
and serv_area_id = 17
and post_date >= '2016-01-21'
and post_date < = '2016-01-31'
)a