# get each
@{
    Name      ='AcceptMessagesOnlyFromSendersOrMembers'
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

#@{Name = 'AdministrativeUnits'}
#@{Name='BypassModerationFromSendersOrMembers'}
#@{Name='ModeratedBy'}
#@{Name='RejectMessagesFromSendersOrMembers'}


# custom / multi
@{Name ='Description'}
@{Name ='EmailAddresses'}
@{Name ='ExtensionCustomAttribute1'}
@{Name ='ExtensionCustomAttribute2'}
@{Name ='ExtensionCustomAttribute3'}
@{Name ='ExtensionCustomAttribute4'}
@{Name ='ExtensionCustomAttribute5'}
@{Name ='UMDtmfMap'}
#@{Name='MailTipTranslations'}
