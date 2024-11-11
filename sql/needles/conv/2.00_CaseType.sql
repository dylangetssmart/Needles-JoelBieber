-- Author: Dylan Smith
-- Date: 2024-09-09
-- Description: Brief description of the script's purpose

/*
This script performs the following tasks:
  - [Task 1]
  - [Task 2]
  - ...

Notes:
	- Because batch separators (GO) are required due to schema changes (adding columns),
	we use a temporary table instead of variables, which are locally scoped
	see: https://learn.microsoft.com/en-us/sql/t-sql/language-elements/variables-transact-sql?view=sql-server-ver16#variable-scope
	see also: https://stackoverflow.com/a/56370223
	- After making schema changes (e.g. adding a new column to an existing table) statements using the new schema must be compiled separately in a different batch.
	- For example, you cannot ALTER a table to add a column, then select that column in the same batch - because while compiling the execution plan, that column does not exist for selecting.
*/

USE JoelBieberSA_Needles
GO

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_db'
			AND object_id = OBJECT_ID(N'sma_trn_Cases')
	)
BEGIN
	ALTER TABLE sma_trn_Cases ADD [saga_db] VARCHAR(5);
END
GO

-- Create a temporary table to store variable values
DROP TABLE IF EXISTS #TempVariables;

CREATE TABLE #TempVariables (
	OfficeName NVARCHAR(255)
   ,StateName NVARCHAR(100)
   ,PhoneNumber NVARCHAR(50)
   ,CaseGroup NVARCHAR(100)
   ,VenderCaseType NVARCHAR(25)
);

-- Insert values into the temporary table
INSERT INTO #TempVariables
	(
	OfficeName
   ,StateName
   ,PhoneNumber
   ,CaseGroup
   ,VenderCaseType
	)
VALUES (
'Joel Bieber LLC', 'Virginia', '8048008000', 'Needles', 'JoelBieberCaseType'
);


-- (0.1) sma_MST_CaseGroup -----------------------------------------------------
-- Create a default case group for data that does not neatly fit elsewhere
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_CaseGroup]
		WHERE [cgpsDscrptn] = (
				SELECT
					CaseGroup
				FROM #TempVariables
			)
	)
BEGIN
	INSERT INTO [sma_MST_CaseGroup]
		(
		[cgpsCode]
	   ,[cgpsDscrptn]
	   ,[cgpnRecUserId]
	   ,[cgpdDtCreated]
	   ,[cgpnModifyUserID]
	   ,[cgpdDtModified]
	   ,[cgpnLevelNo]
	   ,[IncidentTypeID]
	   ,[LimitGroupStatuses]
		)
		SELECT
			'FORCONVERSION' AS [cgpsCode]
		   ,(
				SELECT
					CaseGroup
				FROM #TempVariables
			)				
			AS [cgpsDscrptn]
		   ,368				AS [cgpnRecUserId]
		   ,GETDATE()		AS [cgpdDtCreated]
		   ,NULL			AS [cgpnModifyUserID]
		   ,NULL			AS [cgpdDtModified]
		   ,NULL			AS [cgpnLevelNo]
		   ,(
				SELECT
					IncidentTypeID
				FROM [sma_MST_IncidentTypes]
				WHERE Description = 'General Negligence'
			)				
			AS [IncidentTypeID]
		   ,NULL			AS [LimitGroupStatuses]
END
GO


-- (0.2) sma_MST_Offices -----------------------------------------------------
-- Create an office for conversion client
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_mst_offices]
		WHERE office_name = (
				SELECT
					OfficeName
				FROM #TempVariables
			)
	)
