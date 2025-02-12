

update cs
set cssnstaffid = u.usrnContactID
--select cs.cssnstaffid, u.*
from sma_trn_Casestaff  cs
JOIN  sma_trn_Cases cas on cas.casnCaseID = cs.cssnCaseID
JOIN sma_mst_users u on u.usrnUserID = cs.cssnStaffID
where cas.source_db = 'needles'


