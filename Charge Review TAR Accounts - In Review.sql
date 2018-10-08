select 

	V_ARPB_CHG_REVIEW_WQ.tar_id, --TAR .1
	default_svc_date, --TAR 120
	zc_charge_status.name, --TAR 70001
	pre_ar_chg.charge_line,
	pre_ar_chg.pat_id, -- TAR 70060
	pat.pat_name, -- PAT .2
	pre_ar_chg.account_id, -- TAR 70050
	case when V_ARPB_CHG_REVIEW_WQ.amount is null then 0 else V_ARPB_CHG_REVIEW_WQ.amount end as amount,
	zc_charge_status.name, -- TAR 70001
	pre_ar_chg.serv_area_id, --TAR 70040
	V_ARPB_CHG_REVIEW_WQ.workqueue_nm_Wid,
	V_ARPB_CHG_REVIEW_WQ.entry_date,
	V_ARPB_CHG_REVIEW_WQ.exit_date
from 
V_ARPB_CHG_REVIEW_WQ V_ARPB_CHG_REVIEW_WQ 
left join pre_ar_chg pre_ar_chg on V_ARPB_CHG_REVIEW_WQ.tar_id = pre_ar_chg.tar_id
left join patient pat on pre_ar_chg.pat_id = pat.pat_id
left join zc_charge_status on pre_ar_chg.charge_status_c = zc_charge_status.charge_status_C
left join pre_ar_chg_2 pre_ar_chg_2 on pre_ar_chg.tar_id = pre_ar_chg_2.tar_id and pre_ar_chg.charge_line = pre_ar_chg_2.charge_line


where 

pre_ar_chg.serv_area_id = 18 -- TOLEDO
and pre_ar_chg.charge_status_c = 3 -- IN REVIEW
--and pre_ar_chg.tar_id = 135655792
and pre_ar_chg.charge_line = 1
and V_ARPB_CHG_REVIEW_WQ.exit_date is null

order by V_ARPB_CHG_REVIEW_WQ.workqueue_nm_Wid, pat.pat_name
