/* 
Updated: 7/16/15
By: DSP*/
SELECT info.note_id
	,peh.hospital_area_id
	,nei.contact_serial_num
	,info.pat_enc_csn_id
	,a.line AS 'max_line'
	,a.ip_action_on_note_c
	,zc.NAME AS 'action_taken_on_note'
	,nei.note_status_c
	,zns.NAME AS 'note_status'
	,info.ip_note_type_c
	,znti.NAME AS 'note_type'
	,emp.NAME AS 'user_name'
	,bill_num
	,peh.contact_date
	,pat.pat_name
	,nei.spec_note_time_dttm
	,sa.serv_area_name
	,loc.loc_name
	,dep.department_name
FROM hno_info info
LEFT JOIN note_enc_info nei ON nei.note_id = info.note_id
LEFT JOIN pat_enc_hsp peh ON peh.pat_enc_csn_id = info.pat_enc_csn_id
INNER JOIN zc_note_type_ip znti ON znti.type_ip_c = info.ip_note_type_c
LEFT JOIN clarity_emp emp ON emp.user_id = info.current_author_id
LEFT JOIN patient pat ON pat.pat_id = info.pat_id
INNER JOIN clarity_dep dep ON dep.department_id = peh.department_id
INNER JOIN clarity_loc loc ON loc.loc_id = peh.hospital_area_id
INNER JOIN clarity_sa sa ON sa.serv_area_id = loc.serv_area_id
LEFT JOIN zc_note_status zns ON zns.note_status_c = nei.note_status_c
LEFT JOIN clarity_emp auth ON auth.user_id = nei.author_user_id
LEFT JOIN note_edit_trail a ON info.note_id = a.note_id
LEFT JOIN (
	SELECT note_id
		,max(line) AS 'line'
	FROM note_edit_trail
	GROUP BY note_id
	) b ON a.note_id = b.note_id
	AND a.line = b.line
INNER JOIN ZC_IP_ACTION_NOTE zc ON a.ip_action_on_note_c = zc.ip_action_note_c
WHERE nei.note_status_c IN (
		'1'
		,'10'
		,'12'
		)
	AND hospital_area_id IN (13103) --13101 SEY, 13102 SEB, 13103 SJHC
	--and a.note_id in (388144195, 133449154, 382429840)
	AND a.ip_action_on_note_c IN (
		1
		,10
		,19
		)
	AND nei.spec_note_time_dttm >= '2014-03-01 00:00:00'
ORDER BY info.note_id
	/*
34040 - IP ACTION TACKEN ON NOTE
  1 - INCOMPLETE  
  2 - SIGN     
  3 - DELETED  
  4 - DELETED PENDED      
  5 - AUTOPEND    
  6 - ADDEND / EDIT TRANSCRIPTION     
  7 - COSIGN     
  8 - AUTHORIZE TRANSCRIPTION     
  9 - RESIDENT-AUTHORIZE TRANSCRIPTION     
  10 - SHARE     
  11 - AUTHOR CHANGED    
  12 - Route   
  13 - Transcription Merge    
  14 - Hard Delete   
  15 - CHART CORRECTION   
  16 - Unsigned   
  17 - UNDELETE    
  18 - Note Type Changed   
  19 - Incomplete Revision   
  20 - Remove cosign/attestation  
  21 - Note Metadata Change   
*/