SELECT DISTINCT
    (SELECT COUNT(TargetGroupGUID)
    FROM stagingDistributionGroupRole CR
    WHERE SR.PrimarySmtpAddress = CR.PrimarySmtpAddress) As RoleCount ,SR.*
FROM
    stagingRecipient SR
    RIGHT JOIN
    stagingDistributionGroupRole R
    LEFT JOIN
    recipientMap M
    ON R.PrimarySmtpAddress = M.TCustomAttribute13
    ON SR.PrimarySmtpAddress = R.PrimarySmtpAddress
WHERE R.Role = 'MemberOf' AND M.TCustomAttribute13 IS NULL
    AND SR.RecipientTypeDetails IN
	(
	'UserMailbox'
	,'MailUser'
	,'DynamicDistributionGroup'
	,'SharedMailbox'
	)
