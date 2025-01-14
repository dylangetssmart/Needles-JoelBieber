

use ShinerSA



/* saga_char ---------------------------------------------------
- If saga_char exists and is not type VARCHAR(255), drop and re-add
---------------------------------------------------
*/
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [saga_char] VARCHAR(255) null;
end
go

if exists (
		select
			1
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	if exists (
			select
				1
			from INFORMATION_SCHEMA.columns
			where TABLE_NAME = N'sma_TRN_Cases'
				and COLUMN_NAME = N'saga_char'
				and DATA_TYPE <> 'varchar(255)'
		)
	begin
		alter table [sma_TRN_Cases] drop column [saga_char];
		alter table [sma_TRN_Cases] add [saga_char] VARCHAR(255) null;
	end
end
else
begin
	alter table [sma_TRN_Cases] add [saga_char] VARCHAR(255) null;
end
go


------------------------------------------------------------------------------------------------------
-- [0.0] Temporary table to store variable values
------------------------------------------------------------------------------------------------------
begin

	if OBJECT_ID('conversion.shiner_office', 'U') is not null
	begin
		drop table conversion.shiner_office
	end

	create table conversion.shiner_office (
		OfficeName	   NVARCHAR(255),
		StateName	   NVARCHAR(100),
		PhoneNumber	   NVARCHAR(50),
		CaseGroup	   NVARCHAR(100),
		VenderCaseType NVARCHAR(25)
	);
	insert into conversion.shiner_office
		(
		OfficeName,
		StateName,
		PhoneNumber,
		CaseGroup,
		VenderCaseType
		)
	values (
	'Shiner Law Group',
	'Florida',
	'5617777700',
	'Litify',
	'ShinerCaseType'
	);
end

------------------------------------------------------------------------------------------------------
-- [1.0] Office
------------------------------------------------------------------------------------------------------
begin
	if not exists (
			select
				*
			from [sma_mst_offices]
			where office_name = (
					select
						OfficeName
					from conversion.shiner_office so
				)
		)
	begin
		insert into [sma_mst_offices]
			(
			[office_status],
			[office_name],
			[state_id],
			[is_default],
			[date_created],
			[user_created],
			[date_modified],
			[user_modified],
			[Letterhead],
			[UniqueContactId],
			[PhoneNumber]
			)
			select
				1					as [office_status],
				(
					select
						OfficeName
					from conversion.shiner_office so
				)					as [office_name],
				(
					select
						sttnStateID
					from sma_MST_States
					where sttsDescription = (
							select
								StateName
							from conversion.shiner_office so
						)
				)					as [state_id],
				1					as [is_default],
				GETDATE()			as [date_created],
				'dsmith'			as [user_created],
				GETDATE()			as [date_modified],
				'dbo'				as [user_modified],
				'LetterheadUt.docx' as [letterhead],
				null				as [uniquecontactid],
				(
					select
						phonenumber
					from conversion.shiner_office so
				)					as [phonenumber]
	end
end
