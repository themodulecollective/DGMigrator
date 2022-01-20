function Update-DGMConfigurationInDatabase
{
    [cmdletbinding()]
    param(
    )
    $Configuration = Get-DGMConfiguration -Default

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        Table       = 'configurationOrganization'
    }

    $Columns = @(Get-DbaDbTable @dbparams).Columns.Name

    $ColumnMap = @{}
    $Columns.foreach({
            $ColumnMap.$_ = $_
        })

    $Configuration.Organizations | ConvertTo-DbaDataTable | Write-DbaDataTable -Truncate -ColumnMap $ColumnMap @dbParams
}