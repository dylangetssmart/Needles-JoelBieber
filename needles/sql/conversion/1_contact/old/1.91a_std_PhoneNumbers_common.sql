/* ###################################################################################
description: Update contact phone numbers
steps:
	- [sma_MST_ContactNoType]
usage_instructions:
	-
dependencies:
	- 
notes:
	-
######################################################################################
*/

USE [JohnSalazar_SA]
GO

-- 
INSERT INTO sma_MST_ContactNoType
(
	ctysDscrptn
	,ctynContactCategoryID
	,ctysDefaultTexting
)
SELECT
	'Work Phone'
	,1
	,0
UNION
SELECT
	'Work Fax'
	,1
	,0
UNION
SELECT
	'Cell Phone'
	,1
	,0
EXCEPT
SELECT
	ctysDscrptn
	,ctynContactCategoryID
	,ctysDefaultTexting
FROM sma_MST_ContactNoType 

--
IF OBJECT_ID (N'dbo.FormatPhone', N'FN') IS NOT NULL
    DROP FUNCTION FormatPhone;
GO
CREATE FUNCTION dbo.FormatPhone(@phone varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN
    if len(@phone)=10 and ISNUMERIC(@phone)=1 
    begin
	   return '(' + Substring(@phone,1,3) + ') ' + Substring(@phone,4,3) + '-' + Substring(@phone,7,4) ---> this is good for perecman
    end
    return @phone;
END;
GO
