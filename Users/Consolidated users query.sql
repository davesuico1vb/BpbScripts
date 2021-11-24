select * from 

(
SELECT 
	bch branch,
	user_name username,
	fullname,
	'SavePlus' system
 
FROM SAVEPLUS.DBO.sp_users

union

select
	bch branch,
	username,
	fullname,
	'WebLoan' system
from WEBLOAN.dbo.user_file

union

select 
bch branch,
username,
fullname,
'GlNet' type

from glnet_server.glnet.dbo.user_file

) b

where b.fullname not in (
'Default Cashier',
'Default Manager',
'Default Teller',
'System',
'Start-Up',
'S, Sy Y',
'S, Y S',
','
)

and b.fullname not like  '%SYS%'

and b.fullname not like  '%BCH%'


order by b.fullname