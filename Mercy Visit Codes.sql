select PROC_CODE, PROC_NAME
from clarity_eap tdl
where (tdl.proc_code>='96150' and tdl.proc_code<='96154' or 
                tdl.proc_code>='90800' and tdl.proc_code<='90884' or 
                tdl.proc_code>='90886' and tdl.proc_code<='90899' or 
                tdl.proc_code>='99024' and tdl.proc_code<='99069' or 
                tdl.proc_code>='99071' and tdl.proc_code<='99079' or 
                tdl.proc_code>='99081' and tdl.proc_code<='99144' or 
                tdl.proc_code>='99146' and tdl.proc_code<='99149' or 
                tdl.proc_code>='99151' and tdl.proc_code<='99172' or 
                tdl.proc_code>='99174' and tdl.proc_code<='99291' or 
                tdl.proc_code>='99293' and tdl.proc_code<='99359' or 
                tdl.proc_code>='99375' and tdl.proc_code<='99480' or 
				tdl.proc_code='98969' or
                tdl.proc_code='99361' or 
                tdl.proc_code='99373' or 
				tdl.proc_code='90791' or 
				tdl.proc_code='90792' or 
				tdl.proc_code='99495' or 
				tdl.proc_code='99496' or 
                tdl.proc_code='G0402' or 
                tdl.proc_code='G0406' or 
                tdl.proc_code='G0407' or 
                tdl.proc_code='G0408' or 
                tdl.proc_code='G0409' or 
                tdl.proc_code='G0438' or 
                tdl.proc_code='G0439'
				)

order by PROC_CODE