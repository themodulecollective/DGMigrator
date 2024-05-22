function Invoke-DGMGroupTargetUpdateOperation
{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(ParameterSetName = 'Scoped')]
        [string[]]$ExternalDirectoryObjectID
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

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        as          = 'PSObject'
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'All'
        {
            switch ($Configuration.DistributionGroupsToIgnore.Count)
            {
                0
                {
                    $query = "SELECT * FROM qSDistributionGroup WHERE Action = 'UpdateInTarget'"
                }
                Default
                {
                    $query = "SELECT * FROM qSDistributionGroup WHERE Action = 'UpdateInTarget' AND ExternalDirectoryObjectID NOT IN ($($Configuration.DistributionGroupsToIgnore.foreach({"'$_'"}) -join ","))"
                }
            }
        }
        'Scoped'
        {
            $query = "SELECT * FROM qSDistributionGroup WHERE Action = 'UpdateInTarget' AND ExternalDirectoryObjectID IN ($($ExternalDirectoryObjectID.foreach({"'$_'"}) -join ","))"
        }
    }


    Write-PSFMessage -level Verbose -Message "Running query $query"
    $updateInTarget = @(Invoke-DbaQuery @iqParams -query $query)
    Write-PSFMessage -level Verbose -Message "Found $($updateInTarget.count) staging Distribution Groups for operation UpdateInTarget"

    switch ($PSCmdlet.ParameterSetName)
    {
        'Scoped'
        {
            Write-PSFMessage -level Verbose -Message "Processing Scoped Mode. Filtering Groups for specified ExternalDirectoryObjectID"
            $updateInTarget = $updateInTarget.where({$_.ExternalDirectoryObjectID -in $ExternalDirectoryObjectID})
            Write-PSFMessage -level Verbose -Message "Found $($updateInTarget.count) Distribution Groups for Scoped operation AddToTarget"
        }
        'All'
        {
            #nothing to do here as the $addToTarget already contains all groups from stagingQ table
        }
    }

    $actionsDistributionGroupColumns = @(
        @(Get-DbaDbTable @dbParams -table 'actionsDistributionGroup').Columns.name
    )



    $Results = @(
        #write-progress setup for addtotarget
        $gTotalCount = $updateInTarget.count
        $gCount = 0
        $uGCount = 0
        foreach ($iG in $updateInTarget)
        {
            $gCount++
            $gWPParams = @{
                Activity        = "Update Groups in Target Organization"
                Status          = "Group $gCount of $gTotalCount"
                PercentComplete = $gCount/$gTotalCount * 100
                ID              = 1
            }

            Write-Progress @gWPParams

            #variables re-used each loop
            $outcome = $false
            $actionError = $null
            $hG = Get-DGMhistoryDistributionGroup -Identity $iG.ExternalDirectoryObjectID

            $suppressedProperties = @(
                'Action'
                'TargetOrganization'
                'WhenChangedUTC'
                'UMDtmfMap'
                'AcceptMessagesOnlyFromSendersOrMembers'
                'BypassModerationFromSendersOrMembers'
                'GrantSendOnBehalfTo'
                'ManagedBy'
                'ModeratedBy'
                'RejectMessagesFrom'
                'EmailAddresses'
                'AddressListMembership'
                'PrimarySMTPAddress'
            )

            $updatedProperties = @(Compare-ComplexObject -ReferenceObject $hG -DifferenceObject $iG -SuppressedProperties $suppressedProperties -Show DifferentOnly)

            if ($updatedProperties.count -ge 1)
            {

                Write-PSFMessage -level Verbose -Message "Distribution Group $($iG.ExternalDirectoryObjectID) has $($updatedProperties.count) updated properties."
                Write-PSFMessage -level Verbose -Message "Retrieve Target Group for $($iG.ExternalDirectoryObjectID)."
                $tG = Get-DGMstagingDistributionGroup -Identity $iG.ExternalDirectoryObjectID -TargetGroup
                $uGCount++

                $setDGParams = @{
                    Identity      = $tG.ExternalDirectoryObjectID
                    ErrorAction   = 'Stop'
                    WarningAction = 'SilentlyContinue'
                }

                foreach ($uP in $updatedProperties)
                {
                    $PropertyName = $uP.Property
                    switch -Wildcard ($PropertyName)
                    {
                        'ExtensionCustomAttribute*'
                        {
                            $setDGParams.$PropertyName = $uP.DifferenceObjectValue.split(';')
                        }
                        default
                        {
                            $setDGParams.$PropertyName = $uP.DifferenceObjectValue
                        }
                    }
                }
                try
                {
                    Write-PSFMessage -level Verbose -Message "Set-DistributionGroup $($setDGParams | ConvertTo-Json -compress)"
                    Set-DistributionGroup @setDGParams
                    $outcome = $true
                }
                catch
                {
                    $actionError = $_.tostring()
                    Write-PSFMessage -level Verbose -Message $actionError
                }

                $WhenAction = Get-Date (Get-Date).ToUniversalTime() #-Format "yyyy-MM-dd hh:mm:ss"

                #columns that need special handling
                $CustomColumns = @(
                    'SourceOrganization'
                    'ExchangeObjectId'
                    'Guid'
                    'EmailAddresses'
                    'Description'
                    'UMDtmfMap'
                    'AcceptMessagesOnlyFromSendersOrMembers'
                    'AddressListMembership'
                    'GrantSendOnBehalfTo'
                    'ManagedBy'
                    'WhenAction'
                    'ActionResult'
                    'ActionError'
                    'ActionNote'
                    @(1..5).foreach({
                            "ExtensionCustomAttribute$($_)"
                        })
                )

                $Properties = @(
                    @{n='SourceOrganization'; e={$iG.SourceOrganization}}
                    @{n='ExchangeObjectId'; e={$_.ExchangeObjectId.Guid}}
                    @{n='Guid'; e={$_.Guid.Guid}}
                    $actionsDistributionGroupColumns.where( { $_ -notin $CustomColumns })
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
                    @{n='WhenAction'; e={$WhenAction}}
                    @{n='ActionResult'; e={$outcome}}
                    @{n='ActionError'; e={$actionError}}
                    @{n='ActionNote'; e={''}}
                )

                switch ($outcome)
                {
                    $true
                    {
                        $tg = Get-DistributionGroup -Identity $tg.ExternalDirectoryObjectID
                        $tg | Select-Object -Property $Properties
                    }
                    $false
                    {
                        $iG | Select-Object -Property $Properties
                    }
                }
            }
            else
            {
                Write-PSFMessage -level Verbose -Message "Skipping Distribution Group $($iG.ExternalDirectoryObjectID). No non-role changes detected."
            }
        }
    )

    if ($Results.count -ge 1)
    {
        Write-PSFMessage -Level Verbose -Message "Writing $($Results.count) operation results to actionsDistributionGroup table."
        $ColumnMap = @{ }
        $actionsDistributionGroupColumns.foreach( {
                $ColumnMap.$_ = $_
            })
        $Results | ConvertTo-DbaDataTable | Write-DbaDataTable -ColumnMap $ColumnMap @dbParams -Table 'actionsDistributionGroup'
    }

    Disconnect-ExchangeOnline -confirm:$false

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"

}