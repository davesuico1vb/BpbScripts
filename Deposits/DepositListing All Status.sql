------Deposit Listing

declare @date_end datetime='09/14/2021'	

select --top 100
	   a.bch, 
       bs.bch_add as branchname, 
	   a.acct_no, 
	   l.cis_no,
	   a.name,
	   a.add2,
	   a.rxclass as bytescheme,
	   
	   (select top 1 b.schemeid 
	      from MIGRATION.dbo.product_table b 
		  where a.rxclass = b.what_class) as f1_schemeid, 

	   dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,1) as 'ebal1',
	   dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,2) as 'ebal2',
	   dbo.get_virtual_last_trans(a.bk,a.bch,a.acct_no,@date_end) as 'last_trans',
	   
	   a.open_date, 
	   a.special_rt, 
	   a.maturity, 

	   case 
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 1 then 'active'
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 2 then 'inactive'
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 3 then 'dormant'
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 4 then 'closed'
	     else 'not found'
	   end as status

  from saveplus.dbo.account a	---all regular and time deposits
    with (nolock)
  join WEBLOAN.dbo.cis_lookup l
    with (nolock)	
    on a.bk=l.bk and	
       a.bch=l.bch and	
       a.acct_no=l.acct_no
  join SAVEPLUS.dbo.branch_set bs
    with (nolock)
	on a.bk=bs.bk and
	   a.bch=bs.bch
  where open_date < @date_end and
		 (
		    close_date is null or
		   (close_date is not null and close_date > @date_end)
		 )
union all	
	
	
select --top 100
	   a.bch, 
       bs.bch_add as branchname, 
	   a.acct_no, 
	   l.cis_no,
	   a.name,
	   a.add2,
	   a.caclass as bytescheme,
	   
	   (select top 1 b.schemeid 
	      from MIGRATION.dbo.product_table b 
		  where a.caclass = b.what_class) as f1_schemeid, 

	   dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,1) as 'ebal1',
	   dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,2) as 'ebal2',
	   dbo.get_virtual_last_trans(a.bk,a.bch,a.acct_no,@date_end) as 'last_trans',
	   
	   a.open_date, 
	   0.0 as 'special_rt', 
	   null as 'maturity', 

	   case 
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 1 then 'active'
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 2 then 'inactive'
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 3 then 'dormant'
	     when dbo.acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 4 then 'closed'
	     else 'not found'
	   end as status

  from saveplus.dbo.ca_account a	---all regular and time deposits
    with (nolock)
  join WEBLOAN.dbo.cis_lookup l
    with (nolock)	
    on a.bk=l.bk and	
       a.bch=l.bch and	
       a.acct_no=l.acct_no
  join SAVEPLUS.dbo.branch_set bs
    with (nolock)
	on a.bk=bs.bk and
	   a.bch=bs.bch
  where open_date < @date_end and
		 (
		    close_date is null or
		   (close_date is not null and close_date > @date_end)
		 )

-----------------------


/** 
select *
  from SAVEPLUS.dbo.trans
  where bch = '016'and acct_no = '54-00001-5'
  order by tdate desc


select acct_no, add2 as accoutid, ebal1 as available_balance
  from SAVEPLUS.dbo.account
  where add2 = '116260000015'

**/
