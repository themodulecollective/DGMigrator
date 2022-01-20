function Invoke-DGMContactStagingToQ
{
    [cmdletbinding()]
    param()

    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name)"

    Invoke-DGMContactStagingToQS
    Invoke-DGMContactStagingToQI

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"
}