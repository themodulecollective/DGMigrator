#Requires -Version 5.1
###############################################################################################
# Module Variables
###############################################################################################
$ModuleVariableNames = ('DGMConfiguration', 'SQLScripts')
$ModuleVariableNames.ForEach( { Set-Variable -Scope Script -Name $_ -Value $null })
#Enum Example: enum InstallManager { Chocolatey; Git; PowerShellGet; Manual }

$SQLScripts = @{}

foreach ($s in $SQLFiles)
{
  $item = Get-Item -path $s
  $key = $item.BaseName
  $SQLScripts.$key=$(Get-Content -Path $item.FullName)
}

###############################################################################################
# Module Removal
###############################################################################################
#Clean up objects that will exist in the Global Scope due to no fault of our own . . . like PSSessions

$OnRemoveScript = {
  # perform cleanup
  Write-Verbose -Message 'Removing Module Items from Global Scope'
}

$ExecutionContext.SessionState.Module.OnRemove += $OnRemoveScript
