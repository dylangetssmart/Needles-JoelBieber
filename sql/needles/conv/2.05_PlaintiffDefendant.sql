/*



select * FROM JoelBieberNeedles..party_Indexed pi where role = 'property owner'


1. create plaintiffs from partyroles
1. create plaintiffs from party_indexed using our_client
- co-counsel
- driver
- ins adjuster
- owner
- property owner

1. create defendants from partyroles
- co-counsel
- driver
- ins adjuster
- owner
- property owner
1. create defendants from party_indexed using our_client

create default plaintiff
create default defendant

*/




USE JoelBieberSA_Needles
GO
/*
alter table [sma_TRN_Defendants] disable trigger all
delete from [sma_TRN_Defendants] 
DBCC CHECKIDENT ('[sma_TRN_Defendants]', RESEED, 0);
alter table [sma_TRN_Defendants] enable trigger all

alter table [sma_TRN_Plaintiff] disable trigger all
delete from [sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[sma_TRN_Plaintiff]', RESEED, 0);
alter table [sma_TRN_Plaintiff] enable trigger all

select * from [sma_TRN_Plaintiff] enable trigger all
*/

-------------------------------------------------------------------------------
-- Initialize #################################################################
-- Add [saga_party] to [sma_TRN_Plaintiff]and [sma_TRN_Defendants]
-------------------------------------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
BEGIN
	ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] INT NULL;
END

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND object_id = OBJECT_ID(N'sma_TRN_Defendants')
	)
BEGIN
	ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] INT NULL;
END

-- Disable table triggers
ALTER TABLE [sma_TRN_Plaintiff] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Defendants] DISABLE TRIGGER ALL
GO

-------------------------------------------------------------------------------
-- Create Plaintiffs from PartyRoles
-------------------------------------------------------------------------------

INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID], [plnnContactCtg], [plnnContactID], [plnnAddressID], [plnnRole], [plnbIsPrimary], [plnbWCOut], [plnnPartiallySettled], [plnbSettled], [plnbOut], [plnbSubOut], [plnnSeatBeltUsed], [plnnCaseValueID], [plnnCaseValueFrom], [plnnCaseValueTo], [plnnPriority], [plnnDisbursmentWt], [plnbDocAttached], [plndFromDt], [plndToDt], [plnnRecUserID], [plndDtCreated], [plnnModifyUserID], [plndDtModified], [plnnLevelNo], [plnsMarked], [saga], [plnnNoInj], [plnnMissing], [plnnLIPBatchNo], [plnnPlaintiffRole], [plnnPlaintiffGroup], [plnnPrimaryContact], [saga_party]
	)
	SELECT
		CAS.casnCaseID  AS [plnnCaseID]
	   ,CIO.CTG			AS [plnnContactCtg]
	   ,CIO.CID			AS [plnnContactID]
	   ,CIO.AID			AS [plnnAddressID]
	   ,S.sbrnSubRoleId AS [plnnRole]
	   ,1				AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368				AS [plnnRecUserID]
	   ,GETDATE()		AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL			AS [plnnLevelNo]
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1				AS [plnnPrimaryContact]
	   ,P.TableIndex	AS [saga_party]
	--SELECT cas.casncaseid, p.role, p.party_ID, pr.[needles roles], pr.[sa roles], pr.[sa party], s.*
	FROM JoelBieberNeedles.[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = P.case_id
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.SAGA = P.party_id
	JOIN [PartyRoles] pr
		ON pr.[Needles Roles] = p.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = [sa roles]
			AND S.sbrnRoleID = 4
	WHERE pr.[sa party] = 'Plaintiff'
GO


---------------------------------------------------------------------------------------
-- Create Plaintiffs from PartyRoles for roles that are applicable to both pln and def
---------------------------------------------------------------------------------------
INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID], [plnnContactCtg], [plnnContactID], [plnnAddressID], [plnnRole], [plnbIsPrimary], [plnbWCOut], [plnnPartiallySettled], [plnbSettled], [plnbOut], [plnbSubOut], [plnnSeatBeltUsed], [plnnCaseValueID], [plnnCaseValueFrom], [plnnCaseValueTo], [plnnPriority], [plnnDisbursmentWt], [plnbDocAttached], [plndFromDt], [plndToDt], [plnnRecUserID], [plndDtCreated], [plnnModifyUserID], [plndDtModified], [plnnLevelNo], [plnsMarked], [saga], [plnnNoInj], [plnnMissing], [plnnLIPBatchNo], [plnnPlaintiffRole], [plnnPlaintiffGroup], [plnnPrimaryContact], [saga_party]
	)
	SELECT
		CAS.casnCaseID  AS [plnnCaseID]
	   ,CIO.CTG			AS [plnnContactCtg]
	   ,CIO.CID			AS [plnnContactID]
	   ,CIO.AID			AS [plnnAddressID]
	   ,S.sbrnSubRoleId AS [plnnRole]
	   ,1				AS [plnbIsPrimary]
	   ,0				AS [plnbWCOut]
	   ,0				AS [plnnPartiallySettled]
	   ,0				AS [plnbSettled]
	   ,0				AS [plnbOut]
	   ,0				AS [plnbSubOut]
	   ,0				AS [plnnSeatBeltUsed]
	   ,NULL			AS [plnnCaseValueID]
	   ,NULL			AS [plnnCaseValueFrom]
	   ,NULL			AS [plnnCaseValueTo]
	   ,NULL			AS [plnnPriority]
	   ,NULL			AS [plnnDisbursmentWt]
	   ,NULL			AS [plnbDocAttached]
	   ,GETDATE()		AS [plndFromDt]
	   ,NULL			AS [plndToDt]
	   ,368				AS [plnnRecUserID]
	   ,GETDATE()		AS [plndDtCreated]
	   ,NULL			AS [plnnModifyUserID]
	   ,NULL			AS [plndDtModified]
	   ,NULL			AS [plnnLevelNo]
	   ,NULL			AS [plnsMarked]
	   ,''				AS [saga]
	   ,NULL			AS [plnnNoInj]
	   ,NULL			AS [plnnMissing]
	   ,NULL			AS [plnnLIPBatchNo]
	   ,NULL			AS [plnnPlaintiffRole]
	   ,NULL			AS [plnnPlaintiffGroup]
	   ,1				AS [plnnPrimaryContact]
	   ,P.TableIndex	AS [saga_party]
	FROM JoelBieberNeedles.[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = P.case_id
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.SAGA = P.party_id
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND (
				(P.role = 'CO-COUNSEL'
					AND S.sbrsDscrptn = '(P)-CO-COUNSEL'
					AND S.sbrnRoleID = 4)
				OR (P.role = 'DRIVER'
					AND S.sbrsDscrptn = '(P)-DRIVER'
					AND S.sbrnRoleID = 4)
				OR (P.role = 'INS ADJUSTER'
					AND S.sbrsDscrptn = '(P)-ADJUSTER'
					AND S.sbrnRoleID = 4)
				OR (P.role = 'OWNER'
					AND S.sbrsDscrptn = '(P)-OWNER'
					AND S.sbrnRoleID = 4)
				OR (P.role = 'PROPERTY OWNER'
					AND S.sbrsDscrptn = '(P)-PROPERTY OWNER'
					AND S.sbrnRoleID = 4)
			)
	WHERE p.our_client = 'Y'
GO

/*
select * from [sma_MST_SubRole]
---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Plaintiff'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN

    update [SA].[dbo].[sma_TRN_Plaintiff] set plnnRole=S.sbrnSubRoleId
    from JoelBieberNeedles.[dbo].[party_indexed] P 
    inner join [SA].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber = P.case_id  
    inner join [SA].[dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=4 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed CIO on CIO.SAGA = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;


GO
*/


-------------------------------------------------------------------------------
-- Create Defendants from PartyRoles
-------------------------------------------------------------------------------

INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole], [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority], [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified], [defnLevelNo], [defsMarked], [saga], [saga_party]
	)
	SELECT
		casnCaseID	  AS [defnCaseID]
	   ,ACIO.CTG	  AS [defnContactCtgID]
	   ,ACIO.CID	  AS [defnContactID]
	   ,ACIO.AID	  AS [defnAddressID]
	   ,sbrnSubRoleId AS [defnSubRole]
	   ,1			  AS [defbIsPrimary]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,368			  AS [defnRecUserID]
	   ,GETDATE()	  AS [defdDtCreated]
	   ,NULL		  AS [defnModifyUserID]
	   ,NULL		  AS [defdDtModified]
	   ,NULL		  AS [defnLevelNo]
	   ,NULL
	   ,NULL
	   ,P.TableIndex  AS [saga_party]
	FROM JoelBieberNeedles.[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = P.case_id
	JOIN IndvOrgContacts_Indexed ACIO
		ON ACIO.SAGA = P.party_id
	JOIN [PartyRoles] pr
		ON pr.[Needles Roles] = p.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = [sa roles]
			AND S.sbrnRoleID = 5
	WHERE pr.[sa party] = 'Defendant'
GO


---------------------------------------------------------------------------------------
-- Create Plaintiffs from PartyRoles for roles that are applicable to both pln and def
---------------------------------------------------------------------------------------
INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole], [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority], [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified], [defnLevelNo], [defsMarked], [saga], [saga_party]
	)
	SELECT
		CAS.casnCaseID  AS [defnCaseID]
	   ,ACIO.CTG		AS [defnContactCtgID]
	   ,ACIO.CID		AS [defnContactID]
	   ,ACIO.AID		AS [defnAddressID]
	   ,S.sbrnSubRoleId AS [defnSubRole]
	   ,1				AS [defbIsPrimary]
	   ,NULL			AS [defbCounterClaim]
	   ,NULL			AS [defbThirdParty]
	   ,NULL			AS [defsThirdPartyRole]
	   ,NULL			AS [defnPriority]
	   ,NULL			AS [defdFrmDt]
	   ,NULL			AS [defdToDt]
	   ,368				AS [defnRecUserID]
	   ,GETDATE()		AS [defdDtCreated]
	   ,NULL			AS [defnModifyUserID]
	   ,NULL			AS [defdDtModified]
	   ,NULL			AS [defnLevelNo]
	   ,NULL			AS [defsMarked]
	   ,''				AS [saga]
	   ,P.TableIndex	AS [saga_party]
	FROM JoelBieberNeedles.[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = P.case_id
	JOIN IndvOrgContacts_Indexed ACIO
		ON ACIO.SAGA = P.party_id
	--JOIN [PartyRoles] PR
	--	ON PR.[Needles Roles] = P.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND (
				(P.role = 'CO-COUNSEL'
					AND S.sbrsDscrptn = '(D)-CO-COUNSEL'
					AND S.sbrnRoleID = 5)
				OR (P.role = 'DRIVER'
					AND S.sbrsDscrptn = '(D)-DRIVER'
					AND S.sbrnRoleID = 5)
				OR (P.role = 'INS ADJUSTER'
					AND S.sbrsDscrptn = '(D)-ADJUSTER'
					AND S.sbrnRoleID = 5)
				OR (P.role = 'OWNER'
					AND S.sbrsDscrptn = '(D)-OWNER'
					AND S.sbrnRoleID = 5)
				OR (P.role = 'PROPERTY OWNER'
					AND S.sbrsDscrptn = '(D)-PROPERTY OWNER'
					AND S.sbrnRoleID = 5)
			)
	WHERE p.our_client = 'N'
		--AND p.case_id = 204162
GO


/*
from JoelBieberNeedles.[dbo].[party_indexed] P 
inner join [SA].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
inner join [SA].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA = P.party_id
where S.sbrnRoleID=5 and S.sbrsDscrptn='(D)-Default Role'
and P.role in (SELECT [Needles Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Defendant')
GO

---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Defendant'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN


    update [SA].[dbo].[sma_TRN_Defendants] set defnSubRole=S.sbrnSubRoleId
    from JoelBieberNeedles.[dbo].[party_indexed] P 
    inner join [SA].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
    inner join [SA].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=5 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
*/


/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix A)-- every case need at least one plaintiff
*/

INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID], [plnnContactCtg], [plnnContactID], [plnnAddressID], [plnnRole], [plnbIsPrimary], [plnbWCOut], [plnnPartiallySettled], [plnbSettled], [plnbOut], [plnbSubOut], [plnnSeatBeltUsed], [plnnCaseValueID], [plnnCaseValueFrom], [plnnCaseValueTo], [plnnPriority], [plnnDisbursmentWt], [plnbDocAttached], [plndFromDt], [plndToDt], [plnnRecUserID], [plndDtCreated], [plnnModifyUserID], [plndDtModified], [plnnLevelNo], [plnsMarked], [saga], [plnnNoInj], [plnnMissing], [plnnLIPBatchNo], [plnnPlaintiffRole], [plnnPlaintiffGroup], [plnnPrimaryContact]
	)
	SELECT
		casnCaseID AS [plnnCaseID]
	   ,1		   AS [plnnContactCtg]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Plaintiff'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [plnnContactID]
	   ,NULL	   AS [plnnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(P)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS plnnRole
	   ,1		   AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368		   AS [plnnRecUserID]
	   ,GETDATE()  AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,''
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1		   AS [plnnPrimaryContact]
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Plaintiff] T
		ON T.plnnCaseID = CAS.casnCaseID
	WHERE plnnCaseID IS NULL
