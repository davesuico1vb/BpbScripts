
select --top 10
	a.bch,
	a.rxclass,
	a.bch + '-' + a.acct_no as 'accountid',
	dbo.get_int_rate(a.bk,a.bch,a.acct_no) as 'rate',
	(select top 1
		cis_no
	from WEBLOAN.dbo.cis_lookup l
	where l.bk=a.bk and
		l.bch=a.bch and
		l.acct_no=a.acct_no) as 'cis_no',
	trim(a.name) + trim(a.and_or) as 'acct_name',
	a.value_date as 'value_date',
	a.close_date,
	a.open_date,
	a.maturity,
	a.term,
	a.ebal2 as 'placement',
	cast(a.ebal2 + ((a.ebal2 * (dbo.get_int_rate(a.bk,a.bch,a.acct_no) * 0.01) *  a.term) / (r.rxdayinyr  * 1.0000)) as numeric(18,2)) as 'maturity_value'
from account a
	join rx_rate r
	on a.bk=r.bk and
		a.bch=r.bch and
		a.rxclass=r.rxclass
where r.rx_intmode=5 /* TD / SSA */
	--and a.bch = '022' and acct_no = '31-00911-3'

	and cast(a.value_date as date) between '2022-04-01' and '2022-04-30'
	and close_date is null