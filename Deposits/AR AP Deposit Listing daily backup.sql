USE [READONLY]
GO

/****** Object:  StoredProcedure [dbo].[BACKUP_DEPOSIT_LISTING]    Script Date: 10/14/2021 9:36:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[BACKUP_AR_AP_DEPOSIT_LISTING] @CutOffDate date=null
AS

	declare @date_end Datetime;

	if @CutOffDate is null 
	begin
		set @CutOffDate = dateadd(day, -1, getdate()) 
	end

	set @date_end=@CutOffDate;

    delete from AccountsReceivableAndPayableDepositListing where CutOffDate  = cast(@CutOffDate as date);

	insert into AccountsReceivableAndPayableDepositListing
            exec COMPILE_AR_AP_DEPOSIT_LISTING @date_end
GO





USE [READONLY]
GO

/****** Object:  StoredProcedure [dbo].[COMPILE_AR_AP_DEPOSIT_LISTING]    Script Date: 10/14/2021 9:38:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[COMPILE_AR_AP_DEPOSIT_LISTING] @CutOffDate Date = null
as
			
			if @CutOffDate is null
			set @CutOffDate = GETDATE()

            select 
			@CutOffDate CutOffDate,
			getdate() DateGenerated, 
			* from (
			select
                a.bch BranchId, 
                bs.bch_add as BranchName, 
                a.acct_no AccountId, 
                l.cis_no CustomerId,
                saveplus.dbo.get_name_from_acct_no(a.bk,a.bch,a.acct_no) CustomerName,
                a.name AccountName,
                a.add2 Address,
                a.rxclass as ByteScheme,
                
                (select top 1 b.schemeid 
                    from MIGRATION.dbo.product_table b 
                    where a.rxclass = b.what_class order by 1 desc) as FinnOneScheme, 

                saveplus.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@CutOffDate,1) as AvailableBalance,
                saveplus.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@CutOffDate,2) as LedgerBalance,
                saveplus.dbo.get_virtual_last_trans(a.bk,a.bch,a.acct_no,@CutOffDate) as LastTransaction,
                
                a.open_date OpenDate, 
                a.special_rt SpecialRate, 
                convert(varchar,a.maturity,101) MaturityDate,
                

                case 
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@CutOffDate,1) = 1 then 'Active'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@CutOffDate,1) = 2 then 'Inactive'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@CutOffDate,1) = 3 then 'Dormant'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@CutOffDate,1) = 4 then 'Closed'
                    else 'Not Found'
                end as Status

            from saveplus.dbo.account a	---all regular and time deposits
                with (nolock)
            join WEBLOAN.dbo.cis_lookup l
                with (nolock)	
                on a.bk=l.bk and	
                a.bch=l.bch and	
                a.acct_no=l.acct_no
            join SAVEPLUS.dbo.branch_set bs
                with (nolock)
                on a.bk=bs.bk and
                a.bch=bs.bch
            where open_date <= @CutOffDate and
                    close_date is null

				and a.rxclass  in ('AR1','AP1')

			) x
GO


