select 
ser_perf.prov_name as 'Service Provider'
,eap.proc_code as 'CPT Code'
,eap.proc_name as 'Procedure Description'
,service_date as 'Service Date'
,pat_name as 'Patient Name'
,pat.birth_date as 'DOB'
,pat.home_phone as 'Home Phone'
,pat.work_phone as 'Work Phone'
,year_month_str as 'Year-Month'
from arpb_transactions arpb_tx
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
left join patient pat on pat.pat_id = arpb_tx.patient_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join clarity_ser ser_perf on ser_perf.prov_id = arpb_tx.serv_provider_id
left join V_CUBE_D_BILLING_DATES date on date.calendar_dt_str = arpb_tx.service_date
where service_date >= '1/1/2013'
and service_date <= '08/31/2016'
and tx_type_c =1
and dep.gl_prefix = '791378'
and arpb_tx.cpt_code in ('45378', '45380', '45381', '45382', '45384', '45385', '45386', '45388', '45390', 'G6021', 'G0121', 'G0105')
and ser_perf.prov_name in ('PANGULUR, SUDHAKAR N','DABOUL, ISAM','AHMAD, FARID U')
order by arpb_tx.service_date