BEGIN
	INSERT INTO [sma_mst_offices]
		(
		[office_status]
	   ,[office_name]
	   ,[state_id]
	   ,[is_default]
	   ,[date_created]
	   ,[user_created]
	   ,[date_modified]
	   ,[user_modified]
	   ,[Letterhead]
	   ,[UniqueContactId]
	   ,[PhoneNumber]
		)
		SELECT
			1					AS [office_status]
		   ,(
				SELECT
					OfficeName
				FROM #TempVariables
			)					
			AS [office_name]
		   ,(
				SELECT
					sttnStateID
				FROM sma_MST_States
				WHERE sttsDescription = (
						SELECT
							StateName
						FROM #TempVariables
					)
			)					
			AS [state_id]
		   ,1					AS [is_default]
		   ,GETDATE()			AS [date_created]
		   ,'dsmith'			AS [user_created]
		   ,GETDATE()			AS [date_modified]
		   ,'dbo'				AS [user_modified]
		   ,'LetterheadUt.docx' AS [Letterhead]
		   ,NULL				AS [UniqueContactId]
		   ,(
				SELECT
					PhoneNumber
				FROM #TempVariables
			)					
			AS [PhoneNumber]
END
GO


-- (1) sma_MST_CaseType -----------------------------------------------------
-- (1.1) - Add a case type field that acts as conversion flag
-- for future reference: "VenderCaseType"
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'VenderCaseType'
			AND object_id = OBJECT_ID(N'sma_MST_CaseType')
	)
BEGIN
	ALTER TABLE sma_MST_CaseType
	ADD VenderCaseType VARCHAR(100)
END
GO

-- (1.2) - Create case types from CaseTypeMixtures
INSERT INTO [sma_MST_CaseType]
	(
	[cstsCode]
   ,[cstsType]
   ,[cstsSubType]
   ,[cstnWorkflowTemplateID]
   ,[cstnExpectedResolutionDays]
   ,[cstnRecUserID]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbTimeTracking]
   ,[cstnGroupID]
   ,[cstnGovtMunType]
   ,[cstnIsMassTort]
   ,[cstnStatusID]
   ,[cstnStatusTypeID]
   ,[cstbActive]
   ,[cstbUseIncident1]
   ,[cstsIncidentLabel1]
   ,[VenderCaseType]
	)
	SELECT
		NULL					  AS cstsCode
	   ,[SmartAdvocate Case Type] AS cstsType
	   ,NULL					  AS cstsSubType
	   ,NULL					  AS cstnWorkflowTemplateID
	   ,720						  AS cstnExpectedResolutionDays 		-- ( Hardcode 2 years )
	   ,368						  AS cstnRecUserID
	   ,GETDATE()				  AS cstdDtCreated
	   ,368						  AS cstnModifyUserID
	   ,GETDATE()				  AS cstdDtModified
	   ,0						  AS cstnLevelNo
	   ,NULL					  AS cstbTimeTracking
	   ,(
			SELECT
				cgpnCaseGroupID
			FROM sma_MST_caseGroup
			WHERE cgpsDscrptn = (
					SELECT
						CaseGroup
					FROM #TempVariables
				)
		)						  
		AS cstnGroupID
	   ,NULL					  AS cstnGovtMunType
	   ,NULL					  AS cstnIsMassTort
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						  
		AS cstnStatusID
	   ,(
			SELECT
				stpnStatusTypeID
			FROM [sma_MST_CaseStatusType]
			WHERE stpsStatusType = 'Status'
		)						  
		AS cstnStatusTypeID
	   ,1						  AS cstbActive
	   ,1						  AS cstbUseIncident1
	   ,'Incident 1'			  AS cstsIncidentLabel1
	   ,(
			SELECT
				VenderCaseType
			FROM #TempVariables
		)						  
		AS VenderCaseType
	FROM [CaseTypeMixture] MIX
	LEFT JOIN [sma_MST_CaseType] ct
		ON ct.cststype = mix.[SmartAdvocate Case Type]
	WHERE ct.cstnCaseTypeID IS NULL
GO

