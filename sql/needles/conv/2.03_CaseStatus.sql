USE JoelBieberSA_Needles
GO

/*
alter table [sma_TRN_CaseStatus] disable trigger all
delete from [sma_TRN_CaseStatus]
DBCC CHECKIDENT ('[sma_TRN_CaseStatus]', RESEED, 0);
alter table [sma_TRN_CaseStatus] enable trigger all
*/

---(0)---
/*
Add unique case statuses from Needles..class to sma_MST_CaseStatus
*/
INSERT INTO sma_MST_CaseStatus
	(
	csssDescription
   ,cssnStatusTypeID
	)
	SELECT
		A.[name]
	   ,(
			SELECT
				stpnStatusTypeID
			FROM sma_MST_CaseStatusType
			WHERE stpsStatusType = 'Status'
		)
	FROM (
		/*
		Retrieves distinct descriptions from the JoelBieberNeedles.dbo.class table,
		joining with the JoelBieberNeedles.dbo.cases table
		to filter the classes that are associated with cases.
		*/
		SELECT DISTINCT
			[description] AS [name]
		FROM JoelBieberNeedles.[dbo].[class]
		JOIN JoelBieberNeedles.[dbo].[cases] C
			ON C.class = classcode

		/*
		Adds a hardcoded status description 'Conversion Case No Status'
		to the list of distinct descriptions.
		*/
		UNION
		SELECT
			'Conversion Case No Status'

		EXCEPT

		/*
		Excludes any descriptions that already exist in the sma_MST_CaseStatus table
		with a status type ID corresponding to 'Status'.
		*/
		SELECT
			csssDescription AS [name]
		FROM sma_MST_CaseStatus
		WHERE cssnStatusTypeID = (
				SELECT
					stpnStatusTypeID
				FROM sma_MST_CaseStatusType
				WHERE stpsStatusType = 'Status'
			)
	) A
GO

---(1)---
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
	SELECT
		CAS.casnCaseID
	   ,(
			SELECT
				stpnStatusTypeID
			FROM sma_MST_CaseStatusType
			WHERE stpsStatusType = 'Status'
		)		  
		AS [cssnStatusTypeID]
		  ,case 
		when C.close_date between '1900-01-01' and '2079-06-06'	then
			( 
				select cssnStatusID
				from sma_MST_CaseStatus
				where csssDescription='Closed Case'
			)
		when exists (
						select top 1 *
						from sma_MST_CaseStatus
						where csssDescription=CL.[description]
					)
					then (
							select top 1 cssnStatusID
							from sma_MST_CaseStatus
							where csssDescription=CL.[description]
						)
		else (
				select top 1 cssnStatusID
				from sma_MST_CaseStatus
				where csssDescription='Conversion Case No Status'
				)
		end																as [cssnStatusID]
	   ,''		  AS [cssnExpDays]
	   ,CASE
			WHEN c.close_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN c.close_Date
			ELSE GETDATE()
		END		  AS [cssdFromDate]
	   ,NULL	  AS [cssdToDt]
	   ,CASE
			WHEN C.close_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN 'Prior Status : ' + CL.[description]
			ELSE ''
		END + CHAR(13) +
		''		  AS [csssComments]
	   ,368
	   ,GETDATE() AS [cssdDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [sma_trn_cases] CAS
	JOIN JoelBieberNeedles.[dbo].[cases_Indexed] C
		ON CONVERT(VARCHAR, C.casenum) = CAS.cassCaseNumber
	LEFT JOIN JoelBieberNeedles.[dbo].[class] CL
		ON C.class = CL.classcode
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
SET casnStatusValueID = STA.cssnStatusID
FROM sma_TRN_CaseStatus STA
WHERE STA.cssnCaseID = casnCaseID
GO

ALTER TABLE [sma_trn_cases] ENABLE TRIGGER ALL
GO


