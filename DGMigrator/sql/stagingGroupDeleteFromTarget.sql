/*
    No Matching Group in stagingDistributionGroup (based on ExternalDirectoryObjectID)
        and SourceOrganization
    Needs to be Deleted From Target Organization
    Needs to be Deleted From historyDistributionGroup after processing
    Dynamic Replacement of SourceOrganizations value needed
*/
INSERT INTO qSDistributionGroup
Select T.* ,'DeleteFromTarget' as Action  ,'' as TargetOrganization
FROM
    dbo.stagingDistributionGroup T
    LEFT JOIN
    dbo.stagingDistributionGroup S
    ON S.ExternalDirectoryObjectID = T.CustomAttribute12
WHERE S.ExternalDirectoryObjectID IS NULL
    AND T.CustomAttribute12 IS NOT NULL
    AND T.SourceOrganization IN (SELECT [Name]
    FROM [configurationOrganization]
    WHERE MigrationRole = 'Target')