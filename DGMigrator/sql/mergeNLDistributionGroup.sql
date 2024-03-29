MERGE stagingDistributionGroup T
USING stagingNLDistributionGroup S ON T.ExternalDirectoryObjectID = S.ExternalDirectoryObjectID

WHEN MATCHED THEN
UPDATE SET
	[SourceOrganization] = T.[SourceOrganization],
	[ExchangeObjectId] = T.[ExchangeObjectId],
	[ExternalDirectoryObjectID] = T.[ExternalDirectoryObjectID],
	[Guid] = T.[Guid],
	[Alias] = T.[Alias],
	[DisplayName] = T.[DisplayName],
	[Name] = T.[Name],
	[PrimarySmtpAddress] = T.[PrimarySmtpAddress],
	[WindowsEmailAddress] = T.[WindowsEmailAddress],
	[RecipientType] = T.[RecipientType],
	[RecipientTypeDetails] = T.[RecipientTypeDetails],
	[CustomAttribute1] = T.[CustomAttribute1],
	[CustomAttribute2] = T.[CustomAttribute2],
	[CustomAttribute3] = T.[CustomAttribute3],
	[CustomAttribute4] = T.[CustomAttribute4],
	[CustomAttribute5] = T.[CustomAttribute5],
	[CustomAttribute6] = T.[CustomAttribute6],
	[CustomAttribute7] = T.[CustomAttribute7],
	[CustomAttribute8] = T.[CustomAttribute8],
	[CustomAttribute9] = T.[CustomAttribute9],
	[CustomAttribute10] = T.[CustomAttribute10],
	[CustomAttribute11] = T.[CustomAttribute11],
	[CustomAttribute12] = T.[CustomAttribute12],
	[CustomAttribute13] = T.[CustomAttribute13],
	[CustomAttribute14] = T.[CustomAttribute14],
	[CustomAttribute15] = T.[CustomAttribute15],
	[ExtensionCustomAttribute1] = T.[ExtensionCustomAttribute1],
	[ExtensionCustomAttribute2] = T.[ExtensionCustomAttribute2],
	[ExtensionCustomAttribute3] = T.[ExtensionCustomAttribute3],
	[ExtensionCustomAttribute4] = T.[ExtensionCustomAttribute4],
	[ExtensionCustomAttribute5] = T.[ExtensionCustomAttribute5],
	[Department] = T.[Department],
	[DistinguishedName] = T.[DistinguishedName],
	[Manager] = T.[Manager],
	[WhenCreatedUTC] = T.[WhenCreatedUTC],
	[WhenChangedUTC] = T.[WhenChangedUTC],
	[LastExchangeChangedTime] = T.[LastExchangeChangedTime],
	[EmailAddresses] = T.[EmailAddresses],
	[Description] = T.[Description],
	[UMDtmfMap] = T.[UMDtmfMap],
	[BccBlocked] = T.[BccBlocked],
	[BypassNestedModerationEnabled] = T.[BypassNestedModerationEnabled],
	[EmailAddressPolicyEnabled] = T.[EmailAddressPolicyEnabled],
	[HiddenFromAddressListsEnabled] = T.[HiddenFromAddressListsEnabled],
	[HiddenGroupMembershipEnabled] = T.[HiddenGroupMembershipEnabled],
	[ReportToManagerEnabled] = T.[ReportToManagerEnabled],
	[ReportToOriginatorEnabled] = T.[ReportToOriginatorEnabled],
	[RequireSenderAuthenticationEnabled] = T.[RequireSenderAuthenticationEnabled],
	[ModerationEnabled] = T.[ModerationEnabled],
	[SendOofMessageToOriginatorEnabled] = T.[SendOofMessageToOriginatorEnabled],
	[IsDirSynced] = T.[IsDirSynced],
	[IsValid] = T.[IsValid],
	[MigrationToUnifiedGroupInProgress] = T.[MigrationToUnifiedGroupInProgress],
	[SendModerationNotifications] = T.[SendModerationNotifications],
	[LegacyExchangeDN] = T.[LegacyExchangeDN],
	[MailTip] = T.[MailTip],
	[MemberDepartRestriction] = T.[MemberDepartRestriction],
	[MemberJoinRestriction] = T.[MemberJoinRestriction],
	[GroupType] = T.[GroupType],
	[ObjectCategory] = T.[ObjectCategory],
	[ObjectState] = T.[ObjectState],
	[OrganizationalUnit] = T.[OrganizationalUnit],
	[OrganizationalUnitRoot] = T.[OrganizationalUnitRoot],
	[OrganizationId] = T.[OrganizationId],
	[SimpleDisplayName] = T.[SimpleDisplayName],
	[MaxReceiveSize] = T.[MaxReceiveSize],
	[MaxSendSize] = T.[MaxSendSize],
	[AcceptMessagesOnlyFromSendersOrMembers] = T.[AcceptMessagesOnlyFromSendersOrMembers],
	[AddressListMembership] = T.[AddressListMembership],
	[GrantSendOnBehalfTo] = T.[GrantSendOnBehalfTo],
	[ManagedBy] = T.[ManagedBy]

