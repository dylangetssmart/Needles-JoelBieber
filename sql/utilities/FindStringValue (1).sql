/****** Object:  UserDefinedFunction [utility].[EscapeSingleQuotes]    Script Date: 1/30/2025 12:20:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		J. A. Schweitzer
-- Create date: 2025.01.30
-- Description:	Escapes strings containing single quotes by doubling up the single quotes.
--              Very useful for dynamic SQL.
-- =============================================
CREATE OR ALTER   FUNCTION [utility].[EscapeSingleQuotes](
	@InputString nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	DECLARE @Outputstring nvarchar(4000);

	SET @OutputString = replace(@InputString,nchar(39),replicate(nchar(39),2));

	RETURN @OutputString;
END
GO

/****** Object:  StoredProcedure [utility].[FindStringValue]    Script Date: 1/30/2025 11:24:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------------
-- Find the tables that match the specified nvarchar value in any string column of that table.
-- Returns the database/schema/table name/column name for matches.
--
-- Examines tables in the specified database, if it exists. Defaults to the database where the code runs.
--
-- This code examines every string column in every non-system table in the specified database.
-- Be aware that this may take a substantial amount of time to run.
--
-- NOTE1: Collation of the column we are searching is used for comparing our search string to the column.
--        This is particularly important when the column collation is case-sensitive, accent-sensitive, or a binary collation
--        Ex: Comparing N'Foo' to N'foo' will match on a case-insensitive collation, but will not match on a case-sensitive collation.
----------------------------------------------------------------------------------
-- PARAMETERS:
-- - @FindString nvarchar(1000)   - Required string to search for.
-- - @db_name sysname             - Uses the current database as the default, if null.
-- - @show_check_msgs bit         - Show what is about to be checked as a message. Default to 1.
-- - @allow_initial_matches bit   - Searches for column values *starting* with the specified string. (Ex: "Foo" will match a column value of "Foobar", but not a column value of "BarFoo".) Defaults to 1.
-- - @allow_midstring_matches bit - Searches for column values *containing* the specified string. (Ex: "Foo" will match a column value of "Foobar" *and* a column value of "BarFoo".) Defaults to 0.
----------------------------------------------------------------------------------
-- SAMPLE CALL:
--		exec [utility].[FindStringValue] 'a0V3h00000HAOK4EAP',NULL,1,1,0
----------------------------------------------------------------------------------
-- The code to determine base datatypes for columns by Aaron Bertrand was retrieved from the following link on 2025.01.17:
-- https://stackoverflow.com/questions/10689654/finding-sql-base-type-for-a-user-defined-type
----------------------------------------------------------------------------------
-- 2025.01.09 - JAS - Initial build
-- 2025.01.17 - JAS - Changed to search all columns that have a collation in their data type since collations only apply to string-type data and we want to search all string-type data.
-- 2025.01.30 - JAS - Changed the find string to be 1000 characters long and fixed the associated bug. This should be ample for most purposes.
--                  - Also added midstring matches as an option. Note that midstring match queries tend to be slower.
----------------------------------------------------------------------------------
CREATE OR ALTER  procedure [utility].[FindStringValue](
	@FindString nvarchar(1000) -- Required
	,@db_name sysname = null -- Uses the current database as the default, if null
	,@show_check_msgs bit = 1 -- Show what is about to be checked
	,@allow_initial_matches bit = 1 -- Searches for column values starting with the specified string. (Ex: "Foo" will match a column value of "Foobar", but not a column value of "BarFoo".)
	,@allow_midstring_matches bit = 0 -- Searches for column values containing the specified string. (Ex: "Foo" will match a column value of "Foobar" *and* a column value of "BarFoo".)
)
as
BEGIN
	set nocount on;
	set xact_abort on;

	begin try;
		begin tran;

		declare
			@ListID int
			,@databasename sysname
			,@schemaname sysname
			,@tablename sysname
			,@columnname sysname
			,@datatype_name sysname
			,@collation_name sysname
			,@errmsg nvarchar(2028);

		declare
			@crlf nchar(2) = nchar(13) + nchar(10)
			,@tab nchar(1) = nchar(9);

		declare
			@string_len int = len(@FindString)
			,@FindStringEscaped nvarchar(1000)
			,@SQL nvarchar(max)
			,@TableSQL nvarchar(max)

		-- Validate params
		-- FindString
		if @FindString is null
		begin
			-- Set error string and emit error
			set @errmsg = 'The @FindString parameter cannot be null';
			raiserror(@errmsg,16,1);
		end
		else if len(trim(@FindString)) = 0
		begin
			-- Set error string and emit error
			set @errmsg = 'The @FindString parameter cannot be an empty string';
			raiserror(@errmsg,16,1);
		end
		else
		begin
			-- Escape any single quotes. Used in the dynamic SQL.
			set @FindStringEscaped = utility.EscapeSingleQuotes(@FindString);
		end;

		-- Database
		if @db_name is not null
		begin
			if not exists(
				select
					*
				from
					sys.databases
				where
					[name] = @db_name
			)
			begin
				-- Set error string and emit error
				set @errmsg = 'The database ' + quotename(@db_name) + N' does not exist on this server';
				raiserror(@errmsg,16,1);
			end;
		end
		else
		begin
			-- The parameter is null, so set it to the current database
			set @db_name = db_name();
		end;

		-- Bit params
		-- Force default into bit params when explicitly null
		set @show_check_msgs = isnull(@show_check_msgs,1);
		set @allow_initial_matches = isnull(@allow_initial_matches,1);
		set @allow_midstring_matches = isnull(@allow_midstring_matches,0);

		-- Create and populate the temp table that holds the list of tables and character columns in the current database.
		-- Skip character columns that are shorter than the specified value. They cannot hold that value by definition.
		drop table if exists #table_list;

		-- Holds the list of tables to examine
		create table #table_list(
			ListID int identity(1,1) not null primary key
			,FindString nvarchar(1000) not null
			,[databasename] sysname
			,schemaname sysname
			,tablename sysname
			,columnname sysname
			,datatype_name sysname
			,max_length smallint
			,collation_name sysname
			,[object_id] int not null
			,is_used bit not null default 0
			,has_value bit not null default 0
			,unique(
				[databasename]
				,schemaname
				,tablename
				,columnname
			)
		);

		-- Build SQL to populate the table holding the columns we will search
		set @TableSQL = N'insert #table_list(' + @crlf
			+ replicate(@tab,1) + N'[FindString]' + @crlf
			+ replicate(@tab,1) + N',[databasename]' + @crlf
			+ replicate(@tab,1) + N',schemaname' + @crlf
			+ replicate(@tab,1) + N',tablename' + @crlf
			+ replicate(@tab,1) + N',columnname' + @crlf
			+ replicate(@tab,1) + N',datatype_name' + @crlf
			+ replicate(@tab,1) + N',max_length' + @crlf
			+ replicate(@tab,1) + N',collation_name' + @crlf
			+ replicate(@tab,1) + N',object_id' + @crlf
			+ replicate(@tab,0) + N')' + @crlf
			+ replicate(@tab,0) + N'select' + @crlf
			+ replicate(@tab,1) + N'N''' + @FindStringEscaped + N'''' + @crlf
			+ replicate(@tab,1) + N',N''' + @db_name + N'''' + @crlf
			+ replicate(@tab,1) + N',ss.name' + @crlf
			+ replicate(@tab,1) + N',st.name' + @crlf
			+ replicate(@tab,1) + N',sc.name' + @crlf
			+ replicate(@tab,1) + N',COALESCE(basetype.name, sty.name)' + @crlf
			+ replicate(@tab,1) + N',sc.max_length' + @crlf
			+ replicate(@tab,1) + N',sc.collation_name' + @crlf
			+ replicate(@tab,1) + N',st.object_id' + @crlf
			--------------------------------------------------------------------------------
			-- From clause
			--------------------------------------------------------------------------------
			+ replicate(@tab,0) + N'from' + @crlf
			+ replicate(@tab,1) + quotename(@db_name) + N'.sys.tables st' + @crlf
			+ replicate(@tab,1) + N'inner join ' + quotename(@db_name) + N'.sys.schemas ss' + @crlf
			+ replicate(@tab,2) + N'on st.schema_id = ss.schema_id' + @crlf
			+ replicate(@tab,1) + N'inner join ' + quotename(@db_name) + N'.sys.columns sc' + @crlf
			+ replicate(@tab,2) + N'on st.object_id = sc.object_id' + @crlf
			+ replicate(@tab,1) + N'inner join ' + quotename(@db_name) + N'.sys.types sty' + @crlf
			+ replicate(@tab,2) + N'on sc.system_type_id = sty.system_type_id' + @crlf
			+ replicate(@tab,3) + N'and sc.user_type_id = sty.user_type_id' + @crlf
			-- Get the base datatype for any user-defined datatypes that are used in the table structure.
			+ replicate(@tab,1) + N'left outer join sys.types AS basetype' + @crlf
			+ replicate(@tab,2) + N'ON sty.is_user_defined = 1' + @crlf
			+ replicate(@tab,3) + N'and basetype.is_user_defined = 0' + @crlf
			+ replicate(@tab,3) + N'and sty.system_type_id = basetype.system_type_id' + @crlf
			+ replicate(@tab,3) + N'and basetype.user_type_id = basetype.system_type_id' + @crlf
			--------------------------------------------------------------------------------
			-- Where clause
			--------------------------------------------------------------------------------
			+ replicate(@tab,0) + N'where' + @crlf
			-- Only user tables. Views are *not* searched.
			+ replicate(@tab,1) + N'st.type_desc = ''USER_TABLE''' + @crlf 
			-- Only string datatypes have a collation. This applies to strings stored as either 2-byte characters or 1-byte characters.
			+ replicate(@tab,1) + N'and sc.collation_name is not null' + @crlf
			-- Only return columns that are at least as long as the string we are searching for. Ex: A value of "elephantiasis" (13 characters) simply cannot be stored in a 10 character wide column.
			+ replicate(@tab,1) + N'and 1 = case' + @crlf
			-- Maximum length datatypes potentially contain enormously long strings, so they are automatically included
			-- Note that varbinary(max) cols are excluded because they do not have a collation.
			+ replicate(@tab,2) + N'when sc.max_length = -1' + @crlf
			+ replicate(@tab,3) + N'then 1' + @crlf
			-- Unicode datatypes take up two bytes each so the storage length is always twice as much as the character length
			+ replicate(@tab,2) + N'when sty.[name] in (N''nchar'',N''nvarchar'',N''ntext'',N''sysname'') and sc.max_length >= ' + convert(nvarchar(10),@string_len * 2) + @crlf
			+ replicate(@tab,3) + N'then 1' + @crlf
			-- These are single character datatypes, so we look for lengths that are at least as long as our search value.
			+ replicate(@tab,2) + N'when sc.max_length >= ' + convert(nvarchar(10),@string_len) + @crlf
			+ replicate(@tab,3) + N'then 1' + @crlf
			+ replicate(@tab,2) + N'else 0' + @crlf
			+ replicate(@tab,1) + N'end' + @crlf
			+ replicate(@tab,0) + N'order by' + @crlf
			+ replicate(@tab,1) + N'ss.name' + @crlf
			+ replicate(@tab,1) + N',st.name' + @crlf
			+ replicate(@tab,1) + N',sc.name;' + @crlf;
		
		-- Execute the built SQL
		exec sp_executesql
			@command = @TableSQL;
		
		-- Loop through #table_list
		while exists(
			select
				*
			from
				#table_list
			where
				is_used = 0
		)
		begin
			-- Get the next column's data
			select
				top 1
				@ListID = ListID
				,@databasename = [databasename]
				,@schemaname = [schemaname]
				,@tablename = [tablename]
				,@columnname = [columnname]
				,@datatype_name = [datatype_name]
				,@collation_name = [collation_name]
			from
				#table_list
			where
				is_used = 0;
			
			-- Show that stuff is happening if the option to show messages is set.
			if @show_check_msgs = 1
			begin
				set @errmsg = N'Searching column ' + QUOTENAME(@columnname) + ' in table ' + quotename(@databasename) + N'.' + quotename(@schemaname) + N'.' + QUOTENAME(@tablename) + N' for value ';
				if @allow_midstring_matches = 1
				begin
					-- Search for matches anywhere in the column value
					set @errmsg+= N'like "%' + @FindString + N'%"' + @crlf
				end
				else if @allow_initial_matches = 1
				begin
					-- Search for matches at the beginning of the column value
					set @errmsg+= N'like "' + @FindString + N'%"' + @crlf
				end
				else
				begin
					-- Search for matches exactly equal to the column value
					set @errmsg+= N'equal to "' + @FindString + N'"' + @crlf
				end;
				-- String passed into raiserror as a parameter to deal with the embedded percent sign issue.
				raiserror('%s',0,1,@errmsg) with nowait;
			end;
			
			-- Build the SQL to check this column and update the list table
			set @SQL = N'update tl' + @crlf
				+ replicate(@tab,0) + N'set' + @crlf
				-- is_used
				+ replicate(@tab,1) + N'is_used = 1' + @crlf
				+ replicate(@tab,1) + N',has_value = case' + @crlf
				+ replicate(@tab,2) + N'when exists(' + @crlf
				+ replicate(@tab,3) + N'select' + @crlf
				+ replicate(@tab,4) + N'*' + @crlf
				+ replicate(@tab,3) + N'from' + @crlf
				+ replicate(@tab,4) + QUOTENAME(@databasename) + N'.' + QUOTENAME(@schemaname) + N'.' + QUOTENAME(@tablename) + @crlf
				+ replicate(@tab,3) + N'where' + @crlf
				-- Note: We *must use* collation clause to make the proper comparison to the column we ar searching (i.e. Be case-sensitive, accent-sensitive, etc.)
				-- The column length is always >= the @FindString length, so we know that @FindString might fit in the column.
				+ replicate(@tab,4)
				+ case
					when @datatype_name = N'text'
						then N'convert(varchar(max),'
					when @datatype_name = N'ntext'
						then N'convert(nvarchar(max),'
					else ''
				end
				+ QUOTENAME(@columnname)
				+ case
					when @datatype_name in( N'text',N'ntext')
						then N')'
					else ''
				end
				-- Filter on "LIKE" when partial matches are allowed and "=" when they are not
				+ case
					-- Search for matches anywhere in the column value
					when @allow_midstring_matches = 1
						then N' like N''%' + @FindStringEscaped + N'%'''
					-- Search for matches at the beginning of the column value
					when @allow_initial_matches = 1
						then N' like N''' + @FindStringEscaped + N'%'''
					-- Search for matches exactly equal to the column value
					else N' = N''' + @FindStringEscaped + ''''
				end
				+ N' COLLATE ' + @collation_name + @crlf
				+ replicate(@tab,2) + N')' + @crlf
				+ replicate(@tab,3) + N'then 1' + @crlf
				+ replicate(@tab,4) + N'else 0' + @crlf
				+ replicate(@tab,1) + N'end' + @crlf
				+ replicate(@tab,0) + N'from' + @crlf
				+ replicate(@tab,1) + N'#table_list tl' + @crlf
				+ replicate(@tab,0) + N'where' + @crlf
				+ replicate(@tab,1) + N'tl.ListID = ' + convert(varchar(10),@ListID) + N';' + @crlf; -- Update only the PK row
			
			-- Execute the row update code, which marks off the row and also searches for FindString in the column listed in the row.
			exec (@SQL);
		end;
		
		-- Return the tables and string columns in the specified database that have at least one row matching the specified ID root.
		select
			t.FindString
			,t.databasename
			,t.schemaname
			,t.tablename
			,t.columnname
			,t.datatype_name -- thr base datatype for user-defined types
			,case
				-- Column is max length when it length = -1
				when t.max_length = -1
					then 'max'
				-- The specified datatypes are Unicode and are stored as 2 bytes per character, therefore we divide the storage length in two to get the maximum number of characters.
				when t.datatype_name in (N'nchar',N'ntext',N'nvarchar',N'sysname')
					then convert(nvarchar(10),t.max_length / 2)
				-- All other cases
				else convert(nvarchar(10),t.max_length)
			end [maximum_length]
			,t.collation_name -- The rules for comparing and sorting values in the column
		from
			#table_list t
		where
			t.has_value = 1
		order by
			t.databasename
			,t.schemaname
			,t.tablename
			,t.columnname;
		
		-- Housekeeping
		drop table if exists #table_list;
		
		commit tran;
	end try
	begin catch
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @msg nvarchar(2048) = error_message();
		RAISERROR (@msg, 16, 1);
		return 55555;
	end catch;
END;
GO


