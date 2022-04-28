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
        order by b.close_date) close_date
    from WEBLOAN.dbo.loan_data_termination a
    where exists(
select 1
    from WEBLOAN.dbo.loan_data b
    where a.loan_no = b.loan_no and cast(a.termination_date as date) != cast(b.close_date as date)
)

)z
order by z.termination_date desc