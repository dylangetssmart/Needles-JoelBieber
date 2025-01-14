/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create Cases and case related codes

[sma_mst_offices]
[sma_MST_CaseType]
[sma_TRN_Cases]
[sma_mst_casegroup]
[sma_MST_CaseSubType]
[sma_MST_CaseSubTypeCode]

------------------------------------------------------------------------------------------------------
Step									Object				Action				Source				Notes
------------------------------------------------------------------------------------------------------
[0.0] #TempVariables					create
[1.0] Office							insert
[2.0] Case Groups						insert

[3.0] Case Types
	[3.1] VenderCaseType				schema
	[3.2] sma_MST_CaseType				insert
	[3.3] sma_MST_CaseSubTypeCode		update
	[3.4] sma_MST_CaseSubTypeCode		insert 
	[3.5] sma_MST_CaseSubType			insert

[4.0] Sub Role
	[4.1] sma_MST_SubRole				insert 
	[4.2] sma_MST_SubRole				update
	[4.3] sma_MST_SubroleCode			insert
	[4.3] sma_MST_SubRole				insert

[5.0] Cases								insert


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

------------------------------------------------------------------------------------------------------
-- [5.0] Cases
------------------------------------------------------------------------------------------------------
BEGIN
	ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL

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
	   ,[saga_char]
		)
		SELECT
			m.[Name]					 AS cassCaseNumber
		   ,''							 AS casbAppName
		   ,m.litify_pm__Display_Name__c AS cassCaseName
		   ,(
				SELECT
					cstnCaseSubTypeID
				FROM [sma_MST_CaseSubType] ST
				WHERE ST.cstnGroupID = CST.cstnCaseTypeID
					AND ST.cstsDscrptn = mix.[SmartAdvocate Case Sub Type]
			)							 
			AS casnCaseTypeID
		   ,CASE
				WHEN ISNULL(m.litify_pm__Matter_State__c, '') <> ''
					THEN (
							SELECT
								[sttnStateID]
							FROM [sma_MST_States]
							WHERE sttsCode = LEFT(m.litify_pm__Matter_State__c, 2)
						)
				ELSE (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE [sttsDescription] = (
								SELECT
									StateName
								FROM conversion.shiner_office
							)
					)
			END							 AS casnState
		   ,GETDATE()					 AS casdStatusFromDt
		   ,(
				SELECT
					cssnStatusID
				FROM [sma_MST_CaseStatus]
				WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
			)							 
			AS casnStatusValueID
		   ,GETDATE()					 AS casdsubstatusfromdt
		   ,(
				SELECT
					cssnStatusID
				FROM [sma_MST_CaseStatus]
				WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
			)							 
			AS casnSubStatusValueID
		   ,CASE
				WHEN (m.litify_pm__Open_Date__c NOT BETWEEN '1900-01-01' AND '2079-12-31')
					THEN GETDATE()
				ELSE m.litify_pm__Open_Date__c
			END							 
			AS casdOpeningDate
		   ,CASE
				WHEN m.litify_pm__Status__c = 'Closed'
					THEN CASE
							WHEN ISNULL(m.litify_pm__Closed_Date__c, m.litify_pm__Close_Date__c) IS NULL
								THEN GETDATE()
							WHEN ISNULL(m.litify_pm__Closed_Date__c, m.litify_pm__Close_Date__c) NOT BETWEEN '1900-01-01' AND '2079-12-31'
								THEN GETDATE()
							ELSE ISNULL(m.litify_pm__Closed_Date__c, m.litify_pm__Close_Date__c)
						END
				ELSE NULL
			END							 
			AS casdClosingDate
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,0
		   ,litify_pm__Case_Title__c	 AS cassCaptionText
		   ,1
		   ,0
		   ,0
		   ,0
		   ,0
		   ,0
		   ,0
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,0
		   ,0
		   ,CASE
				WHEN ISNULL(m.litify_pm__Matter_State__c, '') <> ''
					THEN (
							SELECT
								[sttnStateID]
							FROM [sma_MST_States]
							WHERE sttsCode = LEFT(m.litify_pm__Matter_State__c, 2)
						)
				ELSE (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE [sttsDescription] = (
								SELECT
									StateName
								FROM conversion.shiner_office so
							)
					)
			END							 AS casnStateID
		   ,NULL
		   ,NULL
		   ,(
				SELECT
					usrnUserID
				FROM sma_MST_Users
				WHERE saga = m.CreatedById
			)							 
			AS casnRecUserID
		   ,CreatedDate					 AS casdDtCreated
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,NULL
		   ,NULL
		   ,cstnCaseTypeID				 AS casnOrgCaseTypeID
		   ,''							 AS CassCaption
		   ,0							 AS cassMdl
		   ,(
				SELECT
					office_id
				FROM sma_mst_offices
				WHERE office_name = (
						SELECT
							OfficeName
						FROM conversion.shiner_office so
					)
			)							 
			AS office_id
		   ,NULL						 AS saga
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,0							 AS CloseReason
		   ,m.Id						 AS saga_char
		FROM ShinerLitify..litify_pm__Matter__c m
		--JOIN ShinerLitify..litify_pm__case_type__c ct on ct.id = m.litify_pm__Case_Type__c
		JOIN CaseTypeMap mix
			ON mix.LitifyCaseTypeID = m.litify_pm__Case_Type__c
		LEFT JOIN sma_MST_CaseType CST
			ON CST.cstsType = mix.[SmartAdvocate Case Type]
				AND VenderCaseType = (
					SELECT
						VenderCaseType
					FROM conversion.shiner_office so
				)
	ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
END