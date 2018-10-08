select 
 pat.pat_name as 'Patient Name'
,acct.account_name + '-' + cast(acct.account_id as varchar) as 'Guarantor Account'
,ser_perf.prov_name + '-' + ser_perf.prov_id as 'Service Provider'
,ser_bill.prov_name + '-' + ser_bill.prov_id as 'Service Provider'
,pre.service_date as 'Service Date'
,eap_chg.proc_name + '-' + eap_chg.proc_code as 'Charge Procedure'
,mod.int_modifier_id
,edg.dx_name + '-' + edg.diagnosis_code as 'Diagnosis'
,pre.amount as 'Amount'
,pre.charge_line
,pre_hx.charge_hx_line
,dx.line
,pre.tx_id
,pre.tar_id
,craa.ACT_LINE_REF
,craa.data_field
,craa.old_value
,craa.new_value
,craa.DATA_FIELD_LINE

from 
pre_ar_chg pre
left join pre_ar_chg_hx pre_hx on pre_hx.tar_id = pre.tar_id
left join chg_review_dx dx on dx.tar_id = pre.tar_id
left join clarity_ser ser_perf on ser_perf.prov_id = pre.perf_prov_id
left join clarity_eap eap_chg on eap_chg.proc_id = pre.proc_id
left join clarity_edg edg on edg.dx_id = dx.dx_id
left join account acct on acct.account_id = pre.account_id
left join patient pat on pat.pat_id = pre.pat_id
left join clarity_ser ser_bill on ser_bill.prov_id = pre.bill_prov_id
left join chg_review_mods mod on mod.tar_id = pre.tar_id
left join CHG_REVIEW_ACT_AUD craa on craa.tar_id = pre.tar_id and craa.line = pre_hx.charge_hx_line

where 
--pre.service_date >= '2016-04-23'
--and pre.service_Date <= '2016-04-28'
--and pre.perf_prov_id = '1004712'  -- JENNINGS, MARK RICHARD
--and acct.account_name = 'COX,CRAIG M'
pre.tar_id = 198962302
and data_field in (130,150,160,180) -- 130 Diagnosis, 150 - Procedure, 160 - Modifier, 180 - Charge Amount

order by acct.account_name