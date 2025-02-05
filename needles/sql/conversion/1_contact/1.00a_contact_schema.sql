/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Add columns to [sma_MST_IndvContacts]
		- saga
		- source_id
		- source_db
		- source_ref
	- Add columns to [sma_MST_OrgContacts]
		- saga
		- source_id
		- source_db
		- source_ref
usage_instructions:
	-
dependencies:
	- 
notes:
	-
*/

use JoelBieberSA_Needles
go

---------------------------------------------------
-- sma_MST_IndvContacts
---------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [saga] INT null;
end
go

---- saga (INT)
---- Check if the column 'saga' exists and if it's not of type INT, change its type
--if exists (
--		select
--			1
--		from sys.columns
--		where Name = N'saga'
--			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
--	)
--begin
--	-- Check the data type of the 'saga' column
--	if exists (
--			select
--				1
--			from INFORMATION_SCHEMA.COLUMNS
--			where TABLE_NAME = N'sma_MST_IndvContacts'
--				and COLUMN_NAME = N'saga'
--				and DATA_TYPE <> 'int'
--		)
--	begin
--		-- Drop and re-add the 'saga' column as INT if it exists with a different data type
--		alter table [sma_MST_IndvContacts] drop column [saga];
--		alter table [sma_MST_IndvContacts] add [saga] INT null;
--	end
--end
--else
--begin
--	-- Add the 'saga' column if it does not exist
--	alter table [sma_MST_IndvContacts] add [saga] INT null;
--end
--go

go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [source_ref] VARCHAR(MAX) null;
end
go

---------------------------------------------------
-- [sma_MST_OrgContacts]
---------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_id] VARCHAR(max) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_db] VARCHAR(max) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_ref] VARCHAR(max) null;
end
go


--/* --------------------------------------------------------------------------------------------------------------
--Unidentified Contacts
--*/

--alter table sma_MST_IndvContacts disable trigger all
--go

-----------------------------------------------------
---- [1] Unidentified Staff
-----------------------------------------------------
--if not exists (
--		select
--			*
--		from sma_MST_IndvContacts
--		where [cinsFirstName] = 'Staff'
--			and [cinsLastName] = 'Unassigned'
--	)
--begin
--	insert into [sma_MST_IndvContacts]
--		(
--		[cinbPrimary],
--		[cinnContactTypeID],
--		[cinnContactSubCtgID],
--		[cinsPrefix],
--		[cinsFirstName],
--		[cinsMiddleName],
--		[cinsLastName],
--		[cinsSuffix],
--		[cinsNickName],
--		[cinbStatus],
--		[cinsSSNNo],
--		[cindBirthDate],
--		[cinsComments],
--		[cinnContactCtg],
--		[cinnRefByCtgID],
--		[cinnReferredBy],
--		[cindDateOfDeath],
--		[cinsCVLink],
--		[cinnMaritalStatusID],
--		[cinnGender],
--		[cinsBirthPlace],
--		[cinnCountyID],
--		[cinsCountyOfResidence],
--		[cinbFlagForPhoto],
--		[cinsPrimaryContactNo],
--		[cinsHomePhone],
--		[cinsWorkPhone],
--		[cinsMobile],
--		[cinbPreventMailing],
--		[cinnRecUserID],
--		[cindDtCreated],
--		[cinnModifyUserID],
--		[cindDtModified],
--		[cinnLevelNo],
--		[cinsPrimaryLanguage],
--		[cinsOtherLanguage],
--		[cinbDeathFlag],
--		[cinsCitizenship],
--		[cinsHeight],
--		[cinnWeight],
--		[cinsReligion],
--		[cindMarriageDate],
--		[cinsMarriageLoc],
--		[cinsDeathPlace],
--		[cinsMaidenName],
--		[cinsOccupation],
--		[saga],
--		[cinsSpouse],
--		[cinsGrade]
--		)

