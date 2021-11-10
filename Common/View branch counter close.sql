select 

l.bch BranchId,
(
select a.bch_add from SAVEPLUS.dbo.branch_set a

where a.bch = l.bch

) Branchname,
cast(l.ldatetime as date) CutOff,

(

select max(ldatetime)  from dbo.logbook a

where a.bch = l.bch

and cast(a.ldatetime as date) = cast(l.ldatetime as date)

and charindex('Counter closing initiated.',description) > 0

group by cast(ldatetime as date)

) ClosingDateTime

from SAVEPLUS.dbo.logbook l

where charindex('Counter closing initiated.',l.description) > 0



and cast(l.ldatetime as date) between '2021-10-01' and '2021-10-31'

group by l.bch, cast(l.ldatetime as date)

order by cast(l.ldatetime as date) desc,l.bch;


