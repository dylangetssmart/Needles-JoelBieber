/*


*/



-- Create individual contact for Relatives
-- from user_case_data
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
	select
		1									 as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from [dbo].[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)									 as [cinncontacttypeid],
		null								 as [cinncontactsubctgid],
		''									 as [cinsprefix],
		dbo.get_firstword(ucd.Relative_Name) as [cinsfirstname],
		''									 as [cinsmiddlename],
		dbo.get_lastword(ucd.Relative_Name)	 as [cinslastname],
		null								 as [cinssuffix],
		null								 as [cinsnickname],
		1									 as [cinbstatus],
		null								 as [cinsssnno],
		null								 as [cindbirthdate],
		null								 as [cinscomments],
		1									 as [cinncontactctg],
		''									 as [cinnrefbyctgid],
		''									 as [cinnreferredby],
		null								 as [cinddateofdeath],
		''									 as [cinscvlink],
		''									 as [cinnmaritalstatusid],
		1									 as [cinngender],
		''									 as [cinsbirthplace],
		1									 as [cinncountyid],
		1									 as [cinscountyofresidence],
		null								 as [cinbflagforphoto],
		null								 as [cinsprimarycontactno],
		ucd.Relative_Phone					 as [cinshomephone],
		''									 as [cinsworkphone],
		null								 as [cinsmobile],
		0									 as [cinbpreventmailing],
		368									 as [cinnrecuserid],
		GETDATE()							 as [cinddtcreated],
		''									 as [cinnmodifyuserid],
		null								 as [cinddtmodified],
		0									 as [cinnlevelno],
		''									 as [cinsprimarylanguage],
		''									 as [cinsotherlanguage],
		''									 as [cinbdeathflag],
		''									 as [cinscitizenship],
		null								 as [cinsheight],
		null								 as [cinnweight],
		''									 as [cinsreligion],
		null								 as [cindmarriagedate],
		null								 as [cinsmarriageloc],
		null								 as [cinsdeathplace],
		''									 as [cinsmaidenname],
		''									 as [cinsoccupation],
		ucd.casenum							 as [saga],
		''									 as [cinsspouse],
		null							 as [cinsgrade]
	from [JoelBieberNeedles].[dbo].user_case_data ucd
	where ISNULL(ucd.Relative_Name, '') <> ''
go


--
alter table [sma_MST_IndvContacts] enable trigger all
go
--
