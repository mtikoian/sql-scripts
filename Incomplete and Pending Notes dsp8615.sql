declare @hospital_area_id as int
declare @date as date
set @hospital_area_id = 13102
set @date = '2014-03-01 00:00:00';

select 

*

from

(select 
    note_id,
    max(contact_serial_num) as contact_serial_num
from note_enc_info
where note_enc_info.spec_note_time_dttm >= @date
group by note_id
)a 

inner join 

(select 
    hno_info.note_id,
    max(contact_serial_num) as contact_serial_num,
	contact_num,
	pat_enc_hsp.hospital_area_id,
    hno_info.pat_enc_csn_id,
	note_enc_info.note_status_c,
	zc_note_status.name as 'note_status',
	hno_info.ip_note_type_c,
	zc_note_type_ip.name as 'note_type',
	clarity_emp.name as 'user_name',
	bill_num,
	pat_enc_hsp.contact_date,
	patient.pat_name,
	note_enc_info.spec_note_time_dttm,
	clarity_sa.serv_area_name,
	clarity_loc.loc_name,
	clarity_dep.department_name

from 

hno_info
left join note_enc_info on hno_info.note_id = note_enc_info.note_id
left join pat_enc_hsp on pat_enc_hsp.pat_enc_csn_id = hno_info.pat_enc_csn_id
inner join zc_note_type_ip on zc_note_type_ip.type_ip_c = hno_info.ip_note_type_c
left join clarity_emp on clarity_emp.user_id = hno_info.current_author_id
left join patient on patient.pat_id = hno_info.pat_id
inner join clarity_dep on clarity_dep.department_id = pat_enc_hsp.department_id
inner join clarity_loc on clarity_loc.loc_id = pat_enc_hsp.hospital_area_id
inner join clarity_sa on clarity_sa.serv_area_id = clarity_loc.serv_area_id
left join zc_note_status on zc_note_status.note_status_c = note_enc_info.note_status_c
left join clarity_emp auth on auth.user_id = note_enc_info.author_user_id

where hospital_area_id = @hospital_area_id
and note_enc_info.spec_note_time_dttm >= @date

group by hno_info.note_id,
	     pat_enc_hsp.hospital_area_id,
		 contact_num,
		 hno_info.pat_enc_csn_id,
		 note_enc_info.note_status_c,
		 zc_note_status.name,
		 hno_info.ip_note_type_c,
		 zc_note_type_ip.name,
		 clarity_emp.name,
		 bill_num,
		 pat_enc_hsp.contact_date,
		 patient.pat_name,
		 note_enc_info.spec_note_time_dttm,
		 clarity_sa.serv_area_name,
		 clarity_loc.loc_name,
		 clarity_dep.department_name
)b 

on a.note_id = b.note_id and a.contact_serial_num = b.contact_serial_num

where note_status_c in (1, 10, 12)

