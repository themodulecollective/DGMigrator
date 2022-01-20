function Invoke-DGMContactStagingToQI
{
    [cmdletbinding()]
    param()

    $Configuration = Get-DGMConfiguration -Default

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    $qTables = @(
        'qIContact'
    )

    #Truncate/Clean old data from staging tables selected
    foreach ($t in $qTables)
    {
        Write-PSFMessage -Level Verbose -Message "Truncating table $t"
        $null = Invoke-DbaQuery @iqParams -query "TRUNCATE TABLE $t"
    }
    #Get qSDistributionGroup

    $iqParams.as = 'PSObjectArray'
    $query = "SELECT * FROM qSContact WHERE Action = 'AddToTarget'"
    $iqParams.query = $query
    $AddToTarget = Invoke-DbaQuery @iqParams

    Write-PSFMessage -Level Verbose -Message "Processing Contact AddToTarget: Count $($AddToTarget.count)"

    #TargetOrganizations
    $targetOrgs = @($Configuration.Organizations.where({$_.MigrationRole -eq 'Target'}))
    $WriteToQI = @(
        foreach ($to in $targetOrgs)
        {

            # To Transform: PrimarySMTPAddress, CustomAttribute11-13, EmailAddresses (add x500 for legacyexchangedn)
            # need to add MVAs that require lookups
            foreach ($sc in $AddToTarget)
            {

                foreach ($m in $Configuration.SourceToTargetAttributeMap.Contact.psobject.Properties)
                {
                    $sc.$($m.Name) = $($sc.$($m.Value))
                }


                $x500 = 'x500:' + $sc.legacyexchangedn

                $sc.EmailAddresses = @(
                    $x500
                )

                $sc.TargetOrganization = $to.name

                $sc
            }
        }
    )

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    Write-PSFMessage -Level Verbose -Message "Writing result (intermediate objects) to table qIContact"
    $WriteToQI | ConvertTo-DbaDataTable | Write-DbaDataTable @iqParams -Table qIContact
}