select * from (
select 

a.bch,
a.acct_no,
cast(a.close_date as date) close_date,
a.close_bal,
a.rxclass scheme

from 


SAVEPLUS.dbo.account a

where rxclass not in('AR1','AP1')

union

select 

ca.bch,
ca.acct_no,
cast(ca.close_date as date) close_date,
ca.close_bal,
ca.caclass scheme


from

SAVEPLUS.dbo.ca_account ca



) z where z.close_date between '2021-10-01' and '2021-10-31'