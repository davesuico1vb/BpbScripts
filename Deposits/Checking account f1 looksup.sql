--associate f1 accountids to byte but check first if it already exist
select *
  from SAVEPLUS.dbo.acct_no_lookup
  where bch = '066' and acct_no = '21-00056-9'

insert into SAVEPLUS.dbo.acct_no_lookup(accountid,bch,acct_no,saca)
values ('154022000573', '066','21-00056-9', 2)