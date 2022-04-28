select *
from

	(
			SELECT
			bch branch,
			user_name username,
			fullname,
			~user_disable is_enabled,
			cast(permanent_disable as date) permanent_disabled_date,
			cast(valid_until as date) expiry_date,
			group_code user_group,
			'SavePlus' system

		FROM SAVEPLUS.DBO.sp_users

	union

		select
			bch branch,
			username,
			fullname,
			enabled is_enabled,
			null permanent_disabled_date,
			null expiry_date,
			group_code user_group,
			'WebLoan' system
		from WEBLOAN.dbo.user_file

	union

		select
			bch branch,
			username,
			fullname,
			~disabled is_enabled,
			null permanent_disabled_date,
			null expiry_date,
			group_code user_group,
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