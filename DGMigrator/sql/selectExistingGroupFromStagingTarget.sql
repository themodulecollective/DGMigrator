Select *
FROM stagingDistributionGroup
WHERE SourceOrganization IN (SELECT [Name]
FROM [configurationOrganization]
WHERE MigrationRole = 'Target')