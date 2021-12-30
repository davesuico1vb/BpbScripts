select  

a.BranchId,
a.AccountId,
a.CustomerId,
(
select cis_no from WEBLOAN.dbo.cis_lookup b where a.BranchId= b.bch and a.AccountId=b.acct_no
)NewCIS,
a.AccountName


from READONLY.dbo.DepositListing a

where not exists(

select 1 from WEBLOAN.dbo.cis_info b

where a.CustomerId = b.cis_no
) order by a.CutOffDate desc