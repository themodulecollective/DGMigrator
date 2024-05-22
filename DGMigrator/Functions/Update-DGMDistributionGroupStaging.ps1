function Update-DGMDistributionGroupStaging
{
    [cmdletbinding()]
    param(
        [parameter()]
        [validateset(
            'DistributionGroup'
            <#          'DistributionGroupRole',
            'DistributionGroupManagedBy',
            'DistributionGroupModeratedBy',
            'DistributionGroupAcceptMessagesOnlyFrom',
            'DistributionGroupBypassModeration',
            'DistributionGroupGrantSendOnBehalfTo',
            'DistributionGroupRejectMessagesFrom' #>
        )]
        [string[]]$IncludeOperation
        ,
        [parameter()]
        [string[]]$IncludeExternalDirectoryObjectID
    )

    $Configuration = Get-DGMConfiguration -Default

    #TargetOrganizationSettings
    $o = $($Configuration.Organizations.where({$_.MigrationRole -eq 'Target'}))
    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name) for target organization $($o.Name)"

    if ($null -ne $o.Credential)
    {
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
    }
    else
    {
        throw("$($MyInvocation.MyCommand.Name) works only with stored Credentials")
    }

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    $tables = @('stagingNLDistributionGroup')

    Write-PSFMessage -Level Verbose -Message "Truncating tables $($tables -join ', ')"
    foreach ($t in $tables)
    {
        $null = Invoke-DbaQuery @dbParams -query "TRUNCATE TABLE $t"
    }

    switch ($IncludeOperation.count -ge 1)
    {
        $true
        {
            $operation = $IncludeOperation
        }
        $false
        {
            $operation = @(
                'DistributionGroup'
                <# ,
                'DistributionGroupMember',
                'DistributionGroupManagedBy',
                'DistributionGroupModeratedBy',
                'DistributionGroupAcceptMessagesOnlyFrom',
                'DistributionGroupBypassModeration',
                'DistributionGroupGrantSendOnBehalfTo',
                'DistributionGroupRejectMessagesFrom' #>
            )

        }
    }

    $ErrorActionPreference = 'Continue'

    #For commands that support Recipient Filtering
    $GetRParams = @{
        ResultSize    = 'Unlimited'
        WarningAction = 'SilentlyContinue'
    }



    Switch ($Operation | Sort-Object)
    {
        'DistributionGroup'
        {
            $DistributionGroups = @(
                switch ($IncludeExternalDirectoryObjectID.count -ge 1)
                {
                    $true
                    {
                        $OpTotalCount = $IncludeExternalDirectoryObjectID.count
                        $OpCount = 0
                        $IncludeExternalDirectoryObjectID.where({$_.length -ge 1}).foreach({
                                $OpCount++
                                Write-Progress -Activity 'Getting Distribution Groups' -CurrentOperation "" -Status "Group $OpCount of $OpTotalCount" -Id 0
                                Get-DistributionGroup -Filter "CustomAttribute12 -eq '$_'"
                            })
                    }
                    $false
                    {Get-DistributionGroup @GetRParams}
                }
            )

            $sqlColumnMap = Get-DGMColumnMap -TableType stagingDistributionGroup
            $Columns = $sqlColumnMap.foreach({$_.name})
            $ColumnMap = @{}
            $Columns.foreach({
                    $ColumnMap.$_ = $_
                })
            #columns that need special handling in stagingRecipient
            $CustomColumns = @(
                'SourceOrganization'
                'ExchangeObjectId'
                'Guid'
                'EmailAddresses'
                'Description'
                'UMDtmfMap'
                'AcceptMessagesOnlyFromSendersOrMembers'
                'BypassModerationFromSendersOrMembers'
                'AddressListMembership'
                'GrantSendOnBehalfTo'
                'ManagedBy'
                @(1..5).foreach({
                        "ExtensionCustomAttribute$($_)"
                    })
            )
            $Properties = @(
                @{n='SourceOrganization'; e={$o.Name}}
                @{n='ExchangeObjectId'; e={$_.ExchangeObjectId.Guid}}
                @{n='Guid'; e={$_.Guid.Guid}}
                $Columns.where( { $_ -notin $CustomColumns })
                @{n='EmailAddresses'; e={$_.EmailAddresses -join ';'}}
                @{n='Description'; e={$_.Description -join ';'}}
                @{n='UMDtmfMap'; e={$_.UMDtmfMap -join ';'}}
                @{n='AddressListMembership'; e={$_.AddressListMembership -join ';'}}
                @{n='AcceptMessagesOnlyFromSendersOrMembers'; e={$_.AcceptMessagesOnlyFromSendersOrMembers -join ';'}}
                @{n='BypassModerationFromSendersOrMembers'; e={$_.BypassModerationFromSendersOrMembers -join ';'}}
                @{n='GrantSendOnBehalfTo'; e={$_.GrantSendOnBehalfTo -join ';'}}
                @{n='ManagedBy'; e={$_.ManagedBy -join ';'}}
                @{n='ExtensionCustomAttribute1'; e={$_.ExtensionCustomAttribute1 -join ';'}}
                @{n='ExtensionCustomAttribute2'; e={$_.ExtensionCustomAttribute2 -join ';'}}
                @{n='ExtensionCustomAttribute3'; e={$_.ExtensionCustomAttribute3 -join ';'}}
                @{n='ExtensionCustomAttribute4'; e={$_.ExtensionCustomAttribute4 -join ';'}}
                @{n='ExtensionCustomAttribute5'; e={$_.ExtensionCustomAttribute5 -join ';'}}
            )

            $DistributionGroups |
            Select-Object -Property $Properties |
            ConvertTo-DbaDataTable |
            Write-DbaDataTable @dbparams -table 'stagingNLDistributionGroup' -ColumnMap $ColumnMap

            #run Merge query from 'stagingNLDistributionGroup' to 'stagingDistributionGroup'
            Write-PSFMessage -Message "Processing SQL Script mergeNLDistributionGroup"
            #expand the SQL for any PS Variables/Scriptblocks contained
            $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.mergeNLDistributionGroup)
            #run the Script
            Invoke-DbaQuery @dbparams -query $eSQL
        }
    }

    Disconnect-ExchangeOnline -confirm:$false

}