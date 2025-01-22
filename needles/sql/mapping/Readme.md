# Needles Mapping
The scripts in this folder are used to generate an Excel mapping spreadsheet that the implementation team will help the client populate.

Script|Purpose
:---|:---
01_CreateCustomFieldUsage.sql|Creates table `CustomFieldUsage` with all columns from the Needles user tables
02_custom_field_usage.sql|Selects data from `CustomFieldUsage` and appends sample data
03_class.sql|
04_matter.sql|Lists fields from `matter`, which translate to Case Types
05_mini_dir.sql|Lists dropdown values 
06_party_role.sql|Lists Roles from `party`
07_value_code.sql|Lists Value Codes, [see](https://smartadvocate.atlassian.net/wiki/spaces/Conversion/pages/edit-v2/2432303109#Value-%26-Value-Codes)
