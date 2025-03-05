/*
convert insurance.limits to ic.comments
*/

-- how many insurance records are in SA?
SELECT count(*) FROM sma_TRN_InsuranceCoverage stic where saga is not null
-- 39885

-- how many needles insurance records have limits?
SELECT count(*) FROM JoelBieberNeedles..insurance i 
where ISNULL(i.limits,'')<>''
-- 36426

SELECT
-- count(*)
stic.incsComments, i.insurance_id, i.limits
FROM sma_TRN_InsuranceCoverage stic
join JoelBieberNeedles..insurance i
on i.insurance_id = stic.saga
where ISNULL(i.limits,'') <>''
and isnull(stic.incsComments,'') = ''
-- 28635

UPDATE ins
set ins.incsComments = i.limits
from sma_TRN_InsuranceCoverage ins
join JoelBieberNeedles..insurance i
on ins.saga = i.insurance_id
where ISNULL(i.limits,'') <> ''
and isnull(ins.incsComments,'') = ''