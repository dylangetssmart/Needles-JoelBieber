/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts and users

--------------------------------------------------------------------------------------------------------------------------------------
Step				Object							Action			Source				Notes
--------------------------------------------------------------------------------------------------------------------------------------
	[1.1]			sma_mst_SubRoleCode				insert			hardcode			
	[1.2]			sma_mst_SubRole					insert			hardcode			
	[2.0]			sma_TRN_CaseStaff				insert			dbo.litify_pm__Matter__c

Reference
- https://smartadvocate.atlassian.net/wiki/spaces/Conversion/pages/2436366355/SmartAdvocate#Case-Roles

##########################################################################################################################
*/

use ShinerSA
go

------------------------------------
--INSERT SUBROLES
------------------------------------
--select * From sma_mst_subrolecode  where srcnRoleID = 10
--select * From sma_MST_SubRole where sbrnRoleID= 10


-- [1.1] Create SubRoleCodes that don't exist
-- from [litify_pm__Matter_team_member__c]
--INSERT INTO sma_mst_subrolecode
--(
--      srcsDscrptn
--      ,srcnRoleID
--)
--SELECT DISTINCT
--      tr.[name]
--      ,10
--FROM [ShinerLitify]..[litify_pm__Matter_team_member__c] tm
--      JOIN [ShinerLitify]..[litify_pm__Matter_team_role__c] tr
--            on tm.litify_pm__Role__c = tr.Id
--EXCEPT 
--      SELECT
--            srcsDscrptn
--            ,srcnRoleID
--      FROM sma_mst_subrolecode


-- [1.2] Insert SubRole that don't exist
-- from [litify_pm__Matter_team_member__c]
--INSERT INTO sma_MST_SubRole
--(
--      sbrnRoleID
--      ,sbrsDscrptn
--      ,sbrnTypeCode
--)
--SELECT DISTINCT
--      10
--      ,tr.[name]
--      ,(
--            Select srcnCodeID
--            from sma_mst_subrolecode
--            where srcnRoleID = 10
--                  and srcsDscrptn = tr.[name]
--      )
--FROM [ShinerLitify]..[litify_pm__Matter_team_member__c] tm
--      JOIN [ShinerLitify]..[litify_pm__Matter_team_role__c] tr
--            on tm.litify_pm__Role__c = tr.Id
--EXCEPT SELECT sbrnRoleID, sbrsDscrptn, sbrnTypeCode from sma_MST_SubRole 


--INSERT INTO sma_TRN_CaseStaff
--	(
--	[cssnCaseID]
--   ,[cssnStaffID]
--   ,[cssnRoleID]
--   ,[csssComments]
--   ,[cssdFromDate]
--   ,[cssdToDate]
--   ,[cssnRecUserID]
--   ,[cssdDtCreated]
--   ,[cssnModifyUserID]
--   ,[cssdDtModified]
--   ,[cssnLevelNo]
--	)
--	SELECT
--		CAS.casnCaseID  AS [cssnCaseID]
--	   ,u.usrnContactID AS [cssnStaffID]
--	   ,(
--			SELECT
--				sbrnSubRoleId
--			FROM sma_MST_SubRole
--			WHERE sbrnRoleID = 10
--				AND sbrsDscrptn = tr.[Name]
--		)				
--		AS [cssnRoleID]
--	   ,NULL			AS [csssComments]
--	   ,NULL			AS cssdFromDate
--	   ,NULL			AS cssdToDate
--	   ,368				AS cssnRecUserID
--	   ,GETDATE()		AS [cssdDtCreated]
--	   ,NULL			AS [cssnModifyUserID]
--	   ,NULL			AS [cssdDtModified]
--	   ,0				AS cssnLevelNo
--	FROM [sma_TRN_Cases] CAS
--	JOIN [ShinerLitify]..[litify_pm__Matter_Team_Member__c] tm
--		ON tm.litify_pm__Matter__c = cas.Litify_saga
--	JOIN [ShinerLitify]..[litify_pm__Matter_Team_Role__c] tr
--		ON tm.litify_pm__Role__c = tr.Id
--	JOIN [sma_MST_Users] u
--		ON u.saga = tm.litify_pm__User__c
--GO


