use sa
go


--select
--	*
--from JoelBieberNeedles..value_indexed v
--join JoelBieberSA_Needles..sma_TRN_Cases cas
--on cas.cassCaseNumber = convert(varchar,v.case_id)
--where code in ('INT')
--and cas.casdOpeningDate > '2010-01-01 00:00:00.000'

--SELECT * FROM JoelBieberNeedles..value_Indexed v where v.case_id = 213595 and code in ('INT')


/* ##############################################
Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [source_ref] VARCHAR(MAX) null;
end
go

/* ##############################################
Create temporary table to hold disbursement value codes
*/
if OBJECT_ID('tempdb..#DisbursementValueCodes') is not null
	drop table #DisbursementValueCodes;

create table #DisbursementValueCodes (
	code VARCHAR(10)
);

insert into #DisbursementValueCodes
	(
	code
	)
values (
'INT'
)


-- Use this to create custom CheckRequestStatuses
insert into [sma_MST_CheckRequestStatus]
	(
	[description]
	)
	select
		'Interest'
	except
	select
		[description]
	from [sma_MST_CheckRequestStatus]



insert into [sma_MST_DisbursmentType]
	(
	disnTypeCode, dissTypeName
	)
	(
	select distinct
		'CONVERSION',
		vc.[description]
	from [JoelBieberNeedles].[dbo].[value] v
	join [JoelBieberNeedles].[dbo].[value_code] vc
		on vc.code = v.code
	where ISNULL(v.code, '') in (
			select
				code
			from #DisbursementValueCodes
		))
	except
	select
		'CONVERSION',
		dissTypeName
	from [sma_MST_DisbursmentType]

/* --------------------------------------------------------------------------------------------------------------
Create Disbursement helper table
*/

if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_Disbursement_Helper'
			and type = 'U'
	)
begin
	drop table value_tab_Disbursement_Helper
end
go

