
update cas 
set casscasename = aci.[name]
--select casncaseid, aci.LastName, aci.FirstName, aci.[name]
from sma_trn_Cases cas
JOIN sma_trn_Plaintiff p on p.plnncaseid = cas.casncaseid and p.plnbIsPrimary = 1
join sma_MST_AllContactInfo aci on aci.ContactId = p.plnnContactID and p.plnnContactCtg = aci.ContactCtg
where isnull(casscasename,'') = ''