declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

-- >>>>>>>>>>>>>> Charge Lag Calculation. <<<<<<<<<<<<<<<<
-- Measure the amount of time it takes from date of service to posting of the charge.

select
 REGION
,sum([days lag]) as 'Lag Days'
,sum([Distinct Count]) as 'Distinct Count'
,convert(decimal(18,2),round(convert(decimal(18,2),round(sum([days lag]),2))/convert(decimal(18,2),round(sum([Distinct Count]),2)),2)) as [Avg Lag Days]

from

(select *

from
(select
case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end as 'REGION'
,loc.loc_name as 'LOCATION'
,dep.department_name as 'DEPARTMENT'
,date.monthname_year as 'MONTH'
,pos.pos_name as 'POS_NAME'
,pat.pat_mrn_id as 'PAT_MRN_ID'
,tdl.charge_slip_number as 'CHARGE_SLIP_NUMBER'
,tdl.pat_enc_csn_id as 'ORIG_CSN'
,tdl.pat_id as 'ORIG_PAT_ID'
,arpb_match.pat_enc_csn_id as 'MATCHED_CSN'
,tdl.orig_service_date as 'ORIG_SERVICE_DATE'
,tdl.post_Date as 'POST_DATE'          
,min(arpb_match.post_date) as 'Earliest Post Date'                 

-->>>>>>>>  Calculation for Total Charges  <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) then tdl.amount end) as 'Total Charges'

,case when tdl.post_date = min(arpb_match.post_date) then datediff(day,tdl.orig_service_date,tdl.post_date) end as 'Days Lag'

,case when tdl.post_date = min(arpb_match.post_date) then 1 
      when tdl.post_date = tdl.orig_service_date then 1
	  else 0
	  end as 'Distinct Count'

from clarity_tdl_tran tdl
left join arpb_transactions arpb_match on arpb_match.patient_id = tdl.int_pat_id and tdl.orig_service_date = arpb_match.service_date
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date
where

tdl.post_date >= @start_date
and tdl.post_date <=@end_date
and tdl.detail_type in (1,10)
and loc.loc_id in ('11106','11124' -- SPRINGFILED
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138' -- CINCINNATI
,'13104','13105' -- YOUNGSTOWN
,'16102','16103','16104' -- LIMA
,'17105','17106','17107','17108','17109','17110','17112','17113' -- LORAIN
,'18120','18121' -- DEFIANCE
,'18101','18102','18103','18104','18105','18130','18131','18132','18133' -- TOLEDO 
,'18110' -- TOLEDO MRG
,'19101','19102','19106' -- KENTUCKY
,'19107','19108','19116','19118' -- KENTUCKY - OTHER ENTITIES
)

group by
	case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA' 
	end
	,loc.loc_name
	,dep.department_name
	,date.monthname_year
    ,pos.pos_name
	,pat.pat_mrn_id
	,tdl.charge_slip_number
	,tdl.pat_enc_csn_id
	,tdl.pat_id
	,arpb_match.pat_enc_csn_id
	,tdl.orig_service_date
	,tdl.post_date

) as t

group by 
region
,location
,department
,month
,pos_name
,pat_mrn_id
,charge_slip_number
,orig_csn
,orig_pat_id
,matched_csn
,orig_service_date
,post_date
,[earliest post date]
,[total charges]
,[days lag]
,[distinct count]
) as Lag

group by region