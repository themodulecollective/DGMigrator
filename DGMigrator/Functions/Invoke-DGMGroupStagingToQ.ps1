function Invoke-DGMGroupStagingToQ
{
    [cmdletbinding()]
    param()

    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name)"

    Invoke-DGMGroupStagingToQS
    Invoke-DGMGroupStagingToQI

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"
}