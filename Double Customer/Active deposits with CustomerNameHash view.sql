USE [READONLY]
GO

/****** Object:  View [dbo].[CustomerHashWithActiveAccounts]    Script Date: 10/21/2021 6:51:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[CustomerHashWithActiveAccounts]

as

select 
e.*, 
(select concat(a.fname,a.mname,a.lname,a.p_bday) from WEBLOAN.dbo.cis_info a where e.CustomerId = a.cis_no) CustomerNameHash

from 

(
select 

c.*,
d.cis_no CustomerId,
d.bch CustomerBranch

from (

select
a.acct_no AccountId,
a.bch AccountBranchId

from SAVEPLUS.dbo.account a

where a.close_date is null

union

select

b.acct_no,
b.bch

from SAVEPLUS.dbo.ca_account b
where b.close_date is null

) c

left join WEBLOAN.dbo.cis_lookup d
on c.AccountId = d.acct_no and c.AccountBranchId = d.bch

)e where e.CustomerId is not null

GO


