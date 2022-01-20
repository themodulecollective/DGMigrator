function Import-DGMRecipientData
{
    [cmdletbinding()]
    param (
        [parameter()]
        [int]$LimitEmailAddressCount = 65
        ,
        [parameter()]
        [ValidateSet('stagingRecipient', 'stagingDistributionGroup', 'stagingDistributionGroupRole', 'stagingContact')]
        [string[]]$IncludeTable
        ,
        [parameter()]
        [string[]]$IncludeOrganization
        ,
        [switch]$NoTruncate
    )

    $Configuration = Get-DGMConfiguration -Default

    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name)"

    #cleanup staging tables
    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    $stagingTables = @(
        'stagingRecipient'
        'stagingDistributionGroup'
        'stagingDistributionGroupRole'
        'stagingContact'
    )

    #determine which tables to import
    if ($IncludeTable.count -lt 1)
    {
        $IncludeTable = $stagingTables
    }

    Write-PSFMessage -Level Verbose -Message "Processing import to tables $($stagingTables -join ', ')"

    #determine which orgs to process
    $OrgsToProcess = @(
        switch ($IncludeOrganization.count)
        {
            {$_ -ge 1}
            {$Configuration.Organizations.where({$_.name -in $IncludeOrganization})}
            Default
            {$Configuration.Organizations}
        }
    )

    Write-PSFMessage -Level Verbose -Message "Processing import to for configured organizations $($OrgsToProcess.Name -join ', ')"

    #Truncate/Clean old data from staging tables selected
    if ($False -eq $NoTruncate)
    {
        Write-PSFMessage -Level Verbose -Message "Truncating tables $($stagingTables -join ', ')"
        foreach ($t in $IncludeTable)
        {
            $null = Invoke-DbaQuery @dbParams -query "TRUNCATE TABLE $t"
        }
    }

    $oTotalCount = $OrgsToProcess.count
    $oCount = 0
    foreach ($o in $OrgsToProcess)
    {
        $oCount++
        Write-Progress -Activity 'Importing Exchange Recipient Data' -CurrentOperation $o.Name -Status "Organization $oCount of $oTotalCount" -Id 0
        $rFile = $(Get-ChildItem -path $Configuration.DataFolderPath -filter $($o.Name + 'ExchangeRecipients' + '*.xml') |
            Sort-Object -Property Name -Descending |
            Select-Object -First 1
        )
        if ($null -ne $rFile)
        {
            Write-PSFMessage -Level Verbose -Message "Processing File $($rFile.name)"
            $orgRecipientData = Import-Clixml -Path $rFile.FullName
            $tCount = 0
            foreach ($t in $IncludeTable)
            {
                $tCount++
                Write-Progress -Activity "Importing to table $t" -CurrentOperation $() -Status "Import $tCount of $($IncludeTable.count)" -Id 1 -ParentId 0
                $tableParams = @{
                    Table = $t
                }

                $Columns = @(
                    @(Get-DbaDbTable @dbParams @tableParams).Columns.name
                )
                $ColumnMap = @{ }
                $Columns.foreach( {
                        $ColumnMap.$_ = $_
                    })

                switch ($t)
                {
                    'stagingRecipient'
                    {
                        if ($null -ne $orgRecipientData.Recipient -and $orgRecipientData.Recipient.count -ge 1)
                        {
                            #columns that need special handling in stagingRecipient
                            $CustomColumns = @(
                                'SourceOrganization'
                                'ExchangeGuid'
                                'ExchangeObjectId'
                                'Guid'
                                'EmailAddresses'
                                'ExternalEmailAddress'
                            )

                            $Properties = @(
                                @{n='SourceOrganization'; e={$($o.Name)}}
                                @{n='ExchangeGuid'; e={$_.ExchangeGuid.Guid}}
                                @{n='ExchangeObjectId'; e={$_.ExchangeObjectId.Guid}}
                                @{n='Guid'; e={$_.Guid.Guid}}
                                $Columns.where( { $_ -notin $CustomColumns })
                                @{n='ExternalEmailAddress'; e={
                                        if ($_.ExternalEmailAddress.length -ge 1)
                                        {$_.ExternalEmailAddress.split(':')[1]}
                                    }
                                }
                                @{n='EmailAddresses'; e={$_.EmailAddresses[0..$LimitEmailAddressCount] -join ';'}}
                            )

                            $orgRecipientData.Recipient |
                            Select-Object -Property $Properties |
                            ConvertTo-DbaDataTable |
                            Write-DbaDataTable @dbparams @tableParams -ColumnMap $ColumnMap
                        }
                    }
                    'stagingDistributionGroup'
                    {
                        if ($null -ne $orgRecipientData.DistributionGroup -and $orgRecipientData.DistributionGroup.count -ge 1)
                        {
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
                                @{n='EmailAddresses'; e={$_.EmailAddresses[0..$LimitEmailAddressCount] -join ';'}}
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

                            $orgRecipientData.DistributionGroup |
                            Select-Object -Property $Properties |
                            ConvertTo-DbaDataTable |
                            Write-DbaDataTable @dbparams @tableParams -ColumnMap $ColumnMap
                        }
                    }
                    'stagingDistributionGroupRole'
                    {
                        $DistributionGroupRoles = @(
                            'DistributionGroupMember',
                            'DistributionGroupManagedBy',
                            'DistributionGroupModeratedBy',
                            'DistributionGroupAcceptMessagesOnlyFrom',
                            'DistributionGroupBypassModeration',
                            'DistributionGroupGrantSendOnBehalfTo',
                            'DistributionGroupRejectMessagesFrom'
                        )
                        foreach ($r in $DistributionGroupRoles)
                        {
                            if ($null -ne $orgRecipientData.$r -and $orgRecipientData.$r.count -ge 1)
                            {
                                #columns that need special handling in stagingDistributionGroupRole
                                $CustomColumns = @(
                                    'SourceOrganization'
                                    'ExchangeGuid'
                                    'Guid'
                                )

                                $Properties = @(
                                    @{n='SourceOrganization'; e={$o.Name}}
                                    @{n='ExchangeGuid'; e={$_.ExchangeGuid.Guid}}
                                    @{n='Guid'; e={$_.Guid.Guid}}
                                    $Columns.where( { $_ -notin $CustomColumns })
                                )

                                $orgRecipientData.$r |
                                Select-Object -Property $Properties |
                                ConvertTo-DbaDataTable |
                                Write-DbaDataTable @dbparams @tableParams -ColumnMap $ColumnMap
                            }
                        }
                    }
                    'stagingContact'
                    {
                        if ($null -ne $orgRecipientData.Contact -and $orgRecipientData.Contact.count -ge 1)
                        {
                            #columns that need special handling in stagingRecipient
                            $CustomColumns = @(
                                'SourceOrganization'
                                'ExchangeObjectId'
                                'Guid'
                                'EmailAddresses'
                                'ExternalEmailAddress'
                                'Description'
                                'UMDtmfMap'
                                'AcceptMessagesOnlyFromSendersOrMembers'
                                'RejectMessagesFromSendersOrMembers'
                                'AddressListMembership'
                                'GrantSendOnBehalfTo'
                                'ManagedBy'
                                'ModeratedBy'
                                'BypassModerationFromSendersOrMembers'
                                @(1..5).foreach({
                                        "ExtensionCustomAttribute$($_)"
                                    })
                            )

                            $Properties = @(
                                @{n='SourceOrganization'; e={$o.Name}}
                                @{n='ExchangeObjectId'; e={$_.ExchangeObjectId.Guid}}
                                @{n='Guid'; e={$_.Guid.Guid}}
                                $Columns.where( { $_ -notin $CustomColumns })
                                @{n='ExternalEmailAddress'; e={
                                        if ($_.ExternalEmailAddress.length -ge 1)
                                        {$_.ExternalEmailAddress.split(':')[1]}
                                    }
                                }
                                @{n='EmailAddresses'; e={$_.EmailAddresses[0..$LimitEmailAddressCount] -join ';'}}
                                @{n='Description'; e={$_.Description -join ';'}}
                                @{n='UMDtmfMap'; e={$_.UMDtmfMap -join ';'}}
                                @{n='AcceptMessagesOnlyFromSendersOrMembers'; e={$_.AcceptMessagesOnlyFromSendersOrMembers -join ';'}}
                                @{n='RejectMessagesFromSendersOrMembers'; e={$_.RejectMessagesFromSendersOrMembers -join ';'}}
                                @{n='AddressListMembership'; e={$_.AddressListMembership -join ';'}}
                                @{n='GrantSendOnBehalfTo'; e={$_.GrantSendOnBehalfTo -join ';'}}
                                @{n='ManagedBy'; e={$_.ManagedBy -join ';'}}
                                @{n='ModeratedBy'; e={$_.ModeratedBy -join ';'}}
                                @{n='BypassModerationFromSendersOrMembers'; e={$_.BypassModerationFromSendersOrMembers -join ';'}}
                                @{n='ExtensionCustomAttribute1'; e={$_.ExtensionCustomAttribute1 -join ';'}}
                                @{n='ExtensionCustomAttribute2'; e={$_.ExtensionCustomAttribute2 -join ';'}}
                                @{n='ExtensionCustomAttribute3'; e={$_.ExtensionCustomAttribute3 -join ';'}}
                                @{n='ExtensionCustomAttribute4'; e={$_.ExtensionCustomAttribute4 -join ';'}}
                                @{n='ExtensionCustomAttribute5'; e={$_.ExtensionCustomAttribute5 -join ';'}}
                            )

                            $orgRecipientData.Contact |
                            Select-Object -Property $Properties |
                            ConvertTo-DbaDataTable |
                            Write-DbaDataTable @dbparams @tableParams -ColumnMap $ColumnMap
                        }
                    }
                }
            }
        }
    }
    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"
}