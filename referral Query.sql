DECLARE @StartDate DATETIME, 
        @EndDate   DATETIME   
SET @StartDate = '2014-05-01'
SET @EndDate = '2014-05-31'

select distinct
pt.pat_name,
pt.pat_mrn_id,
ref.referral_id,
CLARITY_SER_REF_BY.PROV_NAME AS "REF_BY_PROV",
dep.department_name as "ref_by_dept",
clarity_ser_ref_by.prov_id as "ref_by_prov_id",
convert(varchar,ref.entry_date,101) as "referral_date",
CASE 
WHEN ser.RPT_GRP_ELEVEN_C = '1' or ref.refd_to_dept_id is not null
THEN 'Internal' 
ELSE 'External' 
END AS "Int/Ext",
CASE
WHEN ser.RPT_GRP_TWELVE_C = '1'
THEN 'PHO/ACO'
ELSE NULL
END AS "Tol PHO",

ser.prov_name as "ref_to_prov",
clarity_dep_ref_to.department_name as "ref_to_dep",
zc_order_type.name,
pro.description,
zc_rfl_prov_spec.name as "ref_specified",
(select distinct
ques.ord_quest_resp
from referral ref
left outer join ord_spec_quest ques on ord.order_id=ques.order_id
where ques.ord_quest_id='101198') as "reas_ext"

from referral ref
left outer join patient pt on ref.pat_id=pt.pat_id
left outer join CLARITY_SER AS CLARITY_SER_REF_BY ON REF.REFERRING_PROV_ID=CLARITY_SER_REF_BY.PROV_ID
left outer join clarity_ser ser on ref.referral_prov_id=ser.prov_id
left outer join clarity_ser_spec spec on ser.prov_id=spec.prov_id
left outer join clarity_dep dep on ref.refd_by_dept_id=dep.department_id
left outer join clarity_dep as clarity_dep_ref_to on ref.REFD_TO_DEPT_ID=clarity_dep_ref_to.department_id
left outer join clarity_emp emp on CLARITY_SER_REF_BY.prov_id=emp.prov_id
left outer join referral_order_id ord on ref.referral_id=ord.referral_id
left outer join order_proc pro on ord.order_id=pro.order_proc_id
left outer join zc_order_type on pro.order_type_c=zc_order_type.order_type_c
left outer join zc_rfl_prov_spec on ref.prov_spec_c=zc_rfl_prov_spec.prov_spec_c


where dep.rev_loc_id in (19101) --to be distributed by region 
and dep.specialty_dep_c in ('9','17','125') -- FM, IM, PC 
and ref.entry_date between @startdate and @enddate
and pro.order_type_c = '8'
and clarity_ser_ref_by.PROV_TYPE = 'Physician'
and (emp.USER_STATUS_C = '1' or emp.USER_STATUS_C is null)

order by ref_to_prov

--rev loc by SA below
--
--Sa	AREA_NAME	rev lOC	LOC_NAME
-- 
--11	CINCINNATI	11101	SWOH MMA PHYSICIAN PRACTICES
--11	CINCINNATI	11106	SWOH SPRINGFIELD
--13	YOUNGSTOWN	13105	HMHP PHYSICIANS ENTERPRISE LLC
--16	LIMA	     16102	SRPS ST RITA PROFESSIONAL SERVS
--17	LORAIN	     17105	MLOR MERCY MEDICAL PARTNERS
--17	LORAIN	     17106	MLOR MERCY TRI-CITY
--18	TOLEDO	    18103	MHPN ST. CHARLES PHYSICIANS
--19	KENTUCKY	 19101	KYIN LOURDES PHYSICIAN SERVICES