create table value_tab_Disbursement_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   INT,
	value_id	   INT,
	ProviderNameId INT,
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	ProviderUID	   BIGINT,
	casnCaseID	   INT,
	PlaintiffID	   INT,
	constraint IOC_Clustered_Index_value_tab_Disbursement_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_Disbursement_Helper_case_id on [value_tab_Disbursement_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_Disbursement_Helper_value_id on [value_tab_Disbursement_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_Disbursement_Helper_ProviderNameId on [value_tab_Disbursement_Helper] (ProviderNameId);
go

---(0)---
insert into value_tab_Disbursement_Helper
	(
	case_id, value_id, ProviderNameId, ProviderName, ProviderCID, ProviderCTG, ProviderAID, ProviderUID, casnCaseID, PlaintiffID
	)
	select
		v.case_id	   as case_id,	        -- needles case
		v.value_id	   as tab_id,		    -- needles records TAB item
		v.provider	   as providernameid,
		ioc.Name	   as providername,
		ioc.CID		   as providercid,
		ioc.CTG		   as providerctg,
		ioc.AID		   as provideraid,
		ioc.UNQCID	   as provideruid,
		cas.casncaseid as casncaseid,
		null		   as plaintiffid
	from [JoelBieberNeedles].[dbo].[value_Indexed] v
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = v.provider
			and ISNULL(v.provider, 0) <> 0
	where code in (
			select
				code
			from #DisbursementValueCodes
		);
go

---(0)---
dbcc dbreindex ('value_tab_Disbursement_Helper', ' ', 90) with no_infomsgs
go


---(0)--- value_id may associate with secondary plaintiff
if exists (
		select
			*
		from sys.objects
		where Name = 'value_tab_Multi_Party_Helper_Temp'
	)
begin
	drop table value_tab_Multi_Party_Helper_Temp
end
go

select
	v.case_id  as cid,
	v.value_id as vid,
	t.plnnplaintiffid
into value_tab_Multi_Party_Helper_Temp
from [JoelBieberNeedles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
join IndvOrgContacts_Indexed ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.cid
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID

update value_tab_Disbursement_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.CID
and value_id = a.vid
go

---(0)--- value_id may associate with defendant. steve malman make it associates to primary plaintiff 
if exists (
		select
			*
		from sys.objects
		where Name = 'value_tab_Multi_Party_Helper_Temp'
	)
begin
	drop table value_tab_Multi_Party_Helper_Temp
end
go

select
	v.case_id  as cid,
	v.value_id as vid,
	(
		select
			plnnplaintiffid
		from sma_TRN_Plaintiff
		where plnnCaseID = cas.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnplaintiffid
into value_tab_Multi_Party_Helper_Temp
from [JoelBieberNeedles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.cid
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go

update value_tab_Disbursement_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.CID
and value_id = a.vid
go


/* --------------------------------------------------------------------------------------------------------------
Create Disbursements
*/

alter table [sma_TRN_Disbursement] disable trigger all
go

insert into [sma_TRN_Disbursement]
	(
	disnCaseID, disdCheckDt, disnPayeeContactCtgID, disnPayeeContactID, disnAmount, disnPlaintiffID, dissDisbursementType, UniquePayeeID, dissDescription, dissComments, disnCheckRequestStatus, disdBillDate, disdDueDate, disnRecUserID, disdDtCreated, disnRecoverable, saga, source_id, source_db, source_ref
	)
	select
		map.casnCaseID					   as disncaseid,
		null							   as disdcheckdt,
		map.ProviderCTG					   as disnpayeecontactctgid,
		map.ProviderCID					   as disnpayeecontactid,
		v.total_value					   as disnamount,
		map.PlaintiffID					   as disnplaintiffid,
		(
			select
				disnTypeID
			from [sma_MST_DisbursmentType]
			where dissTypeName = (
					select
						[description]
					from [JoelBieberNeedles].[dbo].[value_code]
					where [code] = v.code
				)
		)								   as dissdisbursementtype,
		map.ProviderUID					   as uniquepayeeid,
		v.[memo]						   as dissdescription,
		--,v.settlement_memo + 
		--ISNULL('Account Number: ' + NULLIF(CAST(Account_Number AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('Cancel: ' + NULLIF(CAST(Cancel AS VARCHAR(MAX)), '') + CHAR(13), '') +    
		--ISNULL('CM Reviewed: ' + NULLIF(CAST(CM_Reviewed AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('Date Paid: ' + NULLIF(CAST(Date_Paid AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('For Dates From: ' + NULLIF(CAST(For_Dates_From AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('OI Checked: ' + NULLIF(CAST(OI_Checked AS VARCHAR(MAX)), '') + CHAR(13), '')
		--                                        as dissComments
		null							   as disscomments,
		--case
		--	when v.code in ('MSC', 'DTF')
		--		then (
		--				select
		--					Id
		--				from [sma_MST_CheckRequestStatus]
		--				where [Description] = 'Paid'
		--			)
		--	-- when v.code in ('UCC')
		--	--     then (
		--	--             select Id
		--	--             FROM [sma_MST_CheckRequestStatus]
		--	--             where [Description]='Check Pending'
		--	--         )
		--	when ISNULL(Check_Requested, '') <> ''
		--		then (
		--				select
		--					Id
		--				from [sma_MST_CheckRequestStatus]
		--				where [Description] = 'Check Pending'
		--			)
		--	else null
		--end				  as disncheckrequeststatus,
		(
			select
				Id
			from [sma_MST_CheckRequestStatus]
			where [Description] = 'Interest'
		)								   as disncheckrequeststatus,
		case
			when v.start_date between '1900-01-01' and '2079-06-06'
				then v.start_date
			else null
		end								   as disdbilldate,
		case
			when v.stop_date between '1900-01-01' and '2079-06-06'
				then v.stop_date
			else null
		end								   as disdduedate,
		--(
		--	select
		--		usrnUserID
		--	from sma_MST_Users
		--	where source_id = v.staff_created
		--)				as disnrecuserid,
		COALESCE(m.SAUserID, u.usrnUserID) as disnrecuserid, -- Use SAUserID if available, otherwise fallback to usrnUserID
		case
			when date_created between '1900-01-01' and '2079-06-06'
				then date_created
			else null
		end								   as disddtcreated,
		1								   as disnrecoverable,
		v.value_id						   as saga,
		null							   as source_id,
		'needles'						   as source_db,
		'post live fix'					   as source_ref
	from [JoelBieberNeedles].[dbo].[value_Indexed] v
	join value_tab_Disbursement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
	left join [conversion].[imp_user_map] m
		on m.StaffCode = v.staff_created
	left join [sma_MST_Users] u
		on u.source_id = v.staff_created
	where v.code = 'INT'
--join JoelBieberNeedles..user_tab2_data u
--	on u.case_id = v.case_id
go

---
alter table [sma_TRN_Disbursement] enable trigger all
go
---

