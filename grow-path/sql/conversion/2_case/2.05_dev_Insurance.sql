/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-17
Description: Create insurance records

XINSTYPE__c
- Liability = defendant insurance
- Health = plaintiff insurance

1. add saga to sma_TRN_InsuranceCoverage
2. add insurance types [sma_MST_InsuranceType] from litify_pm__Insurance_Type__c
3. create insurance records [sma_TRN_InsuranceCoverage]
4. adjuster association [sma_MST_RelContacts]
 
--------------------------------------------------------------------------------------------------------------------------------------
Step				Object							Action			Source				Notes
--------------------------------------------------------------------------------------------------------------------------------------
[0] Placeholder Individual Contacts			
	[0.0]			sma_MST_IndvContacts			insert			hardcode			Unassigned Staff


[1.0] Users
	[1.1]			sma_MST_Address					insert			dbo.User
	

##########################################################################################################################
*/

USE ShinerSA
GO


----------------------------------
-- Validation


SELECT
	*
FROM ShinerSA..[sma_TRN_InsuranceCoverage]
WHERE incnCaseID = 2553
	AND incsPlaintiffOrDef = 'D'
SELECT
	*
FROM ShinerSA..sma_MST_OrgContacts smoc
WHERE smoc.connContactID = 32555
SELECT
	*
FROM ShinerSA..sma_MST_IndvContacts smic
WHERE smic.cinnContactID = 32555

SELECT
	*
FROM ShinerLitify..litify_pm__Insurance__c lpic
WHERE lpic.litify_pm__Insurance_Type__c IS NULL
SELECT
	*
FROM ShinerLitify..litify_pm__Role__c lprc
WHERE lprc.litify_pm__Role__c = 'Insurance Company'

SELECT
	*
FROM ShinerLitify..[User] u
WHERE id = '0058Z000008qiLUQAY'

SELECT DISTINCT
	rt.name
FROM shinerlitify..RecordType rt
JOIN shinerlitify..litify_pm__Insurance__c lpic
	ON lpic.RecordTypeId = LEFT(rt.Id, 15)

SELECT
	*
FROM ShinerLitify..Contact c


-- a0L8Z00000gFZlBUAW
SELECT top 1
lpic.id,
	lpic.litify_pm__Insurance_Company__c, lpic.litify_ext__Insurance_Company_Party__c, lpic.litify_pm__Adjuster__c, lpic.litify_ext__Adjuster_Party__c, lpic.litify_pm__Policy_Holder__c, lpic.litify_ext__Policy_Holder_Party__c
FROM ShinerLitify..litify_pm__Insurance__c lpic
WHERE lpic.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'
--where id ='a0k8Z00000CHT6WQAX'
--where lpic.id ='a0k8Z00000CHVPAQA5'
JOIN ShinerLitify..litify_pm__Role__c ON lipic.
select
	*
FROM ShinerLitify..litify_pm__Role__c lprc
WHERE lprc.litify_pm__Role__c = 'Insurance Company'


SELECT
    lpic.litify_pm__Insurance_Company__c,
    lpic.litify_ext__Insurance_Company_Party__c,
    role_ins.litify_pm__Party__c,
    CASE 
        WHEN role_ins.litify_pm__Party__c = lpic.litify_ext__Insurance_Company_Party__c THEN 'Match'
        ELSE 'No Match'
    END AS Insurance_Company_Match,
    lpic.litify_pm__Policy_Holder__c,
    lpic.litify_ext__Policy_Holder_Party__c,
    role_policy_holder.litify_pm__Party__c,
    lpic.litify_pm__Adjuster__c,
    lpic.litify_ext__Adjuster_Party__c,
    role_adjuster.litify_pm__Party__c
FROM ShinerLitify..litify_pm__Insurance__c lpic
JOIN ShinerLitify..litify_pm__Role__c AS role_ins
    ON role_ins.Id = lpic.litify_pm__Insurance_Company__c
JOIN ShinerLitify..litify_pm__Role__c AS role_policy_holder
    ON role_policy_holder.Id = lpic.litify_pm__Policy_Holder__c
JOIN ShinerLitify..litify_pm__Role__c AS role_adjuster
    ON role_adjuster.Id = lpic.litify_pm__Adjuster__c;


