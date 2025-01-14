/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-23
Description: Create Medical Providers and Medical Bills

1.0 - Medical Providers > [sma_TRN_Hospitals]
- from damages
- from litify_pm__Role__c
1.1 - Medical Bills > [sma_TRN_SpDamages]

*/

use ShinerSA
go


------------------------------------------------------------------
--SELECT
--	*
--FROM ShinerLitify..litify_pm__Damage__c lpdc
--WHERE lpdc.litify_pm__Type__c IS NULL


------------------------------------------------------------------


/* ##############################################

[0.0] - Create temporary tables for mapping codes
- Temporary table to store applicable damage types
- Acts as as single patch point for updates
- Sample Usage:
	WHERE ISNULL(d.litify_pm__type__C, '') IN (SELECT code FROM #DamageTypes dt)
	WHERE litify_pm__role__c IN IN (SELECT code FROM #MedicalProviderRoles dt)
*/


-- [1.1] Damage Type Mapping
if OBJECT_ID('tempdb..#DamageTypes') is not null
begin
	drop table #DamageTypes;
end;

create table #DamageTypes (
	code VARCHAR(25)
);

-- Values from mapping spreadsheet
insert into #DamageTypes
	(
	code
	)
values (
'Medical Bill'
)


-- [1.1] Medical Provider Role Mapping
if OBJECT_ID('tempdb..#MedicalProviderRoles') is not null
begin
	drop table #MedicalProviderRoles;
end;

create table #MedicalProviderRoles (
	code VARCHAR(25)
);

-- Values from mapping spreadsheet
insert into #MedicalProviderRoles
	(
	code
	)
values (
	   'Medical Provider'
	   ),
	   (
'General Provider'
),
	   (
'Records Provider'
),
	   (
'Doctor'
),
	   (
'Health Care Facility'
)


---- [1.1] Request Type Mapping
--IF OBJECT_ID('tempdb..#RequestTypes') IS NOT NULL
--BEGIN
--	DROP TABLE #RequestTypes;
--END;

--CREATE TABLE #RequestTypes (code VARCHAR(25));

---- Values from mapping spreadsheet
--INSERT INTO #RequestTypes (code)
--VALUES
--('Medical Records'), ('Medical Bills and Records'), ('Medical Bills')



/*
alter table [sma_TRN_Hospitals] disable trigger all
delete [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all


alter table [sma_trn_MedicalProviderRequest] disable trigger all
delete [sma_trn_MedicalProviderRequest]
DBCC CHECKIDENT ([sma_trn_MedicalProviderRequest]', RESEED, 0);
alter table [sma_trn_MedicalProviderRequest] enable trigger all
*/
/*
select ioc.name, ioc.saga, req.*
From ShinerLitify..[litify_pm__Request__c] req
LEFT JOIN ShinerLitify..[litify_pm__Role__c] ro on req.litify_pm__Facility__c = ro.Id
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = ro.litify_pm__Party__c
WHERE isnull(litify_pm__Facility__c,'') = ''

select distinct litify_pm__Request_Type__c From ShinerLitify..[litify_pm__Request__c] req
*/


------------------------------------
--ADD SAGA TO HOSPITALS TABLE
------------------------------------
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals]
	add [saga_char] [VARCHAR](100) null;
end

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_bill_id'
			and object_id = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages]
	add [saga_bill_id] [VARCHAR](100) null;
end


--------------------------------------
----ADD SAGA TO MEDICAL REQUESTS TABLE
--------------------------------------
--IF NOT EXISTS (
--		SELECT
--			*
--		FROM sys.columns
--		WHERE Name = N'saga'
--			AND Object_ID = OBJECT_ID(N'sma_trn_MedicalProviderRequest')
--	)
--BEGIN
--	ALTER TABLE [sma_trn_MedicalProviderRequest]
--	ADD [saga] [VARCHAR](100) NULL;
--END

