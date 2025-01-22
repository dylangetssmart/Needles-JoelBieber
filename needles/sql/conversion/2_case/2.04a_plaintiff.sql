/* ###################################################################################
description: Insert plaintiffs
steps:
	- update schema > [sma_TRN_Plaintiff]
	- Insert case staff from staff_1 through staff_4 > [sma_TRN_CaseStaff]	
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/

use [JoelBieberSA_Needles]
go

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_party'
			and object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [saga_party] INT null;
end

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [source_ref] VARCHAR(MAX) null;
end
go


alter table [sma_TRN_Plaintiff] disable trigger all
go

-------------------------------------------------------------------------------
-- Insert plaintiffs
-------------------------------------------------------------------------------

insert into [sma_TRN_Plaintiff]
	(
	[plnnCaseID],
	[plnnContactCtg],
	[plnnContactID],
	[plnnAddressID],
	[plnnRole],
	[plnbIsPrimary],
	[plnbWCOut],
	[plnnPartiallySettled],
	[plnbSettled],
	[plnbOut],
	[plnbSubOut],
	[plnnSeatBeltUsed],
	[plnnCaseValueID],
	[plnnCaseValueFrom],
	[plnnCaseValueTo],
	[plnnPriority],
	[plnnDisbursmentWt],
	[plnbDocAttached],
	[plndFromDt],
	[plndToDt],
	[plnnRecUserID],
	[plndDtCreated],
	[plnnModifyUserID],
	[plndDtModified],
	[plnnLevelNo],
	[plnsMarked],
	[saga],
	[plnnNoInj],
	[plnnMissing],
	[plnnLIPBatchNo],
	[plnnPlaintiffRole],
	[plnnPlaintiffGroup],
	[plnnPrimaryContact],
	[saga_party]
	)
	select
		cas.casnCaseID  as [plnncaseid],
		cio.CTG			as [plnncontactctg],
		cio.CID			as [plnncontactid],
		cio.AID			as [plnnaddressid],
		s.sbrnSubRoleId as [plnnrole],
		1				as [plnbisprimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368				as [plnnrecuserid],
		GETDATE()		as [plnddtcreated],
		null,
		null,
		null			as [plnnlevelno],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnprimarycontact],
		p.TableIndex	as [saga_party]
	--SELECT cas.casncaseid, p.role, p.party_ID, pr.[needles roles], pr.[sa roles], pr.[sa party], s.*
	from JoelBieberNeedles.[dbo].[party_indexed] p
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = p.case_id
	join IndvOrgContacts_Indexed cio
		on cio.SAGA = p.party_id
	join [PartyRoles] pr
		on pr.[Needles Roles] = p.[role]
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = [sa roles]
			and s.sbrnRoleID = 4
	where pr.[sa party] = 'Plaintiff'
go

/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix A)-- every case need at least one plaintiff
*/

insert into [sma_TRN_Plaintiff]
	(
	[plnnCaseID],
	[plnnContactCtg],
	[plnnContactID],
	[plnnAddressID],
	[plnnRole],
	[plnbIsPrimary],
	[plnbWCOut],
	[plnnPartiallySettled],
	[plnbSettled],
	[plnbOut],
	[plnbSubOut],
	[plnnSeatBeltUsed],
	[plnnCaseValueID],
	[plnnCaseValueFrom],
	[plnnCaseValueTo],
	[plnnPriority],
	[plnnDisbursmentWt],
	[plnbDocAttached],
	[plndFromDt],
	[plndToDt],
	[plnnRecUserID],
	[plndDtCreated],
	[plnnModifyUserID],
	[plndDtModified],
	[plnnLevelNo],
	[plnsMarked],
	[saga],
	[plnnNoInj],
	[plnnMissing],
	[plnnLIPBatchNo],
	[plnnPlaintiffRole],
	[plnnPlaintiffGroup],
	[plnnPrimaryContact]
	)
	select
		casnCaseID as [plnncaseid],
		1		   as [plnncontactctg],
		(
			select
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Plaintiff'
				and cinsLastName = 'Unidentified'
		)		   as [plnncontactid],
		null	   as [plnnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(P)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as plnnrole,
		1		   as [plnbisprimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368		   as [plnnrecuserid],
		GETDATE()  as [plnddtcreated],
		null,
		null,
		'',
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1		   as [plnnprimarycontact]
	from sma_trn_cases cas
	left join [sma_TRN_Plaintiff] t
		on t.plnncaseid = cas.casnCaseID
	where plnncaseid is null
go



update sma_TRN_Plaintiff
set plnbIsPrimary = 0

update sma_TRN_Plaintiff
set plnbIsPrimary = 1
from (
	select distinct
		t.plnnCaseID,
		ROW_NUMBER() over (partition by t.plnnCaseID order by p.record_num) as rownumber,
		t.plnnPlaintiffID as id
	from sma_TRN_Plaintiff t
	left join JoelBieberNeedles.[dbo].[party_indexed] p
		on p.TableIndex = t.saga_party
) a
where a.rownumber = 1
and plnnPlaintiffID = a.id



alter table [sma_TRN_Plaintiff] enable trigger all
go
