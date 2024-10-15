-- use [JoelBieberNeedles]
-- GO

/*
alter table [sma_TRN_Incidents] disable trigger all
delete [sma_TRN_Incidents]
DBCC CHECKIDENT ('[sma_TRN_Incidents]', RESEED, 0);
alter table [sma_TRN_Incidents] enable trigger all
*/

DECLARE @StateCode NVARCHAR(2) = 'VA'

---
ALTER TABLE [sma_TRN_Incidents] DISABLE TRIGGER ALL
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
---
INSERT INTO [sma_TRN_Incidents]
(
	[CaseId]
	,[IncidentDate]
	,[StateID]
	,[LiabilityCodeId]
	,[IncidentFacts]
	,[MergedFacts]
	,[Comments]
	,[IncidentTime]
	,[RecUserID]
	,[DtCreated]
	,[ModifyUserID]
	,[DtModified]
)
	SELECT 
		CAS.casnCaseID				as CaseId
		,case
			when (C.[date_of_incident] between '1900-01-01' and '2079-06-06')
				then convert(date,C.[date_of_incident]) 
			else null 
		end							as IncidentDate
		,case
			when exists (
							select * from
							sma_MST_States where
							sttsCode = U.[State]
						)
			 	then (
						select sttnStateID
						from sma_MST_States
						where sttsCode = U.[State]
					)
			else (
					select sttnStateID
					from sma_MST_States
					where sttsCode = @StateCode
				)
		end							as [StateID]
		-- ,(
		-- 	select sttnStateID
		-- 	from sma_MST_States
		-- 	where sttsCode='VA'
		-- )							as [StateID]
		,0							as LiabilityCodeId
		,C.synopsis + char(13) +
		--isnull('Description of Accident:' + nullif(u.Description_of_Accident,'') + CHAR(13),'') + 
		''							as IncidentFacts
		,''							as [MergedFacts]
		,null						as [Comments]
		,null						as [IncidentTime]
		,368						as [RecUserID]
		,getdate()					as [DtCreated]
		,null						as [ModifyUserID]
		,null						as [DtModified]
	FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
	JOIN JoelBieberNeedles.[dbo].[user_case_data] U
		on U.casenum = C.casenum
	JOIN [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = convert(varchar,C.casenum)

UPDATE CAS
SET
	CAS.casdIncidentDate = INC.IncidentDate
	,CAS.casnStateID = INC.StateID
	,CAS.casnState = INC.StateID
FROM sma_trn_cases as CAS
LEFT JOIN sma_TRN_Incidents as INC
	on casnCaseID = caseid
WHERE INC.CaseId = CAS.casncaseid 

---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO