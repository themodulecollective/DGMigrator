SELECT count(DD.MissingRecipient) As DistinctCount ,DD.SRecipientTypeDetails
FROM (
SELECT DISTINCT D.MissingRecipient ,SRecipientTypeDetails
    FROM
        (
	SELECT
            R.PrimarySmtpAddress AS MissingRecipient
		 ,R.RecipientTypeDetails AS SRecipientTypeDetails
        FROM
            stagingDistributionGroupRole R
            LEFT JOIN
            recipientMap M
            ON R.PrimarySmtpAddress = M.TCustomAttribute13
        WHERE R.Role = 'MemberOf' AND M.TCustomAttribute13 IS NULL
) D) DD
GROUP BY SRecipientTypeDetails