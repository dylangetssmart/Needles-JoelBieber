/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual and organization contacts

[sma_mst_offices]
[sma_MST_CaseType]
[sma_TRN_Cases]
[sma_mst_casegroup]
[sma_MST_CaseSubType]
[sma_MST_CaseSubTypeCode]

------------------------------------------------------------------------------------------------------
Step								Object				Action				Source				Notes
------------------------------------------------------------------------------------------------------
[0.0] #TempVariables				create
[1.0] Office						insert
[2.0] Case Groups					insert

[3.0] Case Types
- 3.1 VenderCaseType				schema
- 3.2 sma_MST_CaseType				insert
- 3.3 sma_MST_CaseSubTypeCode		update
- 3.4 sma_MST_CaseSubTypeCode		insert 
- 3.5 sma_MST_CaseSubType			insert

[4.0] Sub Role
- SubRole
- SubRoleCode
[5.0] Cases							insert


Notes:
	- Because batch separators (GO) are required due to schema changes (adding columns),
	we use a temporary table instead of variables, which are locally scoped
	see: https://learn.microsoft.com/en-us/sql/t-sql/language-elements/variables-transact-sql?view=sql-server-ver16#variable-scope
	see also: https://stackoverflow.com/a/56370223
	- After making schema changes (e.g. adding a new column to an existing table) statements using the new schema must be compiled separately in a different batch.
	- For example, you cannot ALTER a table to add a column, then select that column in the same batch - because while compiling the execution plan, that column does not exist for selecting.

##########################################################################################################################
*/

USE ShinerSA
GO


/***********************************************************************
**  Status Types:  [litify_pm__Matter__c].[litify_pm__Status__c]
**	Sub Status Types:  Litify Stage
***********************************************************************/

 ------------------------------------------------
 --MAKE SURE ALL STATUSES EXIST IN SA
 ------------------------------------------------
 INSERT INTO sma_mst_casestatus
 (
	csssDescription
	,cssnStatusTypeID
)
 SELECT DISTINCT
 	isnull(litify_pm__Status__c,'LIT 00 - Lawsuit Needed')
	,1 
 FROM
 	ShinerLitify..[litify_pm__Matter__c]
WHERE litify_pm__Status__c <> 'Closed'
EXCEPT
	SELECT
		csssDescription
		,cssnStatusTypeID
	FROM sma_mst_casestatus

 --SUB STATUSES
INSERT INTO sma_mst_casestatus
(
	csssDescription
	,cssnStatusTypeID
)
SELECT distinct
	st.[name] as [Stage]
	, 2
FROM ShinerLitify..litify_pm__Matter_plan__c p
	JOIN ShinerLitify..litify_pm__Matter_stage__c st
		on p.id = st.litify_pm__Matter_Plan__c
	JOIN ShinerLitify..litify_pm__Matter_stage_activity__c sta
		on sta.litify_pm__Original_Matter_Stage__c = st.Id
WHERE sta.litify_pm__Stage_Status__c = 'Active'
EXCEPT
	SELECT
		csssDescription
		,cssnStatusTypeID
	FROM sma_mst_casestatus

---------
ALTER TABLE [sma_TRN_CaseStatus] DISABLE TRIGGER ALL
GO
---------

