SELECT
    G.SourceOrganization 'SourceOrganization'
     ,G.externaldirectoryobjectID 'GroupIdentifier'
     ,G.DisplayName 'GroupDisplayName'
     ,G.PrimarySmtpAddress 'GroupPrimarySMTP'
      ,STRING_AGG (R.PrimarySmtpAddress,'; ') 'Managers'
FROM
    dbo.stagingDistributionGroup G
    JOIN
    dbo.stagingDistributionGroupRole R
    ON G.ExternalDirectoryObjectID = R.TargetGroupExternalDirectoryObjectID
WHERE R.Role = 'ManagedBy'
GROUP BY G.SourceOrganization, G.externaldirectoryobjectID, G.DisplayName, G.PrimarySMTPAddress