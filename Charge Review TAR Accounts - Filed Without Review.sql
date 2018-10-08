select 
    loc_id,
    pre_ar_chg.tar_id, --Tar .1
	service_date,
	file_date,
	zc_charge_status.name, --TAR 70001
	pre_ar_chg.pat_id, -- TAR 70060
	pat.pat_name, -- PAT .2
	pre_ar_chg.account_id, -- TAR 70050
	pre_ar_chg.amount,
	pre_ar_chg.proc_id,
	proc_name,
	proc_code,
	SESS_BILL_PROV_ID,
	prov_name
	



from 
pre_ar_chg pre_ar_chg 
left join patient pat on pre_ar_chg.pat_id = pat.pat_id
left join zc_charge_status on pre_ar_chg.charge_status_c = zc_charge_status.charge_status_C
left join pre_ar_chg_2 pre_ar_chg_2 on pre_ar_chg.tar_id = pre_ar_chg_2.tar_id and pre_ar_chg.charge_line = pre_ar_chg_2.charge_line
left join clarity_eap clarity_eap on pre_ar_chg.proc_id = clarity_eap.proc_id
left join clarity_ser clarity_ser on pre_ar_chg.sess_bill_prov_id = clarity_ser.prov_id

where 

pre_ar_chg.charge_status_c = 1 -- FILED WITHOUT REVIEW
and service_date >= '2015-06-01 00:00:00'
and pre_ar_chg.loc_id in (11132, 11138)
--and pre_ar_chg.tar_id = 135041879


order by tar_id

