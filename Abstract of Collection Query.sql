--------Abstract of Collection Query


use WEBLOAN

select 
		ph.bch,
		(select bs.bch_add from WEBLOAN.dbo.branch_set bs where ph.bch = bs.bch) as branchname,
		
		ld.loan_no,
		
		(select lai.cis_no
            from webloan.dbo.loan_acct_info lai
			where ld.bk=lai.bk
			and ld.bch=lai.bch 
			and ld.acct_no=lai.acct_no) as cis_no,
	   'Name' = webloan.dbo.get_name_from_cis(lai.cis_no),
					   
	   --ld.cat_mis_group,
	   --isnull((select x.description from webloan.dbo.mis_group x with (nolock)where x.group_no=0 and x.path=ld.cat_mis_group),'') as 'cat_mis_group_desc',
	   
	   --ld.cat_mis_group2,
	   --isnull((select x.description from webloan.dbo.mis_group x with (nolock) where x.group_no=1 and x.path=ld.cat_mis_group2),'') as 'cat_mis_group2_desc',

	   --ld.cat_mis_group3,
	   --isnull((select x.description from webloan.dbo.mis_group x with (nolock)where x.group_no=6 and x.path=ld.cat_mis_group3),'') as 'cat_mis_group3_desc',
	  
	   --ld.cat_mis_group4,
	   --isnull((select x.description from webloan.dbo.mis_group x with (nolock) where x.group_no=7 and x.path=ld.cat_mis_group4),'') as 'cat_mis_group4_desc',
	   
	   --ld.cat_mis_group5,
	   --isnull((select x.description from webloan.dbo.mis_group x with (nolock) where x.group_no=8 and x.path=ld.cat_mis_group5),'') as 'cat_mis_group5_desc',

 
	--(select top 1 (select mi.description from webloan.dbo.mis_group mi
	--		where mis.pid_code = mi.path and group_no = 100)
	--		from webloan.dbo.mis_group mis
	--where ld.loan_product = mis.id_code) as 'Product Group',

	--	lp.id_code as [Loan Product],
		lp.description as [Loan Product Description],

    webloan.dbo.date2str(ph.payment_date) as payment_date,
     ph.payment_ref,
    --'amort_covered_from'=isnull(ph.amort_covered_from,0),
	--'amort_covered_to'=isnull(ph.amort_covered_to,0),
    'p_covered_from'=webloan.dbo.date2str(isnull(ph.period_covered_from,ld.date_granted)),
	'p_covered_to'=webloan.dbo.date2str(isnull(ph.period_covered_to,ld.date_granted)),
    ph.paid_principal,
    'paid_int'=(ph.paid_int - ph.air_reversal),
	ph.paid_pdi,ph.paid_uid,ph.paid_sc,
	ph.paid_vat,
    ph.paid_penalty,
    ph.paid_over,
	ph.paid_sa,
	ph.paid_mutual,
	ph.paid_com,
    ph.paid_total,
    ph.total_amount_due,
    ph.rebate_amt,
    ph.interest_due,
    ph.penalty_tot,
    ph.waive_amt,

	--lp.pay_type,
	'Loan Product Computation Type' =  
	case	
		when lp.pay_type = 0 then 'Simple'
		when lp.pay_type = 1 then 'Compunded'
		when lp.pay_type = 2 then 'As Earned'
	else 'Advance Interest'
	end,

	--ld.cat_loan_security,
	'Loan Security' = (select ls.description from webloan.dbo.loan_security ls
		where ls.id_code = ld.cat_loan_security), 


	--ph.loan_status,
	CASE 
	WHEN ld.loan_status = 0 THEN 'Current'
	WHEN ld.loan_status = 1 THEN 'Past Due Performing'
	WHEN ld.loan_status = 2 THEN 'Past Due Non Performing'
	WHEN ld.loan_status = 3 THEN 'Litigation'
	WHEN ld.loan_status = 4 THEN 'Transfer Asset'
	WHEN ld.loan_status = 5 THEN 'Write Off'
    ELSE 'Closed'
    END AS [Loan Status Description],

	ph.ar,
	ph.sandry,
	
	--ph.payment_type, /** 0-cash 1-check 2-Adjustment **/
	'Payment Type Description' = 
	case 
		when ph.payment_type = 0 then 'Cash'
		when ph.payment_type = 1 then 'Check'
		when ph.payment_type = 1 then 'Adjustment'
		when ph.payment_type = 3 then 'Returned Check'
	else 'MEMO'
	end,
		
	--ld.cat_loan_class,
	--isnull(lc.description,'') as cat_loan_class_desc,
	
	--ld.cat_loan_purpose,
	isnull(lps.description,'') as cat_loan_purpose_desc,
	
	'loan_term'=datediff(day,ld.date_granted,ld.date_maturity),
	'dosri'=lai.dosri_status,
	
	ph.principal_bal,
	ph.air_reversal,
	lai.kiosk,
	ld.bullet_amort,
	ld.discounted

  from webloan.dbo.payment_history ph
    with (nolock)

  join webloan.dbo.loan_data ld 
    with (nolock)
    on ld.loan_no = ph.loan_no

  left join webloan.dbo.loan_acct_info lai 
    with (nolock)
    on ld.bk = lai.bk and
	   ld.bch = lai.bch and 
	   ld.acct_no = lai.acct_no

  left join webloan.dbo.loan_product lp 
    with (nolock)
    on ld.loan_product = lp.id_code

	left outer join webloan.dbo.loan_class lc 
	   with (nolock)
	   on ld.cat_loan_class=lc.path

	left outer join webloan.dbo.loan_purpose lps 
	   with (nolock)
	   on ld.cat_loan_purpose=lps.path

	left outer join webloan.dbo.mis_group mis
	   with (nolock)
	   on ld.cat_mis_group=mis.path

  where 
        datediff(day,'09/13/2021',ph.payment_date) >= 0 
	and datediff(day,ph.payment_date,'09/15/2021') >= 0 
	and	webloan.dbo.is_loan(ph.loan_no)=1
	--and posted_by='sys001' 

order by ph.bch