SELECT
   lpic.litify_pm__Matter__c as [matter_id]
	,lpic.id					[insurance_id]
   ,a.Name					AS [account_name]
   ,a1.name AS [account_name_from_role]
   --,lprc.litify_pm__Role__c AS [role.role]
   ,lpic.litify_pm__Insurance_Company__c
   ,lpic.litify_ext__Insurance_Company_Party__c
FROM ShinerLitify..litify_pm__Insurance__c lpic
LEFT JOIN ShinerLitify..litify_pm__Role__c lprc
	ON lprc.id = lpic.litify_pm__Insurance_Company__c
LEFT JOIN ShinerLitify..Account a
	ON a.Id = lpic.litify_ext__Insurance_Company_Party__c
LEFT JOIN ShinerLitify..Account a1
	ON a1.id = lprc.litify_pm__Party__c
WHERE lpic.litify_pm__Matter__c = 'a0L8Z00000ek7z1UAA'


select * FROM ShinerLitify..litify_pm__Role__c lprc

select * FROM ShinerLitify..Account a
select * FROM ShinerLitify..Contact c



----------------------------------

USE ShinerSA

/*
######################################################################
Data Table
######################################################################

- P or D
- ins comp
- adjuster
- policy holder
- sa case
- owner: ownerId > ioci.saga



*/



IF
	OBJECT_ID('helper_InsuranceCompanies', 'U') IS NOT NULL
BEGIN
	DROP TABLE helper_InsuranceCompanies;
END;

CREATE TABLE helper_InsuranceCompanies (
	InsuranceId VARCHAR(25)
   ,SACaseId INT
   ,LitifyCaseId VARCHAR(50)
   ,PlaintiffOrDefendant VARCHAR(1)
   ,PlaintiffId VARCHAR(25)
   ,DefendantId VARCHAR(25)
   ,InsuranceCompany VARCHAR(25)
   ,InsuranceCompanyAddress VARCHAR(25)
   ,Adjuster VARCHAR(25)
   ,AdjusterAddress VARCHAR(25)
   ,PolicyHolder VARCHAR(25)
   ,PolicyHolderUnqId VARCHAR(25)
   ,RecordType VARCHAR(25)
);
GO

INSERT INTO helper_InsuranceCompanies
	(
	InsuranceId
   ,SACaseId
   ,LitifyCaseId
   ,PlaintiffOrDefendant
   ,PlaintiffId
   ,DefendantId
   ,InsuranceCompany
   ,InsuranceCompanyAddress
   ,Adjuster
   ,AdjusterAddress
   ,PolicyHolder
   ,PolicyHolderUnqId
   ,RecordType
	)
	SELECT
		i.Id				 AS InsuranceId
	   ,cas.casnCaseID		 AS SAcaseID
	   ,cas.Litify_saga		 AS LitifyCaseId
	   ,CASE i.litify_pm__Insurance_Type__c
			WHEN NULL
				THEN 'D'
			ELSE 'P'
		END					 AS PlaintiffOrDefendant
	   ,plnn.plnnPlaintiffID AS PlaintiffId
	   ,def.defnDefendentID	 AS DefendantId
	   ,InsComp.CID			 AS InsuranceCompany
	   ,InsComp.aid			 AS InsuranceCompanyAddress
	   ,adj.cid				 AS Adjuster
	   ,adj.aid				 AS Adjuster
	   ,insured.cid			 AS PolicyHolder
	   ,insured.UNQCID		 AS PolicyHolderUnqId
	   ,rt.Name				 AS RecordType
	--select * 
	FROM [ShinerLitify]..litify_pm__Insurance__c i
	-- Case
	LEFT JOIN [sma_TRN_Cases] CAS
		ON cas.Litify_saga = i.litify_pm__Matter__c
	-- Insurance Company: Role > IOC
	LEFT JOIN [ShinerLitify]..litify_pm__Role__c m
		ON m.Id = i.litify_pm__Insurance_Company__c
			AND ISNULL(i.litify_pm__Insurance_Company__c, '') <> ''
	LEFT JOIN IndvOrgContacts_Indexed InsComp
		ON InsComp.saga = m.litify_pm__Party__c
			AND InsComp.CTG = 2
	-- Adjuster: Role > IOC
	LEFT JOIN [ShinerLitify]..litify_pm__Role__c madj
		ON madj.Id = i.litify_pm__Adjuster__c
			AND ISNULL(i.litify_pm__Adjuster__c, '') <> ''
			AND madj.litify_pm__Subtype__c = 'Adjuster'
	LEFT JOIN IndvOrgContacts_Indexed adj
		ON adj.saga = madj.litify_pm__Party__c
	-- Policy Holder: Role > IOC
	LEFT JOIN [ShinerLitify]..litify_pm__Role__c mpol
		ON mpol.Id = i.litify_pm__Policy_Holder__c
			AND ISNULL(i.litify_pm__Policy_Holder__c, '') <> ''
	LEFT JOIN IndvOrgContacts_Indexed insured
		ON insured.saga = mpol.litify_pm__Party__c
	-- Plaintiff
	LEFT JOIN [sma_TRN_Plaintiff] plnn
		ON plnn.plnnCaseID = cas.casnCaseID
			AND plnn.plnbIsPrimary = 1
	-- Defendant
	LEFT JOIN [sma_TRN_Defendants] def
		ON def.defnCaseID = cas.casnCaseID
			AND def.defbIsPrimary = 1
	-- RecordType
	LEFT JOIN ShinerLitify.dbo.RecordType rt
		ON i.RecordTypeId = LEFT(rt.Id, 15)
