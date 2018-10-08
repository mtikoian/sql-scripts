select 
 coalesce(ser.PROV_ID,'') as PROVIDER_ID
,coalesce(ser.PROV_NAME,'') as PROVIDER
,coalesce(ser.CLINICIAN_TITLE,'') as CREDENTIALS
,coalesce(ser.PROV_TYPE,'') as PROVIDER_TYPE
,coalesce(zs.NAME,'') as SPECIALTY
,coalesce(spec.SPECIALTY_C,'') as SPECIALTY_CODE
,coalesce(ser.DOCTORS_DEGREE,'') as DEGREE
,coalesce(ser.DEA_NUMBER,'') as DEA_NUMBER
,coalesce(csi.IRS_NUM,'') as IRS_NUM
,coalesce(UPIN,'') as UPIN
,coalesce(LICENSE_NUM,'') as LICENSE_NUM
,coalesce(LICENSE_TYPE,'') as LICENSE_TYPE
,coalesce(state2.name,'') as LICENSE_STATE
,LICENSE_EXP_DATE
,coalesce(NPI,'') as NPI
--,coalesce(IDENTITY_ID,'') as IDENTITY_ID
--,coalesce(cast(IDENTITY_TYPE_ID as nvarchar),'') as IDENTITY_TYPE_ID
,coalesce(cast(ser_2.PRIMARY_DEPT_ID as nvarchar),'') as PRIMARY_DEPARTMENT_ID
,coalesce(dep.DEPARTMENT_NAME,'') as PRIMARY_DEPARTMENT
,coalesce(addr.ADDRESS,'') as ADDRESS
,coalesce(dep2.ADDRESS_CITY,'') as CITY
,coalesce(state.name,'') as STATE
,coalesce(dep2.ADDRESS_ZIP_CODE,'') as ZIP
,coalesce(dep.PHONE_NUMBER,'') as PHONE_NUMBER

,ser.ACTIVE_STATUS
from clarity_ser ser
left join clarity_ser_spec spec on spec.prov_id = ser.prov_id
left join clarity_ser_2 ser_2 on ser_2.prov_id = ser.prov_id
left join zc_specialty zs on zs.SPECIALTY_C = spec.SPECIALTY_C
left join clarity_dep dep on dep.department_id = ser_2.primary_dept_id
left join clarity_dep_addr addr on addr.department_id = dep.department_id
left join clarity_dep_2 dep2 on dep2.department_id = dep.department_id
left join zc_state state on state.state_c = dep2.address_state_c
left join CLARITY_SER_IRSNUM csi on csi.prov_id = ser.prov_id
left join CLARITY_SER_LICEN2 csl2 on csl2.prov_id = ser.prov_id
left join zc_state state2 on state2.state_c = csl2.LICENSE_STATE_C
--left join IDENTITY_SER_ID isi on isi.prov_id = ser.prov_id

where (spec.line = 1 or spec.line is null)
and ser.PROV_ID is not null
--and ser.PROV_TYPE in ('Physician','Physician Assistant','Nurse Practitioner','Certified Nurse Midwife')
and ser.PROV_TYPE in ('Physician')
and ser.ACTIVE_STATUS = 'Active'
and ser.PRACTICE_NAME_C = 710 -- Mercy providers
and (addr.line = 1 or addr.line is null)
and (LICENSE_EXP_DATE is null or LICENSE_EXP_DATE >= getdate())
order by ser.prov_id
