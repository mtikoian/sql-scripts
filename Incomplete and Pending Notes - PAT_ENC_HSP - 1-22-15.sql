USE CLARITY;

select
	   info.note_id,
	   (nei.contact_serial_num),
	   nei.note_status_c,
	   peh.hospital_area_id,
	   info.pat_enc_csn_id,
	   zns.name,
	   info.ip_note_type_c,
	   znti.name,
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
	   inner join 
			(select note_id, max(contact_serial_num) as 'contact_serial_num' 
				from note_enc_info nei  
				group by note_id) a
			 on a.contact_serial_num = nei.CONTACT_SERIAL_NUM
where
	    nei.note_status_c in ('1','10','12') 
		and hospital_area_id in (13102,13101) 
		and info.note_id in (388144195, 133449154, 382429840)

order by info.note_id


