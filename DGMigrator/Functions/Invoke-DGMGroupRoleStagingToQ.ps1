function Invoke-DGMGroupRoleStagingToQ
{
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(    )


    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name)"

    $Configuration = Get-DGMConfiguration -Default

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }


    $qTables = @(
        'qSDistributionGroupRole'
        'qIDistributionGroupRole'
    )

    #Truncate/Clean old data from staging tables selected
    Write-PSFMessage -Level Verbose -Message "Truncating tables $($qTables -join ', ')"
    foreach ($t in $qTables)
    {
        $null = Invoke-DbaQuery @iqParams -query "TRUNCATE TABLE $t"
    }

    $ScriptsToRun = @(
        'stagingRoleAddToTarget'
        'stagingRoleDeleteFromTarget'
    )

    Write-PSFMessage -Level Verbose -Message "Processing scripts $($ScriptsToRun -join ', ')"

    foreach  ($s in $ScriptsToRun)
    {
        Write-PSFMessage -Message "Processing SQL Script $s"
        #expand the SQL for any PS Variables/Scriptblocks contained
        $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.$s)
        #set the expanded SQL as the query value
        Write-PSFMessage -Message "Expanded SQL = $eSQL"
        $iqParams.query = $eSQL
        #run the Query
        Invoke-DbaQuery @iqParams -MessagesToOutput -as PSObject
    }

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"
}