select 

Account,
cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, TransactionDate), 0)as date)Month,
sum(CompoundedDailyBalance) TotalDailyBalance,
sum(DaysBeforeNextTransaction) TotalDays,
cast(sum(CompoundedDailyBalance) / sum(DaysBeforeNextTransaction) as decimal(18,2)) AverageDailyBalance

from dbo.AccountDailyBalance

where Account='003-51-14397-6'



group by Account, DATEADD(MONTH, DATEDIFF(MONTH, 0, TransactionDate), 0)