-- (1.3) - Add conversion flag to case types created above
UPDATE [sma_MST_CaseType]
SET VenderCaseType = (
	SELECT
		VenderCaseType
	FROM #TempVariables
)
FROM [CaseTypeMixture] MIX
JOIN [sma_MST_CaseType] ct
	ON ct.cststype = mix.[SmartAdvocate Case Type]
WHERE ISNULL(VenderCaseType, '') = ''
GO

-- (2) sma_MST_CaseSubType -----------------------------------------------------
-- (2.1) - sma_MST_CaseSubTypeCode
-- For non-null values of SA Case Sub Type from CaseTypeMixture,
-- add distinct values to CaseSubTypeCode and populate stcsDscrptn
INSERT INTO [dbo].[sma_MST_CaseSubTypeCode]
	(
	stcsDscrptn
	)
	SELECT DISTINCT
		MIX.[SmartAdvocate Case Sub Type]
	FROM [CaseTypeMixture] MIX
	WHERE ISNULL(MIX.[SmartAdvocate Case Sub Type], '') <> ''
	EXCEPT
	SELECT
		stcsDscrptn
	FROM [dbo].[sma_MST_CaseSubTypeCode]
GO

-- (2.2) - sma_MST_CaseSubType
-- Construct CaseSubType using CaseTypes
INSERT INTO [sma_MST_CaseSubType]
	(
	[cstsCode]
   ,[cstnGroupID]
   ,[cstsDscrptn]
   ,[cstnRecUserId]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbDefualt]
   ,[saga]
   ,[cstnTypeCode]
	)
	SELECT
		NULL						  AS [cstsCode]
	   ,cstnCaseTypeID				  AS [cstnGroupID]
	   ,[SmartAdvocate Case Sub Type] AS [cstsDscrptn]
	   ,368							  AS [cstnRecUserId]
	   ,GETDATE()					  AS [cstdDtCreated]
	   ,NULL						  AS [cstnModifyUserID]
	   ,NULL						  AS [cstdDtModified]
	   ,NULL						  AS [cstnLevelNo]
	   ,1							  AS [cstbDefualt]
	   ,NULL						  AS [saga]
	   ,(
			SELECT
				stcnCodeId
			FROM [sma_MST_CaseSubTypeCode]
			WHERE stcsDscrptn = [SmartAdvocate Case Sub Type]
		)							  
		AS [cstnTypeCode]
	FROM [sma_MST_CaseType] CST
	JOIN [CaseTypeMixture] MIX
		ON MIX.[SmartAdvocate Case Type] = CST.cststype
	LEFT JOIN [sma_MST_CaseSubType] sub
		ON sub.[cstnGroupID] = cstnCaseTypeID
			AND sub.[cstsDscrptn] = [SmartAdvocate Case Sub Type]
	WHERE sub.cstnCaseSubTypeID IS NULL
		AND ISNULL([SmartAdvocate Case Sub Type], '') <> ''


/*
---(2.2) sma_MST_CaseSubType
insert into [sma_MST_CaseSubType]
(
       [cstsCode]
      ,[cstnGroupID]
      ,[cstsDscrptn]
      ,[cstnRecUserId]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbDefualt]
      ,[saga]
      ,[cstnTypeCode]
)
select  	null				as [cstsCode],
		cstncasetypeid		as [cstnGroupID],
		MIX.[SmartAdvocate Case Sub Type] as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1				as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=MIX.[SmartAdvocate Case Sub Type]) as [cstnTypeCode] 
FROM [sma_MST_CaseType] CST 
JOIN [CaseTypeMixture] MIX on MIX.matcode=CST.cstsCode  
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] = cstncasetypeid and sub.[cstsDscrptn] = MIX.[SmartAdvocate Case Sub Type]
WHERE isnull(MIX.[SmartAdvocate Case Type],'')<>''
and sub.cstncasesubtypeID is null
*/


