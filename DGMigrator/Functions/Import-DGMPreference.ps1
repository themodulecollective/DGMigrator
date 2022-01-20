function Import-DGMPreference
{
    $script:IMConfiguration = Get-PSFConfigValue -FullName "$($MyInvocation.MyCommand.ModuleName).Preferences"
}
