function Invoke-DGMGroupRoleQuery
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet(
            'AcceptMessagesOnlyFrom',
            'BypassModeration',
            'GrantSendOnBehalfTo',
            'RejectMessagesFrom',
            'ModeratedBy',
            'ManagedBy',
            'MemberOf'

        )]
        [string]$Role
        ,
        $GroupIdentity
    )

    $Configuration = Get-DGMConfiguration -default
    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        as          = 'PSObject'
    }

    $query = @"
    SELECT M.TExternalDirectoryObjectID AS Identifier
    FROM stagingDistributionGroupRole R JOIN recipientMap M
    ON R.ExternalDirectoryObjectID = M.ExternalDirectoryObjectID
    WHERE TExternalDirectoryObjectID IS NOT NULL
    AND Role = '$Role'
    AND TargetGroupExternalDirectoryObjectID = '$GroupIdentity'
"@

    Write-PSFMessage -level Verbose -Message "Running Query: $query"
    @(Invoke-DbaQuery @iqParams -query $query |
        Select-Object -ExpandProperty Identifier)
}