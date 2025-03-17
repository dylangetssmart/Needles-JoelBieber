/*
2.13_negotiate.sql stamped userid as staffid, should have been contact id
COALESCE(m.SAUserID, u.usrnUserID) as negnStaffID,

todo:
- for converted [sma_TRN_Negotiations] records, update [negnStaffID] to use [sma_MST_IndvContacts].[cinnContactID]
*/
	
	
/* ------------------------------------------------------------------------------------------------------------
discovery
*/
SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber = '225155'
SELECT * FROM sma_TRN_Negotiations stn where negnCaseID = 19613

select * from sma_MST_Users where usrnUserID = 451
select * from conversion.imp_user_map


select 
(select usrnContactiD from sma_MST_Users where source_id=NEG.staff) as usrnContactiD,
(select SAContactID from conversion.imp_user_map where StaffCode=NEG.staff) as SAContactID,
COALESCE(

(select usrnContactiD from sma_MST_Users where source_id=NEG.staff),

(select SAContactID from conversion.imp_user_map where StaffCode=NEG.staff)


) as negnStaffID
from JoelBieberNeedles.[dbo].[negotiation] NEG
	left join JoelBieberNeedles.[dbo].[insurance_Indexed] INS
		on INS.insurance_id = NEG.insurance_id
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = NEG.case_id
	left join [JoelBieberSA_Needles].[conversion].[Insurance_Contacts_Helper] MAP
		on INS.insurance_id = MAP.insurance_id
	left join [conversion].[imp_user_map] m
		on m.StaffCode = neg.staff
	left join [sma_MST_Users] u
		on u.source_id = neg.staff
	where NEG.neg_id = 25360

SELECT neg_id, staff FROM JoelBieberNeedles..negotiation n where n.neg_id = 25360
SELECT * FROM sma_mst_indvcontacts where cinncontactid = 113

SELECT * FROM sma_TRN_Negotiations stn where negnCaseID = 19613

-- record count
SELECT count(*) FROM sma_TRN_Negotiations n where
	n.source_db = 'needles'
	and n.source_ref = 'negotiation'
-- 22770


--
select
	n.negnStaffID as negnStaffID,
	(
		select
			usrnContactiD
		from sma_MST_Users
		where source_id = NEG.staff
	)			  as usrnContactiD,
	(
		select
			SAContactID
		from conversion.imp_user_map
		where StaffCode = NEG.staff
	)			  as SAContactID,
	COALESCE((
		select
			usrnContactID
		from sma_MST_Users
		where source_id = NEG.staff
	), (
		select
			SAContactID
		from conversion.imp_user_map
		where StaffCode = NEG.staff
	))
from sma_trn_negotiations n
join JoelBieberNeedles..negotiation neg
	on neg.neg_id = n.saga
where
	n.source_db = 'needles'
	and n.source_ref = 'negotiation'
	and neg.neg_id in (24159,
27968,
27969,
27970,
28078,
28094,
28159)


/* ------------------------------------------------------------------------------------------------------------
update negotation records
*/

-- users with more than 1 source user
SELECT * FROM JoelBieberNeedles..staff s where s.full_name like '%marshall%' or s.full_name like '%bryant%' or s.full_name like '%schlegel%'
-- KGRAHAM
-- KMARSH
-- DANA
-- DANAB
-- BECCA
-- SCHLEGEL

-- are any of them applicable here?
SELECT * FROM JoelBieberNeedles..negotiation n where n.staff in (
'KGRAHAM',
'KMARSH',
'DANA',
'DANAB',
'BECCA',
'SCHLEGEL')

/*
neg_id 
24159 > DANAB
27968 > KMARSH
27969 > KMARSH
27970 > KMARSH
28078 > KMARSH
28094 > KMARSH
28159 > KMARSH
*/

select
	n.negnStaffID as negnStaffID,
	(
		select
			usrnContactiD
		from sma_MST_Users
		where source_id = NEG.staff
	)			  as usrnContactiD,
	(
		select
			SAContactID
		from conversion.imp_user_map
		where StaffCode = NEG.staff
	)			  as SAContactID,
	COALESCE((
		select
			usrnContactID
		from sma_MST_Users
		where source_id = NEG.staff
	), (
		select
			SAContactID
		from conversion.imp_user_map
		where StaffCode = NEG.staff
	))
from sma_trn_negotiations n
join JoelBieberNeedles..negotiation neg
	on neg.neg_id = n.saga
where
	n.source_db = 'needles'
	and n.source_ref = 'negotiation'
	and neg.neg_id in (24159,
27968,
27969,
27970,
28078,
28094,
28159)

-- looks good




update n
set n.negnStaffID = COALESCE((
	select
		SAContactID
	from conversion.imp_user_map
	where StaffCode = NEG.staff
), (
	select
		usrnContactID
	from sma_MST_Users
	where source_id = NEG.staff
))
from sma_trn_negotiations n
join JoelBieberNeedles..negotiation neg
	on neg.neg_id = n.saga
where n.source_db = 'needles'
and n.source_ref = 'negotiation'