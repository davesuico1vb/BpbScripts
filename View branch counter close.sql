select 
l.bch branchId,
(select z.bch_add  from dbo.branch_set z where l.bch = z.bch) branchName,
max(l.ldatetime) as closingDateAndTime

from saveplus.dbo.logbook l
with (nolock)
where --bk='190' and
--bch='002' and
datediff(day,l.ldatetime,'09/13/2021')=0
--and action_no=1204
and charindex('Counter closing initiated.',description) > 0
group by l.bch
order by l.bch
