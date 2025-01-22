/* 
###########################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-24
Description: Create lienors and lien details

Step							Target						Source
-----------------------------------------------------------------------------------------------
[1.0] Lien Types				sma_MST_LienType			hardcode
[2.0] Lienors					sma_TRN_Lienors				[litify_pm__Lien__c]
[3.0] Lienors					sma_TRN_Lienors				[litify_pm__Damage__c]
[4.0] Lien Details				sma_TRN_LienDetails			[litify_pm__Lien__c]
[5.0] Lien Details				sma_TRN_LienDetails			[litify_pm__Damage__c]

##########################################################################################################################
*/

USE ShinerSA
GO

/*
######################################################################
Validation
######################################################################
*/

IF 1 = 0 -- Always false
BEGIN

	--matter id: a0L8Z00000eDawuUAC
	SELECT
		a.id
	   ,a.type
	   ,a.Name
	   ,*
	FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
	JOIN ShinerLitify..Account a
		ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c
	WHERE lpdc.litify_pm__Matter__c LIKE 'a0L8Z00000eDawuUAC'
	-- litify_pm__Negotiating_with__c = a0VNt000000ZUBJMA4
	-- litify_ext__Negotiating_with_Party__c =  0018Z00002rytGyQAI
	-- OwnerId = 0058Z000009TFzAQAW

	SELECT
		*
	FROM shinerlitify..account
	WHERE id = '0058Z000009TFzAQAW'


	SELECT
		*
	FROM shinerlitify..contact
	WHERE LastName LIKE '%hoffman%'
		AND firstname LIKE '%michael%'
	-- id = 003Nt000005czyxIAA
	-- AccountId = 001Nt000005WIesIAG
	-- OwnerId = 0058Z000008qiLTQAY

	SELECT
		*
	FROM shinerlitify..account
	WHERE name LIKE '%hoffman%'
--id = 001Nt000005WIesIAG

--select * from shinerlitify..contact WHERE name like '%hoffman%'
--a0VNt000000ZUBJMA4


--SELECT
--	*
--FROM shinerlitify.dbo.User


--SELECT
--	*
--FROM sma_mst_users
--WHERE saga = '0058Z000008qiLTQAY'


--SELECT
--	a.name
--   ,*
--FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
--LEFT JOIN ShinerLitify..Account a
--	ON a.Id = lpdc.CreatedById
--WHERE lpdc.litify_pm__Matter__c LIKE 'a0L8Z00000eDawuUAC'

--SELECT
--	*
--FROM ShinerLitify..Account a

--SELECT
--	*
--FROM [ShinerLitify]..litify_pm__Role__c
--WHERE litify_pm__Party__c = '0018Z00002rytGyQAI'

----SELECT
----	MAX(LEN(lpdc.litify_ext__Negotiating_with_Party__c))
----FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc

---- Account
--SELECT
--	*
--FROM ShinerLitify..Account a
--WHERE a.Id = '0018Z00002rytGyQAI'


--SELECT DISTINCT
--	a.Type
--FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
--JOIN ShinerLitify..Account a
--	ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c



--SELECT
--	*
--FROM ShinerLitify..litify_pm__Matter__c lpmc
--WHERE lpmc.litify_pm__Display_Name__c LIKE '%cheryl lavigne%'
---- id: a0LNt00000B4BoWMAV
---- MAT-24041528833

--SELECT
--	*
--FROM ShinerSa


END
-------------------------------------------- END VALIDATION --------------------------------------------

/*
######################################################################
[1.0] Party Helper
######################################################################

- build helper table with refernces to "Negotiating With"
- check Account.Type
SELECT DISTINCT a.type
FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
JOIN ShinerLitify..Account a
ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c

if account.type = insurance, get
"I+[sma_trn_InsuranceCoverage].[IncnInsCovgID]"

if account.type = lawyer, get 
- "L+[sma_trn_LawFirms].[lwfnLawFirmID]"

*/


-- [] Create helper
IF
	OBJECT_ID('helper_Negotiation_Party', 'U') IS NOT NULL
