-- *** PIVOT / CROSSTAB Query per Transaction - Ver 2.0 ***
Select
	  [Chrg_Dtl].Tx_ID												As 'Transaction ID'

	, Max([Chrg_Dtl].Charge_Slip_Number)							As 'Charge Slip Number'
	, Convert(Varchar(10), Max([Chrg_Dtl].Orig_Service_Date), 101)	As 'Date of Service'
	, Convert(Varchar(10), Max([Chrg_Dtl].Orig_Post_Date), 101)		As 'Date of Transaction'
	, Max([Chrg_Dtl].CPT_Code)										As 'CPT'

	, Sum(CASE	When [Chrg_Dtl].Detail_Type In (1) 
				Then [Chrg_Dtl].Amount Else 0 END)					As 'Charges'
	, Sum(CASE	When [Chrg_Dtl].Detail_Type In (20) 
				Then [Chrg_Dtl].Amount Else 0 END)					As 'Payments'
	, Sum(CASE	When [Chrg_Dtl].Detail_Type In (21) 
				Then [Chrg_Dtl].Amount Else 0 END)					As 'Adjustments'
	, Max(CASE	When [Chrg_Dtl].Detail_Type In (50) 
				Then [Chrg_Dtl].Invoice_Number Else Null END)		As 'Invoice Number'
	, Sum([Chrg_Dtl].Procedure_Quantity)							As 'Units'

From	(
			-- *** DETAIL Query For Charges ***
			Select 
					clarity_tdl_tran_charges.charge_slip_number,
					clarity_tdl_tran_charges.orig_service_date,
					clarity_tdl_tran_charges.orig_post_date,
					clarity_tdl_tran_charges.cpt_code,
					clarity_tdl_tran_charges.tx_id,
					clarity_tdl_tran_charges.detail_type,
					clarity_tdl_tran_charges.amount,
					clarity_tdl_tran_charges.invoice_number,
					clarity_tdl_tran_charges.procedure_quantity
			From clarity_tdl_tran clarity_tdl_tran_charges
			Where clarity_tdl_tran_charges.detail_type in (1,20,21,50)
			And clarity_tdl_tran_charges.tx_id in (45555858, 46092689, 48260109,53152570,54130717,57511138,32848222,40087070,42263598,40742900,42129959,47091118)
		) As Chrg_Dtl

Group By [Chrg_Dtl].Tx_ID
;
