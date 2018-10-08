/*
are you able to include the modifier on this one?
DX on a separate report
*/

select pac2.CHRG_ROUTER_SRC_ID as UCL_ID
, pac.tar_id
,sa.name
, dep.department_name
,cast(pac.service_date as date) as service_date
, ser.prov_name
, pat.pat_name
,case when xeap.proc_code = eap.proc_code then 'Yes' else 'No' end as 'Orig PX Kept?'
, xeap.proc_code as original_code
, xeap.proc_name as original_desc
, eap.proc_code
, eap.proc_name
,mod.orig_mod_id
,activity_c
,cast(activity_date as date) as activity_date
,emp.user_id
,emp.name

from pre_ar_chg pac 
left join pre_ar_chg_2 pac2 on pac2.tar_id = pac.tar_id and pac2.charge_line = pac.charge_line
left join clarity_eap eap on eap.proc_id = pac.proc_id
left join x_clarity_ucl xcu on xcu.ucl_id = pac2.chrg_router_src_id
left join clarity_eap xeap on xeap.proc_id = xcu.orig_procedure_id
left join PRE_AR_CHG_HX pach on pach.tar_id = pac.tar_id
left join clarity_emp emp on emp.user_id = pach.user_id
left join clarity_ser ser on ser.prov_id = pac.bill_prov_id
left join Clarity.dbo.patient pat on pat.pat_id = pac.pat_id
left join Clarity.dbo.clarity_loc loc on loc.loc_id = pac.loc_id
left join Clarity.dbo.clarity_dep dep on dep.department_id = pac.proc_dept_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join x_clarity_ucl_mod mod on mod.ucl_id = pac2.chrg_router_src_id -- line?

where ACTIVITY_C = 106 -- charge filed
and activity_date >= '3/1/2018'
and activity_date <= '3/31/2018'
-- and pac2.CHRG_ROUTER_SRC_ID =  255077526
and sa.RPT_GRP_TEN in (18)
order by pac2.CHRG_ROUTER_SRC_ID