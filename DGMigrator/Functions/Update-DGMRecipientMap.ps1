function Update-DGMRecipientMap
{
    [cmdletbinding()]
    param(
    )

    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name)"

    $Configuration = Get-DGMConfiguration -Default

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    #Truncate/Clean old data from staging tables selected
    $t='recipientMap'

    Write-PSFMessage -Level Verbose -Message "Truncating table $t"
    $null = Invoke-DbaQuery @dbParams -query "TRUNCATE TABLE $t"

    Write-PSFMessage -Level Verbose -Message "Inserting into table $t"
    $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.insertRecipientMap)
    Invoke-DbaQuery @dbparams -query $eSQL

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"

}