USE JoelBieberSA_Needles
GO

/* ####################################
1.0 -- Add Contact to case
*/

ALTER TABLE [sma_MST_OtherCasesContact] DISABLE TRIGGER ALL
GO

--INSERT INTO [sma_MST_OtherCasesContact]
--	(
--	[OtherCasesID], [OtherCasesContactID], [OtherCasesContactCtgID], [OtherCaseContactAddressID], [OtherCasesContactRole], [OtherCasesCreatedUserID], [OtherCasesContactCreatedDt], [OtherCasesModifyUserID], [OtherCasesContactModifieddt]
--	)
--	SELECT
--		cas.casnCaseID				 AS [OtherCasesID]
--	   ,ioc.CID						 AS [OtherCasesContactID]
--	   ,ioc.CTG						 AS [OtherCasesContactCtgID]
--	   ,ioc.AID						 AS [OtherCaseContactAddressID]
--	   ,ud.Relationship_to_Plaintiff AS [OtherCasesContactRole]
--	   ,368							 AS [OtherCasesCreatedUserID]
--	   ,GETDATE()					 AS [OtherCasesContactCreatedDt]
--	   ,NULL						 AS [OtherCasesModifyUserID]
--	   ,NULL						 AS [OtherCasesContactModifieddt]
--	FROM NeedlesSLF.[dbo].user_party_data ud
--	JOIN sma_TRN_Cases cas
--		ON cas.cassCaseNumber = ud.case_id
--	JOIN NeedlesSLF..names n
--		ON n.names_id = ud.party_id
--	JOIN IndvOrgContacts_Indexed ioc
--		ON ioc.SAGA = n.names_id
--	WHERE ISNULL(ud.Relationship_to_Plaintiff, '') <> ''
--GO


--SELECT * FROM conversion.user

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
	JOIN [sma_MST_IndvContacts] indv
		on indv.source_id = ucd.Relative_Name
		and indv.source_ref = 'conversion.user_party_relative'
	JOIN IndvOrgContacts_Indexed ioc
		on ioc.CID = indv.cinnContactID
		--ON CONVERT(VARCHAR, ucd.casenum) = ioc.saga
		--ON ic.saga = ucd.casenum
		--and cinsgrade = 'relative'
	WHERE ISNULL(ucd.Relative_Name, '') <> ''
GO

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
-- FROM NeedlesSLF.[dbo].user_party_data ud
-- join sma_TRN_Cases cas
-- 	on cas.cassCaseNumber = ud.case_id
-- join NeedlesSLF..names n
-- 	on n.names_id = ud.party_id
-- join IndvOrgContacts_Indexed ioc
-- 	on ioc.SAGA = n.names_id
-- where isnull(ud.Spouse,'') <> '' or isnull(ud.Alternate_Contact,'') <> '' or isnull(ud.Contact_Relationship,'') <> ''