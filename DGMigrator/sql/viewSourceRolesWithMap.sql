CREATE VIEW [dbo].[SourceRolesWithMap]
AS
    SELECT SourceRole.SourceOrganization ,SourceRole.ExternalDirectoryObjectID ,SourceRole.Role ,SourceRole.TargetGroupExternalDirectoryObjectID ,SourceRole.TargetGroupDisplayName ,SourceRole.TargetGroupPrimarySmtpAddress
        ,GroupMap.TExternalDirectoryObjectID AS DestinationGroupExternalDirectoryObjectID ,RoleHolderMap.TExternalDirectoryObjectID AS DestinationRoleHolderExternalDirectoryObjectID ,SourceRole.RecipientTypeDetails
        ,SourceRole.DisplayName ,SourceRole.PrimarySmtpAddress ,SourceRole.Alias ,SourceRole.Guid ,SourceRole.ExchangeGuid ,SourceRole.TargetGroupGUID
        ,RoleHolderMap.TPrimarySmtpAddress AS DestinationRoleHolderPrimarySMTPAddress ,RoleHolderMap.TRecipientTypeDetails AS DestinationRoleHolderRecipientTypeDetails
        ,GroupMap.TPrimarySmtpAddress AS DestinationGroupPrimarySmtpAddress ,GroupMap.TRecipientTypeDetails AS DestinationGroupRecipientTypeDetails ,RoleHolderMap.TAlias AS DestinationRoleHolderAlias
    FROM dbo.stagingDistributionGroupRole AS SourceRole INNER JOIN
        dbo.recipientMap AS RoleHolderMap ON SourceRole.ExternalDirectoryObjectID = RoleHolderMap.ExternalDirectoryObjectID AND SourceRole.SourceOrganization IN
                      (SELECT Name
            FROM dbo.configurationOrganization
            WHERE   (MigrationRole = 'Source')) INNER JOIN
        dbo.recipientMap AS GroupMap ON SourceRole.TargetGroupExternalDirectoryObjectID = GroupMap.ExternalDirectoryObjectID
;
