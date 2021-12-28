alter procedure create_all_branch_user_maker

@baseUsername varchar(10),
@fullname varchar(30)

as

DECLARE 
    @bch VARCHAR(MAX),
	@concatenatedUser varchar(MAX);

DECLARE cursor_branch CURSOR
FOR SELECT
    bch
FROM
    branch_set;

OPEN cursor_branch;

FETCH NEXT FROM cursor_branch INTO 
    @bch;

WHILE @@FETCH_STATUS = 0
    BEGIN
	set @concatenatedUser = concat(@bch,'-',@baseUsername);
    exec sp_cm_a_user @concatenatedUser, 'fvbank@69',@fullname, 'ACT_MKR',@bch, '', 1
    FETCH NEXT FROM cursor_branch INTO 
            @bch;
            
END;

CLOSE cursor_branch;

DEALLOCATE cursor_branch;




