use WEBLOAN								
								
select								
		ld.bch,						
		(select bs.bch_add from webloan.dbo.branch_set bs where ld.bch = bs.bch) as branchname,						
		(select ldsd.crd_last_modified_by from webloan.dbo.leads_data ldsd where ld.loan_no = ldsd.pre_loan_no) as crd_incharge,						
		ld.acct_no,						
		--dbo.get_mis_classification(ld.loan_no,@mis_type) as 'cat_mis_group',						
		ld.loan_no,						
		dbo.get_name_from_cis(lai.cis_no) as customername,						
		--ld.slg, -- pre loan						
		ld.principal,						
		dbo.date2str(ld.date_granted) as 'date_granted',						
		dbo.date2str(ld.date_maturity) as 'date_maturity',						
								
		ld.payment_interval,						
		ld.total_amortization,						
								
		datediff(day,ld.date_granted,ld.date_maturity) as 'loan_term',						
		--(ld.payment_interval * ld.total_amortization) + term_adj as 'loan_term',						
		case						
		  when llp.auto_recompute_stc2dea=1 then ld.granted_rate_o						
	      else ld.granted_rate							
		end as 'granted_rate',						
		ld.effective_rate_annum as eir_per_annum,						
		dbo.net_proceeed_get(ld.loan_no) as 'd_net_proceeds',						
		--ld.d_net_proceeds,						
		/*** other Charges ***/						
		'c_grt'            = isnull(ld.c_grt,0.00),						
		'c_inspection_fee' = isnull(ld.c_inspection_fee,0.00),						
		'c_sc_amt'         = isnull((select top 1 ldc2.amt + ld.c_manual_sc + ld.c_sc_amt  from webloan.dbo.loan_data_charges2 ldc2						
								where ldc2.charge_code = 'SC' and ldc2.loan_no = ld.loan_no), '0.00'),
		--isnull(ld.c_sc_amt,0.00) + isnull(ld.c_manual_sc,0.00) + ,						
								
		'c_insurance_amt'  = isnull((select top 1 ldc2.amt + ld.c_mri + ld.c_fire from webloan.dbo.loan_data_charges2 ldc2						
								where ldc2.charge_code = 'INSUR' and ldc2.loan_no = ld.loan_no), '0.00'),
		--isnull(ld.c_insurance_amt,0) + isnull(ld.c_fire,0.00),						
								
		'c_notarial_fee'   = isnull((select top 1 ldc2.amt + ld.c_notarial_fee  from webloan.dbo.loan_data_charges2 ldc2						
								where ldc2.charge_code = 'NOT' and ldc2.loan_no = ld.loan_no), '0.00'),
		--isnull(ld.c_notarial_fee,0.00),						
		'c_filling_fee'    = isnull(ld.c_filling_fee,0.00) + dbo.other_charges_get(ld.loan_no,'PF'),						
		'c_doc_stamp'      = isnull((select top 1 ldc2.amt + ld.c_doc_stamp from webloan.dbo.loan_data_charges2 ldc2						
								where ldc2.charge_code = 'DOC' and ldc2.loan_no = ld.loan_no), '0.00'),
		--isnull(ld.c_doc_stamp,0.00),						
		'c_other_charges'  = isnull(ld.c_other_charges,0.00) + dbo.other_charges_get(ld.loan_no,'IC'),						
								
		'Previous PN'=isnull(ld.c_p_loan_no,''),						
		'Previous closing amount'=isnull(ld.c_p_principal,0.00),						
		--'Prevoius Interest Amount'=isnull(ld.c_p_int,0.00),						
								
								
		/*** Co Maker ***/						
		isnull(co1.name,'') as [co1_name],						
		isnull(co2.name,'') as 'co2_name',						
		ld.creation_type,						
								
		'Creation Type' = 						
			case 					
				when ld.creation_type = 0 then 'New Loan'				
				when ld.creation_type = 1 then 'Reloan'				
				when ld.creation_type = 2 then 'Restructured Loan'				
				when ld.creation_type = 3 then 'Continuation Loan'				
				when ld.creation_type = 4 then 'Extention Loan'				
				when ld.creation_type = 5 then 'Renewal Loan'				
			else 'Additional Loan'					
			end,					
								
								
	(select top 1 (select mi.description from mis_group mi							
			where mis.pid_code = mi.path and group_no = 100)					
			from mis_group mis					
	where ld.loan_product = mis.id_code) as 'Product Group',							
								
		llp.id_code as [Loan Product],						
		llp.description as [Loan Product Description],						
		ld.cat_eco_act,						
								
		'Loan Economic Activity' = isnull((select lea.description from loan_eco_act lea						
			where lea.id_code = ld.cat_eco_act),''),					
								
								
		ld.cat_loan_security,						
								
		'Loan Security' = (select ls.description from loan_security ls						
			where ls.id_code = ld.cat_loan_security) ,					
								
		ld.cat_loan_class,						
		isnull(lc.description,'') as cat_loan_class_desc,						
		ld.cat_loan_purpose,						
		isnull(lp.description,'') as cat_loan_purpose_desc,						
								
		'cycle'=dbo.count_loan_data(ld.bk,ld.bch,ld.acct_no,ld.loan_no),						
		'first_amort'=dbo.get_first_amort_date(ld.bk,ld.bch,ld.loan_no),						
		'orig_int'=ld.orig_int,						
		c_pledge_sa_open,						
		ld.date_granted,						
		'sex'=isnull(cs.p_gender,1), /* 1 male 2 female */						
		ld.d_advance_int,						
		ld.cat_debt_instrument,						
								
		'Debt Intrumant' = (select mg.description from mis_group mg						
			where mg.group_no = 3 and mg.path = ld.cat_debt_instrument) ,					
								
		ld.cat_loan_industry,						
								
		'Loan Industry' = (select mg.description from mis_group mg						
			where mg.group_no = 4 and mg.path = ld.cat_loan_industry) ,					
								
								
		ld.cat_allowance4losses,						
		lai.dosri_status,						
		lai.loan_firm_size,						
								
		'Firm Size' = (select fs.description from loan_firm_size fs						
			where fs.id_code = lai.loan_firm_size) ,					
								
		lai.borrower_type,						
								
		'Borrower Type' = (select bt.description from borrower_type bt						
			where bt.path = lai.borrower_type) ,					
								
		lai.kiosk,						
		ld.bullet_amort,						
        ld.discounted,								
		ld.c_processing_fee						
   from loan_data ld								
	join loan_product llp 							
	  with (nolock)							
	  on ld.loan_product=llp.id_code							
								
	join loan_acct_info lai 							
	  with (nolock)							
	  on ld.bk=lai.bk and							
		 ld.bch=lai.bch and						
		 ld.acct_no=lai.acct_no						
								
	left outer join loan_class lc 							
	   with (nolock)							
	   on ld.cat_loan_class=lc.path							
								
	left outer join loan_purpose lp 							
	   with (nolock)							
	   on ld.cat_loan_purpose=lp.path							
								
	join cis_info cs 							
	   with (nolock)							
	   on lai.cis_no=cs.cis_no							
								
	---- optional join ----							
	left outer join co_maker co1 							
	   with (nolock)							
	   on ld.co_maker1=co1.id_code							
								
	left outer join co_maker co2 							
	   with (nolock)							
	   on ld.co_maker2=co2.id_code							
	where ld.date_granted = '09/14/2021' and webloan.dbo.is_loan(ld.loan_no) = 1							
	order by 3, 1;							
