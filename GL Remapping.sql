/*Cincinnati: Where EAF 8200=6321 & ETR 92 or 94 = Admin, Contra, Bad, BadRecovery, Charity, Legacy Recovery or Legacy Contractual); Set DEP 4030 to 848000

Lorain: Where EAF 8200=6010 & DEP 4030=800000; Set EAF 8200 to 6051

Toledo: 
Where: EAF 8200     &      DEP4030;             Set EAF 8200 
                6734                       405000                  6710       
                6734                       410365                  6760
                6734                       440000                  6770
                6734                       468000                  6760
                6734                       471351                  6770
                6734                       430370                  6752
                6734                       642000                  6770
                6734                       792396                  6760       
                6749                       427351                  6734

Where EAF 8200=6734 & ETR 144=18105107; Set EAF 8200=6770

Where EAF 8200=6734 & ETR 144=18101151; Set EAF 8200=6760

Where EAF 8200=6734 & ETR 144=18103116; Set EAF 8200=6710

Where EAF 8200=6734 & ETR 144=18102102; Set EAF 8200=6740

Where ETR 144=18101257 or 19390163 & ETR 5001=1733188; Set DEP 4030=793387

Mercy Health:
Where: EAF 8200     &      DEP4030;             Set EAF 8200 
                6734                       405000                  6710       
                6734                       410365                  6760
                6734                       440000                  6770
                6734                       468000                  6760
                6734                       471351                  6770
                6734                       430370                  6752
                6734                       642000                  6770
                6734                       792396                  6760       
                6749                       427351                  6734

Where ETR 144=18101257 or 19390163 & ETR 5001=1733188; Set DEP 4030=793387
*/

select
 tx_id
,loc.gl_prefix
,dep.gl_prefix
,credit_gl_num
,debit_gl_num
,case when loc.gl_prefix = '6321' and (credit_gl_num in ('Admin', 'Contra', 'Bad', 'BadRecovery', 'Charity', 'Legacy Recovery', 'Legacy Contractual') 
or debit_gl_num in ('Admin', 'Contra', 'Bad', 'BadRecovery', 'Charity', 'Legacy Recovery', 'Legacy Contractual')) then '848000' else dep.gl_prefix end as 'Department_GL'
from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
where tdl.serv_area_id = 11
and orig_service_date >= '3/1/2017'
and detail_type in (2,11)
and loc.gl_prefix = '6321'
and debit_gl_num = 'badrecovery'