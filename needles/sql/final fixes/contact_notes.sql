/*
- issue due to [sma_trn_Notes].[notnNoteTypeID] = null
1. create note type
2. assign it where missing
3. NoteContacts? - n/a as per rahul
*/


/* ------------------------------------------------------------------------------------------------------------

*/

SELECT * FROM sma_TRN_NoteContacts stnc where stnc.UniqueContactID = 185183
--where stnc.UniqueContactID like '%85183%'
where stnc.NoteID in (127645,
127644,
56163,
56162)

UPDATE sma_trn_notes
set notnCaseID = 0
where notnContactCtgID = 1 and notnContactId = 85183

select * from sma_TRN_Notes stn where stn.source_ref in ('party', 'provider_notes') and stn.notnNoteTypeID is null


select * from sma_trn_Notes where notnContactCtgID = 1 and notnContactId = 85183
SELECT * FROM ShinerSA..sma_TRN_Notes stn where stn.notnNoteID = 61449
SELECT * FROM ShinerSA..sma_TRN_NoteContacts stnc
SELECT * FROM ShinerSA..sma_MST_NoteTypes
SELECT * FROM sa..sma_MST_NoteTypes
SELECT * FROM sma_MST_NoteTypes where nttsNoteText like '%contact%'

select count(*) from sma_TRN_Notes stn where stn.source_ref in ('party', 'provider_notes') and stn.notnNoteTypeID is null
-- 152758

/* ------------------------------------------------------------------------------------------------------------
1. create note type
*/

select * from sma_MST_NoteTypes where nttscode = 'contact'

insert into sma_MST_NoteTypes
	(
		nttsCode,
		nttsDscrptn,
		nttsNoteText,
		nttnRecUserID,
		nttdDtCreated
	)
	values
	('CONTACT', 'Contact Note', 'Note related to contacts', 368, GETDATE())

/* ------------------------------------------------------------------------------------------------------------
2. assign it where missing
*/
update sma_TRN_Notes
set notnNoteTypeID = (
	select
		nttnNoteTypeID
	from sma_MST_NoteTypes
	where nttsCode = 'Contact'
)
where source_ref in ('party', 'provider_notes')
and notnNoteTypeID is null


/*
insert records into sma_TRN_NoteContacts
sma_TRN_NoteContacts.NoteId = sma_TRN_Notes.notnNoteID

*/


--SELECT top 1000 * FROM sma_TRN_Notes stn
--where stn.notnContactId = 85183 and stn.notnContactCtgID = 1

--SELECT * FROM sma_TRN_NoteContacts stnc

--insert into sma_TRN_NoteContacts
--(NoteID, UniqueContactID)
--select
--	null as NoteID,
--	null as UniqueContactID
--from sma_TRN_Notes


-- -----------------------------------------
----INSERT RELATED TO FIELD FOR NOTES
-------------------------------------------
--insert into sma_TRN_NoteContacts
--	(
--	NoteID, UniqueContactID
--	)
--	select distinct
--		note.notnNoteID,
--		ioc.UNQCID
--	--select v.provider, ioc.*, n.note, note.*
--	from JoelBieberNeedles..[value_notes] n
--	join JoelBieberNeedles..value_Indexed v
--		on v.value_id = n.value_num
--	join sma_trn_Cases cas
--		on cas.cassCaseNumber = v.case_id
--	join IndvOrgContacts_Indexed ioc
--		on ioc.saga = v.[provider]
--	join [sma_TRN_Notes] note
--		on note.saga = n.note_key
--			and note.[notnNoteTypeID] = (
--				select top 1
--					nttnNoteTypeID
--				from [sma_MST_NoteTypes]
--				where nttsDscrptn = n.topic
--			)

--UPDATE nc
--set UniqueContactID = n.notnContactId
--from sma_TRN_NoteContacts nc
--join sma_TRN_Notes n
--on nc.NoteID = n.notnNoteID

--SELECT nc.*, n.notnNoteID, n.notnContactId
--FROM sma_trn_notecontacts nc
--join sma_TRN_Notes n
--on n.notnNoteID = nc.NoteID
--where n.notnContactId is not null


--SELECT * FROM sma_TRN_Notes stn where stn.notnContactId is not null


---- for note records with contactid, ensure they have a record in NoteContacts
--insert into sma_TRN_NoteContacts
--	(
--	NoteID, UniqueContactID
--	)
--	select distinct
--		n.notnNoteID as NoteID,
--		ioci.UNQCID	 as UniqueContactID
--	from sma_TRN_Notes n
--	join IndvOrgContacts_Indexed ioci
--		on ioci.CID = n.notnContactId
--			and ioci.CTG = n.notnContactCtgID
--	where n.notnContactId = 85183
--	--where n.notnContactId is not null
--	--and n.notnContactId = 85183

--	except

--	select
--		NoteID,
--		UniqueContactID
--	from sma_TRN_NoteContacts


--	select count(*) from sma_trn_Notes where notnContactId is not null
--	--154736