-- (3.0) sma_MST_SubRole -----------------------------------------------------
INSERT INTO [sma_MST_SubRole]
	(
	[sbrsCode]
   ,[sbrnRoleID]
   ,[sbrsDscrptn]
   ,[sbrnCaseTypeID]
   ,[sbrnPriority]
   ,[sbrnRecUserID]
   ,[sbrdDtCreated]
   ,[sbrnModifyUserID]
   ,[sbrdDtModified]
   ,[sbrnLevelNo]
   ,[sbrbDefualt]
   ,[saga]
	)
	SELECT
		[sbrsCode]		   AS [sbrsCode]
	   ,[sbrnRoleID]	   AS [sbrnRoleID]
	   ,[sbrsDscrptn]	   AS [sbrsDscrptn]
	   ,CST.cstnCaseTypeID AS [sbrnCaseTypeID]
	   ,[sbrnPriority]	   AS [sbrnPriority]
	   ,[sbrnRecUserID]	   AS [sbrnRecUserID]
	   ,[sbrdDtCreated]	   AS [sbrdDtCreated]
	   ,[sbrnModifyUserID] AS [sbrnModifyUserID]
	   ,[sbrdDtModified]   AS [sbrdDtModified]
	   ,[sbrnLevelNo]	   AS [sbrnLevelNo]
	   ,[sbrbDefualt]	   AS [sbrbDefualt]
	   ,[saga]			   AS [saga]
	FROM sma_MST_CaseType CST
	LEFT JOIN sma_mst_subrole S
		ON CST.cstnCaseTypeID = S.sbrnCaseTypeID
			OR S.sbrnCaseTypeID = 1
	JOIN [CaseTypeMixture] MIX
		ON MIX.matcode = CST.cstsCode
	WHERE VenderCaseType = (
			SELECT
				VenderCaseType
			FROM #TempVariables
		)
		AND ISNULL(MIX.[SmartAdvocate Case Type], '') = ''

-- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
UPDATE sma_MST_SubRole
SET sbrnTypeCode = A.CodeId
FROM (
	SELECT
		S.sbrsDscrptn AS sbrsDscrptn
	   ,S.sbrnSubRoleId AS SubRoleId
	   ,(
			SELECT
				MAX(srcnCodeId)
			FROM sma_MST_SubRoleCode
			WHERE srcsDscrptn = S.sbrsDscrptn
		)
		AS CodeId
	FROM sma_MST_SubRole S
	JOIN sma_MST_CaseType CST
		ON CST.cstnCaseTypeID = S.sbrnCaseTypeID
		AND CST.VenderCaseType = (
			SELECT
				VenderCaseType
			FROM #TempVariables
		)
) A
WHERE A.SubRoleId = sbrnSubRoleId


