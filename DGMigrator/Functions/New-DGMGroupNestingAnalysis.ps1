Function New-DGMGroupNestingAnalysis
{
    [cmdletbinding()]
    param
    (
        $KeyAttribute = 'ExternalDirectoryObjectID'
        ,
        $TargetGroupKeyAttribute = 'CustomAttribute12'
    )

    Write-PSFMessage -level Verbose -Message "Processing operation $($MyInvocation.MyCommand.Name)"

    $Configuration = Get-DGMConfiguration -Default

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
    }

    $iqParams = @{
        SQLInstance = $Configuration.SQLInstance
        Database    = $Configuration.Name
        as          = 'PSObject'
    }

    $getGroupsQuery = $ExecutionContext.InvokeCommand.ExpandString($SqlScripts.selectGroupAddToTargetFromQI)
    $Groups = Invoke-DbaQuery @iqParams -query $getGroupsQuery
    $getExistingGroupsQuery = $ExecutionContext.InvokeCommand.ExpandString($SqlScripts.selectExistingGroupFromStagingTarget)
    $existingGroups = Invoke-DbaQuery @iqParams -query $getExistingGroupsQuery | Select-Object -ExpandProperty $TargetGroupKeyAttribute
    $existingGroupsLookup = @{}
    $existingGroups.foreach({
            $existingGroupsLookup.$_ = $_
        })

    $OutputGroups = @{}
    $NestingLevel = -1
    #Nesting levels start with 0 but 0 will be last processed - the groups that contain other groups that must come before

    $NoMoreNests = $false

    Do
    {
        $NLCount = 0
        $gCount = 0
        $RemainingGroups = @($Groups.where({-not $OutputGroups.ContainsKey($_.$KeyAttribute)}))
        $gTotalCount = $RemainingGroups.count
        Write-PSFMessage -Message "Begin Nesting Level $NestingLevel"
        foreach ($group in $RemainingGroups)
        {

            $gCount++
            $gWPParams = @{
                Activity         = "Processing Group Nesting. Current Level: $NestingLevel Assignments: $NLCount"
                Status           = "$($OutputGroups.Keys.count) of All $($Groups.count) Level Assignments"
                CurrentOperation = "$($gTotalCount - $gCount) of $gTotalCount Remaining Groups."
                PercentComplete  = $gCount/$gTotalCount * 100
                ID               = 0
            }
            Write-Progress @gWPParams

            Write-PSFMessage -message "Nesting Level $NestingLevel; Processing Group $($group.$KeyAttribute). Running MemberOfThisGroup and ThisGroupMemberOf Queries."
            $qMemberOfThisGroup = "SELECT $KeyAttribute FROM stagingDistributionGroupRole WHERE RecipientTypeDetails IN ('MailUniversalSecurityGroup','MailUniversalDistributionGroup') AND Role = 'MemberOf' AND TargetGroup$KeyAttribute = '$($group.$KeyAttribute)'"
            Write-PSFMessage -message "Running Query: $qMemberOfThisGroup"
            $rMemberOfThisGroup = @(Invoke-DbaQuery @iqParams -query $qMemberOfThisGroup | Select-Object -ExpandProperty $KeyAttribute)
            $qThisGroupMemberOf = "SELECT TargetGroup$KeyAttribute FROM stagingDistributionGroupRole WHERE Role = 'MemberOf' AND $KeyAttribute = '$($group.$KeyAttribute)'"
            Write-PSFMessage -message "Running Query: $qThisGroupMemberOf"
            $rThisGroupMemberOf = @(Invoke-DbaQuery @iqParams -query $qThisGroupMemberOf | Select-Object -ExpandProperty "TargetGroup$KeyAttribute")

            switch ($NestingLevel)
            {
                -1
                {
                    #Groups that have no relation to nesting as container or contained
                    If ($rThisGroupMemberOf.count -eq 0 -and $rMemberOfThisGroup.count -eq 0)
                    {
                        Write-PSFMessage -message "Adding group $($group.$KeyAttribute) to NestingLevel $NestingLevel"
                        $OutputGroups.$($group.$KeyAttribute) = $NestingLevel
                        $NLCount++
                    }
                }
                0
                {
                    #Groups that can only be a container so they go after their contained groups
                    If ($rThisGroupMemberOf.count -eq 0 -and $rMemberOfThisGroup.count -ge 1)
                    {
                        Write-PSFMessage -message "Adding group $($group.$KeyAttribute) to NestingLevel $NestingLevel"
                        $OutputGroups.$($group.$KeyAttribute) = $NestingLevel
                        $NLCount++
                    }
                }
                {$_ -gt 0 -and $false -eq $NoMoreNests}
                {
                    #Groups that are contained and they go before their containers
                    if ($rThisGroupMemberOf.count -ge 1)
                    {
                        $tests = @(
                            foreach ($mo in $rThisGroupMemberOf)
                            {
                                $(
                                    ($OutputGroups.ContainsKey($mo) -and $OutputGroups.$mo -lt $NestingLevel) -or
                                    ($existingGroupsLookup.ContainsKey($mo))
                                )
                            }
                        )
                        if ($tests -notcontains $false)
                        {
                            Write-PSFMessage -message "Adding group $($group.$KeyAttribute) to NestingLevel $NestingLevel"
                            $OutputGroups.$($group.$KeyAttribute) = $NestingLevel
                            $NLCount++
                        }
                    }
                }
            }
        }
        Write-PSFMessage -Message "End Nesting Level $NestingLevel"
        switch ($OutputGroups.Keys.Count)
        {
            {$_ -eq $Groups.count}
            {
                Write-PSFMessage -Message "$($OutputGroups.Keys.Count) of $($Groups.Count) completed"
                Write-PSFMessage -Message "No More Nests Required"
                $NoMoreNests = $true
            }
            {$_ -lt $Groups.Count}
            {
                Write-PSFMessage -Message "$($OutputGroups.Keys.Count) of $($Groups.Count) completed."
            }
        }
        $NestingLevel++
    }
    Until
    ($NoMoreNests)
    $OrderedGroups = $OutputGroups.GetEnumerator() | Select-Object Name, Value | Sort-Object -Property Value -Descending
    $OrderedGroups

    Write-PSFMessage -level Verbose -Message "Completed operation $($MyInvocation.MyCommand.Name)"

}
