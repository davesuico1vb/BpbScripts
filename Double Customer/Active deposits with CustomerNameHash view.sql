USE [READONLY]
GO

/****** Object:  View [dbo].[CustomerHashWithActiveAccounts]    Script Date: 11/4/2021 2:16:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[CustomerHashWithActiveAccounts]

as

    select
        e.*,
        (select LOWER(REPLACE(concat(a.fname,a.mname,a.lname,a.p_bday),' ',''))
        from WEBLOAN.dbo.cis_info a
        where e.CustomerId = a.cis_no) CustomerNameHash,
        'Deposit' AccountType

    from

        (
select

            c.*,
            d.cis_no CustomerId


        from (

                select
                    a.acct_no AccountId,
                    a.bch AccountBranchId,
                    cast (a.open_date as date) OpenDate

                from SAVEPLUS.dbo.account a with (nolock)

                where a.close_date is null

            union

                select

                    b.acct_no AccountId,
                    b.bch AccountBranchId,
                    cast (b.open_date as date) OpenDate

                from SAVEPLUS.dbo.ca_account b with (nolock)
                where b.close_date is null

) c

            left join WEBLOAN.dbo.cis_lookup d with (nolock)
            on c.AccountId = d.acct_no and c.AccountBranchId = d.bch

)e
    where e.CustomerId is not null


union all


    select

        b.*,
        (select LOWER(REPLACE(concat(a.fname,a.mname,a.lname,a.p_bday),' ',''))
        from WEBLOAN.dbo.cis_info  a with (nolock)
        where b.CustomerId = a.cis_no) CustomerNameHash,
        'Loan' AccountType

    from

        (

select
            a.loan_no AccountId,
		
            a.bch AccountBranchId,
			
			cast(a.date_granted as date) OpenDate,

            (select lai.cis_no
            from webloan.dbo.loan_acct_info lai with (nolock)
            where a.bk=lai.bk
                and a.bch=lai.bch
                and a.acct_no=lai.acct_no) as CustomerId

        From WEBLOAN.dbo.loan_data a with (nolock)
        where close_date is null
) b

GO