GO



UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 0

UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 1
FROM (
	SELECT DISTINCT
		T.plnnCaseID
	   ,ROW_NUMBER() OVER (PARTITION BY T.plnnCaseID ORDER BY P.record_num) AS RowNumber
	   ,T.plnnPlaintiffID AS ID
	FROM sma_TRN_Plaintiff T
	LEFT JOIN JoelBieberNeedles.[dbo].[party_indexed] P
		ON P.TableIndex = T.saga_party
) A
WHERE A.RowNumber = 1
AND plnnPlaintiffID = A.ID



/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix B)-- every case need at least one defendant
*/

INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole], [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority], [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified], [defnLevelNo], [defsMarked], [saga]
	)
	SELECT
		casnCaseID AS [defnCaseID]
	   ,1		   AS [defnContactCtgID]
	   ,(
			SELECT
				cinnContactID
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Defendant'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [defnContactID]
	   ,NULL	   AS [defnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(D)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS [defnSubRole]
	   ,1		   AS [defbIsPrimary]
	   ,-- reexamine??
		NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,368		   AS [defnRecUserID]
	   ,GETDATE()  AS [defdDtCreated]
	   ,368		   AS [defnModifyUserID]
	   ,GETDATE()  AS [defdDtModified]
	   ,NULL
	   ,NULL
	   ,NULL
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Defendants] D
		ON D.defnCaseID = CAS.casnCaseID
	WHERE D.defnCaseID IS NULL

----
UPDATE sma_TRN_Defendants
SET defbIsPrimary = 0

UPDATE sma_TRN_Defendants
SET defbIsPrimary = 1
FROM (
	SELECT DISTINCT
		D.defnCaseID
	   ,ROW_NUMBER() OVER (PARTITION BY D.defnCaseID ORDER BY P.record_num) AS RowNumber
	   ,D.defnDefendentID AS ID
	FROM sma_TRN_Defendants D
	LEFT JOIN JoelBieberNeedles.[dbo].[party_indexed] P
		ON P.TableIndex = D.saga_party
) A
WHERE A.RowNumber = 1
AND defnDefendentID = A.ID

GO

---
ALTER TABLE [sma_TRN_Defendants] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Plaintiff] ENABLE TRIGGER ALL
GO

