use JoelBieberSA_Needles
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

--SELECT smu.usrsLoginID, smu.source_id FROM JoelBieberSA_Needles..sma_MST_Users smu order by smu.usrsLoginID

--select s.staff_code, u.*
--	FROM [JoelBieberSA_Needles]..sma_mst_users u
--		JOIN [JoelBieberSA_Needles]..sma_MST_IndvContacts smic
--			ON smic.cinnContactID = u.usrnContactID
--		LEFT JOIN JoelBieberNeedles..staff s
--			ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName