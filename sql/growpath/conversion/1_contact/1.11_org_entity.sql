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
	[conbPrimary], [connContactTypeID], [connContactSubCtgID], [consName], [conbStatus], [consEINNO], [consComments], [connContactCtg], [connRefByCtgID], [connReferredBy], [connContactPerson], [consWorkPhone], [conbPreventMailing], [connRecUserID], [condDtCreated], [connModifyUserID], [condDtModified], [connLevelNo], [consOtherName], [saga_char]
	)
	select
		1						 as [conbprimary],
		case
			when c.[Type] = 'Court'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Court'
					)
			when c.[Type] = 'Insurance Company'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Insurance Company'
					)
			when c.[Type] in ('Health Care Facility', 'Medical Provider', 'Doctor')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Hospital'
					)
			when c.[Type] in ('Attorney', 'Law Firm', 'Co-Counsel')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Law Firm'
					)
			when c.[Type] = 'Pharmacy'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Pharmacy'
					)
			-- ds 2024-10-02
			when c.[Type] in ('Police', 'Police Department')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Police'
					)
			else (
					select
						octnOrigContactTypeID
					from sma_MST_OriginalContactTypes
					where octnContactCtgID = 2
						and octsDscrptn = 'General'
				)
		end						 as [conncontacttypeid],
		''						 as [conncontactsubctgid],
		LEFT(c.[Name], 110)		 as [consname], --100 
		1						 as [conbstatus],
		null					 as [conseinno],	--30
		ISNULL('Contact: ' + NULLIF((ISNULL(litify_pm__First_Name__c, '') + ' ' + ISNULL(litify_pm__Last_Name__c, '')), '') + CHAR(13), '') +
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR, c.[Description]), '') + CHAR(13), '') +
		''						 as [conscomments],
		2						 as [conncontactctg],
		null					 as [connrefbyctgid],
		null					 as [connreferredby],
		null					 as [conncontactperson],
		null					 as [consworkphone],
		0						 as [conbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.CreatedById
		)						 as [connrecuserid],
		c.CreatedDate			 as [conddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)						 as [connmodifyuserid],
		c.LastModifiedDate		 as [conddtmodified],
		0						 as [connlevelno],
		null					 as [consothername],
		c.[Id]					 as [saga_char]
		--'account:LitifyBusiness' as [saga_ref]
	--Select max(len(name))
	from ShinerLitify..[Account] c
	left join ShinerLitify..Contact ct
		on ct.AccountId = c.Id
	join ShinerLitify..RecordType rt
		on c.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_MST_OrgContacts org
		on org.saga_char = c.Id
	where org.connContactID is null
		and (rt.[Name] = 'Litify Business'
		or (rt.[Name] = 'Litify Individual'
		and ISNULL(litify_pm__Last_Name__c, '') = ''))
go

alter table sma_MST_OrgContacts enable trigger all