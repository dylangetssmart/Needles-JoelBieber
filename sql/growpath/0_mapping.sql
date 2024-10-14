-- Case Types
SELECT
	ct.name AS CaseType
	,count(*) as count
FROM case_type ct
LEFT JOIN matter m ON ct.id = m.case_type_id
group BY ct.name
order BY ct.name ASC

-- Party Roles
SELECT
    it.name as InvolvementType
	,it.meaning AS Meaning
	,it.valid_involvee_kind AS ValidInvolveeKind
	,CASE it.active
		when 'f' then 'False'
		when 't' then 'True'
	end AS Active
	,CASE mi.adversarial
		when 'f' then 'False'
		when 't' then 'True'
	end AS Adversarial
    ,COUNT(*) AS count
FROM matter_involvement mi
JOIN matter_involvement_involvement_type mit
    ON mit.matter_involvement_id = mi.id
JOIN involvement_type it
    ON it.id = mit.involvement_type_id
JOIN entity e
    ON e.id = mi.involvee_id
GROUP BY it.name, it.meaning, mi.adversarial, it.valid_involvee_kind, it.active
ORDER BY InvolvementType;


-- Insurance Types
SELECT
	lpic.litify_pm__Insurance_Type__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Insurance__c lpic
GROUP BY lpic.litify_pm__Insurance_Type__c
ORDER BY RoleCount DESC;


-- Referral Sources
SELECT
	lpsc.litify_tso_Source_Type_Name__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Source__c lpsc
GROUP BY lpsc.litify_tso_Source_Type_Name__c
ORDER BY RoleCount DESC;


-- Damage Types
SELECT
	lpdc.litify_pm__Type__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Damage__c lpdc
GROUP BY lpdc.litify_pm__Type__c
ORDER BY RoleCount DESC;


-- Damage Types
SELECT
	lprc.litify_pm__Request_Type__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Request__c lprc
GROUP BY lprc.litify_pm__Request_Type__c
ORDER BY RoleCount DESC;