--------------------------------------
----RECORD REQUEST TYPES
--------------------------------------
--INSERT INTO sma_MST_Request_RecordTypes
--	(
--	RecordType
--	)
--	(SELECT DISTINCT
--		litify_pm__Request_Type__c
--	FROM ShinerLitify..[litify_pm__Request__c]
--	WHERE litify_pm__Request_Type__c IN ('Autopsy', 'Updated Medical Bills', 'Updated Medical Records', 'Medical Bills',
--		'Physical Therapy', 'Medical', 'Prior Medical', 'Medical Records')
--	)
--	EXCEPT
--	SELECT
--		RecordType
--	FROM sma_MST_Request_RecordTypes

----select distinct litify_pm__Request_Type__c From ShinerLitify..[litify_pm__Request__c]
--------------------------------------
----REQUEST STATUS
--------------------------------------
--INSERT INTO sma_MST_RequestStatus
--	(
--	Status
--   ,Description
--	)
--	SELECT
--		'No Record Available'
--	   ,'No Record Available'
--	EXCEPT
--	SELECT
--		Status
--	   ,Description
--	FROM sma_MST_RequestStatus
--GO


---

--ALTER TABLE [sma_trn_MedicalProviderRequest] DISABLE TRIGGER ALL
--GO

--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------


alter table [sma_TRN_Hospitals] disable trigger all
go


-- HOSPITALS FROM REQUEST TABLE
-- request type mapping
--INSERT INTO [sma_TRN_Hospitals]
--	(
--	[hosnCaseID]
--   ,[hosnContactID]
--   ,[hosnContactCtg]
--   ,[hosnAddressID]
--   ,[hossMedProType]
--   ,[hosdStartDt]
--   ,[hosdEndDt]
--   ,[hosnPlaintiffID]
--   ,[hosnComments]
--   ,[hosnHospitalChart]
--   ,[hosnRecUserID]
--   ,[hosdDtCreated]
--   ,[hosnModifyUserID]
--   ,[hosdDtModified]
--   ,[saga]
--	)
--	SELECT DISTINCT
--		casnCaseID AS [hosnCaseID]
--	   ,ioc.CID AS [hosnContactID]
--	   ,ioc.CTG AS [hosnContactCtg]
--	   ,ioc.AID AS [hosnAddressID]
--	   ,'M' AS [hossMedProType]
--	   ,			--M or P (P for Prior Medical Provider)
--		NULL AS [hosdStartDt]
--	   ,NULL AS [hosdEndDt]
--	   ,(
--			SELECT TOP 1
--				plnnPlaintiffID
--			FROM [sma_TRN_Plaintiff]
--			WHERE plnnCaseID = casnCaseID
--				AND plnbIsPrimary = 1
--		)
--		AS hosnPlaintiffID
--	   ,'' AS [hosnComments]
--	   ,NULL AS [hosnHospitalChart]
--	   ,368 AS [hosnRecUserID]
--	   ,GETDATE() AS [hosdDtCreated]
--	   ,NULL AS [hosnModifyUserID]
--	   ,NULL AS [hosdDtModified]
--	   ,litify_pm__Facility__c AS [saga]
--	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
--	--select *
--	FROM ShinerLitify..[litify_pm__Request__c] req
--	--JOIN ShinerLitify..[litify_pm__pro] ro on req.Provider__c = ro.Id
--	JOIN IndvOrgContacts_Indexed ioc
--		ON ioc.saga = req.Medical_Provider__c
--	JOIN sma_TRN_Cases cas
--		ON cas.Litify_saga = req.litify_pm__Matter__c
--	WHERE ISNULL(Medical_Provider__c, '') <> ''
--		AND litify_pm__Request_Type__c IN (SELECT code from #RequestTypes rt)
--GO

-----------------------------------------
--HOSPITALS FROM DAMAGES
-- damage type mapping
-----------------------------------------
insert into [sma_TRN_Hospitals]
	(
	[hosnCaseID],
	[hosnContactID],
	[hosnContactCtg],
	[hosnAddressID],
	[hossMedProType],
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments],
	[hosnHospitalChart],
	[hosnRecUserID],
	[hosdDtCreated],
	[hosnModifyUserID],
	[hosdDtModified],
	[saga_char]
	)
	select distinct
		casnCaseID as [hosncaseid],
		r.CID	   as [hosncontactid],
		r.CTG	   as [hosncontactctg],
		r.AID	   as [hosnaddressid],
		'M'		   as [hossmedprotype],			--M or P (P for Prior Medical Provider)
		null	   as [hosdstartdt],
		null	   as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)		   as hosnplaintiffid,
		''		   as [hosncomments],
		null	   as [hosnhospitalchart],
		368		   as [hosnrecuserid],
		GETDATE()  as [hosddtcreated],
		null	   as [hosnmodifyuserid],
		null	   as [hosddtmodified],
		d.Id	   as [saga_char]
	from ShinerLitify..[litify_pm__Damage__c] d
	join ShinerSa..vw_litifyRoleMapID r
		on d.litify_pm__Provider__c = r.Id
	join ShinerSA..[sma_TRN_Cases] cas
		on cas.saga_char = d.litify_pm__Matter__c
	left join ShinerSA..[sma_TRN_Hospitals] h
		on h.hosncaseid = cas.casnCaseID
			and h.hosncontactctg = r.CTG
			and h.hosncontactid = r.CID
	where ISNULL(d.litify_pm__Type__c, '') in (
			select
				code
			from #DamageTypes dt
		)
		and h.hosnHospitalID is null	--only add if it does not already exist
