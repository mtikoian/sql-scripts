--SELECT ALL QUALIFYING TDL_ID'S
with tdl_id as
(
select tdl_id
from clarity_tdl_tran tdl
where 
--tdl.cur_payor_id in (2002, 3333, 4088, 4179, 4186, 4236, 4241) -- CARESOURCE
tdl.cur_plan_id = 4179001 -- Caresource Marketplace ACA OH
and tdl.detail_type in (20) -- MATCHED CHARGES TO PAYMENTS
and tdl.serv_area_id in (11,13,16,17,18,19) --MERCY MARKETS
and tdl.orig_service_date >= '1/1/2015' 
--and tdl.orig_service_date <= '12/31/2017'
and tdl.orig_amt > 0
and tdl.tx_id not in (select tx_id from arpb_tx_void) --EXCLUDE VOIDED CHARGES
)

-- JOIN TRANSACTION AND EOB COLUMNS
select *
from
(
select 
 upper(sa.name) as 'REGION'
,loc.loc_name as 'LOCATION'
,dep.department_name as 'DEPARTMENT'
,pos.pos_name as 'POS'
,pos.pos_type as 'POS TYPE'
,pat.pat_first_name as 'PATIENT FIRST NAME'
,pat.pat_last_name as 'PATIENT LAST NAME'
,cast(pat.birth_date as date) as 'DOB'
,coalesce(cov.subscr_num,'') as 'SUBSCRIBER #'
,tdl.tx_id as 'CHG ID'
,cast(tdl.orig_service_date as date) as 'SERVICE DATE'
,ser_bill.prov_id as 'BILLING PROVIDER ID'
,ser_bill.prov_name as 'BILLING PROVIDER'
,coalesce(ser_bill_2.NPI,'') as 'NPI'
,tdl.orig_amt as 'CHG AMT'
--,tdl.match_trx_id as 'PAYMENT ID'
,epm.payor_name as 'PAYOR'
,epp.benefit_plan_name as 'PLAN'
,coalesce(cast(eob.icn as nvarchar),'') as 'ICN'
,coalesce(cast(eob.cvd_amt as nvarchar),'') as 'CVD AMT'
,coalesce(cast(eob.noncvd_amt as nvarchar),'') as 'NONCVD AMT'
,coalesce(cast(eob.ded_amt as nvarchar),'') as 'DED AMT'
,coalesce(cast(eob.copay_amt as nvarchar),'') as 'COPAY AMT'
,coalesce(cast(eob.coins_amt as nvarchar),'') as 'COINS AMT'
--,eob.tdl_id as 'EOB TDL ID'
--,eob.denial_codes as 'DENIAL CODES'
,coalesce(cast(tdl.amount as nvarchar),'') as 'PAYMENT AMT'
,tdl.orig_amt
,row_number() over(partition by tdl.tx_id order by eob.tdl_id desc) as 'ROW#' -- RANK EOB'S IN DESCENDING ORDER TO PULL THE LAST ONE LINKED TO THE CHARGE

from tdl_id
inner join clarity_tdl_tran tdl on tdl.tdl_id = tdl_id.tdl_id
left join clarity_epm epm on epm.payor_id = tdl.cur_payor_id
left join zc_detail_type detail on detail.detail_type = tdl.detail_type
left join pmt_eob_info_i eob on eob.tdl_id = tdl.tdl_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join clarity_ser ser_bill on ser_bill.prov_id = tdl.billing_provider_id
left join clarity_ser_2 ser_bill_2 on ser_bill_2.prov_id = ser_bill.prov_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join coverage cov on cov.coverage_id = tdl.cur_cvg_id
left join clarity_epp epp on epp.benefit_plan_id = tdl.cur_plan_id
where eob.denial_codes is null

group by 
 sa.name
,loc.loc_name
,dep.department_name
,pos.pos_name
,pos.pos_type
,pat.pat_first_name
,pat.pat_last_name
,pat.birth_date
,cov.subscr_num
,tdl.tx_id
,tdl.orig_service_date
,ser_bill.prov_id
,ser_bill.prov_name
,ser_bill_2.NPI
,tdl.orig_amt
--,tdl.match_trx_id
,epm.payor_name
,epp.benefit_plan_name
,eob.icn
,eob.cvd_amt
,eob.noncvd_amt
,eob.ded_amt
,eob.copay_amt
,eob.coins_amt
,eob.tdl_id
--,eob.denial_codes
,tdl.amount
,tdl.orig_amt
)a

where row# = 1  -- ONLY PULL LAST EOB
order by a.[CHG ID] asc