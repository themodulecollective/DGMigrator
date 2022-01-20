INSERT INTO recipientMap
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
UNION
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
            AND RecipientTypeDetails IN ('MailContact','GuestMailUser','MailUser','UserMailbox','SharedMailbox','RoomMailbox','GroupMailbox')
    )
    AS S
        LEFT JOIN
        (
        Select *
        FROM stagingRecipient
        WHERE SourceOrganization IN (SELECT [Name]
            FROM [configurationOrganization]
            WHERE MigrationRole = 'Target')
            AND RecipientTypeDetails IN ('MailContact','GuestMailUser','MailUser','UserMailbox','SharedMailbox','RoomMailbox','GroupMailbox')
    )
    AS T
        ON S.PrimarySMTPAddress = T.CustomAttribute13 OR S.CustomAttribute13 = T.CustomAttribute13
    WHERE T.ExternalDirectoryObjectID IS NOT NULL
UNION
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
            AND RecipientTypeDetails LIKE ('%Group')
    )
    AS S
        LEFT JOIN
        (
        Select *
        FROM stagingRecipient
        WHERE SourceOrganization IN (SELECT [Name]
            FROM [configurationOrganization]
            WHERE MigrationRole = 'Target')
            AND RecipientTypeDetails LIKE ('%Group')
    )
    AS T
        ON S.ExternalDirectoryObjectID = T.CustomAttribute12
    WHERE T.ExternalDirectoryObjectID IS NOT NULL