go


-----------------------------------------
--HOSPITALS FROM CONTACT ROLES
-----------------------------------------
-- from Party Mapping
insert into [sma_TRN_Hospitals]
	(
	[hosnCaseID],
	[hosnContactID],
	[hosnContactCtg],
	[hosnAddressID],
	[hossMedProType],
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments],
	[hosnHospitalChart],
	[hosnRecUserID],
	[hosdDtCreated],
	[hosnModifyUserID],
	[hosdDtModified],
	[saga_char]
	)
	select distinct
		casnCaseID as [hosncaseid],
		ioc.CID	   as [hosncontactid],
		ioc.CTG	   as [hosncontactctg],
		ioc.AID	   as [hosnaddressid],
		case
			when litify_pm__role__c like 'Prior%'
				then 'P'
			else 'M'
		end		   as [hossmedprotype],		--M or P (P for Prior Medical Provider)
		null	   as [hosdstartdt],
		null	   as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)		   as hosnplaintiffid,
		''		   as [hosncomments],
		null	   as [hosnhospitalchart],
		368		   as [hosnrecuserid],
		GETDATE()  as [hosddtcreated],
		null	   as [hosnmodifyuserid],
		null	   as [hosddtmodified],
		m.Id	   as [saga_char]
	from [ShinerLitify]..litify_pm__role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
	left join [sma_TRN_Hospitals] h
		on h.hosncaseid = cas.casnCaseID
			and h.hosncontactctg = ioc.ctg
			and h.hosncontactid = ioc.CID
	where litify_pm__role__c in (
			select
				code
			from #MedicalProviderRoles mpr
		)
		and h.hosnHospitalID is null	--only add if it does not already exist
--WHERE litify_pm__role__c IN ('Doctor', 'Health Care Facility', 'Medical Provider', 'PRIOR Medical Provider')
go


