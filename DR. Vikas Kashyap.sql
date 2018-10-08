select ORIG_SERVICE_DATE, performing_prov_id, billing_provider_id, tdl.serv_area_id, dept_id, department_name, cpt_code
from clarity_tdl_tran tdl -- transactions
--inner join patient pat on tdl.int_pat_id = pat.pat_mrn_id -- patients
inner join clarity_dep dep on tdl.dept_id = dep.DEPARTMENT_ID
where orig_service_date >= '2013-01-01 00:00:00'
and orig_service_date <= '2014-12-31 00:00:00' -- SERVICE DATE BETWEEN 1/1/13 - 12/31/14
and tdl.SERV_AREA_ID = 11  -- CINCINNATI
and dept_id = 11101219 -- MMA DELHI IM
and performing_prov_id = '1004920' --DR. VIKAS KASHYAP
