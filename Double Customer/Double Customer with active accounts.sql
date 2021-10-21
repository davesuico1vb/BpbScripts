select *
from CustomerHashWithActiveAccounts z


where exists(
select
    1

from (

select b.CustomerNameHash


    from


        (select

            a.CustomerId,
            a.CustomerNameHash

        from dbo.CustomerHashWithActiveAccounts a
        group by a.CustomerId,a.CustomerNameHash) b

    group by b.CustomerNameHash
    having count(b.CustomerNameHash) > 1) c

where z.CustomerNameHash = c.CustomerNameHash

)

order by z.CustomerNameHash


