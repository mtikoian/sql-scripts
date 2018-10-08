select info.note_id,
	   nei.contact_serial_num,
	   nei.note_status_c,
	   peh.pat_enc_csn_id,
	   info.pat_enc_csn_id
from 
hno_info info
 left join note_enc_info nei on nei.note_id = info.note_id
left join pat_enc_hsp peh on peh.pat_enc_csn_id = info.pat_enc_csn_id
where info.note_id in (388144195, 133449154, 382429840)
order by info.note_id

/*B
NOTE STATUS C
  1 - Incomplete   
  2 - Signed   
  3 - Addendum   
  4 - Deleted   
  5 - Revised  
  6 - Cosigned   
  7 - Finalized   
  8 - Unsigned   
  9 - Cosign Needed   
  10 - Incomplete Revision     
  11 - Cosign Needed Addendum   
  12 - Shared   

*/

select note_id, line, zc.name
from note_edit_trail a
inner join ZC_IP_ACTION_NOTE zc on a.ip_action_on_note_c = zc.ip_action_note_c 
where note_id in (388144195, 133449154, 382429840)
order by note_id, line

select a.note_id, b.line, a.ip_action_on_note_c, zc.name, a.ACTION_NOTE_STAT_C, zns.name
from note_edit_trail a
inner join (select note_id, max(line) as 'line' from note_edit_trail where note_id in (388144195, 133449154, 382429840) group by note_id)b on  a.note_id = b.note_id and a.line = b.line
left join ZC_IP_ACTION_NOTE zc on a.ip_action_on_note_c = zc.ip_action_note_c 
left join zc_note_status zns on zns.note_status_c = a.action_note_stat_c
order by note_id, line

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

