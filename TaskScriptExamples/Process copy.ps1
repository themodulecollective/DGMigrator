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
