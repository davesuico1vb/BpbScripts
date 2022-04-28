

select

    a.AccountId,
    a.BranchId,
    (select top 1
        b.amt
    from SAVEPLUS.dbo.ca_trans b
    where a.AccountId = b.acct_no and a.BranchId = b.bch and b.symbol='GINT' and a.CutOffDate >= cast(b.tdate as date)
    order by id_code desc) AccumulatedInterest,
    (select top 1
        b.amt
    from SAVEPLUS.dbo.ca_trans b
    where a.AccountId = b.acct_no and a.BranchId = b.bch and b.symbol='WT' and a.CutOffDate >= cast(b.tdate as date)
    order by id_code desc) Tax,
    (select top 1
        cast(b.tdate as date)
    from SAVEPLUS.dbo.ca_trans b
    where a.AccountId = b.acct_no and a.BranchId = b.bch and b.symbol='WT' and a.CutOffDate >= cast(b.tdate as date)
    order by id_code desc) LastInterestDate,
    a.ByteScheme,
    a.FinnOneScheme

from READONLY.dbo.DepositListing a



where a.CutOffDate ='2022-01-31'

    and a.FinnOneScheme in ('1STCC1',
'1STCC2')
