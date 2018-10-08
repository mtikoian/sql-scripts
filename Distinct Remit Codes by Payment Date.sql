
select distinct varc.remit_code_id, rmc.remit_code_name, rpt_group_title, code_cat_c, zrcc.name, rpt_grp_three
from v_arpb_remit_codes varc
left join clarity_rmc rmc on rmc.remit_code_id = varc.remit_code_id
left join ZC_RMC_CODE_CAT zrcc on zrcc.rmc_code_cat_c = rmc.code_cat_c
where payment_post_date >= '2015-08-01'
and serv_area_id in (11,13,16,17,18,19,1312)
order by remit_code_id