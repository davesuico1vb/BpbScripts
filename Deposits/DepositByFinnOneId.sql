select

    a.accountid FinnOne,
    b.acct_no AccountId,
    b.bch AccountBranchId,
    b.name AccountName,
    b.ebal1 AvailableBalance,
    b.ebal2 LedgerBalance

from

    dbo.acct_no_lookup a

    left join
    dbo.account b on a.bch = b.bch

        and a.acct_no = b.acct_no

where accountid in 

(
116061004390,
116061010450,
116061008130,
116061005443,
116061006310,
118051091040,
116061009083,
116061006980,
116061009160,
10251293901,
116061006090,
116061005674
)