--		WHERE CAS.casnCaseID = 2553
GO





/*
select *
FROM [ShinerLitify]..litify_pm__insurance__c i
JOIN [ShinerLitify]..litify_pm__role__c m on m.id = i.litify_pm__Insurance_Company__c
JOIN [sma_TRN_Cases] CAS on CAS.saga = m.litify_pm__Matter__c
LEFT JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = m.litify_pm__Party__c and ioc.CTG = 1
LEFT JOIN IndvOrgContacts_Indexed IOCP on IOCP.SAGA = m.litify_pm__Party__c and ioc.ctg = 2
--JOIN [sma_TRN_Plaintiff] T on T.plnnContactID = IOCP.CID and T.plnnContactCtg = IOCP.CTG and T.plnnCaseID=CAS.casnCaseID
WHERE litify_pm__role__c  IN ('Insurance Company')
*/

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
BEGIN
	ALTER TABLE [sma_TRN_InsuranceCoverage] ADD [saga] VARCHAR(100)
END
GO

----------------------------
--INSURANCE TYPE
----------------------------
INSERT INTO [sma_MST_InsuranceType]
	(
	intsDscrptn
	)
	SELECT
		'Unspecified'
	UNION
	-- Adding the specific insurance types from the table
	SELECT
		'Health Insurance'
	UNION
	SELECT
		'Medicare'
	UNION
	SELECT
		'Medicaid'
	UNION
	SELECT
		'Preferred Provider Organization'
	UNION
	SELECT
		'Health Maintenance Organization'
	UNION
	SELECT
		'Liability'
	UNION
	-- Adding any other distinct insurance types not present in the table
	SELECT DISTINCT
		litify_pm__Insurance_Type__c
	FROM [ShinerLitify]..litify_pm__Insurance__c i
	WHERE ISNULL(litify_pm__Insurance_Type__c, '') <> ''
	EXCEPT
	-- Exclude insurance types that are already in the sma_MST_InsuranceType table
	SELECT
		intsDscrptn
	FROM [sma_MST_InsuranceType]
GO

---
ALTER TABLE [sma_TRN_InsuranceCoverage] DISABLE TRIGGER ALL
GO

----------------------------
-- Insurance Companies
----------------------------

