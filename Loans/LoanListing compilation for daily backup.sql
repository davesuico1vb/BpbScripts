USE [READONLY]
GO
/****** Object:  StoredProcedure [dbo].[GET_LOAN_LISTING]    Script Date: 3/23/2022 1:30:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[GET_LOAN_LISTING]
    @toDate DateTime = null

as 

	
if @toDate is null 
	set @toDate = getdate()

            select
    @toDate as CutOffDate,
    GETDATE() as BackUpDate,
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
                END as Aging
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
        webloan.dbo.mis_get_description_path(53,ld.cat_loan_purpose) as LoanPurposeFullDescription,
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
        from webloan.dbo.loan_acct_info lai
        where ld.bk=lai.bk
            and ld.bch=lai.bch
            and ld.acct_no=lai.acct_no) as CustomerId,
        (select top 1
            cin.lname + ', ' + cin.fname + ' ' + cin.mname
        from webloan.dbo.cis_info cin
        where cin.cis_no =
		  (select lai.cis_no
        from webloan.dbo.loan_acct_info lai
        where ld.bk=lai.bk
            and ld.bch=lai.bch
            and ld.acct_no=lai.acct_no))  as CustomerName,
        (select trim(upper(replace(replace(replace(replace(isnull(z.h_sadd, ''),
                                             isnull(z.h_village, ''),
                                             ''),
                                     isnull(z.h_barangay, ''),
                                     ''),
                             trim(replace(isnull(z.h_city, ''), '(CAPITAL)', '')),
                             ''),
                     isnull(z.h_state_prov, ''),
                     '') + ' ' +
             replace(replace(replace(isnull(z.h_village, ''),
                                     isnull(z.h_barangay, ''),
                                     ''),
                             isnull(z.h_city, ''),
                             ''),
                     isnull(z.h_state_prov, ''),
                     '') + ' ' + isnull(z.h_barangay, ''))
	 + ' ' + 
	 upper(trim(replace(isnull(z.h_city, ''), '(CAPITAL)', '')) + ' ' + isnull(z.h_state_prov, ''))) Address
        from WEBLOAN.dbo.cis_info z
        where z.cis_no = (select lai.cis_no
        from webloan.dbo.loan_acct_info lai
        where ld.bk=lai.bk
            and ld.bch=lai.bch
            and ld.acct_no=lai.acct_no))CustomerAddress,
        ld.date_granted DateGranted,
        convert(varchar,ld.date_maturity,101) MaturityDate,
        ld.principal Principal,
        webloan.dbo.get_virtual_principal_bal(bk,bch,acct_no,ld.loan_no,@toDate) as BytePrincipalBalance,

        isnull((select
            sum(ag.int_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no), (select sum(ag.int_amort)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no))TotalInterest,

        (isnull((select sum(ag.int_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no), (select sum(ag.int_amort)
        from WEBLOAN.dbo.amort_data ag
        where ag.loan_no = ld.loan_no) ) 
		- 
		(select isnull(sum(ph.paid_int),0)
        from webloan.dbo.payment_history ph
        where ph.loan_no=ld.loan_no and
            cast(payment_date as date) <= @toDate))  TotalInterestBalance,

        isnull((select sum(isnull(ph.paid_pdi,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no=ld.loan_no and
            datediff(day,payment_date,@toDate)>=0),0) as ByteTotalPastDueInterestPaid,

        isnull((select sum(isnull(ph.paid_penalty,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no=ld.loan_no and
            datediff(day,payment_date,@toDate)>=0),0) as ByteTotalPenaltyPaid,

        ld.penalty_bal as BytePenaltyBalance,
        webloan.dbo.get_first_amort_date(ld.bk,ld.bch,ld.loan_no) as  firstamortdate,
        webloan.dbo.get_first_amort_amt(ld.loan_no) as amortamount,
        datediff(day,ld.date_granted,ld.date_maturity) as loanterm,

        isnull((select max(z.amort_no)
        from webloan.dbo.amort_guide z
        where z.loan_no = ld.loan_no),
		(select max(amort_no)
        from WEBLOAN.dbo.amort_data
        where loan_no=ld.loan_no)) as numberofamort,

        ld.granted_rate GrantedRate,
        ld.effective_rate_annum EffectiveRatePerAnnum,

        READONLY.dbo.GetLoanAge(ld.loan_no,@toDate,ld.date_granted,lp.id_code,lp.pay_type,lp.auto_transfer_pastdue) as LoanAge,

        webloan.dbo.get_loan_status_str(bk,bch,ld.loan_no,@toDate) as Status,
        webloan.dbo.get_virtual_air_bal(bk,bch,ld.loan_no,@toDate) as 
        AccruedInterestReceivable,
        ld.air_bal AccruedInterestReceivableBalance,
        ld.ar_bal ArBalance,
        webloan.dbo.get_virtual_uid_bal(bk,bch,ld.loan_no,@toDate) as ByteUidBalance,

        isnull((select sum(ag.principal_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0),
		(select isnull(sum(ag.principal_amort),0)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0)) as TotalPrincipalDue,

        isnull((select sum(ag.int_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0),
		
		(select isnull(sum(ag.int_amort),0)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0)
		) as TotalInterestDue,

        isnull((select sum(ag.total_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0),
		(select isnull(sum(ag.total_amort),0)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0)
		) as TotalAmortDue,

        isnull((select sum(isnull(ph.paid_int,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0),0) as TotalInterestReceived,

        isnull((select sum(isnull(ph.paid_principal,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0),0) as TotalPrincipalReceived,

        isnull((select sum(isnull(ph.paid_int,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0) +
                                                                        
                        (select sum(isnull(ph.paid_principal,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0),0) as TotalAmortPaid,

        isnull((select sum(ag.principal_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0
                    ),(select isnull(sum(ag.principal_amort),0)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0))		
		-
		(select isnull(sum(ph.paid_principal),0)
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0)
		as TotalPrincipalOverdue,
        ---------------------

        isnull((select sum(ag.int_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0),
		
		(select isnull(sum(ag.int_amort),0)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0)) -

                    (select isnull(sum(ph.paid_int),0)
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0) as TotalInterestOverdue,

        ---------------------
        (isnull((select sum(ag.principal_amort) + sum(ag.int_amort)
        from webloan.dbo.amort_guide ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0),(
		select isnull(sum(ag.principal_amort),0) + isnull(sum(ag.int_amort),0)
        from webloan.dbo.amort_data ag
        where ag.loan_no = ld.loan_no and datediff(day,amort_date,@toDate)>=0
		)) -

                                                                        
                    isnull((select sum(isnull(ph.paid_int,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0) +
                                                                        
                        (select sum(isnull(ph.paid_principal,0))
        from webloan.dbo.payment_history ph
        where ph.loan_no= ld.loan_no
            and datediff(day,payment_date,@toDate)>=0),0)) as CollectibleAdvance,
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
            and ph.paid_total > 0 and DATEDIFF(day,ph.payment_date,@toDate) >= 0
        order by ph.payment_date desc) LatestTotalPaymentReceivedDate,

        (select top 1
            ph.paid_total
        from webloan.dbo.payment_history ph
        where ph.bch = ld.bch and ph.loan_no = ld.loan_no
            and ph.paid_total > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
        order by ph.payment_date desc) LatestTotalPaymentReceivedAmount,

        (select top 1
            ph.payment_date
        from webloan.dbo.payment_history ph
        where ph.bch = ld.bch and ph.loan_no = ld.loan_no
            and ph.paid_principal > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
        order by ph.payment_date desc) LatestPrincipalPaidDate,

        (select top 1
            ph.paid_principal
        from webloan.dbo.payment_history ph
        where ph.bch = ld.bch and ph.loan_no = ld.loan_no
            and ph.paid_principal > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
        order by ph.payment_date desc)LatestPrincipalPaidAmount,

        (select top 1
            int.payment_date
        from
            (                                                                                                                                                                                                                                                                                                                                                select ph.payment_date, ph.paid_pdi as int_paid
                from webloan.dbo.payment_history ph
                where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                    and ph.paid_pdi > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
            union all
                select ph.payment_date, ph.paid_int as int_paid
                from webloan.dbo.payment_history ph
                where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                    and ph.paid_int > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
                        ) as int
        order by int.payment_date desc) LatestInterestPaidDate,


        (select top 1
            int.int_paid
        from
            (                                                                                                                                                                                                                                                                                                                                select ph.payment_date, ph.paid_pdi as int_paid
                from webloan.dbo.payment_history ph
                where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                    and ph.paid_pdi > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
            union all
                select ph.payment_date, ph.paid_int as int_paid
                from webloan.dbo.payment_history ph
                where ph.bch = ld.bch and ph.loan_no = ld.loan_no
                    and ph.paid_int > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
                        ) as int
        order by int.payment_date desc) LatestInterestPaidAmount,


        (select top 1
            ph.payment_date
        from webloan.dbo.payment_history ph
        where ph.bch = ld.bch and ph.loan_no = ld.loan_no
            and ph.paid_penalty > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
        order by ph.payment_date desc ) LatestPenaltyPaidDate,

        (select top 1
            ph.paid_penalty
        from webloan.dbo.payment_history ph
        where ph.bch = ld.bch and ph.loan_no = ld.loan_no
            and ph.paid_penalty > 0 and DATEDIFF(day,payment_date,@toDate) >= 0
        order by ph.payment_date desc ) LatestPenaltyPaidAmount,



        case
                        when webloan.dbo.get_loan_data_dynamic_boolean(ld.loan_no,'Auto Debit Advice')=1 or
            lp.auto_debit_sa_4_loan_payment=1
                        then webloan.dbo.get_loan_data_dynamic_string(ld.loan_no,'Account No')
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
            and ld.cat_loan_industry = c.id_code) as LoanPurposeToIndustry,

        readonly.dbo.charges_ledger_get_balance(ld.loan_no,'SC', @toDate) as ServiceChargeCollected,

        webloan.dbo.get_loan_discount_balance2(ld.loan_no,@toDate) as ServiceChargeBalance,

        case  ld.payment_interval
		when 30 then 'MONTHLY'
		when 90 then 'QUARTERLY'
		when 180 then 'HALF_YEARLY'
		when 360 then 'YEARLY'
		else 'LUMPSUM'
		end as PaymentFrequency,

        ld.payment_interval PaymentInterval

    from webloan.dbo.loan_data ld	
                                                                    with (nolock)
        join webloan.dbo.loan_product lp								
                                                                    with (nolock)
        on ld.loan_product=lp.id_code
    where 
                    DATEDIFF(day,date_granted,@toDate) >= 0 -- use < if releases on or after
        and WEBLOAN.dbo.is_loan(ld.loan_no) = 1

        and webloan.dbo.get_loan_status(ld.bk,ld.bch,ld.loan_no,@toDate) not in (10,4)

        and not exists (select 1
        from READONLY.dbo.loan_listing_exclusions a
        where ld.loan_no = a.loan_no)
                                        ) z

order by z.BranchId;


