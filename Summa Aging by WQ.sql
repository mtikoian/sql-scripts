/*workqueue aging summa as of november 30
3 reports
claim edit
follow up - follow up history wqf fol_info fol_history
charge review
wkq id, name, owining area, outstanding amount in wkg
service date
day entered and left
compare to 11/30
group gy wkq id
*/

with entered as
(
select fh.fol_id
from fol_history fh
inner join fol_info fi on fh.fol_id = fi.fol_id
where fi.service_area_id = 1312 -- Summa
and fh.act_type_c = 10
),

completed as
(
select fh.fol_id
from fol_history fh
inner join fol_info fi on fh.fol_id = fi.fol_id
where fi.service_area_id = 1312 -- Summa
and fh.act_type_c = 27 
and fh.act_date > '11/30/2017'
)

select *
from entered
left join completed on completed.fol_id = entered.fol_id
where completed.fol_id is null