WHEN NOT MATCHED THEN
INSERT (SourceOrganization,ExchangeObjectId,ExternalDirectoryObjectID,Guid,Alias,DisplayName,Name,PrimarySmtpAddress,WindowsEmailAddress,RecipientType,RecipientTypeDetails,CustomAttribute1,CustomAttribute2,CustomAttribute3,CustomAttribute4,CustomAttribute5,CustomAttribute6,CustomAttribute7,CustomAttribute8,CustomAttribute9,CustomAttribute10,CustomAttribute11,CustomAttribute12,CustomAttribute13,CustomAttribute14,CustomAttribute15,ExtensionCustomAttribute1,ExtensionCustomAttribute2,ExtensionCustomAttribute3,ExtensionCustomAttribute4,ExtensionCustomAttribute5,Department,DistinguishedName,Manager,WhenCreatedUTC,WhenChangedUTC,LastExchangeChangedTime,EmailAddresses,Description,UMDtmfMap,BccBlocked,BypassNestedModerationEnabled,EmailAddressPolicyEnabled,HiddenFromAddressListsEnabled,HiddenGroupMembershipEnabled,ReportToManagerEnabled,ReportToOriginatorEnabled,RequireSenderAuthenticationEnabled,ModerationEnabled,SendOofMessageToOriginatorEnabled,IsDirSynced,IsValid,MigrationToUnifiedGroupInProgress,SendModerationNotifications,LegacyExchangeDN,MailTip,MemberDepartRestriction,MemberJoinRestriction,GroupType,ObjectCategory,ObjectState,OrganizationalUnit,OrganizationalUnitRoot,OrganizationId,SimpleDisplayName,MaxReceiveSize,MaxSendSize,AcceptMessagesOnlyFromSendersOrMembers,AddressListMembership,GrantSendOnBehalfTo,ManagedBy)
VALUES (S.SourceOrganization,S.ExchangeObjectId,S.ExternalDirectoryObjectID,S.Guid,S.Alias,S.DisplayName,S.Name,S.PrimarySmtpAddress,S.WindowsEmailAddress,S.RecipientType,S.RecipientTypeDetails,S.CustomAttribute1,S.CustomAttribute2,S.CustomAttribute3,S.CustomAttribute4,S.CustomAttribute5,S.CustomAttribute6,S.CustomAttribute7,S.CustomAttribute8,S.CustomAttribute9,S.CustomAttribute10,S.CustomAttribute11,S.CustomAttribute12,S.CustomAttribute13,S.CustomAttribute14,S.CustomAttribute15,S.ExtensionCustomAttribute1,S.ExtensionCustomAttribute2,S.ExtensionCustomAttribute3,S.ExtensionCustomAttribute4,S.ExtensionCustomAttribute5,S.Department,S.DistinguishedName,S.Manager,S.WhenCreatedUTC,S.WhenChangedUTC,S.LastExchangeChangedTime,S.EmailAddresses,S.Description,S.UMDtmfMap,S.BccBlocked,S.BypassNestedModerationEnabled,S.EmailAddressPolicyEnabled,S.HiddenFromAddressListsEnabled,S.HiddenGroupMembershipEnabled,S.ReportToManagerEnabled,S.ReportToOriginatorEnabled,S.RequireSenderAuthenticationEnabled,S.ModerationEnabled,S.SendOofMessageToOriginatorEnabled,S.IsDirSynced,S.IsValid,S.MigrationToUnifiedGroupInProgress,S.SendModerationNotifications,S.LegacyExchangeDN,S.MailTip,S.MemberDepartRestriction,S.MemberJoinRestriction,S.GroupType,S.ObjectCategory,S.ObjectState,S.OrganizationalUnit,S.OrganizationalUnitRoot,S.OrganizationId,S.SimpleDisplayName,S.MaxReceiveSize,S.MaxSendSize,S.AcceptMessagesOnlyFromSendersOrMembers,S.AddressListMembership,S.GrantSendOnBehalfTo,S.ManagedBy)
;