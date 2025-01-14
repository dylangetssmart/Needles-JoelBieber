/* ######################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- add [saga]
	- add [saga_char]
	- Create fallback contacts
		- Unassigned Staff
		- Unidentified Individual
		- Unidentified Plaintiff
		- Unidentified Defendant
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#########################################################################################
*/

use ShinerSA
go

alter table sma_MST_IndvContacts disable trigger all
go


/* saga ---------------------------------------------------
- If saga exists and is not type INT, drop and re-add
---------------------------------------------------
*/
if exists (
		select
			1
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	if exists (
			select
				1
			from INFORMATION_SCHEMA.columns
			where TABLE_NAME = N'sma_MST_IndvContacts'
				and COLUMN_NAME = N'saga'
				and DATA_TYPE <> 'int'
		)
	begin
		alter table [sma_MST_IndvContacts] drop column [saga];
		alter table [sma_MST_IndvContacts] add [saga] INT null;
	end
end
else
begin
	alter table [sma_MST_IndvContacts] add [saga] INT null;
end
go


/* saga_char ---------------------------------------------------
- If saga_char exists and is not type VARCHAR(255), drop and re-add
---------------------------------------------------
*/
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [saga_char] VARCHAR(255) null;
end
go

if exists (
		select
			1
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	if exists (
			select
				1
			from INFORMATION_SCHEMA.columns
			where TABLE_NAME = N'sma_MST_IndvContacts'
				and COLUMN_NAME = N'saga_char'
				and DATA_TYPE <> 'varchar(255)'
		)
	begin
		alter table [sma_MST_IndvContacts] drop column [saga_char];
		alter table [sma_MST_IndvContacts] add [saga_char] VARCHAR(255) null;
	end
end
else
begin
	alter table [sma_MST_IndvContacts] add [saga_char] VARCHAR(255) null;
end
go

---------------------------------------------------
-- [1] Unassigned Staff
---------------------------------------------------
if not exists (
		select
			*
		from sma_MST_IndvContacts
		where [cinsFirstName] = 'Staff'
			and [cinsLastName] = 'Unassigned'
	)
begin
	insert into [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		select
			1,
			10,
			null,
			'Mr.',
			'Staff',
			'',
			'Unassigned',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			null
end

---------------------------------------------------
-- [2] Unidentified Individual
---------------------------------------------------
if not exists (
		select
			*
		from sma_MST_IndvContacts
		where [cinsFirstName] = 'Individual'
			and [cinsLastName] = 'Unidentified'
	)
begin
	insert into [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		select
			1,
			10,
			null,
			'Mr.',
			'Individual',
			'',
			'Unidentified',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'Unknown',
			'',
			'Doe',
			null
end

---------------------------------------------------
-- [3] Unidentified Plaintiff
---------------------------------------------------
if not exists (
		select
			*
		from sma_MST_IndvContacts
		where [cinsFirstName] = 'Plaintiff'
			and [cinsLastName] = 'Unidentified'
	)
begin
	insert into [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		select
			1,
			10,
			null,
			'',
			'Plaintiff',
			'',
			'Unidentified',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			null
end

---------------------------------------------------
-- [4] Unidentified Defendant
---------------------------------------------------
if not exists (
		select
			*
		from sma_MST_IndvContacts
		where [cinsFirstName] = 'Defendant'
			and [cinsLastName] = 'Unidentified'
	)
begin
	insert into [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		select distinct
			1,
			10,
			null,
			'',
			'Defendant',
			'',
			'Unidentified',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			null
end
go

alter table sma_MST_IndvContacts enable trigger all