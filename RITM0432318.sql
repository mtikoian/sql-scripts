/*
I would need this for all the oncologists hitting GL 6734.440360 and 6734.440361. 
The department names are MHP Cancer Ctr Oregon and MHP Cancer Ctr Toledo. The date range I need is 12/13/2012 thru 10/26/2015.

The info I would need:

Department Name
Department GL
Provider performing
MRN
CPT
Procedure Code description
Month of transaction
Count of Patients

I need this for legal for discovery.
*/

select 
 dep.department_name + ' - ' + cast(dep.department_id as varchar) as 'Department'
,dep.gl_prefix as 'Department GL'
,ser.prov_name as 'Performing Provider'
,type.name as 'Transaction Type'
,eap.proc_code as 'CPT'
,eap.proc_name as 'Procedure Description'
,pat.pat_mrn_id as 'Patient MRN'
,tdl.amount as 'Charge Amount'
,tdl.procedure_quantity as 'Procedure Quantity'
,case when  (eap.proc_code between '96150' and '96154'
or eap.proc_code between '90800' and '90884'
or eap.proc_code between '90886' and '90899'
or eap.proc_code between '99024' and '99079'
or eap.proc_code between '99071' and '96154'
or eap.proc_code between '99081' and '99144'
or eap.proc_code between '99146' and '99149'
or eap.proc_code between '99151' and '99172'
or eap.proc_code between '99174' and '99291'
or eap.proc_code between '99293' and '99359'
or eap.proc_code between '99375' and '99480'
or eap.proc_code = '90791'
or eap.proc_code = '90792'
or eap.proc_code = '99495'
or eap.proc_code = '99496'
or eap.proc_code = '99361'
or eap.proc_code = '99373'
or eap.proc_code = 'G0402'
or eap.proc_code = 'G0406'
or eap.proc_code = 'G0407'
or eap.proc_code = 'G0408'
or eap.proc_code = 'G0409'
or eap.proc_code = 'G0438'
or eap.proc_code = 'G0439'
)
	then 1 else 0 end as 'Visits'
,date.year_month as 'Month of Service'

from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_ser ser on ser.prov_id = tdl.performing_prov_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join date_dimension date on date.calendar_dt_str = tdl.orig_service_date
left join zc_detail_type type on type.detail_type = tdl.detail_type

where loc.gl_prefix in ('6734')
and dep.gl_prefix in ('440360','440361')
and tdl.detail_type in (1,10)
and tdl.orig_service_date >= '12/13/2012'
and tdl.orig_service_date <= '10/26/2015'

order by 
 year_month
,dep.department_id
,dep.gl_prefix
,ser.prov_id
,eap.proc_code
,eap.proc_name
,pat.pat_mrn_id