---------------------------------
--MEDICAL BILLS #########################################################################################
---------------------------------
-- uses #DamageTypes
insert into [sma_TRN_SpDamages]
	(
	[spdsRefTable],
	[spdnRecordID],
	[spdnBillAmt]
	--,[spdnadditionalField2] --written off
	,
	[spdsAccntNo],
	[spddNegotiatedBillAmt],
	[spdnAmtPaid],
	[spddDateFrom],
	[spddDateTo],
	[spddDamageSubType],
	[spdnVisitId],
	[spdsComments],
	[spdnRecUserID],
	[spddDtCreated],
	[spdnModifyUserID],
	[spddDtModified],
	[spdnBalance],
	[spdbLienConfirmed],
	[spdbDocAttached],
	[saga_bill_id]
	)
	select
		'Hospitals'																	 as spdsreftable,
		h.hosnHospitalID															 as spdnrecordid,
		d.litify_pm__Amount_Billed__c												 as spdnbillamt
		--,d.litify_pm__Reduction_Amount__c											 AS [spdnadditionalField2]
		,
		null																		 as spdsaccntno,
		null																		 as spddnegotiatedbillamt,
		d.litify_pm__Amount_Paid__c													 as [spdnamtpaid],
		case
			when d.litify_pm__Service_Start_Date__c between '1900-01-01' and '2079-06-06'
				then d.litify_pm__Service_Start_Date__c
			else null
		end																			 as spdddatefrom,
		case
			when d.litify_pm__Service_End_Date__c between '1900-01-01' and '2079-06-06'
				then d.litify_pm__Service_End_Date__c
			else null
		end																			 as spdddateto,
		null																		 as spdddamagesubtype,
		null																		 as spdnvisitid,
		ISNULL(NULLIF(CONVERT(VARCHAR, d.litify_pm__Comments__c), ''), 'conversion') as spdscomments,
		(
			select
				usrnUserID
			from sma_MST_Users
			where usrsLoginID = d.CreatedById
		)																			 as spdnrecordid,
		case
			when d.CreatedDate between '1900-01-01' and '2079-06-06'
				then d.CreatedDate
			else GETDATE()
		end																			 as spdddtcreated,
		(
			select
				usrnUserID
			from sma_MST_Users
			where usrsLoginID = d.LastModifiedById
		)																			 as spdnmodifyuserid,
		case
			when d.LastModifiedDate between '1900-01-01' and '2079-06-06'
				then d.LastModifiedDate
			else GETDATE()
		end																			 as spdddtmodified,
		null																		 as spdnbalance,
		0																			 as spdblienconfirmed,
		0																			 as spdbdocattached,
		d.Id																		 as saga_bill_id  -- one bill one value
	--select *
	from ShinerLitify..[litify_pm__Damage__c] d
	join vw_litifyRoleMapID r
		on d.litify_pm__Provider__c = r.Id
	join [sma_TRN_Cases] cas
		on cas.saga_char = d.litify_pm__Matter__c
	join [sma_TRN_Hospitals] h
		on h.hosnCaseID = cas.casnCaseID
			and h.hosnContactCtg = r.ctg
			and h.hosnContactID = r.CID
	where ISNULL(d.litify_pm__Type__c, '') in (
			select
				code
			from #DamageTypes dt
		)
		or d.litify_pm__Type__c is null		-- ds 2024-10-21 include null values, which should not exist during live conversion
	--WHERE ISNULL(d.litify_pm__type__C, '') IN ('', 'Medical Bill')


--------------------------------------------
--SPDAMAGES PAYMENTS
--------------------------------------------
--INSERT INTO [dbo].[sma_TRN_SpecialDamageAmountPaid]
--	(
--	[AmountPaidDamageReferenceID]
--   ,[AmountPaidCollateralType]
--   ,[AmountPaidPaidByID]
--   ,[AmountPaidTotal]
--   ,[AmountPaidClaimSubmittedDt]
--   ,[AmountPaidDate]
--   ,[AmountPaidRecUserID]
--   ,[AmountPaidDtCreated]
--   ,[AmountPaidModifyUserID]
--   ,[AmountPaidDtModified]
--   ,[AmountPaidLevelNo]
--   ,[AmountPaidAdjustment]
--   ,[AmountPaidComments]
--   ,[IsAdjustment]
--	)
--	SELECT
--		sp.spdnSpDamageID	--(<AmountPaidDamageReferenceID, int,>
--	   ,NULL				--,<AmountPaidCollateralType, int,>
--	   ,NULL				--,<AmountPaidPaidByID, int,>
--	   ,CASE
--			WHEN p.type__c <> 'Adjustment'
--				THEN p.amount_paid__c
--			ELSE NULL
--		END		--,<AmountPaidTotal, numeric(18,2),>
--	   ,NULL			--,<AmountPaidClaimSubmittedDt, smalldatetime,>
--	   ,p.Date_paid__c			--,<AmountPaidDate, smalldatetime,>
--	   ,(
--			SELECT
--				usrnUserID
--			FROM sma_mst_users
--			WHERE saga = p.createdbyID
--		)  --,<AmountPaidRecUserID, int,>
--	   ,p.createddate			--,<AmountPaidDtCreated, smalldatetime,>
--	   ,(
--			SELECT
--				usrnUserID
--			FROM sma_mst_users
--			WHERE saga = p.lastmodifiedByID
--		)				--,<AmountPaidModifyUserID, int,>
--	   ,p.lastModifiedDate				--,<AmountPaidDtModified, smalldatetime,>
--	   ,1					--,<AmountPaidLevelNo, int,>
--	   ,CASE
--			WHEN p.type__c = 'Adjustment'
--				THEN p.amount_paid__c
--			ELSE NULL
--		END		--,<AmountPaidAdjustment, numeric(18,2),>)
--	   ,ISNULL('Type: ' + NULLIF(CONVERT(VARCHAR, p.type__c), '') + CHAR(13), '') +
--		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR, p.Comment__c), '') + CHAR(13), '') +
--		'' AS [AmountPaidComments]
--	   ,CASE
--			WHEN p.type__c = 'Adjustment'
--				THEN 1
--			ELSE 0
--		END AS [IsAdjustment]
--	--select p.*
--	FROM ShinerLitify..litify_pm__Damage__c d
--	JOIN ShinerLitify..payment__c p
--		ON p.CM_Damage__c = d.Id
--	JOIN [sma_TRN_SpDamages] sp
--		ON sp.saga_bill_id = d.id


