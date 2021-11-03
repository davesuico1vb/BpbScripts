

select * from(

select bch,acct_no,ebal1 available,ebal2 ledger,close_date, rxclass schemeid,open_date,name

from SAVEPLUS.dbo.account

union

select bch,acct_no, ebal1 available,ebal2 ledger,close_date, caclass schemeid, open_date,name

from SAVEPLUS.dbo.ca_account)

a where not exists(

select 1 from WEBLOAN.dbo.cis_lookup z where z.acct_no = a.acct_no and z.bch = a.bch
)

and a.close_date is null

and open_date is not null