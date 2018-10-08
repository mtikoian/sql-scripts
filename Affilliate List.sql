create view sp_affiliates
as
select 
 SERV_AREA_ID
,SERV_AREA_NAME
,SERV_AREA_ABBR
from CLARITY_SA
where SERV_AREA_ID in 
(30,31,303,304,305,401,404,501,502,503,505,601,603,604,608,609)
order by SERV_AREA_ID

--select * from clarity_sa where serv_area_name like '%surgical%'


/*                                                
 Rudolf J. Moriera, MD 
Moin A Ranginwala, MD, Inc
Regina Hill
Monclova Road Pediatrics LTD 
"Nephrology Associates of Toledo, Inc
Sylvan Lakes
Surgical Associates of Springfield   SAS SURGERY & VEIN SPECIALISTS
Vascular Professionals, Inc. 
Regency Urological Associates, Inc.
Interventional Spine Specialists                             Billing Option Thru CarePath  1/1/2017
Mark Akers, MD, Inc.
Dr. Christopher  Sears 
Dr. James Felton
Dr. Dipakkumar Amin
GJ International Consultants Inc 
Maumee Bay FP
Dr. Kris Kostrzewski 
"Pulmonary Rehabilitation Associates
RAJ K BHATIA MD INC
Springfield Heart Surgeons Add Billing 9/16
Northwest Ohio Primary Care Physicians, Inc.     
Youngstown IM Add Billing 1/1/2018
Dr. Andrew Gase
Integrative Pain Management 
Ohio Heart and CardioThoracic Surgeons
"Dr. Bhargava Ravi, MD  Internal Med-
Cheviot Medical Center Epic BILLING May 1, 2017
Dr. Babitha Nalluri, MD 
Robert E. Bisel D.O. & Associates
Bruce Willner-TCI doing billing
William T Bartels MD
*/