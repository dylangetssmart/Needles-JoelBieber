USE JoelBieberSA_Needles
GO

--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO
--

INSERT INTO [sma_MST_IndvContacts]
(
	[cinbPrimary]
	,[cinnContactTypeID]
	,[cinnContactSubCtgID]
	,[cinsPrefix]
	,[cinsFirstName]
	,[cinsMiddleName]
	,[cinsLastName]
	,[cinsSuffix]
	,[cinsNickName]
	,[cinbStatus]
	,[cinsSSNNo]
	,[cindBirthDate]
	,[cinsComments]
	,[cinnContactCtg]
	,[cinnRefByCtgID]
	,[cinnReferredBy]
	,[cindDateOfDeath]
	,[cinsCVLink]
	,[cinnMaritalStatusID]
	,[cinnGender]
	,[cinsBirthPlace]
	,[cinnCountyID]
	,[cinsCountyOfResidence]
	,[cinbFlagForPhoto]
	,[cinsPrimaryContactNo]
	,[cinsHomePhone]
	,[cinsWorkPhone]
	,[cinsMobile]
	,[cinbPreventMailing]
	,[cinnRecUserID]
	,[cindDtCreated]
	,[cinnModifyUserID]
	,[cindDtModified]
	,[cinnLevelNo]
	,[cinsPrimaryLanguage]
	,[cinsOtherLanguage]
	,[cinbDeathFlag]
	,[cinsCitizenship]
	,[cinsHeight]
	,[cinnWeight]
	,[cinsReligion]
	,[cindMarriageDate]
	,[cinsMarriageLoc]
	,[cinsDeathPlace]
	,[cinsMaidenName]
	,[cinsOccupation]
	,[saga]
	,[cinsSpouse]
	,[cinsGrade]
) 
SELECT DISTINCT 
	1									as [cinbPrimary]
	,(
		SELECT octnOrigContactTypeID
		FROM [dbo].[sma_MST_OriginalContactTypes]
		WHERE octsDscrptn = 'Police Officer'
	)									as [cinnContactTypeID]
	,null								as [cinnContactSubCtgID]
	,'Officer'							as [cinsPrefix]
	,dbo.get_firstword(P.officer)		as [cinsFirstName]
	,''									as [cinsMiddleName]
	,dbo.get_lastword(P.officer)		as [cinsLastName]
	,null								as [cinsSuffix]
	,null								as [cinsNickName]
	,1									as [cinbStatus]
	,null								as [cinsSSNNo]
	,null								as [cindBirthDate]
	,null								as [cinsComments]
	,1									as [cinnContactCtg]
	,''									as [cinnRefByCtgID]
	,''									as [cinnReferredBy]
	,null								as [cindDateOfDeath]
	,''									as [cinsCVLink]
	,''									as [cinnMaritalStatusID]
	,1									as [cinnGender]
	,''									as [cinsBirthPlace]
	,1									as [cinnCountyID]
	,1									as [cinsCountyOfResidence]
	,null								as [cinbFlagForPhoto]
	,null								as [cinsPrimaryContactNo]
	,''									as [cinsHomePhone]
	,''									as [cinsWorkPhone]
	,null								as [cinsMobile]
	,0									as [cinbPreventMailing]
	,368								as [cinnRecUserID]
	,GETDATE()							as [cindDtCreated]
	,''									as [cinnModifyUserID]
	,null								as [cindDtModified]
	,0									as [cinnLevelNo]
	,''									as [cinsPrimaryLanguage]
	,''									as [cinsOtherLanguage]
	,''									as [cinbDeathFlag]
	,''									as [cinsCitizenship]
	,null + null						as [cinsHeight]
	,null								as [cinnWeight]
	,''									as [cinsReligion]
	,null								as [cindMarriageDate]
	,null								as [cinsMarriageLoc]
	,null								as [cinsDeathPlace]
	,''									as [cinsMaidenName]
	,''									as [cinsOccupation]
	,''									as [saga]
	,''									as [cinsSpouse]
	,P.officer							as [cinsGrade]			-- Used in Investigations_PoliceReport.sql
FROM [JoelBieberNeedles].[dbo].[police] P 
WHERE ISNULL(officer, '') <> ''
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO
--
