/*
for custom fields that are of field_type = name, contacts will have been created already. just need to update contact type

*/

SELECT * FROM JoelBieberSA_Needles..[sma_MST_OriginalContactTypes]

UPDATE sma_MST_IndvContacts
set cinnContactTypeID = 1
from sma_MST_IndvContacts smic