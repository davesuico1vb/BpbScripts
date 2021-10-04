use WEBLOAN

declare @date_end datetime='09/20/2021'								
								
select 
	   ld.bch,							
	   ld.loan_no,
	   lp.id_code,
	   ld.cat_mis_group,							
	   (select misg.description from webloan.dbo.mis_group misg							
			where misg.group_no = 0 ---mis 1 bsp classification								
			and misg.child_node = 1								
			and ld.cat_mis_group = misg.path) as mis_group_desc,								
	   lp.description as loan_product,		
	   dbo.mis_get_description_path(53,ld.cat_loan_purpose) as long_loan_pupose,
	   (select b.description 
			from webloan.dbo.loan_purpose b 
			where ld.cat_loan_purpose = b.path) as loan_purpose,
	   (select c.description 
			from webloan.dbo.mis_group c
			where c.group_no = 8 ---mis 5 account officer
			and c.child_node = 1 
			and ld.cat_mis_group5 = c.id_code) as account_officer,
	   (select ls.description
			from webloan.dbo.loan_security ls 
			where ld.cat_loan_security = ls.id_code) as loan_security,
	   (select lt.description 
			from webloan.dbo.mis_group lt
			where lt.group_no = 5 ---mis 6 loan to value (ltv)
			and lt.child_node = 1
			and ld.cat_allowance4losses = lt.path) as ltv,
		(select misg.description from webloan.dbo.mis_group misg							
			where misg.group_no = 1 ---mis 1 bsp classification								
			and misg.child_node = 1								
			and ld.cat_mis_group2 = misg.path) as agency,
		(select lai.cis_no
            from loan_acct_info lai
			where ld.bk=lai.bk
			and ld.bch=lai.bch 
			and ld.acct_no=lai.acct_no) as cis_no,
       dbo.get_name_from_loan_no(ld.loan_no) as customer_name,
	   ld.date_granted,							
	   ld.date_maturity,							
	   ld.principal,							
	   dbo.get_virtual_principal_bal(bk,bch,acct_no,ld.loan_no,@date_end) as 'bpb_prin_bal',
	   
	   isnull((select sum(isnull(ph.paid_int,0))							
		 from webloan.dbo.payment_history ph						
		 where ph.loan_no=ld.loan_no and
			   datediff(day,payment_date,@date_end)>=0),0) as 'bpbtot_int_paid',
		 
	   isnull((select sum(isnull(ph.paid_pdi,0))							
		 from webloan.dbo.payment_history ph						
		 where ph.loan_no=ld.loan_no and
			   datediff(day,payment_date,@date_end)>=0),0) as 'bpbtot_pdi_paid',

       isnull((select sum(isnull(ph.paid_penalty,0))							
		 from webloan.dbo.payment_history ph						
		 where ph.loan_no=ld.loan_no and
			   datediff(day,payment_date,@date_end)>=0),0) as 'bpbtot_pen_paid',
			   
       ld.penalty_bal as bpb_penalty_bal,
	   
	   webloan.dbo.get_first_amort_date(ld.bk,ld.bch,ld.loan_no) as first_amort_date,
	   webloan.dbo.get_first_amort_amt(ld.loan_no) as amort_amount,
	   datediff(day,ld.date_granted,ld.date_maturity) as loan_term,

	   round(datediff(day,ld.date_granted,ld.date_maturity) / (case
																when cast(ld.payment_interval as int) = 0 then datediff(day,ld.date_granted,ld.date_maturity)
																else cast(ld.payment_interval as int)
																end)
																, 0) as no_of_amort,

	   ld.granted_rate,								
	   ld.effective_rate_annum,							
	   case							
            when datediff(day,@date_end,ld.date_granted) > 0 then -1								
            when lp.pay_type=3 then datediff(day,dbo.get_last_uid(ld.loan_no,@date_end),@date_end) --- for UID ---								
  --- Daily Triggered / SavePlus StartUp -----------------------------------------------------------------------								
            when lp.auto_transfer_pastdue in (3,4) and								
                    lp.pay_type in (0,1,2)								
                    then datediff(day,dbo.get_min_amort_unpaid(ld.loan_no,@date_end),@date_end)								
  ------------------------------------------------------------------------------------------------------------								
            else datediff(day,dbo.get_min_amort_unpaid(ld.loan_no,@date_end),@date_end)								
        end as 'loan_age',
		dbo.get_loan_status_str(bk,bch,ld.loan_no,@date_end) as 'status',						
		dbo.get_virtual_air_bal(bk,bch,ld.loan_no,@date_end) as 'air',
		ld.air_bal,
		ld.ar_bal,
		dbo.get_virtual_uid_bal(bk,bch,ld.loan_no,@date_end) as 'bpb_uid_bal',	
		
		isnull((select sum(isnull(ag.total_amort,0))
		  from webloan.dbo.amort_guide ag
		  where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0),0) as total_amort_due,

		isnull((select sum(isnull(ph.paid_int,0))							
		  from webloan.dbo.payment_history ph						
		  where ph.loan_no= ld.loan_no 
		  and datediff(day,payment_date,@date_end)>=0) +
		 
		(select sum(isnull(ph.paid_principal,0))							
		  from webloan.dbo.payment_history ph						
		  where ph.loan_no= ld.loan_no
		  and datediff(day,payment_date,@date_end)>=0),0) as total_amort_paid,

		---------------------
		(isnull((select sum(isnull(ag.total_amort,0))
		  from webloan.dbo.amort_guide ag
		  where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0),0) -

		
		isnull((select sum(isnull(ph.paid_int,0))							
		  from webloan.dbo.payment_history ph						
		  where ph.loan_no= ld.loan_no 
		  and datediff(day,payment_date,@date_end)>=0) +
		 
		(select sum(isnull(ph.paid_principal,0))							
		  from webloan.dbo.payment_history ph						
		  where ph.loan_no= ld.loan_no
		  and datediff(day,payment_date,@date_end)>=0),0)) as collectible_advance,
