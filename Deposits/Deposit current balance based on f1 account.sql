
select 

CONCAT(bch,'-',acct_no) ByteAccount,
add2 FinnOneAccount,
name AccountName,
saveplus.dbo.get_virtual_ebal12(bk,bch,acct_no,GETDATE(),2) as LedgerBalance,
cast(getdate() as date) BalanceDate


from saveplus.dbo.account

where add2 in ('116051171047')