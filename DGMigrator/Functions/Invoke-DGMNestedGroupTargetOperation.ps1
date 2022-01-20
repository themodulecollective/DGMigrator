function Invoke-DGMNestedGroupTargetOperation
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        $NestingArray
        ,
        [switch]$IncludeLowest
    )

    $Configuration = Get-DGMConfiguration -Default

    #TargetOrganizationSettings
    $o = $($Configuration.Organizations.where({$_.MigrationRole -eq 'Target'}))
    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name) for target organization $($o.Name)"

    $NestingLevels = @($(($NestingArray | Group-Object -Property Value -NoElement).name.where({$_ -ne -1}) | Sort-Object -Descending))

    if ($includeLowest)
    {
        $NestingLevels = @(-1; $NestingLevels)
    }


    foreach ($l in $NestingLevels)
    {
        Write-PSFMessage -level Verbose -Message "Running Update-DGMRecipientMap"
        Update-DGMRecipientMap
        Write-PSFMessage -level Verbose -Message "Running Invoke-DGMGroupStagingToQ"
        Invoke-DGMGroupStagingToQ
        Write-PSFMessage -level Verbose -Message "Running Invoke-DGMGroupTargetAddOperation -NestingArray `$NestingArray -NestingLevel $l"
        Invoke-DGMGroupTargetAddOperation -NestingArray $NestingArray -NestingLevel $l
        $externalDirectoryObjectIDs = $($NestingArray.where({$_.Value -eq $l}).Name)
        Write-PSFMessage -level Verbose -Message "Running Update-DGMDistributionGroupStaging"
        Update-DGMDistributionGroupStaging -includeOperation DistributionGroup -includeExternalDirectoryObjectID $externalDirectoryObjectIDs
    }

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"

}