------------------------------- 

		ld.last_compute_charge,
		(select ldi.due_amt from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as total_loan_due,
		(select ldi.due_amt_future from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as future_due_amt,
		(select ldi.due_date from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as future_due_date,
		(select ldi.penalty_amt from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as total_penalty_due,
		(select ldi.to_close from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as amt_to_close,
		(select ldi.last_principal_paid_amt from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as last_principal_paid_amt,
		(select ldi.last_principal_paid_date from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as last_principal_paid_date,
		(select ldi.last_int_paid_amt from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as last_int_paid_amt,
		(select ldi.last_int_paid_date from webloan_reports.dbo.loan_data_info ldi where ld.loan_no = ldi.loan_no) as last_int_paid_date,

---------------to know autdebit account
		case
           when dbo.get_loan_data_dynamic_boolean(ld.loan_no,'Auto Debit Advice')=1 or
                lp.auto_debit_sa_4_loan_payment=1
            then dbo.get_loan_data_dynamic_string(ld.loan_no,'Account No')
           else ''
		end as autodebit_acct,

		case 					
				when ld.creation_type = 0 then 'New Loan'				
				when ld.creation_type = 1 then 'Reloan'				
				when ld.creation_type = 2 then 'Restructured Loan'				
				when ld.creation_type = 3 then 'Continuation Loan'				
				when ld.creation_type = 4 then 'Extention Loan'				
				when ld.creation_type = 5 then 'Renewal Loan'				
			else 'Additional Loan'					
			end as creation_type
---------------to know autodebit ends
  --select top 1 * 
  from webloan.dbo.loan_data ld	
  --   where loan_no = '449444'							
    with (nolock)								
  join webloan.dbo.loan_product lp								
    with (nolock)								
    on ld.loan_product=lp.id_code								
  where --ld.bch='001'								
    --and 								
	DATEDIFF(day,date_granted,@date_end) >= 0 -- use < if releases on or after
	--and ld.loan_no in ('1000337')	
	and WEBLOAN.dbo.is_loan(ld.loan_no) = 1

	and dbo.get_loan_status(bk,bch,ld.loan_no,@date_end) <> 10
  order by ld.bch;
