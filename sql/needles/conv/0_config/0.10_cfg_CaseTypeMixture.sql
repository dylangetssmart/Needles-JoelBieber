use JoelBieberSA_Needles
go

IF EXISTS (select * from sys.objects where name='CaseTypeMixture')
BEGIN
    DROP TABLE [dbo].[CaseTypeMixture]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CaseTypeMixture]
(
	[matcode] [nvarchar](255) NULL
	,[header] [nvarchar](255) NULL
	,[description] [nvarchar](255) NULL
	,[SmartAdvocate Case Type] [nvarchar](255) NULL
	,[SmartAdvocate Case Sub Type] [nvarchar](255) NULL
) ON [PRIMARY]


-- Seed CaseTypeMixture with values directly from matter for initial converison
INSERT INTO [dbo].[CaseTypeMixture]
(
	[matcode]
	,[header]
	,[description]
	,[SmartAdvocate Case Type]
	,[SmartAdvocate Case Sub Type]
)
	SELECT 
		matcode, 
		header, 
		description, 
		description AS [SmartAdvocate Case Type], 
		'' AS [SmartAdvocate Case Sub Type]
	FROM JoelBieberNeedles..matter;
GO

select * from casetypemixture