INSERT INTO [sma_TRN_InsuranceCoverage]
	(
	[incnCaseID]
   ,[incnInsContactID]
   ,[incnInsAddressID]
   ,[incbCarrierHasLienYN]
   ,[incnInsType]
   ,[incnAdjContactId]
   ,[incnAdjAddressID]
   ,[incsPolicyNo]
   ,[incsClaimNo]
   ,[incnStackedTimes]
   ,[incsComments]
   ,[incnInsured]
   ,[incnCovgAmt]
   ,[incnDeductible]
   ,[incnUnInsPolicyLimit]
   ,[incnUnderPolicyLimit]
   ,[incbPolicyTerm]
   ,[incbTotCovg]
   ,[incsPlaintiffOrDef]
   ,[incnPlaintiffIDOrDefendantID]
   ,[incnTPAdminOrgID]
   ,[incnTPAdminAddID]
   ,[incnTPAdjContactID]
   ,[incnTPAdjAddID]
   ,[incsTPAClaimNo]
   ,[incnRecUserID]
   ,[incdDtCreated]
   ,[incnModifyUserID]
   ,[incdDtModified]
   ,[incnLevelNo]
   ,[incnUnInsPolicyLimitAcc]
   ,[incnUnderPolicyLimitAcc]
   ,[incb100Per]
   ,[incnMVLeased]
   ,[incnPriority]
   ,[incbDelete]
   ,[incnauthtodefcoun]
   ,[incnauthtodefcounDt]
   ,[incbPrimary]
   ,[saga]
	)
	SELECT DISTINCT
		help.SACaseId							AS [incnCaseID]
	   ,help.InsuranceCompany					AS [incnInsContactID]
	   ,help.InsuranceCompanyAddress			AS [incnInsAddressID]
	   ,0										AS [incbCarrierHasLienYN]
	   ,(
			SELECT
				intnInsuranceTypeID, intsDscrptn
			FROM [sma_MST_InsuranceType]
			WHERE intsDscrptn = CASE
					WHEN ISNULL(litify_pm__Insurance_Type__c, '') = ''
						THEN 'Liability'
					WHEN litify_pm__Insurance_Type__c = 'HMO'
						THEN 'Health Maintenance Organization'
					WHEN litify_pm__Insurance_Type__c = 'PPO'
						THEN 'Preferred Provider Organization'
					WHEN litify_pm__Insurance_Type__c = 'Health'
						THEN 'Health Insurance'
					WHEN litify_pm__Insurance_Type__c = 'Medicare'
						THEN 'Medicare'
					WHEN litify_pm__Insurance_Type__c = 'Medicaid'
						THEN 'Medicaid'
					ELSE ISNULL(litify_pm__Insurance_Type__c, 'Unspecified')
				END
		)										
		AS [incnInsType]
	   ,help.Adjuster							AS [incnAdjContactId]
	   ,help.AdjusterAddress					AS [incnAdjAddressID]
	   ,LEFT(i.litify_pm__Policy_Number__c, 30) AS [incsPolicyNo]
	   ,LEFT(i.litify_pm__Claim_Number__c, 30)  AS [incsClaimNo]
	   ,NULL									AS [incnStackedTimes]
	   ,ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR, i.[Name]), '') + CHAR(13), '') +
		ISNULL('Policy Number: ' + NULLIF(CONVERT(VARCHAR, i.litify_pm__Policy_Number__c), '') + CHAR(13), '') +
		ISNULL('Claim Number: ' + NULLIF(CONVERT(VARCHAR, i.litify_pm__Claim_Number__c), '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR, i.[litify_pm__Comments__c]), '') + CHAR(13), '') +
		''										AS [incsComments]
		--ISNULL('Their Number: ' + NULLIF(CONVERT(VARCHAR, i.[their_number__c]), '') + CHAR(13), '') +
		--ISNULL('Policy Limit: ' + NULLIF(CONVERT(VARCHAR, i.[Policy_limit__c]), '') + CHAR(13), '') +
	   ,help.PolicyHolderUnqId					AS [incnInsured]
	   ,NULL									AS [incnCovgAmt]
	   ,NULL									AS [incnDeductible]
	   ,NULL									AS [incnUnInsPolicyLimit]
	   ,NULL									AS [incnUnderPolicyLimit]
	   ,0										AS [incbPolicyTerm]
	   ,0										AS [incbTotCovg]
	   ,help.PlaintiffOrDefendant				AS [incsPlaintiffOrDef]
	   ,CASE help.PlaintiffOrDefendant
			WHEN 'P'
				THEN help.PlaintiffId
			WHEN 'D'
				THEN help.DefendantId
			ELSE help.PlaintiffId
		END										[incnPlaintiffIDOrDefendantID]
	   ,NULL									AS [incnTPAdminOrgID]
	   ,NULL									AS [incnTPAdminAddID]
	   ,NULL									AS [incnTPAdjContactID]
	   ,NULL									AS [incnTPAdjAddID]
	   ,NULL									AS [incsTPAClaimNo]
	   ,368										AS [incnRecUserID]
	   ,GETDATE()								AS [incdDtCreated]
	   ,NULL									AS [incnModifyUserID]
	   ,NULL									AS [incdDtModified]
	   ,NULL									AS [incnLevelNo]
	   ,NULL									AS [incnUnInsPolicyLimitAcc]
	   ,NULL									AS [incnUnderPolicyLimitAcc]
	   ,0										AS [incb100Per]
	   ,NULL									AS [incnMVLeased]
	   ,NULL									AS [incnPriority]
	   ,0										AS [incbDelete]
	   ,0										AS [incnauthtodefcoun]
	   ,NULL									AS [incnauthtodefcounDt]
	   ,0										AS [incbPrimary]
	   ,i.Id									AS [saga]
	FROM [ShinerLitify]..litify_pm__Insurance__c i
	JOIN helper_InsuranceCompanies help
		ON help.LitifyCaseId = i.litify_pm__Matter__c
	WHERE help.InsuranceId = i.id --and help.SACaseId = 2553
GO


--	SELECT distinct
--	help.SACaseId AS [incnCaseID]
--   ,help.InsuranceCompany									AS [incnInsContactID]
--   ,help.InsuranceCompanyAddress AS [incnInsAddressID]
--   ,0										AS [incbCarrierHasLienYN]
--   ,(
--		SELECT
--			intnInsuranceTypeID
--		FROM [sma_MST_InsuranceType]
--		WHERE intsDscrptn = ISNULL(litify_pm__Insurance_Type__c, 'Unspecified')
--	)										
--	AS [incnInsType]
--   ,help.Adjuster									AS [incnAdjContactId]
--   ,help.AdjusterAddress								AS [incnAdjAddressID]
--   ,LEFT(i.litify_pm__Policy_Number__c, 30) AS [incsPolicyNo]
--   ,LEFT(i.litify_pm__Claim_Number__c, 30)  AS [incsClaimNo]
--   ,NULL									AS [incnStackedTimes]
--   ,ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR, i.[Name]), '') + CHAR(13), '') +
--	ISNULL('Policy Number: ' + NULLIF(CONVERT(VARCHAR, i.litify_pm__Policy_Number__c), '') + CHAR(13), '') +
--	ISNULL('Claim Number: ' + NULLIF(CONVERT(VARCHAR, i.litify_pm__Claim_Number__c), '') + CHAR(13), '') +
--	ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR, i.[litify_pm__Comments__c]), '') + CHAR(13), '') +
--	''										AS [incsComments]
--	--ISNULL('Their Number: ' + NULLIF(CONVERT(VARCHAR, i.[their_number__c]), '') + CHAR(13), '') +
--	--ISNULL('Policy Limit: ' + NULLIF(CONVERT(VARCHAR, i.[Policy_limit__c]), '') + CHAR(13), '') +
--   ,help.PolicyHolderUnqId							AS [incnInsured]
--   ,NULL									AS [incnCovgAmt]
--   ,NULL									AS [incnDeductible]
--   ,NULL									AS [incnUnInsPolicyLimit]
--   ,NULL									AS [incnUnderPolicyLimit]
--   ,0										AS [incbPolicyTerm]
--   ,0										AS [incbTotCovg]
--   ,help.PlaintiffOrDefendant				 AS [incsPlaintiffOrDef]
--   ,CASE help.PlaintiffOrDefendant
--		when 'P' THEN help.PlaintiffId
--		when 'D' THEN help.DefendantId
--		ELSE help.PlaintiffId
--	END [incnPlaintiffIDOrDefendantID]
--   ,NULL									AS [incnTPAdminOrgID]
--   ,NULL									AS [incnTPAdminAddID]
--   ,NULL									AS [incnTPAdjContactID]
--   ,NULL									AS [incnTPAdjAddID]
--   ,NULL									AS [incsTPAClaimNo]
--   ,368										AS [incnRecUserID]
--   ,GETDATE()								AS [incdDtCreated]
--   ,NULL									AS [incnModifyUserID]
--   ,NULL									AS [incdDtModified]
--   ,NULL									AS [incnLevelNo]
--   ,NULL									AS [incnUnInsPolicyLimitAcc]
--   ,NULL									AS [incnUnderPolicyLimitAcc]
--   ,0										AS [incb100Per]
--   ,NULL									AS [incnMVLeased]
--   ,NULL									AS [incnPriority]
--   ,0										AS [incbDelete]
--   ,0										AS [incnauthtodefcoun]
--   ,NULL									AS [incnauthtodefcounDt]
--   ,0										AS [incbPrimary]
--   ,i.Id									AS [saga]
--FROM [ShinerLitify]..litify_pm__Insurance__c i
--JOIN helper_InsuranceCompanies help
--on help.LitifyCaseId = i.litify_pm__Matter__c
--order by incnCaseID


