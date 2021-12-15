select 

b.bch Branch_ID,
(select c.bch_add from WEBLOAN.dbo.branch_set c where c.bch = b.bch) BRANCH_NAME,
*




from 

readonly.dbo.fv_loan_balance  a

left join webloan.dbo.loan_data b on cast(a.agreementid as nvarchar(MAX)) = b.loan_no

where a.PRINCIPAL_BALANCE <=0


