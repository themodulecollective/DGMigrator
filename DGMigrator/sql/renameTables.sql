IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[stagingDistributionGroupMember]') AND type in (N'U'))
    EXEC sp_rename N'[dbo].[stagingDistributionGroupMember]','stagingDistributionGroupRole';

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[historyDistributionGroupMember]') AND type in (N'U'))
    EXEC sp_rename N'[dbo].[historyDistributionGroupMember]','historyDistributionGroupRole';

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qSDistributionGroupMember]') AND type in (N'U'))
    EXEC sp_rename N'[dbo].[qSDistributionGroupMember]','qSDistributionGroupRole';

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[qIDistributionGroupMember]') AND type in (N'U'))
    EXEC sp_rename N'[dbo].[qIDistributionGroupMember]','qIDistributionGroupRole';

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[actionsDistributionGroupMember]') AND type in (N'U'))
    EXEC sp_rename N'[dbo].[actionsDistributionGroupMember]','actionsDistributionGroupRole';
