/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual and organization contacts

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

use ShinerSA
go

alter table sma_MST_OrgContacts disable trigger all
go

---------------------------------------------------
-- [2.0] Organization Contacts
---------------------------------------------------

-- [2.1] "Litify Business" accounts
insert into sma_MST_OrgContacts
	(
	[conbPrimary],
	[connContactTypeID],
	[connContactSubCtgID],
	[consName],
	[conbStatus],
	[consEINNO],
	[consComments],
	[connContactCtg],
	[connRefByCtgID],
	[connReferredBy],
	[connContactPerson],
	[consWorkPhone],
	[conbPreventMailing],
	[connRecUserID],
	[condDtCreated],
	[connModifyUserID],
	[condDtModified],
	[connLevelNo],
	[consOtherName],
	[saga_char]
	)
	select
		1					as [conbprimary],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octnContactCtgID = 2
				and octsDscrptn = 'General'
		)					as [conncontacttypeid],
		''					as [conncontactsubctgid],
		LEFT(e.last_name_or_company_name, 512) as [consname], --100 
		1					as [conbstatus],
		null				as [conseinno],	--30
		ISNULL('Contact: ' + NULLIF((ISNULL(litify_pm__First_Name__c, '') + ' ' + ISNULL(litify_pm__Last_Name__c, '')), '') + CHAR(13), '') +
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR, c.[description]), '') + CHAR(13), '') +
		''					as [conscomments],
		2					as [conncontactctg],
		null				as [connrefbyctgid],
		null				as [connreferredby],
		null				as [conncontactperson],
		null				as [consworkphone],
		0					as [conbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.CreatedById
		)					as [connrecuserid],
		c.CreatedDate		as [conddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)					as [connmodifyuserid],
		c.LastModifiedDate  as [conddtmodified],
		0					as [connlevelno],
		null				as [consothername],
		e.[Id]				as [saga]
	--'account:LitifyBusiness' as [saga_ref]
	--Select max(len(name))

	from JoelBieber_GrowPath..entity e
	--left join cte_phone
	--	on cte_phone.entity_id = e.id
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
	where e.type = 'Company'


--from ShinerLitify..[Account] c
--left join ShinerLitify..Contact ct
--	on ct.AccountId = c.Id
--join ShinerLitify..RecordType rt
--	on c.RecordTypeId = LEFT(rt.Id, 15)
--		and rt.SobjectType = 'Account'
--left join sma_MST_OrgContacts org
--	on org.saga_char = c.Id
--where org.connContactID is null
--	and (rt.[Name] = 'Litify Business'
--	or (rt.[Name] = 'Litify Individual'
--	and ISNULL(litify_pm__Last_Name__c, '') = ''))
go

alter table sma_MST_OrgContacts enable trigger all