INSERT INTO [sma_TRN_CaseStatus]
(
	[cssnCaseID]
	,[cssnStatusTypeID]
	,[cssnStatusID]
	,[cssnExpDays]
	,[cssdFromDate]
	,[cssdToDt]
	,[csssComments]
	,[cssnRecUserID]
	,[cssdDtCreated]
	,[cssnModifyUserID]
	,[cssdDtModified]
	,[cssnLevelNo]
	,[cssnDelFlag]
)
SELECT DISTINCT
    CAS.casnCaseID			as [cssnCaseID]
    ,(
		SELECT stpnStatusTypeID
		FROM sma_MST_CaseStatusType
		WHERE stpsStatusType = 'Status'
	)						as [cssnStatusTypeID]
    ,case
		when litify_pm__Status__c = 'Closed'
			then (
					SELECT cssnStatusID
					FROM sma_MST_CaseStatus
					WHERE csssDescription = 'Closed Case'
				)
		when litify_pm__Status__c IS NULL
			then (
					SELECT cssnStatusID
					FROM sma_MST_CaseStatus
					WHERE csssDescription = 'LIT 00 - Lawsuit Needed'
						and cssnStatusTypeID = 1
				)
		else (
				SELECT cssnStatusID
				FROM sma_MST_CaseStatus
				WHERE csssDescription = [litify_pm__Status__c] 
					and cssnStatusTypeID = 1
			)
		end					as [cssnStatusID]
    ,''						as [cssnExpDays]
    ,CASE
		WHEN litify_pm__Status__c = 'Closed'
			THEN isnull(m.litify_pm__Closed_Date__c, litify_pm__Close_Date__c)
		ELSE getdate()
		END					as [cssdFromDate]
    ,null					as [cssdToDt]
    ,isnull('Closed Reason: ' + nullif(convert(varchar,m.[litify_pm__Closed_Reason__c]),'') + CHAR(13),'')
		+ isnull('Closed Details: ' + nullif(convert(varchar,m.[litify_pm__Closed_Reason_Details__c]),'') + CHAR(13),'')
		+ ''				as [csssComments]
    ,368					as [cssnRecUserID]
    ,GETDATE()				as [cssdDtCreated]
    ,null
	,null
	,null
	,null 
FROM [sma_trn_cases] CAS
	JOIN ShinerLitify..[litify_pm__Matter__c] m
		on m.Id = CAS.saga_char
GO

---------------------------
--SUB STATUS
---------------------------
INSERT INTO [sma_TRN_CaseStatus]
(
	[cssnCaseID]
	,[cssnStatusTypeID]
	,[cssnStatusID]
	,[cssnExpDays]
	,[cssdFromDate]
	,[cssdToDt]
	,[csssComments]
	,[cssnRecUserID]
	,[cssdDtCreated]
	,[cssnModifyUserID]
	,[cssdDtModified]
	,[cssnLevelNo]
	,[cssnDelFlag]
)
SELECT DISTINCT
    CAS.casnCaseID		as [cssnCaseID]
    ,(
		SELECT stpnStatusTypeID
		FROM sma_MST_CaseStatusType
		WHERE stpsStatusType = 'Sub Status'
	)					as [cssnStatusTypeID]
    ,(
		SELECT cssnStatusID
		FROM sma_MST_CaseStatus
		WHERE csssDescription = st.[name] 
			and cssnStatusTypeID = (
										SELECT stpnStatusTypeID
										FROM sma_MST_CaseStatusType
										WHERE stpsStatusType = 'Sub Status'
									)
	)					as [cssnStatusID]
    ,''					as [cssnExpDays]
    ,CASE
		WHEN [litify_pm__Set_As_Active_At__c] between '1/1/1900' and '6/6/2079'
			then [litify_pm__Set_As_Active_At__c]
		ELSE getdate()
		END				as [cssdFromDate]
    ,null				as [cssdToDt]
    ,''					as [csssComments]
    ,368				as [cssnRecUserID]
    ,GETDATE()			as [cssdDtCreated]
    ,null
	,null
	,null
	,null 
FROM [ShinerLitify]..[litify_pm__Matter_plan__c] p
	JOIN [ShinerLitify]..[litify_pm__Matter_stage__c] st
		on p.id = st.litify_pm__Matter_Plan__c
	JOIN [ShinerLitify]..[litify_pm__Matter_stage_activity__c] sta
		on sta.litify_pm__Original_Matter_Stage__c = st.Id
	JOIN [sma_trn_cases] CAS
		on cas.saga_char = sta.litify_pm__Matter__c
WHERE sta.litify_pm__Stage_Status__c = 'Active'
GO


--------
ALTER TABLE [sma_TRN_CaseStatus] ENABLE TRIGGER ALL
GO
--------


---(2)---
ALTER TABLE [sma_trn_cases] DISABLE TRIGGER ALL
GO
---------
UPDATE sma_trn_cases 
SET casnStatusValueID=STA.cssnStatusID
FROM sma_TRN_CaseStatus STA
WHERE STA.cssnCaseID=casnCaseID

ALTER TABLE [sma_trn_cases] ENABLE TRIGGER ALL
GO


