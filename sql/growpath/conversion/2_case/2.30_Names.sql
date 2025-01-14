USE ShinerSA
GO


---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'TempCaseName'
			AND type = 'U'
	)
BEGIN
	DROP TABLE TempCaseName
END

SELECT
	CAS.casnCaseID										  AS CaseID
   ,CAS.cassCaseName									  AS CaseName
   ,ISNULL(IOC.Name, '') + ' v. ' + ISNULL(IOCD.Name, '') AS NewCaseName INTO TempCaseName
FROM sma_TRN_Cases CAS
LEFT JOIN sma_TRN_Plaintiff T
	ON T.plnnCaseID = CAS.casnCaseID
		AND T.plnbIsPrimary = 1
LEFT JOIN (
	SELECT
		cinnContactID AS CID
	   ,cinnContactCtg AS CTG
	   ,cinsLastName + ', ' + cinsFirstName AS Name		-- ds 2024-10-15 #36
	   --,cinsFirstName + ' ' + cinsLastName AS Name
	   ,saga AS SAGA
	FROM [sma_MST_IndvContacts]
	UNION
	SELECT
		connContactID AS CID
	   ,connContactCtg AS CTG
	   ,consName AS Name
	   ,saga AS SAGA
	FROM [sma_MST_OrgContacts]
) IOC
	ON IOC.CID = T.plnnContactID
		AND IOC.CTG = T.plnnContactCtg
LEFT JOIN sma_TRN_Defendants D
	ON D.defnCaseID = CAS.casnCaseID
		AND D.defbIsPrimary = 1
LEFT JOIN (
	SELECT
		cinnContactID AS CID
	   ,cinnContactCtg AS CTG
	   ,cinsLastName + ', ' + cinsFirstName AS Name		-- ds 2024-10-15 #36
	   --,cinsFirstName + ' ' + cinsLastName AS Name
	   ,saga AS SAGA
	FROM [sma_MST_IndvContacts]
	UNION
	SELECT
		connContactID AS CID
	   ,connContactCtg AS CTG
	   ,consName AS Name
	   ,saga AS SAGA
	FROM [sma_MST_OrgContacts]
) IOCD
	ON IOCD.CID = D.defnContactID
		AND IOCD.CTG = D.defnContactCtgID


---(1)---
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO
UPDATE sma_TRN_Cases
SET cassCaseName = A.NewCaseName
FROM TempCaseName A
WHERE A.CaseID = casnCaseID
AND ISNULL(A.CaseName, '') = ''

ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO


--select * from TempCaseName WHERE CaseID = 4575
--select * FROM ShinerSA..sma_TRN_Cases stc WHERE stc.casnCaseID = 4575