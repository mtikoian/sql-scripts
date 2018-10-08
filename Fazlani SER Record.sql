select tx_id, prov_name, * from clarity_Tdl_tran tdl
left join clarity_ser ser on ser.prov_id = tdl.performing_prov_id where tx_id = 15353 

select * from clarity_ser_dept where prov_id = '1003206'

select * from clarity_dep where department_id = 11101216

select * from clarity_loc where loc_id = 11101

select * from clarity_ser where prov_id = '1003206'