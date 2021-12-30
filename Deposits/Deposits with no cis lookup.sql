-- Savings 

select 

a.bch Branch,
a.acct_no AccountNumber,
a.name AccountName,
a.open_date OpenDate,
a.ebal1 AvailableBalance,
a.ebal2 LedgerBalance,
(
select top 1 description  from

WEBLOAN.dbo.logbook

where description like CONCAT('%',a.bch,a.acct_no,'%')

order by ldatetime desc
)LogbookLastMessage,
(
select top 1 fullname  from

WEBLOAN.dbo.logbook

where description like CONCAT('%',a.bch,a.acct_no,'%')

order by ldatetime desc
)LogbookLastTouchedBy


from SAVEPLUS.dbo.account a

where not exists(

select 1 from WEBLOAN.dbo.cis_lookup b 

where a.bch = b.bch and a.acct_no = b.acct_no

)

and close_date is null

and rxclass not in ('AR1','AP1')

and open_date is not null;


-- Checking Accounts


select 

a.bch Branch,
a.acct_no AccountNumber,
a.name AccountName,
a.open_date OpenDate,
a.ebal1 AvailableBalance,
a.ebal2 LedgerBalance,
(
select top 1 description  from

WEBLOAN.dbo.logbook

where description like CONCAT('%',a.bch,a.acct_no,'%')

order by ldatetime desc
)LogbookLastMessage,
(
select top 1 fullname  from

WEBLOAN.dbo.logbook

where description like CONCAT('%',a.bch,a.acct_no,'%')

order by ldatetime desc
)LogbookLastTouchedBy


from SAVEPLUS.dbo.ca_account a

where not exists(

select 1 from WEBLOAN.dbo.cis_lookup b 

where a.bch = b.bch and a.acct_no = b.acct_no

)

and close_date is null


and open_date is not null