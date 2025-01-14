use JoelBieberSA_Needles
GO

/* ##############################################
Create temporary table to hold disbursement value codes
*/
IF OBJECT_ID('tempdb..#DisbursementValueCodes') IS NOT NULL
	DROP TABLE #DisbursementValueCodes;

CREATE TABLE #DisbursementValueCodes (
	code VARCHAR(10)
);

INSERT INTO #DisbursementValueCodes (code)
VALUES
('DTF'), ('MSC'); -- ds 2024-11-07 updated value codes
-- ('CEX'), ('CL'), ('DTF'), ('INV'), ('MSC'), ('REI'), ('REN');



/*
alter table [sma_TRN_Disbursement] disable trigger all
delete from [sma_TRN_Disbursement] 
DBCC CHECKIDENT ('[sma_TRN_Disbursement]', RESEED, 0);
alter table [sma_TRN_Disbursement] enable trigger all
*/


/* ##############################################
Add saga to sma_TRN_Disbursement
*/
if not exists (
SELECT
	*
FROM sys.columns
WHERE Name = N'saga'
	AND Object_ID = OBJECT_ID(N'sma_TRN_Disbursement'))
BEGIN
	ALTER TABLE [sma_TRN_Disbursement] ADD [saga] INT NULL;
END

-- Use this to create custom CheckRequestStatuses
-- INSERT INTO [sma_MST_CheckRequestStatus] ([description])
-- select 'Unrecouped'
-- EXCEPT SELECT [description] FROM [sma_MST_CheckRequestStatus]


/* ##############################################
Create disbursement types for applicable value codes
*/
INSERT INTO [sma_MST_DisbursmentType]
	(
	disnTypeCode
   ,dissTypeName
	)
	(
	SELECT DISTINCT
		'CONVERSION'
	   ,VC.[description]
	FROM JoelBieberNeedles.[dbo].[value] V
	JOIN JoelBieberNeedles.[dbo].[value_code] VC
		ON VC.code = V.code
	WHERE ISNULL(V.code, '') IN (
			SELECT
				code
			FROM #DisbursementValueCodes
		)
	)
	EXCEPT
	SELECT
		'CONVERSION'
	   ,dissTypeName
	FROM [sma_MST_DisbursmentType]


/* ##############################################
Create Disbursement helper table
*/
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Disbursement_Helper'
			AND TYPE = 'U'
	)
BEGIN
	DROP TABLE value_tab_Disbursement_Helper
END
GO

