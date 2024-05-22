function Invoke-DGMGroupTargetAddOperation
{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(ParameterSetName = 'Nesting', Mandatory)]
        $NestingArray
        ,
        [parameter(ParameterSetName = 'Nesting', Mandatory)]
        $NestingLevel
        ,
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
        'Scoped'
        {
            $query = "SELECT * FROM qIDistributionGroup WHERE Action = 'AddToTarget' AND ExternalDirectoryObjectID IN ($($ExternalDirectoryObjectID.foreach({"'$_'"}) -join ","))"
        }
        Default
        {
            switch ($Configuration.DistributionGroupsToIgnore.Count)
            {
                0
                {
                    $query = "SELECT * FROM qIDistributionGroup WHERE Action = 'AddToTarget'"
                }
                Default
                {
                    $query = "SELECT * FROM qIDistributionGroup WHERE Action = 'AddToTarget' AND ExternalDirectoryObjectID NOT IN ($($Configuration.DistributionGroupsToIgnore.foreach({"'$_'"}) -join ","))"
                }
            }
        }
    }

    Write-PSFMessage -level Verbose -Message "Running query $query"
    $addToTarget = @(Invoke-DbaQuery @iqParams -query $query)
    Write-PSFMessage -level Verbose -Message "Found $($addToTarget.count) staging Distribution Groups for operation AddToTarget"

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nesting'
        {
            $NestingIDs = @($NestingArray.where({$_.value -eq $NestingLevel}).Name)
            Write-PSFMessage -level Verbose -Message "Processing Nesting Mode. Filtering Groups for Nesting Level $NestingLevel"
            $addToTarget = $addToTarget.where({$_.ExternalDirectoryObjectID -in $NestingIDs})
            Write-PSFMessage -level Verbose -Message "Found $($addToTarget.count) Distribution Groups for Nesting Level $NestingLevel operation AddToTarget"
        }
        'Scoped'
        {
            Write-PSFMessage -level Verbose -Message "Processing Scoped Mode. Filtering Groups for specified ExternalDirectoryObjectID"
            $addToTarget = $addToTarget.where({$_.ExternalDirectoryObjectID -in $ExternalDirectoryObjectID})
            Write-PSFMessage -level Verbose -Message "Found $($addToTarget.count) Distribution Groups for Scoped operation AddToTarget"

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
        $gTotalCount = $addToTarget.count
        $gCount = 0
        foreach ($ig in $addToTarget)
        {
            $gCount++
            $gWPParams = @{
                Activity        = "Add Groups to Target Organization"
                Status          = "Group $gCount of $gTotalCount"
                PercentComplete = $gCount/$gTotalCount * 100
                ID              = 1
            }

            Write-Progress @gWPParams

            #variables re-used each loop
            $outcome = $false
            $actionError = $null
            $tg = $null

            $newDGParams =
            @{
                ErrorAction                        = 'Stop'
                WarningAction                      = 'SilentlyContinue'
                Alias                              = $ig.Alias
                ByPassNestedModerationEnabled      = $ig.ByPassNestedModerationEnabled
                DisplayName                        = $ig.DisplayName
                IgnoreNamingPolicy                 = $true
                MemberDepartRestriction            = $ig.MemberDepartRestriction
                MemberJoinRestriction              = $ig.MemberJoinRestriction
                Members                            = Invoke-DGMGroupRoleQuery -Role 'MemberOf' -GroupIdentity $ig.ExternalDirectoryObjectID
                Name                               = $ig.Name
                PrimarySmtpAddress                 = $ig.PrimarySmtpAddress
                RequireSenderAuthenticationEnabled = $ig.RequireSenderAuthenticationEnabled
                type                               = $ig.RecipientTypeDetails.foreach({switch ($_){'MailUniversalDistributionGroup'{'Distribution'} 'MailUniversalSecurityGroup' {'Security'}}})
                SendModerationNotifications        = $ig.SendModerationNotifications
            }
            switch ($Configuration.MigrationSettings.DelayManagedBy)
            {
                $false
                {
                    $newDGParams.ManagedBy = @(Invoke-DGMGroupRoleQuery -Role 'ManagedBy' -GroupIdentity $ig.ExternalDirectoryObjectID)
                }
            }
            try
            {
                Write-PSFMessage -level Verbose -message "Members Are: $($newDGParams.Members -join ',')"
                Write-PSFMessage -level Verbose -Message "New-DistributionGroup $($newDGParams | ConvertTo-Json -compress)"
                $tg = New-DistributionGroup @newDGParams
            }
            catch
            {
                $actionError = $_.tostring()
                Write-PSFMessage -level Verbose -Message $actionError
            }

            if ($null -ne $tg)
            {
                $setDGParams =
                @{
                    ErrorAction                            = 'Stop'
                    WarningAction                          = 'SilentlyContinue'
                    Identity                               = $tg.ExternalDirectoryObjectID
                    AcceptMessagesOnlyFromSendersOrMembers = Invoke-DGMGroupRoleQuery -Role 'AcceptMessagesOnlyFrom' -GroupIdentity $ig.ExternalDirectoryObjectID
                    BypassModerationFromSendersOrMembers   = Invoke-DGMGroupRoleQuery -Role 'BypassModeration' -GroupIdentity $ig.ExternalDirectoryObjectID
                    CustomAttribute1                       = $ig.CustomAttribute1
                    CustomAttribute10                      = $ig.CustomAttribute10
                    CustomAttribute11                      = $ig.CustomAttribute11
                    CustomAttribute12                      = $ig.CustomAttribute12
                    CustomAttribute13                      = $ig.CustomAttribute13
                    CustomAttribute14                      = $ig.CustomAttribute14
                    CustomAttribute15                      = $ig.CustomAttribute15
                    CustomAttribute2                       = $ig.CustomAttribute2
                    CustomAttribute3                       = $ig.CustomAttribute3
                    CustomAttribute4                       = $ig.CustomAttribute4
                    CustomAttribute5                       = $ig.CustomAttribute5
                    CustomAttribute6                       = $ig.CustomAttribute6
                    CustomAttribute7                       = $ig.CustomAttribute7
                    CustomAttribute8                       = $ig.CustomAttribute8
                    CustomAttribute9                       = $ig.CustomAttribute9
                    EmailAddresses                         = @{add =$ig.EmailAddresses}
                    GrantSendOnBehalfTo                    = Invoke-DGMGroupRoleQuery -Role 'GrantSendOnBehalfTo' -GroupIdentity $ig.ExternalDirectoryObjectID
                    HiddenFromAddressListsEnabled          = $ig.HiddenFromAddressListsEnabled
                    MailTip                                = $ig.MailTip
                    #MailTipTranslations = $ig.MailTipTranslations - need a multivalue lookup approach
                    RejectMessagesFromSendersOrMembers     = Invoke-DGMGroupRoleQuery -Role 'RejectMessagesFrom' -GroupIdentity $ig.ExternalDirectoryObjectID
                    ReportToManagerEnabled                 = $ig.ReportToManagerEnabled
                    ReportToOriginatorEnabled              = $ig.ReportToOriginatorEnabled
                    SendOofMessageToOriginatorEnabled      = $ig.SendOofMessageToOriginatorEnabled
                    SimpleDisplayName                      = $ig.SimpleDisplayName
                    #UMDtmfMap = $ig.UMDtmfMap - need a multivalue lookup approach
                    ModeratedBy                            = Invoke-DGMGroupRoleQuery -Role 'ModeratedBy' -GroupIdentity $ig.ExternalDirectoryObjectID
                    ModerationEnabled                      = $ig.ModerationEnabled
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
                    if ($null -ne $tg)
                    {
                        Write-PSFMessage -level Verbose -Message "Removing Distribution Group $($tg.ExternalDirectoryObjectID) due to failed 'Set-DistributionGroup' command."
                        Remove-DistributionGroup -Identity $tg.ExternalDirectoryObjectID -confirm:$false
                    }
                }
            }

            $WhenAction = Get-Date (Get-Date).ToUniversalTime() #-Format "yyyy-MM-dd hh:mm:ss"
            #columns that need special handling in stagingRecipient
            #columns that need special handling in stagingRecipient
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
                @{n='SourceOrganization'; e={$ig.SourceOrganization}}
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
                    $ig | Select-Object -Property $Properties
                }
            }
        }
    )

    $ColumnMap = @{ }
    $actionsDistributionGroupColumns.foreach( {
            $ColumnMap.$_ = $_
        })

    Write-PSFMessage -Level Verbose -Message "Writing $($Results.count) operation results to actionsDistributionGroup table."
    if ($Results.count -ge 1)
    {
        $Results | ConvertTo-DbaDataTable | Write-DbaDataTable -ColumnMap $ColumnMap @dbParams -Table 'actionsDistributionGroup'
    }

    Disconnect-ExchangeOnline -Confirm:$False
}