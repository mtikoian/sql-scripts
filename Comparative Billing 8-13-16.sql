select 
pac.tar_id
,pat.pat_name
,acct.account_name
,ser_bill.prov_name
,max(case when aud.tar_id is null then 'Yes' else 'No' end) as 'Org PX/Mod/Dx Kept?'
,max(case when data_field = 150 then old_value + ', ' + eap.proc_name else eap.proc_name end) as 'Original Procedure'
,max(eap.proc_name) as 'Charge Procedure'
,max(case when data_field = 160 then old_value else '' end) as 'Original Modifier'
,max(coalesce(mod.int_modifier_id,'')) as 'Procedure Mods'
,max(case when data_field = 130 then old_value + ', ' + edg.dx_name else edg.dx_name end) as 'Original Diagnosis'
,max(edg.dx_name) as 'Diagnosis'


from 
pre_ar_chg pac
left join patient pat on pat.pat_id = pac.pat_id
left join account acct on acct.account_id = pac.account_id
left join clarity_ser ser_bill on ser_bill.prov_id = pac.bill_prov_id
left join CHG_REVIEW_ACT_AUD aud on aud.tar_id = pac.tar_id
left join clarity_eap eap on eap.proc_id = pac.proc_id
left join CHG_REVIEW_DX crd on crd.tar_id = pac.tar_id and crd.line = pac.charge_line
left join clarity_edg edg on edg.dx_id = crd.dx_id
left join chg_review_mods mod on mod.tar_id = pac.tar_id

where
--pat.pat_name = 'BUNK,SALLY K'
service_date = '2016-08-01'
--and aud.data_field in (130,150,160,180) -- 130 Diagnosis, 150 - Procedure, 160 - Modifier, 180 - Charge Amount
and pac.serv_area_id in (11,13,16,17,18,19)

group by pac.tar_id, pat.pat_name, acct.account_name, ser_bill.prov_name