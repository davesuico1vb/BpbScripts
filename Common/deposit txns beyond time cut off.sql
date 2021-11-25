

select

    b.bch AccountBranchId,
    b.acct_no Accountid,
    b.account_name AccountName,
    b.op_bch OperatingBranchId,
    (select a.bch_add
    from SAVEPLUS.dbo.branch_set a
    where b.op_bch = a.bch) OperatingBranchName,
    b.op_fullname PostedBy,
    b.amt Amount,
    b.reference Narration,
    b.txn_descritpion TransactionType,
    b.tdate TransactionDate,
    cast(b.tdate as date) CutOff,
    FORMAT(CAST(b.tdate AS datetime2), N'hh:mm tt') Time

from

    (

        select


            a.bch ,
            a.acct_no ,
            (select b.name
            from SAVEPLUS.dbo.account b
            where a.bch = b.bch and a.acct_no = b.acct_no) account_name,
            a.op_bch ,
            a.op_fullname ,
            a.amt ,
            a.tdate,
            a.reference,
            (select td.tc_name
            from SAVEPLUS.dbo.tcdata td
            where a.tc = td.tc and a.tc_type = td.tc_type) as txn_descritpion


        from

            SAVEPLUS.dbo.trans a


    union all

        select


            a.bch,
            a.acct_no,
            (select b.name
            from SAVEPLUS.dbo.ca_account b
            where a.bch = b.bch and a.acct_no = b.acct_no) account_name,
            a.op_bch,
            a.op_fullname,
            a.amt,
            a.tdate,
            a.reference,
            (select td.tc_name
            from SAVEPLUS.dbo.ca_tcdata td
            where a.tc = td.tc and a.tc_type = td.tc_type) as txn_descritpion

        from

            SAVEPLUS.dbo.ca_trans a


) b

where b.op_bch = '016'

    and CAST(b.tdate as time) > '18:30'

    and op_fullname not like '%system%'

order by tdate desc