BEGIN
	DROP TABLE helper_Negotiation_Party;
END;

CREATE TABLE helper_Negotiation_Party (
	SACaseID INT
   ,LitifyCaseId VARCHAR(50)
   ,negsUniquePartyID VARCHAR(25)
   ,negotiatedBy INT
   ,partyType VARCHAR(10)
);
GO

/*
[1.3] Populate helper

- add insurance companies
- add attorneys

*/
INSERT INTO helper_Negotiation_Party
	(
	SAcaseID
   ,LitifyCaseId
   ,negsUniquePartyID
   ,negotiatedBy
   ,partyType
	)
	-- Insurance Companies
	SELECT
		cas.casnCaseID								   AS SAcaseID
	   ,cas.saga_char								   AS LitifyCaseId
	   ,'I' + CONVERT(VARCHAR(10), stic.incnInsCovgID) AS negsUniquePartyID
	   ,ioci.CID									   AS negotiatedBy
	   ,'Insurance'									   AS partyType
	FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
	-- Negotiating With
	JOIN ShinerLitify..Account a
		ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c
	-- Insurance company Id
	JOIN sma_TRN_Cases cas
		ON cas.saga_char = lpdc.litify_pm__Matter__c
	JOIN sma_TRN_InsuranceCoverage stic
		ON stic.incnCaseID = cas.casnCaseID
	-- Negotiated By
	LEFT JOIN ShinerSA..IndvOrgContacts_Indexed ioci
		ON ioci.saga_char = lpdc.OwnerId
	WHERE ISNULL(a.Type, '') <> ''
		AND a.Type IN ('insurance', 'Insurance Company')

	UNION

	-- Lawyers
	SELECT
		cas.casnCaseID								AS SAcaseID
	   ,cas.saga_char								AS LitifyCaseId
	   ,'L' + CONVERT(VARCHAR(10), [lwfnLawFirmID]) AS negsUniquePartyID
	   ,ioci.CID									AS negotiatedBy
	   ,'Attorney'									AS partyType
	FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
	-- case
	JOIN sma_TRN_Cases cas
		ON cas.saga_char = lpdc.litify_pm__Matter__c
	-- Negotiated With
	JOIN ShinerLitify..Account a
		ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c
	LEFT JOIN IndvOrgContacts_Indexed IOC
		ON IOC.saga_char = a.Id
	-- Law Firm
	LEFT JOIN sma_TRN_LawFirms stlf
		ON stlf.lwfnLawFirmID = IOC.CID
	-- Negotiated By
	JOIN ShinerSA..IndvOrgContacts_Indexed ioci
		ON ioci.saga_char = lpdc.OwnerId
	WHERE ISNULL(a.Type, '') <> ''
		AND a.Type IN ('Attorney')
GO



--AND lpdc.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'

--SELECT * FROM sma_TRN_LawFirms stlf
--SELECT * FROM helper_Negotiation_Party
----[sma_TRN_Negotiations]
--WHERE SAcaseID= 2553

/*
######################################################################
[1.0] Negotiations
######################################################################
*/

-- Add saga
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_char'
			AND object_id = OBJECT_ID(N'sma_TRN_Negotiations')
	)
BEGIN
	ALTER TABLE [sma_TRN_Negotiations] ADD saga_char VARCHAR(100) NULL;
END
GO


-- [2.2] Insert Negotiations
-- Source = 

--SELECT
--	*
--FROM [sma_TRN_Negotiations]
--WHERE negncaseId = 2553
--SELECT
--	*
--FROM sma_MST_IndvContacts smic
--WHERE smic.cinnContactID = 446
--SELECT
--	ownerid
--FROM ShinerLitify..litify_pm__Negotiation__c lpnc
--WHERE lpnc.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'

