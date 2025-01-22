use JoelBieberSA_Needles
go

drop table [sma_MST_AllContactInfo]
go

/****** Object:  Table [dbo].[sma_MST_AllContactInfo]    Script Date: 9/9/2015 12:29:41 PM ******/
set ansi_nulls on
go

set quoted_identifier on
go

set ansi_padding on
go


--sp_help sma_mst_address
create table [dbo].[sma_MST_AllContactInfo] (
	[uId]			  [BIGINT]		  identity (1, 1) not null,
	[UniqueContactId] [BIGINT]		  not null,
	[ContactId]		  [BIGINT]		  not null,
	[ContactCtg]	  [TINYINT]		  not null,
	--[Name] [varchar](110) NULL,
	[Name]			  [VARCHAR](210)  null,
	[FirstName]		  [VARCHAR](100)  null,
	--[LastName] [varchar](90) NULL,
	[LastName]		  [VARCHAR](200)  null,
	[OtherName]		  [NVARCHAR](255) null,
	[AddressId]		  [BIGINT]		  null,
	--[Address1] [varchar](75) NULL,
	[Address1]		  [VARCHAR](100)  null,
	[Address2]		  [VARCHAR](150)  null,
	[Address3]		  [VARCHAR](75)	  null,
	[City]			  [VARCHAR](50)	  null,
	[State]			  [VARCHAR](20)	  null,
	--[Zip] [varchar](10) NULL,
	[Zip]			  [VARCHAR](20)	  null,
	[ContactNumber]	  [VARCHAR](80)	  null,
	[ContactEmail]	  [VARCHAR](255)  null,
	[ContactTypeId]	  [INT]			  null,
	[ContactType]	  [VARCHAR](50)	  null,
	[Comments]		  [VARCHAR](MAX)  null,
	[DateModified]	  [DATETIME]	  null,
	[ModifyUserId]	  [INT]			  null,
	[IsDeleted]		  [BIT]			  null,
	[NameForLetters]  [NVARCHAR](255) null,
	[DateOfBirth]	  [DATETIME]	  null,
	[SSNNo]			  [VARCHAR](100)  null,
	[County]		  [VARCHAR](50)	  null,
	[IsActive]		  [BIT]			  null,
	constraint [PK_sma_MST_AllContactInfo] primary key clustered
	(
	[uId] asc
	) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
) on [PRIMARY]

go

set ansi_padding off
go


delete from sma_MST_AllContactInfo
go

--insert org contacts

insert into [dbo].[sma_MST_AllContactInfo]
	(
	[UniqueContactId],
	[ContactId],
	[ContactCtg],
	[Name],
	[NameForLetters],
	[FirstName],
	[LastName],
	[OtherName],
	[AddressId],
	[Address1],
	[Address2],
	[Address3],
	[City],
	[State],
	[Zip],
	[ContactNumber],
	[ContactEmail],
	[ContactTypeId],
	[ContactType],
	[Comments],
	[DateModified],
	[ModifyUserId],
	[IsDeleted],
	[IsActive]
	)

	select
		CONVERT(BIGINT, ('2' + CONVERT(VARCHAR(30), sma_MST_OrgContacts.connContactID))) as uniquecontactid,
		CONVERT(BIGINT, sma_MST_OrgContacts.connContactID)								 as contactid,
		2																				 as contactctg,
		sma_MST_OrgContacts.consName													 as name,
		sma_MST_OrgContacts.consName,
		null																			 as firstname,
		null																			 as lastname,
		sma_MST_OrgContacts.consOtherName												 as othername,
		null																			 as addressid,
		null																			 as address1,
		null																			 as address2,
		null																			 as address3,
		null																			 as city,
		null																			 as state,
		null																			 as zip,
		null																			 as contactnumber,
		null																			 as contactemail,
		sma_MST_OrgContacts.connContactTypeID											 as contacttypeid,
		sma_MST_OriginalContactTypes.octsDscrptn										 as contacttype,
		sma_MST_OrgContacts.consComments												 as comments,
		GETDATE()																		 as datemodified,
		347																				 as modifyuserid,
		0																				 as isdeleted,
		[conbStatus]
	from sma_MST_OrgContacts
	left join sma_MST_OriginalContactTypes
		on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_OrgContacts.connContactTypeID
go

--insert individual contacts

