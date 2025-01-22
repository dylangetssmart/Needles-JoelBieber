




with cte_user_case_plaintiff_defendant
as
(
	-- user_case_data.plaintiff
	select distinct
		ucd.casenum as casenum,
		ucd.PLAINTIFF as contact_name,
		'P' as plaintiff_or_defendant
	from JoelBieberNeedles..user_case_data ucd
	where ISNULL(ucd.PLAINTIFF, '') <> ''

	union all

	-- user_case_data.defendant
	select distinct
		ucd.casenum as casenum,
		ucd.DEFENDANT as contact_name,
		'D' as plaintiff_or_defendant
	from JoelBieberNeedles..user_case_data ucd
	where ISNULL(ucd.DEFENDANT, '') <> ''
)

-------------------------------------------------------------------
-- Insert Individual Contacts
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
	[source_id],
	[source_db],
	[source_ref]
	)
	select
		1									as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from [dbo].[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)									as [cinncontacttypeid],
		null								as [cinncontactsubctgid],
		''									as [cinsprefix],
		dbo.get_firstword(cte.contact_name) as [cinsfirstname],
		''									as [cinsmiddlename],
		dbo.get_lastword(cte.contact_name)  as [cinslastname],
		null								as [cinssuffix],
		null								as [cinsnickname],
		1									as [cinbstatus],
		null								as [cinsssnno],
		null								as [cindbirthdate],
		null								as [cinscomments],
		1									as [cinncontactctg],
		''									as [cinnrefbyctgid],
		''									as [cinnreferredby],
		null								as [cinddateofdeath],
		''									as [cinscvlink],
		''									as [cinnmaritalstatusid],
		1									as [cinngender],
		''									as [cinsbirthplace],
		1									as [cinncountyid],
		1									as [cinscountyofresidence],
		null								as [cinbflagforphoto],
		null								as [cinsprimarycontactno],
		null								as [cinshomephone],
		''									as [cinsworkphone],
		null								as [cinsmobile],
		0									as [cinbpreventmailing],
		368									as [cinnrecuserid],
		GETDATE()							as [cinddtcreated],
		''									as [cinnmodifyuserid],
		null								as [cinddtmodified],
		0									as [cinnlevelno],
		''									as [cinsprimarylanguage],
		''									as [cinsotherlanguage],
		''									as [cinbdeathflag],
		''									as [cinscitizenship],
		null								as [cinsheight],
		null								as [cinnweight],
		''									as [cinsreligion],
		null								as [cindmarriagedate],
		null								as [cinsmarriageloc],
		null								as [cinsdeathplace],
		''									as [cinsmaidenname],
		null								as [cinsoccupation],
		''									as [cinsspouse],
		''									as [cinsgrade],
		cte.casenum							as [saga],
		case
			when cte.plaintiff_or_defendant = 'P'
				then 'P'
			when cte.plaintiff_or_defendant = 'D'
				then 'D'
			else null
		end									as [source_id],
		'needles'							as [source_db],
		'cte_user_case_plaintiff_defendant' as [source_ref]	
	from cte_user_case_plaintiff_defendant cte
go