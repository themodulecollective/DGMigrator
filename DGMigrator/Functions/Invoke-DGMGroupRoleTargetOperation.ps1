function Invoke-DGMGroupRoleTargetOperation
{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(Mandatory, ParameterSetName = 'IncludeRoleType')]
        [ValidateSet(
            'AcceptMessagesOnlyFrom',
            'BypassModeration',
            'GrantSendOnBehalfTo',
            'RejectMessagesFrom',
            'ModeratedBy',
            'ManagedBy',
            'MemberOf'
        )]
        [string[]]$IncludeRoleType
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

    $query = "SELECT * FROM qIDistributionGroupRole"

    Write-PSFMessage -level Verbose -Message "Running query $query"
    $iqParams.query = $query
    $rolesToProcess = @(Invoke-DbaQuery @iqParams)
    Write-PSFMessage -level Verbose -Message "Retrieved $($rolesToProcess.count) Roles for Target Operation"
    switch ($PSCmdlet.ParameterSetName)
    {
        'All'
        {
            #nothing to do here - all roles included
        }
        'IncludeRoleType'
        {
            $rolesToProcess = @($rolesToProcess.where({$_.Role -in $IncludeRoleType}))
            Write-PSFMessage -level Verbose -Message "IncludeRoleType was specified with the following roles: $($IncludeRoleType -join ',')"
            Write-PSFMessage -level Verbose -Message "Filtered Roles to $($rolesToProcess.count) Included Roles for Target Operation."
        }
    }


    $actionDistributionGroupRole = @(
        @(Get-DbaDbTable @dbParams -table 'actionsDistributionGroupRole').Columns.name
    )

    #Write-Progress Setup
    $oCount = 0
    $oTotalCount = $targetOrgs.count
    $rTotalCount = $rolesToProcess.count


    $Results = @(
        #write-progress setup for role process
        $rCount = 0
        foreach ($r in $rolesToProcess)
        {
            $rCount++
            $rWPParams = @{
                Activity        = "Group Role Processing for Target Organization"
                Status          = "Role $rCount of $rTotalCount"
                PercentComplete = $rCount/$rTotalCount * 100
                ID              = 1
            }
            Write-Progress @rWPParams

            #variables re-used each loop
            $outcome = $false
            $actionError = $null

            $roleOpParams =
            @{
                ErrorAction   = 'Stop'
                WarningAction = 'SilentlyContinue'
                Confirm       = $false
                Identity      =  $r.TargetGroupExternalDirectoryObjectID
            }
            try
            {
                switch ($r.role)
                {
                    'MemberOf'
                    {
                        $roleOpParams.Member = $r.ExternalDirectoryObjectID
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                Write-PSFMessage -level Verbose -Message "Add-DistributionGroupMember $($roleOpParams | ConvertTo-Json -compress)"
                                Add-DistributionGroupMember @roleOpParams
                            }
                            'DeleteFromTarget'
                            {
                                Write-PSFMessage -level Verbose -Message "Remove-DistributionGroupMember $($roleOpParams | ConvertTo-Json -compress)"
                                Remove-DistributionGroupMember @roleOpParams
                            }
                        }
                        $outcome = $true
                    }
                    'ManagedBy'
                    {
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                $roleOpParams.ManagedBy = @{add ="$($r.ExternalDirectoryObjectID)"}

                            }
                            'DeleteFromTarget'
                            {
                                $roleOpParams.ManagedBy = @{remove ="$($r.ExternalDirectoryObjectID)"}
                            }
                        }
                    }
                    'ModeratedBy'
                    {
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                $roleOpParams.ModeratedBy = @{add ="$($r.ExternalDirectoryObjectID)"}

                            }
                            'DeleteFromTarget'
                            {
                                $roleOpParams.ModeratedBy = @{remove ="$($r.ExternalDirectoryObjectID)"}
                            }
                        }
                    }
                    'AcceptMessagesOnlyFrom'
                    {
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                $roleOpParams.AcceptMessagesOnlyFromSendersOrMembers = @{add ="$($r.ExternalDirectoryObjectID)"}

                            }
                            'DeleteFromTarget'
                            {
                                $roleOpParams.AcceptMessagesOnlyFromSendersOrMembers = @{remove ="$($r.ExternalDirectoryObjectID)"}
                            }
                        }
                    }
                    'BypassModeration'
                    {
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                $roleOpParams.BypassModerationFromSendersOrMembers = @{add ="$($r.ExternalDirectoryObjectID)"}

                            }
                            'DeleteFromTarget'
                            {
                                $roleOpParams.BypassModerationFromSendersOrMembers = @{remove ="$($r.ExternalDirectoryObjectID)"}
                            }
                        }
                    }
                    'GrantSendOnBehalfTo'
                    {
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                $roleOpParams.GrantSendOnBehalfTo = @{add ="$($r.ExternalDirectoryObjectID)"}

                            }
                            'DeleteFromTarget'
                            {
                                $roleOpParams.GrantSendOnBehalfTo = @{remove ="$($r.ExternalDirectoryObjectID)"}
                            }
                        }
                    }
                    'RejectMessagesFrom'
                    {
                        switch ($r.Action)
                        {
                            'AddToTarget'
                            {
                                $roleOpParams.RejectMessagesFromSendersOrMembers = @{add ="$($r.ExternalDirectoryObjectID)"}

                            }
                            'DeleteFromTarget'
                            {
                                $roleOpParams.RejectMessagesFromSendersOrMembers = @{remove ="$($r.ExternalDirectoryObjectID)"}
                            }
                        }

                    }
                }
                if ($r.Role -ne 'MemberOf') #everything but memberOf
                {
                    switch ($Configuration.MigrationSettings.DelayManagedBy -and $r.Role -eq 'ManagedBy')
                    {
                        $true # role is ManagedBy but delayManagedBy is configured
                        {
                            #Do nothing since we don't set ManagedBy yet
                        }
                        $false
                        {
                            Write-PSFMessage -level Verbose -Message "Set-DistributionGroup $($roleOpParams | ConvertTo-Json -compress)"
                            Set-DistributionGroup @roleOpParams
                            $outcome = $true
                        }
                    }
                }
            }
            catch
            {
                $actionError = $_.tostring()
                Write-PSFMessage -level Verbose -Message $actionError
            }


            $WhenAction = Get-Date (Get-Date).ToUniversalTime() #-Format "yyyy-MM-dd hh:mm:ss"
            #columns that need special handling in stagingRecipient
            $CustomColumns = @(
                'WhenAction'
                'ActionResult'
                'ActionError'
                'ActionNote'
            )

            $Properties = @(
                $actionDistributionGroupRole.where( { $_ -notin $CustomColumns })
                @{n='WhenAction'; e={$WhenAction}}
                @{n='ActionResult'; e={$outcome}}
                @{n='ActionError'; e={$actionError}}
                @{n='ActionNote'; e={''}}
            )

            $r | Select-Object -Property $Properties

        }
    )

    $ColumnMap = @{ }
    $actionDistributionGroupRole.foreach( {
            $ColumnMap.$_ = $_
        })

    Write-PSFMessage -Level Verbose -Message "Writing $($Results.count) operation results to actionsDistributionGroupRole table."

    if ($Results.count -ge 1)
    {
        $Results | ConvertTo-DbaDataTable | Write-DbaDataTable -ColumnMap $ColumnMap @dbParams -Table 'actionsDistributionGroupRole'
    }

    Disconnect-ExchangeOnline -Confirm:$False

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"

}