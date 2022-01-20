function Export-DGMDataTable
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet(
            'historyDistributionGroup',
            'qIContact',
            'actionsDistributionGroup',
            'actionsDistributionGroupRole',
            'actionsContact',
            'recipientMap',
            'stagingDistributionGroupRole',
            'historyDistributionGroupRole',
            'qSDistributionGroupRole',
            'stagingNLDistributionGroup',
            'historyContact',
            'qIDistributionGroupRole',
            'configurationOrganization',
            'stagingRecipient',
            'qSDistributionGroup',
            'stagingDistributionGroup',
            'qSContact',
            'stagingContact',
            'qIDistributionGroup'
        )]
        [string[]]$Table
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

    foreach ($t in $Table)
    {
        Write-PSFMessage -Level Verbose -Message "Exporting Table $t"
        $eParams.WorksheetName = $t
        $SQL = "SELECT * FROM $t"
        Write-PSFMessage -Level Verbose -Message "Running report query: $eSQL"
        $Results = Invoke-DbaQuery @dbparams -query $SQL
        Write-PSFMessage -Level Verbose -Message "Table contains $($Results.count) records"
        Export-Excel @eParams -InputObject $Results
        Write-PSFMessage -Level Verbose -Message "Table $t exported to $FilePath"
    }

}
