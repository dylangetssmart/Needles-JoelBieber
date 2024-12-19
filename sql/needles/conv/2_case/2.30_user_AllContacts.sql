USE JoelBieberNeedles
GO

/* ####################################
1.0 -- Add Contact to case
*/

ALTER TABLE [sma_MST_OtherCasesContact] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_MST_OtherCasesContact]
	(
	[OtherCasesID], [OtherCasesContactID], [OtherCasesContactCtgID], [OtherCaseContactAddressID], [OtherCasesContactRole], [OtherCasesCreatedUserID], [OtherCasesContactCreatedDt], [OtherCasesModifyUserID], [OtherCasesContactModifieddt]
	)
	SELECT
		cas.casnCaseID				 AS [OtherCasesID]
	   ,ioc.CID						 AS [OtherCasesContactID]
	   ,ioc.CTG						 AS [OtherCasesContactCtgID]
	   ,ioc.AID						 AS [OtherCaseContactAddressID]
	   ,'Relative'					 AS [OtherCasesContactRole]
	   ,368							 AS [OtherCasesCreatedUserID]
	   ,GETDATE()					 AS [OtherCasesContactCreatedDt]
	   ,NULL						 AS [OtherCasesModifyUserID]
	   ,NULL						 AS [OtherCasesContactModifieddt]
	--SELECT *
	FROM [JoelBieberNeedles].[dbo].user_case_data ucd
	JOIN sma_TRN_Cases cas
		ON CONVERT(VARCHAR, ucd.casenum) = CAS.cassCaseNumber
	--JOIN [JoelBieberNeedles]..names n
	--	ON n.names_id = ud.party_id
	JOIN IndvOrgContacts_Indexed ioc
		ON CONVERT(VARCHAR, ucd.casenum) = ioc.saga
	JOIN [sma_MST_IndvContacts] ic
		ON ic.saga = ucd.casenum
		and cinsgrade = 'relative'
	WHERE ISNULL(ucd.Relative_Name, '') <> ''
GO

--SELECT * FROM JoelBieberSA_Needles..sma_MST_IndvContacts smic WHERE smic.cinsGrade = 'relative'
--SELECT * FROM JoelBieberSA_Needles..IndvOrgContacts_Indexed ioci WHERE ioci.Name LIKE 'HAROLD GRAHAM'
--229795
--sp_help 'IndvOrgContacts_Indexed'

---
ALTER TABLE [sma_MST_OtherCasesContact] ENABLE TRIGGER ALL
GO

/* ####################################
2.0 -- Add comment
*/
                
-- INSERT INTO [sma_TRN_CaseContactComment]
-- (
-- 	[CaseContactCaseID]
-- 	,[CaseRelContactID]
-- 	,[CaseRelContactCtgID]
-- 	,[CaseContactComment]
-- 	,[CaseContactCreaatedBy]
-- 	,[CaseContactCreateddt]
-- 	,[caseContactModifyBy]
-- 	,[CaseContactModifiedDt]
-- )
-- SELECT
-- 	cas.casnCaseID	as [CaseContactCaseID]
-- 	,ioc.CID		as [CaseRelContactID]
-- 	,ioc.CTG		as [CaseRelContactCtgID]
-- 	,isnull(('Spouse: '+ nullif(convert(varchar(max),ud.spouse),'')+char(13)),'') +
-- 	isnull(('Alternate Contact: '+ nullif(convert(varchar(max),ud.Alternate_Contact),'')+char(13)),'') +
-- 	isnull(('Contact Relationship: '+ nullif(convert(varchar(max),ud.Contact_Relationship),'')+char(13)),'') +
-- 	''				as [CaseContactComment]
-- 	,368			as [CaseContactCreaatedBy]
-- 	,getdate()		as [CaseContactCreateddt]
-- 	,null			as [caseContactModifyBy]
-- 	,null			as [CaseContactModifiedDt]
-- FROM [JoelBieberNeedles].[dbo].user_party_data ud
-- join sma_TRN_Cases cas
-- 	on cas.cassCaseNumber = ud.case_id
-- join [JoelBieberNeedles]..names n
-- 	on n.names_id = ud.party_id
-- join IndvOrgContacts_Indexed ioc
-- 	on ioc.SAGA = n.names_id
-- where isnull(ud.Spouse,'') <> '' or isnull(ud.Alternate_Contact,'') <> '' or isnull(ud.Contact_Relationship,'') <> ''