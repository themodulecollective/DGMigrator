Function Export-DGMConfiguration
{
    <#
    .SYNOPSIS
        Exports the DGMigrator Configurations.  If no configurations have been created or imported yet, returns nothing.  Use Import-DGMConfiguration to import DGManagerConfigurations.
    .DESCRIPTION
        Exports the DGMigrator Configurations.  If no configurations have been created or imported yet, returns nothing.  Use Import-DGMConfiguration to import DGManagerConfigurations.
    .EXAMPLE
        Export-DGMConfiguration -Name ContosoMerger -FolderPath c:\Local\

        Exports the DGMigrator Configuration for ContosoMerger to the file [TimeStamp]ContosoMerger.json

    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    #>

    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        # Use to specify the name of the DGMigrator Configurations to Export.  Accepts Wildcard.
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name', Position = 1)]
        [string[]]$Name
        ,
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'All', Position = 1)]
        [string[]]$All
        ,
        [parameter(Mandatory)]
        [ValidateScript( { Test-Path -type Container -Path $_ })]
        [string]$OutputFolderPath

    )

    process
    {
        $timeStamp = Get-TimeStamp
        switch ($PSCmdlet.ParameterSetName)
        {
            'Name'
            {
                foreach ($n in $Name)
                {
                    $fileName = $n + 'AsOf' + $timeStamp + '.json'
                    $filePath = Join-Path -Path $OutputFolderPath -ChildPath $fileName
                    (Get-PSFConfig -Module DGMigrator -Name Configurations.$($n)).foreach( {
                         Get-PSFConfigValue -FullName $_.FullName }) | ConvertTo-Json | Out-File -FilePath $filePath -Encoding utf8
                }
            }
            'All'
            {
                (Get-PSFConfig -Module DGMigrator -Name Configurations.*).foreach( { 
                    $Configuration = Get-PSFConfigValue -FullName $_.FullName 
                    $n = $Configuration.Name
                    $fileName = $n + 'AsOf' + $timeStamp + '.json'
                    $filePath = Join-Path -Path $OutputFolderPath -ChildPath $fileName
                    $Configuration | Convertto-json | Out-File -FilePath $filePath -Encoding utf8
                })
            }
        }
    }
}
