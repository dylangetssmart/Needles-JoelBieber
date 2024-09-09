-- USE JoelBieberNeedles

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