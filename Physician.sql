 select distinct 
 --Physician
	ser.prov_name as Physician
 --Full Name
 	, ser.prov_name + ' ' + ser.clinician_title as Full_Name
 --Physician Code
	, ser.prov_id as Physician_Code
 --State License Number  -- looks like a little free text is allowed with these!
	, coalesce((select top 1 ser_license.license_num
		from clarity_ser_licen2 ser_license
		where ser_license.prov_id=ser.prov_id
			and ser.prov_id is not null
			and ser_license.license_type = 'STL'
	   ), (select top 1 'MD.'+ convert(varchar,ser_license.license_num)
		from clarity_ser_licen2 ser_license
		where ser_license.prov_id=ser.prov_id
			and ser.prov_id is not null
			and ser_license.license_type = 'MD'
		)) as State_License_Number
 --Group Affiliation
	, ser2.grp_or_site_c  as Group_Affliation --ZC_GROUP_OR_SITE
 --Physician Speciality
	, (select css.specialty_c
		from clarity_ser_spec css
		where css.prov_id=ser.prov_id
			and ser.prov_id is not null
			and css.line = '1'
	  ) as Physician_Specialty
 --NPI
	, ser2.NPI as NPI
	--, ser.medicare_prov_id
	--, ser.medicaid_prov_id
 --First Name
 --Is Active
	, ser.active_status  as Is_Active
	, ser.ACTIVE_STATUS_C as Is_Active_C -- because wait to poulate ZC_ACTIVE_STATUS 
 --Is Provider
	, ser.prov_type as Is_Provider
 --Title
	, ser.clinician_title as Title
 --ACO Flag  --Accountable Care Organization
	, ' ' as ACO_Flag	
 --In Medical Group -- CLARITY_SER_MDGRP 
	, ' ' as In_Medical_Group
 from  clarity_ser ser
	left outer join clarity_ser_2 ser2
		on ser.prov_id=ser2.prov_id
	left outer join clarity_ser_licen2 ser_license
		on ser.prov_id=ser_license.prov_id


where SER.PROV_TYPE NOT LIKE 'Resource%'
	AND SER.PROV_ID NOT LIKE 'E%'

order by ser.prov_id



