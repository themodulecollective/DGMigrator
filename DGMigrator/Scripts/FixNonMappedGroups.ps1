$NotMapped = @(Invoke-DGMQuery -query 'select * from TargetGroupNotMappedToSource')
$DGMConfig = Get-DGMConfiguration -Default
$SourcePrimaryDomains = @($DGMConfig.Organizations.Where({$_.MigrationRole -eq 'Source'}).PrimaryDomain)


$Result = @(
    foreach ($nmg in $NotMapped)
    {
        $prefix = $nmg.PrimarySmtpAddress.Split('@')[0]
        $AddressMapped = @(
            foreach ($d in $SourcePrimaryDomains)
            {
                $address = $prefix + '@' + $d
                $query = "Select * FROM stagingDistributionGroup WHERE PrimarySMTPAddress = '$address'"
                Invoke-DGMQuery -query $query
            }
        )
        switch ($AddressMapped.Count)
        {
            1
            {
                $SetGroupParams = @{
                    Identity          = $nmg.externaldirectoryobjectID
                    CustomAttribute11 = $AddressMapped[0].SourceOrganization
                    CustomAttribute12 = $AddressMapped[0].externaldirectoryobjectID
                    CustomAttribute13 = $AddressMapped[0].PrimarySMTPAddress
                }
                $SetGroupParams
            }
            {$_ -gt 1}
            {
                Write-Warning -Message "Multiple ($($AddressMapped.Count)) Matches for prefix $prefix found."
            }
            Default
            {
                Write-Warning -Message "No Matches for prefix $prefix found."
            }
        }
    }
)

foreach ($r in $Result)
{
    "Set-DistributionGroup $($r | ConvertTo-Json -compress)"
    #Set-DistributionGroup @r
}