------------------------------------------------------------------------
----INSERT UNIDENTIFIED MEDICAL PROVIDERS WHERE NO FACILITY ID EXISTS
------------------------------------------------------------------------
--INSERT INTO [sma_TRN_Hospitals]
--	(
--	[hosnCaseID]
--   ,[hosnContactID]
--   ,[hosnContactCtg]
--   ,[hosnAddressID]
--   ,[hossMedProType]
--   ,[hosdStartDt]
--   ,[hosdEndDt]
--   ,[hosnPlaintiffID]
--   ,[hosnComments]
--   ,[hosnHospitalChart]
--   ,[hosnRecUserID]
--   ,[hosdDtCreated]
--   ,[hosnModifyUserID]
--   ,[hosdDtModified]
--   ,[saga]
--	)
--	SELECT DISTINCT
--		casnCaseID AS [hosnCaseID]
--	   ,ioc.CID AS [hosnContactID]
--	   ,ioc.CTG AS [hosnContactCtg]
--	   ,ioc.AID AS [hosnAddressID]
--	   ,'M' AS [hossMedProType]
--	   ,			--M or P (P for Prior Medical Provider)
--		NULL AS [hosdStartDt]
--	   ,NULL AS [hosdEndDt]
--	   ,(
--			SELECT TOP 1
--				plnnPlaintiffID
--			FROM [sma_TRN_Plaintiff]
--			WHERE plnnCaseID = casnCaseID
--				AND plnbIsPrimary = 1
--		)
--		AS hosnPlaintiffID
--	   ,'' AS [hosnComments]
--	   ,NULL AS [hosnHospitalChart]
--	   ,368 AS [hosnRecUserID]
--	   ,GETDATE() AS [hosdDtCreated]
--	   ,NULL AS [hosnModifyUserID]
--	   ,NULL AS [hosdDtModified]
--	   ,litify_pm__Facility__c AS [saga]
--	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
--	FROM ShinerLitify..[litify_pm__Request__c] req
--	JOIN IndvOrgContacts_Indexed ioc
--		ON ioc.saga = 'unidentifiedhospital'
--	JOIN sma_TRN_Cases cas
--		ON cas.Litify_saga = req.litify_pm__Matter__c
--	WHERE ISNULL(Medical_Provider__c, '') = ''
--		AND litify_pm__Request_Type__c IN ('Autopsy', 'Updated Medical Bills', 'Updated Medical Records', 'Medical Bills',
--		'Physical Therapy', 'Billing', 'Medical', 'Prior Medical', 'Medical Records')

----------------------------------------------------------------------------
------------------------------ MEDICAL REQUESTS ----------------------------
----------------------------------------------------------------------------

