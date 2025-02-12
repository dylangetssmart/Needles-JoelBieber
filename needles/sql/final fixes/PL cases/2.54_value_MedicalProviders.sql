/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [SA]
go

/*
alter table [sma_TRN_Hospitals] disable trigger all
delete [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all

alter table [sma_TRN_SpDamages] disable trigger all
delete [sma_TRN_SpDamages]
DBCC CHECKIDENT ('[sma_TRN_SpDamages]', RESEED, 0);
alter table [sma_TRN_SpDamages] enable trigger all

alter table [sma_TRN_SpecialDamageAmountPaid] disable trigger all
delete [sma_TRN_SpecialDamageAmountPaid]
DBCC CHECKIDENT ('[sma_TRN_SpecialDamageAmountPaid]', RESEED, 0);
alter table [sma_TRN_SpecialDamageAmountPaid] enable trigger all
*/


/* ##############################################
Create temporary table to hold disbursement value codes
*/
if OBJECT_ID('tempdb..#MedChargeCodes') is not null
	drop table #MedChargeCodes;

create table #MedChargeCodes (
	code VARCHAR(10)
);

insert into #MedChargeCodes
	(
	code
	)
values (
'MED'
)


alter table [sma_TRN_Hospitals] disable trigger all
go

alter table [sma_TRN_SpDamages] disable trigger all
go

alter table [sma_TRN_SpecialDamageAmountPaid] disable trigger all
go


---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [saga] [VARCHAR](100) null;
end
go

---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_bill_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages] add [saga_bill_id] [VARCHAR](100) null;
end
go

---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_MedicalProvider_Helper'
			and type = 'U'
	)
begin
	drop table value_tab_MedicalProvider_Helper
end
go

