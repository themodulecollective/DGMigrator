function Invoke-DGMGroupStagingToQS
{
    [cmdletbinding(DefaultParameterSetName = 'Standard')]
    param(
        #Groups with a WhenChangedUTC value greater than this date will be updated in the target
        [parameter(ParameterSetName = 'UpdateByComparisonDate', Mandatory)]
        [datetime]$ComparisonDate
    )

    $Configuration = Get-DGMConfiguration -Default

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'Standard'
        {
            $ScriptsToRun = @(
                'stagingGroupAddToTarget'
                'stagingGroupUpdateInTarget'
                'stagingGroupDeleteFromTarget'
            )
        }
        'UpdateByComparisonDate'
        {
            $ScriptsToRun = @(
                'stagingGroupUpdateInTargetByDate'
            )
        }
    }


    Write-PSFMessage -Level Verbose -Message "Processing scripts $($ScriptsToRun -join ', ')"

    $qTables = @(
        'qSDistributionGroup'
    )

    #Truncate/Clean old data from staging tables selected
    Write-PSFMessage -Level Verbose -Message "Truncating tables $($qTables -join ', ')"
    foreach ($t in $qTables)
    {
        $null = Invoke-DbaQuery @iqParams -query "TRUNCATE TABLE $t"
    }

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
}