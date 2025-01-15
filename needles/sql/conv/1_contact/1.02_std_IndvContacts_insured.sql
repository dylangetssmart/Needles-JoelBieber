/* ###################################################################################
description: Handle all operations related to [sma_MST_IndvContacts]
steps:
	- insert from insurance
	- update bridge
usage_instructions:
	-
dependencies:
	- 
notes:
	-
source: [insurance]
target: [sma_MST_IndvContacts]
saga: saga_char
*/

use JoelBieberSA_Needles
go

alter table [sma_MST_IndvContacts] disable trigger all

/* --------------------------------------------------------------------------------------------------------------
- Insert from [insurance]
*/
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade], [saga_char]
	)
	select distinct
		1					  as [cinbprimary],
		10					  as [cinncontacttypeid],
		null				  as [cinncontactsubctgid],
		''					  as [cinsprefix],
		''					  as [cinsfirstname],
		''					  as [cinsmiddlename],
		LEFT(ins.insured, 40) as [cinslastname],
		null				  as [cinssuffix],
		null				  as [cinsnickname],
		1					  as [cinbstatus],
		null				  as [cinsssnno],
		null				  as [cindbirthdate],
		null				  as [cinscomments],
		1					  as [cinncontactctg],
		''					  as [cinnrefbyctgid],
		''					  as [cinnreferredby],
		null				  as [cinddateofdeath],
		''					  as [cinscvlink],
		''					  as [cinnmaritalstatusid],
		1					  as [cinngender],
		''					  as [cinsbirthplace],
		1					  as [cinncountyid],
		1					  as [cinscountyofresidence],
		null				  as [cinbflagforphoto],
		null				  as [cinsprimarycontactno],
		''					  as [cinshomephone],
		''					  as [cinsworkphone],
		null				  as [cinsmobile],
		0					  as [cinbpreventmailing],
		368					  as [cinnrecuserid],
		GETDATE()			  as [cinddtcreated],
		''					  as [cinnmodifyuserid],
		null				  as [cinddtmodified],
		0					  as [cinnlevelno],
		''					  as [cinsprimarylanguage],
		''					  as [cinsotherlanguage],
		''					  as [cinbdeathflag],
		''					  as [cinscitizenship],
		null + null			  as [cinsheight],
		null				  as [cinnweight],
		''					  as [cinsreligion],
		null				  as [cindmarriagedate],
		null				  as [cinsmarriageloc],
		null				  as [cinsdeathplace],
		''					  as [cinsmaidenname],
		''					  as [cinsoccupation],
		null				  as [saga],
		''					  as [cinsspouse],
		null				  as [cinsgrade],
		ins.insured			  as [saga_char]
	from [JoelBieberNeedles].[dbo].[insurance] ins
	where ISNULL(insured, '') <> ''
go

alter table [sma_MST_IndvContacts] enable trigger all