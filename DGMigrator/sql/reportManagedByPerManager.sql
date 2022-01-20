SELECT
    G.SourceOrganization 'SourceOrganization'
     ,G.externaldirectoryobjectID 'GroupIdentifier'
     ,G.DisplayName 'GroupDisplayName'
     ,G.PrimarySmtpAddress 'GroupPrimarySMTP'
     ,R.ExternalDirectoryObjectID 'RoleHolderIdentifier'
     ,R.DisplayName 'RoleHolderDisplayName'
     ,R.PrimarySmtpAddress 'RoleHolderPrimarySMTP'
FROM
    dbo.stagingDistributionGroup G
    JOIN
    dbo.stagingDistributionGroupRole R
    ON G.ExternalDirectoryObjectID = R.TargetGroupExternalDirectoryObjectID
WHERE R.Role = 'ManagedBy'