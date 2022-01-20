
/*
    No Matching Group Role (Membership, etc.) in historyDistributionGroupRole (based on ExternalDirectoryObjectID)
    Needs to be Added to Target Organization
    Needs to be Added to historyDistributionGroup after processing
*/
INSERT INTO qSDistributionGroupRole
SELECT
    SourceRoles.[SourceOrganization]
    ,SourceRoles.[ExchangeGuid]
    ,SourceRoles.[ExternalDirectoryObjectID]
    ,SourceRoles.[Guid]
    ,SourceRoles.[Alias]
    ,SourceRoles.[DisplayName]
    ,SourceRoles.[PrimarySmtpAddress]
    ,SourceRoles.[RecipientTypeDetails]
    ,SourceRoles.[Role]
    ,SourceRoles.[TargetGroupGUID]
    ,SourceRoles.[TargetGroupExternalDirectoryObjectID]
    ,SourceRoles.[TargetGroupDisplayName]
    ,SourceRoles.[TargetGroupPrimarySmtpAddress]
    ,'AddToTarget' AS Action
     ,'' AS TargetOrganization
FROM SourceRolesWithMap SourceRoles
    LEFT JOIN TargetRolesMatchingSourceRoles TargetRoles
    ON SourceRoles.DestinationRoleHolderExternalDirectoryObjectID = TargetRoles.ExternalDirectoryObjectID
        AND SourceRoles.DestinationGroupExternalDirectoryObjectID = TargetRoles.TargetGroupExternalDirectoryObjectID
        AND SourceRoles.Role = TargetRoles.Role
WHERE TargetRoles.SourceRoleHolderExternalDirectoryObjectID IS NULL
    AND SourceRoles.DestinationGroupExternalDirectoryObjectID IS NOT NULL
    AND SourceRoles.DestinationRoleHolderExternalDirectoryObjectID IS NOT NULL
    AND SourceRoles.TargetGroupExternalDirectoryObjectID NOT IN
    (
        SELECT Q.ExternalDirectoryObjectID
    FROM qSDistributionGroup Q
    WHERE [Action] = 'AddToTarget'
    )
;
INSERT INTO qIDistributionGroupRole
SELECT
    SourceRoles.SourceOrganization
	 ,'' AS ExchangeGUID
      ,SourceRoles.DestinationRoleHolderExternalDirectoryObjectID AS ExternalDirectoryObjectID
	  ,'' AS [Guid]
	  ,SourceRoles.DestinationRoleHolderAlias AS Alias
	  ,SourceRoles.DisplayName
	  ,SourceRoles.DestinationRoleHolderPrimarySMTPAddress AS PrimarySMTPAddress
	  ,SourceRoles.DestinationRoleHolderRecipientTypeDetails AS RecipientTypeDetails
      ,SourceRoles.Role
	  ,'' AS TargetGroupGUID
	  ,SourceRoles.[DestinationGroupExternalDirectoryObjectID] AS TargetGroupExternalDirectoryObjectID
	  ,SourceRoles.TargetGroupDisplayName
	  ,SourceRoles.DestinationGroupPrimarySmtpAddress AS TargetGroupPrimarySMTPAddress
     ,'AddToTarget' AS Action
     ,'' AS TargetOrganization
FROM SourceRolesWithMap SourceRoles
    LEFT JOIN TargetRolesMatchingSourceRoles TargetRoles
    ON SourceRoles.DestinationRoleHolderExternalDirectoryObjectID = TargetRoles.ExternalDirectoryObjectID
        AND SourceRoles.DestinationGroupExternalDirectoryObjectID = TargetRoles.TargetGroupExternalDirectoryObjectID
        AND SourceRoles.Role = TargetRoles.Role
    LEFT JOIN recipientMap Map
    ON SourceRoles.DestinationGroupExternalDirectoryObjectID = Map.TExternalDirectoryObjectID
WHERE TargetRoles.SourceRoleHolderExternalDirectoryObjectID IS NULL
    AND SourceRoles.DestinationGroupExternalDirectoryObjectID IS NOT NULL
    AND SourceRoles.DestinationRoleHolderExternalDirectoryObjectID IS NOT NULL
    AND SourceRoles.TargetGroupExternalDirectoryObjectID NOT IN
    (
        SELECT Q.ExternalDirectoryObjectID
    FROM qSDistributionGroup Q
    WHERE [Action] = 'AddToTarget'
    )
;
