select * from READONLY.dbo.DepositListing where LedgerBalance < 0

and CutOffDate = (select max(CutOffDate) from READONLY.dbo.DepositListing)