function Invoke-DGMContactTargetOperation
{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(ParameterSetName = 'Specified', Mandatory)]
        [string[]]$ExternalDirectoryObjectID
    )

    $Configuration = Get-DGMConfiguration -Default

    #TargetOrganizationSettings
    $o = $($Configuration.Organizations.where({$_.MigrationRole -eq 'Target'}))
    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name) for target organization $($o.Name)"

    if ($null -ne $o.Credential)
    {
        $Credential = Import-Clixml -Path $o.Credential
        Connect-ExchangeOnline -Credential $Credential
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
            switch ($Configuration.ContactsToIgnore.Count)
            {
                0
                {
                    $query = "SELECT * FROM qIContact WHERE Action = 'AddToTarget'"
                }
                Default
                {
                    $query = "SELECT * FROM qIContact WHERE Action = 'AddToTarget' AND ExternalDirectoryObjectID NOT IN ($($Configuration.ContactsToIgnore.foreach({"'$_'"}) -join ","))"
                }
            }
        }
        'Specified'
        {
            $query = "SELECT * FROM qIContact WHERE Action = 'AddToTarget' AND ExternalDirectoryObjectID IN ($($ExternalDirectoryObjectID.foreach({"'$_'"}) -join ","))"
        }
    }

    Write-PSFMessage -level Verbose -Message "Running query $query"
    $iqParams.query = $query
    $addToTarget = @(Invoke-DbaQuery @iqParams)
    Write-PSFMessage -level Verbose -Message "Processing $($addToTarget.count) Contacts for operation AddToTarget"
    $actionsContactColumns = @(
        @(Get-DbaDbTable @dbParams -table 'actionsContact').Columns.name
    )

    $Results = @(
        #write-progress setup for addtotarget
        $cCount = 0
        $cTotalCount = $addToTarget.count
        foreach ($ic in $addToTarget)
        {
            $cCount++
            $cWPParams = @{
                Activity        = "Add Contacts to Target Organization"
                Status          = "Contacts $cCount-$($cCount+99) of $cTotalCount"
                PercentComplete = $cCount/$cTotalCount * 100
                ID              = 1
            }

            if (($cCount % 100) -eq 1)
            {
                Write-Progress @cWPParams
            }

            #variables re-used each loop
            $outcome = $false
            $actionError = $null

            $newCParams =
            @{
                ErrorAction                 = 'Stop'
                WarningAction               = 'SilentlyContinue'
                Confirm                     = $false
                Alias                       = $ic.Alias
                DisplayName                 = $ic.DisplayName
                ExternalEmailAddress        = $ic.ExternalEmailAddress
                #ModeratedBy = $ic.ModeratedBy - will need a lookup query
                #ModerationEnabled             = $ic.ModerationEnabled - Enable after Moderated By is set
                Name                        = $ic.Name
                SendModerationNotifications = $ic.SendModerationNotifications
            }

            try
            {
                Write-PSFMessage -level Verbose -Message "New-MailContact $($newCParams | ConvertTo-Json -compress)"
                $tC = New-MailContact @newCParams
            }
            catch
            {
                $actionError = $_.tostring()
                Write-PSFMessage -level Verbose -Message $actionError
            }

            if ($null -ne $tC)
            {
                $setCParams =
                @{
                    ErrorAction                        = 'Stop'
                    WarningAction                      = 'SilentlyContinue'
                    Identity                           = $tC.ExternalDirectoryObjectID
                    #AcceptMessagesOnlyFromSendersOrMembers = $ic.AcceptMessagesOnlyFromSendersOrMembers - lookup
                    #BypassModerationFromSendersOrMembers = $ic.BypassModerationFromSendersOrMembers - lookup
                    CustomAttribute1                   = $ic.CustomAttribute1
                    CustomAttribute10                  = $ic.CustomAttribute10
                    CustomAttribute11                  = $ic.CustomAttribute11
                    CustomAttribute12                  = $ic.CustomAttribute12
                    CustomAttribute13                  = $ic.CustomAttribute13
                    CustomAttribute14                  = $ic.CustomAttribute14
                    CustomAttribute15                  = $ic.CustomAttribute15
                    CustomAttribute2                   = $ic.CustomAttribute2
                    CustomAttribute3                   = $ic.CustomAttribute3
                    CustomAttribute4                   = $ic.CustomAttribute4
                    CustomAttribute5                   = $ic.CustomAttribute5
                    CustomAttribute6                   = $ic.CustomAttribute6
                    CustomAttribute7                   = $ic.CustomAttribute7
                    CustomAttribute8                   = $ic.CustomAttribute8
                    CustomAttribute9                   = $ic.CustomAttribute9
                    EmailAddresses                     = @{add = $ic.EmailAddresses}
                    #GrantSendOnBehalfTo = $ic.GrantSendOnBehalfTo - lookup
                    HiddenFromAddressListsEnabled      = $ic.HiddenFromAddressListsEnabled
                    MailTip                            = $ic.MailTip
                    #MailTipTranslations = $ic.MailTipTranslations - need a multivalue lookup approach
                    #RejectMessagesFromSendersOrMembers = $ic.RejectMessagesFromSendersOrMembers - lookup
                    RequireSenderAuthenticationEnabled = $ic.RequireSenderAuthenticationEnabled
                    SimpleDisplayName                  = $ic.SimpleDisplayName
                    UseMapiRichTextFormat              = $ic.UseMapiRichTextFormat
                }

                try
                {
                    #may need a delay here
                    Write-PSFMessage -level Verbose -Message "Set-MailContact $($setCParams | ConvertTo-Json -compress)"
                    Set-MailContact @setCParams
                    $outcome = $true
                }
                catch
                {
                    $actionError = $_.tostring()
                    Write-PSFMessage -level Verbose -Message $actionError
                    Remove-MailContact -Identity $tc.ExternalDirectoryObjectID
                }
            }

            $WhenAction = Get-Date (Get-Date).ToUniversalTime() #-Format "yyyy-MM-dd hh:mm:ss"
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
                'WhenAction'
                'ActionResult'
                'ActionError'
                'ActionNote'
                'LastExchangeChangedTime'
                @(1..5).foreach({
                        "ExtensionCustomAttribute$($_)"
                    })
            )

            $Properties = @(
                @{n='SourceOrganization'; e={$ic.SourceOrganization}}
                @{n='ExchangeObjectId'; e={$_.ExchangeObjectId.Guid}}
                @{n='Guid'; e={$_.Guid.Guid}}
                $actionsContactColumns.where( { $_ -notin $CustomColumns })
                @{n='ExternalEmailAddress'; e={
                        if ($_.ExternalEmailAddress.length -ge 1)
                        {$_.ExternalEmailAddress.split(':')[1]}
                    }
                }
                @{n='EmailAddresses'; e={$_.EmailAddresses -join ';'}}
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
                @{n='LastExchangeChangedTime'; e={''}}
                @{n='WhenAction'; e={$WhenAction}}
                @{n='ActionResult'; e={$outcome}}
                @{n='ActionError'; e={$actionError}}
                @{n='ActionNote'; e={''}}
            )

            switch ($outcome)
            {
                $true
                {
                    $tC = Get-MailContact -Identity $tc.ExternalDirectoryObjectID
                    $tC | Select-Object -Property $Properties
                }
                $false
                {
                    $ic | Select-Object -Property $Properties
                }
            }

        }
    )


    $ColumnMap = @{ }
    $actionsContactColumns.foreach( {
            $ColumnMap.$_ = $_
        })

    Write-PSFMessage -Level Verbose -Message "Writing $($Results.count) operation results to actionsContact table."

    if ($Results.count -ge 1)
    {
        $Results | ConvertTo-DbaDataTable | Write-DbaDataTable -ColumnMap $ColumnMap @dbParams -Table 'actionsContact'
    }

    Disconnect-ExchangeOnline -Confirm:$False

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"

}