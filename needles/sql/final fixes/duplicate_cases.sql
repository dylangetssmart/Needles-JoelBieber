use JoelBieberSA_Needles
go

----------------------------------------------------------------------------------------------------------------------------------
-- duplicate cases

-- are there dupes?
SELECT cassCaseNumber, COUNT(*) AS duplicate_count
FROM sma_trn_cases
GROUP BY cassCaseNumber
HAVING COUNT(*) > 1;

SELECT * FROM sma_TRN_Notes n
join sma_TRN_Cases cas
on n.notnCaseID = cas.casnCaseID
where cas.cassCaseNumber in (

'214873')
--'214874')
order by n.notdDtCreated

SELECT * FROM sma_TRN_Cases cas where cas.cassCaseNumber in (

'214873',
'214874')

/*
cassCaseNumber	duplicate_count
214873	2
214874	2
216059	2
216101	2
216313	2
216365	2
217016	2
217593	2
218055	2
218100	2
218550	2
219267	2
219374	2
219411	2
219424	2
219496	2
219658	2
219750	2
219756	2
220261	2
220588	2
220647	2
220960	2
222175	2
222727	2
222728	2
223036	2
223909	2
225142	2
225486	2
225519	2
225597	2
226556	2
227554	2
228154	2
228253	2
229519	2
229747	2
229748	2
230032	2
230168	2
230463	2
*/

-- why?
select * from sma_TRN_Cases where cassCaseNumber = '214873'
select * from sma_MST_CaseType smct  where smct.cstnCaseTypeID in (1782,1701,407,1772) order by smct.cstsType
select * from sma_MST_CaseGroup smcg where smcg.cgpnCaseGroupID in (143,
153,
175,
176)

-- 407
-- 1701

-- there are duplicate case types
SELECT cstsType, COUNT(*) AS duplicate_count
FROM sma_MST_CaseType
GROUP by cstsType
HAVING COUNT(*) > 1;

-----------------------------------------------------------------------------------------------------------------------------------


/*
"delete" cases belonging to case type 407, 1701
set cassCaseNumber = null

*/

use SA
go

-- inactive case types (cstbActive = 0)
select * from sma_MST_CaseType smct  where smct.cstnCaseTypeID in (1701,407) order by smct.cstsType

-- verify applicable cases
-- expected 42
SELECT * FROM sma_TRN_Cases stc where stc.casnOrgCaseTypeID in (1701,407) 
SELECT distinct casnOrgCaseTypeID FROM sma_TRN_Cases stc where stc.casnOrgCaseTypeID in (1701,407) 

-- set cassCaseNumber = null
UPDATE sma_TRN_Cases
SET cassCaseNumber = NULL
WHERE casnOrgCaseTypeID IN (1701, 407);