---(0)---
create table value_tab_MedicalProvider_Helper (
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
	constraint IOC_Clustered_Index_value_tab_MedicalProvider_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_MedicalProvider_Helper_case_id on [value_tab_MedicalProvider_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_MedicalProvider_Helper_value_id on [value_tab_MedicalProvider_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_MedicalProvider_Helper_ProviderNameId on [value_tab_MedicalProvider_Helper] (ProviderNameId);
go

---(0)---
insert into value_tab_MedicalProvider_Helper
	(
	case_id, value_id, ProviderNameId, ProviderName, ProviderCID, ProviderCTG, ProviderAID, casnCaseID, PlaintiffID
	)
	select
		V.case_id	   as case_id,	-- needles case
		V.value_id	   as tab_id,		-- needles records TAB item
		V.provider	   as ProviderNameId,
		IOC.Name	   as ProviderName,
		IOC.CID		   as ProviderCID,
		IOC.CTG		   as ProviderCTG,
		IOC.AID		   as ProviderAID,
		CAS.casnCaseID as casnCaseID,
		null		   as PlaintiffID
	from [JoelBieberNeedles].[dbo].[value_Indexed] V
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = CONVERT(VARCHAR, V.case_id)
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = V.provider
			and ISNULL(V.provider, 0) <> 0
	where code in (
			select
				code
			from #MedChargeCodes
		)
go

---(0)---
dbcc dbreindex ('value_tab_MedicalProvider_Helper', ' ', 90) with no_infomsgs
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
	V.case_id  as cid,
	V.value_id as vid,
	T.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [JoelBieberNeedles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on CAS.cassCaseNumber = V.case_id
join IndvOrgContacts_Indexed IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Plaintiff] T
	on T.plnnContactID = IOC.CID
		and T.plnnContactCtg = IOC.CTG
		and T.plnnCaseID = CAS.casnCaseID

update value_tab_MedicalProvider_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
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
	V.case_id  as cid,
	V.value_id as vid,
	(
		select
			plnnPlaintiffID
		from [JoelBieberSA_Needles].[dbo].[sma_TRN_Plaintiff]
		where plnnCaseID = CAS.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [JoelBieberNeedles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on CAS.cassCaseNumber = V.case_id
join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Defendants] D
	on D.defnContactID = IOC.CID
		and D.defnContactCtgID = IOC.CTG
		and D.defnCaseID = CAS.casnCaseID
go

update value_tab_MedicalProvider_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
go


---(1)---
insert into [sma_TRN_Hospitals]
	(
	[hosnCaseID], [hosnContactID], [hosnContactCtg], [hosnAddressID], [hossMedProType], [hosdStartDt], [hosdEndDt], [hosnPlaintiffID], [hosnComments], [hosnHospitalChart], [hosnRecUserID], [hosdDtCreated], [hosnModifyUserID], [hosdDtModified], [saga]
	)
	select
		A.casnCaseID  as [hosnCaseID],
		A.ProviderCID as [hosnContactID],
		A.ProviderCTG as [hosnContactCtg],
		A.ProviderAID as [hosnAddressID],
		'M'			  as [hossMedProType],
		null		  as [hosdStartDt],
		null		  as [hosdEndDt],
		A.PlaintiffID as hosnPlaintiffID,
		null		  as [hosnComments],
		null		  as [hosnHospitalChart],
		368			  as [hosnRecUserID],
		GETDATE()	  as [hosdDtCreated],
		null		  as [hosnModifyUserID],
		null		  as [hosdDtModified],
		'value'		  as [saga]
	from (
		select -- (Note: make sure no duplicate provider per case )
			ROW_NUMBER() over (partition by MAP.ProviderCID, MAP.ProviderCTG, MAP.casnCaseID, MAP.PlaintiffID order by V.value_id) as RowNumber,
			MAP.PlaintiffID,
			MAP.casnCaseID,
			MAP.ProviderCID,
			MAP.ProviderCTG,
			MAP.ProviderAID
		from [JoelBieberNeedles].[dbo].[value_Indexed] V
		inner join value_tab_MedicalProvider_Helper MAP
			on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id
		join sma_TRN_Cases cas
			on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
		where cas.source_ref = 'PL'
	) A
	where A.RowNumber = 1 ---Note: No merging. got to be the first script to populate Medical Provider
go

---(2)--- (Medical Provider Bill section)
insert into [sma_TRN_SpDamages]
	(
	[spdsRefTable], [spdnRecordID], [spdnBillAmt], [spddNegotiatedBillAmt], [spddDateFrom], [spddDateTo], [spddDamageSubType], [spdnVisitId], [spdsComments], [spdnRecUserID], [spddDtCreated], [spdnModifyUserID], [spddDtModified], [spdnBalance], [spdbLienConfirmed], [spdbDocAttached], [saga_bill_id]
	)
	select
		'Hospitals'														 as spdsRefTable,
		H.hosnHospitalID												 as spdnRecordID,
		V.total_value													 as spdnBillAmt,
		(V.total_value - V.reduction)									 as spddNegotiatedBillAmt,
		case
			when V.[start_date] between '1900-01-01' and '2079-06-06'
				then CONVERT(DATE, V.[start_date])
			else null
		end																 as spddDateFrom,
		case
			when V.[stop_date] between '1900-01-01' and '2079-06-06'
				then CONVERT(DATE, V.[stop_date])
			else null
		end																 as spddDateTo,
		null															 as spddDamageSubType,
		null															 as spdnVisitId,
		ISNULL('value tab medical bill. memo - ' + NULLIF(memo, ''), '') as spdsComments,
		368																 as spdnRecordID,
		GETDATE()														 as spddDtCreated,
		null															 as spdnModifyUserID,
		null															 as spddDtModified,
		V.due															 as spdnBalance,
		0																 as spdbLienConfirmed,
		0																 as spdbDocAttached,
		V.value_id														 as saga_bill_id  -- one bill one value
	from [JoelBieberNeedles].[dbo].[value_Indexed] V
	join value_tab_MedicalProvider_Helper MAP
		on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id
	join [sma_TRN_Hospitals] H
		on H.hosnContactID = MAP.ProviderCID
			and H.hosnContactCtg = MAP.ProviderCTG
			and H.hosnCaseID = MAP.casnCaseID
			and H.hosnPlaintiffID = MAP.PlaintiffID
	join sma_TRN_Cases cas
		on cas.casnCaseID = h.hosnCaseID
	where cas.source_ref = 'PL'
go

---(3)--- (Amount Paid section)  --Type=Client--
insert into [sma_TRN_SpecialDamageAmountPaid]
	(
	[AmountPaidDamageReferenceID], [AmountPaidCollateralType], [AmountPaidPaidByID], [AmountPaidTotal], [AmountPaidClaimSubmittedDt], [AmountPaidDate], [AmountPaidRecUserID], [AmountPaidDtCreated], [AmountPaidModifyUserID], [AmountPaidDtModified], [AmountPaidLevelNo], [AmountPaidAdjustment], [AmountPaidComments]
	)
	select
		SPD.spdnSpDamageID as [AmountPaidDamageReferenceID],
		(
			select
				cltnCollateralTypeID
			from [dbo].[sma_MST_CollateralType]
			where cltsDscrptn = 'Client'
		)				   as [AmountPaidCollateralType],
		null			   as [AmountPaidPaidByID],
		VP.payment_amount  as [AmountPaidTotal],
		null			   as [AmountPaidClaimSubmittedDt],
		case
			when VP.date_paid between '1900-01-01' and '2079-06-06'
				then VP.date_paid
			else null
		end				   as [AmountPaidDate],
		368				   as [AmountPaidRecUserID],
		GETDATE()		   as [AmountPaidDtCreated],
		null			   as [AmountPaidModifyUserID],
		null			   as [AmountPaidDtModified],
		null			   as [AmountPaidLevelNo],
		null			   as [AmountPaidAdjustment],
		ISNULL('paid by:' + NULLIF(VP.paid_by, '') + CHAR(13), '')
		+ ISNULL('paid to:' + NULLIF(VP.paid_to, '') + CHAR(13), '')
		+ ''			   as [AmountPaidComments]
	from [JoelBieberNeedles].[dbo].[value_Indexed] V
	join value_tab_MedicalProvider_Helper MAP
		on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id
	join [sma_TRN_SpDamages] SPD
		on SPD.saga_bill_id = V.value_id
	join [JoelBieberNeedles].[dbo].[value_payment] VP
		on VP.value_id = V.value_id -- multiple payment per value_id
	join sma_TRN_Cases cas
			on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
		where cas.source_ref = 'PL'
go


---(Appendix)--- Update hospital TotalBill from Bill section
--update [sma_TRN_Hospitals]
--set hosnTotalBill = (
--	select
--		SUM(spdnBillAmt)
--	from sma_TRN_SpDamages
--	where sma_TRN_SpDamages.spdsRefTable = 'Hospitals'
--		and sma_TRN_SpDamages.spdnRecordID = hosnHospitalID

--)

UPDATE h
SET h.hosnTotalBill = (
    SELECT SUM(spdnBillAmt)
    FROM sma_TRN_SpDamages s
    WHERE s.spdsRefTable = 'Hospitals'
    AND s.spdnRecordID = h.hosnHospitalID
)
FROM sma_TRN_Hospitals h
JOIN sma_TRN_Cases cas
    ON cas.casnCaseID = h.hosnCaseID
WHERE cas.source_ref = 'PL'
AND EXISTS (
    SELECT 1
    FROM sma_TRN_SpDamages s
    WHERE s.spdsRefTable = 'Hospitals'
    AND s.spdnRecordID = h.hosnHospitalID
)

go

-----------
alter table [sma_TRN_Hospitals] enable trigger all
go

alter table [sma_TRN_SpDamages] enable trigger all
go

alter table [sma_TRN_SpecialDamageAmountPaid] enable trigger all
go
-----------





