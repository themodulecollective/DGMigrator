function Set-DGMConfiguration
{
  <#
  .SYNOPSIS
    Sets an DGMigrator Configuration and updates the current user's configuration
  .DESCRIPTION
    Sets an DGMigrator Configuration and updates the current user's configuration
  .EXAMPLE
    PS C:\> Set-DGMConfiguration
    Sets the DGMigrator Configuration to
  .INPUTS
    None
  .OUTPUTS
    None
  .NOTES

  #>
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
  param (
    # Specify the Name of the DGMigrator Configuration to Set
    [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
    [String]
    $Name
    ,
    # Specify the FilePath to the Folder containing the Source Environments Data
    [Parameter(Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
    [ValidateScript( { Test-Path -path $_ -PathType Container })]
    [String]
    $DataFolderPath
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
            Write-Warning -Message "Not Found: DGMigratorConfiguration for $Name"
            Return
          }
          1
          {
            #All OK - found just one Definition to Set
          }
          Default
          {
            throw("Ambiguous: DGMigratorConfiguration for $Name. This is unexpected.  Please contact support.")
          }
        }
      }
    }

    foreach ($dgmc in $Configuration)
    {
      $keys = $PSBoundParameters.keys.ForEach( { $_ }) #avoid enumerating and modifying
      foreach ($k in $keys)
      {
        switch ($k -in ('DataFolderPath'))
        {
          $true
          {
            $dgmc.$k = $PSBoundParameters.$k
          }
          $false
          { }
        }
      }
      if ($PSCmdlet.ShouldProcess("$dgmc"))
      {
        $SetConfigParams = @{
          Module      = $MyInvocation.MyCommand.ModuleName
          AllowDelete = $true
          Passthru    = $true
          Name        = "Configurations.$($dgmc.Name)"
          Value       = $dgmc
        }
        Set-PSFConfig @SetConfigParams | Register-PSFConfig
      }
    }
  }

  end
  {

  }
}
