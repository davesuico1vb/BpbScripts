select --top 100
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

                saveplus.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,1) as AvailableBalance,
                saveplus.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,2) as LedgerBalance,
                saveplus.dbo.get_virtual_last_trans(a.bk,a.bch,a.acct_no,@date_end) as LastTransaction,
                
                a.open_date OpenDate, 
                a.special_rt SpecialRate, 
                convert(varchar,a.maturity,101) MaturityDate,
                

                case 
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 1 then 'Active'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 2 then 'Inactive'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 3 then 'Dormant'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,1) = 4 then 'Closed'
                    else 'Not Found'
                end as status

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
            where open_date < @date_end and
                    (
                        close_date is null or
                    (close_date is not null and close_date > @date_end)
                    )

                    and a.bch = isnull(@BranchId,a.bch)
            union all	
                
                
            select --top 100
                a.bch BranchId, 
                bs.bch_add as BranchName, 
                a.acct_no AccountId, 
                l.cis_no CustomerId,
                saveplus.dbo.get_name_from_acct_no(a.bk,a.bch,a.acct_no) CustomerName,
                a.name AccountName,
                a.add2 Address,
                a.caclass as ByteScheme,
                
                (select top 1 b.schemeid 
                    from MIGRATION.dbo.product_table b 
                    where a.caclass = b.what_class ) as FinnOneScheme, 

                saveplus.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,1) as AvailableBalance,
                saveplus.dbo.get_virtual_ebal12(a.bk,a.bch,a.acct_no,@date_end,2) as LedgerBalance,
                saveplus.dbo.get_virtual_last_trans(a.bk,a.bch,a.acct_no,@date_end) as LastTransaction,
                
                a.open_date OpenDate, 
                0.0 as SpecialRate, 
                null as MaturityDate, 

                case 
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 1 then 'Active'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 2 then 'Inactive'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 3 then 'Dormant'
                    when readonly.dbo.fvb_acct_status(a.bk,a.bch,a.acct_no,@date_end,2) = 4 then 'Closed'
                    else 'Not Found'
                end as status

            from saveplus.dbo.ca_account a	---all regular and time deposits
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
            where open_date < @date_end and
                    (
                        close_date is null or
                    (close_date is not null and close_date > @date_end)
                    ) 

                    and a.bch = isnull(@BranchId,a.bch)