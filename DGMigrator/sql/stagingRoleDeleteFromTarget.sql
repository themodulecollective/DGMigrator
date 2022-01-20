/*
    No Matching Group in stagingDistributionGroup (based on ExternalDirectoryObjectID)
        and SourceOrganization
    Needs to be Deleted From Target Organization
    Needs to be Deleted From historyDistributionGroup after processing
    Dynamic Replacement of SourceOrganizations value needed
*/
INSERT INTO qSDistributionGroupRole
SELECT
    TargetRoles.SourceOrganization
	 ,TargetRoles.ExchangeGuid
	 ,TargetRoles.ExternalDirectoryObjectID
	 ,TargetRoles.Guid
	 ,TargetRoles.Alias
	 ,TargetRoles.DisplayName
	 ,TargetRoles.PrimarySmtpAddress
	 ,TargetRoles.RecipientTypeDetails
	 ,TargetRoles.Role
	 ,TargetRoles.TargetGroupGUID
	 ,TargetRoles.TargetGroupExternalDirectoryObjectID
	 ,TargetRoles.TargetGroupDisplayName
	 ,TargetRoles.TargetGroupPrimarySmtpAddress
	,'DeleteFromTarget' AS Action
	,'' AS TargetOrganization
FROM stagingDistributionGroupRole TargetRoles
    LEFT JOIN (
	SELECT [SourceOrganization]
      ,[ExternalDirectoryObjectID]
      ,[PrimarySmtpAddress]
      ,[RecipientTypeDetails]
      ,[Role]
      ,[TargetGroupExternalDirectoryObjectID]
      ,[TargetGroupPrimarySmtpAddress]
      ,[SourceGroupExternalDirectoryObjectID]
      ,[SourceRoleHolderExternalDirectoryObjectID]
    FROM [dbo].[TargetRolesMatchingSourceRoles]
	) TRM
    ON
	TargetRoles.SourceOrganization = TRM.SourceOrganization
        AND TargetRoles.ExternalDirectoryObjectID = TRM.ExternalDirectoryObjectID
        AND TargetRoles.TargetGroupExternalDirectoryObjectID = TRM.TargetGroupExternalDirectoryObjectID
        AND TargetRoles.Role = TRM.Role
WHERE	TRM.SourceOrganization IS NULL
    AND TargetRoles.SourceOrganization IN
    (
        SELECT [name]
    FROM configurationOrganization
    WHERE MigrationRole = 'Target'
    )
    AND TargetRoles.ExternalDirectoryObjectID IN
    (
        SELECT TExternalDirectoryObjectID
    FROM recipientMap
    WHERE TExternalDirectoryObjectID IS NOT NULL
    )
    AND TargetRoles.TargetGroupExternalDirectoryObjectID NOT IN
    (
        SELECT Q.ExternalDirectoryObjectID
    FROM qSDistributionGroup Q
    WHERE [Action] = 'DeleteFromTarget' AND Q.ExternalDirectoryObjectID IS NOT NULL
    )
    AND TargetRoles.TargetGroupExternalDirectoryObjectID NOT IN
	(
		SELECT TGNM.ExternalDirectoryObjectID
    FROM TargetGroupNotMappedToSource AS TGNM
	)
ORDER BY TargetRoles.TargetGroupExternalDirectoryObjectID
;
INSERT INTO qIDistributionGroupRole
SELECT
    TargetRoles.SourceOrganization
	 ,TargetRoles.ExchangeGuid
	 ,TargetRoles.ExternalDirectoryObjectID
	 ,TargetRoles.Guid
	 ,TargetRoles.Alias
	 ,TargetRoles.DisplayName
	 ,TargetRoles.PrimarySmtpAddress
	 ,TargetRoles.RecipientTypeDetails
	 ,TargetRoles.Role
	 ,TargetRoles.TargetGroupGUID
	 ,TargetRoles.TargetGroupExternalDirectoryObjectID
	 ,TargetRoles.TargetGroupDisplayName
	 ,TargetRoles.TargetGroupPrimarySmtpAddress
	,'DeleteFromTarget' AS Action
	,'' AS TargetOrganization
FROM stagingDistributionGroupRole TargetRoles
    LEFT JOIN (
	SELECT [SourceOrganization]
      ,[ExternalDirectoryObjectID]
      ,[PrimarySmtpAddress]
      ,[RecipientTypeDetails]
      ,[Role]
      ,[TargetGroupExternalDirectoryObjectID]
      ,[TargetGroupPrimarySmtpAddress]
      ,[SourceGroupExternalDirectoryObjectID]
      ,[SourceRoleHolderExternalDirectoryObjectID]
    FROM [dbo].[TargetRolesMatchingSourceRoles]
	) TRM
    ON
	TargetRoles.SourceOrganization = TRM.SourceOrganization
        AND TargetRoles.ExternalDirectoryObjectID = TRM.ExternalDirectoryObjectID
        AND TargetRoles.TargetGroupExternalDirectoryObjectID = TRM.TargetGroupExternalDirectoryObjectID
        AND TargetRoles.Role = TRM.Role
WHERE	TRM.SourceOrganization IS NULL
    AND TargetRoles.SourceOrganization IN
    (
        SELECT [name]
    FROM configurationOrganization
    WHERE MigrationRole = 'Target'
    )
    AND TargetRoles.ExternalDirectoryObjectID IN
    (
        SELECT TExternalDirectoryObjectID
    FROM recipientMap
    WHERE TExternalDirectoryObjectID IS NOT NULL
    )
    AND TargetRoles.TargetGroupExternalDirectoryObjectID NOT IN
    (
        SELECT Q.ExternalDirectoryObjectID
    FROM qSDistributionGroup Q
    WHERE [Action] = 'DeleteFromTarget' AND Q.ExternalDirectoryObjectID IS NOT NULL
    )
    AND TargetRoles.TargetGroupExternalDirectoryObjectID NOT IN
	(
		SELECT TGNM.ExternalDirectoryObjectID
    FROM TargetGroupNotMappedToSource AS TGNM
	)
ORDER BY TargetRoles.TargetGroupExternalDirectoryObjectID