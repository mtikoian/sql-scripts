 --Physician Specialty
 Select distinct 
 --Name	The name of the Physician Specialty
	zs.Name
 --Description	The description for the Physician Specialty
	, zs.TITLE as Description
 --Physician Specialty Code	The unique code for the Physician Specialty
	, css.specialty_c as Physician_Specialty_Code
 --Specialty Group	The group or rollup for the Physician Specialty
	, ' ' as Specialty_Group
 from clarity_ser_spec css
	inner join ZC_SPECIALTY zs
		on css.specialty_c=zs.specialty_c
 


