--declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-3')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

with comp as
(
select
distinct
 [Year-Month]
,[Date Updated]
,slip_num as 'CHARGE SLIP #'
,tar_id as 'TAR ID'
,file_date as 'FILE DATE'
,service_date as 'SERVICE DATE'
,pat_name as 'PATIENT NAME'
,account_name as 'ACCOUNT NAME'
,region_id as 'REGION ID'
,region_name as 'REGION NAME'
,location_id as 'LOCATION ID'
,location_name as 'LOCATION NAME'
,department_id as 'DEPARTMENT ID'
,department_name as 'DEPARTMENT NAME'
,prov_name as 'PROVIDER NAME'
,case when [original procedure] <> [new procedure] then 'No' else 'Yes' end as 'ORIG PX KEPT?'
,[Original Procedure]
,case when [New Procedure] = '<deleted>' then 'Deleted Line' else [New Procedure] end as 'New Procedure'
--,[New Procedure]
,case when [original modifier] <> [new modifier] then 'No' else 'Yes' end as 'ORIG MOD KEPT?'
,case when [original modifier] is null then '' 
      when [original modifier] = '<blank>' then ''
	  when [original modifier] = ' []' then ''
	  else [original modifier] end as 'ORIGINAL MODIFIER'
,case when [new modifier] is null then '' else [new modifier] end as 'NEW MODIFIER'
,case when [original diagnosis] <> [new diagnosis] then 'No' else 'Yes' end as 'ORIG DX KEPT?'
,[Original Diagnosis]
,[New Diagnosis]
,Reviewer
,coalesce(Comment,'') as 'Comment'
,DATA_FIELD_LINE
,data_field
,line
,ROW_NUMBER() OVER(PARTITION BY tar_id, charge_line, [original procedure], [new procedure], [original modifier], [new modifier]
,[original diagnosis], [new diagnosis] ORDER BY line desc) as Row#

from 

(select
 slip_num
,pac.tar_id
,cast(file_date as date) as file_date
,cast(service_date as date) as service_date
,pat.pat_name
,acct.account_name
,sa.rpt_grp_ten as region_id
,upper(sa.name) as region_name
,loc.loc_id as location_id
,loc.loc_name as location_name
,dep.department_id as department_id
,dep.department_name as department_name
,ser_bill.prov_name
,date.year_month_str as 'Year-Month'
,getdate() as 'Date Updated'
,case when data_field = 150 and px_comment_yn is null and aud.data_field_line = pac.charge_line then old_value 
      when data_field = 150 and new_value is not null then old_value
	  end as 'Original Procedure'
,case when data_field = 150 and px_comment_yn is null and aud.data_field_line = pac.charge_line then new_value 
	  when data_field = 150 and new_value is not null then new_value
	  end as 'New Procedure'
,case when data_field = 160 and aud.data_field_line = pac.charge_line then old_value 
	 when data_field = 160 and px_comment_yn is null and new_value is not null then old_value
	 end as 'Original Modifier'
,case when data_field = 160 and aud.data_field_line = pac.charge_line then new_value 
     when data_field = 160 and px_comment_yn is null and new_value is not null then new_value
	 end as 'New Modifier'
,case when data_field = 130 and aud.data_field_line = pac.charge_line then old_value 
     when data_field = 130 and px_comment_yn is null and new_value is not null then old_value
     end as 'Original Diagnosis'
,case when data_field = 130 and aud.data_field_line = pac.charge_line then new_value 
     when data_field = 130 and px_comment_yn is null and new_value is not null then new_value
	 end as 'New Diagnosis'
,emp.name as 'Reviewer'
,crh.chg_hx_comment as 'Comment'
,aud.DATA_FIELD_LINE
,data_field
,crh.line
,charge_line

from
Clarity.dbo.pre_ar_chg pac
left join Clarity.dbo.patient pat on pat.pat_id = pac.pat_id
left join Clarity.dbo.account acct on acct.account_id = pac.account_id
left join Clarity.dbo.clarity_ser ser_bill on ser_bill.prov_id = pac.bill_prov_id
left join Clarity.dbo.CHG_REVIEW_ACT_AUD aud on aud.tar_id = pac.tar_id -- and aud.data_field_line = pac.charge_line
left join Clarity.dbo.clarity_eap eap on eap.proc_id = pac.proc_id
left join Clarity.dbo.CHG_REVIEW_DX crd on crd.tar_id = pac.tar_id and crd.line = pac.charge_line
left join Clarity.dbo.chg_review_mods mod on mod.tar_id = pac.tar_id
left join Clarity.dbo.clarity_loc loc on loc.loc_id = pac.loc_id
left join Clarity.dbo.clarity_dep dep on dep.department_id = pac.proc_dept_id
left join Clarity.dbo.zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join Clarity.dbo.CHG_REVIEW_HX crh on crh.tar_id = aud.tar_id and CHG_HX_ACTIVITY_C in (2)
left join Clarity.dbo.CLARITY_EMP emp on emp.user_id = crh.chg_hx_user_id
left join Clarity.dbo.DATE_DIMENSION date on date.calendar_dt = pac.file_date


where
 
file_date between '1/1/2018' and '1/31/2018'
--and ser_bill.prov_name = 'mousa, soha'
--and file_date <= @end_date
--and aud.data_field in (130,150,160,180) -- 130 Diagnosis, 150 - Procedure, 160 - Modifier, 180 - Charge Amount
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and aud.tar_id is not null
--and pac.tar_id in (257673862,258214815,258320296, 258287348, 258287348, 258146502)
--and pac.tar_id = 272897499
and data_field in (130,150,160)
--and slip_num in (19478780, -8579013)
--and pac.tar_id = 268102674
--and slip_num = 19133275
--group by 
-- year_month_str
--,pac.slip_num
--,pac.tar_id
--,file_date
--,service_date
--,pat.pat_name
--,acct.account_name
--,ser_bill.prov_name
--,sa.rpt_grp_ten
--,sa.name
--,loc.rpt_grp_two
--,loc.rpt_grp_three
--,dep.rpt_grp_one
--,dep.rpt_grp_two
--,emp.name
--,crh.chg_hx_comment
----,aud.DATA_FIELD_LINE
)a
)

select * from comp
where row#= 1

order by 
[TAR ID]