insert into [dbo].[sma_MST_AllContactInfo]
	(
	[UniqueContactId],
	[ContactId],
	[ContactCtg],
	[Name],
	[NameForLetters],
	[FirstName],
	[LastName],
	[OtherName],
	[AddressId],
	[Address1],
	[Address2],
	[Address3],
	[City],
	[State],
	[Zip],
	[ContactNumber],
	[ContactEmail],
	[ContactTypeId],
	[ContactType],
	[Comments],
	[DateModified],
	[ModifyUserId],
	[IsDeleted],
	[DateOfBirth],
	[SSNNo],
	[IsActive]
	)

	select
		CONVERT(BIGINT, ('1' + CONVERT(VARCHAR(30), sma_MST_IndvContacts.cinnContactID))) as uniquecontactid,
		CONVERT(BIGINT, sma_MST_IndvContacts.cinnContactID)								  as contactid,
		1																				  as contactctg,
		case ISNULL(cinsLastName, '')
			when ''
				then ''
			else cinsLastName + ', '
		end +
		case ISNULL([cinsFirstName], '')
			when ''
				then ''
			else [cinsFirstName]
		end
		+
		case ISNULL(cinsMiddleName, '')
			when ''
				then ''
			else ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.'
		end
		+
		case ISNULL(cinsSuffix, '')
			when ''
				then ''
			else ', ' + cinsSuffix
		end																				  as name,
		case ISNULL([cinsFirstName], '')
			when ''
				then ''
			else [cinsFirstName]
		end
		+
		case ISNULL(cinsMiddleName, '')
			when ''
				then ''
			else ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.'
		end
		+
		case ISNULL(cinsLastName, '')
			when ''
				then ''
			else ' ' + cinsLastName
		end
		+
		case ISNULL(cinsSuffix, '')
			when ''
				then ''
			else ', ' + cinsSuffix
		end																				  as [nameforletters],

		ISNULL(sma_MST_IndvContacts.cinsFirstName, '')									  as firstname,
		ISNULL(sma_MST_IndvContacts.cinsLastName, '')									  as lastname,
		ISNULL(sma_MST_IndvContacts.cinsNickName, '')									  as othername,
		null																			  as addressid,
		null																			  as address1,
		null																			  as address2,
		null																			  as address3,
		null																			  as city,
		null																			  as state,
		null																			  as zip,
		null																			  as contactnumber,
		null																			  as contactemail,
		sma_MST_IndvContacts.cinnContactTypeID											  as contacttypeid,
		sma_MST_OriginalContactTypes.octsDscrptn										  as contacttype,
		sma_MST_IndvContacts.cinsComments												  as comments,
		GETDATE()																		  as datemodified,
		347																				  as modifyuserid,
		0																				  as isdeleted,
		[cindBirthDate],
		[cinsSSNNo],
		[cinbStatus]
	from sma_MST_IndvContacts
	left join sma_MST_OriginalContactTypes
		on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_IndvContacts.cinnContactTypeID

go

--fill out address information for all contact types
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = Addrr.addsAddress1,
	[Address2] = Addrr.addsAddress2,
	[Address3] = Addrr.addsAddress3,
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
from sma_MST_AllContactInfo allinfo
inner join sma_MST_Address addrr
	on (allinfo.ContactId = addrr.addnContactID)
	and (allinfo.ContactCtg = addrr.addnContactCtgID)
go

--fill out address information for all contact types, overwriting with primary addresses
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = Addrr.addsAddress1,
	[Address2] = Addrr.addsAddress2,
	[Address3] = Addrr.addsAddress3,
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
from sma_MST_AllContactInfo allinfo
inner join sma_MST_Address addrr
	on (allinfo.ContactId = addrr.addnContactID)
	and (allinfo.ContactCtg = addrr.addnContactCtgID)
	and addrr.addbPrimary = 1
go

--fill out email information
update [dbo].[sma_MST_AllContactInfo]
set [ContactEmail] = Email.cewsEmailWebSite
from sma_MST_AllContactInfo allinfo
inner join sma_MST_EmailWebsite email
	on (allinfo.ContactId = email.cewnContactID)
	and (allinfo.ContactCtg = email.cewnContactCtgID)
	and email.cewsEmailWebsiteFlag = 'E'
go

--fill out default email information
update [dbo].[sma_MST_AllContactInfo]
set [ContactEmail] = Email.cewsEmailWebSite
from sma_MST_AllContactInfo allinfo
inner join sma_MST_EmailWebsite email
	on (allinfo.ContactId = email.cewnContactID)
	and (allinfo.ContactCtg = email.cewnContactCtgID)
	and email.cewsEmailWebsiteFlag = 'E'
	and email.cewbDefault = 1
go

--fill out phone information
update [dbo].[sma_MST_AllContactInfo]
set ContactNumber = Phones.cnnsContactNumber + (case
	when Phones.[cnnsExtension] is null
		then ''
	when Phones.[cnnsExtension] = ''
		then ''
	else ' x' + Phones.[cnnsExtension] + ''
end)
from sma_MST_AllContactInfo allinfo
inner join sma_MST_ContactNumbers phones
	on (allinfo.ContactId = phones.cnnnContactID)
	and (allinfo.ContactCtg = phones.cnnnContactCtgID)
go

