/*1st DENIAL AUTHORIZATION SCORECARD*/

select 
-->>>>>>>>  Calculation for 1st Denial - Authorization <<<<<<<<<<<
sum(case when (tdl.detail_type = 44 or tdl.detail_type = 45) and rmc_code.name = 'AUTHORIZATION'  then tdl.action_amount end) as '1st DENIAL - AUTHORIZATION'


from clarity_tdl_tran tdl
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
where sa.rpt_grp_ten = 11
and tdl.post_date between '10/1/2018' and '10/31/2018'
and loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138,19151,19154,19148,19155,19156,19149,19150)


/*FIRST PASS DENIAL - POWER BI*/
select 
 case when rmc1.remit_code_name is not null then upper(zrcc.name) else upper(remit_code_cat_name) end as 'Remit Code Category'
,sum(varc.REMIT_AMOUNT) as 'Remit Amount'

from 

clarity.dbo.V_ARPB_REMIT_CODES varc
left join clarity.dbo.CLARITY_RMC rmc on rmc.REMIT_CODE_ID = varc.REMIT_CODE_ID
left join clarity.dbo.CLARITY_RMC rmc1 on rmc1.REMIT_CODE_ID = varc.REMARK_CODE_1_ID
left join clarity.dbo.ZC_RMC_CODE_CAT zrcc on zrcc.RMC_CODE_CAT_C = rmc1.CODE_CAT_C
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = varc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = varc.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where 
varc.PAYMENT_POST_DATE between '10/1/2018' and '10/31/2018'
and varc.REMIT_ACTION in (9)
and varc.REMIT_AMOUNT >= 0
and loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138,19151,19154,19148,19155,19156,19149,19150)
an

group by 
case when rmc1.remit_code_name is not null then upper(zrcc.name) else upper(remit_code_cat_name) end

