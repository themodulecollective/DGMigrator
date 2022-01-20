function Invoke-DGMGroupStagingToQI
{
    [cmdletbinding()]
    param()
    $Configuration = Get-DGMConfiguration -Default

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    $qTables = @(
        'qIDistributionGroup'
    )

    #Truncate/Clean old data from staging tables selected
    foreach ($t in $qTables)
    {
        Write-PSFMessage -Level Verbose -Message "Truncating table $t"
        $null = Invoke-DbaQuery @iqParams -query "TRUNCATE TABLE $t"
    }
    #Get qSDistributionGroup

    $iqParams.as = 'PSObjectArray'
    $query = "SELECT * FROM qSDistributionGroup WHERE Action = 'AddToTarget'"
    $iqParams.query = $query
    $AddToTarget = Invoke-DbaQuery @iqParams
    $AddToTarget = $AddToTarget.where({$_.ExternalDirectoryObjectID -notin $Configuration.DistributionGroupsToIgnore})

    Write-PSFMessage -Level Verbose -Message "Processing AddToTarget: Count $($AddToTarget.count)"


    #TargetOrganizations
    $targetOrgs = @($Configuration.Organizations.where({$_.MigrationRole -eq 'Target'}))
    $WriteToQI = @(
        foreach ($to in $targetOrgs)
        {
            $tTenantDomain = $to.TenantDomain
            $tPrimaryDomain = $to.PrimaryDomain

            # To Transform: PrimarySMTPAddress, CustomAttribute11-13, EmailAddresses (add x500 for legacyexchangedn)
            # need to add MVAs that require lookups
            foreach ($sg in $AddToTarget)
            {
                #SourceOrganization Settings
                $soSettings = $Configuration.Organizations.where({$_.name -eq $sg.SourceOrganization})
                $sTenantDomain = $soSettings.TenantDomain
                $sPrimaryDomain = $soSettings.PrimaryDomain

                foreach ($m in $Configuration.SourceToTargetAttributeMap.DistributionGroup.psobject.Properties)
                {
                    $sg.$($m.Name) = $($sg.$($m.Value))
                }

                $NewDomain =
                switch ($sg.PrimarySMTPAddress)
                {
                    {$_ -like "*$sTenantDomain"}
                    {
                        $tTenantDomain
                    }
                    {$_ -like "*$sPrimaryDomain"}
                    {
                        $tPrimaryDomain
                    }
                    Default
                    {
                        $tPrimaryDomain
                    }
                }

                $NewPrimarySMTPAddress = $sg.PrimarySMTPAddress.split('@')[0] + '@' + $NewDomain
                $sg.PrimarySMTPAddress = $NewPrimarySMTPAddress

                $x500 = 'x500:' + $sg.legacyexchangedn

                $sg.EmailAddresses = @(
                    $x500
                    if ($NewDomain -eq $tPrimaryDomain)
                    {$sg.alias + '@' + $tTenantDomain}
                )
                $sg.TargetOrganization = $to.name

                $sg
            }
        }
    )

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    Write-PSFMessage -Level Verbose -Message "Writing result (intermediate objects) to table qIDistributionGroup"
    $WriteToQI | ConvertTo-DbaDataTable | Write-DbaDataTable @iqParams -Table qIDistributionGroup
}