GO

---
ALTER TABLE [sma_TRN_InsuranceCoverage] ENABLE TRIGGER ALL
GO
---

---(Adjuster/Insurer association)---
INSERT INTO [sma_MST_RelContacts]
	(
	[rlcnPrimaryCtgID]
   ,[rlcnPrimaryContactID]
   ,[rlcnPrimaryAddressID]
   ,[rlcnRelCtgID]
   ,[rlcnRelContactID]
   ,[rlcnRelAddressID]
   ,[rlcnRelTypeID]
   ,[rlcnRecUserID]
   ,[rlcdDtCreated]
   ,[rlcnModifyUserID]
   ,[rlcdDtModified]
   ,[rlcnLevelNo]
   ,[rlcsBizFam]
   ,[rlcnOrgTypeID]
	)
	SELECT DISTINCT
		1					  AS [rlcnPrimaryCtgID]
	   ,IC.[incnAdjContactId] AS [rlcnPrimaryContactID]
	   ,IC.[incnAdjAddressID] AS [rlcnPrimaryAddressID]
	   ,2					  AS [rlcnRelCtgID]
	   ,IC.[incnInsContactID] AS [rlcnRelContactID]
	   ,IC.[incnAdjAddressID] AS [rlcnRelAddressID]
	   ,2					  AS [rlcnRelTypeID]
	   ,368					  AS [rlcnRecUserID]
	   ,GETDATE()			  AS [rlcdDtCreated]
	   ,NULL				  AS [rlcnModifyUserID]
	   ,NULL				  AS [rlcdDtModified]
	   ,NULL				  AS [rlcnLevelNo]
	   ,'Business'			  AS [rlcsBizFam]
	   ,NULL				  AS [rlcnOrgTypeID]
	FROM [sma_TRN_InsuranceCoverage] IC
	WHERE ISNULL(IC.[incnAdjContactId], 0) <> 0
		AND ISNULL(IC.[incnInsContactID], 0) <> 0






-- Count of insurance records in the source table (Litify)
SELECT
	COUNT(*) AS SourceRecordCount
FROM ShinerLitify..litify_pm__Insurance__c;

-- Count of insurance records in the target table (ShinerSA)
SELECT
	COUNT(*) AS TargetRecordCount
FROM ShinerSA..sma_TRN_InsuranceCoverage;

-- 3. Show records that are in the source but missing in the target (source records not transferred)
SELECT
	i.Id				AS SourceRecordId
   ,'Missing in Target' AS RecordStatus
FROM ShinerLitify..litify_pm__Insurance__c i
LEFT JOIN ShinerSA..sma_TRN_InsuranceCoverage ic
	ON i.Id = ic.saga
WHERE ic.saga IS NULL;

-- 4. Show records that are in the target but not in the source (extra records in target)
SELECT
	ic.saga			  AS TargetRecordId
   ,'Extra in Target' AS RecordStatus
FROM ShinerSA..sma_TRN_InsuranceCoverage ic
LEFT JOIN ShinerLitify..litify_pm__Insurance__c i
	ON ic.saga = i.Id
WHERE i.Id IS NULL;
