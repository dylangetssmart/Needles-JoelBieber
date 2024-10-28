/*
- the first part of this script is used during initial conversion.
- it seeds implementation_users from needles..staff


- when the project phase is reached where we want to use the implementation database as our starting point,
the second part of the script is used instead
- it seeds implementation_users with records from the implementation database's sma_mst_user table,
and adds staff_code from needles..staff


*/




USE JoelBieberSA
GO

if exists (select * from sys.objects where name='implementation_users' and type='U')
begin
    drop table implementation_users
end
GO

CREATE TABLE implementation_users
(
    StaffCode varchar(50)
    ,SAloginID varchar(20)
    ,Prefix varchar(10)
    ,SAFirst varchar(50)
    ,SAMiddle varchar(5)
    ,SALast varchar(50)
    ,suffix varchar(15)
    ,Active varchar(1)
    ,visible varchar(1)
)
GO

-- INSERT INTO implementation_users (StaffCode, SAloginID, Prefix, SAFirst, SAMiddle, SALast, suffix, Active, Visible)

-- ds 2024-05-31 // Modified to insert data into the implementation_users table from the dbo.staff table
INSERT INTO implementation_users
(
    StaffCode
    ,SAloginID
    ,Prefix
    ,SAFirst
    ,SAMiddle
    ,SALast
    ,suffix
)
SELECT 
    staff_code                          as StaffCode
    ,staff_code                         as SAloginID
	,prefix                             as Prefix
	,dbo.get_firstword(s.full_name)     as SAFirst
    ,''                                 as SAMiddle
    ,dbo.get_lastword(s.full_name)      as SALast
    ,suffix                             as suffix
FROM [JoelBieberNeedles].[dbo].[staff] s
GO

-------------------------------------

--  2024-10-27 - create users from implementation database


--INSERT INTO implementation_users (
--	StaffCode
--	,SAloginID
--	,Prefix
--	,SAFirst
--	,SAMiddle
--	,SALast
--	,suffix
--	,Active
--	,Visible
--)
--SELECT '@PORTAL', '@PORTAL', '', 'Mary', '', 'McCabe', '', 'N', 'Y' UNION
--SELECT 'ABRIL', 'ABRIL', 'Ms.', 'Abril', '', 'Garcia', '', 'N', '' UNION

/* ################################################################################
Phase 2

1. drop table
2. seed with users from imp db

*/

--select * From implementation_users

--update implementation_users
--set Active = case when Active = 'N' then 0
--					when Active = 'Y' then 1
--					else 0 end,
--	visible = Case when active = 'Y' then 1
--					else 0 END


-- Drop the table if it exists
IF OBJECT_ID('implementation_users', 'U') IS NOT NULL
    DROP TABLE implementation_users;


-- Create the implementation_users table
CREATE TABLE implementation_users (
    StaffCode NVARCHAR(50),
    full_name NVARCHAR(100),
    SALoginID NVARCHAR(50),
    Prefix NVARCHAR(10),
    SAFirst NVARCHAR(50),
    SALast NVARCHAR(50),
    Suffix NVARCHAR(10),
    Active BIT,
    Visible BIT
);

-- Insert data into implementation_users
--INSERT INTO implementation_users (
--    StaffCode,
--    full_name,
--    SALoginID,
--    Prefix,
--    SAFirst,
--    SALast,
--    Suffix,
--    Active,
--    Visible
--)
--SELECT
--    COALESCE(s.staff_code, '') AS StaffCode,
--    COALESCE(s.full_name, smic.cinsFirstName + ' ' + smic.cinsLastName) AS full_name,
--    COALESCE(u.usrsLoginID, s.staff_code) AS SALoginID, -- Use staff_code if usrsLoginID is NULL
--    smic.cinsPrefix AS Prefix,
--    smic.cinsFirstName AS SAFirst,
--    smic.cinsLastName AS SALast,
--    smic.cinsSuffix AS Suffix,
--    u.usrbActiveState AS Active,
--    u.usrbIsShowInSystem AS Visible
--FROM 
--    [JoelBieber_Imp_2024-10-28]..sma_mst_users u
--FULL OUTER JOIN 
--    [JoelBieber_Imp_2024-10-28]..sma_MST_IndvContacts smic 
--    ON smic.cinnContactID = u.usrnContactID
--FULL OUTER JOIN 
--    JoelBieberNeedles..staff s 
--    ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName;

SELECT
	COALESCE(s.staff_code, '') AS StaffCode
	,s.full_name
	,u.usrsLoginID AS SALoginID
	,smic.cinsPrefix as Prefix
   ,smic.cinsFirstName AS SAFirst
   ,smic.cinsLastName AS SALast
   ,smic.cinsSuffix as Suffix
   ,u.usrbActiveState AS Active
   ,u.usrbIsShowInSystem as Visible
   --select * 
FROM [JoelBieber_Imp_2024-10-28]..sma_mst_users u
JOIN [JoelBieber_Imp_2024-10-28]..sma_MST_IndvContacts smic
	ON smic.cinnContactID = u.usrnContactID
LEFT JOIN
	JoelBieberNeedles..staff s ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName



SELECT * FROM JoelBieberNeedles..staff s WHERE s.full_name like '%ashley%'


