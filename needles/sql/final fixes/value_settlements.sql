use sa
go



--select
--	*
--from JoelBieberNeedles..value_indexed v
--join JoelBieberSA_Needles..sma_TRN_Cases cas
--on cas.cassCaseNumber = convert(varchar,v.case_id)
--where code in ('PPC'
--	,
--	'PPP'
--	,
--	'TBP')
--and cas.casdOpeningDate > '2010-01-01 00:00:00.000'

----TBP - 215099
----PPC - 216528
----PPP - 226532

--SELECT * FROM JoelBieberNeedles..value_Indexed v where v.case_id = 226532 and code in ('PPC'
--	,
--	'PPP'
--	,
--	'TBP')



-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [source_ref] VARCHAR(MAX) null;
end
go

/* ##############################################
Store applicable value codes
*/
if OBJECT_ID('tempdb..#NegSetValueCodes') is not null
	drop table #NegSetValueCodes;

create table #NegSetValueCodes (
	code VARCHAR(10)
);

insert into #NegSetValueCodes
	(
	code
	)
values (
	   'PPC'
	   ),
	   (
'PPP'
),
	   (
'TBP'
);

-- ds 2024-11-07 update value codes
--('ATT'),
--('MPP'),
--('PIP'),
--('SET'),
--('SUB');


/*
alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
*/

--select distinct code, description from JoelBieberNeedles.[dbo].[value] order by code
---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [saga] INT null --VARCHAR(100) null;
end
go

---(0)---
------------------------------------------------
--INSERT SETTLEMENT TYPES
------------------------------------------------
--insert into [sma_MST_SettlementType]
--	(
--	SettlTypeName
--	)
--	select
--		'Verdict'
--	--union
--	--select
--	--	'MedPay'
--	--union
--	--select
--	--	'Paid To Client'
--	except
--	select
--		SettlTypeName
--	from [sma_MST_SettlementType]
--go


---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_Settlement_Helper'
			and type = 'U'
	)
begin
	drop table value_tab_Settlement_Helper
end
go

---(0)---
create table value_tab_Settlement_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   INT,
	value_id	   INT,
	ProviderNameId INT,
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	casnCaseID	   INT,
	PlaintiffID	   INT,
	constraint IOC_Clustered_Index_value_tab_Settlement_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_case_id on [value_tab_Settlement_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_value_id on [value_tab_Settlement_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_ProviderNameId on [value_tab_Settlement_Helper] (ProviderNameId);
create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_PlaintiffID on [value_tab_Settlement_Helper] (PlaintiffID);
go

---(0)---
insert into value_tab_Settlement_Helper
	(
	case_id, value_id, ProviderNameId, ProviderName, ProviderCID, ProviderCTG, ProviderAID, casnCaseID, PlaintiffID
	)
	select
		v.case_id	   as case_id,	-- needles case
		v.value_id	   as tab_id,		-- needles records TAB item
		v.provider	   as providernameid,
		ioc.Name	   as providername,
		ioc.CID		   as providercid,
		ioc.CTG		   as providerctg,
		ioc.AID		   as provideraid,
		cas.casncaseid as casncaseid,
		null		   as plaintiffid
	from JoelBieberNeedles.[dbo].[value_Indexed] v
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = v.provider
			and ISNULL(v.provider, 0) <> 0
	where code in (
			select
				code
			from #NegSetValueCodes
		);
go

---(0)---
dbcc dbreindex ('value_tab_Settlement_Helper', ' ', 90) with no_infomsgs
go


---(0)--- (prepare for multiple party)
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
	t.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from JoelBieberNeedles.[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.cid
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID
go

update value_tab_Settlement_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.cid
and value_id = a.vid
go


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
		from [sma_TRN_Plaintiff]
		where plnnCaseID = cas.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnplaintiffid
into value_tab_Multi_Party_Helper_Temp
from JoelBieberNeedles.[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.cid
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go

update value_tab_Settlement_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.cid
and value_id = a.vid
go

----(1)----(  specified items go to settlement rows )
alter table [sma_TRN_Settlements] disable trigger all
go

insert into [sma_TRN_Settlements]
	(
	stlnCaseID, stlnSetAmt, stlnNet, stlnNetToClientAmt, stlnPlaintiffID, stlnStaffID, stlnLessDisbursement, stlnGrossAttorneyFee, stlnForwarder,  --referrer
	stlnOther, InterestOnDisbursement, stlsComments, stlTypeID, stldSettlementDate, saga, source_id, source_db, source_ref
	)
	select
		map.casnCaseID  as stlncaseid,
		v.total_value   as stlnsetamt,
		null			as stlnnet,
		null			as stlnnettoclientamt,
		map.PlaintiffID as stlnplaintiffid,
		null			as stlnstaffid,
		null			as stlnlessdisbursement,
		0				as stlngrossattorneyfee,
		null			as stlnforwarder,		-- Referrer
		null			as stlnother,
		null			as interestondisbursement,
		ISNULL('memo:' + NULLIF(v.memo, '') + CHAR(13), '')
		+ ISNULL('code:' + NULLIF(v.code, '') + CHAR(13), '')
		+ ''			as [stlscomments],
		null			as stltypeid,
		case
			when v.[start_date] between '1900-01-01' and '2079-06-06'
				then v.[start_date]
			else null
		end				as stldsettlementdate,
		v.value_id		as saga,
		null			as source_id,
		'needles'		as source_db,
		'post live fix' as source_ref
	from JoelBieberNeedles.[dbo].[value_Indexed] v
	join value_tab_Settlement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
	where v.code in (
			select
				code
			from #NegSetValueCodes
		)
go

alter table [sma_TRN_Settlements] enable trigger all
go