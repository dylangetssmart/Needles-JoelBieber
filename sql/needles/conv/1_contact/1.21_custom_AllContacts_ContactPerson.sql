USE JoelBieberSA_Needles
GO

--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO
--

-- Create contact card 
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
	)
	SELECT
		1									 AS [cinbPrimary]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [dbo].[sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 1
		)									 
		AS [cinnContactTypeID]
	   ,NULL								 AS [cinnContactSubCtgID]
	   ,''									 AS [cinsPrefix]
	   ,dbo.get_firstword(ucd.Relative_Name) AS [cinsFirstName]
	   ,''									 AS [cinsMiddleName]
	   ,dbo.get_lastword(ucd.Relative_Name)	 AS [cinsLastName]
	   ,NULL								 AS [cinsSuffix]
	   ,NULL								 AS [cinsNickName]
	   ,1									 AS [cinbStatus]
	   ,NULL								 AS [cinsSSNNo]
	   ,NULL								 AS [cindBirthDate]
	   ,NULL								 AS [cinsComments]
	   ,1									 AS [cinnContactCtg]
	   ,''									 AS [cinnRefByCtgID]
	   ,''									 AS [cinnReferredBy]
	   ,NULL								 AS [cindDateOfDeath]
	   ,''									 AS [cinsCVLink]
	   ,''									 AS [cinnMaritalStatusID]
	   ,1									 AS [cinnGender]
	   ,''									 AS [cinsBirthPlace]
	   ,1									 AS [cinnCountyID]
	   ,1									 AS [cinsCountyOfResidence]
	   ,NULL								 AS [cinbFlagForPhoto]
	   ,NULL								 AS [cinsPrimaryContactNo]
	   ,ucd.Relative_Phone					 AS [cinsHomePhone]
	   ,''									 AS [cinsWorkPhone]
	   ,NULL								 AS [cinsMobile]
	   ,0									 AS [cinbPreventMailing]
	   ,368									 AS [cinnRecUserID]
	   ,GETDATE()							 AS [cindDtCreated]
	   ,''									 AS [cinnModifyUserID]
	   ,NULL								 AS [cindDtModified]
	   ,0									 AS [cinnLevelNo]
	   ,''									 AS [cinsPrimaryLanguage]
	   ,''									 AS [cinsOtherLanguage]
	   ,''									 AS [cinbDeathFlag]
	   ,''									 AS [cinsCitizenship]
	   ,NULL + NULL							 AS [cinsHeight]
	   ,NULL								 AS [cinnWeight]
	   ,''									 AS [cinsReligion]
	   ,NULL								 AS [cindMarriageDate]
	   ,NULL								 AS [cinsMarriageLoc]
	   ,NULL								 AS [cinsDeathPlace]
	   ,''									 AS [cinsMaidenName]
	   ,''									 AS [cinsOccupation]
	   ,ucd.casenum							 AS [saga]
	   ,''									 AS [cinsSpouse]
	   ,'relative'							 AS [cinsGrade]
	FROM [JoelBieberNeedles].[dbo].user_case_data ucd
	WHERE ISNULL(ucd.Relative_Name, '') <> ''
GO



--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO
--