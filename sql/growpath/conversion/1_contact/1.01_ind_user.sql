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
	- update bridge
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

---------------------------------------------------
-- [1.0] Individual contacts for users
---------------------------------------------------
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga_char], [cinsSpouse], [cinsGrade]
	)
	select distinct
		1		  as [cinbprimary],
		10		  as [cinncontacttypeid],
		null,
		'',
		FirstName as [cinsfirstname],
		''		  as [cinsmiddlename],
		LastName  as [cinslastname],
		null	  as [cinssuffix],
		null	  as [cinsnickname],
		1		  as [cinbstatus],
		null	  as [cinsssnno],
		null	  as [cindbirthdate],
		null	  as [cinscomments],
		1		  as [cinncontactctg],
		'',
		'',
		null,
		'',
		'',
		0		  as [cinngender],
		'',
		1,
		1,
		null,
		null,
		'',
		'',
		null,
		0,
		368		  as [cinnrecuserid],
		GETDATE() as [cinddtcreated],
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
		u.Title	  as [cinsoccupation],
		u.[Id]	  as [saga_char],
		''		  as [cinsspouse],
		null	  as [cinsgrade]
	from ShinerLitify..[User] u
	left join [sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
	where ind.cinnContactID is null

alter table sma_MST_IndvContacts enable trigger all
go