CREATE TABLE value_tab_Disbursement_Helper (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,case_id INT
   ,value_id INT
   ,ProviderNameId INT
   ,ProviderName VARCHAR(200)
   ,ProviderCID INT
   ,ProviderCTG INT
   ,ProviderAID INT
   ,ProviderUID BIGINT
   ,casnCaseID INT
   ,PlaintiffID INT
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Disbursement_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_case_id ON [value_tab_Disbursement_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_value_id ON [value_tab_Disbursement_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_ProviderNameId ON [value_tab_Disbursement_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO value_tab_Disbursement_Helper
	(
	case_id
   ,value_id
   ,ProviderNameId
   ,ProviderName
   ,ProviderCID
   ,ProviderCTG
   ,ProviderAID
   ,ProviderUID
   ,casnCaseID
   ,PlaintiffID
	)
	SELECT
		V.case_id	   AS case_id
	   ,	        -- needles case
		V.value_id	   AS tab_id
	   ,		    -- needles records TAB item
		V.provider	   AS ProviderNameId
	   ,IOC.Name	   AS ProviderName
	   ,IOC.CID		   AS ProviderCID
	   ,IOC.CTG		   AS ProviderCTG
	   ,IOC.AID		   AS ProviderAID
	   ,IOC.UNQCID	   AS ProviderUID
	   ,CAS.casnCaseID AS casnCaseID
	   ,NULL		   AS PlaintiffID
	FROM JoelBieberNeedles.[dbo].[value_Indexed] V
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = V.case_id
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA = V.provider
			AND ISNULL(V.provider, 0) <> 0
	WHERE code IN (
			SELECT
				code
			FROM #DisbursementValueCodes
		);
GO

---(0)---
DBCC DBREINDEX ('value_tab_Disbursement_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(0)--- value_id may associate with secondary plaintiff
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'value_tab_Multi_Party_Helper_Temp'
	)
BEGIN
	DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT
	V.case_id  AS cid
   ,V.value_id AS vid
   ,T.plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM JoelBieberNeedles.[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS
	ON CAS.cassCaseNumber = V.case_id
JOIN IndvOrgContacts_Indexed IOC
	ON IOC.SAGA = V.party_id
JOIN [sma_TRN_Plaintiff] T
	ON T.plnnContactID = IOC.CID
		AND T.plnnContactCtg = IOC.CTG
		AND T.plnnCaseID = CAS.casnCaseID

UPDATE value_tab_Disbursement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO

---(0)--- value_id may associate with defendant. steve malman make it associates to primary plaintiff 
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'value_tab_Multi_Party_Helper_Temp'
	)
BEGIN
	DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT
	V.case_id  AS cid
   ,V.value_id AS vid
   ,(
		SELECT
			plnnPlaintiffID
		FROM sma_TRN_Plaintiff
		WHERE plnnCaseID = CAS.casnCaseID
			AND plnbIsPrimary = 1
	)		   
	AS plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM JoelBieberNeedles.[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS
	ON CAS.cassCaseNumber = V.case_id
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA = V.party_id
JOIN [sma_TRN_Defendants] D
	ON D.defnContactID = IOC.CID
		AND D.defnContactCtgID = IOC.CTG
		AND D.defnCaseID = CAS.casnCaseID
GO

UPDATE value_tab_Disbursement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


/* ##############################################
Create Disbursements
*/
ALTER TABLE [sma_TRN_Disbursement] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Disbursement]
	(
	disnCaseID
   ,disdCheckDt
   ,disnPayeeContactCtgID
   ,disnPayeeContactID
   ,disnAmount
   ,disnPlaintiffID
   ,dissDisbursementType
   ,UniquePayeeID
   ,dissDescription
   ,dissComments
   ,disnCheckRequestStatus
   ,disdBillDate
   ,disdDueDate
   ,disnRecUserID
   ,disdDtCreated
   ,disnRecoverable
   ,saga
	)
	SELECT
		MAP.casnCaseID	  AS disnCaseID
	   ,NULL AS disdCheckDt
	   ,MAP.ProviderCTG	  AS disnPayeeContactCtgID
	   ,MAP.ProviderCID	  AS disnPayeeContactID
	   ,V.total_value	  AS disnAmount
	   ,MAP.PlaintiffID	  AS disnPlaintiffID
	   ,(
			SELECT
				disnTypeID
			FROM [sma_MST_DisbursmentType]
			WHERE dissTypeName = (
					SELECT
						[description]
					FROM JoelBieberNeedles.[dbo].[value_code]
					WHERE [code] = V.code
				)
		)				  
		AS dissDisbursementType
	   ,MAP.ProviderUID	  AS UniquePayeeID
	   ,V.[memo]		  AS dissDescription
	   ,v.settlement_memo
		--ISNULL('Account Number: ' + NULLIF(CAST(Account_Number AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('Cancel: ' + NULLIF(CAST(Cancel AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('CM Reviewed: ' + NULLIF(CAST(CM_Reviewed AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('Date Paid: ' + NULLIF(CAST(Date_Paid AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('For Dates From: ' + NULLIF(CAST(For_Dates_From AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('OI Checked: ' + NULLIF(CAST(OI_Checked AS VARCHAR(MAX)), '') + CHAR(13), '')
		AS dissComments
		--,case
		-- when v.code in ('CEX', 'CSF', 'ICF', 'MCF' )
		--     then (
		--             select Id
		--             FROM [sma_MST_CheckRequestStatus]
		--             where [Description]='Paid'
		--         )
		-- when v.code in ('UCC')
		--     then (
		--             select Id
		--             FROM [sma_MST_CheckRequestStatus]
		--             where [Description]='Check Pending'
		--         )
		--      when isnull(Check_Requested,'') <> ''
		--          then (
		--              select Id
		--              FROM [sma_MST_CheckRequestStatus]
		--              where [Description]='Check Pending'
		--          )
		--else NULL
		--      end	                                as disnCheckRequestStatus
	   ,(
			SELECT
				Id
			FROM [sma_MST_CheckRequestStatus]
			WHERE [Description] = 'Paid'
		)				  
		AS disnCheckRequestStatus
	   ,CASE
			WHEN V.start_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.start_date
			ELSE NULL
		END				  AS disdBillDate
	   ,CASE
			WHEN V.stop_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.stop_date
			ELSE NULL
		END				  AS disdDueDate
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = V.staff_created
		)				  
		AS disnRecUserID
	   ,CASE
			WHEN date_created BETWEEN '1900-01-01' AND '2079-06-06'
				THEN date_created
			ELSE NULL
		END				  AS disdDtCreated
	   ,CASE
			WHEN v.code IN ('DTF', 'CEX', 'REI')
				THEN 0
			ELSE 1
		END				  AS disnRecoverable
	   ,V.value_id		  AS saga
	FROM JoelBieberNeedles.[dbo].[value_Indexed] V
	JOIN value_tab_Disbursement_Helper MAP
		ON MAP.case_id = V.case_id
			AND MAP.value_id = V.value_id
	--JOIN TestNeedles..user_tab2_data u
	--	ON u.case_id = v.case_id
GO
---
ALTER TABLE [sma_TRN_Disbursement] ENABLE TRIGGER ALL
GO
---

