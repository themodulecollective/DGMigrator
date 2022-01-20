$UpdateNeeded = @(Invoke-DGMQuery -query 'select * from stagingDistributionGroup where customattribute12 is not null')
$DGMConfig = Get-DGMConfiguration -Default


$Result = @(
    foreach ($g in $UpdateNeeded)
    {
        $SetGroupParams = @{
            Identity          = $g.externaldirectoryobjectID
            CustomAttribute11 = $g.CustomAttribute13
            CustomAttribute13 = $g.CustomAttribute11
        }
        $SetGroupParams
    }
)

foreach ($r in $Result)
{
    "Set-DistributionGroup $($r | ConvertTo-Json -compress)"
    #Set-DistributionGroup @r
}
