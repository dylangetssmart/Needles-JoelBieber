/*
sma_MST_IndvContacts
sma_MST_Address


todo:
stamp saga
stamp source_id1

saga = party_id
sourceid1 = case_id -> use for [AllContactInfo]
sourceid2
sourceid3

*/


--select
--	*
--from JoelBieberNeedles..user_party_data upd

/*
user_party_data > user_party_name > names
*/

--select top 5
--	upd.case_id,
--	upd.party_id,
--	upd.Relative_Name
--from JoelBieberNeedles..user_party_data upd
--where ISNULL(upd.Relative_Name, '') <> ''
--select
--	*
--from JoelBieberNeedles..user_party_name upn

--select
--	*
--from JoelBieberNeedles..names n
--where n.names_id = 28916

--select
--	casenum,
--	ucd.Relative_Name
--from JoelBieberNeedles..user_case_data ucd
--where ISNULL(ucd.Relative_Name, '') <> ''
--select
--	*
--from JoelBieberNeedles..user_case_fields ucf
--where ucf.field_title like '%relative name%'
--select
--	*
--from JoelBieberNeedles..user_case_name

---- user case

--select top 2
--	casenum,
--	ucd.Relative_Name
--from JoelBieberNeedles..user_case_data ucd
--where ISNULL(ucd.Relative_Name, '') <> ''
--select
--	*
--from JoelBieberNeedles..user_case_fields ucf
--where ucf.field_title like '%relative name%'
--select
--	*
--from JoelBieberNeedles..user_case_name
--select
--	*
--from JoelBieberNeedles..user_case_matter ucm
--where ucm.field_title like '%relative name%'


---- user party

--select
--	*
--from JoelBieberNeedles..user_party_data
--select
--	*
--from JoelBieberNeedles..user_party_name upn
--select
--	*
--from JoelBieberNeedles..user_case_name

use JoelBieberSA_Needles
go

--
alter table [sma_MST_IndvContacts] disable trigger all
go

alter table [sma_MST_Address] disable trigger all
go


/* --------------------------------------------------------------------------------------------------------------
user_case_data
	- insert ind contact
	- insert address
*/


-- Create individual contact for Relatives
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




/* --------------------------------------------------------------------------------------------------------------
user_party_data
	- insert ind contact
	- insert address
*/

-- Create CTE for all relevant data from [needles].[user_party_data]
-- sa_contact_id: user_party_data > user_party_name > names.names_id
with cte_user_party_relative
as
(
	-- user_party_data.relative_name
	select distinct
		upd.party_id as party_id,
		upd.case_id as case_id,
		upd.Relative_Name as relative_name,
		upd.Relative_Phone as relative_phone,
		upd.Relative_Address as relative_address,
		upd.Relative_City as relative_city,
		upd.Relative_State as relative_state,
		upd.Relative_Zip as relative_zip
	from JoelBieberNeedles..user_party_data upd
	where ISNULL(upd.Relative_Name, '') <> ''

	union all

	-- user_party_data.relative
	select distinct
		upd.party_id as party_id,
		upd.case_id as case_id,
		upd.Relative as relative_name,
		upd.Relative_Phone as relative_phone,
		upd.Relative_Address as relative_address,
		upd.Relative_City as relative_city,
		upd.Relative_State as relative_state,
		upd.Relative_Zip as relative_zip
	from JoelBieberNeedles..user_party_data upd
	where ISNULL(upd.Relative, '') <> ''
)

-- Validate record count
--SELECT distinct upd.Relative FROM JoelBieberNeedles..user_party_data upd
--where isnull(upd.Relative,'')<>''

--SELECT distinct upd.Relative_name FROM JoelBieberNeedles..user_party_data upd
--where isnull(upd.Relative_Name,'')<>''

--SELECT * FROM cte_user_party_relative

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
		dbo.get_firstword(cte_relative_name) as [cinsfirstname],
		''									 as [cinsmiddlename],
		dbo.get_lastword(cte_relative_name)	 as [cinslastname],
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
		cte.relative_phone					 as [cinshomephone],
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
		null								 as [cinsoccupation],
		cte.party_id						 as [saga],
		''									 as [cinsspouse],
		''									 as [cinsgrade],
		cte.case_id							 as [saga_char]
	from cte_user_party_relative cte
go


-------------------------------------------------------------------
-- ADDRESS


insert into [sma_MST_Address]
	(
	[addnContactCtgID],
	[addnContactID],
	[addnAddressTypeID],
	[addsAddressType],
	[addsAddTypeCode],
	[addsAddress1],
	[addsAddress2],
	[addsAddress3],
	[addsStateCode],
	[addsCity],
	[addnZipID],
	[addsZip],
	[addsCounty],
	[addsCountry],
	[addbIsResidence],
	[addbPrimary],
	[adddFromDate],
	[adddToDate],
	[addnCompanyID],
	[addsDepartment],
	[addsTitle],
	[addnContactPersonID],
	[addsComments],
	[addbIsCurrent],
	[addbIsMailing],
	[addnRecUserID],
	[adddDtCreated],
	[addnModifyUserID],
	[adddDtModified],
	[addnLevelNo],
	[caseno],
	[addbDeleted],
	[addsZipExtn],
	[saga]
	)
	select
		i.cinnContactCtg as addncontactctgid,
		i.cinnContactID	 as addncontactid,
		t.addnAddTypeID	 as addnaddresstypeid,
		t.addsDscrptn	 as addsaddresstype,
		t.addsCode		 as addsaddtypecode,
		cte.[address]	 as addsaddress1,
		null			 as addsaddress2,
		null			 as addsaddress3,
		cte.[state]		 as addsstatecode,
		cte.[city]		 as addscity,
		null			 as addnzipid,
		cte.[zipcode]	 as addszip,
		null			 as addscounty,
		null			 as addscountry,
		null			 as addbisresidence,
		1				 as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		null			 as [addscomments],
		null,
		null,
		368				 as addnrecuserid,
		GETDATE()		 as addddtcreated,
		368				 as addnmodifyuserid,
		GETDATE()		 as addddtmodified,
		null,
		null,
		null,
		null,
		null
	from cte_user_party_relative cte
	join [sma_MST_Indvcontacts] i
		on i.saga = cte.party_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'HM'
	where ISNULL(cte.address, '') <> ''
		or ISNULL(cte.city, '') <> ''
		or ISNULL(cte.state, '') <> ''
		or ISNULL(cte.Zip, '') <> ''

-------------------------------------------------------------------
-- TRIGGERS

alter table [sma_MST_IndvContacts] enable trigger all
go

alter table [sma_MST_Address] enable trigger all
go