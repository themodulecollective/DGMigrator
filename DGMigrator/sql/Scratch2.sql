--Contact to Contact
Select DISTINCT
    S.[SourceOrganization]
	  ,T.SourceOrganization AS TSourceOrganization
      ,S.[ExternalDirectoryObjectID]
	  ,T.ExternalDirectoryObjectID AS TExternalDirectoryObjectID
      ,S.[Alias]
	  ,T.Alias AS TAlias
      ,S.[PrimarySmtpAddress]
	  ,T.PrimarySmtpAddress AS TPrimarySMTPAddress
      ,S.[ExternalEmailAddress]
	  ,T.ExternalEmailAddress AS TExternalEmailAddress
      ,T.CustomAttribute13 AS TCustomAttribute13
      ,S.[RecipientTypeDetails]
	  ,T.RecipientTypeDetails AS TRecipientTypeDetails
FROM
    (
        Select *
    FROM stagingRecipient
    WHERE SourceOrganization IN (SELECT [Name]
        FROM [configurationOrganization]
        WHERE MigrationRole = 'Source')
        AND RecipientTypeDetails IN ('MailContact')
    )
    AS S
    LEFT JOIN
    (
        Select *
    FROM stagingRecipient
    WHERE SourceOrganization IN (SELECT [Name]
        FROM [configurationOrganization]
        WHERE MigrationRole = 'Target')
        AND RecipientTypeDetails IN ('MailContact')
    )
    AS T
    ON S.ExternalEmailAddress = T.PrimarySMTPAddress
WHERE T.ExternalDirectoryObjectID IS NOT NULL