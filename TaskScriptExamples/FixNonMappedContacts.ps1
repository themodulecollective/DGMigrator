$NotMapped = @(Invoke-DGMQuery -query 'select * from qIContact')
$DGMConfig = Get-DGMConfiguration -Default
$SourcePrimaryDomains = @($DGMConfig.Organizations.Where({$_.MigrationRole -eq 'Source'}).PrimaryDomain)


$Result = @(
    foreach ($nmc in $NotMapped)
    {
        $Contact = @(get-MailContact -Identity $nmc.ExternalEmailAddress)
        switch ($Contact.Count)
        {
            1
            {
                $SetMCParams = @{
                    Identity          = $Contact.externaldirectoryobjectID
                    CustomAttribute11 = $nmc.SourceOrganization
                    CustomAttribute12 = $nmc.externaldirectoryobjectID
                    CustomAttribute13 = $nmc.PrimarySMTPAddress
                    ErrorAction       = 'Stop'
                    WarningAction     = 'SilentlyContinue'
                }

                Set-MailContact @SetMCParams
            }

            Default
            {
                Write-Warning -Message "Unable to Set Contact $($nmc.PrimarySmtpAddress)"
            }

        }
    }
)
