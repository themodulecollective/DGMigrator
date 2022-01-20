function Copy-DGMStagingTablesToHistory
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

    $tableSourceTargetMap = @{
        'stagingContact'               = 'historyContact'
        'stagingDistributionGroup'     = 'historyDistributionGroup'
        'stagingDistributionGroupRole' = 'historyDistributionGroupRole'
    }

    $tableSourceTargetMap.getenumerator().foreach({
            $tm = $_

            $CopyParams = @{
                Table            = $tm.name
                DestinationTable = $tm.value
                Truncate         = $true
                Confirm          = $false
            }

            $null = Copy-DbaDbTableData @dbParams @CopyParams
        })

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"
}