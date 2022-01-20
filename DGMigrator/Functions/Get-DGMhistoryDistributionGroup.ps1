function Get-DGMhistoryDistributionGroup
{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(Mandatory, ParameterSetName = 'Identity')]
        [string]$Identity
    )

    $Configuration = Get-DGMConfiguration -Default

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        as          = 'PSObject'
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'Identity'
        {
            $query = "SELECT * FROM historyDistributionGroup WHERE externaldirectoryobjectid = '$Identity'"
        }
        'All'
        {
            $query = "SELECT * FROM historyDistributionGroup"
        }
    }

    Invoke-DbaQuery @iqParams -query $query

}