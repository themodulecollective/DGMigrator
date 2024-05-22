function Export-DGMOrganizationRecipient
{
    [cmdletbinding()]
    param(
        [parameter()]
        [string[]]$IncludeOrganization
        ,
        [parameter()]
        [validateset(
            'Recipient',
            'Contact',
            'UnifiedGroup',
            'DistributionGroup',
            'DistributionGroupMember',
            'DistributionGroupManagedBy',
            'DistributionGroupModeratedBy',
            'DistributionGroupAcceptMessagesOnlyFrom',
            'DistributionGroupBypassModeration',
            'DistributionGroupGrantSendOnBehalfTo',
            'DistributionGroupRejectMessagesFrom'
        )]
        [string[]]$IncludeOperation
    )

    $Configuration = Get-DGMConfiguration -Default

    $OrgsToProcess = $Configuration.Organizations.where({$IncludeOrganization.Count -eq 0 -or $_.name -in $IncludeOrganization})

    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name) for target organizations $($OrgsToProcess.Name -join ', ')."

    switch ($IncludeOperation.count -ge 1)
    {
        $true
        {
            $operation = $IncludeOperation
        }
        $false
        {
            $operation = @(
                'Recipient',
                'Contact',
                'UnifiedGroup',
                'DistributionGroup',
                'DistributionGroupMember',
                'DistributionGroupManagedBy',
                'DistributionGroupModeratedBy',
                'DistributionGroupAcceptMessagesOnlyFrom',
                'DistributionGroupBypassModeration',
                'DistributionGroupGrantSendOnBehalfTo',
                'DistributionGroupRejectMessagesFrom'
            )

        }
    }

    foreach ($o in $OrgsToProcess)
    {
        if ($null -ne $o.Credential)
        {

            Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name) for target organization $($o.Name)"

            $Credential = Import-Clixml -Path $o.Credential
            
            switch ($o.MFARequired)
            {
                $true
                {
                    Connect-ExchangeOnline -UserPrincipalName $Credential.username
                }
                $false
                {
                    Connect-ExchangeOnline -Credential $Credential
                }
                Default
                {
                    Connect-ExchangeOnline -Credential $Credential
                }
            }

            $eDGMRParams = @{
                Operation        = $operation
                OutputFolderPath = $Configuration.DataFolderPath
            }

            Export-ExchangeRecipient @eDGMRParams

            Disconnect-ExchangeOnline -confirm:$false

        }
    }

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name) for target organizations $($OrgsToProcess.Name -join ', ')."
}