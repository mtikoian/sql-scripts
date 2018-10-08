select a.*
from

(select arpb.pat_name, 
       tdl.tx_num,
       tdl.post_date,
       tdl.orig_service_date,
       eap.proc_code,
       eap.proc_name,
       tdl.modifier_one as 'PX_Mod',
       arpb.service_area_id, 
       arpb.service_area_name,
       tdl.tx_id, 
       tdl.orig_amt,
	   tdl.amount as 'Payment_Amt',
       arpb.eob_allowed_amount,
	   arpb.eob_copay_amount,
	   arpb.eob_deduct_amount,
	   arpb.eob_coins_amount,
       arpb.payor_name,
	   epm3.payor_name as 'Matched_Payor',
       arpb.pos_type,
	   tdl.account_id
from clarity_tdl_tran tdl
       left join v_arpb_reimbursement arpb on tdl.match_trx_id = arpb.payment_tx_id
       left join clarity_eap eap on tdl.proc_id = eap.proc_id
       left join zc_cur_fin_class fin on tdl.cur_fin_class = fin.cur_fin_class
	   left join clarity_epm epm3 on tdl.action_payor_id = epm3.payor_id
where detail_type = 20
and fin.name not in ('self-pay')
and orig_service_date >= '01/01/2016'
and orig_service_date < '04/01/2016'
and tdl.serv_area_id in (7,11,12,13,16,17,18,19)
and tdl.orig_amt = arpb.eob_allowed_amount
and tdl.orig_amt <> 0
--and arpb.pos_type in ('home','office','Urgent Care Facility','rural health clinic') -- Non Facility
and arpb.pos_type not in ('home','office','Urgent Care Facility','rural health clinic') --Facility
and eob_line = 1 --eob line is primary key, values are 1 and 6.
--and tx_id in (53416025) --( 40743353 ,41000938 )
)a

inner join

(select min(post_date) minPostDate, tx_id
       from clarity_tdl_tran tdl
       left join v_arpb_reimbursement arpb on tdl.match_trx_id = arpb.payment_tx_id
       left join clarity_eap eap on tdl.proc_id = eap.proc_id
       left join zc_cur_fin_class fin on tdl.cur_fin_class = fin.cur_fin_class
       where detail_type = 20
       and fin.name not in ('self-pay')
       and orig_service_date >= '01/01/2016'
       and orig_service_date < '04/01/2016'
       and tdl.serv_area_id in (7,11,12,13,16,17,18,19)
       and tdl.orig_amt = arpb.eob_allowed_amount
       and tdl.orig_amt <> 0
       --and arpb.pos_type in ('home','office','Urgent Care Facility','rural health clinic') -- Non Facility
       and arpb.pos_type not in ('home','office','Urgent Care Facility','rural health clinic') --Facility
       and eob_line = 1 --eob line is primary key, values are 1 and 6.

       group by tx_id
)b

on a.post_date = b.minPostDate
and a.tx_id = b.tx_id

group by a.pat_name, 
       a.tx_num,
       a.post_date,
       a.orig_service_date,
       a.proc_code,
       a.proc_name,
       a.PX_Mod,
       a.service_area_id, 
       a.service_area_name,
       a.tx_id, 
       a.orig_amt,
	   a.payment_amt,
       a.eob_allowed_amount,
	   a.eob_copay_amount,
	   a.eob_deduct_amount,
	   a.eob_coins_amount,
       a.payor_name,
	   a.matched_payor,
       a.pos_type,
	   a.account_id

order by a.tx_id,a.post_date
