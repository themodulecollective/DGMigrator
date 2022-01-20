#Initial Setup
Import-DGMConfiguration
New-DGMDatabase
Set-DGMLoggingConfiguration

#Table Maintenance
Update-DGMDatabaseSchema

#Contact Creation and Missing Recipient Mitigations/Determinations
Export-DGMOrganizationRecipient
Import-DGMRecipientData
Update-DGMRecipientMap
Invoke-DGMContactStagingToQ
Invoke-DGMContactTargetOperation

# After Contacts Created and other Missing Recipients Mitigated
Export-DGMOrganizationRecipient
Import-DGMRecipientData
Update-DGMRecipientMap

#First Nesting Level Group Creation (level -1)
Export-DGMOrganizationRecipient #pickup latest changes
Import-DGMRecipientData #import latest changes
Update-DGMRecipientMap
Invoke-DGMGroupStagingToQ
$NestingArray = New-DGMGroupNestingAnalysis
Invoke-DGMGroupTargetAddOperation -NestingArray $NestingArray -NestingLevel -1

#Subsequent Nesting Level Group Creation - Manual Process
#From Highest to Lowest Nesting Level - DO NOT do Level 0 until last.
Export-DGMOrganizationRecipient -IncludeOrganization "<TargetOrg>" #pickup newly created groups
Import-DGMRecipientData #import newly created groups
Update-DGMRecipientMap
Invoke-DGMGroupStagingToQ
Invoke-DGMGroupTargetAddOperation -NestingArray $NestingArray -NestingLevel "<highest not yet processed>"
$externalDirectoryObjectIDs = $($NestingArray.where({$_.Value -eq "<level just processed by Invoke-DGMGroupTargetAddOperation>"}).Name)
Update-DGMDistributionGroupStaging -TargetOrganization "<TargetOrganization>" -includeExternalDirectoryObjectID $externalDirectoryObjectIDs

#Mostly Automated Process for Nesting Level Group Creation
$NestingArray = New-DGMGroupNestingAnalysis
Invoke-DGMNestedGroupTargetOperation -NestingArray $NestingArray -IncludeLowest -TargetOrganization "<the target org>"

#check
# - DelayManagedBy setting
# - Errors for actionsContact
# - Mapping of attributes in configuration file