-- (4) specific plaintiff and defendant party roles ----------------------------------------------------
-- roleId 4 -> plaintiff
-- roleId 5 -> defendant
--INSERT INTO [sma_MST_SubRoleCode]
--	(
--	srcsDscrptn
--   ,srcnRoleID
--	)
--	(
--	SELECT
--		'(P)-Default Role'
--	   ,4

--	UNION ALL

--	SELECT
--		'(D)-Default Role'
--	   ,5

--	UNION ALL

--	SELECT
--		[SA Roles]
--	   ,4
--	FROM [PartyRoles]
--	WHERE [SA Party] = 'Plaintiff'

--	UNION ALL

--	SELECT
--		[SA Roles]
--	   ,5
--	FROM [PartyRoles]
--	WHERE [SA Party] = 'Defendant'

--	-- co-counsel
--	UNION ALL
--	SELECT
--		'(P)-CO-COUNSEL'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-CO-COUNSEL'


--	   ,5
--	-- driver
--	UNION ALL
--	SELECT
--		'(P)-Driver'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-Driver'
--	   ,5
--	-- Ins Adjuster
--	UNION ALL
--	SELECT
--		'(P)-Adjuster'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-Adjuster'
--	   ,5
--	-- Owner
--	UNION ALL
--	SELECT
--		'(P)-Owner'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-Owner'
--	   ,5
--	-- PROPERTY OWNER
--	UNION ALL
--	SELECT
--		'(P)-PROPERTY OWNER'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-PROPERTY OWNER'
--	   ,5




--	)
--	EXCEPT
--	SELECT
--		srcsDscrptn
--	   ,srcnRoleID
--	FROM [sma_MST_SubRoleCode]
INSERT INTO [sma_MST_SubRoleCode] (srcsDscrptn, srcnRoleID)
(
    -- Default Roles
    SELECT '(P)-Default Role', 4
    UNION ALL
    SELECT '(D)-Default Role', 5

    -- Roles from PartyRoles table
    UNION ALL
    SELECT [SA Roles], 4 FROM [PartyRoles] WHERE [SA Party] = 'Plaintiff'
    UNION ALL
    SELECT [SA Roles], 5 FROM [PartyRoles] WHERE [SA Party] = 'Defendant'

    -- party.role = "CO-COUNSEL"
    UNION ALL
    SELECT '(P)-CO-COUNSEL', 4
    UNION ALL
    SELECT '(D)-CO-COUNSEL', 5

    -- party.role = "DRIVER"
    UNION ALL
    SELECT '(P)-DRIVER', 4
    UNION ALL
    SELECT '(D)-DRIVER', 5

    -- party.role = "INS ADJUSTER"
    UNION ALL
    SELECT '(P)-ADJUSTER', 4
    UNION ALL
    SELECT '(D)-ADJUSTER', 5

    -- party.role = "OWNER"
    UNION ALL
    SELECT '(P)-OWNER', 4
    UNION ALL
    SELECT '(D)-OWNER', 5

    -- party.role = "PROPERTY OWNER"
    UNION ALL
    SELECT '(P)-PROPERTY OWNER', 4
    UNION ALL
    SELECT '(D)-PROPERTY OWNER', 5
)
EXCEPT
SELECT srcsDscrptn, srcnRoleID
FROM [sma_MST_SubRoleCode];


-- (4.1) Not already in sma_MST_SubRole-----
INSERT INTO sma_MST_SubRole
    (sbrnRoleID, sbrsDscrptn, sbrnCaseTypeID, sbrnTypeCode)
SELECT
    NewRoles.sbrnRoleID,
    NewRoles.sbrsDscrptn,
    NewRoles.sbrnCaseTypeID,
    SubRoleCodes.srcnCodeId AS sbrnTypeCode
FROM (
    SELECT
        R.PorD AS sbrnRoleID,
        R.[role] AS sbrsDscrptn,
        CST.cstnCaseTypeID AS sbrnCaseTypeID
    FROM sma_MST_CaseType CST
    CROSS JOIN (
        -- Default Roles
        SELECT '(P)-Default Role' AS role, 4 AS PorD
        UNION ALL
        SELECT '(D)-Default Role' AS role, 5 AS PorD
        
        -- Roles from PartyRoles table
        UNION ALL
        SELECT [SA Roles] AS role, 4 AS PorD FROM [PartyRoles] WHERE [SA Party] = 'Plaintiff'
        UNION ALL
        SELECT [SA Roles] AS role, 5 AS PorD FROM [PartyRoles] WHERE [SA Party] = 'Defendant'
        
        -- Specific Roles
        UNION ALL
        SELECT '(P)-CO-COUNSEL', 4
        UNION ALL
        SELECT '(D)-CO-COUNSEL', 5
        UNION ALL
        SELECT '(P)-DRIVER', 4
        UNION ALL
        SELECT '(D)-DRIVER', 5
        UNION ALL
        SELECT '(P)-ADJUSTER', 4
        UNION ALL
        SELECT '(D)-ADJUSTER', 5
        UNION ALL
        SELECT '(P)-OWNER', 4
        UNION ALL
        SELECT '(D)-OWNER', 5
        UNION ALL
        SELECT '(P)-PROPERTY OWNER', 4
        UNION ALL
        SELECT '(D)-PROPERTY OWNER', 5
    ) R
    WHERE CST.VenderCaseType = (
        SELECT VenderCaseType FROM #TempVariables
    )
) AS NewRoles
JOIN sma_MST_SubRoleCode SubRoleCodes
    ON SubRoleCodes.srcsDscrptn = NewRoles.sbrsDscrptn
    AND SubRoleCodes.srcnRoleID = NewRoles.sbrnRoleID
