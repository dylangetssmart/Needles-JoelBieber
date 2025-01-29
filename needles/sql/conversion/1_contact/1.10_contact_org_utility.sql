/* ###################################################################################
description: Handle all operations related to [sma_MST_IndvContacts]
steps:
	- add saga
	- add saga_char
	- Unidentified Medical Provider
	- Unidentified Insurance
	- Unidentified Court
	- Unidentified Lienor
	- Unidentified School
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#####################################################################################
*/


/* --------------------------------------------------------------------------------------------------------------
- Update schema
*/

-- saga (INT)
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_id] VARCHAR(max) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_db] VARCHAR(max) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_ref] VARCHAR(max) null;
end
go


---------------------------------------------------
-- [1] - Unidentified Medical Provider
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Medical Provider'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Medical Provider' as [consname],
			2								as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'Hospital'
			)								as [conncontacttypeid],
			368								as [connrecuserid],
			GETDATE()						as [conddtcreated]
end
go

---------------------------------------------------
-- [2] - Unidentified Insurance
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Insurance'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Insurance' as [consname],
			2						 as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'Insurance Company'
			)						 as [conncontacttypeid],
			368						 as [connrecuserid],
			GETDATE()				 as [conddtcreated]
end
go

---------------------------------------------------
-- [3] - Unidentified Court
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Court'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Court' as [consname],
			2					 as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'Court'
			)					 as [conncontacttypeid],
			368					 as [connrecuserid],
			GETDATE()			 as [conddtcreated]
end
go

---------------------------------------------------
-- [4] - Unidentified Lienor
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Lienor'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Lienor' as [consname],
			2					  as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end
go

---------------------------------------------------
-- [5] - Unidentified School
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified School'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified School' as [consname],
			2					  as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end
go

---------------------------------------------------
-- [6] - Unidentified Employer
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Employer'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Employer' as [consname],
			2					  as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end
go