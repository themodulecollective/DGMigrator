Function Get-DGMConfiguration
{
    <#
    .SYNOPSIS
        Gets the DGMigrator Configurations.  If no configurations have been created or imported yet, returns nothing.  Use Import-DGMConfiguration to import DGManagerConfigurations.
    .DESCRIPTION
            Gets the DGMigrator Configurations.  If no configurations have been created or imported yet, returns nothing.  Use Import-DGMConfiguration to import DGManagerConfigurations.
    .EXAMPLE
        Get-DGMConfiguration -Name ContosoMerger

        Name            : ContosoMerger
        DataFolderPath  : c:\ContosoMerger


        Gets the DGMigrator Configuration for ContosoMerger

    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>

    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        # Use to specify the name of the DGMigrator Configurations to get.  Accepts Wildcard.
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name', Position = 1)]
        [string[]]$Name
        ,
        [switch]$Default
    )

    process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'Name'
            {
                foreach ($n in $Name)
                {
                    (Get-PSFConfig -Module DGMigrator -Name Configurations.$($n)).foreach( { Get-PSFConfigValue -FullName $_.FullName })
                }
            }
            'All'
            {
                (Get-PSFConfig -Module DGMigrator -Name Configurations.*).foreach( { Get-PSFConfigValue -FullName $_.FullName }) | Where-Object { $_.IsDefaultConfiguration -eq $True -or -not $Default }
            }
        }
    }
}