--		select
--			1,
--			10,
--			null,
--			'Mr.',
--			'Staff',
--			'',
--			'Unassigned',
--			null,
--			null,
--			1,
--			null,
--			null,
--			null,
--			1,
--			'',
--			'',
--			null,
--			'',
--			'',
--			1,
--			'',
--			1,
--			1,
--			null,
--			null,
--			'',
--			'',
--			null,
--			0,
--			368,
--			GETDATE(),
--			'',
--			null,
--			0,
--			'',
--			'',
--			'',
--			'',
--			null + null,
--			null,
--			'',
--			null,
--			'',
--			'',
--			'',
--			'',
--			'',
--			'',
--			null
--end

-----------------------------------------------------
---- [2] Unidentified Individual
-----------------------------------------------------

--if not exists (
--		select
--			*
--		from sma_MST_IndvContacts
--		where [cinsFirstName] = 'Individual'
--			and [cinsLastName] = 'Unidentified'
--	)
--begin
--	insert into [sma_MST_IndvContacts]
--		(
--		[cinbPrimary],
--		[cinnContactTypeID],
--		[cinnContactSubCtgID],
--		[cinsPrefix],
--		[cinsFirstName],
--		[cinsMiddleName],
--		[cinsLastName],
--		[cinsSuffix],
--		[cinsNickName],
--		[cinbStatus],
--		[cinsSSNNo],
--		[cindBirthDate],
--		[cinsComments],
--		[cinnContactCtg],
--		[cinnRefByCtgID],
--		[cinnReferredBy],
--		[cindDateOfDeath],
--		[cinsCVLink],
--		[cinnMaritalStatusID],
--		[cinnGender],
--		[cinsBirthPlace],
--		[cinnCountyID],
--		[cinsCountyOfResidence],
--		[cinbFlagForPhoto],
--		[cinsPrimaryContactNo],
--		[cinsHomePhone],
--		[cinsWorkPhone],
--		[cinsMobile],
--		[cinbPreventMailing],
--		[cinnRecUserID],
--		[cindDtCreated],
--		[cinnModifyUserID],
--		[cindDtModified],
--		[cinnLevelNo],
--		[cinsPrimaryLanguage],
--		[cinsOtherLanguage],
--		[cinbDeathFlag],
--		[cinsCitizenship],
--		[cinsHeight],
--		[cinnWeight],
--		[cinsReligion],
--		[cindMarriageDate],
--		[cinsMarriageLoc],
--		[cinsDeathPlace],
--		[cinsMaidenName],
--		[cinsOccupation],
--		[saga],
--		[cinsSpouse],
--		[cinsGrade]
--		)

--		select
--			1,
--			10,
--			null,
--			'Mr.',
--			'Individual',
--			'',
--			'Unidentified',
--			null,
--			null,
--			1,
--			null,
--			null,
--			null,
--			1,
--			'',
--			'',
--			null,
--			'',
--			'',
--			1,
--			'',
--			1,
--			1,
--			null,
--			null,
--			'',
--			'',
--			null,
--			0,
--			368,
--			GETDATE(),
--			'',
--			null,
--			0,
--			'',
--			'',
--			'',
--			'',
--			null + null,
--			null,
--			'',
--			null,
--			'',
--			'',
--			'',
--			'Unknown',
--			'',
--			'Doe',
--			null
--end

-----------------------------------------------------
---- [3] Unidentified Plaintiff
-----------------------------------------------------

--if not exists (
--		select
--			*
--		from sma_MST_IndvContacts
--		where [cinsFirstName] = 'Plaintiff'
--			and [cinsLastName] = 'Unidentified'
--	)
--begin
--	insert into [sma_MST_IndvContacts]
--		(
--		[cinbPrimary],
--		[cinnContactTypeID],
--		[cinnContactSubCtgID],
--		[cinsPrefix],
--		[cinsFirstName],
--		[cinsMiddleName],
--		[cinsLastName],
--		[cinsSuffix],
--		[cinsNickName],
--		[cinbStatus],
--		[cinsSSNNo],
--		[cindBirthDate],
--		[cinsComments],
--		[cinnContactCtg],
--		[cinnRefByCtgID],
--		[cinnReferredBy],
--		[cindDateOfDeath],
--		[cinsCVLink],
--		[cinnMaritalStatusID],
--		[cinnGender],
--		[cinsBirthPlace],
--		[cinnCountyID],
--		[cinsCountyOfResidence],
--		[cinbFlagForPhoto],
--		[cinsPrimaryContactNo],
--		[cinsHomePhone],
--		[cinsWorkPhone],
--		[cinsMobile],
--		[cinbPreventMailing],
--		[cinnRecUserID],
--		[cindDtCreated],
--		[cinnModifyUserID],
--		[cindDtModified],
--		[cinnLevelNo],
--		[cinsPrimaryLanguage],
--		[cinsOtherLanguage],
--		[cinbDeathFlag],
--		[cinsCitizenship],
--		[cinsHeight],
--		[cinnWeight],
--		[cinsReligion],
--		[cindMarriageDate],
--		[cinsMarriageLoc],
--		[cinsDeathPlace],
--		[cinsMaidenName],
--		[cinsOccupation],
--		[saga],
--		[cinsSpouse],
--		[cinsGrade]
--		)

