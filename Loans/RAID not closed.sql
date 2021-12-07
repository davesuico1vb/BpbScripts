select

    d.* ,
    cast(e.date_granted as date) NewAgreementGrantedDate,
    e.principal NewAgreementPrincipal,
    webloan.dbo.get_virtual_principal_bal(e.bk,e.bch,e.acct_no,e.loan_no,GETDATE()) NewAgreementPrincipalBalance
from

    (



select

        b.loan_no OldAgreementId,
        b.bch OldAgreementBranchId,
        webloan.dbo.get_virtual_principal_bal(b.bk,b.bch,b.acct_no,b.loan_no,GETDATE()) OldPrincipalBalance,
        (
select

            c.loan_no

        from loan_data c

        where c.c_p_loan_no = b.loan_no

            and WEBLOAN.dbo.is_loan(c.loan_no) =1
            and c.close_date is null

) NewAgreementId


    from

        WEBLOAN.dbo.loan_data b

    where b.loan_no in (

select

            a.c_p_loan_no


        from


            WEBLOAN.dbo.loan_data a

        where c_p_loan_no <> ''

            and WEBLOAN.dbo.is_loan(a.loan_no) = 1

            and a.close_date is null

)


        and WEBLOAN.dbo.is_loan(b.loan_no) = 1

        and b.close_date is null
)d

    left join loan_data e

    on d.NewAgreementId = e.loan_no

where d.OldPrincipalBalance <> 0