/* ds 2024-09-17

1. create roles:
- Paralegal
- Principal Attorney
- Case Manager

2. Add case staff
- litify_pm__Principal_Attorney__c
- Paralegal__c
- litify_pm__lit_Case_Manager__c

*/

---------------------------------------------------
-- Validation
---------------------------------------------------

--SELECT
--	*
--FROM ShinerSA..sma_mst_SubRoleCode smsrc
--SELECT
--	*
--FROM ShinerSA..sma_MST_SubRole smsr

--sp_help 'litify_pm__Matter__c'
--SELECT * FROM [ShinerLitify]..litify_pm__Matter__c WHERE Name = 'MAT-23010526449'  
----id: a0L8Z00000eDawuUAC

--SELECT * FROM [ShinerLitify]..[litify_pm__Matter_team_member__c] tm WHERE tm.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'
--0058Z000009TKgXQAW
--0058Z000009TFzAQAW
--0058Z000009TRKTQA4

---------------------------------------------------
-- [1.0] Sub Roles
---------------------------------------------------

-- [1.1] Create SubRole Codes
insert into sma_mst_SubRoleCode
	(
	srcsDscrptn,
	srcnRoleID
	)
	select
		v.srcsdscrptn,
		v.srcnroleid
	from (
		select
			'Paralegal' as srcsdscrptn,
			10 as srcnroleid
		union all
		select
			'Principal Attorney',
			10
		union all
		select
			'Case Manager',
			10
	) v
	except
	select
		srcsdscrptn,
		srcnroleid
	from sma_mst_SubRoleCode;
go

-- [1.2] Create SubRole definitions that don't exist
-- sbrnTypeCode = SubRoleCode.srcnCodeId
insert into sma_MST_SubRole
	(
	sbrnRoleID,
	sbrsDscrptn,
	sbrnTypeCode
	)
	select
		v.srcnroleid,
		v.srcsdscrptn,
		v.srcntypecode
	from (
		-- Subrole: Paralegal
		select
			10 as srcnroleid,
			'Paralegal' as srcsdscrptn,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcnroleid = 10
					and srcsdscrptn = 'Paralegal'
			) as srcntypecode
		union all
		-- Subrole: Principal Attorney
		select
			10 as srcnroleid,
			'Principal Attorney' as srcsdscrptn,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcnroleid = 10
					and srcsdscrptn = 'Principal Attorney'
			) as srcntypecode
		union all
		-- Subrole: Case Manager
		select
			10 as srcnroleid,
			'Case Manager' as srcsdscrptn,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcnroleid = 10
					and srcsdscrptn = 'Case Manager'
			) as srcntypecode
	) v
	except
	select
		sbrnRoleID,
		sbrsDscrptn,
		sbrnTypeCode
	from sma_MST_SubRole
go

---------------------------------------------------
-- [2.0] Case Staff
---------------------------------------------------
alter table [sma_TRN_CaseStaff] disable trigger all
go

insert into sma_TRN_CaseStaff
	(
	[cssnCaseID],
	[cssnStaffID],
	[cssnRoleID],
	[csssComments],
	[cssdFromDate],
	[cssdToDate],
	[cssnRecUserID],
	[cssdDtCreated],
	[cssnModifyUserID],
	[cssdDtModified],
	[cssnLevelNo]
	)
	-- Insert for Principal Attorney
	select
		cas.casnCaseID,
		u.usrnContactID,
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = 'Principal Attorney'
		),
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from [sma_TRN_Cases] cas
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
	join [sma_MST_Users] u
		on u.saga_char = m.litify_pm__Principal_Attorney__c
	where m.litify_pm__Principal_Attorney__c is not null

	union all

	-- Insert for Paralegal
	select
		cas.casnCaseID,
		u.usrnContactID,
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = 'Paralegal'
		),
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from [sma_TRN_Cases] cas
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
	join [sma_MST_Users] u
		on u.saga_char = m.Paralegal__c
	where m.Paralegal__c is not null

	union all

	-- Insert for Case Manager
	select
		cas.casnCaseID,
		u.usrnContactID,
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = 'Case Manager'
		),
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from [sma_TRN_Cases] cas
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
	join [sma_MST_Users] u
		on u.saga_char = m.litify_pm__lit_Case_Manager__c
	where m.litify_pm__lit_Case_Manager__c is not null;
go

alter table [sma_TRN_CaseStaff] enable trigger all
go