--INSERT INTO [sma_trn_MedicalProviderRequest]
--	(
--	MedPrvCaseID
--   ,MedPrvPlaintiffID
--   ,MedPrvhosnHospitalID
--   ,MedPrvRecordType
--   ,MedPrvRequestdate
--   ,MedPrvAssignee
--   ,MedPrvAssignedBy
--   ,MedPrvHighPriority
--   ,MedPrvFromDate
--   ,MedPrvToDate
--   ,MedPrvComments
--   ,MedPrvNotes
--   ,MedPrvCompleteDate
--   ,MedPrvStatusId
--   ,MedPrvFollowUpDate
--   ,MedPrvStatusDate
--   ,OrderAffidavit
--   ,FollowUpNotes
--   ,		--Retrieval Provider Notes
--	SAGA
--	)
--	SELECT
--		hosnCaseID AS MedPrvCaseID
--	   ,hosnPlaintiffID AS MedPrvPlaintiffID
--	   ,H.hosnHospitalID AS MedPrvhosnHospitalID
--	   ,(
--			SELECT
--				uId
--			FROM sma_MST_Request_RecordTypes
--			WHERE RecordType = req.litify_pm__Request_Type__c
--		)
--		AS MedPrvRecordType
--	   ,CASE
--			WHEN (req.litify_pm__Date_Requested__c BETWEEN '1900-01-01' AND '2079-06-06')
--				THEN req.litify_pm__Date_Requested__c
--			ELSE NULL
--		END AS MedPrvRequestdate
--	   ,NULL AS MedPrvAssignee
--	   ,(
--			SELECT
--				usrnUserID
--			FROM sma_mst_users
--			WHERE saga = req.litify_pm__Requested_by__c
--		)
--		AS MedPrvAssignedBy
--	   ,0 AS MedPrvHighPriority
--	   ,		--1=high priority; 0=Normal
--		CASE
--			WHEN litify_pm__Record_Start_Date__c BETWEEN '1900-01-01' AND '2079-06-06'
--				THEN litify_pm__Record_Start_Date__c
--			ELSE NULL
--		END AS MedPrvFromDate
--	   ,CASE
--			WHEN litify_pm__Record_End_Date__c BETWEEN '1900-01-01' AND '2079-06-06'
--				THEN litify_pm__Record_End_Date__c
--			ELSE NULL
--		END AS MedPrvToDate
--	   ,ISNULL(NULLIF(CONVERT(VARCHAR(MAX), req.litify_pm__comments__c), '') + CHAR(13), '') +
--		'' AS MedPrvComments
--	   ,ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), req.[Name]), '') + CHAR(13), '') +
--		'' AS MedPrvNotes
--	   ,CASE
--			WHEN (req.litify_pm__Date_Received__c BETWEEN '1900-01-01' AND '2079-06-06')
--				THEN req.litify_pm__Date_Received__c
--			ELSE NULL
--		END AS MedPrvCompleteDate
--	   ,CASE
--			WHEN (req.litify_pm__Date_Received__c BETWEEN '1900-01-01' AND '2079-06-06')
--				THEN (
--						SELECT
--							uId
--						FROM [sma_MST_RequestStatus]
--						WHERE [status] = 'Received'
--					)
--			ELSE NULL
--		END AS MedPrvStatusId
--	   ,NULL AS MedPrvFollowUpDate
--	   ,CASE
--			WHEN (litify_pm__Date_Received__c BETWEEN '1900-01-01' AND '2079-06-06')
--				THEN (
--						SELECT
--							uId
--						FROM [sma_MST_RequestStatus]
--						WHERE [status] = 'Received'
--					)
--			ELSE NULL
--		END AS MedPrvStatusDate
--	   ,NULL AS OrderAffidavit
--	   ,	--bit
--		'' AS FollowUpNotes
--	   ,	--Retreival Provider Notes
--		req.Id AS SAGA
--	--select *
--	FROM ShinerLitify..[litify_pm__Request__c] req
--	JOIN sma_TRN_Cases cas
--		ON cas.Litify_saga = req.litify_pm__Matter__c
--	JOIN [sma_TRN_Hospitals] H
--		ON H.hosnCaseID = cas.casnCaseID
--			AND h.saga = req.litify_pm__Facility__c
--	WHERE litify_pm__Request_Type__c IN ('Autopsy', 'Updated Medical Bills', 'Updated Medical Records', 'Medical Bills',
--		'Physical Therapy', 'Medical', 'Prior Medical', 'Medical Records')
--GO

--ALTER TABLE [sma_trn_MedicalProviderRequest] ENABLE TRIGGER ALL
--GO
