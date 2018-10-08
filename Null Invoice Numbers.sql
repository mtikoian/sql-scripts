select 
	clarity_tdl_tran_charges.charge_slip_number as 'Charge Slip Number',
	clarity_tdl_tran_charges.orig_service_date as 'Date of Service',
	clarity_tdl_tran_charges.post_date as 'Date of Transaction',
	clarity_tdl_tran_charges.cpt_code as 'CPT',
	clarity_tdl_tran_charges.tx_id as 'Transaction ID',
	case when detail_type = 1 then clarity_tdl_tran_charges.amount else 0 end as 'Charges',
	case when detail_type = 20 then clarity_tdl_tran_charges.amount else 0 end as 'Payments',
	case when detail_type = 21 then clarity_tdl_tran_charges.amount else 0 end as 'Adjustments',
	case when detail_type = 50 then clarity_tdl_tran_charges.invoice_number else 0 end as 'Invoice Number',
	procedure_quantity,
	detail_type,*
from clarity_tdl_tran clarity_tdl_tran_charges
where clarity_tdl_tran_charges.tx_id in (45555858,46092689,48260109,53152570,54130717,57511138,32848222,40087070,42263598,40742900,4219959)
and clarity_tdl_tran_charges.detail_type in (1,20,21,50)

order by [Transaction ID]

