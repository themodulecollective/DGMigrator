function Import-DGMConfiguration
{
  <#
  .SYNOPSIS
    Creates a new DGMigrator Configuration and stores it in the current user's configuration
  .DESCRIPTION
    Creates a new DGMigrator Configuration and stores it in the current user's configuration
  .EXAMPLE
    PS C:\> New-DGMConfiguration -Name ContosoMerger
    Adds an DGMigratorConfiguration for ContosoMerger and sets it to the defaults.
  .INPUTS
    None
  .OUTPUTS
    None
  .NOTES

  #>
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'File')]
  param (
    # Specify the FilePath to the JSON file containing the Configuration
    [Parameter(Mandatory, Position = 1, ParameterSetName = 'File')]
    [ValidateScript( { Test-Path -path $_ -PathType leaf -Include '*.json' })]
    [String]
    $ConfigurationFilePath
  )


  $Configuration = Get-Content -Raw -Path $ConfigurationFilePath | ConvertFrom-Json


  if ($PSCmdlet.ShouldProcess("$Configuration"))
  {
    $SetConfigParams = @{
      Module      = $MyInvocation.MyCommand.ModuleName
      AllowDelete = $true
      Passthru    = $true
      Name        = "Configurations.$($Configuration.Name)"
      Value       = $Configuration
    }
    Set-PSFConfig @SetConfigParams | Register-PSFConfig
  }

}
