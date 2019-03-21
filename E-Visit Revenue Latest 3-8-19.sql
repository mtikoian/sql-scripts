with charges as 
(
select 
 loc.RPT_GRP_TEN
,dep.DEPARTMENT_NAME
,tdl.TX_ID
,sum(tdl.AMOUNT) as 'CHG_AMT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join CLARITY_DEP dep on dep .DEPARTMENT_ID = tdl.DEPT_ID

where tdl.DETAIL_TYPE in (1,10) -- Charge matched to payment
and eap.PROC_CODE in ('99444','98969')
and tdl.POST_DATE >= '3/1/2018'
and tdl.POST_DATE <= '2/28/2019'
and loc.rpt_grp_ten in (1,11,13,16,17,18,19)

group by loc.RPT_GRP_TEN, dep.DEPARTMENT_NAME, tdl.TX_ID
),

matched as
(
select 
 charges.TX_ID
,case when tdl.DETAIL_TYPE = 20 then 'Payment' else 'Adjustment' end as Type
,tdl.AMOUNT

from charges
left join CLARITY_TDL_TRAN tdl on tdl.TX_ID = charges.TX_ID

where tdl.DETAIL_TYPE in (20,21) -- matched payments and adjustments

and tdl.POST_DATE <= '2/28/2019'
)

select 
 charges.RPT_GRP_TEN
,charges.DEPARTMENT_NAME
,charges.TX_ID
,avg(charges.CHG_AMT) as Charge
,sum(case when matched.type = 'Payment' then matched.AMOUNT *-1 end) as 'Payment'
,sum(case when matched.type = 'Adjustment' then matched.AMOUNT *-1 end) as 'Adjustment'
from charges
left join matched on matched.TX_ID = charges.TX_ID
group by 
 charges.RPT_GRP_TEN
,charges.DEPARTMENT_NAME
,charges.TX_ID
order by 
 charges.RPT_GRP_TEN
,charges.DEPARTMENT_NAME
 ,charges.TX_ID
