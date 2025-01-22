/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts from [user]

[0.0] Update schema
- 

[1.0] Individual Contacts					Target							Source
	-------------------------------------------------------------------------------------------------
	[1.1] Litify Contacts					sma_MST_IndvContacts			dbo.Contact
	[1.2] Litify Individual accounts		sma_MST_IndvContacts			dbo.Account
	[1.3] Law Firm Primary Contacts			sma_MST_IndvContacts			dbo.litify_pm__firm__c

[2.0] Organization Contacts					Target							Source
	-------------------------------------------------------------------------------------------------
	[2.1] Litify Business accounts			sma_MST_OrgContacts				dbo.Account
	[2.2] Law Firms							sma_MST_OrgContacts				dbo.litify_pm__firm__c

########################################################################################################################
*/


/* ###################################################################################
description: Create general individual contacts
steps:
	- insert [sma_MST_IndvContacts] from [needles].[names]
usage_instructions:
	-
dependencies:
	- 
notes:
	- 
saga:
	- saga
source:
	- [names]
target:
	- [sma_MST_IndvContacts]
######################################################################################
*/


use ShinerSA
go

---------------------------------------------------
-- [1.0] Individual Contacts
---------------------------------------------------
alter table [sma_MST_IndvContacts] disable trigger all
go

/*
Add saga columns to reference source data

1. saga		> link to source record
2. saga_db	> "GP" or "ND"
3. saga_ref	> indicate data source where applicable

*/
if not exists (
		select
			*
		from sys.columns
		where Name in (N'saga', N'saga_db', N'saga_ref')
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga'
				and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
		)
	begin
		alter table [sma_MST_IndvContacts]
		add saga VARCHAR(100);
	end

	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga_db'
				and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
		)
	begin
		alter table [sma_MST_IndvContacts]
		add saga_db VARCHAR(2);
	end

	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga_ref'
				and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
		)
	begin
		alter table [sma_MST_IndvContacts]
		add saga_ref VARCHAR(50);
	end
end
go

---
if not exists (
		select
			*
		from sys.columns
		where Name in (N'saga', N'saga_db', N'saga_ref')
			and Object_ID = OBJECT_ID(N'sma_MST_Users')
	)
begin
	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga'
				and Object_ID = OBJECT_ID(N'sma_MST_Users')
		)
	begin
		alter table [sma_MST_Users]
		add saga VARCHAR(100);
	end

	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga_db'
				and Object_ID = OBJECT_ID(N'sma_MST_Users')
		)
	begin
		alter table [sma_MST_Users]
		add saga_db VARCHAR(2);
	end

	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga_ref'
				and Object_ID = OBJECT_ID(N'sma_MST_Users')
		)
	begin
		alter table [sma_MST_Users]
		add saga_ref VARCHAR(50);
	end
end
go


alter table sma_MST_IndvContacts disable trigger all
go

---------------------------------------------------
-- [1.0] Individual contacts for users
---------------------------------------------------
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary],
	[cinnContactTypeID],
	[cinnContactSubCtgID],
	[cinsPrefix],
	[cinsFirstName],
	[cinsMiddleName],
	[cinsLastName],
	[cinsSuffix],
	[cinsNickName],
	[cinbStatus],
	[cinsSSNNo],
	[cindBirthDate],
	[cinsComments],
	[cinnContactCtg],
	[cinnRefByCtgID],
	[cinnReferredBy],
	[cindDateOfDeath],
	[cinsCVLink],
	[cinnMaritalStatusID],
	[cinnGender],
	[cinsBirthPlace],
	[cinnCountyID],
	[cinsCountyOfResidence],
	[cinbFlagForPhoto],
	[cinsPrimaryContactNo],
	[cinsHomePhone],
	[cinsWorkPhone],
	[cinsMobile],
	[cinbPreventMailing],
	[cinnRecUserID],
	[cindDtCreated],
	[cinnModifyUserID],
	[cindDtModified],
	[cinnLevelNo],
	[cinsPrimaryLanguage],
	[cinsOtherLanguage],
	[cinbDeathFlag],
	[cinsCitizenship],
	[cinsHeight],
	[cinnWeight],
	[cinsReligion],
	[cindMarriageDate],
	[cinsMarriageLoc],
	[cinsDeathPlace],
	[cinsMaidenName],
	[cinsOccupation],
	[cinsSpouse],
	[cinsGrade],
	[saga],
	[saga_db],
	[saga_ref]
	)
	select distinct
		1							as [cinbprimary],
		10							as [cinncontacttypeid],
		null,
		e.prefix					as [cinsprefix],
		e.first_name				as [cinsfirstname],
		e.middle_name				as [cinsmiddlename],
		e.last_name_or_company_name as [cinslastname],
		e.suffix					as [cinssuffix],
		null						as [cinsnickname],
		1							as [cinbstatus],
		null						as [cinsssnno],
		e.date_of_birth				as [cindbirthdate],
		null						as [cinscomments],
		1							as [cinncontactctg],
		'',
		'',
		null,
		'',
		'',
		lbg.name					as [cinngender],
		'',
		1,
		1,
		null,
		null,
		'',
		'',
		null,
		0,
		368							as [cinnrecuserid],
		GETDATE()					as [cinddtcreated],
		'',
		null,
		0,
		'',
		'',
		'',
		'',
		null,
		null,
		'',
		null,
		'',
		'',
		'',
		lbo.name					as [cinsoccupation],
		''							as [cinsspouse],
		null						as [cinsgrade],
		u.id						as [saga],
		'GP'						as [saga_db],
		'user_profile'				as [saga_ref]
	from JoelBieber_GrowPath..user_profile u
	join JoelBieber_GrowPath..entity e
		on e.user_profile_id = u.id
	-- Occupation
	left join JoelBieber_GrowPath..lookup_bucket lbo
		on lbo.id = u.job_title_id
	-- Gender
	left join JoelBieber_GrowPath..lookup_bucket lbg
		on lbg.id = e.gender_id
	left join [sma_MST_IndvContacts] ind
		on ind.saga = u.id
	where ind.cinnContactID is null
go


alter table sma_MST_IndvContacts enable trigger all
go