select * From READONLY.dbo.LoanListing where 

CutOffDate >= (select MAX(CutOffDate) from READONLY.dbo.LoanListing)

and BytePrincipalBalance <=0