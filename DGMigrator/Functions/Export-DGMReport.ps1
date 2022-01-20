function Export-DGMReport
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet(
            'reportCountMissingMemberByRecipientType',
            'reportDistinctMissingMember',
            'reportQueuedGroupActions',
            'reportQueuedGroupRoleActions',
            'reportManagedByPerGroup',
            'reportManagedByPerManager'
        )]
        [string[]]$Report
        ,
        [parameter(Mandatory)]
        [validatescript({$_ -like '*.xl*'})]
        [string]$FilePath #accepts native Excel file extensions (*.xls, *.xlsx) only
    )

    $Configuration = Get-DGMConfiguration -Default

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        AS          = 'PSObjectArray'
    }

    $eParams = @{
        Path         = $FilePath
        FreezeTopRow = $true
        TableStyle   = 'Medium21'
        AutoSize     = $true
    }

    foreach ($r in $Report)
    {
        Write-PSFMessage -Level Verbose -Message "Running Report $r"
        $eParams.WorksheetName = $r
        $eSQL = $ExecutionContext.InvokeCommand.ExpandString($SQLScripts.$r)
        Write-PSFMessage -Level Verbose -Message "Running report query: $eSQL"
        $Results = Invoke-DbaQuery @dbparams -query $eSQL
        Write-PSFMessage -Level Verbose -Message "Report contains $($Results.count) records"
        Export-Excel @eParams -InputObject $Results
        Write-PSFMessage -Level Verbose -Message "Report $r exported to $FilePath"
    }

}
