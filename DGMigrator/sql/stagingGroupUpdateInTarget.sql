INSERT INTO qSDistributionGroup
SELECT
    S.[SourceOrganization]
      ,S.[ExchangeObjectId]
      ,S.[ExternalDirectoryObjectID]
      ,S.[Guid]
      ,S.[Alias]
      ,S.[DisplayName]
      ,S.[Name]
      ,S.[PrimarySmtpAddress]
      ,S.[WindowsEmailAddress]
      ,S.[RecipientType]
      ,S.[RecipientTypeDetails]
      ,S.[CustomAttribute1]
      ,S.[CustomAttribute2]
      ,S.[CustomAttribute3]
      ,S.[CustomAttribute4]
      ,S.[CustomAttribute5]
      ,S.[CustomAttribute6]
      ,S.[CustomAttribute7]
      ,S.[CustomAttribute8]
      ,S.[CustomAttribute9]
      ,S.[CustomAttribute10]
      ,S.[CustomAttribute11]
      ,S.[CustomAttribute12]
      ,S.[CustomAttribute13]
      ,S.[CustomAttribute14]
      ,S.[CustomAttribute15]
      ,S.[ExtensionCustomAttribute1]
      ,S.[ExtensionCustomAttribute2]
      ,S.[ExtensionCustomAttribute3]
      ,S.[ExtensionCustomAttribute4]
      ,S.[ExtensionCustomAttribute5]
      ,S.[Department]
      ,S.[DistinguishedName]
      ,S.[Manager]
      ,S.[WhenCreatedUTC]
	,MAX(S.WhenChangedUTC) OVER (PARTITION BY S.ExternalDirectoryObjectID) AS WhenChangedUTC
      ,S.[LastExchangeChangedTime]
      ,S.[EmailAddresses]
      ,S.[Description]
      ,S.[UMDtmfMap]
      ,S.[BccBlocked]
      ,S.[BypassNestedModerationEnabled]
      ,S.[EmailAddressPolicyEnabled]
      ,S.[HiddenFromAddressListsEnabled]
      ,S.[HiddenGroupMembershipEnabled]
      ,S.[ReportToManagerEnabled]
      ,S.[ReportToOriginatorEnabled]
      ,S.[RequireSenderAuthenticationEnabled]
      ,S.[ModerationEnabled]
      ,S.[SendOofMessageToOriginatorEnabled]
      ,S.[IsDirSynced]
      ,S.[IsValid]
      ,S.[MigrationToUnifiedGroupInProgress]
      ,S.[SendModerationNotifications]
      ,S.[LegacyExchangeDN]
      ,S.[MailTip]
      ,S.[MemberDepartRestriction]
      ,S.[MemberJoinRestriction]
      ,S.[GroupType]
      ,S.[ObjectCategory]
      ,S.[ObjectState]
      ,S.[OrganizationalUnit]
      ,S.[OrganizationalUnitRoot]
      ,S.[OrganizationId]
      ,S.[SimpleDisplayName]
      ,S.[MaxReceiveSize]
      ,S.[MaxSendSize]
      ,S.[AcceptMessagesOnlyFromSendersOrMembers]
      ,S.[AddressListMembership]
      ,S.[GrantSendOnBehalfTo]
      ,S.[ManagedBy]
	,'UpdateInTarget' as Action
	,'' as TargetOrganization
FROM
    dbo.stagingDistributionGroup S
    JOIN
    dbo.historyDistributionGroup T
    ON
        S.ExternalDirectoryObjectID = T.ExternalDirectoryObjectID
        AND
        S.WhenChangedUTC > T.WhenChangedUTC
        AND
        S.SourceOrganization IN
(SELECT [Name]
        FROM [configurationOrganization]
        WHERE MigrationRole = 'Source')
        AND
        T.SourceOrganization IN
(SELECT [Name]
        FROM [configurationOrganization]
        WHERE MigrationRole = 'Source')
ORDER BY ExternalDirectoryObjectID