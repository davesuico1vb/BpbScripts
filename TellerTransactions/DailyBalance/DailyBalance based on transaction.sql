USE [READONLY]
GO

/****** Object:  View [dbo].[AccountDailyBalance]    Script Date: 12/29/2021 6:16:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[AccountDailyBalance] as 


select 

*,
(e.DaysBeforeNextTransaction * e.EndingBalance) CompoundedDailyBalance
from 

(
select 

*, 

isnull((
	select top 1 DATEDIFF(day,d.TransactionDate,b.tdate) TransactionDate from SAVEPLUS.dbo.trans b 
	where d.Account = concat(b.bch,'-',b.acct_no)
	and b.id_code > d.TransactionId
),1 ) DaysBeforeNextTransaction

from

(

select 
CONCAT(a.bch,'-',a.acct_no) Account,
cast(tdate as date) TransactionDate,
max(a.id_code) TransactionId,

(select bal2 from SAVEPLUS.dbo.trans b where b.id_code = max(a.id_code)) EndingBalance

from 

SAVEPLUS.dbo.trans a

group by

CONCAT(a.bch,'-',a.acct_no),cast(tdate as date)

)
d

)e
GO


