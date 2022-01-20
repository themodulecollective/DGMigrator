function New-DGMConfiguration
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
  [CmdletBinding(SupportsShouldProcess)]
  param (
    # Specify the Name of the Module or Package
    [Parameter(Mandatory, Position = 1)]
    [String]
    $Name
    ,
    # Specify the FilePath to the Folder containing the Source Environments Data
    [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
    [ValidateScript( { Test-Path -path $_ -PathType Container })]
    [String]
    $DataFolderPath
  )

  begin
  {

  }
  process
  {
    if ((Get-DGMConfiguration -Name $Name).count -eq 0)
    {
      $Configuration =
      [pscustomobject]@{
        PSTypeName     = 'DGMigratorConfiguration'
        Name           = $Name
        DataFolderPath = $DataFolderPath
      }
      if ($PSCmdlet.ShouldProcess("$Configuration"))
      {
        $SetConfigParams = @{
          Module      = $MyInvocation.MyCommand.ModuleName
          AllowDelete = $true
          Passthru    = $true
          Name        = "Configurations.$Name"
          Value       = $Configuration
        }
        Set-PSFConfig @SetConfigParams | Register-PSFConfig
      }
    }
    else
    {
      throw("Configuration for $Name already exists. To modify it, use Set-DGMConfiguration")
    }
  }

  end
  {

  }
}
