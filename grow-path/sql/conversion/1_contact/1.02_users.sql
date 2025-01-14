/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts and users

--------------------------------------------------------------------------------------------------------------------------------------
Step									Object							Source						Notes
--------------------------------------------------------------------------------------------------------------------------------------
1. Create indv contacts					sma_MST_IndvContacts			dbo.User
2. Insert addresses						sma_MST_Address					dbo.User
3. Insert email addresses				sma_MST_EmailWebsite			dbo.User
4. Insert phone number types			sma_MST_ContactNoType			hardcode
5. Insert phone numbers					sma_MST_ContactNumbers			dbo.User					Work Fax, HQ/Main Office Phone, Cell
6. Create aadmin user					sma_MST_Users					hardcode
7. Create conversion user				sma_MST_Users					hardcode
8. Create users							sma_MST_Users					sma_MST_IndvContacts		The only IndvContacts that exist at this point were created above from User
						
##########################################################################################################################
*/

use ShinerSA
go

---------------------------------------------------
-- [1.4] Users
---------------------------------------------------
alter table sma_MST_Users disable trigger all
go

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table sma_MST_Users
	add saga VARCHAR(255)
end

-- Create aadmin user using Unassigned Staff contact
if (
		select
			COUNT(*)
		from sma_MST_Users
		where usrsLoginID = 'aadmin'
	) = 0
begin
	set identity_insert sma_MST_Users on

	insert into [sma_MST_Users]
		(
		usrnUserID,
		[usrnContactID],
		[usrsLoginID],
		[usrsPassword],
		[usrsBackColor],
		[usrsReadBackColor],
		[usrsEvenBackColor],
		[usrsOddBackColor],
		[usrnRoleID],
		[usrdLoginDate],
		[usrdLogOffDate],
		[usrnUserLevel],
		[usrsWorkstation],
		[usrnPortno],
		[usrbLoggedIn],
		[usrbCaseLevelRights],
		[usrbCaseLevelFilters],
		[usrnUnsuccesfulLoginCount],
		[usrnRecUserID],
		[usrdDtCreated],
		[usrnModifyUserID],
		[usrdDtModified],
		[usrnLevelNo],
		[usrsCaseCloseColor],
		[usrnDocAssembly],
		[usrnAdmin],
		[usrnIsLocked],
		[usrbActiveState]
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
	set identity_insert sma_MST_Users off
end
go

-- Create converison user using Unassigned Staff contact
if (
		select
			COUNT(*)
		from sma_mst_users
		where usrsLoginID = 'conversion'
	) = 0
begin
	insert into [sma_MST_Users]
		(
		[usrnContactID],
		[usrsLoginID],
		[usrsPassword],
		[usrsBackColor],
		[usrsReadBackColor],
		[usrsEvenBackColor],
		[usrsOddBackColor],
		[usrnRoleID],
		[usrdLoginDate],
		[usrdLogOffDate],
		[usrnUserLevel],
		[usrsWorkstation],
		[usrnPortno],
		[usrbLoggedIn],
		[usrbCaseLevelRights],
		[usrbCaseLevelFilters],
		[usrnUnsuccesfulLoginCount],
		[usrnRecUserID],
		[usrdDtCreated],
		[usrnModifyUserID],
		[usrdDtModified],
		[usrnLevelNo],
		[usrsCaseCloseColor],
		[usrnDocAssembly],
		[usrnAdmin],
		[usrnIsLocked],
		[usrbActiveState]
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

-- Create users from individual contacts
insert into [sma_MST_Users]
	(
	[usrnContactID],
	[usrsLoginID],
	[usrsPassword],
	[usrsBackColor],
	[usrsReadBackColor],
	[usrsEvenBackColor],
	[usrsOddBackColor],
	[usrnRoleID],
	[usrdLoginDate],
	[usrdLogOffDate],
	[usrnUserLevel],
	[usrsWorkstation],
	[usrnPortno],
	[usrbLoggedIn],
	[usrbCaseLevelRights],
	[usrbCaseLevelFilters],
	[usrnUnsuccesfulLoginCount],
	[usrnRecUserID],
	[usrdDtCreated],
	[usrnModifyUserID],
	[usrdDtModified],
	[usrnLevelNo],
	[usrsCaseCloseColor],
	[usrnDocAssembly],
	[usrnAdmin],
	[usrnIsLocked],
	[usrbActiveState],
	[usrnFirmRoleID],
	[usrnFirmTitleID],
	[usrbIsShowInSystem],
	[saga_char]
	)
	select
		cinnContactID as [usrncontactid],
		up.username	  as [usrsloginid],
		'#'			  as [usrspassword],
		null		  as [usrsbackcolor],
		null		  as [usrsreadbackcolor],
		null		  as [usrsevenbackcolor],
		null		  as [usrsoddbackcolor],
		33			  as [usrnroleid],
		null		  as [usrdlogindate],
		null		  as [usrdlogoffdate],
		null		  as [usrnuserlevel],
		null		  as [usrsworkstation],
		null		  as [usrnportno],
		null		  as [usrbloggedin],
		null		  as [usrbcaselevelrights],
		null		  as [usrbcaselevelfilters],
		null		  as [usrnunsuccesfullogincount],
		1			  as [usrnrecuserid],
		GETDATE()	  as [usrddtcreated],
		null		  as [usrnmodifyuserid],
		null		  as [usrddtmodified],
		null		  as [usrnlevelno],
		null		  as [usrscaseclosecolor],
		null		  as [usrndocassembly],
		0			  as [usrnadmin],
		null		  as [usrnislocked],
		0			  as [usrbactivestate],
		21862		  as [usrnfirmroleid],
		21866		  as [usrnfirmtitleid],
		0			  as [usrbisshowinsystem],
		up.id		  as [saga]
	from sma_MST_IndvContacts ind
	join JoelBieber_GrowPath..user_profile up
		on ind.saga = up.id
	left join [sma_MST_Users] u
		on u.saga = ind.saga
	where u.usrsloginid is null
--join ShinerLitify..[user] lu
--	on ind.saga_char = lu.Id
--left join [sma_MST_Users] u
--	on u.saga_char = ind.saga_char
--where u.usrsloginid is null
--	and lu.Alias <> 'APP'
--order by usrsloginid
go

--select
--	username, alias, id
--from ShinerLitify..[User] u
--order by u.Username

-----------------------------------------------------------
-- Add default set of case browse columns for every user.
-----------------------------------------------------------

declare @UserID INT

declare staff_cursor cursor fast_forward for select
	usrnUserID
from sma_MST_Users

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
		cbsnColumnID,
		cbsnUserID,
		cbssCaption,
		cbsbVisible,
		cbsnWidth,
		cbsnOrder,
		cbsnRecUserID,
		cbsdDtCreated,
		cbsn_StyleName
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
go

---- Appendix ----
insert into Account_UsersInRoles
	(
	user_id,
	role_id
	)
	select
		usrnUserID as user_id,
		2		   as role_id
	from sma_MST_Users

update Account_UsersInRoles
set role_id = 1
where user_id = 368