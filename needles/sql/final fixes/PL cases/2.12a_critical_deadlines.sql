/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [JoelBieberSA_Needles]
go

/*
alter table [sma_TRN_CriticalDeadlines] disable trigger all
delete [sma_TRN_CriticalDeadlines]
DBCC CHECKIDENT ('[sma_TRN_CriticalDeadlines]', RESEED, 0);
alter table [sma_TRN_CriticalDeadlines] enable trigger all


(select cdtnCriticalTypeID FROM [sma_MST_CriticalDeadlineTypes] where cdtbActive = 1 and cdtsDscrptn='date due') 
*/


/*
Function to strip white spaces surrounding case_dates
*/
if OBJECT_ID(N'dbo.GMACaseDate', N'FN') is not null
	drop function GMACaseDate;
go

create function dbo.GMACaseDate (@str VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin
	--set @str=replace(@str,'1.','');
	--set @str=replace(@str,'2.','');
	--set @str=replace(@str,'3.','');
	--set @str=replace(@str,'4.','');
	--set @str=replace(@str,'5.','');
	--set @str=replace(@str,'6.','');
	--set @str=replace(@str,'7.','');
	--set @str=replace(@str,'8.','');
	--set @str=replace(@str,'9.','');
	return RTRIM(LTRIM(@str));
end;
go

/* CRITICAL DEADLINE TYPES ##################################
Insert new Critical Deadline Types that don't yet exist
from matter.case_date_1 through case_date_10
*/

-- Disable triggers
alter table [sma_TRN_CriticalDeadlines] disable trigger all
---

insert into [sma_MST_CriticalDeadlineTypes]
	(
	cdtsDscrptn, cdtbActive
	)
	(
	select distinct
		dbo.GMACaseDate(M.case_date_1),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_1), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_2),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_2), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_3),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_3), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_4),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_4), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_5),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_5), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_6),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_6), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_7),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_7), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_8),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_8), '') <> ''
		and m.matcode = 'pl'

	union

	select distinct
		dbo.GMACaseDate(M.case_date_9),
		1
	from JoelBieberNeedles.[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_9), '') <> ''
		and m.matcode = 'pl'
	)

	except

	select
		cdtsDscrptn,
		cdtbActive
	from [sma_MST_CriticalDeadlineTypes]
	where cdtbActive = 1


/*
Create a helper table
*/
if exists (
		select
			*
		from sys.objects
		where name = 'criticalDeadline_Helper'
			and TYPE = 'U'
	)
begin
	drop table criticalDeadline_Helper
end
go

create table criticalDeadline_Helper (
	TableIndex		INT identity (1, 1) not null,
	casnCaseID		INT,
	UniqueContactId BIGINT
	constraint IOC_Clustered_Index_criticalDeadline_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

insert into criticalDeadline_Helper
	(
	casnCaseID, UniqueContactId
	)
	select
		plnnCaseID,
		UniqueContactId
	from sma_TRN_Plaintiff
	join sma_MST_AllContactInfo
		on ContactCtg = plnnContactCtg
			and ContactId = plnnContactID
	join sma_TRN_Cases cas
	on cas.casnCaseID = sma_TRN_Plaintiff.plnnCaseID
	where plnbIsPrimary = 1
	and cas.source_ref = 'pl'
go

dbcc dbreindex ('criticalDeadline_Helper', ' ', 90) with no_infomsgs
go

select * FROM criticalDeadline_Helper MAP

/*
Create Critical Deadline records
Loop through case_date_1 to case_date_10
*/

declare @i INT = 1
declare @sql NVARCHAR(MAX)
declare @caseDate NVARCHAR(20)

while @i <= 9
begin
set @caseDate = 'case_date_' + CAST(@i as NVARCHAR(2))

set @sql = '
    INSERT INTO [sma_TRN_CriticalDeadlines] (
        [crdnCaseID]
        ,[crdnCriticalDeadlineTypeID]
        ,[crddDueDate]
        ,[crdsRequestFrom]
        ,[ResponderUID]
    )
    SELECT 
        CAS.casnCaseID as [crdnCaseID]
        ,(
            SELECT cdtnCriticalTypeID
            FROM [sma_MST_CriticalDeadlineTypes]
            WHERE cdtbActive = 1
                AND cdtsDscrptn = dbo.GMACaseDate(M.' + @caseDate + ')
        ) as [crdnCriticalDeadlineTypeID]
        ,CASE 
            WHEN C.' + @caseDate + ' BETWEEN ''1900-01-01'' AND ''2079-06-01''
                THEN C.' + @caseDate + '
            ELSE NULL
        END as [crddDueDate]
        ,(
            SELECT CONVERT(VARCHAR, MAP.UniqueContactId) + '';''
            FROM criticalDeadline_Helper MAP
            WHERE MAP.casnCaseID = CAS.casnCaseID
        ) as [crdsRequestFrom]
        ,(
            SELECT CONVERT(VARCHAR, MAP.UniqueContactId)
            FROM criticalDeadline_Helper MAP
            WHERE MAP.casnCaseID = CAS.casnCaseID
        ) as [ResponderUID]
    FROM JoelBieberNeedles.[dbo].[cases] C
    JOIN JoelBieberNeedles.[dbo].[matter] M
        ON M.matcode = C.matcode
    JOIN [sma_TRN_cases] CAS
        ON CAS.cassCaseNumber = convert(varchar, casenum)
    WHERE ISNULL(C.' + @caseDate + ', '''') <> ''''
	and cas.source_ref = ''PL''
    '

exec sp_executesql @sql

set @i = @i + 1
end

-----
alter table [sma_TRN_CriticalDeadlines] enable trigger all
go

-----

---(Appendix)---
alter table sma_TRN_CriticalDeadlines disable trigger all
go

update [sma_TRN_CriticalDeadlines]
set crddCompliedDate = GETDATE()
where crddDueDate < GETDATE()
go

alter table sma_TRN_CriticalDeadlines enable trigger all
go