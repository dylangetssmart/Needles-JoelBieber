/* ###################################################################################
description: Update contact phone numbers
steps:
	-
usage_instructions:
	-
dependencies:
	- 
notes:
	-
######################################################################################
*/

use [JohnSalazar_SA]
go

---
alter table [sma_MST_ContactNumbers] disable trigger all
---

-- Home Phone
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			as cnnncontactctgid,
		c.cinnContactID				as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Primary Phone'
				and ctynContactCategoryID = 1
		)							as cnnnphonetypeid   -- Home Phone 
		,
		dbo.FormatPhone(home_phone) as cnnscontactnumber,
		home_ext					as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Home Phone'				as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(n.home_phone, '') <> ''


-- Work Phone
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			as cnnncontactctgid,
		c.cinnContactID				as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Work Phone'
				and ctynContactCategoryID = 1
		)							as cnnnphonetypeid,
		dbo.FormatPhone(work_phone) as cnnscontactnumber,
		work_extension				as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Work Phone'				as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(work_phone, '') <> ''


-- Cell Phone
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg		   as cnnncontactctgid,
		c.cinnContactID			   as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Cell Phone'
				and ctynContactCategoryID = 1
		)						   as cnnnphonetypeid,
		dbo.FormatPhone(car_phone) as cnnscontactnumber,
		car_ext					   as cnnsextension,
		1						   as cnnbprimary,
		null					   as cnnbvisible,
		a.addnAddressID			   as cnnnaddressid,
		'Mobile Phone'			   as cnnslabelcaption,
		368						   as cnnnrecuserid,
		GETDATE()				   as cnnddtcreated,
		368						   as cnnnmodifyuserid,
		GETDATE()				   as cnnddtmodified,
		null					   as cnnnlevelno,
		null					   as caseno
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(car_phone, '') <> ''


-- Home Primary Fax
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			as cnnncontactctgid,
		c.cinnContactID				as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Primary Fax'
				and ctynContactCategoryID = 1
		)							as cnnnphonetypeid,
		dbo.FormatPhone(fax_number) as cnnscontactnumber,
		fax_ext						as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Fax'						as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(fax_number, '') <> ''


-- Home Vacation Phone
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			   as cnnncontactctgid,
		c.cinnContactID				   as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Vacation Phone'
				and ctynContactCategoryID = 1
		)							   as cnnnphonetypeid,
		dbo.FormatPhone(beeper_number) as cnnscontactnumber,
		beeper_ext					   as cnnsextension,
		1							   as cnnbprimary,
		null						   as cnnbvisible,
		a.addnAddressID				   as cnnnaddressid,
		'Pager'						   as cnnslabelcaption,
		368							   as cnnnrecuserid,
		GETDATE()					   as cnnddtcreated,
		368							   as cnnnmodifyuserid,
		GETDATE()					   as cnnddtmodified,
		null						   as cnnnlevelno,
		null						   as caseno
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(beeper_number, '') <> ''

---

--- 

----------------------
---(Other phones for Individual)--
--(1)-- 
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Vacation Phone'
				and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone1) as cnnscontactnumber,
		other1_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title1				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(n.other_phone1, '') <> ''


--(2)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Vacation Phone'
				and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone2) as cnnscontactnumber,
		other2_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title2				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(n.other_phone2, '') <> ''

--(3)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Vacation Phone'
				and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone3) as cnnscontactnumber,
		other3_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title3				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(n.other_phone3, '') <> ''


--(4)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Vacation Phone'
				and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone4) as cnnscontactnumber,
		other4_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title4				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(n.other_phone4, '') <> ''


--(5)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Home Vacation Phone'
				and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone5) as cnnscontactnumber,
		other5_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title5				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where ISNULL(n.other_phone5, '') <> ''



	UPDATE [sma_MST_ContactNumbers] set cnnbPrimary=0
FROM (
	SELECT 
		ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
		cnnnContactNumberID as ContactNumberID  
	FROM [sma_MST_ContactNumbers] 
	WHERE cnnnContactCtgID = (select ctgnCategoryID FROM [dbo].[sma_MST_ContactCtg] where ctgsDesc='Individual')
) A
WHERE A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID


alter table [sma_MST_ContactNumbers] enable trigger all