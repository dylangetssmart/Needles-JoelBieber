# Needles Init
The scripts in this folder are used to create indexed versions of specific Needles tables.

Script|Purpose
:---|:---
01_AddRowIDToCaseIntake.sql|Adds column `ROW_ID` to table `case_intake`, used during the intake migration
02_memo_case_notes.SQL|Creates `case_notes_indexed`
03_memo_case.SQL|Creates `cases_Indexed`
04_memo_checklist_dir.sql|Creates `checklist_dir_indexed`
05_memo_counsel.SQL|Creates `counsel_Indexed`
06_memo_insurance.SQL|Creates `insurance_Indexed`
07_memo_party.SQL|Creates `party_Indexed`
08_memo_value.SQL|Creates `value_Indexed`
