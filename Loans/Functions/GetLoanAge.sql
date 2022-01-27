USE [READONLY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetLoanAge]    Script Date: 1/27/2022 3:06:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Dave Suico>
-- Create date: <2022-01-27>
-- Description:	<Compute the loan age of the loan.>
-- =============================================
ALTER FUNCTION [dbo].[GetLoanAge] 
(
	-- Add the parameters for the function here
	@LoanNumber varchar(MAX),
	@CutOffDate date,
	@DateGranted datetime,
	@LoanProduct varchar(MAX),
	@PaymentType tinyint,
	@LoanProductAutoTransferPastDue tinyint
)
RETURNS int
AS
BEGIN
	
	declare @LoanAge as int  = 
				case							
				    when datediff(day,@CutOffDate,@DateGranted) > 0 then -1								
				    when @PaymentType=3 then datediff(day,webloan.dbo.get_last_uid(@LoanNumber,@CutOffDate),@CutOffDate) --- for UID ---								
				    -- Daily Triggered / SavePlus StartUp -----------------------------------------------------------------------								
				    when @LoanProductAutoTransferPastDue in (3,4) and								
				            @PaymentType in (0,1,2)								
				            then datediff(day,webloan.dbo.get_min_amort_unpaid(@LoanNumber,@CutOffDate),@CutOffDate)								
				    ------------------------------------------------------------------------------------------------------------								
				    else datediff(day,webloan.dbo.get_min_amort_unpaid(@LoanNumber,@CutOffDate),@CutOffDate)								
				end;

	if @LoanProduct in ('LS1', 'LS2', 'LT6', 'LT7','LT8', 'LV1', 'LV2', 'LV3','LV4', 'LV5', 'LV6')	
		set @LoanAge = @LoanAge - 30;
		return iif(@LoanAge < 0,0,@LoanAge);
	

	

	return @LoanAge;

END