--		select
--			1,
--			10,
--			null,
--			'',
--			'Plaintiff',
--			'',
--			'Unidentified',
--			null,
--			null,
--			1,
--			null,
--			null,
--			null,
--			1,
--			'',
--			'',
--			null,
--			'',
--			'',
--			1,
--			'',
--			1,
--			1,
--			null,
--			null,
--			'',
--			'',
--			null,
--			0,
--			368,
--			GETDATE(),
--			'',
--			null,
--			0,
--			'',
--			'',
--			'',
--			'',
--			null + null,
--			null,
--			'',
--			null,
--			'',
--			'',
--			'',
--			'',
--			'',
--			'',
--			null
--end

-----------------------------------------------------
---- [4] Unidentified Defendant
-----------------------------------------------------

--if not exists (
--		select
--			*
--		from sma_MST_IndvContacts
--		where [cinsFirstName] = 'Defendant'
--			and [cinsLastName] = 'Unidentified'
--	)
--begin
--	insert into [sma_MST_IndvContacts]
--		(
--		[cinbPrimary],
--		[cinnContactTypeID],
--		[cinnContactSubCtgID],
--		[cinsPrefix],
--		[cinsFirstName],
--		[cinsMiddleName],
--		[cinsLastName],
--		[cinsSuffix],
--		[cinsNickName],
--		[cinbStatus],
--		[cinsSSNNo],
--		[cindBirthDate],
--		[cinsComments],
--		[cinnContactCtg],
--		[cinnRefByCtgID],
--		[cinnReferredBy],
--		[cindDateOfDeath],
--		[cinsCVLink],
--		[cinnMaritalStatusID],
--		[cinnGender],
--		[cinsBirthPlace],
--		[cinnCountyID],
--		[cinsCountyOfResidence],
--		[cinbFlagForPhoto],
--		[cinsPrimaryContactNo],
--		[cinsHomePhone],
--		[cinsWorkPhone],
--		[cinsMobile],
--		[cinbPreventMailing],
--		[cinnRecUserID],
--		[cindDtCreated],
--		[cinnModifyUserID],
--		[cindDtModified],
--		[cinnLevelNo],
--		[cinsPrimaryLanguage],
--		[cinsOtherLanguage],
--		[cinbDeathFlag],
--		[cinsCitizenship],
--		[cinsHeight],
--		[cinnWeight],
--		[cinsReligion],
--		[cindMarriageDate],
--		[cinsMarriageLoc],
--		[cinsDeathPlace],
--		[cinsMaidenName],
--		[cinsOccupation],
--		[saga],
--		[cinsSpouse],
--		[cinsGrade]
--		)

--		select distinct
--			1,
--			10,
--			null,
--			'',
--			'Defendant',
--			'',
--			'Unidentified',
--			null,
--			null,
--			1,
--			null,
--			null,
--			null,
--			1,
--			'',
--			'',
--			null,
--			'',
--			'',
--			1,
--			'',
--			1,
--			1,
--			null,
--			null,
--			'',
--			'',
--			null,
--			0,
--			368,
--			GETDATE(),
--			'',
--			null,
--			0,
--			'',
--			'',
--			'',
--			'',
--			null + null,
--			null,
--			'',
--			null,
--			'',
--			'',
--			'',
--			'',
--			'',
--			'',
--			null
--end
--go