/* ###################################################################################
description: Create users
steps:
	- Create IndvContacts for staff users
	- Create aadmin user
	- Create conversion user
	- create contacts from staff
	- emails for staff
	- users from staff
	- sma_TRN_CaseBrowseSettings
usage_instructions:
	-
dependencies:
	- 1.00_std_UnidentifiedIndvContacts
notes:
	-
#######################################################################################
*/

use [JohnSalazar_SA]
go

-- Add [saga_char] to [sma_MST_Users]
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [saga_char] VARCHAR(255) null;
end

go

/* --------------------------------------------------------------------------------------------------------------
- Users
*/

-- Create 'aadmin' user
if (
		select
			COUNT(*)
		from sma_mst_users
		where usrsLoginID = 'aadmin'
	) = 0
begin
	set identity_insert sma_mst_users on

	insert into [sma_MST_Users]
		(
		usrnUserID, [usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
		)
		select distinct
			368		  as usrnuserid,
			(
				select
				top 1
					cinnContactID
				from dbo.sma_MST_IndvContacts
				where cinsLastName = 'Unassigned'
					and cinsFirstName = 'Staff'
			)		  as usrncontactid,
			'aadmin'  as usrsloginid,
			'2/'	  as usrspassword,
			null	  as [usrsbackcolor],
			null	  as [usrsreadbackcolor],
			null	  as [usrsevenbackcolor],
			null	  as [usrsoddbackcolor],
			33		  as [usrnroleid],
			null	  as [usrdlogindate],
			null	  as [usrdlogoffdate],
			null	  as [usrnuserlevel],
			null	  as [usrsworkstation],
			null	  as [usrnportno],
			null	  as [usrbloggedin],
			null	  as [usrbcaselevelrights],
			null	  as [usrbcaselevelfilters],
			null	  as [usrnunsuccesfullogincount],
			1		  as [usrnrecuserid],
			GETDATE() as [usrddtcreated],
			null	  as [usrnmodifyuserid],
			null	  as [usrddtmodified],
			null	  as [usrnlevelno],
			null	  as [usrscaseclosecolor],
			null	  as [usrndocassembly],
			null	  as [usrnadmin],
			null	  as [usrnislocked],
			1		  as [usrbactivestate]
	set identity_insert sma_mst_users off
end

-- Create 'conversion' user
if (
		select
			COUNT(*)
		from sma_mst_users
		where usrsLoginID = 'conversion'
	) = 0
begin
	insert into [sma_MST_Users]
		(
		[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
		)
		select distinct
			(
				select
				top 1
					cinnContactID
				from dbo.sma_MST_IndvContacts
				where cinsLastName = 'Unassigned'
					and cinsFirstName = 'Staff'
			)			 as usrncontactid,
			'conversion' as usrsloginid,
			'pass'		 as usrspassword,
			null		 as [usrsbackcolor],
			null		 as [usrsreadbackcolor],
			null		 as [usrsevenbackcolor],
			null		 as [usrsoddbackcolor],
			33			 as [usrnroleid],
			null		 as [usrdlogindate],
			null		 as [usrdlogoffdate],
			null		 as [usrnuserlevel],
			null		 as [usrsworkstation],
			null		 as [usrnportno],
			null		 as [usrbloggedin],
			null		 as [usrbcaselevelrights],
			null		 as [usrbcaselevelfilters],
			null		 as [usrnunsuccesfullogincount],
			1			 as [usrnrecuserid],
			GETDATE()	 as [usrddtcreated],
			null		 as [usrnmodifyuserid],
			null		 as [usrddtmodified],
			null		 as [usrnlevelno],
			null		 as [usrscaseclosecolor],
			null		 as [usrndocassembly],
			null		 as [usrnadmin],
			null		 as [usrnislocked],
			1			 as [usrbactivestate]
end

-- Insert [sma_MST_Users] from [staff]
insert into [sma_MST_Users]
	(
	[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [saga_char], [usrbActiveState], [usrbIsShowInSystem]
	)
	select
		indv.cinnContactID as [usrncontactid],
		s.staff_code	   as [usrsloginid],
		'#'				   as [usrspassword],
		null			   as [usrsbackcolor],
		null			   as [usrsreadbackcolor],
		null			   as [usrsevenbackcolor],
		null			   as [usrsoddbackcolor],
		33				   as [usrnroleid],
		null			   as [usrdlogindate],
		null			   as [usrdlogoffdate],
		null			   as [usrnuserlevel],
		null			   as [usrsworkstation],
		null			   as [usrnportno],
		null			   as [usrbloggedin],
		null			   as [usrbcaselevelrights],
		null			   as [usrbcaselevelfilters],
		null			   as [usrnunsuccesfullogincount],
		1				   as [usrnrecuserid],
		GETDATE()		   as [usrddtcreated],
		null			   as [usrnmodifyuserid],
		null			   as [usrddtmodified],
		null			   as [usrnlevelno],
		null			   as [usrscaseclosecolor],
		null			   as [usrndocassembly],
		null			   as [usrnadmin],
		null			   as [usrnislocked],
		s.staff_code	   as [saga_char],
		0				   as [usrbactivestate],
		1				   as [usrbisshowinsystem]
	from JoelBieberNeedles..staff s
	join sma_MST_IndvContacts indv
		on indv.saga_char = s.staff_code
	--on indv.cinsGrade = s.staff_code
	left join [sma_MST_Users] u
		on u.saga_char = s.staff_code
	where u.usrsloginid is null
go



/* --------------------------------------------------------------------------------------------------------------
Update [BridgeMap]
*/

-- [SourceTables]
if not exists (
		select
			1
		from conversion.SourceTables
		where SourceDB = N'JoelBieberNeedles'
			and SourceTable = N'staff'
			and SourceColumn = N'staff_code'
	)
begin
	insert into conversion.SourceTables
		(
		SourceDB, SourceTable, SourceColumn, SourceDataType
		)
	values (
	N'JoelBieberNeedles',
	N'staff',
	N'staff_code',
	'char'
	)
end;

-- [BridgeMap]
with cte_bridgetables
as
(
	select
		ID
	from [conversion].[BridgeTables]
	where BridgeTable = N'sma_MST_Users'
),
cte_sourcetables
as
(
	select
		[ID]
	from [conversion].[SourceTables]
	where [SourceDB] = N'JoelBieberNeedles'
		and [SourceSchema] = N'dbo'
		and [SourceTable] = N'staff'
)
insert into [conversion].[BridgeMap]
	(
	[BridgeTableID], [BridgeRecordID], [SourceTableID], [SourceRecordID_char]
	)
	select
		cte_bridgetables.ID			  as [BridgeTableID],
		CONVERT(BIGINT, u.usrnUserID) as [BridgeRecordID],
		cte_sourcetables.ID			  as [sourcetableid],
		s.staff_code				  as [sourcerecordid_char]
	from dbo.sma_MST_Users u
	inner join [JoelBieberNeedles].[dbo].[staff] s
		on u.saga_char = s.staff_code
	cross join cte_bridgetables
	cross join cte_sourcetables;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

declare @UserID INT

declare staff_cursor cursor fast_forward for select
	usrnUserID
from sma_mst_users

open staff_cursor

fetch next from staff_cursor into @UserID

set nocount on;
while @@FETCH_STATUS = 0
begin
-- Print the fetched UserID for debugging
print 'Fetched UserID: ' + CAST(@UserID as VARCHAR);

-- Check if @UserID is NULL
if @UserID is not null
begin
	print 'Inserting for UserID: ' + CAST(@UserID as VARCHAR);

	insert into sma_TRN_CaseBrowseSettings
		(
		cbsnColumnID, cbsnUserID, cbssCaption, cbsbVisible, cbsnWidth, cbsnOrder, cbsnRecUserID, cbsdDtCreated, cbsn_StyleName
		)
		select distinct
			cbcnColumnID,
			@UserID,
			cbcsColumnName,
			'True',
			200,
			cbcnDefaultOrder,
			@UserID,
			GETDATE(),
			'Office2007Blue'
		from [sma_MST_CaseBrowseColumns]
		where cbcnColumnID not in (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33);
end
else
begin
	-- Log the NULL @UserID occurrence
	print 'NULL UserID encountered. Skipping insert.';
end

fetch next from staff_cursor into @UserID;
end

close staff_cursor
deallocate staff_cursor



---- Appendix ----
insert into Account_UsersInRoles
	(
	user_id, role_id
	)
	select
		usrnUserID as user_id,
		2		   as role_id
	from sma_MST_Users

update sma_MST_Users
set usrbActiveState = 1
where usrsLoginID = 'aadmin'

update Account_UsersInRoles
set role_id = 1
where user_id = 368 


