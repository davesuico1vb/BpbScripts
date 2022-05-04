--select * from WEBLOAN.dbo.loan_data_termination

--where exists(
--select * from

--)



    select
        z.*,
        DATEDIFF(day,z.termination_date,z.close_date) days_gap
    from(

select
            a.loan_no,
            a.bch,
            a.termination_date,
            (select top 1
                b.close_date
            from WEBLOAN.dbo.loan_data b
            where a.loan_no = b.loan_no
            order by b.close_date) close_date,
            WEBLOAN.dbo.get_loan_status_str(a.bk,a.bch,a.loan_no,getdate()) status
        from WEBLOAN.dbo.loan_data_termination a


        where exists(
select 1
            from WEBLOAN.dbo.loan_data b
            where a.loan_no = b.loan_no and cast(a.termination_date as date) != cast(b.close_date as date)
                and WEBLOAN.dbo.is_loan(b.loan_no) = 1
	
)

            and WEBLOAN.dbo.is_loan(a.loan_no) = 1

            and WEBLOAN.dbo.get_loan_status_str(a.bk,a.bch,a.loan_no,getdate()) !='Closed'

)z


union

    select
        b.loan_no,
        b.bch,
        ldt.termination_date,
        b.close_date,
        WEBLOAN.dbo.get_loan_status_str(b.bk,b.bch,b.loan_no,getdate()) status,
        DATEDIFF(day,ldt.termination_date,ISNULL(b.close_date,getdate())) days_gap

    from WEBLOAN.dbo.loan_data b
        left join WEBLOAN.dbo.loan_data_termination ldt on b.loan_no = ldt.loan_no

    where b.close_date is null

        and WEBLOAN.dbo.get_loan_status_str(b.bk,b.bch,b.loan_no,getdate()) != 'Closed'
        and WEBLOAN.dbo.is_loan(b.loan_no) = 1
        and exists(

select 1
        from WEBLOAN.dbo.loan_data_termination c
        where b.loan_no = c.loan_no

)