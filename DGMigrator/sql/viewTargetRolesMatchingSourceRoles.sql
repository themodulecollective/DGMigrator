CREATE VIEW [dbo].[TargetRolesMatchingSourceRoles]
AS
    SELECT TR.SourceOrganization ,TR.ExternalDirectoryObjectID ,TR.PrimarySmtpAddress ,TR.RecipientTypeDetails ,TR.Role ,TR.TargetGroupExternalDirectoryObjectID ,TR.TargetGroupPrimarySmtpAddress
		,GMap.ExternalDirectoryObjectID AS SourceGroupExternalDirectoryObjectID ,HMap.ExternalDirectoryObjectID AS SourceRoleHolderExternalDirectoryObjectID
    FROM dbo.stagingDistributionGroupRole AS TR INNER JOIN
        dbo.recipientMap AS GMap ON TR.TargetGroupExternalDirectoryObjectID = GMap.TExternalDirectoryObjectID INNER JOIN
        dbo.recipientMap AS HMap ON HMap.TExternalDirectoryObjectID = TR.ExternalDirectoryObjectID
    WHERE  (TR.SourceOrganization IN
                      (SELECT Name
        FROM dbo.configurationOrganization
        WHERE   (MigrationRole = 'Target'))) AND EXISTS
                      (SELECT SR.Alias
        FROM dbo.stagingDistributionGroupRole AS SR INNER JOIN
            dbo.recipientMap AS SGMap ON SR.TargetGroupExternalDirectoryObjectID = SGMap.ExternalDirectoryObjectID
        WHERE   (SR.SourceOrganization IN
                                             (SELECT Name
            FROM dbo.configurationOrganization AS configurationOrganization_1
            WHERE   (MigrationRole = 'Source'))) AND (GMap.ExternalDirectoryObjectID = SR.TargetGroupExternalDirectoryObjectID) AND (HMap.ExternalDirectoryObjectID = SR.ExternalDirectoryObjectID) AND (TR.Role = SR.Role))
;