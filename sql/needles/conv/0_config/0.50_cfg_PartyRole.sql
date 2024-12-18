USE JoelBieberSA_Needles
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * From sys.tables where name = 'PartyRoles' and type = 'U')
begin 
	drop table partyRoles
end

CREATE TABLE [dbo].[PartyRoles]
(
	[Needles Roles] [nvarchar](255) NULL
	,[SA Roles] [nvarchar](255) NULL
	,[SA Party] [nvarchar](255) NULL
) ON [PRIMARY]

GO

-- ds 2024-06-24 // From live mapping
INSERT INTO [dbo].[PartyRoles]
(
	[Needles Roles]
	,[SA Roles]
	,[SA Party]
)
--SELECT 'Witness', '(P)-Witness', 'Plaintiff' UNION
--SELECT 'Employer', '(P)-Employer', 'Plaintiff' UNION
--SELECT 'Beneficiary', '(P)-Beneficiary', 'Plaintiff' UNION
--SELECT 'Plntf-Deceased', '(P)-Decedent', 'Plaintiff' UNION
--SELECT 'Potential Guard.', '(P)-Guardian', 'Plaintiff' UNION
--SELECT 'Defendant', '(D)-Defendant', 'Defendant' UNION
--SELECT 'Plntf-Minor', '(P)-Minor', 'Plaintiff' UNION
--SELECT 'Potential Adm''r', '(P)-Administrator', 'Plaintiff' UNION
--SELECT 'Plaintiff', '(P)-Plaintiff', 'Plaintiff' UNION
--SELECT 'Parent/Guardian', '(P)-Parent/Guardian', 'Plaintiff'
--GO

SELECT 'ADMINISTRATIX', '(P)-ADMINISTRATIX', 'PLAINTIFF' UNION
SELECT 'Administratrix', '(P)-ADMINISTRATIX', 'PLAINTIFF' UNION
SELECT 'Beneficiary', '(P)-BENEFICIARY', 'PLAINTIFF' UNION
SELECT 'CLAIMANT', '(P)-PLAINTIFF', 'PLAINTIFF' UNION
SELECT 'Co Guardian', '(P)-Co Guardian', 'PLAINTIFF' UNION
SELECT 'DECEASED', '(P)-DECEASED', 'PLAINTIFF' UNION
SELECT 'Decedent', '(P)-DECENDENT', 'PLAINTIFF' UNION
SELECT 'DECENDENT', '(P)-DECENDENT', 'PLAINTIFF' UNION
SELECT 'DEFENDANT', '(D)-DEFENDANT', 'DEFENDANT' UNION
SELECT 'DRIVER OF PL VEH', '(P)-DRIVER', 'PLAINTIFF' UNION
SELECT 'EMPLOYEE', '(P)-EMPLOYEE', 'PLAINTIFF' UNION
SELECT 'EMPLOYER', '(P)-EMPLOYER', 'PLAINTIFF' UNION
SELECT 'ESTATE', '(P)-ESTATE', 'PLAINTIFF' UNION
SELECT 'ESTATE OF', '(P)-ESTATE', 'PLAINTIFF' UNION
SELECT 'Expert Witness', '(P)-EXPERT WITNESS', 'PLAINTIFF' UNION
SELECT 'GUARDIAN', '(P)-GUARDIAN', 'PLAINTIFF' UNION
SELECT 'MINOR', '(P)-MINOR', 'PLAINTIFF' UNION
SELECT 'MINOR CHILD', '(P)-MINOR CHILD', 'PLAINTIFF' UNION
SELECT 'No Fault Party', '(P)-NO FAULT PARTY', 'PLAINTIFF' UNION
SELECT 'NO-FAULT PARTY', '(P)-NO FAULT PARTY', 'PLAINTIFF' UNION
SELECT 'OWNER DEF VEH', '(D)-OWNER', 'DEFENDANT' UNION
SELECT 'OWNER NFP VEH', '(P)-OWNER', 'PLAINTIFF' UNION
SELECT 'Owner of NFP Veh', 'Owner', 'PLAINTIFF' UNION
SELECT 'Owner of Pl Veh', '(P)-OWNER', 'PLAINTIFF' UNION
SELECT 'OWNER PL VEH', '(P)-OWNER', 'PLAINTIFF' UNION
SELECT 'PARENT', '(P)-PARENT', 'PLAINTIFF' UNION
SELECT 'Passenger Def Vh', '(D)-PASSENGER', 'DEFENDANT' UNION
SELECT 'Passenger Df Veh', '(D)-Passenger', 'Defendant' UNION
SELECT 'PASSENGER PL VEH', '(P)-PASSENGER', 'PLAINTIFF' UNION
SELECT 'PLAINTIFF', '(P)-PLAINTIFF', 'PLAINTIFF' UNION
SELECT 'POA', '(P)-POWER OF ATTORNEY', 'PLAINTIFF' UNION
SELECT 'SPOUSE', '(P)-SPOUSE', 'PLAINTIFF' UNION
SELECT 'THIRD PARTY DEF', '(D)-THIRD PARTY DEFENDANT', 'DEFENDANT' UNION
SELECT 'TREATING PHYS', '(P)-MEDICAL PROVIDER', 'PLAINTIFF' UNION
SELECT 'Treating Phys.', '(P)-MEDICAL PROVIDER', 'PLAINTIFF' UNION
SELECT 'WITNESS', '(P)-WITNESS', 'PLAINTFF'



-- add non-typical roles to Other Contacts (sma_MST_OtherCasesContact)
-- Drop the sma_MST_OtherCasesContact table if it exists
--IF EXISTS (SELECT * FROM sys.tables WHERE name = 'sma_MST_OtherCasesContact' AND type = 'U')
--BEGIN 
--    DROP TABLE [dbo].[sma_MST_OtherCasesContact]
--END
--GO

---- Create the sma_MST_OtherCasesContact table
--CREATE TABLE [dbo].[sma_MST_OtherCasesContact](
--    [OtherCasesContactPKID] [int] IDENTITY(1,1) NOT NULL,
--    [OtherCasesID] [int] NULL,
--    [OtherCasesContactID] [int] NULL,
--    [OtherCasesContactCtgID] [int] NULL,
--    [OtherCaseContactAddressID] [int] NULL,
--    [OtherCasesContactRole] [varchar](500) NULL,
--    [OtherCasesCreatedUserID] [int] NULL,
--    [OtherCasesContactCreatedDt] [smalldatetime] NULL,
--    [OtherCasesModifyUserID] [int] NULL,
--    [OtherCasesContactModifieddt] [smalldatetime] NULL,
-- CONSTRAINT [PK_sma_MST_OtherCasesContact] PRIMARY KEY CLUSTERED 
--(
--    [OtherCasesContactPKID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
--) ON [PRIMARY]

---- Create
----INSERT [JoelBieberNeedles].[dbo].[sma_MST_OtherCasesContact](
----	[OtherCasesContactRole]
----)
----SELECT 'Personal Representative' UNION
----SELECT 'Seller' UNION
----SELECT 'Voter' UNION
----SELECT 'Payee' UNION
----SELECT 'Family Member' UNION
----SELECT 'Buyer'
