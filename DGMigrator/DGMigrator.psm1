#Requires -Version 5.1

$ModuleFolder = Split-Path $PSCommandPath -Parent

$Scripts = Join-Path -Path $ModuleFolder -ChildPath 'scripts'
$Functions = Join-Path -Path $ModuleFolder -ChildPath 'functions'
$SQLFolder = Join-Path -Path $ModuleFolder -ChildPath 'sql'

#Write-Information -MessageData "Scripts Path  = $Scripts" -InformationAction Continue
#Write-Information -MessageData "Functions Path  = $Functions" -InformationAction Continue
#Write-Information -MessageData "SQL Folder  = $SQLFolder" -InformationAction Continue

$Script:SQLFiles = @(
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingGroupAddToTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingContactAddToTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingGroupDeleteFromTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingGroupUpdateInTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'DropQTables.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'Indexes.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'insertRecipientMap.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingRoleAddToTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingRoleDeleteFromTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'reportCountMissingMemberByRecipientType.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'reportDistinctMissingMember.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'mergeNLDistributionGroup.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'renameTables.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'selectGroupAddToTargetFromQI.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'selectExistingGroupFromStagingTarget.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'DropViews.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'viewTargetRolesMatchingSourceRoles.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'viewSourceRolesWithMap.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'viewStagingDistributionGroupRoleSourceOnly.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'viewStagingDistributionGroupRoleTargetOnly.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'viewTargetGroupNotMappedToSource.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'stagingGroupUpdateInTargetByDate.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'reportQueuedGroupActions.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'reportQueuedGroupRoleActions.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'reportManagedByPerGroup.sql')
  $(Join-Path -Path $SQLFolder -ChildPath 'reportManagedByPerManager.sql')
)

$Script:ModuleFiles = @(
  $(Join-Path -Path $Scripts -ChildPath 'Initialize.ps1')
  # Load Functions
  $(Join-Path -Path $functions -ChildPath 'Set-DGMConfiguration.ps1')
  $(Join-Path -Path $functions -ChildPath 'New-DGMConfiguration.ps1')
  $(Join-Path -Path $functions -ChildPath 'Get-DGMConfiguration.ps1')
  $(Join-Path -Path $functions -ChildPath 'Remove-DGMConfiguration.ps1')
  $(Join-Path -Path $functions -ChildPath 'Import-DGMConfiguration.ps1')
  $(Join-Path -Path $functions -ChildPath 'Import-DGMRecipientData.ps1')
  $(Join-Path -Path $functions -ChildPath 'New-DGMDatabase.ps1')
  $(Join-Path -Path $functions -ChildPath 'Export-DGMOrganizationRecipient.ps1')
  $(Join-Path -Path $functions -ChildPath 'Get-DGMColumnMap.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupStagingToQS.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupStagingToQI.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupTargetAddOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMContactStagingToQS.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMContactStagingToQI.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMContactTargetOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Update-DGMDatabaseSchema.ps1')
  $(Join-Path -Path $functions -ChildPath 'Set-DGMLoggingConfiguration.ps1')
  $(Join-Path -Path $functions -ChildPath 'Update-DGMRecipientMap.ps1')
  $(Join-Path -Path $functions -ChildPath 'Export-DGMReport.ps1')
  $(Join-Path -Path $functions -ChildPath 'New-DGMGroupNestingAnalysis.ps1')
  $(Join-Path -Path $functions -ChildPath 'Update-DGMDistributionGroupStaging.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMNestedGroupTargetOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Copy-DGMStagingTablesToHistory.ps1')
  $(Join-Path -Path $functions -ChildPath 'Update-DGMConfigurationInDatabase.ps1')
  $(Join-Path -Path $functions -ChildPath 'Get-DGMSQLScript.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupTargetUpdateOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Get-DGMhistoryDistributionGroup.ps1')
  $(Join-Path -Path $functions -ChildPath 'Get-DGMstagingDistributionGroup.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupTargetDeleteOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupStagingToQ.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMContactStagingToQ.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMContactTargetOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupRoleStagingToQ.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupRoleTargetOperation.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMQuery.ps1')
  $(Join-Path -Path $functions -ChildPath 'Export-DGMDataTable.ps1')
  $(Join-Path -Path $functions -ChildPath 'Invoke-DGMGroupRoleQuery.ps1')

  #Private Functions
  $(Join-Path -Path $functions -ChildPath 'Export-ExchangeRecipient.ps1')
  $(Join-Path -Path $functions -ChildPath 'Compare-ComplexObject.ps1')

  # Finalize / Run any Module Functions defined above
  $(Join-Path -Path $Scripts -ChildPath 'RunFunctions.ps1')
)
foreach ($f in $ModuleFiles)
{
  . $f
}