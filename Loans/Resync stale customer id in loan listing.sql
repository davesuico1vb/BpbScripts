
update readonly.dbo.LoanListing  set customerid=b.cis_no
 from readonly.dbo.LoanListing a, webloan.dbo.loan_acct_info b, webloan.dbo.loan_data c 
 where a.AgreementId=c.loan_no and b.acct_no=c.acct_no and b.bch=c.bch and a.CutOffDate >= '2022-01-31' and a.CustomerId<>b.cis_no;