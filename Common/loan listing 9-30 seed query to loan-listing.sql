USE [READONLY]
GO

INSERT INTO [dbo].[LoanListing]
           (
			[BranchId]
           ,[BranchName]
           ,[AgreementId]
           ,[SchemeId]
           ,[CatMisGroup]
           ,[SchemeName]
           ,[LoanProduct]
           ,[LoanPurposeFullDescription]
           ,[LoanPurpose]
           ,[AccountOfficer]
           ,[LoanSecurity]
           ,[Ltv]
           ,[Agency]
           ,[CustomerId]
           ,[CustomerName]
           ,[CustomerAddress]
           ,[DateGranted]
           ,[MaturityDate]
           ,[Principal]
           ,[BytePrincipalBalance]
           ,[TotalInterest]
           ,[TotalInterestBalance]
           ,[ByteTotalPastDueInterestPaid]
           ,[ByteTotalPenaltyPaid]
           ,[BytePenaltyBalance]
           ,[firstamortdate]
           ,[amortamount]
           ,[loanterm]
           ,[numberofamort]
           ,[GrantedRate]
           ,[EffectiveRatePerAnnum]
           ,[LoanAge]
           ,[Status]
           ,[AccruedInterestReceivable]
           ,[AccruedInterestReceivableBalance]
           ,[ArBalance]
           ,[ByteUidBalance]
           ,[TotalPrincipalDue]
           ,[TotalInterestDue]
           ,[TotalAmortDue]
           ,[TotalInterestReceived]
           ,[TotalPrincipalReceived]
           ,[TotalAmortPaid]
           ,[TotalPrincipalOverdue]
           ,[TotalInterestOverdue]
           ,[CollectibleAdvance]
           ,[LastComputedChargeDate]
           ,[TotalLoanDue]
           ,[FutureDueAmount]
           ,[FutureDueDate]
           ,[TotalPenaltyDue]
           ,[AmountToClose]
           ,[LatestTotalPaymentReceivedDate]
           ,[LatestTotalPaymentReceivedAmount]
           ,[LatestPrincipalPaidDate]
           ,[LatestPrincipalPaidAmount]
           ,[LatestInterestPaidDate]
           ,[LatestInterestPaidAmount]
           ,[LatestPenaltyPaidDate]
           ,[LatestPenaltyPaidAmount]
           ,[AutoDebitAccount]
           ,[CreationType]
           ,[PastDueInterestBalance]
           ,[OldLoanProduct]
           ,[LoanPurposeToIndustry]
           ,[LoanAgeDescription])
     
select

a.BranchId,
a.BranchName,
a.AgreementId,
a.SchemeId,
a.CatMisGroup,
a.SchemeName,
a.LoanProduct,
a.LoanPurposeFullDescription,
a.LoanPurpose,
a.AccountOfficer,
a.LoanSecurity,
a.Ltv,
a.Agency,
a.CustomerId,
a.CustomerName,
null as CustomerAddress,
a.DateGranted,
a.MaturityDate,
a.Principal,
a.BytePrincipalBalance,
0 as TotalInterest,
a.ByteTotalInterestPaid as TotalInterestBalance,
a.ByteTotalPastDueInterestPaid,
a.ByteTotalPenaltyPaid,
a.BytePenaltyBalance,
a.FirstAmortDate,
a.AmortAmount,
a.LoanTerm,
a.NumberOfAmort,
a.GrantedRate,
a.EffectiveRatePerAnnum,
a.LoanAge,
a.Status,
a.AccruedInterestReceivable,
a.AccruedInterestReceivableBalance,
a.ArBalance,
a.ByteUidBalance,
0 as TotalPrincipalDue,
0 as TotalInterestDue,
a.TotalAmortDue,
0 as TotalInterestReceived,
0 as TotalPrincipalReceived,
a.TotalAmortPaid,
0 as TotalPrincipalOverdue,
0 as TotalInterestOverdue,
a.CollectibleAdvance,
a.LastComputedChargeDate,
a.TotalLoanDue,
a.FutureDueAmount,
a.FutureDueDate,
a.TotalPenaltyDue,
a.AmountToClose,
0 as LatestTotalPaymentReceivedDate,
0 as LatestTotalPaymentReceivedAmount,
0 as [LatestPrincipalPaidDate],
0 as [LatestPrincipalPaidAmount],
0 as [LatestInterestPaidDate],
0 as [LatestInterestPaidAmount],
0 as [LatestPenaltyPaidDate],
0 as [LatestPenaltyPaidAmount],
a.AutoDebitAccount,
a.CreationType,
0 as [PastDueInterestBalance],
null as OldLoanProduct,
null as LoanPurposeToIndustry,
null as LoanAgeDescription


from dbo.[LoanListing-9_30_2021] a