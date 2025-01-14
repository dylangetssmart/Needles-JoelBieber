/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts from [account]

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

select
	*
from JoelBieber_GrowPath..contact c

select
	e.id,
	e.first_name,
	p.number,
	p.phone_type_id,
	lb.type,
	lb.name
from JoelBieber_GrowPath..entity e
join JoelBieber_GrowPath..phone p
	on p.entity_id = e.id
join JoelBieber_GrowPath..lookup_bucket lb
	on lb.id = p.phone_type_id

---------------------------------------------------
-- [1.0] Individual Contacts
---------------------------------------------------
alter table [sma_MST_IndvContacts] disable trigger all
go


---------------------------------------
-- Construct [sma_MST_IndvContacts] from dbo.entity
---------------------------------------
with cte_phone
as
(
	select
		e.id as entity_id,
		case
			when lpg.type = 'Work'
				then p.number
			else null
		end as work_phone,
		case
			when lpg.type = 'Home'
				then p.number
			else null
		end as home_phone,
		case
			when lpg.type = 'Cell' or
				lpg.type = 'Mobile'
				then p.number
			else null
		end as cell_phone
	from JoelBieber_GrowPath..entity e
	join JoelBieber_GrowPath..phone p
		on p.entity_id = e.id
	join JoelBieber_GrowPath..lookup_bucket lpg
		on lpg.id = p.phone_type_id
	where e.type = 'Person'
)
insert into [sma_MST_IndvContacts]
	(
	[cinsPrefix],
	[cinsSuffix],
	[cinsFirstName],
	[cinsMiddleName],
	[cinsLastName],
	[cinsHomePhone],
	[cinsWorkPhone],
	[cinsSSNNo],
	[cindBirthDate],
	[cindDateOfDeath],
	[cinnGender],
	[cinsMobile],
	[cinsComments],
	[cinnContactCtg],
	[cinnContactTypeID],
	[cinnContactSubCtgID],
	[cinnRecUserID],
	[cindDtCreated],
	[cinbStatus],
	[cinbPreventMailing],
	[cinsNickName],
	[cinsPrimaryLanguage],
	[cinsOtherLanguage],
	[cinnRace],
	[saga],
	[saga_db],
	[saga_ref]
	)
	select
		LEFT(e.prefix, 20)								  as [cinsprefix],
		LEFT(e.suffix, 10)								  as [cinssuffix],
		CONVERT(VARCHAR(30), e.first_name)				  as [cinsfirstname],
		CONVERT(VARCHAR(30), e.middle_name)				  as [cinsmiddlename],
		CONVERT(VARCHAR(40), e.last_name_or_company_name) as [cinslastname],
		LEFT(cte_phone.home_phone, 20)					  as [cinshomephone],
		LEFT(cte_phone.work_phone, 20)					  as cinsworkphone,
		null											  as [cinsssnno],
		case
			when (e.date_of_birth not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else e.date_of_birth
		end												  as [cindbirthdate],
		case
			when (e.date_of_death not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else e.date_of_death
		end												  as [cinddateofdeath],
		case
			when lbg.name = 'M'
				then 1
			when lbg.name = 'F'
				then 2
			else 0
		end												  as [cinngender],
		LEFT(cte_phone.cell_phone, 20)					  as [cinsmobile],
		null											  as [cinscomments],
		1												  as [cinncontactctg],
		(
			select
				octnOrigContactTypeID
			from [sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)												  as [cinncontacttypeid],
		case
			-- if names.deceased = "Y", then grab the contactSubCategoryID for "Deceased"
			when ISNULL(e.date_of_death, '') <> ''
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Deceased'
					)
			-- if incapacitated = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Incompetent"
			--when exists (
			--	select *
			--	from [TestNeedles].[dbo].[party_Indexed] P
			--	where P.party_id=N.names_id and P.incapacitated='Y'
			--) then (
			--	select cscnContactSubCtgID
			--	from [sma_MST_ContactSubCategory]
			--	where cscsDscrptn='Incompetent'
			--)
			-- if minor = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Infant"
			-- otherwise, grab the contactSubCategoryID for "Adult"
			--when exists (
			--	select *
			--	from [TestNeedles].[dbo].[party_Indexed] P
			--	where P.party_id=N.names_id and P.minor='Y'
			--) then (
			--	select cscnContactSubCtgID
			--	from [sma_MST_ContactSubCategory]
			--	where cscsDscrptn='Infant'
			--	)
			else (
					select
						cscnContactSubCtgID
					from [sma_MST_ContactSubCategory]
					where cscsDscrptn = 'Adult'
				)
		end												  as cinncontactsubctgid,
		368												  as cinnrecuserid,
		GETDATE()										  as cinddtcreated,
		1												  as [cinbstatus],			-- Hardcode Status as ACTIVE 
		0												  as [cinbpreventmailing],
		null											  as [cinsnickname],
		null											  as [cinsprimarylanguage],
		null											  as [cinsotherlanguage],
		lbr.name										  as cinnrace,
		e.id											  as saga,
		'GP'											  as saga_db,
		'entity'										  as saga_ref
	from JoelBieber_GrowPath..entity e
	left join cte_phone
		on cte_phone.entity_id = e.id
	-- Race
	join JoelBieber_GrowPath..lookup_bucket lbr
		on lbr.id = e.race_id
	-- Gender
	join JoelBieber_GrowPath..lookup_bucket lbg
		on lbg.id = e.gender_id
	join JoelBieber_GrowPath..marital_status ms
		on ms.id = e.marital_status_id
	-- cte_phone
	join JoelBieber_GrowPath..phone p
		on p.entity_id = e.id
	join JoelBieber_GrowPath..lookup_bucket lbp
		on lbp.id = p.phone_type_id
	where e.type = 'Person'

go

alter table sma_MST_IndvContacts enable trigger all