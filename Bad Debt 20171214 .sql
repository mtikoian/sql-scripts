declare @start_date as date = DATEADD(month,-17,CONVERT(DATETIME, CONVERT(VARCHAR(7), getdate(), 120) + '-01'))
declare @end_date as date = DATEADD(day,-1,DATEADD(month,-3,CONVERT(DATETIME, CONVERT(VARCHAR(7), getdate(), 120) + '-01')));

with charges as
(select
*
from
(select 
 tdl.tx_id
,tdl.match_trx_id
,tdl.post_date
,tdl.loc_id
,tdl.dept_id
,tdl.pos_id
,tdl.account_id
,tdl.orig_service_date
,tdl.orig_post_date
,tdl.proc_id
,tdl.original_payor_id
,tdl.orig_amt
,tdl.match_proc_id
,tdl.amount
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.post_date asc) as Row#
from clarity.dbo.clarity_tdl_tran tdl
left join clarity.dbo.arpb_tx_void atv on atv.tx_id = tdl.tx_id
where tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.match_proc_id = 7064 --COLLECTIONS BAD DEBT WRITE OFF (ACCOUNT)
and tdl.detail_type in (21) -- MATCH/UNMATCH (CHARGE->CREDIT ADJUSTMENT)
and atv.tx_id is null
group by 
 tdl.tx_id
,tdl.match_trx_id
,tdl.post_date
,tdl.loc_id
,tdl.dept_id
,tdl.pos_id
,tdl.account_id
,tdl.orig_service_date
,tdl.orig_post_date
,tdl.proc_id
,tdl.original_payor_id
,tdl.orig_amt
,tdl.match_proc_id
,tdl.amount
)a

where row# = 1
),

eob as
(select *
from 
(select 
 tdl.tx_id
,tdl.post_date
,eob.paid_amt
,eob.cvd_amt
,eob.noncvd_amt
,eob.ded_amt
,eob.copay_amt
,eob.coins_amt
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY eob.tdl_id desc) as Row#
from charges
left join clarity.dbo.clarity_tdl_tran tdl on tdl.tx_id = charges.tx_id
left join clarity.dbo.pmt_eob_info_i eob on eob.tdl_id = tdl.tdl_id
where 
detail_type = 20 -- MATCH/UNMATCH (CHARGE->PAYMENT)
group by 
 tdl.tx_id
,eob.tdl_id
,tdl.post_date
,eob.paid_amt
,eob.cvd_amt
,eob.noncvd_amt
,eob.ded_amt
,eob.copay_amt
,eob.coins_amt
)a
where row# = 1
)

select 
 charges.tx_id as 'Chg ID'
,charges.match_trx_id as 'Adj ID'
,charges.post_date as 'Adj Post Date'
,upper(sa.name) as 'Region'
,loc.loc_name as 'Location'
,dep.department_name as 'Department'
,dep.specialty as 'Specialty'
,dep16.name as 'Service Line'
,pos.pos_name as 'POS'
,pos.pos_type as 'POS Type'
,charges.account_id as 'Account'
,charges.orig_service_date as 'Service Date'
,charges.orig_post_date as 'Chg Post Date'
,epm.payor_name as 'Original Payor'
,eap_chg.proc_code as 'Proc Code'
,eap_chg.proc_name as 'Proc Desc'
,charges.orig_amt as 'Charge Amt'
,eap_adj.proc_code as 'Adj Code'
,eap_adj.proc_name as 'Adj Desc'
,charges.amount as 'Adj Amount'
,eob.tx_id as 'Pymnt ID'
,charges.tx_id as 'Matched Chg ID'
,charges.post_date as 'Pymnt Date'
,eob.paid_amt as 'Pymnt Amt'
,eob.cvd_amt as 'CVD Amt'
,eob.noncvd_amt as 'NonCVD Amt'
,eob.ded_amt as 'Ded Amt'
,eob.copay_amt as 'Copay Amt'
,eob.coins_amt as 'Coins Amt'
,date.year_month as 'Adj Month'
,case when eob.row# is null then 'Self-Pay' else 'Insurance' end as 'Coverage'

from charges
left join eob on eob.tx_id = charges.tx_id
left join clarity.dbo.clarity_loc loc on loc.loc_id = charges.loc_id
left join clarity.dbo.zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity.dbo.clarity_pos pos on pos.pos_id = charges.pos_id
left join clarity.dbo.clarity_dep dep on dep.department_id = charges.dept_id
left join clarity.dbo.zc_dep_rpt_grp_16 dep16 on dep16.rpt_grp_sixteen_c = dep.rpt_grp_sixteen_c
left join clarity.dbo.clarity_eap eap_chg on eap_chg.proc_id = charges.proc_id
left join clarity.dbo.clarity_epm epm on epm.payor_id = charges.original_payor_id
left join clarity.dbo.clarity_eap eap_adj on eap_adj.proc_id = charges.match_proc_id
left join clarity.dbo.date_dimension date on date.calendar_dt = charges.post_date
where charges.post_date >= @start_date
and charges.post_date <= @end_date

order by charges.tx_id asc
