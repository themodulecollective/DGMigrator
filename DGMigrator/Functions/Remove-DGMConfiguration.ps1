function Remove-DGMConfiguration
{
  <#
  .SYNOPSIS
    Removes an DGMigrator Configuration and updates the current user's configuration
  .DESCRIPTION
    Removes an DGMigrator Configuration and updates the current user's configuration
  .EXAMPLE
    PS C:\> Remove-DGMConfiguration -Name ContosoMerger
    Removes the DGMigrator Configuration for ContosoMerger
  .INPUTS
    None
  .OUTPUTS
    None
  .NOTES

  #>
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
  param (
    # Specify the Name of the Module or Package
    [Parameter(Mandatory, Position = 1, ParameterSetName = 'Name')]
    [String]
    $Name
    ,
    # Allows submission of an IMDefinition object via pipeline or named parameter
    [Parameter(ValueFromPipeline, ParameterSetName = 'DGMigratorConfiguration')]
    [ValidateScript( { $_.psobject.TypeNames[0] -like '*DGMigratorConfiguration' })]
    $DGMigratorConfiguration
  )

  begin
  {

  }
  process
  {
    switch ($PSCmdlet.ParameterSetName)
    {
      'Name'
      {
        $Configuration = @(Get-DGMConfiguration -Name $Name)
        switch ($Configuration.count)
        {
          0
          {
            Write-Warning -Message "Not Found: DGMigrator Configuration for $Name"
            Return
          }
          1
          {
            #All OK - found just one Definition to Remove
          }
          Default
          {
            throw("Ambiguous:  DGMigratorConfiguration for $Name.  Try being more specific.")
          }
        }
      }
      'DGMigratorConfiguration'
      {
        $Configuration = @($DGMigratorConfiguration)
      }
    }
    foreach ($dgmc in $Configuration)
    {
      $remConfigParams = @{
        Module = $MyInvocation.MyCommand.ModuleName
        Name   = "Configurations.$($dgmc.Name)"
      }
      if ($PSCmdlet.ShouldProcess("Name = $($dgmc.Name)"))
      {
        Set-PSFConfig @remConfigParams -AllowDelete
        $remConfigParams.Confirm = $false
        Write-PSFMessage -Level Verbose -Message $($remConfigParams | ConvertTo-Json -Compress)
        Remove-PSFConfig @remConfigParams
      }
    }
  }

  end
  {

  }
}
