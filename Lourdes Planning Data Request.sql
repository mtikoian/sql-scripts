select

 coalesce(tdl.TX_ID,'') as 'Transaction ID'
,coalesce(pat.PAT_MRN_ID,'') as 'Patient MRN'
,coalesce(tdl.ACCOUNT_ID,'') as 'Account #'
,coalesce(pat.ADD_LINE_1,'') as 'Address'
,coalesce(pat.ADD_LINE_2,'') as 'Address 2'
,coalesce(pat.CITY,'') as 'City'
,coalesce(st.NAME,'') as 'State'
,coalesce(pat.ZIP,'') as 'Zip'
,coalesce(pat.BIRTH_DATE,'') 'DOB'
,coalesce(cast(epm.PAYOR_ID as varchar),'') + ' - ' + coalesce(epm.PAYOR_NAME,'') as 'Original Payor'
,coalesce(cast(fin.FIN_CLASS_C as varchar),'') + ' - ' + coalesce(fin.NAME, '') as 'Original Fincancial Class'
,coalesce(tdl.ORIG_SERVICE_DATE,'') as 'Service Date'
,coalesce(tdl.POST_DATE,'') as 'POST DATE'
,coalesce(tdl.PERIOD,'') as 'Month of Entry (POST DATE)'
,coalesce(ser.PROV_ID, '') + ' - ' + coalesce(ser.PROV_NAME, '') as 'Performing Provider'
,coalesce(ser2.NPI,'')as 'Performing Provider NPI'
,coalesce(eap.PROC_CODE, '') + ' - ' + coalesce(eap.PROC_NAME,'') as 'Primary CPT'
,coalesce(cast(sa.SERV_AREA_ID as varchar),'') + ' - ' + coalesce(sa.SERV_AREA_NAME, '') as 'Department'
,coalesce(loc.GL_PREFIX,'') as 'Location GL'
,coalesce(cast(loc.LOC_ID as varchar),'') + ' - ' + coalesce(loc.LOC_NAME, '') as 'Location'
,coalesce(dep.GL_PREFIX,'') as 'Department GL'
,coalesce(cast(dep.DEPARTMENT_ID as varchar),'') + ' - ' + coalesce(dep.DEPARTMENT_NAME, '') as 'Department'
,coalesce(tdl.procedure_quantity,'') as 'Procedure Quantity'

from 

CLARITY_TDL_TRAN tdl
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join ZC_STATE st on st.STATE_C = pat.STATE_C
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join ZC_FIN_CLASS fin on fin.FIN_CLASS_C = tdl.ORIGINAL_FIN_CLASS
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.PERFORMING_PROV_ID
left join CLARITY_SER_2 ser2 on ser2.PROV_ID = ser.PROV_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = tdl.SERV_AREA_ID

where 

tdl.POST_DATE >='2014-01-01'
and tdl.POST_DATE <= '2015-12-31'
and tdl.DETAIL_TYPE in (1,10)
and loc.GL_PREFIX in ('6608','6628')
and (eap.PROC_CODE between '96150' and '96154'
or eap.PROC_CODE between '90800' and '90884'
or eap.PROC_CODE between '90886' and '90899'
or eap.PROC_CODE between '99024' and '99079'
or eap.PROC_CODE between '99071' and '96154'
or eap.PROC_CODE between '99081' and '99144'
or eap.PROC_CODE between '99146' and '99149'
or eap.PROC_CODE between '99151' and '99172'
or eap.PROC_CODE between '99174' and '99291'
or eap.PROC_CODE between '99293' and '99359'
or eap.PROC_CODE between '99375' and '99480'
or eap.PROC_CODE = '90791'
or eap.PROC_CODE = '90792'
or eap.PROC_CODE = '99495'
or eap.PROC_CODE = '99496'
or eap.PROC_CODE = '99361'
or eap.PROC_CODE = '99373'
or eap.PROC_CODE = 'G0402'
or eap.PROC_CODE = 'G0406'
or eap.PROC_CODE = 'G0407'
or eap.PROC_CODE = 'G0408'
or eap.PROC_CODE = 'G0409'
or eap.PROC_CODE = 'G0438'
or eap.PROC_CODE = 'G0439'
)

order by tdl.TX_ID