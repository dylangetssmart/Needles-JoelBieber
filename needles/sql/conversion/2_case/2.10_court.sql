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

USE [JoelBieberSA_Needles]
GO
---
ALTER TABLE [sma_trn_caseJudgeorClerk] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_CourtDocket] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Courts] DISABLE TRIGGER ALL
GO
---

--SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactTypeID = (select
--					octnOrigContactTypeID
--				from [dbo].[sma_MST_OriginalContactTypes]
--				where octsDscrptn = 'Law Clerk'
--					and octnContactCtgID = 1)



---(1)---
INSERT INTO [sma_TRN_Courts]
	(
	crtnCaseID, crtnCourtID, crtnCourtAddId, crtnIsActive, crtnLevelNo
	)
	SELECT
		A.casnCaseID AS crtnCaseID
	   ,A.CID		 AS crtnCourtID
	   ,A.AID		 AS crtnCourtAddId
	   ,1			 AS crtnIsActive
	   ,A.judge_link AS crtnLevelNo -- remembering judge_link
	FROM (
		SELECT
			CAS.casnCaseID
		   ,IOC.CID
		   ,IOC.AID
		   ,C.judge_link
		FROM [JoelBieberNeedles].[dbo].[cases] C
		JOIN [sma_TRN_cases] CAS
			ON CAS.cassCaseNumber = C.casenum
		JOIN IndvOrgContacts_Indexed IOC
			ON IOC.SAGA = C.court_link
		WHERE ISNULL(court_link, 0) <> 0

		UNION

		SELECT
			CAS.casnCaseID
		   ,IOC.CID
		   ,IOC.AID
		   ,C.judge_link
		FROM [JoelBieberNeedles].[dbo].[cases] C
		JOIN [sma_TRN_cases] CAS
			ON CAS.cassCaseNumber = C.casenum
		JOIN IndvOrgContacts_Indexed IOC
			ON IOC.SAGA = -1
			AND IOC.[Name] = 'Unidentified Court'
		WHERE ISNULL(court_link, 0) = 0
			AND (
			ISNULL(judge_link, 0) <> 0
			OR docket <> ''
			)
	) A
GO

---(2)---
INSERT INTO [sma_TRN_CourtDocket]
	(
	crdnCourtsID, crdnIndexTypeID, crdnDocketNo, crdnPrice, crdbActiveInActive, crdsEfile, crdsComments
	)
	SELECT
		crtnPKCourtsID AS crdnCourtsID
	   ,(
			SELECT
				idtnIndexTypeID
			FROM sma_MST_IndexType
			WHERE idtsDscrptn = 'Index Number'
		)			   
		AS crdnIndexTypeID
	   ,CASE
			WHEN ISNULL(C.docket, '') <> ''
				THEN LEFT(C.docket, 30)
			ELSE 'Case-' + CAS.cassCaseNumber
		END			   AS crdnDocketNo
	   ,0			   AS crdnPrice
	   ,1			   AS crdbActiveInActive
	   ,0			   AS crdsEfile
	   ,'Docket Number:' + LEFT(C.docket, 30)
		AS crdsComments
	FROM [sma_TRN_Courts] CRT
	JOIN [sma_TRN_cases] CAS
		ON CAS.casnCaseID = CRT.crtnCaseID
	JOIN [JoelBieberNeedles].[dbo].[cases] C
		ON C.casenum = CAS.cassCaseNumber
GO

---(3)---
INSERT INTO [sma_trn_caseJudgeorClerk]
	(
	crtDocketID, crtJudgeorClerkContactID, crtJudgeorClerkContactCtgID, crtJudgeorClerkRoleID
	)
	SELECT DISTINCT
		CRD.crdnCourtDocketID AS crtDocketID
	   ,IOC.CID				  AS crtJudgeorClerkContactID
	   ,IOC.CTG				  AS crtJudgeorClerkContactCtgID
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM sma_MST_OriginalContactTypes
			WHERE octsDscrptn = 'Judge'
		)					  
		AS crtJudgeorClerkRoleID
	FROM [sma_TRN_CourtDocket] CRD
	JOIN [sma_TRN_Courts] CRT
		ON CRT.crtnPKCourtsID = CRD.crdnCourtsID
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA = CRT.crtnLevelNo  -- ( crtnLevelNo --> C.judge_link )
	WHERE ISNULL(crtnLevelNo, 0) <> 0


