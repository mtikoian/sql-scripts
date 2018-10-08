select 
region as Region
,year_month as Year_Month
,month_year as Month_Year
, count(*) as 'Provider Count'

from 

(
select 
distinct 
region
,year_month
,month_year
,visit_provider_id
,visit_provider
from ClarityCHPUtil.rpt.PB_COPR_Encounters

where 
open_encounters >= 30
and year_month = 201708
)a

group by
region
,year_month
,month_year

order by
region
,year_month
,month_year