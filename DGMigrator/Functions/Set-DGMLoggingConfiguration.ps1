function Set-DGMLoggingConfiguration
{
    [cmdletbinding()]
    param()
    $Configuration = Get-DGMConfiguration -default
    switch ($null -eq $Configuration)
    {
        $true
        {
            $Message = "Logging Configured to Default for User"
        }
        $false
        {
            $LPSetParams = @{
                Name           = 'LogFile'
                InstanceName   = 'DGMigrator'
                IncludeModules = 'DGMigrator'
                Enabled        = $true
                FileType       = 'json'
                UTC            = $true
                TimeFormat     = 'yyyy-MM-dd-hh:mm:ss'
                JsonCompress   = $true
                JsonString     = $true
                FilePath       = $(Join-Path -Path $(Join-Path -Path $Configuration.DataFolderPath -ChildPath 'Logs') -ChildPath 'DGM-') + '%date%-%hour%.log'
            }
            Set-PSFLoggingProvider @LPSetParams
            $Message = "Logging configured to Configuration $($Configuration.Name) subFolder $($LPSetParams.FilePath)"
        }
    }

    Write-PSFMessage -Level Verbose -Message $Message
}
