select 
    pre_ar_chg.serv_area_id,
	serv_area_name,
	sess_dept_id,
	clarity_dep.department_name,
    pre_ar_chg.tar_id, --Tar .1
	arpb_transactions.tx_id,
	pre_ar_chg.service_date,
	file_date,
	zc_charge_status.name, --TAR 70001
	pre_ar_chg.pat_id, -- TAR 70060
	pat.pat_name, -- PAT .2
	pre_ar_chg.account_id, -- TAR 70050
	pre_ar_chg.amount,
	outstanding_amt,
	proc_code,
	proc_name,
	SESS_BILL_PROV_ID,
	prov_name,
	ext_modifier,
	clarity_ucl.charge_source_c


from 
pre_ar_chg pre_ar_chg 
left join patient pat on pre_ar_chg.pat_id = pat.pat_id
left join zc_charge_status on pre_ar_chg.charge_status_c = zc_charge_status.charge_status_C
left join pre_ar_chg_2 pre_ar_chg_2 on pre_ar_chg.tar_id = pre_ar_chg_2.tar_id and pre_ar_chg.charge_line = pre_ar_chg_2.charge_line
left join clarity_eap clarity_eap on pre_ar_chg.proc_id = clarity_eap.proc_id
left join clarity_ser clarity_ser on pre_ar_chg.sess_bill_prov_id = clarity_ser.prov_id
left join chg_review_mods on pre_ar_chg.tar_id = chg_review_mods.tar_id
left join clarity_dep on pre_ar_chg.sess_dept_id = clarity_dep.department_id
left join clarity_ucl on pre_ar_chg_2.CHRG_ROUTER_SRC_ID = clarity_ucl.ucl_id
left join arpb_transactions on pre_ar_chg.tx_id = arpb_transactions.tx_id
left join clarity_sa on pre_ar_chg.serv_area_id = clarity_sa.serv_area_id

where ha

--pre_ar_chg.charge_status_c = 1 -- FILED WITHOUT REVIEW
pre_ar_chg.service_date >= '2014-01-01 00:00:00'
and chg_review_mods.ext_modifier = '25'
and clarity_ucl.charge_source_c = 2 -- EpicCare
and arpb_transactions.tx_type_c = 1 -- Charge
--and arpb_transactions.outstanding_amt > 0
and pre_ar_chg.serv_area_id < 30
and arpb_transactions.tx_id = 40989935

order by tar_id

