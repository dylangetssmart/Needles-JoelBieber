/*
- update source_id on both sma_mst_users and sma_mst_indvcontacts

because users were created manually in the implementation system,
we need to update both the user and indvContact records with a reference to the associated needles user

1. update sma_MST_Users.source_id
2. update sma_MST_IndvContacts.source_id from users


*/

--SELECT u.usrsLoginID, u.source_id, indv.cinsFirstName, indv.source_id, indv.cinnContactID
--FROM sma_MST_Users u
--join sma_MST_IndvContacts indv
--on u.usrnContactID = indv.cinnContactID


use JoelBieberSA_Needles
go


-- saga (INT)
-- Check if the column 'saga' exists and if it's not of type INT, change its type
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_MST_Users] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [source_ref] VARCHAR(MAX) null;
end
go

update sma_mst_users
set source_id = (
		select top 1
			s.staff_code
		from JoelBieberNeedles..staff s
		join [JoelBieberSA_Needles]..sma_MST_IndvContacts indv
			on s.full_name = indv.cinsFirstName + ' ' + indv.cinsLastName
		where indv.cinnContactID = sma_MST_Users.usrnContactID
	),
	source_db = 'needles';

--UPDATE sma_MST_IndvContacts
--set source_id = (
--	select top 1 
--	source_id
--	from sma_MST_Users u
--	where u.usrnContactID = sma_MST_IndvContacts.cinnContactID
--),
--source_db = 'needles'


-- Step 1: Create a temporary table for mapping contact IDs to source IDs
IF OBJECT_ID('tempdb..#ContactSourceMap') IS NOT NULL
    DROP TABLE #ContactSourceMap;

SELECT 
    indv.cinnContactID AS ContactID,
    u.source_id AS SourceID
INTO #ContactSourceMap
FROM sma_MST_Users u
JOIN sma_MST_IndvContacts indv
    ON u.usrnContactID = indv.cinnContactID;

-- Step 2: Create an index on the temporary table for faster joins
CREATE INDEX idx_ContactID ON #ContactSourceMap(ContactID);

-- Step 3: Update sma_MST_IndvContacts using the temporary table
UPDATE indv
SET indv.source_id = map.SourceID,
    indv.source_db = 'needles'
FROM sma_MST_IndvContacts indv
JOIN #ContactSourceMap map
    ON indv.cinnContactID = map.ContactID;

-- Step 4: Clean up the temporary table
DROP TABLE #ContactSourceMap;

--SELECT smu.usrsLoginID, smu.source_id FROM JoelBieberSA_Needles..sma_MST_Users smu order by smu.usrsLoginID

--select s.staff_code, u.*
--	FROM [JoelBieberSA_Needles]..sma_mst_users u
--		JOIN [JoelBieberSA_Needles]..sma_MST_IndvContacts smic
--			ON smic.cinnContactID = u.usrnContactID
--		LEFT JOIN JoelBieberNeedles..staff s
--			ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName