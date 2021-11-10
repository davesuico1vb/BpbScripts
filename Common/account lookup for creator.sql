select *
  from webloan.dbo.cis_log
  where cis_no in ( select cl.cis_no
					from webloan.dbo.cis_lookup cl
					where cl.bch + '-' + cl.acct_no in (select act.bch + '-' + act.acct_no
														from saveplus.dbo.account act
														where cast(act.open_date as date) >= '10/01/2021')
														)
					and remarks like '%New account initiated. acct_no:%'
  order by tdate desc
