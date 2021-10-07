declare @date_end datetime= @Date

            
            select
                z.*,

                CASE
                WHEN z.LoanAge = 0	 			THEN 'A. CURRENT' 
                WHEN LoanAge > 0 AND LoanAge <= 30	THEN 'B. 1 TO 30'
                WHEN LoanAge > 30 AND LoanAge <= 60	THEN 'C. 31 TO 60'
                WHEN LoanAge > 60 AND LoanAge <= 90	THEN 'D. 61 TO 90'
                WHEN LoanAge > 90 AND LoanAge <= 180	THEN 'E. 91 TO 180'
                WHEN LoanAge > 180 AND LoanAge <= 360	THEN 'F. 181 TO 360'
                WHEN LoanAge > 360 AND LoanAge <= 720	THEN 'G. 361 TO 720'
                WHEN LoanAge > 720				THEN 'H. 721 & UP'
                END as LoanAgeDescription

            from (

                                            select
                    ld.bch BranchId,
                    (select z.bch_add
                    from WEBLOAN.dbo.branch_set z
                    where ld.bch = z.bch)as BranchName,
                    ld.loan_no AgreementId,
                    lp.id_code SchemeId,
                    ld.cat_mis_group CatMisGroup,
                    (select misg.description
                    from webloan.dbo.mis_group misg
                    where misg.group_no = 0 ---mis 1 bsp classification								
                        and misg.child_node = 1
                        and ld.cat_mis_group = misg.path) as SchemeName,
                    lp.description as LoanProduct,
                    dbo.mis_get_description_path(53,ld.cat_loan_purpose) as LoanPurposeFullDescription,
                    (select b.description
                    from webloan.dbo.loan_purpose b
                    where ld.cat_loan_purpose = b.path) as LoanPurpose,
                    (select c.description
                    from webloan.dbo.mis_group c
                    where c.group_no = 8 ---mis 5 account officer
                        and c.child_node = 1
                        and ld.cat_mis_group5 = c.id_code) as AccountOfficer,
                    (select ls.description
                    from webloan.dbo.loan_security ls
                    where ld.cat_loan_security = ls.id_code) as LoanSecurity,
                    (select lt.description
                    from webloan.dbo.mis_group lt
                    where lt.group_no = 5 ---mis 6 loan to value (ltv)
                        and lt.child_node = 1
                        and ld.cat_allowance4losses = lt.path) as Ltv,
                    (select misg.description
                    from webloan.dbo.mis_group misg
                    where misg.group_no = 1 ---mis 1 bsp classification								
                        and misg.child_node = 1
                        and ld.cat_mis_group2 = misg.path) as Agency,
                    (select lai.cis_no
                    from loan_acct_info lai
                    where ld.bk=lai.bk
                        and ld.bch=lai.bch
                        and ld.acct_no=lai.acct_no) as CustomerId,
                    dbo.get_name_from_loan_no(ld.loan_no) as CustomerName,
                    (select h_sadd
                    from WEBLOAN.dbo.cis_info z
                    where z.cis_no = (select lai.cis_no
                    from loan_acct_info lai
                    where ld.bk=lai.bk
                        and ld.bch=lai.bch
                        and ld.acct_no=lai.acct_no))CustomerAddress,
                    ld.date_granted DateGranted,
                    convert(varchar,ld.date_maturity,101) MaturityDate,
                    ld.principal Principal,
                    dbo.get_virtual_principal_bal(bk,bch,acct_no,ld.loan_no,@date_end) as BytePrincipalBalance,

                    isnull((select sum(isnull(ag.int_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no ),0) as TotalInterest,

                    isnull((select sum(isnull(ag.int_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no ) -
                                                                
                                                    (select sum(isnull(ph.paid_int,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no=ld.loan_no and
                        datediff(day,payment_date,@date_end)>=0),0) as TotalInterestBalance,

                    isnull((select sum(isnull(ph.paid_pdi,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no=ld.loan_no and
                        datediff(day,payment_date,@date_end)>=0),0) as ByteTotalPastDueInterestPaid,

                    isnull((select sum(isnull(ph.paid_penalty,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no=ld.loan_no and
                        datediff(day,payment_date,@date_end)>=0),0) as ByteTotalPenaltyPaid,

                    ld.penalty_bal as BytePenaltyBalance,
                    webloan.dbo.get_first_amort_date(ld.bk,ld.bch,ld.loan_no) as  firstamortdate,
                    webloan.dbo.get_first_amort_amt(ld.loan_no) as amortamount,
                    datediff(day,ld.date_granted,ld.date_maturity) as loanterm,

                    isnull((select max(z.amort_no)
                    from webloan.dbo.amort_guide z
                    where z.loan_no = ld.loan_no),1) as numberofamort,
                    ld.granted_rate GrantedRate,
                    ld.effective_rate_annum EffectiveRatePerAnnum,
                    case							
                    when datediff(day,@date_end,ld.date_granted) > 0 then -1								
                    when lp.pay_type=3 then datediff(day,dbo.get_last_uid(ld.loan_no,@date_end),@date_end) --- for UID ---								
                    --- Daily Triggered / SavePlus StartUp -----------------------------------------------------------------------								
                    when lp.auto_transfer_pastdue in (3,4) and lp.pay_type in (0,1,2)								
                    then datediff(day,dbo.get_min_amort_unpaid(ld.loan_no,@date_end),@date_end)								
                    ------------------------------------------------------------------------------------------------------------								
                    else datediff(day,dbo.get_min_amort_unpaid(ld.loan_no,@date_end),@date_end)								
                    end as LoanAge,
                    dbo.get_loan_status_str(bk,bch,ld.loan_no,@date_end) as Status,
                    dbo.get_virtual_air_bal(bk,bch,ld.loan_no,@date_end) as AccruedInterestReceivable,
                    ld.air_bal AccruedInterestReceivableBalance,
                    ld.ar_bal ArBalance,
                    dbo.get_virtual_uid_bal(bk,bch,ld.loan_no,@date_end) as ByteUidBalance,

                    isnull((select sum(isnull(ag.principal_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0),0) as TotalPrincipalDue,

                    isnull((select sum(isnull(ag.int_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0),0) as TotalInterestDue,

                    isnull((select sum(isnull(ag.total_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0),0) as TotalAmortDue,

                    isnull((select sum(isnull(ph.paid_int,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no= ld.loan_no
                        and datediff(day,payment_date,@date_end)>=0),0) as TotalInterestReceived,

                    isnull((select sum(isnull(ph.paid_principal,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no= ld.loan_no
                        and datediff(day,payment_date,@date_end)>=0),0) as TotalPrincipalReceived,

                    isnull((select sum(isnull(ph.paid_int,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no= ld.loan_no
                        and datediff(day,payment_date,@date_end)>=0) +
                                                                        
                        (select sum(isnull(ph.paid_principal,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no= ld.loan_no
                        and datediff(day,payment_date,@date_end)>=0),0) as TotalAmortPaid,

                    isnull((select sum(isnull(ag.principal_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0) -

                    (select sum(isnull(ph.paid_principal,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no= ld.loan_no
                        and datediff(day,payment_date,@date_end)>=0),0) as TotalPrincipalOverdue,
                    ---------------------

                    isnull((select sum(isnull(ag.int_amort,0))
                    from webloan.dbo.amort_guide ag
                    where ag.loan_no = ld.loan_no and datediff(day,amort_date,@date_end)>=0) -

                    (select sum(isnull(ph.paid_int,0))
                    from webloan.dbo.payment_history ph
                    where ph.loan_no= ld.loan_no
                        and datediff(day,payment_date,@date_end)>=0),0) as TotalInterestOverdue,

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
                        and datediff(day,payment_date,@date_end)>=0),0)) as CollectibleAdvance,
                    ------------------------------- 

                    ld.last_compute_charge LastComputedChargeDate,
                    (select ldi.due_amt
                    from webloan_reports.dbo.loan_data_info ldi
                    where ld.loan_no = ldi.loan_no) as TotalLoanDue,
                    (select ldi.due_amt_future
                    from webloan_reports.dbo.loan_data_info ldi
                    where ld.loan_no = ldi.loan_no) as FutureDueAmount,
                    (select ldi.due_date
                    from webloan_reports.dbo.loan_data_info ldi
                    where ld.loan_no = ldi.loan_no) as FutureDueDate,
                    (select ldi.penalty_amt
                    from webloan_reports.dbo.loan_data_info ldi
                    where ld.loan_no = ldi.loan_no) as TotalPenaltyDue,
                    (select ldi.to_close
                    from webloan_reports.dbo.loan_data_info ldi
                    where ld.loan_no = ldi.loan_no) as AmountToClose,

                    (select top 1
                        ph.payment_date
                    from webloan.dbo.payment_history ph
                    where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                        and ph.paid_total > 0 and DATEDIFF(day,ph.payment_date,@date_end) >= 0
                    order by ph.payment_date desc) LatestTotalPaymentReceivedDate,

                    (select top 1
                        ph.paid_total
                    from webloan.dbo.payment_history ph
                    where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                        and ph.paid_total > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                    order by ph.payment_date desc) LatestTotalPaymentReceivedAmount,

                    (select top 1
                        ph.payment_date
                    from webloan.dbo.payment_history ph
                    where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                        and ph.paid_principal > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                    order by ph.payment_date desc) LatestPrincipalPaidDate,

                    (select top 1
                        ph.paid_principal
                    from webloan.dbo.payment_history ph
                    where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                        and ph.paid_principal > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                    order by ph.payment_date desc)LatestPrincipalPaidAmount,

                    (select top 1
                        int.payment_date
                    from
                        (                                                select ph.payment_date, ph.paid_pdi as int_paid
                            from webloan.dbo.payment_history ph
                            where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                                and ph.paid_pdi > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                        union all
                            select ph.payment_date, ph.paid_int as int_paid
                            from webloan.dbo.payment_history ph
                            where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                                and ph.paid_int > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                        ) as int
                    order by int.payment_date desc) LatestInterestPaidDate,


                    (select top 1
                        int.int_paid
                    from
                        (                                select ph.payment_date, ph.paid_pdi as int_paid
                            from webloan.dbo.payment_history ph
                            where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                                and ph.paid_pdi > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                        union all
                            select ph.payment_date, ph.paid_int as int_paid
                            from webloan.dbo.payment_history ph
                            where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                                and ph.paid_int > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                        ) as int
                    order by int.payment_date desc) LatestInterestPaidAmount,


                    (select top 1
                        ph.payment_date
                    from webloan.dbo.payment_history ph
                    where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                        and ph.paid_penalty > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                    order by ph.payment_date desc ) LatestPenaltyPaidDate,

                    (select top 1
                        ph.paid_penalty
                    from webloan.dbo.payment_history ph
                    where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                        and ph.paid_penalty > 0 and DATEDIFF(day,payment_date,@date_end) >= 0
                    order by ph.payment_date desc ) LatestPenaltyPaidAmount,



                    case
                        when dbo.get_loan_data_dynamic_boolean(ld.loan_no,'Auto Debit Advice')=1 or
                        lp.auto_debit_sa_4_loan_payment=1
                        then dbo.get_loan_data_dynamic_string(ld.loan_no,'Account No')
                    else ''
                    end as AutoDebitAccount,
                    case 					
                        when ld.creation_type = 0 then 'New Loan'				
                        when ld.creation_type = 1 then 'Reloan'				
                        when ld.creation_type = 2 then 'Restructured Loan'				
                        when ld.creation_type = 3 then 'Continuation Loan'				
                        when ld.creation_type = 4 then 'Extention Loan'				
                        when ld.creation_type = 5 then 'Renewal Loan'				
                    else 'Additional Loan'					
                    end as CreationType,

                    isnull((select ldi.pdi
                    from webloan_reports.dbo.loan_data_info ldi
                    where ld.loan_no = ldi.loan_no),0) as PastDueInterestBalance,

                    (select top 1
                        opm.old_product_type
                    from READONLY.dbo.old_product_mapping opm
                    where ld.loan_product = opm.schemeidbyte) as OldLoanProduct,

                    (select c.description
                        from webloan.dbo.mis_group c
                        where c.group_no = 4 ---mis 4 loan purpose to industry
                        and c.child_node = 1 
                        and ld.cat_loan_industry = c.id_code) as LoanPurposeToIndustry

                from webloan.dbo.loan_data ld	
                                                                    with (nolock)
                    join webloan.dbo.loan_product lp								
                                                                    with (nolock)
                    on ld.loan_product=lp.id_code
                where ld.bch=isnull(@BranchId,ld.bch)
                    and
                    DATEDIFF(day,date_granted,@date_end) >= 0 -- use < if releases on or after
                    and WEBLOAN.dbo.is_loan(ld.loan_no) = 1

                    and webloan.dbo.get_loan_status(ld.bk,ld.bch,ld.loan_no,@date_end) != 10

                    and not exists (select 1
                    from READONLY.dbo.loan_listing_exclusions a
                    where ld.loan_no = a.loan_no)
                                        ) z

            order by z.BranchId