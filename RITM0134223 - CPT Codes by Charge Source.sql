declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
case when source.name is null then 'Manual' else source.name  + ' [' + convert(varchar(18),ucl.CHARGE_SOURCE_C) + ']' end as 'Charge Source'
,zcs.name as 'Charge Status'
,sa.serv_area_name + ' [' + convert(varchar(18),sa.serv_area_id) + ']' as 'Service Area'
,pat.pat_name  + ' [' + convert(varchar(18),pat.pat_id) + ']' as 'Patient'
,acct.account_name + ' [' + convert(varchar(18),acct.account_id) + ']' as 'Account'
,ser_bill.prov_name + ' [' + convert(varchar(18),ser_bill.prov_id) + ']' as 'Billing Provider'
,ser_perf.prov_name + ' [' + convert(varchar(18),ser_perf.prov_id) + ']' as 'Performing Provider'
,coalesce(eap.proc_code,'') as 'Procedure Code'
,eap.proc_name + ' [' + convert(varchar(18),eap.proc_code) + ']' as 'Procedure'
,pre.service_date as 'Service Date'
,coalesce(convert(varchar(18),ucl.ucl_id),'') as 'UCL ID'
,coalesce(convert(varchar(18),pre.tar_id),'') as 'TAR ID'
,coalesce(convert(varchar(18),pre.tx_id),'') as 'Transaction ID'
,zcd.name as 'Destination'
,dd.year_month

from 

pre_ar_chg pre
left join pre_ar_chg_2 pre2 on pre2.tar_id = pre.tar_id and pre2.charge_line = pre.charge_line
left join clarity_ucl ucl on ucl.ucl_id = pre2.CHRG_ROUTER_SRC_ID
left outer join ZC_CHG_SOURCE_UCL source on source.CHG_SOURCE_UCL_C = ucl.charge_source_c
left join clarity_sa sa on sa.serv_area_id = pre.serv_area_id
left join patient pat on pat.pat_id = pre.pat_id
left join account acct on acct.account_id = pre.account_id
left join clarity_ser ser_bill on ser_bill.prov_id = pre.bill_prov_id
left join clarity_ser ser_perf on ser_perf.prov_id = pre.SESS_PERF_PROV_ID
left join clarity_eap eap on eap.proc_id = pre.proc_id
left join zc_charge_status zcs on zcs.charge_status_c = pre.charge_status_c
left join zc_chg_destination zcd on zcd.CHG_DESTINATION_C = ucl.CHG_DESTINATION_C
left join date_dimension dd on dd.calendar_dt_str = pre.service_date

where
pre.serv_area_id in (11,13,16,17,18,19)
and pre.service_date >= @start_date 
and pre.service_date <= @end_date
and zcs.charge_status_c in (1,2)

order by pre.service_date, pre.tx_id
