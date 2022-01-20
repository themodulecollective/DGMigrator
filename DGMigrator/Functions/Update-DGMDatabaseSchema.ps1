function Update-DGMDatabaseSchema
{
    [cmdletbinding()]
    param(
        [switch]$AddIndexes
    )
    $Configuration = Get-DGMConfiguration -Default

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
    }

    $existingDatabase = Get-DbaDatabase @dbParams -Database $Configuration.Name

    if ($null -ne $existingDatabase -and $existingDatabase -is [Microsoft.SqlServer.Management.Smo.Database])
    {
        $dbParams.Database = $Configuration.Name

        $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.renameTables)
        Invoke-DbaQuery @dbparams -query $eSQL

        $existingTables = Get-DbaDbTable @dbParams | Select-Object -expandProperty Name

        $tables = @(
            'stagingRecipient'
            'stagingDistributionGroup'
            'stagingDistributionGroupRole'
            'stagingContact'
            'historyDistributionGroup'
            'historyDistributionGroupRole'
            'historyContact'
            'qSDistributionGroup'
            'qSDistributionGroupRole'
            'qSContact'
            'qIDistributionGroup'
            'qIDistributionGroupRole'
            'qIContact'
            'actionsDistributionGroup'
            'actionsDistributionGroupRole'
            'actionsContact'
            'recipientMap'
            'stagingNLDistributionGroup'
            'configurationOrganization'
        )
        # Table Creations
        foreach ($t in $tables.where({$_ -notin $existingTables}))
        {
            Write-PSFMessage -Level Verbose -Message "Creating Table $t on Database $($dbParams.Database)"
            $tableParams = @{}
            $tableParams.name = $t
            $tableParams.columnMap = Get-DGMColumnMap -TableType $tableParams.name
            $null = New-DbaDbTable @dbParams @tableParams
        }

        #View Create/Replace
        $viewScripts = @(
            'DropViews'
            'viewSourceRolesWithMap'
            'viewTargetRolesMatchingSourceRoles'
            'viewStagingDistributionGroupRoleSourceOnly'
            'viewStagingDistributionGroupRoleTargetOnly'
            'viewTargetGroupNotMappedToSource'
        )
        foreach  ($s in $viewScripts)
        {
            Write-PSFMessage -Message "Processing SQL Script $s"
            #expand the SQL for any PS Variables/Scriptblocks contained
            $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.$s)
            #set the expanded SQL as the query value
            Write-PSFMessage -Message "Expanded SQL = $eSQL"
            $dbParams.query = $eSQL
            #run the Query
            Invoke-DbaQuery @dbParams -MessagesToOutput -as PSObject
        }


        #add indexes
        if ($AddIndexes)
        {
            $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.Indexes)
            $dbParams.query = $eSQL
            Invoke-DbaQuery @dbparams
        }
    }
}