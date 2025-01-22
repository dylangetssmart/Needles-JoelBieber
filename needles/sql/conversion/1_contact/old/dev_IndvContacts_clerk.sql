/* ###################################################################################


don't need this script - would need this to create contacts from an alpha
*/

use JoelBieberSA_Needles
go

select
	ucd.CLERK
from JoelBieberNeedles..user_case_data ucd
where ISNULL(clerk, '') <> ''

--select * from JoelBieberSA_Needles..[sma_MST_OriginalContactTypes]

/* --------------------------------------------------------------------------------------------------------------
- Insert from [police]
*/

with cte_clerks
as
(
	select distinct
		names_id
	from JoelBieberNeedles..user_case_data ucd
	join JoelBieberNeedles..user_case_fields ucf
		on ucf.field_title = 'Clerk'
	join JoelBieberNeedles..user_case_name ucn
		on ucn.ref_num = ucf.field_num
		and ucd.casenum = ucn.casenum
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	where ISNULL(ucd.CLERK, '') <> ''

)
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
	[saga],
	[cinsSpouse],
	[cinsGrade],
	[saga_char]
	)
	select distinct
		1							 as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from [dbo].[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'Law Clerk'
		)							 as [cinncontacttypeid],
		null						 as [cinncontactsubctgid],
		''							 as [cinsprefix],
		dbo.get_firstword(ucd.CLERK) as [cinsfirstname],
		''							 as [cinsmiddlename],
		dbo.get_lastword(ucd.CLERK)	 as [cinslastname],
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
		n.names_id					 as [saga_char]
	from JoelBieberNeedles..names n
	LEFT join cte_clerks
	on n.names_id = cte_clerks.names_id


	select *
	from JoelBieberNeedles..user_case_data ucd
	join JoelBieberNeedles..user_case_fields ucf
		on ucf.field_title = 'Clerk'
	join JoelBieberNeedles..user_case_name ucn
		on ucn.ref_num = ucf.field_num
			and ucd.casenum = ucn.casenum
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	where ISNULL(ucd.CLERK, '') <> ''

	--from [JohnSalazar_Needles].[dbo].user_case_data ucd
	--where ISNULL(ucd.clerk, '') <> ''
go


select distinct
		ucd.casenum, ucd.clerk, ucn.casenum, ucn.user_name, n.names_id
	from JoelBieberNeedles..user_case_data ucd
	join JoelBieberNeedles..user_case_fields ucf
		on ucf.field_title = 'clerk'
	join JoelBieberNeedles..user_case_name ucn
		on ucn.ref_num = ucf.field_num
		and ucd.casenum = ucn.casenum
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	where ucd.clerk = 'Dean, Clerk, Bevill  M.'
	21326

--'Dean, Clerk, Bevill  M.'


SELECT *
FROM JoelBieberSA_Needles..sma_MST_IndvContacts smic
where saga = 21326


SELECT * FROM JoelBieberNeedles..names n where n.names_id = 18166