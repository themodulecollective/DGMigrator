IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qIDistributionGroupRole]') AND type in (N'U'))
DROP TABLE [dbo].[qIDistributionGroupRole]
;
IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qIContact]') AND type in (N'U'))
DROP TABLE [dbo].[qIContact]
;
IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qIDistributionGroup]') AND type in (N'U'))
DROP TABLE [dbo].[qIDistributionGroup]
;
IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qSDistributionGroupRole]') AND type in (N'U'))
DROP TABLE [dbo].[qSDistributionGroupRole]
;
IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qSContact]') AND type in (N'U'))
DROP TABLE [dbo].[qSContact]
;
IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qSDistributionGroup]') AND type in (N'U'))
DROP TABLE [dbo].[qSDistributionGroup]
;
