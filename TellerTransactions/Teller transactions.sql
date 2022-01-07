
declare @fromDate as date = '2021-09-13';
declare @toDate as date = '2021-10-15';
declare @branchId as nvarchar(4) = '029';

    select
        concat(a.bch,'-',a.acct_no) Account,
        a.op_bch BranchId,
        (select b.bch_add
        from webloan.dbo.branch_set b
        where a.op_bch = b.bch)  BranchName,
        a.amt TransactionAmount,
        a.sbal1 BeforeAvailableBalance,
        a.bal1 AfterAvailableBalance,
        a.sbal1 BeforeLedgerBalance,
        a.bal2 AfterLedgerBalance,
        (select td.tc_name
        from SAVEPLUS.dbo.tcdata td
        where a.tc = td.tc and a.tc_type = td.tc_type) as TransactionType,
        a.reference Description,
        a.op_fullname Username,
        a.tdate TransactionDate


    from SAVEPLUS.dbo.trans a


    where cast(a.tdate  as date )between @fromDate and @toDate

        and a.op_bch=ISNULL(@branchId,a.op_bch)


union


    select
        concat(b.bch,'-',b.acct_no) Account,
        b.op_bch BranchId,
        (select bb.bch_add
        from webloan.dbo.branch_set bb
        where b.op_bch = bb.bch)  BranchName,
        b.amt TransactionAmount,
        b.sbal1 BeforeAvailableBalance,
        b.bal1 AfterAvailableBalance,
        b.sbal1 BeforeLedgerBalance,
        b.bal2 AfterLedgerBalance,
        (select td.tc_name
        from SAVEPLUS.dbo.ca_tcdata td
        where b.tc = td.tc and b.tc_type = td.tc_type) as TransactionType,
        b.reference Description,
        b.op_fullname Username,
        b.tdate TransactionDate


    from SAVEPLUS.dbo.ca_trans b


    where cast(b.tdate  as date )between @fromDate and @toDate

        and b.op_bch=ISNULL(@branchId,b.op_bch)