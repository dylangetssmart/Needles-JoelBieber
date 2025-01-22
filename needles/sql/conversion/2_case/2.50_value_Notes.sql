/* ######################################################################################
description: Create note records from needles..value_notes

steps:
	- create note types from distinct instances of value_notes.topic
	- insert trn_notes

dependencies:
	- sma_TRN_Cases
	- sma_MST_users

notes:
	- value_notes appears to contain comments about specific value transactions using key value_num
	- value transactions may be mapped to disbursements, lien tracking, etc
	- each of those locations may or may not have a comment/description field large enough to hold the data from value_notes
	- therefore it is cleaner & easier to import these as TRN_Notes instead
	- but it technically should be possible/feasible to use value_notes to update a comment or description field for the associated value transaction

#########################################################################################
*/

USE [JoelBieberSA_Needles]
GO

/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/

----(0)----
--INSERT INTO [sma_MST_NoteTypes]
--	(
--	nttsDscrptn, nttsNoteText
--	)
--	SELECT
--		'Balance Verify'			  AS nttsDscrptn
--	   ,'Verify Outstanding Balances' AS nttsNoteText
--	EXCEPT
--	SELECT
--		nttsDscrptn
--	   ,nttsNoteText
--	FROM [sma_MST_NoteTypes]


-- Create note types that don't yet exist
INSERT INTO [sma_MST_NoteTypes]
	(
	nttsDscrptn, nttsNoteText
	)
	SELECT distinct
		vn.topic
		,vn.topic
		FROM JoelBieberNeedles..value_notes vn
	EXCEPT
	SELECT
		nttsDscrptn
	   ,nttsNoteText
	FROM [sma_MST_NoteTypes]


---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO [sma_TRN_Notes]
	(
	[notnCaseID], [notnNoteTypeID], [notmDescription], [notmPlainText], [notnContactCtgID], [notnContactId], [notsPriority], [notnFormID], [notnRecUserID], [notdDtCreated], [notnModifyUserID], [notdDtModified], [notnLevelNo], [notdDtInserted], [WorkPlanItemId], [notnSubject]
	)
	SELECT
		casnCaseID	 AS [notnCaseID]
	   ,(
			SELECT
				nttnNoteTypeID
			FROM [sma_MST_NoteTypes]
			WHERE nttsDscrptn = n.topic
		)			 
		AS [notnNoteTypeID]
	   ,note		 AS [notmDescription]
	   ,note		 AS [notmPlainText]
	   ,0			 AS [notnContactCtgID]
	   ,NULL		 AS [notnContactId]
	   ,NULL		 AS [notsPriority]
	   ,NULL		 AS [notnFormID]
	   ,U.usrnUserID AS [notnRecUserID]
	   ,CASE
			WHEN N.note_date BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(N.note_time, '00:00:00')) <> CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(N.note_date AS DATE) AS DATETIME) + CAST(CAST(N.note_time AS TIME) AS DATETIME)
			ELSE NULL
		END			 AS notdDtCreated
	   ,NULL		 AS [notnModifyUserID]
	   ,NULL		 AS notdDtModified
	   ,NULL		 AS [notnLevelNo]
	   ,NULL		 AS [notdDtInserted]
	   ,NULL		 AS [WorkPlanItemId]
	   ,NULL		 AS [notnSubject]
	FROM JoelBieberNeedles.[dbo].[value_notes] N
	JOIN JoelBieberNeedles.[dbo].[value_Indexed] V
		ON V.value_id = N.value_num
	JOIN [sma_TRN_Cases] C
		ON C.cassCaseNumber = V.case_id
	JOIN [sma_MST_Users] U
		ON U.saga = N.staff_id
GO

---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---

-----------------------------------------
--INSERT RELATED TO FIELD FOR NOTES
-----------------------------------------
INSERT INTO sma_TRN_NoteContacts
	(
	NoteID, UniqueContactID
	)
	SELECT DISTINCT
		note.notnNoteID
	   ,ioc.UNQCID
	--select v.provider, ioc.*, n.note, note.*
	FROM JoelBieberNeedles..[value_notes] N
	JOIN JoelBieberNeedles..value_Indexed V
		ON V.value_id = N.value_num
	JOIN sma_trn_Cases cas
		ON cas.cassCaseNumber = v.case_id
	JOIN IndvOrgContacts_Indexed ioc
		ON ioc.saga = v.[provider]
	JOIN [sma_TRN_Notes] note
		ON note.saga = n.note_key
			AND note.[notnNoteTypeID] = (
				SELECT
					nttnNoteTypeID
				FROM [sma_MST_NoteTypes]
				WHERE nttsDscrptn = n.topic
			)