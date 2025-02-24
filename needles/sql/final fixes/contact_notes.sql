SELECT * FROM sma_TRN_NoteContacts stnc where stnc.UniqueContactID = 185183
where stnc.UniqueContactID like '%85183%'
where stnc.NoteID in (127645,
127644,
56163,
56162)

 select * from sma_trn_Notes where notnContactCtgID = 1 and notnContactId = 85183


 -----------------------------------------
--INSERT RELATED TO FIELD FOR NOTES
-----------------------------------------
insert into sma_TRN_NoteContacts
	(
	NoteID, UniqueContactID
	)
	select distinct
		note.notnNoteID,
		ioc.UNQCID
	--select v.provider, ioc.*, n.note, note.*
	from JoelBieberNeedles..[value_notes] n
	join JoelBieberNeedles..value_Indexed v
		on v.value_id = n.value_num
	join sma_trn_Cases cas
		on cas.cassCaseNumber = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga = v.[provider]
	join [sma_TRN_Notes] note
		on note.saga = n.note_key
			and note.[notnNoteTypeID] = (
				select top 1
					nttnNoteTypeID
				from [sma_MST_NoteTypes]
				where nttsDscrptn = n.topic
			)

UPDATE nc
set UniqueContactID = n.notnContactId
from sma_TRN_NoteContacts nc
join sma_TRN_Notes n
on nc.NoteID = n.notnNoteID

SELECT nc.*, n.notnNoteID, n.notnContactId
FROM sma_trn_notecontacts nc
join sma_TRN_Notes n
on n.notnNoteID = nc.NoteID
where n.notnContactId is not null


SELECT * FROM sma_TRN_Notes stn where stn.notnContactId is not null


-- for note records with contactid, ensure they have a record in NoteContacts
insert into sma_TRN_NoteContacts
	(
	NoteID, UniqueContactID
	)
	select distinct
		n.notnNoteID as NoteID,
		ioci.UNQCID	 as UniqueContactID
	from sma_TRN_Notes n
	join IndvOrgContacts_Indexed ioci
		on ioci.CID = n.notnContactId
			and ioci.CTG = n.notnContactCtgID
	where n.notnContactId is not null
	--and n.notnContactId = 85183

	except

	select
		NoteID,
		UniqueContactID
	from sma_TRN_NoteContacts


	select count(*) from sma_trn_Notes where notnContactId is not null
	--154736