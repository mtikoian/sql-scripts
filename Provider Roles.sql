select

clarity_ser.prov_id, --SER .1
clarity_ser.prov_name, -- SER .2
clarity_ser.active_status, -- SER 35
clarity_ser.prov_type, -- SER 1040
clarity_ser.rpt_grp_seven as 'SER 2906', -- SER 2906
clarity_sa.serv_area_name,
provider_attn_priv.att_priv_sa_id as 'SER 850',
sa2.serv_area_name,
clarity_emp_ar_sa.serv_area_id as 'EMP 13002',
sa3.serv_area_name,
clarity_emp_es_sa.serv_area_id as 'EMP 5040',
sa4.serv_area_name,
clarity_emp.user_id, -- EMP .1
clarity_emp.name, -- EMP .2
clarity_emp.lnk_sec_templt_id, -- EMP 198
clarity_emp_role.default_user_role, -- EMP 14300
clarity_emp_ar_sa.dflt_sec_class_c, -- EMP 13001
zc_dflt_sec_class.name -- EMP 13000


from 

clarity_ser

left join clarity_emp on clarity_ser.user_id = clarity_emp.user_id
left join clarity_emp_role on clarity_emp.user_id = clarity_emp_role.user_id
left join clarity_emp_ar_sa on clarity_emp.user_id = clarity_emp_ar_sa.user_id
left join zc_dflt_sec_class on clarity_emp_ar_sa.dflt_sec_class_c = zc_dflt_sec_class.dflt_sec_class_c
left join clarity_sa on clarity_ser.rpt_grp_seven = clarity_sa.serv_area_id
left join provider_attn_priv on clarity_ser.prov_id = provider_attn_priv.prov_id
left join clarity_sa sa2 on sa2.serv_area_id = provider_attn_priv.att_priv_sa_id
left join clarity_sa sa3 on sa3.serv_area_id = clarity_emp_ar_sa.serv_area_id
left join clarity_emp_es_sa on clarity_emp.user_id = clarity_emp_es_sa.user_id
left join clarity_sa sa4 on sa4.serv_area_id = clarity_emp_es_sa.serv_area_id

where clarity_ser.active_status = 'active'
--and clarity_ser.rpt_grp_seven in (11,13,16,17,18,19)
and clarity_ser.prov_type in ('Physician', 'Nurse Practitioner', 'Physician Assistant')
and clarity_emp.user_id is not null


order by clarity_ser.prov_id