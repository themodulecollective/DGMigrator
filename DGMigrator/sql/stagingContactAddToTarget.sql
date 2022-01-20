
/*
    No Matching Group Role (Membership, etc.) in historyDistributionGroupRole (based on ExternalDirectoryObjectID)
    Needs to be Added to Target Organization
    Needs to be Added to historyDistributionGroup after processing
*/
INSERT INTO qSContact
SELECT * ,'AddToTarget' as Action  ,'' as TargetOrganization
FROM stagingContact
WHERE
ExternalDirectoryObjectID IN (
SELECT DISTINCT
		R.ExternalDirectoryObjectID
	FROM
		stagingDistributionGroupRole R
		LEFT JOIN
		stagingRecipient T
		ON R.PrimarySmtpAddress = T.CustomAttribute13
	WHERE
	R.RecipientTypeDetails = 'MailContact'
		AND T.CustomAttribute13 IS NULL
)
	AND SourceOrganization IN (SELECT [Name]
	FROM [configurationOrganization]
	WHERE MigrationRole = 'Source')
