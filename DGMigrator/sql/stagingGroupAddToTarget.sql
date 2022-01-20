
/*
    No Matching Group in historyDistributionGroup (based on ExternalDirectoryObjectID)
    Needs to be Added to Target Organization
    Needs to be Added to historyDistributionGroup after processing
*/
INSERT INTO qSDistributionGroup
Select S.* ,'AddToTarget' as Action  ,'' as TargetOrganization
FROM
    dbo.stagingDistributionGroup S
    LEFT JOIN
    dbo.stagingDistributionGroup T
    ON S.ExternalDirectoryObjectID = T.CustomAttribute12
WHERE
    T.CustomAttribute12 IS NULL
    AND
    S.SourceOrganization IN (SELECT [Name]
    FROM [configurationOrganization]
    WHERE MigrationRole = 'Source')