--0058Z000009TFzAQAW
--SELECT
--	*
--FROM shinersa..sma_mst_users
--WHERE saga = '0058Z000009TFzAQAW'
--truncate TABLE [sma_TRN_Negotiations]
--sp_help '[sma_TRN_Negotiations]'
INSERT INTO [dbo].[sma_TRN_Negotiations]
	(
	[negnCaseID]
   ,[negsUniquePartyID]		-- Negotiating With
   ,[negdDate]
   ,[negnStaffID]
   ,[negnPlaintiffID]
   ,[negbPartiallySettled]
   ,[negnClientAuthAmt]
   ,[negbOralConsent]
   ,[negdOralDtSent]
   ,[negdOralDtRcvd]
   ,[negnDemand]
   ,[negnOffer]
   ,[negbConsentType]
   ,[negnRecUserID]
   ,[negdDtCreated]
   ,[negnModifyUserID]
   ,[negdDtModified]
   ,[negnLevelNo]
   ,[negsComments]
   ,[negnPartyCompanyUid]
   ,[negnPartyIndividualUid]
   ,[saga_char]
	)
	SELECT DISTINCT
		cas.casnCaseID
	   ,CASE
			WHEN ISNULL(hnp.negsUniquePartyID, '') <> ''
				THEN hnp.negsUniquePartyID
			ELSE NULL
		END										AS [negsUniquePartyID]
	   ,CASE
			WHEN CONVERT(DATETIME, neg.litify_pm__Date__c) BETWEEN '1/1/1900' AND '12/31/2079'
				THEN CONVERT(DATETIME, litify_pm__Date__c)
			ELSE NULL
		END										AS negdDate
	   ,hnp.negotiatedBy						AS negnStaffID				 -- ds 2024-09-26
	   ,p.plnnPlaintiffID						AS [negnPlaintiffID]
	   ,NULL									AS [negbPartiallySettled]
	   ,NULL									AS [negnClientAuthAmt]
	   ,NULL									AS [negbOralConsent]
	   ,NULL									AS [negdOralDtSent]
	   ,NULL									AS [negdOralDtRcvd]
	   ,CASE
			WHEN neg.litify_pm__Type__c LIKE '%Demand%'
				THEN litify_pm__Amount__c
			ELSE NULL
		END										AS [negnDemand]
	   ,CASE
			WHEN neg.litify_pm__Type__c LIKE '%Offer%'
				THEN litify_pm__Amount__c
			ELSE NULL
		END										AS [negnOffer]
	   ,NULL									AS [negbConsentType]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga_char = OwnerId
		)										
		AS [negnRecUserID]
	   ,CONVERT(DATETIME, neg.CreatedDate)		AS [negdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga_char = LastModifiedById
		)										
		AS [negnModifyUserID]
	   ,CONVERT(DATETIME, neg.LastModifiedDate) AS [negdDtModified]
	   ,1										AS [negnLevelNo]
	   ,ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(500), neg.[Name]), '') + CHAR(13), '') +
		ISNULL('Type: ' + NULLIF(neg.litify_pm__Type__c, '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(4000), neg.litify_pm__Comments__c), '') + CHAR(13), '') +
		''										AS [negsComments]
	   ,NULL									AS [negnPartyCompanyUid]
	   ,NULL									AS [negnPartyIndividualUid]
	   ,neg.Id									AS [saga_char]
	--select *
	FROM ShinerLitify..[litify_pm__Negotiation__c] neg
	JOIN sma_TRN_Cases cas
		ON cas.saga_char = neg.litify_pm__Matter__c
	--RECEIVING PARTY / PLAINTIFF
	LEFT JOIN sma_TRN_Plaintiff p
		ON p.plnnCaseID = cas.casnCaseID
			AND p.plnbIsPrimary = 1
	-- Negotiating With
	LEFT JOIN IndvOrgContacts_Indexed ioc
		ON ioc.saga_char = neg.litify_ext__Negotiating_with_Party__c
	JOIN sma_MST_AllContactInfo smaci
		ON smaci.ContactId = ioc.CID
	LEFT JOIN helper_Negotiation_Party hnp
		ON hnp.SAcaseID = cas.casnCaseID
--	WHERE cas.casnCaseID = 2553
