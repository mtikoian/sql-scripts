/*
Template Slot – Any slot opening within a provider’s schedule template
----------------
Available Slot – Any template slot listed as Available for both the day and the time
Unavailable Slot – Any template slot where the provider is not listed as Available either for the day or time
--------------
Regular Slot – Template slot that is not an overbook or Unavailable slot
Non-Regular Slot – Template Slot that is an overbook slot or an Unavailable slot 
------------------
Private Slot – any template that is an overbook slot or any slot marked as private or any slot blocked for a reason that is categorized as private. 
Public Slot – Not marked as private and is a regular slot and is not blocked for a reason that is categorized as private
------------------
Restricted Slot – Any Private slot or slot blocked as restricted
Non-Restricted Slot – Any Public Slot that is also not blocked as restricted

*/
use clarity
;
drop table if exists #providers 
drop table if exists #blocks
;
declare
		@startdate date = '8/01/2018'
		,@enddate date = '8/31/2018'
;
create table #providers (

		Prov_id varchar(18),
		npi varchar (99),
		market varchar (99),
		specialty varchar (99),
		Clinical_Fte numeric,
		Clinical_Hours numeric
)
;
create table #blocks (
		DEPARTMENT_ID numeric,
		PROV_ID varchar(18),
		SLOT_BEGIN_TIME datetime,
		Block_Private int,
		Block_Restricted int,
		Block_New_Patient int
)
;
insert into #providers (NPI, Prov_id, market,specialty, Clinical_Fte, Clinical_Hours)

select 
		Prov.NPI
		,clarity_ser.PROV_ID
		,prov.CIN_MARKETNAME
		,prov.AUTH_PROV_DEP_SPECIALTY
		,isnull(clinical_fte_temp.Clinical_Fte, 0)
		,isnull(clinical_fte_temp.Clinical_hours, 0)
from
		ClarityCHPUtil.PROVDEM.V_D_CUBE_PROVIDER as Prov
		inner join clarity.dbo.clarity_Ser_2 on clarity_ser_2.npi = prov.NPI
		inner join clarity.dbo.clarity_ser on clarity_ser.prov_id = clarity_ser_2.PROV_ID
		Left join ClarityCHPUtil.rpt.clinical_fte_temp on clinical_fte_temp.Prov_id = clarity_ser.PROV_ID
where
		prov.EMPLOYMENTTYPE = 'Employed'
		and prov.IS_MD = 'True'
		and clarity_Ser.ACTIVE_STATUS_c = 1
;
----------------
insert into #blocks (DEPARTMENT_ID, PROV_ID, SLOT_BEGIN_TIME, Block_Private, Block_Restricted, Block_New_Patient)

select 
		core.DEPARTMENT_ID
		,core.PROV_ID
		,core.SLOT_BEGIN_TIME
		,max(core.Block_Private) as Block_Private
		,max(core.Block_Restricted) as Block_Restricted
		,max(core.Block_New_Patient) as Block_New_Patient
from
		(
			select 
					AVAIL_BLOCK.DEPARTMENT_ID
					,AVAIL_BLOCK.PROV_ID
					,AVAIL_BLOCK.SLOT_BEGIN_TIME
					,zc_appt_block.NAME
					,AVAIL_BLOCK.BLOCK_C
					,case when ZC_APPT_BLOCK.APPT_BLOCK_C = '2' then 1 else 0 end as Block_Private ----same day
					,case when ZC_APPT_BLOCK.APPT_BLOCK_C not in ('1','2') then 1 else 0 end as Block_Restricted
					,case when ZC_APPT_BLOCK.APPT_BLOCK_C ='1' then 1 else 0 end as Block_New_Patient
			from 
					clarity.dbo.AVAIL_BLOCK
					inner join clarity.dbo.zc_appt_block on ZC_APPT_BLOCK.INTERNAL_ID = AVAIL_BLOCK.BLOCK_C
			where
					convert(date,AVAIL_BLOCK.SLOT_BEGIN_TIME) between @startdate and @enddate
		) as core
Group by
		core.DEPARTMENT_ID
		,core.PROV_ID
		,core.SLOT_BEGIN_TIME
