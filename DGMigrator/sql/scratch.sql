SELECT
    TR.SourceOrganization
 ,TR.ExternalDirectoryObjectID
 ,TR.PrimarySmtpAddress
 ,TR.RecipientTypeDetails
 ,TR.Role
 ,TR.TargetGroupExternalDirectoryObjectID
 ,TR.TargetGroupPrimarySmtpAddress
 ,GMap.ExternalDirectoryObjectID SourceGroupExternalDirectoryObjectID
 ,HMap.ExternalDirectoryObjectID SourceRoleHolderExternalDirectoryObjectID
FROM
    dbo.stagingDistributionGroupRoleTargetOnly TR
    INNER JOIN
    dbo.recipientMap GMap
    ON TR.TargetGroupExternalDirectoryObjectID = GMap.TExternalDirectoryObjectID
    INNER JOIN
    dbo.recipientMap HMap
    ON HMap.TExternalDirectoryObjectID = TR.ExternalDirectoryObjectID
    INNER JOIN
    (
        SELECT Role
    FROM stagingDistributionGroupRoleSourceOnly
    ) SR
    ON SR.externalDirectoryObjectID = HMap.ExternalDirectoryObjectID
        AND
        SR.TargetGroupExternalDirectoryObjectID = GMap.ExternalDirectoryObjectID
        AND
        SR.Role = TR.Role
