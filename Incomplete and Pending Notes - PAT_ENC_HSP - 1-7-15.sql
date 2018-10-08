select
	   info.note_id,
	   nei.contact_serial_num,
	   nei.note_status_c,
	   peh.hospital_area_id,
	   info.pat_enc_csn_id,
	   peh.pat_enc_csn_id,
	   zns.name,
	   info.ip_note_type_c,
	   znti.name,
	   auth.name,
	   emp.name,
	   bill_num,
	   peh.contact_date,
	   pat.pat_name,
	   nei.spec_note_time_dttm,
	   sa.serv_area_name,
	   loc.loc_name,
	   dep.department_name
from
	   hno_info info
	   inner join note_enc_info nei on nei.note_id = info.note_id
	   left join pat_enc_hsp peh on peh.pat_enc_csn_id = info.pat_enc_csn_id
	   left join zc_note_type_ip znti on znti.type_ip_c = info.ip_note_type_c
	   left join clarity_emp emp on emp.user_id = info.current_author_id
	   left join patient pat on pat.pat_id = info.pat_id
	   inner join clarity_dep dep on dep.department_id = peh.department_id
	   inner join clarity_loc loc on loc.loc_id = peh.hospital_area_id
       left join clarity_sa sa on sa.serv_area_id = loc.serv_area_id
	   left join zc_note_status zns on zns.note_status_c = nei.note_status_c
	   left join clarity_emp auth on auth.user_id = nei.author_user_id
where
	   hospital_area_id = 13102
	   and nei.note_status_c in ('1','10','12')
order by info.note_id