-------------------------------------------------
;
Select   ---logic layer


		--core2.YEAR
		--,core2.MONTH_NUMBER
		--,Core2.MONTH_NAME
		core2.Region
		--,core2.LOC_NAME
		,core2.DEPARTMENT_NAME
		,core2.Department_Specialty
		,core2.Provider_Specialty
		,core2.PROV_NAME
		,core2.Clinical_Fte
		,core2.Clinical_Hours
		,core2.SLOT_BEGIN_TIME
		,core2.SLOT_LENGTH
		--,'---'
		, case when core2.Unavailable_Category = 'Available' then (core2.Reg_Openings + core2.Overbook_Openings) else 0 end as Available_Slots
		, case when core2.Unavailable_Category <> 'Available' then (core2.Reg_Openings + core2.Overbook_Openings) else 0 end as Unavailable_Slots
		, case when core2.Unavailable_Category = 'Available' then (core2.Num_Reg_Private_Appts_Scheduled + core2.Num_Reg_Public_Appts_Scheduled + core2.Num_Overbook_Appts_Scheduled) else 0 end as Available_Slots_Booked
		, case when core2.Unavailable_Category <> 'Available' then (core2.Num_Reg_Private_Appts_Scheduled + core2.Num_Reg_Public_Appts_Scheduled + core2.Num_Overbook_Appts_Scheduled) else 0 end as Unavailable_Slots_Booked
		--,'---'
		, case when core2.Unavailable_Category = 'Available' then core2.Reg_Openings else 0 end as Regular_Slots									--this covers regular private and regular public
		, case when core2.Unavailable_Category <> 'Available' then core2.Reg_Openings else 0 end + core2.Overbook_slots_Private as Non_Regular_Slots
		, case when core2.Unavailable_Category = 'Available' then core2.Num_Reg_Private_Appts_Scheduled + core2.Num_Reg_Public_Appts_Scheduled else 0 end as Regular_Slots_booked
		, case when core2.Unavailable_Category <> 'Available' then core2.Num_Reg_Private_Appts_Scheduled + core2.Num_Reg_Public_Appts_Scheduled else 0 end + core2.Num_Overbook_Appts_Scheduled as Non_Regular_Slots_Booked
		--,'---'
		, case when core2.Block_Private = 1 then core2.Reg_Slots_Public else 0 end + Reg_Slots_Private + core2.Overbook_slots_Private as Private_Slots
		, case when core2.Block_Private = 0 then core2.Reg_Slots_Public else 0 end as Public_Slots
		, case when core2.Block_Private = 1 then core2.Num_Reg_Public_Appts_Scheduled else 0 end + core2.Num_Reg_Private_Appts_Scheduled + core2.Num_Overbook_Appts_Scheduled as Private_Slots_Booked
		, case when core2.Block_Private = 0 then core2.Num_Reg_Public_Appts_Scheduled else 0 end as Public_Slots_Booked
		--,'---'
		, case when (core2.Block_Private = 1 or core2.Block_Restricted = 1) then core2.Reg_Slots_Public else 0 end + Reg_Slots_Private + core2.Overbook_slots_Private as Restricted_Slots
		, case when core2.Block_Private = 0 and core2.Block_Restricted = 0 then core2.Reg_Slots_Public else 0 end as Non_Restricted_Slots
		, case when (core2.Block_Private = 1 or core2.Block_Restricted = 1) then core2.Num_Reg_Public_Appts_Scheduled else 0 end + core2.Num_Reg_Private_Appts_Scheduled + core2.Num_Overbook_Appts_Scheduled as Restricted_Slots_Booked
		, case when core2.Block_Private = 0 and core2.Block_Restricted = 0 then core2.Reg_Slots_Public else 0 end as Non_Restricted_Slots_Booked
		,Core2.Block_New_Patient
		
		
		--,core2.Unavailable_Category
		--,core2.Reg_Openings
		--,core2.Overbook_Openings
		--,core2.Reg_Slots_Public
		--,core2.Reg_Slots_Private
		--,core2.Overbook_slots_Private
		--,core2.Num_Reg_Private_Appts_Scheduled
		--,core2.Num_Reg_Public_Appts_Scheduled
		--,core2.Num_Overbook_Appts_Scheduled
		--,core2.Block_Private
		--,core2.Block_Restricted

from
		(

			Select ---this level does math/logic on the multiple rows to get to 1 row per slot
					core.YEAR
					,core.MONTH_NUMBER
					,Core.MONTH_NAME
					,core.Region
					,core.LOC_NAME
					,core.DEPARTMENT_NAME
					,core.DEPARTMENT_ID
					,core.Department_Specialty
					,core.Provider_Specialty
					,core.PROV_NAME
					,core.PROV_ID
					,core.Clinical_Fte
					,core.Clinical_Hours
					,core.SLOT_BEGIN_TIME
					,core.SLOT_LENGTH 
					,max(core.Reg_Openings) as Reg_Openings
					,max(core.Overbook_openings) as Overbook_Openings
					,Max(core.Unavailable_Category) as Unavailable_Category
					,Max(core.Reg_Slots_Public) as Reg_Slots_Public
					,Max(core.Reg_Slots_Private) as Reg_Slots_Private
					,max(core.Overbook_Slots_Private) as Overbook_slots_Private
					,sum(core.Num_Reg_Private_Appts_Scheduled) as Num_Reg_Private_Appts_Scheduled
					,sum(core.Num_Reg_Public_Appts_Scheduled) as Num_Reg_Public_Appts_Scheduled
					,sum(Num_Overbook_Appts_Scheduled) as Num_Overbook_Appts_Scheduled
					,isnull(#blocks.Block_Private, 0) as Block_Private
					,isnull(#blocks.Block_Restricted, 0) as Block_Restricted
					,isnull(#blocks.Block_New_patient,0) as Block_New_Patient
			from
					(
						select						---this level pulls the raw data
								ZC_LOC_RPT_GRP_10.name as Region
								,ZC_SPECIALTY_DEP.NAME as Department_Specialty
								,clarity_dep.DEPARTMENT_NAME
								,clarity_Dep.DEPARTMENT_ID
								,clarity_loc.LOC_NAME
								,clarity_ser.prov_name
								,clarity_Ser.PROV_ID
								,#providers.Clinical_Fte
								,#providers.clinical_Hours
								,ZC_SPECIALTY.NAME as Provider_Specialty
								,AVAILABILITY.SLOT_BEGIN_TIME 
								,DATE_DIMENSION.MONTH_NUMBER
								,DATE_DIMENSION.MONTH_NAME
								,DATE_DIMENSION.YEAR
								,AVAILABILITY.SLOT_LENGTH	
								, case when AVAILABILITY.appt_number = 0 then AVAILABILITY.ORG_REG_OPENINGS else 0 end as Reg_Openings																	--take max
								, case when AVAILABILITY.appt_number = 0 then AVAILABILITY.ORG_OVBK_OPENINGS else 0 end as Overbook_openings															--take max
								, case when AVAILABILITY.appt_number = 0 and AVAILABILITY.PRIVATE_YN = 'N' then ORG_REG_OPENINGS else 0 end as Reg_Slots_Public											--take max					
								, case when AVAILABILITY.appt_number = 0 and AVAILABILITY.PRIVATE_YN = 'Y' then ORG_REG_OPENINGS else 0 end as Reg_Slots_Private										--take max
								, case when AVAILABILITY.appt_number = 0 then AVAILABILITY.ORG_OVBK_OPENINGS else 0 end as Overbook_Slots_Private														--take max
								, case when AVAILABILITY.appt_number <> 0 and APPT_OVERBOOK_YN = 'N' and AVAILABILITY.PRIVATE_YN = 'Y' then 1 else 0 end as Num_Reg_Private_Appts_Scheduled				--take Sum
								, case when AVAILABILITY.appt_number <> 0 and APPT_OVERBOOK_YN = 'N' and AVAILABILITY.PRIVATE_YN = 'N' then 1 else 0 end as Num_Reg_Public_Appts_Scheduled				--take Sum
								, case when AVAILABILITY.appt_number <> 0 and AVAILABILITY.APPT_OVERBOOK_YN = 'Y' then 1 else 0 end as Num_Overbook_Appts_Scheduled										--take sum
								,AVAILABILITY.PRIVATE_YN
								,case
									when 
									    (ZC_UNAVAIL_REASON.INTERNAL_ID in (14,21,22,23,24,7,55,10,26,6,49,57,53,52,31,18,34,50,58,54,5,43,44,46,11,47,48) 
										or Day_unavail_reason.internal_id in (14,21,22,23,24,7,55,10,26,6,49,57,53,52,31,18,34,50,58,54,5,43,44,46,11,47,48))
									then 'Clinical' 
									when 
										(ZC_UNAVAIL_REASON.INTERNAL_ID in (8,56,60,59,4,19,20,9,16,59,2,61,13,42,17,62,3,1) 
										or Day_unavail_reason.internal_id in (8,56,60,59,4,19,20,9,16,59,2,61,13,42,17,62,3,1))
									then 'Non-Clinical' 
									else 'Available'
									End as Unavailable_Category																											--take max
						From
								clarity.dbo.AVAILABILITY 
								
								inner join clarity.dbo.clarity_Dep on clarity_dep.DEPARTMENT_ID = AVAILABILITY.DEPARTMENT_ID
								Left join clarity.dbo.ZC_SPECIALTY_DEP on ZC_SPECIALTY_DEP.INTERNAL_ID = clarity_dep.SPECIALTY_DEP_C
								inner join clarity.dbo.clarity_loc on clarity_loc.LOC_ID = clarity_Dep.REV_LOC_ID
								Inner join clarity.dbo.ZC_LOC_RPT_GRP_10 on ZC_LOC_RPT_GRP_10.INTERNAL_ID = clarity_loc.RPT_GRP_TEN
								inner join clarity.dbo.clarity_ser on clarity_ser.prov_id = AVAILABILITY.PROV_ID
								inner join #providers on #providers.Prov_id = clarity_ser.PROV_ID
								Left join clarity.dbo.clarity_Ser_spec on clarity_ser_spec.PROV_ID = clarity_ser.PROV_ID
										and clarity_Ser_spec.LINE = 1
								Left join clarity.dbo.ZC_SPECIALTY on ZC_SPECIALTY.INTERNAL_ID = clarity_ser_spec.SPECIALTY_C
								inner join clarity.dbo.DATE_DIMENSION on converT(date,DATE_DIMENSION.CALENDAR_DT) = convert(date, AVAILABILITY.SLOT_BEGIN_TIME)
								LEft join clarity.dbo.ZC_UNAVAIL_REASON on ZC_UNAVAIL_REASON.INTERNAL_ID = AVAILABILITY.UNAVAILABLE_RSN_C
								Left join clarity.dbo.ZC_UNAVAIL_REASON as Day_unavail_reason on Day_unavail_reason.INTERNAL_ID = AVAILABILITY.DAY_UNAVAIL_RSN_C
								Left join clarity.dbo.ZC_HELD_REASON on ZC_HELD_REASON.INTERNAL_ID = AVAILABILITY.DAY_HELD_RSN_C
								Left join clarity.dbo.ZC_HELD_REASON as Time_held_Reason on Time_held_Reason.INTERNAL_ID = AVAILABILITY.DAY_HELD_RSN_C
								Left join clarity.dbo.ZC_APPT_BLOCK on ZC_APPT_BLOCK.INTERNAL_ID = AVAILABILITY.APPT_BLOCK_C
							
						where
								AVAILABILITY.SLOT_BEGIN_TIME > @startdate							--date range
								and convert(date,AVAILABILITY.SLOT_BEGIN_TIME) <= @enddate			--date range
								and try_convert(int,clarity_loc.RPT_GRP_TEN) < 20	--mercy only
								and clarity_ser.STAFF_RESOURCE_C = 1				--people only
								--and clarity_ser.prov_id in ('3051512')
							) as core
					Left join #blocks on #blocks.DEPARTMENT_ID = core.DEPARTMENT_id
					and #blocks.PROV_ID = core.PROV_ID
					and #blocks.SLOT_BEGIN_TIME = Core.SLOT_BEGIN_TIME
		


					Group by
							core.YEAR
							,core.MONTH_NUMBER
							,Core.MONTH_NAME
							--,core.WEEK_NUMBER
							,core.Region
							,core.LOC_NAME
							,core.DEPARTMENT_NAME
							,core.DEPARTMENT_ID
							,core.Department_Specialty
							,core.Provider_Specialty
							,core.PROV_NAME
							,core.PROV_ID
							,core.Clinical_Fte
							,core.Clinical_Hours
							,core.SLOT_LENGTH
							,core.SLOT_BEGIN_TIME
							,isnull(#blocks.Block_Private, 0)
							,isnull(#blocks.Block_Restricted, 0) 
							,isnull(#blocks.Block_New_patient,0)
					
		) as core2
		
		

