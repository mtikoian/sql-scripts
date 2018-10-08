select 
 upper(sa.name) as 'Region'
,dep.rpt_grp_two as 'Department'
,dep.specialty as 'Specialty'
,dep_add.address as 'Address'
,dep2.address_city as 'City'
,state.abbr as 'State'
,dep2.address_zip_code as 'Zip'
,ser.prov_name as 'Billing Provider'
,date.year_month as 'Month of Service'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,dep.rpt_grp_six as 'Department GRP 6'
,sum(arpb_tx.amount) as 'Chg Amount'

from arpb_transactions arpb_tx
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join date_dimension date on date.calendar_dt = arpb_tx.service_date
left join clarity_ser ser on ser.prov_id = arpb_tx.billing_prov_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join clarity_dep_addr dep_add on dep_add.department_id = dep.rpt_grp_one
left join clarity_dep_2 dep2 on dep2.department_id = dep.rpt_grp_one
left join zc_state state on state.state_c = dep2.address_state_c
where tx_type_c = 1 -- charges
and void_date is null -- exclude voids
and dep.rpt_grp_six in (101,102) -- include 101 or 102
and sa.rpt_grp_ten in (11,13,16,17,18,19) -- Mercy Regions
and arpb_tx.service_date >= '1/1/2016' -- service dates since 1/1/2016
and arpb_tx.amount <> 0 -- exclude $0 charge amounts
and dep_add.line = 1

group by 
 sa.name
,dep.rpt_grp_two
,dep_add.address
,dep2.address_city
,state.abbr 
,dep2.address_zip_code
,dep.specialty
,ser.prov_name
,date.year_month
,eap.proc_code
,eap.proc_name
,dep.rpt_grp_six 

order by 
 sa.name
,dep.rpt_grp_two
,dep_add.address
,dep2.address_city
,state.abbr 
,dep2.address_zip_code
,dep.specialty
,ser.prov_name
,date.year_month
,eap.proc_code
,eap.proc_name
,dep.rpt_grp_six 