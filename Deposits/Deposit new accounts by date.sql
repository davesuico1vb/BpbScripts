select 

z.*, 
(select top 1
                b.schemeid
            from MIGRATION.dbo.product_table b
            where z.bytescheme = b.what_class
            order by 1 desc) as FinnOneScheme

from 

(

select 

bch,
acct_no,
name accountname,
cast(open_date as date) open_date,
open_bal,
maturity,
close_date,
close_bal,
rxclass bytescheme,
cast(value_date as date)value_date

	
from SAVEPLUS.dbo.account


union


select

bch,
acct_no,
name accountname,
cast(open_date as date) open_date,
open_bal,
null maturity,
close_date,
close_bal,
caclass bytescheme,
null value_date


from SAVEPLUS.dbo.ca_account


) z where cast(z.open_date as date) between '2021-10-01' and '2021-10-31'