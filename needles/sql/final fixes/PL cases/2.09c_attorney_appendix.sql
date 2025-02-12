/* ###################################################################################
description: Update contact types for attorneys
steps:
	- Update individual contact type > [sma_MST_IndvContacts]
	
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

use [SA]
GO


---(Appendix)---
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
		AND octnContactCtgID = 1
)
FROM (
	SELECT
		I.cinnContactID AS ID
	FROM JoelBieberNeedles.[dbo].[counsel] C
	join JoelBieberNeedles..cases_Indexed cases
	on cases.casenum = c.case_num
	JOIN JoelBieberNeedles.[dbo].[names] L
		ON C.counsel_id = L.names_id
	JOIN [dbo].[sma_MST_IndvContacts] I
		ON saga = L.names_id
	WHERE L.person = 'Y'
	and cases.matcode = 'PL'
	
) A
WHERE cinnContactID = A.ID
GO
