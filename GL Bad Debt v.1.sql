/* 11/18/15 BAD DEBT GL
CPT CODE 5002, 6002, 5060
5002 to collection agency
6002 recovery code (patient payment, set for a year with no recovery is terminal debt)
5060 terminal debt

Providers: 1603149
post dates: 5/1 - 5/31
7,232.73
11106127
SWOH

BAD DEBT RECOVERY REPORT
Provider: 1624493
dates: 2/1 - 2/28
6002 + 5060
6,525.19
16102006
LIMA

transaction type = adjustment
*/

select
case when (grouping(b.gl_prefix) = 1) then 'ALL' else isnull(b.gl_prefix, 'UNKNOWN') end as gl_prefix,
case when (grouping(b.department_name) = 1) then 'ALL' else isnull(b.department_name, 'UNKNOWN') end as department_name,
case when (grouping(b.billing_provider) = 1) then 'ALL' else isnull(b.billing_provider, 'UNKNOWN') end as billing_provider,
case when (grouping(b.proc_name) = 1) then 'ALL' else isnull(b.proc_name, 'UNKNOWN') end as proc_name,
sum(b.amount) as amount

from 

(
select 
a.gl_prefix,
a.department_name,
a.proc_name,
case when a.billing_provider is null then 'NO PROVIDER' else billing_provider end as billing_provider,
a.amount

from
(

select 
cast(dep.department_id as varchar) + ' - ' + dep.department_name as department_name,
tdl.tx_id,
tdl.post_date,
eap.proc_code + ' - ' + eap.proc_name as proc_name,
tdl.amount,
case when tdl.billing_provider_id is null then ser2.prov_id + ' - ' + ser2.prov_name else ser.prov_id + ' - ' + ser.prov_name end  as billing_provider,
loc.gl_prefix + ' - ' + dep.gl_prefix as gl_prefix
from clarity_tdl_tran tdl
left join clarity_eap eap on tdl.match_proc_id = eap.proc_id
left join clarity_ser ser on tdl.billing_provider_id = prov_id
left join clarity_tdl_tran tdl2 on tdl.match_trx_id = tdl2.tx_id
left join clarity_ser ser2 on tdl2.billing_provider_id = ser2.prov_id
left join clarity_dep dep on tdl.dept_id = dep.department_id
left join clarity_loc loc on tdl.loc_id = loc.loc_id
where eap.proc_code in ('5002','6002','5060','6021','6000')
and dep.gl_prefix = '485158'
and tdl.post_date between '2015-05-01 00:00:00' and '2015-06-01 00:00:00'
and tdl2.detail_type in (3,4,6) --3 New Debit Adjustment, 4, New Credit Adjustment, 6 Credit Adjustment Reversal


)a

--where billing_provider = '1603149 - AKHTER, FAIQ'

)b

group by gl_prefix, department_name, billing_provider, proc_name with rollup