EXCEPT
SELECT
    sbrnRoleID,
    sbrsDscrptn,
    sbrnCaseTypeID,
    sbrnTypeCode
FROM sma_MST_SubRole;



/* 
---Checking---
SELECT CST.cstnCaseTypeID,CST.cstsType,sbrsDscrptn
FROM sma_MST_SubRole S
INNER JOIN sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID
WHERE CST.VenderCaseType='SLFCaseType'
and sbrsDscrptn='(D)-Default Role'
ORDER BY CST.cstnCaseTypeID
*/


-------- (5) sma_TRN_cases ----------------------
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Cases]
	(
	[cassCaseNumber]
   ,[casbAppName]
   ,[cassCaseName]
   ,[casnCaseTypeID]
   ,[casnState]
   ,[casdStatusFromDt]
   ,[casnStatusValueID]
   ,[casdsubstatusfromdt]
   ,[casnSubStatusValueID]
   ,[casdOpeningDate]
   ,[casdClosingDate]
   ,[casnCaseValueID]
   ,[casnCaseValueFrom]
   ,[casnCaseValueTo]
   ,[casnCurrentCourt]
   ,[casnCurrentJudge]
   ,[casnCurrentMagistrate]
   ,[casnCaptionID]
   ,[cassCaptionText]
   ,[casbMainCase]
   ,[casbCaseOut]
   ,[casbSubOut]
   ,[casbWCOut]
   ,[casbPartialOut]
   ,[casbPartialSubOut]
   ,[casbPartiallySettled]
   ,[casbInHouse]
   ,[casbAutoTimer]
   ,[casdExpResolutionDate]
   ,[casdIncidentDate]
   ,[casnTotalLiability]
   ,[cassSharingCodeID]
   ,[casnStateID]
   ,[casnLastModifiedBy]
   ,[casdLastModifiedDate]
   ,[casnRecUserID]
   ,[casdDtCreated]
   ,[casnModifyUserID]
   ,[casdDtModified]
   ,[casnLevelNo]
   ,[cassCaseValueComments]
   ,[casbRefIn]
   ,[casbDelete]
   ,[casbIntaken]
   ,[casnOrgCaseTypeID]
   ,[CassCaption]
   ,[cassMdl]
   ,[office_id]
   ,[saga]
   ,[LIP]
   ,[casnSeriousInj]
   ,[casnCorpDefn]
   ,[casnWebImporter]
   ,[casnRecoveryClient]
   ,[cas]
   ,[ngage]
   ,[casnClientRecoveredDt]
   ,[CloseReason]
   ,[saga_db]
	)
	SELECT
		C.casenum	   AS cassCaseNumber
	   ,''			   AS casbAppName
	   ,case_title	   AS cassCaseName
	   ,(
			SELECT
				cstnCaseSubTypeID
			FROM [sma_MST_CaseSubType] ST
			WHERE ST.cstnGroupID = CST.cstnCaseTypeID
				AND ST.cstsDscrptn = MIX.[SmartAdvocate Case Sub Type]
		)			   
		AS casnCaseTypeID
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = (
					SELECT
						StateName
					FROM #TempVariables
				)
		)			   
		AS casnState
	   ,GETDATE()	   AS casdStatusFromDt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   
		AS casnStatusValueID
	   ,GETDATE()	   AS casdsubstatusfromdt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   
		AS casnSubStatusValueID
	   ,CASE
			WHEN (C.date_opened NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE C.date_opened
		END			   AS casdOpeningDate
	   ,CASE
			WHEN (C.close_date NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE C.close_date
		END			   AS casdClosingDate
	   ,NULL		   AS [casnCaseValueID]
	   ,NULL		   AS [casnCaseValueFrom]
	   ,NULL		   AS [casnCaseValueTo]
	   ,NULL		   AS [casnCurrentCourt]
	   ,NULL		   AS [casnCurrentJudge]
	   ,NULL		   AS [casnCurrentMagistrate]
	   ,0			   AS [casnCaptionID]
	   ,case_title	   AS cassCaptionText
	   ,1			   AS [casbMainCase]
	   ,0			   AS [casbCaseOut]
	   ,0			   AS [casbSubOut]
	   ,0			   AS [casbWCOut]
	   ,0			   AS [casbPartialOut]
	   ,0			   AS [casbPartialSubOut]
	   ,0			   AS [casbPartiallySettled]
	   ,1			   AS [casbInHouse]
	   ,NULL		   AS [casbAutoTimer]
	   ,NULL		   AS [casdExpResolutionDate]
	   ,NULL		   AS [casdIncidentDate]
	   ,0			   AS [casnTotalLiability]
	   ,0			   AS [cassSharingCodeID]
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = (
					SELECT
						StateName
					FROM #TempVariables
				)
		)			   
		AS [casnStateID]
	   ,NULL		   AS [casnLastModifiedBy]
	   ,NULL		   AS [casdLastModifiedDate]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = C.intake_staff
		)			   
		AS casnRecUserID
	   ,CASE
			WHEN C.intake_date BETWEEN '1900-01-01' AND '2079-06-06' AND
				C.intake_time BETWEEN '1900-01-01' AND '2079-06-06'
				THEN (
						SELECT
							CAST(CONVERT(DATE, C.intake_date) AS DATETIME) + CAST(CONVERT(TIME, C.intake_time) AS DATETIME)
					)
			ELSE NULL
		END			   AS casdDtCreated
	   ,NULL		   AS casnModifyUserID
	   ,NULL		   AS casdDtModified
	   ,''			   AS casnLevelNo
	   ,''			   AS cassCaseValueComments
	   ,NULL		   AS casbRefIn
	   ,NULL		   AS casbDelete
	   ,NULL		   AS casbIntaken
	   ,cstnCaseTypeID AS casnOrgCaseTypeID -- actual case type
	   ,''			   AS CassCaption
	   ,0			   AS cassMdl
	   ,(
			SELECT
				office_id
			FROM sma_MST_Offices
			WHERE office_name = (
					SELECT
						OfficeName
					FROM #TempVariables
				)
		)			   
		AS office_id
	   ,''			   AS [saga]
	   ,NULL		   AS [LIP]
	   ,NULL		   AS [casnSeriousInj]
	   ,NULL		   AS [casnCorpDefn]
	   ,NULL		   AS [casnWebImporter]
	   ,NULL		   AS [casnRecoveryClient]
	   ,NULL		   AS [cas]
	   ,NULL		   AS [ngage]
	   ,NULL		   AS [casnClientRecoveredDt]
	   ,0			   AS CloseReason
	   ,'ND'		   AS [saga_db]
	FROM [JoelBieberNeedles].[dbo].[cases_Indexed] C
	LEFT JOIN [JoelBieberNeedles].[dbo].[user_case_data] U
		ON U.casenum = C.casenum
	JOIN caseTypeMixture mix
		ON mix.matcode = c.matcode
	LEFT JOIN sma_MST_CaseType CST
		ON CST.cststype = mix.[SmartAdvocate Case Type]
			AND VenderCaseType = (
				SELECT
					VenderCaseType
				FROM #TempVariables
			)
	ORDER BY C.casenum
GO

---
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO
---
