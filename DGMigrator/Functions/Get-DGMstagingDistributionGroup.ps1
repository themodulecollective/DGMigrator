function Get-DGMstagingDistributionGroup
{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(Mandatory, ParameterSetName = 'Identity')]
        [string]$Identity
        ,
        [parameter(ParameterSetName = 'Identity')]
        [switch]$TargetGroup

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
            switch ($TargetGroup)
            {
                $true
                {
                    $query = @"
                    SELECT * FROM stagingDistributionGroup
                    WHERE CustomAttribute12 = '$Identity'
                    AND SourceOrganization
                    IN (
                        SELECT name
                        FROM configurationOrganization
                        WHERE MigrationRole = 'Target'
                        )
"@
                }
                $false
                {
                    $query = "SELECT * FROM stagingDistributionGroup WHERE externaldirectoryobjectid = '$Identity'"
                }
            }
        }
        'All'
        {
            $query = "SELECT * FROM stagingDistributionGroup"
        }
    }

    Invoke-DbaQuery @iqParams -query $query

}