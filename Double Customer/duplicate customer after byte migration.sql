
select 
LOWER(REPLACE(concat(x.fname,x.mname,x.lname,x.p_bday),' ','')) CustomerNameHash,

x.cis_no,
x.bch,
(select y.bch_add from WEBLOAN.dbo.branch_set y where x.bch = y.bch) branch_name,
x.fname,
LEN(x.fname) fnamelen,
x.mname,
LEN(x.mname) mnamelen,
x.lname,
LEN(x.lname) lnamelen,
x.p_bday,
x.cis_cleared,
x.cis_cleared_date,

x.date_of_creation,

(
	select count(*) from (
		select bch,acct_no,close_date from SAVEPLUS.dbo.account

		union

		select bch,acct_no,close_date from SAVEPLUS.dbo.ca_account
	) y where exists(
	
		select 1 from WEBLOAN.dbo.cis_lookup yy
		where y.acct_no = yy.acct_no
		and y.bch = yy.bch
		and yy.cis_no = x.cis_no
		and y.close_date is null
	)

) ActiveDepositCounts,

(

select count(*) from
	WEBLOAN.dbo.loan_data yy
	where exists(
		select lai.cis_no
        from webloan.dbo.loan_acct_info lai
        where yy.bk=lai.bk
            and yy.bch=lai.bch
            and yy.acct_no=lai.acct_no
			and lai.cis_no = x.cis_no
	)
	and close_date is null

) ActiveOpenLoans

from 

WEBLOAN.dbo.cis_info x


where exists (
select * from (select

b.CustomerNameHash

from

(
select 

LOWER(REPLACE(concat(a.fname,a.mname,a.lname,a.p_bday),' ','')) CustomerNameHash


from WEBLOAN.dbo.cis_info a

) b group by b.CustomerNameHash having count(b.CustomerNameHash) > 1) y

where LOWER(REPLACE(concat(x.fname,x.mname,x.lname,x.p_bday),' ',''))  = y.CustomerNameHash

)


and  x.date_of_creation >='2021-09-13'

order by  LOWER(REPLACE(concat(x.fname,x.mname,x.lname,x.p_bday),' ','')), date_of_creation desc


