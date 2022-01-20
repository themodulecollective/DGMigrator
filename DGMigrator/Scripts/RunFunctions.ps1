###############################################################################################
# Import User's Preferences
###############################################################################################
#Import-DGMPreference
###############################################################################################
# Setup Tab Completion
###############################################################################################
# Tab Completions for IM Definition Names
$DGMigratorConfigurationsScriptBlock = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
  $MyParams = @{ }
  if ($null -ne $wordToComplete)
  {
    $MyParams.Name = $wordToComplete + '*'
  }
  $MyNames = Get-DGMConfiguration @MyParams |
  Select-Object -expandProperty Name

  foreach ($n in $MyNames)
  {
    [System.Management.Automation.CompletionResult]::new($n, $n, 'ParameterValue', $n)
  }
}

$DGMigratorOrganizationsScriptBlock = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
  switch ($null -eq $wordToComplete)
  {
    $true
    {
      $MyNames = (Get-DGMConfiguration -Default).Organizations.Name
    }
    $false
    {
      $MyNames = (Get-DGMConfiguration -Default).Organizations.Name.where({$_ -like $($wordToComplete + '*')})
    }
  }

  foreach ($n in $MyNames)
  {
    [System.Management.Automation.CompletionResult]::new($n, $n, 'ParameterValue', $n)
  }
}


$DGMigratorSQLScriptsScriptBlock = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
  switch ($null -eq $wordToComplete)
  {
    $true
    {
      $MyNames = $script:SQLScripts.keys
    }
    $false
    {
      $MyNames = $script:SQLScripts.keys.where({$_ -like $($wordToComplete + '*')})
    }
  }

  foreach ($n in $MyNames)
  {
    [System.Management.Automation.CompletionResult]::new($n, $n, 'ParameterValue', $n)
  }
}

#SQL Scripts
Register-ArgumentCompleter -CommandName @(
  'Get-DGMSQLScript'
) -ParameterName 'Name' -ScriptBlock $DGMigratorSQLScriptsScriptBlock


#Configuration Names
Register-ArgumentCompleter -CommandName @(
  'Set-DGMConfiguration'
  'New-DGMConfiguration'
  'Get-DGMConfiguration'
  'Remove-DGMConfiguration'
) -ParameterName 'Name' -ScriptBlock $DGMigratorConfigurationsScriptBlock

#Organization Names
Register-ArgumentCompleter -CommandName @(
  'Import-DGMRecipientData'
  'Export-DGMOrganizationRecipient'
  'Update-DGMDistributionGroupStaging'
) -ParameterName 'IncludeOrganization' -ScriptBlock $DGMigratorOrganizationsScriptBlock

Register-ArgumentCompleter -CommandName @(
  'Invoke-DGMNestedGroupTargetOperation'
  'Update-DGMDistributionGroupStaging'
  'Invoke-DGMGroupTargetUpdateOperation'
) -ParameterName 'TargetOrganization' -ScriptBlock $DGMigratorOrganizationsScriptBlock

###############################################################################################
# Module Logging
###############################################################################################
Set-DGMLoggingConfiguration
