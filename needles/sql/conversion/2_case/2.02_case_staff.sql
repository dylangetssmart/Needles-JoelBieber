/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Insert sub-role codes from case staff mapping > [sma_MST_SubRoleCode]
	- Insert case staff from staff_1 through staff_4 > [sma_TRN_CaseStaff]	
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/



use [JoelBieberSA_Needles]
go


----(0) staff roles ----
-- Add the following roles into sma_MST_SubRoleCode if they do not exist
insert into [sma_MST_SubRoleCode]
	(
	srcsDscrptn, srcnRoleID
	)
	(
	--In Needles, box 1 = paralegal, box 2 = attorney, box 3 = negotiator, box 4 = clerical.  Also, box 6 = prior paralegal, box 7 = prior attorney.  Can the roles be imported?
	select
		'Attorney',
		10
	union all
	select
		'Intake Paralegal',
		10
	union all
	select
		'Primary Paralegal',
		10
	union all
	select
		'Primary Attorney',
		10
	union all
	select
		'Negotiator',
		10
	union all
	select
		'Overseeing Attorney/Paralegal',
		10
	)
	except
	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode]



---------------------------------------------------
-- [sma_TRN_caseStaff]
---------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseStaff')
	)
begin
	alter table [sma_TRN_caseStaff] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseStaff')
	)
begin
	alter table [sma_TRN_caseStaff] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseStaff')
	)
begin
	alter table [sma_TRN_caseStaff] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseStaff')
	)
begin
	alter table [sma_TRN_caseStaff] add [source_ref] VARCHAR(MAX) null;
end
go



alter table [sma_TRN_caseStaff] disable trigger all
go


/*
Hardcode staff_1 through staff_10 with "Staff"
*/

---- Declare variables
--DECLARE @i INT = 1;
--DECLARE @sql NVARCHAR(MAX);
--DECLARE @staffColumn NVARCHAR(20);

---- Loop through staff_1 to staff_10
--WHILE @i <= 10
--BEGIN
--    -- Set the current staff column
--    SET @staffColumn = 'staff_' + CAST(@i AS NVARCHAR(2));

--    -- Create the dynamic SQL query
--    SET @sql = '
--    INSERT INTO sma_TRN_caseStaff 
--    (
--           [cssnCaseID]
--          ,[cssnStaffID]
--          ,[cssnRoleID]
--          ,[csssComments]
--          ,[cssdFromDate]
--          ,[cssdToDate]
--          ,[cssnRecUserID]
--          ,[cssdDtCreated]
--          ,[cssnModifyUserID]
--          ,[cssdDtModified]
--          ,[cssnLevelNo]
--    )
--    SELECT 
--        CAS.casnCaseID              as [cssnCaseID],
--        U.usrnContactID             as [cssnStaffID],
--        (
--            select sbrnSubRoleId
--            from sma_MST_SubRole
--            where sbrsDscrptn=''Staff'' and sbrnRoleID=10
--        )                           as [cssnRoleID],
--        null                        as [csssComments],
--        null                        as cssdFromDate,
--        null                        as cssdToDate,
--        368                         as cssnRecUserID,
--        getdate()                   as [cssdDtCreated],
--        null                        as [cssnModifyUserID],
--        null                        as [cssdDtModified],
--        0                           as cssnLevelNo
--    FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--    JOIN [sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--    JOIN [sma_MST_Users] U on ( U.saga = C.' + @staffColumn + ' )
--    ';

--    -- Execute the dynamic SQL query
--    EXEC sp_executesql @sql;

--    -- Increment the counter
--    SET @i = @i + 1;
--END
--GO


-- ds 2024-11-07 only staff_1 through staff_4 are used

------------------------------------------------------------------------------
-- Convert staff_1 ###########################################################
------------------------------------------------------------------------------
insert into sma_TRN_caseStaff
	(
	[cssnCaseID], [cssnStaffID], [cssnRoleID], [csssComments], [cssdFromDate], [cssdToDate], [cssnRecUserID], [cssdDtCreated], [cssnModifyUserID], [cssdDtModified], [cssnLevelNo], [source_id], [source_db], [source_ref]
	)
	select
		CAS.casnCaseID					   as [cssnCaseID],
		COALESCE(m.SAUserID, u.usrnUserID) as [cssnStaffID], -- Use SAUserID if available, otherwise fallback to usrnUserID
		--,U.usrnContactID AS [cssnStaffID]
		--,iu.SAContactID AS [cssnStaffID]
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrsDscrptn = 'Primary Attorney'
				and sbrnRoleID = 10
		)								   as [cssnRoleID],
		null							   as [csssComments],
		null							   as cssdFromDate,
		null							   as cssdToDate,
		368								   as cssnRecUserID,
		GETDATE()						   as [cssdDtCreated],
		null							   as [cssnModifyUserID],
		null							   as [cssdDtModified],
		0								   as cssnLevelNo,
		c.staff_1						   as [source_id],
		'needles'						   as [source_db],
		'cases_indexed.staff_1'			   as [source_ref]
	from JoelBieberNeedles.[dbo].[cases_Indexed] C
	inner join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	inner join [sma_MST_Users] U
		on (U.source_id = C.staff_1)
	left join [conversion].[imp_user_map] m
		on m.StaffCode = c.staff_1

--INNER JOIN implementation_users iu
--	ON iu.StaffCode = c.staff_1

