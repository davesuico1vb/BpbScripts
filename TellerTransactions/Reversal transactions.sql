
declare @BranchId as nvarchar(10) = null;

declare @FromDate as date = '2021-09-13'

declare @ToDate as date = '2021-11-30'



select * from

(


select 

        a.id_code TransactionId,
        a.bch BranchId,
        (select b.bch_add	
                        from webloan.dbo.branch_set b		
                        where a.bch = b.bch)  BranchName,	
        a.acct_no AccountNumber,
        (select Replace(Replace(b.name,CHAR(10),''),CHAR(13),'') from SAVEPLUS.dbo.account b where a.bch = b.bch and a.acct_no = b.acct_no) AccountName,
        a.reference Narration,
        (select td.tc_name from SAVEPLUS.dbo.tcdata td where a.tc = td.tc and a.tc_type = td.tc_type) as TransactionDescription,
        a.op_fullname PostedBy,
        a.sbal2 BeginningBalance,
        a.amt TransactionAmount,
        a.bal2 EndingBalance,
        a.tdate TransactionDate,
		FORMAT(CAST(a.tdate AS datetime2), N'hh:mm tt') TransactionTime,
        a.symbol Symbol,
        case 
            when a.bal2 > a.sbal2 then 'Credit'

            else 'Debit'
        end Movement
        From SAVEPLUS.dbo.trans a

        where exists(


        select 1 from SAVEPLUS.dbo.account b
        where  a.bch = b.bch
            and a.acct_no = b.acct_no

        )

		and a.tc in (
			select td.tc from SAVEPLUS.dbo.tcdata td where tc_name like '%rev%' or tc_name like '%cor%'
		)


		union all

		select 

        ca.id_code TransactionId,
        ca.bch BranchId,
        (select b.bch_add	
                        from webloan.dbo.branch_set b		
                        where ca.bch = b.bch)  BranchName,	
        ca.acct_no AccountNumber,
        (select  Replace(Replace(b.name,CHAR(10),''),CHAR(13),'') from SAVEPLUS.dbo.ca_account b where ca.bch = b.bch and ca.acct_no = b.acct_no) AccountName,
        ca.reference Narration,
        (select td.tc_name from SAVEPLUS.dbo.tcdata td where ca.tc = td.tc and ca.tc_type = td.tc_type) as TransactionDescription,
        ca.op_fullname PostedBy,
        ca.sbal2 BeginningBalance,
        ca.amt TransactionAmount,
        ca.bal2 EndingBalance,
        ca.tdate TransactionDate,
		FORMAT(CAST(ca.tdate AS datetime2), N'hh:mm tt') TransactionTime,
        ca.symbol Symbol,
        case 
            when ca.bal2 > ca.sbal2 then 'Credit'

            else 'Debit'
        end Movement
        From SAVEPLUS.dbo.ca_trans ca

        where exists(


        select 1 from SAVEPLUS.dbo.ca_account b
        where  ca.bch = b.bch
            and ca.acct_no = b.acct_no
        )

		and ca.tc in (
			select td.tc from SAVEPLUS.dbo.tcdata td where tc_name like '%rev%' or tc_name like '%cor%'
		)
) z


        where cast(z.TransactionDate as date) between @FromDate and @ToDate

        and z.BranchId = isnull(@BranchId,z.BranchId)

		


        order by z.TransactionId desc