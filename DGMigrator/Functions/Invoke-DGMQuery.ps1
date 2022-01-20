function Invoke-DGMQuery
{
    [cmdletbinding()]
    param(
        [string]$query
    )

    $Configuration = Get-DGMConfiguration -Default
    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        as          = 'PSObject'
        query       = $query
    }

    Invoke-DbaQuery @iqParams
}