--fill out default phone information
update [dbo].[sma_MST_AllContactInfo]
set ContactNumber = Phones.cnnsContactNumber + (case
	when Phones.[cnnsExtension] is null
		then ''
	when Phones.[cnnsExtension] = ''
		then ''
	else ' x' + Phones.[cnnsExtension] + ''
end)
from sma_MST_AllContactInfo allinfo
inner join sma_MST_ContactNumbers phones
	on (allinfo.ContactId = phones.cnnnContactID)
	and (allinfo.ContactCtg = phones.cnnnContactCtgID)
	and phones.cnnbPrimary = 1
go

go

delete from [sma_MST_ContactTypesForContact]
insert into [sma_MST_ContactTypesForContact]
	(
	[ctcnContactCtgID],
	[ctcnContactID],
	[ctcnContactTypeID],
	[ctcnRecUserID],
	[ctcdDtCreated]
	)
	select distinct
		advnSrcContactCtg,
		advnSrcContactID,
		71,
		368,
		GETDATE()
	from sma_TRN_PdAdvt
	union
	select distinct
		2,
		lwfnLawFirmContactID,
		9,
		368,
		GETDATE()
	from sma_TRN_LawFirms
	union
	select distinct
		1,
		lwfnAttorneyContactID,
		7,
		368,
		GETDATE()
	from sma_TRN_LawFirms
	union
	select distinct
		2,
		incnInsContactID,
		11,
		368,
		GETDATE()
	from sma_TRN_InsuranceCoverage
	union
	select distinct
		1,
		incnAdjContactId,
		8,
		368,
		GETDATE()
	from sma_TRN_InsuranceCoverage
	union
	select distinct
		1,
		pornPOContactID,
		86,
		368,
		GETDATE()
	from sma_TRN_PoliceReports
	union
	select distinct
		1,
		usrncontactid,
		44,
		368,
		GETDATE()
	from sma_mst_users
go

go

/****** Object:  Index [UniqueContactId]    Script Date: 9/21/2015 12:46:06 PM ******/
create nonclustered index [UniqueContactId] on [dbo].[sma_MST_AllContactInfo]
(
[UniqueContactId] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [NonClusteredIndex-20141119-152835]    Script Date: 9/21/2015 12:45:52 PM ******/
create nonclustered index [NonClusteredIndex-20141119-152835] on [dbo].[sma_MST_AllContactInfo]
(
[UniqueContactId] asc,
[ContactId] asc,
[ContactCtg] asc,
[Name] asc,
[IsDeleted] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [index_Zip]    Script Date: 9/21/2015 12:45:38 PM ******/
create nonclustered index [index_Zip] on [dbo].[sma_MST_AllContactInfo]
(
[Zip] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [index_State]    Script Date: 9/21/2015 12:45:17 PM ******/
create nonclustered index [index_State] on [dbo].[sma_MST_AllContactInfo]
(
[State] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [index_Name_UID]    Script Date: 9/21/2015 12:45:00 PM ******/
create nonclustered index [index_Name_UID] on [dbo].[sma_MST_AllContactInfo]
(
[Name] asc,
[UniqueContactId] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [index_ContactTypeId]    Script Date: 9/21/2015 12:44:40 PM ******/
create nonclustered index [index_ContactTypeId] on [dbo].[sma_MST_AllContactInfo]
(
[ContactTypeId] asc,
[ContactId] asc,
[ContactCtg] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [index_ContactCtg]    Script Date: 9/21/2015 12:44:20 PM ******/
create nonclustered index [index_ContactCtg] on [dbo].[sma_MST_AllContactInfo]
(
[ContactCtg] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [index_City]    Script Date: 9/21/2015 12:44:03 PM ******/
create nonclustered index [index_City] on [dbo].[sma_MST_AllContactInfo]
(
[City] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [IDX_ContactID_CTG]    Script Date: 9/21/2015 12:43:35 PM ******/
create nonclustered index [IDX_ContactID_CTG] on [dbo].[sma_MST_AllContactInfo]
(
[ContactId] asc,
[ContactCtg] asc
)
include ([NameForLetters]) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [ContactTypeIndex]    Script Date: 9/21/2015 12:43:17 PM ******/
create nonclustered index [ContactTypeIndex] on [dbo].[sma_MST_AllContactInfo]
(
[ContactType] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [CategoryId_ContactId]    Script Date: 9/21/2015 12:42:59 PM ******/
create nonclustered index [CategoryId_ContactId] on [dbo].[sma_MST_AllContactInfo]
(
[ContactCtg] asc,
[ContactId] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go



go

/****** Object:  Index [AddressId]    Script Date: 9/21/2015 12:42:53 PM ******/
create nonclustered index [AddressId] on [dbo].[sma_MST_AllContactInfo]
(
[AddressId] asc
) with (pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 100) on [PRIMARY]
go

