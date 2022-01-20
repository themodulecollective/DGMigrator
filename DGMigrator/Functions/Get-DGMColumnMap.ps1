function Get-DGMColumnMap
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet(
            'historyContact',
            'historyDistributionGroupRole',
            'historyDistributionGroup',
            'qIContact',
            'qIDistributionGroupRole',
            'qIDistributionGroup',
            'qSContact',
            'qSDistributionGroupRole',
            'qSDistributionGroup',
            'stagingContact',
            'stagingDistributionGroupRole',
            'stagingDistributionGroup',
            'stagingRecipient',
            'actionsDistributionGroup',
            'actionsDistributionGroupRole',
            'actionsContact',
            'recipientMap',
            'stagingNLDistributionGroup',
            'configurationOrganization'
        )]
        $TableType
    )

    $ParentTypesToTableTypes = @{
        'historyContact'               = 'Contact'
        'historyDistributionGroupRole' = 'DistributionGroupRole'
        'historyDistributionGroup'     = 'DistributionGroup'
        'qIContact'                    = 'Contact'
        'qIDistributionGroupRole'      = 'DistributionGroupRole'
        'qIDistributionGroup'          = 'DistributionGroup'
        'qSContact'                    = 'Contact'
        'qSDistributionGroupRole'      = 'DistributionGroupRole'
        'qSDistributionGroup'          = 'DistributionGroup'
        'stagingContact'               = 'Contact'
        'stagingDistributionGroupRole' = 'DistributionGroupRole'
        'stagingDistributionGroup'     = 'DistributionGroup'
        'stagingRecipient'             = 'Recipient'
        'actionsDistributionGroup'     = 'DistributionGroup'
        'actionsDistributionGroupRole' = 'DistributionGroupRole'
        'actionsContact'               = 'Contact'
        'recipientMap'                 = 'recipientMap'
        'stagingNLDistributionGroup'   = 'DistributionGroup'
        'configurationOrganization'    = 'configurationOrganization'
    }

    $ParentType = $ParentTypesToTableTypes.$TableType

    if ($TableType -notin @('configurationOrganization'))
    {
        @{
            Name      = 'SourceOrganization'
            Type      = 'nvarchar'
            MaxLength = 64
            Nullable  = $true
        }
    }

    switch ($ParentType)
    {
        'Recipient'
        {
            @(
                $(@('ExchangeGuid', 'ExchangeObjectId', 'ExternalDirectoryObjectID', 'Guid').foreach(
                        {
                            @{
                                Name      = $_
                                Type      = 'nchar'
                                MaxLength = 36
                                Nullable  = $true
                            }
                        }))
                @{
                    Name      = 'Alias'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      = 'DisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'PrimarySmtpAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'ExternalEmailAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientType'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientTypeDetails'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                $(@(1..15).foreach(
                        {
                            @{
                                Name      = "CustomAttribute$($_)"
                                Type      = 'nvarchar'
                                MaxLength = 1024
                                Nullable  = $true
                            }
                        })
                )
                @{
                    Name      = 'Department'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'DistinguishedName'
                    Type      = 'nvarchar'
                    MaxLength = 1024
                    Nullable  = $true
                }
                @{
                    Name      = 'Manager'
                    Type      = 'nvarchar'
                    MaxLength = 1024
                    Nullable  = $true
                }
                @{
                    Name     = 'WhenCreatedUTC'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name     = 'WhenChangedUTC'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name      = 'EmailAddresses'
                    Type      = 'nvarchar'
                    MaxLength = 4000
                    Nullable  = $true
                }
            )
        }
        'DistributionGroup'
        {
            @(
                $(@('ExchangeObjectId', 'ExternalDirectoryObjectID', 'Guid').foreach(
                        {
                            @{
                                Name      = $_
                                Type      = 'nchar'
                                MaxLength = 36
                                Nullable  = $true
                            }
                        }))
                @{
                    Name      = 'Alias'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      = 'DisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'Name'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'PrimarySmtpAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'WindowsEmailAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientType'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientTypeDetails'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                $(@(1..15).foreach(
                        {
                            @{
                                Name      = "CustomAttribute$($_)"
                                Type      = 'nvarchar'
                                MaxLength = 1024
                                Nullable  = $true
                            }
                        })
                )
                $(@(1..5).foreach(
                        {
                            @{
                                Name      = "ExtensionCustomAttribute$($_)"
                                Type      = 'nvarchar'
                                MaxLength = 1024
                                Nullable  = $true
                            }
                        })
                )
                @{
                    Name      = 'Department'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'DistinguishedName'
                    Type      = 'nvarchar'
                    MaxLength = 1024
                    Nullable  = $true
                }
                @{
                    Name      = 'Manager'
                    Type      = 'nvarchar'
                    MaxLength = 1024
                    Nullable  = $true
                }
                @{
                    Name     = 'WhenCreatedUTC'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name     = 'WhenChangedUTC'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name     = 'LastExchangeChangedTime'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name      = 'EmailAddresses'
                    Type      = 'nvarchar'
                    MaxLength = 4000
                    Nullable  = $true
                }
                @{
                    Name      = 'Description'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      = 'UMDtmfMap'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name     ='BccBlocked'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='BypassNestedModerationEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='EmailAddressPolicyEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='HiddenFromAddressListsEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='HiddenGroupMembershipEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='ReportToManagerEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='ReportToOriginatorEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='RequireSenderAuthenticationEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='ModerationEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='SendOofMessageToOriginatorEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='IsDirSynced'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='IsValid'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='MigrationToUnifiedGroupInProgress'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name      ='SendModerationNotifications'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='LegacyExchangeDN'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='MailTip'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='MemberDepartRestriction'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='MemberJoinRestriction'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='GroupType'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='ObjectCategory'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='ObjectState'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='OrganizationalUnit'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='OrganizationalUnitRoot'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='OrganizationId'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='SimpleDisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='MaxReceiveSize'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='MaxSendSize'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='AcceptMessagesOnlyFromSendersOrMembers'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='BypassModerationFromSendersOrMembers'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='AddressListMembership'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='GrantSendOnBehalfTo'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='ManagedBy'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
            )
        }
        'DistributionGroupRole'
        {
            @(
                $(@('ExchangeGuid', 'ExternalDirectoryObjectID', 'Guid').foreach(
                        {
                            @{
                                Name      = $_
                                Type      = 'nchar'
                                MaxLength = 36
                                Nullable  = $true
                            }
                        }))
                @{
                    Name      = 'Alias'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      = 'DisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'PrimarySmtpAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientTypeDetails'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'Role'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $false
                }
                @{
                    Name      = 'TargetGroupGUID'
                    Type      = 'nchar'
                    MaxLength = 36
                    Nullable  = $true
                }
                @{
                    Name      = 'TargetGroupExternalDirectoryObjectID'
                    Type      = 'nchar'
                    MaxLength = 36
                    Nullable  = $true
                }
                @{
                    Name      = 'TargetGroupDisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'TargetGroupPrimarySmtpAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
            )
        }
        'Contact'
        {
            @(
                $(@('ExchangeObjectId', 'ExternalDirectoryObjectID', 'Guid').foreach(
                        {
                            @{
                                Name      = $_
                                Type      = 'nchar'
                                MaxLength = 36
                                Nullable  = $true
                            }
                        }))
                @{
                    Name      = 'Alias'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      = 'DisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'Name'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'ExternalEmailAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'PrimarySmtpAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'WindowsEmailAddress'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientType'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      = 'RecipientTypeDetails'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                $(@(1..15).foreach(
                        {
                            @{
                                Name      = "CustomAttribute$($_)"
                                Type      = 'nvarchar'
                                MaxLength = 1024
                                Nullable  = $true
                            }
                        })
                )
                $(@(1..5).foreach(
                        {
                            @{
                                Name      = "ExtensionCustomAttribute$($_)"
                                Type      = 'nvarchar'
                                MaxLength = 1024
                                Nullable  = $true
                            }
                        })
                )
                @{
                    Name      = 'DistinguishedName'
                    Type      = 'nvarchar'
                    MaxLength = 1024
                    Nullable  = $true
                }
                @{
                    Name      = 'Manager'
                    Type      = 'nvarchar'
                    MaxLength = 1024
                    Nullable  = $true
                }
                @{
                    Name     = 'WhenCreatedUTC'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name     = 'WhenChangedUTC'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name     = 'LastExchangeChangedTime'
                    Type     = 'DateTime'
                    Nullable = $true
                }
                @{
                    Name      = 'EmailAddresses'
                    Type      = 'nvarchar'
                    MaxLength = 4000
                    Nullable  = $true
                }
                @{
                    Name      = 'Description'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      = 'UMDtmfMap'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name     ='EmailAddressPolicyEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='HiddenFromAddressListsEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='RequireSenderAuthenticationEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='ModerationEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='SendOofMessageToOriginatorEnabled'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='IsDirSynced'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     ='IsValid'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name     = 'UsePreferMessageFormat'
                    Type     = 'bit'
                    Nullable = $true
                }
                @{
                    Name      ='SendModerationNotifications'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='LegacyExchangeDN'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='MailTip'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='ObjectCategory'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='ObjectState'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='OrganizationalUnit'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='OrganizationalUnitRoot'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='OrganizationId'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='SimpleDisplayName'
                    Type      = 'nvarchar'
                    MaxLength = 256
                    Nullable  = $true
                }
                @{
                    Name      ='MaxReceiveSize'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='MaxSendSize'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='AcceptMessagesOnlyFromSendersOrMembers'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='RejectMessagesFromSendersOrMembers'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='AddressListMembership'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='GrantSendOnBehalfTo'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='ManagedBy'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='ModeratedBy'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='BypassModerationFromSendersOrMembers'
                    Type      = 'nvarchar'
                    MaxLength = 2048
                    Nullable  = $true
                }
                @{
                    Name      ='MacAttachmentFormat'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='MessageBodyFormat'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
                @{
                    Name      ='UseMapiRichTextFormat'
                    Type      = 'nvarchar'
                    MaxLength = 64
                    Nullable  = $true
                }
            )
        }
        'recipientMap'
        {
            @{
                Name      = 'TSourceOrganization'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            $(@('ExternalDirectoryObjectID', 'TExternalDirectoryObjectID').foreach(
                    {
                        @{
                            Name      = $_
                            Type      = 'nchar'
                            MaxLength = 36
                            Nullable  = $true
                        }
                    }))
            @{
                Name      = 'Alias'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            @{
                Name      = 'TAlias'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            @{
                Name      = 'PrimarySmtpAddress'
                Type      = 'nvarchar'
                MaxLength = 256
                Nullable  = $true
            }
            @{
                Name      = 'TPrimarySmtpAddress'
                Type      = 'nvarchar'
                MaxLength = 256
                Nullable  = $true
            }
            @{
                Name      = 'ExternalEmailAddress'
                Type      = 'nvarchar'
                MaxLength = 256
                Nullable  = $true
            }
            @{
                Name      = 'TExternalEmailAddress'
                Type      = 'nvarchar'
                MaxLength = 256
                Nullable  = $true
            }
            @{
                Name      = "TCustomAttribute13"
                Type      = 'nvarchar'
                MaxLength = 1024
                Nullable  = $true
            }
            @{
                Name      = 'RecipientTypeDetails'
                Type      = 'nvarchar'
                MaxLength = 256
                Nullable  = $true
            }
            @{
                Name      = 'TRecipientTypeDetails'
                Type      = 'nvarchar'
                MaxLength = 256
                Nullable  = $true
            }
        }
        'configurationOrganization'
        {
            @{
                Name      = 'Name'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            @{
                Name      = 'MigrationRole'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            @{
                Name      = 'Credential'
                Type      = 'nvarchar'
                MaxLength = 1024
                Nullable  = $true
            }
            @{
                Name      = 'TenantDomain'
                Type      = 'nvarchar'
                MaxLength = 512
                Nullable  = $true
            }
            @{
                Name      = 'PrimaryDomain'
                Type      = 'nvarchar'
                MaxLength = 512
                Nullable  = $true
            }
            @{
                Name      = 'ConflictPrefix'
                Type      = 'nvarchar'
                MaxLength = 8
                Nullable  = $true
            }
            @{
                Name     = 'ConflictPriority'
                Type     = 'int'
                Nullable = $true
            }
        }
    }

    switch -wildcard ($TableType)
    {
        'q*'
        {
            @{
                Name      = 'Action'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            @{
                Name      = 'TargetOrganization'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
        }
        'action*'
        {
            @{
                Name      = 'Action'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
            @{
                Name     = 'WhenAction'
                Type     = 'DateTime'
                Nullable = $true
            }
            @{
                Name     ='ActionResult'
                Type     = 'bit'
                Nullable = $true
            }
            @{
                Name      = 'ActionError'
                Type      = 'nvarchar'
                MaxLength = 1024
                Nullable  = $true
            }
            @{
                Name      = 'ActionNote'
                Type      = 'nvarchar'
                MaxLength = 1024
                Nullable  = $true
            }
            @{
                Name      = 'TargetOrganization'
                Type      = 'nvarchar'
                MaxLength = 64
                Nullable  = $true
            }
        }
    }

}