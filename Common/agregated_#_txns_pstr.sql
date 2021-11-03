-- agregated # txns starts



declare @date_start datetime= (select dateadd(day,-7,getdate()));
declare	@date_end datetime= getdate();

-------------savings accounts starts

select * from
(
--declare @date_start datetime= (select dateadd(day,-7,getdate()));
--declare	@date_end datetime= getdate();

select --top 100 
	   t.bch as branch_code,
       (select bs.bch_add
          from SAVEPLUS.dbo.branch_set bs
         where t.bk = bs.bk
           and t.bch = bs.bch) as branch_name,
       t.acct_no, 'savings' as product,
       (select a.name
          from SAVEPLUS.dbo.account a
         where t.bk = a.bk
           and t.bch = a.bch
           and t.acct_no = a.acct_no) as customername,
       count(isnull(t.amt, 0)) as transaction_count,
	   sum(isnull(t.amt, 0)) as transaction_amt
  from SAVEPLUS.dbo.trans t with(nolock)
 where datediff(day, @date_start, t.tdate) >= 0
   and datediff(day, t.tdate, @date_end) >= 0
   and t.tc not in (4, 20, 24, 40, 96, 97, 98, 99,
                    100, 101, 374, 375, 376, 377, 378, 379,
                    392, 393, 394, 396, 397, 398)
   and t.rx_now not in ('T01', 'T02', 'T03', 'T04',
						 'T05', 'T06', 'T07', 'T08',
						 'T09', 'T10', 'DYM')
 group by t.bch, t.bk, t.acct_no
   having (count(isnull(t.amt, 0)) >= 8 and sum(isnull(t.amt, 0)) < 1000000)


union all

--declare @date_start datetime= (select dateadd(day,-7,getdate()));
--declare	@date_end datetime= getdate();


select --top 100 
	   t.bch as branch_code,
       (select bs.bch_add
          from SAVEPLUS.dbo.branch_set bs
         where t.bk = bs.bk
           and t.bch = bs.bch) as branch_name,
       t.acct_no, 'time' as product,
       (select a.name
          from SAVEPLUS.dbo.account a
         where t.bk = a.bk
           and t.bch = a.bch
           and t.acct_no = a.acct_no) as customername,
       count(isnull(t.amt, 0)) as transaction_count,
	   sum(isnull(t.amt, 0)) as transaction_amt
  from SAVEPLUS.dbo.trans t with(nolock)
 where datediff(day, @date_start, t.tdate) >= 0
   and datediff(day, t.tdate, @date_end) >= 0
   and t.tc not in (4, 20, 24, 40, 96, 97, 98, 99,
                    100, 101, 374, 375, 376, 377, 378, 379,
                    392, 393, 394, 396, 397, 398)
   and t.rx_now in ('T01', 'T02', 'T03', 'T04',
						 'T05', 'T06', 'T07', 'T08',
						 'T09', 'T10', 'DYM')
 group by t.bch, t.bk, t.acct_no
   having (count(isnull(t.amt, 0)) >= 8 and sum(isnull(t.amt, 0)) <20000000)


   union all

-------------checking accounts starts

--declare @date_start datetime= (select dateadd(day,-7,getdate()));
--declare	@date_end datetime= getdate();

select --top 100 
	   t.bch as branch_code,
       (select bs.bch_add
          from SAVEPLUS.dbo.branch_set bs
         where t.bk = bs.bk
           and t.bch = bs.bch) as branch_name,
       t.acct_no, 'current' as product,
       (select a.name
          from SAVEPLUS.dbo.ca_account a
         where t.bk = a.bk
           and t.bch = a.bch
           and t.acct_no = a.acct_no) as customername,
       count(isnull(t.amt, 0)) as transaction_count,
	   sum(isnull(t.amt, 0)) as transaction_amt
  from SAVEPLUS.dbo.ca_trans t with(nolock)
 where datediff(day, @date_start, t.tdate) >= 0
   and datediff(day, t.tdate, @date_end) >= 0
   and t.tc not in (12, 20, 40,	78, 80,	87, 88,	89,
					93,	96, 96,	97, 98,	99, 100, 100,
					374, 375, 376, 377, 378, 379, 394, 396,
					397, 398)
 group by t.bch, t.bk, t.acct_no
   having (count(isnull(t.amt, 0)) >= 8 and sum(isnull(t.amt, 0)) < 1000000)
  ) as pstr			
   order by 1, 5						

--agregated # txns ends