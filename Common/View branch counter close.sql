  
select

    l.bch BranchId,
    (
select a.bch_add
    from SAVEPLUS.dbo.branch_set a

    where a.bch = l.bch

) Branchname,
    cast(l.ldatetime as date) CutOff,

    (

select max(ldatetime)
    from saveplus.dbo.logbook a

    where a.bch = l.bch

        and cast(a.ldatetime as date) = cast(l.ldatetime as date)

        and charindex('Counter closing initiated.',description) > 0

    group by cast(ldatetime as date)

) ClosingDateTime,

(
select isnull(sum(a.cr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'OVERT'
	and a.cr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) Overage,

(
select isnull(count(a.cr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'OVERT'
	and a.cr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) OverageCount,

(
select isnull(sum(a.dr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'OVERT'
	and a.dr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) OverageClaim,
(
select isnull(count(a.dr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'OVERT'
	and a.dr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) OverageClaimCount,

(
select isnull(sum(a.dr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'ARSHORT'
	and a.dr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) Shortage,

(
select isnull(count(a.dr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'ARSHORT'
	and a.dr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) ShortageCount,

(
select isnull(sum(a.cr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'ARSHORT'
	and a.cr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) SettledShortage,
(
select isnull(count(a.cr_amt),0)
	   
  from glnet_server.glnet.dbo.tk a
    where a.id_code = 'ARSHORT'
	and a.cr_amt >0
	and cast(a.tk_date as date) = cast(l.ldatetime as date)
	and a.u_bch = l.bch

) SettledShortageCount


from SAVEPLUS.dbo.logbook l

where charindex('Counter closing initiated.',l.description) > 0

and cast(l.ldatetime as date) between '2021-10-01' and  '2021-10-01'

group by l.bch, cast(l.ldatetime as date)

order by cast(l.ldatetime as date) desc,l.bch;