--------------------
----STAFF 2
--------------------
insert into sma_TRN_caseStaff
	(
	[cssnCaseID], [cssnStaffID], [cssnRoleID], [csssComments], [cssdFromDate], [cssdToDate], [cssnRecUserID], [cssdDtCreated], [cssnModifyUserID], [cssdDtModified], [cssnLevelNo], [source_id], [source_db], [source_ref]
	)
	select
		CAS.casnCaseID					   as [cssnCaseID],
		COALESCE(m.SAUserID, u.usrnUserID) as [casnrecuserid], -- Use SAUserID if available, otherwise fallback to usrnUserID
		--U.usrnContactID as [cssnStaffID]
		--,iu.SAContactID AS [cssnStaffID]
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrsDscrptn = 'Primary Paralegal'
				and sbrnRoleID = 10
		)								   as [cssnRoleID],
		null							   as [csssComments],
		null							   as cssdFromDate,
		null							   as cssdToDate,
		368								   as cssnRecUserID,
		GETDATE()						   as [cssdDtCreated],
		null							   as [cssnModifyUserID],
		null							   as [cssdDtModified],
		0								   as cssnLevelNo,
		c.staff_2						   as [source_id],
		'needles'						   as [source_db],
		'cases_indexed.staff_2'			   as [source_ref]
	from JoelBieberNeedles.[dbo].[cases_Indexed] C
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	join [sma_MST_Users] U
		on (U.source_id = C.staff_2)
	left join [conversion].[imp_user_map] m
		on m.StaffCode = c.staff_2
--INNER JOIN implementation_users iu
--	ON iu.StaffCode = c.staff_2

--------------------
----STAFF 3
--------------------
insert into sma_TRN_caseStaff
	(
	[cssnCaseID], [cssnStaffID], [cssnRoleID], [csssComments], [cssdFromDate], [cssdToDate], [cssnRecUserID], [cssdDtCreated], [cssnModifyUserID], [cssdDtModified], [cssnLevelNo], [source_id], [source_db], [source_ref]
	)
	select
		CAS.casnCaseID					   as [cssnCaseID],
		COALESCE(m.SAUserID, u.usrnUserID) as [casnrecuserid], -- Use SAUserID if available, otherwise fallback to usrnUserID
		--U.usrnContactID as [cssnStaffID]
		--,iu.SAContactID AS [cssnStaffID]
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrsDscrptn = 'Negotiator'
				and sbrnRoleID = 10
		)								   as [cssnRoleID],
		null							   as [csssComments],
		null							   as cssdFromDate,
		null							   as cssdToDate,
		368								   as cssnRecUserID,
		GETDATE()						   as [cssdDtCreated],
		null							   as [cssnModifyUserID],
		null							   as [cssdDtModified],
		0								   as cssnLevelNo,
		c.staff_3						   as [source_id],
		'needles'						   as [source_db],
		'cases_indexed.staff_3'			   as [source_ref]
	from JoelBieberNeedles.[dbo].[cases_Indexed] C
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	join [sma_MST_Users] U
		on (U.source_id = C.staff_3)
	left join [conversion].[imp_user_map] m
		on m.StaffCode = c.staff_3
--INNER JOIN implementation_users iu
--	ON iu.StaffCode = c.staff_3


--------------------
----STAFF 4
--------------------
insert into sma_TRN_caseStaff
	(
	[cssnCaseID], [cssnStaffID], [cssnRoleID], [csssComments], [cssdFromDate], [cssdToDate], [cssnRecUserID], [cssdDtCreated], [cssnModifyUserID], [cssdDtModified], [cssnLevelNo], [source_id], [source_db], [source_ref]
	)
	select
		CAS.casnCaseID					   as [cssnCaseID],
		COALESCE(m.SAUserID, u.usrnUserID) as [casnrecuserid], -- Use SAUserID if available, otherwise fallback to usrnUserID
		--U.usrnContactID as [cssnStaffID]
		--,iu.SAContactID AS [cssnStaffID]
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrsDscrptn = 'Overseeing Attorney/Paralegal'
				and sbrnRoleID = 10
		)								   as [cssnRoleID],
		null							   as [csssComments],
		null							   as cssdFromDate,
		null							   as cssdToDate,
		368								   as cssnRecUserID,
		GETDATE()						   as [cssdDtCreated],
		null							   as [cssnModifyUserID],
		null							   as [cssdDtModified],
		0								   as cssnLevelNo,
		c.staff_4						   as [source_id],
		'needles'						   as [source_db],
		'cases_indexed.staff_4'			   as [source_ref]
	from JoelBieberNeedles.[dbo].[cases_Indexed] C
	inner join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	inner join [sma_MST_Users] U
		on (U.source_id = C.staff_4)
	left join [conversion].[imp_user_map] m
		on m.StaffCode = c.staff_4
--INNER JOIN implementation_users iu
--	ON iu.StaffCode = c.staff_4


--------------------
----STAFF 5
--------------------
--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--inner join [SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_5 )
--*/

--------------------
----STAFF 6
--------------------
--INSERT INTO sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--SELECT 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Attorney' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--JOIN [sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--JOIN [sma_MST_Users] U on ( U.saga = C.staff_6 )

--/*
--------------------
----STAFF 7
--------------------
--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--inner join [SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_7 )


--------------------
----STAFF 8
--------------------
--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--inner join [SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_8 )
--*/

--------------------
----STAFF 9
--------------------
--INSERT INTO sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--SELECT 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Intake Paralegal' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--JOIN sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
--JOIN sma_MST_Users U on ( U.saga = C.staff_9 )

--/*
--------------------
----STAFF 10
--------------------
--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM JoelBieberNeedles.[dbo].[cases_Indexed] C
--inner join [SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_10 )
--*/


---
alter table [sma_TRN_caseStaff] enable trigger all
go
---


