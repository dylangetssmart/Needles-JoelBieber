/*
delete all cases other than the applicable PL cases to convert


Case Type = "Product Liability - General"
1787

*/

SELECT * FROM JoelBieberNeedles..cases c where c.matcode = 'PL'
		and (
		c.date_of_incident > '2010-12-31'
		or (c.date_of_incident is null
		and c.date_opened > '2010-12-31')
		)

select * from sma_MST_CaseType where cstncasetypeid = 1787

select * from [sma_MST_SubRoleCode]
select * from [sma_MST_SubRole] where sbrncasetypeid = 1787

SELECT * FROM casetypemixture


INSERT INTO casetypemixture (matcode, header, description, [SmartAdvocate Case Type], [SmartAdvocate Case Sub Type])  
VALUES ('PL', 'PROD/LIA', 'PRODUCTS LIABILITY CASE', 'Product Liability - General', '');




PL	PROD/LIA	PRODUCTS LIABILITY CASE	Y	Treatment in Progress	Evaluation & Summary	Negotiation & Settlement	Litigation	Final Accounting	Litigation	Hearing	Filed Suit	Effect Service	Trial	Demand Sent	Y	Y	Y	Y	Y	N												N		N		Y	Witness	N		N		N		N		N		N		Y				0	Y	Alt Case Num	Alt Case 2	Date of Incident	N	Status	NULL	0	0	N	NULL	N	Our Client	Maximum	Minimum											N	N	NULL	NULL	NULL	DOI:	56



select * from joelbiebersa_needles..partyroles


where cas.casnOrgCaseTypeID = 1787
and cas.casnOrgCaseTypeID = 1787

SELECT * FROM sma_trn_cases cas where cas.casnOrgCaseTypeID = 1787

join JoelBieberNeedles..cases_Indexed c
on ii.case_num = c.casenum



where cas.source_ref = 'PL'

		
		select * from sma_trn_cases cas
		join joelbieberneedles..cases_indexed c
		on c.casenum = cas.saga
		where c.matcode = 'PL'

		select cas.*
FROM sma_trn_cases cas
JOIN joelbieberneedles..cases_indexed c
    ON c.casenum = cas.saga
WHERE c.matcode = 'PL';


		DELETE cas
FROM sma_trn_cases cas
JOIN joelbieberneedles..cases_indexed c
    ON c.casenum = cas.saga
WHERE c.matcode = 'PL';



select * from sma_trn_cases cas where cas.source_ref = 'PL'


--213898
--216148
--216299
--216655
--217839
--218122
--219843
--227038
--229786

SELECT * FROM joelbieberneedles..user_case_data where casenum in ('213898',
'216148',
'216299',
'216655',
'217839',
'218122',
'219843',
'227038',
'229786')


SELECT * FROM joelbieberneedles..user_party_data where case_id in ('213898',
'216148',
'216299',
'216655',
'217839',
'218122',
'219843',
'227038',
'229786')

SELECT * FROM joelbieberneedles..calendar where casenum in ('213898',
'216148',
'216299',
'216655',
'217839',
'218122',
'219843',
'227038',
'229786')