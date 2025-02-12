/* ###################################################################################
description: Insert defendants
steps:
	- Insert case values > [sma_trn_CaseValue]
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

USE [JoelBieberSA_Needles]
GO

ALTER TABLE sma_trn_Casevalue DISABLE TRIGGER ALL
GO

INSERT INTO sma_trn_Casevalue
(
	csvncaseid
	,csvnValueID
	,csvnValue
	,csvsComments
	,csvdFromDate
	,csvdToDate
	,csvnRecUserID
	,csvdDtCreated
	,csvnMinSettlementValue
	,csvnExpectedResolutionDate
	,csvnMaxSettlementValue
)
SELECT DISTINCT
	cas.casncaseid			as csvncaseid,
	NULL					as csvnValueID,
	NULL					as csvnValue,
	''						as csvsComments, 
	getdate()				as  csvdFromDate,
	null					as csvdToDate,
	368						as csvnRecUserID,
	getdate()				as csvdDtCreated,
	minimum_amount			as csvnMinSettlementValue,
	null					as csvnExpectedResolutionDate,
	null					as csvnMaxSettlementValue
FROM JoelBieberNeedles..insurance_Indexed ii
JOIN sma_trn_Cases cas
	on cas.cassCaseNumber = convert(varchar,ii.case_num)
join JoelBieberNeedles..cases_Indexed c
on ii.case_num = c.casenum
WHERE isnull(minimum_amount,0) <> 0
and cas.source_ref = 'PL'


ALTER TABLE sma_trn_Casevalue ENABLE TRIGGER ALL