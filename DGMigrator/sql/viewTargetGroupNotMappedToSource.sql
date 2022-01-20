CREATE VIEW [dbo].[TargetGroupNotMappedToSource]
AS
    SELECT SourceOrganization ,ExchangeGuid ,ExchangeObjectId ,ExternalDirectoryObjectID ,Guid ,Alias ,DisplayName ,PrimarySmtpAddress ,ExternalEmailAddress ,RecipientType ,RecipientTypeDetails ,CustomAttribute1 ,CustomAttribute2
        ,CustomAttribute3 ,CustomAttribute4 ,CustomAttribute5 ,CustomAttribute6 ,CustomAttribute7 ,CustomAttribute8 ,CustomAttribute9 ,CustomAttribute10 ,CustomAttribute11 ,CustomAttribute12 ,CustomAttribute13 ,CustomAttribute14
        ,CustomAttribute15 ,Department ,DistinguishedName ,Manager ,WhenCreatedUTC ,WhenChangedUTC ,EmailAddresses
    FROM dbo.stagingRecipient
    WHERE  (RecipientTypeDetails LIKE '%group') AND (SourceOrganization IN (SELECT name
        FROM configurationOrganization
        WHERE MigrationRole = 'Target' )) AND (CustomAttribute13 IS NULL OR
        CustomAttribute13 LIKE '')