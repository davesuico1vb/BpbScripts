declare @cutoff date  = '2021-10-31';

select  

a.bch BranchId,
a.acct_no AccountId,
SAVEPLUS.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@cutoff,1) AvailableBalance,
SAVEPLUS.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@cutoff,2) LedgerBalance,
a.sa_acct_no SavingsAccountId,
a.sa_bch SavingsAccountBranchId,
@cutoff CutOffDate
 
from SAVEPLUS.dbo.ca_account a


where a.sa_acct_no is not null

and a.sa_acct_no !=''

and (a.close_date is null or cast(a.close_date as date) > @cutoff  )

order by a.close_date desc;


