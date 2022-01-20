CREATE VIEW [dbo].[stagingDistributionGroupRoleTargetOnly]
AS
    SELECT SourceOrganization ,ExchangeGuid ,ExternalDirectoryObjectID ,Guid ,Alias ,DisplayName ,PrimarySmtpAddress ,RecipientTypeDetails ,Role ,TargetGroupGUID ,TargetGroupExternalDirectoryObjectID ,TargetGroupDisplayName
        ,TargetGroupPrimarySmtpAddress
    FROM dbo.stagingDistributionGroupRole
    WHERE  (SourceOrganization IN
                      (SELECT Name
    FROM dbo.configurationOrganization
    WHERE   (MigrationRole = 'Target')))
;