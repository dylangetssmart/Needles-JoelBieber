/* ###################################################################################
description: Create Police Officer contacts
steps:
	- insert from police
	- update bridge
usage_instructions:
	-
dependencies:
	- 
notes:
	-
source: [police]
target: [sma_MST_IndvContacts]
saga: saga_char
*/

use JoelBieberSA_Needles
go

/* --------------------------------------------------------------------------------------------------------------
- Insert from [police]
*/
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade], [saga_char]
	)
	select distinct
		1							 as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from [dbo].[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'Police Officer'
		)							 as [cinncontacttypeid],
		null						 as [cinncontactsubctgid],
		'Officer'					 as [cinsprefix],
		dbo.get_firstword(p.officer) as [cinsfirstname],
		''							 as [cinsmiddlename],
		dbo.get_lastword(p.officer)	 as [cinslastname],
		null						 as [cinssuffix],
		null						 as [cinsnickname],
		1							 as [cinbstatus],
		null						 as [cinsssnno],
		null						 as [cindbirthdate],
		null						 as [cinscomments],
		1							 as [cinncontactctg],
		''							 as [cinnrefbyctgid],
		''							 as [cinnreferredby],
		null						 as [cinddateofdeath],
		''							 as [cinscvlink],
		''							 as [cinnmaritalstatusid],
		1							 as [cinngender],
		''							 as [cinsbirthplace],
		1							 as [cinncountyid],
		1							 as [cinscountyofresidence],
		null						 as [cinbflagforphoto],
		null						 as [cinsprimarycontactno],
		''							 as [cinshomephone],
		''							 as [cinsworkphone],
		null						 as [cinsmobile],
		0							 as [cinbpreventmailing],
		368							 as [cinnrecuserid],
		GETDATE()					 as [cinddtcreated],
		''							 as [cinnmodifyuserid],
		null						 as [cinddtmodified],
		0							 as [cinnlevelno],
		''							 as [cinsprimarylanguage],
		''							 as [cinsotherlanguage],
		''							 as [cinbdeathflag],
		''							 as [cinscitizenship],
		null + null					 as [cinsheight],
		null						 as [cinnweight],
		''							 as [cinsreligion],
		null						 as [cindmarriagedate],
		null						 as [cinsmarriageloc],
		null						 as [cinsdeathplace],
		''							 as [cinsmaidenname],
		''							 as [cinsoccupation],
		null						 as [saga],
		''							 as [cinsspouse],
		null						 as [cinsgrade],
		p.officer					 as [saga_char]
	from JoelBieberNeedles.[dbo].[police] p
	where ISNULL(officer, '') <> ''
go