/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-11-07
Description: Create employment records and corresponding lost wage records

##########################################################################################################################
*/


USE JoelBieberSA_Needles
GO

/* ##############################################
Store applicable value codes
*/
IF OBJECT_ID('tempdb..#NegSetValueCodes') IS NOT NULL
	DROP TABLE #NegSetValueCodes;

CREATE TABLE #NegSetValueCodes (
	code VARCHAR(10)
);

INSERT INTO #NegSetValueCodes (code)
VALUES
('MPP'),
('SET'),

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
SELECT
	*
FROM sys.columns
WHERE Name = N'saga'
	AND Object_ID = OBJECT_ID(N'sma_TRN_Settlements'))
BEGIN
	ALTER TABLE [sma_TRN_Settlements] ADD [saga] INT NULL;
END
GO

---(0)---
------------------------------------------------
--INSERT SETTLEMENT TYPES
------------------------------------------------
INSERT INTO [sma_MST_SettlementType]
	(
	SettlTypeName
	)
	SELECT
		'Settlement Recovery'
	UNION
	SELECT
		'MedPay'
	UNION
	SELECT
		'Paid To Client'
	EXCEPT
	SELECT
		SettlTypeName
	FROM [sma_MST_SettlementType]
GO


---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Settlement_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_Settlement_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Settlement_Helper (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,case_id INT
   ,value_id INT
   ,ProviderNameId INT
   ,ProviderName VARCHAR(200)
   ,ProviderCID INT
   ,ProviderCTG INT
   ,ProviderAID INT
   ,casnCaseID INT
   ,PlaintiffID INT
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Settlement_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_case_id ON [value_tab_Settlement_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_value_id ON [value_tab_Settlement_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_ProviderNameId ON [value_tab_Settlement_Helper] (ProviderNameId);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_PlaintiffID ON [value_tab_Settlement_Helper] (PlaintiffID);
GO

---(0)---
INSERT INTO value_tab_Settlement_Helper
	(
	case_id
   ,value_id
   ,ProviderNameId
   ,ProviderName
   ,ProviderCID
   ,ProviderCTG
   ,ProviderAID
   ,casnCaseID
   ,PlaintiffID
	)
	SELECT
		V.case_id	   AS case_id
	   ,	-- needles case
		V.value_id	   AS tab_id
	   ,		-- needles records TAB item
		V.provider	   AS ProviderNameId
	   ,IOC.Name	   AS ProviderName
	   ,IOC.CID		   AS ProviderCID
	   ,IOC.CTG		   AS ProviderCTG
	   ,IOC.AID		   AS ProviderAID
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
			FROM #NegSetValueCodes
		);
GO
---(0)---
DBCC DBREINDEX ('value_tab_Settlement_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(0)--- (prepare for multiple party)
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
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA = V.party_id
JOIN [sma_TRN_Plaintiff] T
	ON T.plnnContactID = IOC.CID
		AND T.plnnContactCtg = IOC.CTG
		AND T.plnnCaseID = CAS.casnCaseID
GO

UPDATE value_tab_Settlement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


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
		FROM [sma_TRN_Plaintiff]
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

UPDATE value_tab_Settlement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO

----(1)----(  specified items go to settlement rows )
ALTER TABLE [sma_TRN_Settlements] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Settlements]
	(
	stlnCaseID
   ,stlnSetAmt
   ,stlnNet
   ,stlnNetToClientAmt
   ,stlnPlaintiffID
   ,stlnStaffID
   ,stlnLessDisbursement
   ,stlnGrossAttorneyFee
   ,stlnForwarder
   ,  --referrer
	stlnOther
   ,InterestOnDisbursement
   ,stlsComments
   ,stlTypeID
   ,stldSettlementDate
   ,saga
   ,stlbTakeMedPay		-- "Take Fee"
	)
	SELECT
		MAP.casnCaseID  AS stlnCaseID
	   ,V.total_value   AS stlnSetAmt
	   ,NULL			AS stlnNet
	   ,NULL			AS stlnNetToClientAmt
	   ,MAP.PlaintiffID AS stlnPlaintiffID
	   ,NULL			AS stlnStaffID
	   ,NULL			AS stlnLessDisbursement
	   ,NULL			AS stlnGrossAttorneyFee
	   ,NULL			AS stlnForwarder    --Referrer
	   ,NULL			AS stlnOther
	   ,NULL			AS InterestOnDisbursement
	   ,ISNULL('memo:' + NULLIF(V.memo, '') + CHAR(13), '')
		+ ISNULL('code:' + NULLIF(V.code, '') + CHAR(13), '')
		+ ''			AS [stlsComments]
	   ,(
			SELECT
				ID
			FROM [sma_MST_SettlementType]
			WHERE SettlTypeName = CASE
					WHEN v.[code] IN ('SET')
						THEN 'Settlement Recovery'
					WHEN v.[code] IN ('MP')
						THEN 'MedPay'
					WHEN v.[code] IN ('PTC')
						THEN 'Paid To Client'
				END
		)				
		AS stlTypeID
	   ,CASE
			WHEN V.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.[start_date]
			ELSE NULL
		END				AS stldSettlementDate
	   ,V.value_id		AS saga
	   ,CASE
			WHEN v.code = 'MPP'
				THEN 1
			ELSE 0
		END				AS stlbTakeMedPay		-- ds 2024-11-07 "Take Fee"
	FROM JoelBieberNeedles.[dbo].[value_Indexed] V
	JOIN value_tab_Settlement_Helper MAP
		ON MAP.case_id = V.case_id
			AND MAP.value_id = V.value_id
	WHERE V.code IN (
			SELECT
				code
			FROM #NegSetValueCodes
		)
GO

ALTER TABLE [sma_TRN_Settlements] ENABLE TRIGGER ALL
GO