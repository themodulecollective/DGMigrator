Export-DGMOrganizationRecipient
Copy-DGMStagingTablesToHistory
Import-DGMRecipientData
Update-DGMRecipientMap
Invoke-DGMContactStagingToQ
Invoke-DGMGroupStagingToQ
Invoke-DGMGroupRoleStagingToQ
Invoke-DGMContactTargetOperation
Invoke-DGMGroupTargetDeleteOperation
Invoke-DGMGroupRoleTargetOperation
$NestingArray = New-DGMGroupNestingAnalysis
$NGTOParams = @{
    NestingArray  = $NestingArray
    IncludeLowest = $true
}
Invoke-DGMNestedGroupTargetOperation @NGTOParams
Invoke-DGMGroupTargetUpdateOperation

# Process for Bulk update of groups based on selected Date
[datetime]$ComparisonDate = '10/1/2021'
Invoke-DGMGroupStagingToQS -ComparisonDate $ComparisonDate
Invoke-DGMGroupTargetUpdateOperation

#Process for Bulk Update of ManagedBy
#usually performed after changing DelayManagedBy setting in migration configuration
Invoke-DGMGroupRoleStagingToQ
Invoke-DGMGroupRoleTargetOperation -IncludeRoleType ManagedBy