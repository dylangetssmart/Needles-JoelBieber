race
language


-- from entity

---------------------------------------
-- Construct [sma_MST_IndvContacts]
---------------------------------------
INSERT INTO [sma_MST_IndvContacts]
(
	[cinsPrefix]
	,[cinsSuffix]
	,[cinsFirstName]
	,[cinsMiddleName]
	,[cinsLastName]
	,[cinsHomePhone]
	,[cinsWorkPhone]
	,[cinsSSNNo]
	,[cindBirthDate]
	,[cindDateOfDeath]
	,[cinnGender]
	,[cinsMobile]
	,[cinsComments]
	,[cinnContactCtg]
	,[cinnContactTypeID]
	,[cinnContactSubCtgID]
	,[cinnRecUserID]
	,[cindDtCreated]
	,[cinbStatus]	
	,[cinbPreventMailing]
	,[cinsNickName]
	,[cinsPrimaryLanguage]
    ,[cinsOtherLanguage]
	,[cinnRace]
	,[saga]					
)
SELECT										 
	left(N.[prefix],20)							as [cinsPrefix],
	left(N.[suffix],10)							as [cinsSuffix],
	convert(varchar(30),N.[first_name])			as [cinsFirstName],
	convert(varchar(30),N.[initial])			as [cinsMiddleName],
	convert(varchar(40),N.[last_long_name])		as [cinsLastName],
	left(N.[home_phone],20)						as [cinsHomePhone],
	left(N.[work_phone],20)						as [cinsWorkPhone],
	left(N.[ss_number],20)						as [cinsSSNNo],
	case
		when (N.[date_of_birth] not between '1900-01-01' and '2079-12-31') then getdate()
			else N.[date_of_birth]
		end										as [cindBirthDate],
	case
		when (N.[date_of_death] not between '1900-01-01' and '2079-12-31') then getdate()
			else N.[date_of_death]
		end										as [cindDateOfDeath],
	case
		when N.[sex]='M' then 1
		when N.[sex]='F' then 2
			else 0
		end										as [cinnGender],
	left(N.[car_phone],20)						as [cinsMobile],
	case
		when isnull(N.[fax_number],'') <> '' then 'FAX NUMBER: ' + N.[fax_number]
		else NULL
		end										as [cinsComments],
	1											as [cinnContactCtg],
	(
		select octnOrigContactTypeID
		from [sma_MST_OriginalContactTypes]
		where octsDscrptn='General' and octnContactCtgID=1
	)											as [cinnContactTypeID],
	case
		-- if names.deceased = "Y", then grab the contactSubCategoryID for "Deceased"
		when N.[deceased] = 'Y' then (
				select cscnContactSubCtgID
				from [sma_MST_ContactSubCategory]
				where cscsDscrptn='Deceased'
			)
		-- if incapacitated = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Incompetent"
		when exists (
			select *
			from [TestNeedles].[dbo].[party_Indexed] P
			where P.party_id=N.names_id and P.incapacitated='Y'
		) then (
			select cscnContactSubCtgID
			from [sma_MST_ContactSubCategory]
			where cscsDscrptn='Incompetent'
		)
		-- if minor = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Infant"
		-- otherwise, grab the contactSubCategoryID for "Adult"
		when exists (
			select *
			from [TestNeedles].[dbo].[party_Indexed] P
			where P.party_id=N.names_id and P.minor='Y'
		) then (
			select cscnContactSubCtgID
			from [sma_MST_ContactSubCategory]
			where cscsDscrptn='Infant'
			)
		else (
			select cscnContactSubCtgID
			from [sma_MST_ContactSubCategory]
			where cscsDscrptn='Adult'
		)
		end										as cinnContactSubCtgID,
	368											as cinnRecUserID,
	getdate()									as cindDtCreated,
	1											as [cinbStatus],			-- Hardcode Status as ACTIVE 
	0											as [cinbPreventMailing], 
	convert(varchar(15),aka_full)				as [cinsNickName],
	NULL										as [cinsPrimaryLanguage],
	null										as [cinsOtherLanguage],
	case
		when isnull(n.race,'') <> '' then
			(
				select raceid
				from sma_mst_ContactRace
				where RaceDesc = r.Race_Name
			) 
		else NULL
		end										as cinnrace,
	N.[names_id]								as saga  
FROM [TestNeedles].[dbo].[names] N
LEFT JOIN [TestNeedles].[dbo].[Race] r on r.race_ID = n.race
WHERE N.[person]='Y'


---------------------------------------
-- Construct [sma_MST_OrgContacts]
---------------------------------------
INSERT INTO [sma_MST_OrgContacts] (
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga]					
	)
SELECT 
    N.[last_long_name]							as [consName],
    N.[work_phone]								as [consWorkPhone],
    case 
		when isnull(N.[aka_full],'') <> '' and  isnull(N.[email],'') = '' then (
			'AKA: ' +  N.[aka_full]
		)
		when isnull(N.[aka_full],'') = '' and  isnull(N.[email],'') <> '' then (
			'EMAIL: ' + N.[email]
		)
		when isnull(N.[aka_full],'') <> '' and  isnull(N.[email],'') <> '' then (
			'AKA: ' +  N.[aka_full] + ' EMAIL: ' + N.[email]
		)
    end											as [consComments],
    2											as [connContactCtg],
    (
		select octnOrigContactTypeID
		FROM .[sma_MST_OriginalContactTypes]
		where octsDscrptn='General' and octnContactCtgID=2
	)											as [connContactTypeID],
    368											as [connRecUserID],
    getdate()									as [condDtCreated],
    1											as [conbStatus],	-- Hardcode Status as ACTIVE
    N.[names_id]								as [saga]			-- remember the [names].[names_id] number
FROM [TestNeedles].[dbo].[names] N
WHERE N.[person] <> 'Y'