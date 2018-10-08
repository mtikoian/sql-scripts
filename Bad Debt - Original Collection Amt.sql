--595205 rows

declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-17')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-4');

with charges as
(
select 
 upper(sa.name) as 'Region'
,dep.rpt_grp_two as 'Department'
,pos.pos_name as 'Place of Service'
,pos_type.name as 'POS Type'
,dep.specialty as 'Specialty'
,dep16.name as 'Service Line'
,tdl.tx_id as 'Chg ID'
,cast(tdl.orig_service_date as date) as 'Service Date'
,cast(tdl.orig_post_date as date) as 'Chg Post Date'
,eap_chg.proc_code as 'Proc Code'
,eap_chg.proc_name as 'Proc Desc'
,epm.payor_name as 'Original Payor'
,tdl.orig_amt as 'Chg Amt'
,tdl.match_trx_id as 'Adj ID'
,date.year_month as 'Adj Month'
,cast(tdl.post_date as date) as 'Adj Post Date'
,eap.proc_code as 'Adj Code'
,eap.proc_name as 'Adj Desc'
,tdl.amount as 'Adj Amt'
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.post_date asc) as Row#

from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.match_proc_id -- matched procedure id
left join clarity_epm epm on epm.payor_id = tdl.original_payor_id -- original payor
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join zc_dep_rpt_grp_16 dep16 on dep16.rpt_grp_sixteen_c = dep.rpt_grp_sixteen_c
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join zc_pos_type pos_type on pos_type.pos_type_c = pos.pos_type_c
left join clarity_eap eap_chg on eap.proc_id = tdl.proc_id 
left join date_dimension date on date.calendar_dt = tdl.post_date

where tdl.serv_area_id in (11,13,16,17,18,19)
and eap.proc_code in ('5002') --COLLECTIONS BAD DEBT WRITE OFF (ACCOUNT)
and tdl.detail_type in (21) -- MATCH/UNMATCH (CHARGE->CREDIT ADJUSTMENT)
and arpb_tx.void_date is null--exclude voids
and tdl.amount < 0
group by
 sa.name
,dep.rpt_grp_two
,pos.pos_name
,pos_type.name
,dep.specialty
,dep16.name
,tdl.tx_id
,tdl.orig_service_date
,tdl.orig_post_date
,eap_chg.proc_code
,eap_chg.proc_name
,epm.payor_name
,tdl.orig_amt
,tdl.match_trx_id
,date.year_month
,tdl.post_date
,eap.proc_code
,eap.proc_name
,tdl.amount
),

eob as
(select 
 eob.tx_id as 'Pymnt ID'
,tdl.tx_id as 'Matched Chg ID'
,cast(tdl.post_date as date) as 'Pymnt Date'
,eob.cvd_amt as 'CVD Amt'
,eob.noncvd_amt as 'NonCVD Amt'
,eob.ded_amt as 'Ded Amt'
,eob.copay_amt as 'Copay Amt'
,eob.coins_amt as 'Coins Amt'
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY eob.tdl_id desc) as Row#
from pmt_eob_info_i eob
left join clarity_tdl_tran tdl on tdl.tdl_id = eob.tdl_id
inner join charges on charges.[chg id] = tdl.tx_id
group by 
 eob.tx_id
,eob.tdl_id
,tdl.tx_id
,tdl.post_date
,eob.cvd_amt
,eob.noncvd_amt
,eob.ded_amt
,eob.copay_amt
,eob.coins_amt
)

select 
 [Region]
,[Department]
,[Place of Service]
,[POS Type]
,[Specialty]
,[Service Line]
,[Chg ID]
,[Service Date]
,[Chg Post Date]
,[Proc Code]
,[Proc Desc]
,[Original Payor]
,[Chg Amt]
,[Adj ID]
,[Adj Month]
,[Adj Post Date]
,[Adj Code]
,[Adj Desc]
,[Adj Amt]
,[Pymnt ID]
,[Pymnt Date]
,[CVD Amt]
,[NonCVD Amt]
,[Ded Amt]
,[Copay Amt]
,[Coins Amt]
from charges
left join eob on eob.[matched chg id] = charges.[chg id]
where charges.row# = 1
and (eob.row# = 1 or eob.row# is null)
and [Adj Post Date] >= @start_date
and [Adj Post Date] <= @end_date;