function Get-DistributionGroupMessageTrace {
    <#
    .SYNOPSIS
        Get message trace for specified or all distribution groups.
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .EXAMPLE
        Get-DistributionGroupMessageTrace -Identity MessageGroup@contoso.com -StartDate 04/20/22 -Enddate 4/28/22
        Get the message trace for the specified group during the specified time period
    #>
    
    [cmdletbinding(DefaultParameterSetName = 'SpecifiedDistributionGroups')]
    param(
        # Specify the distribution group
        [parameter(Mandatory, ParameterSetName = 'SpecifiedDistributionGroups')]
        [string[]]$Identity
        ,
        # Select all distribution groups
        [parameter(Mandatory, ParameterSetName = 'All')]
        [switch]$all
        ,
        # Start date for message trace query
        [parameter(Mandatory)]
        [datetime]$StartDate
        ,
        # End date for message trace query
        [parameter(Mandatory)]
        [datetime]$EndDate
        ,
        # Specify Batch Size. Default 100
        [parameter()]
        [int]$BatchSize = 100
    )

    switch ($PSCmdlet.ParameterSetName) {
        'All' {
            $GetParams = @{
                RecipientTypeDetails = 'MailUniversalDistributionGroup'
                ResultSize           = 'Unlimited'
                ErrorAction          = 'Stop'
            }
            $Identity = @(
                Get-EXORecipient @GetParams | Select-Object -ExpandProperty 'PrimarySMTPAddress'
            )
        }
    }

    $Properties = @('Organization', 'MessageID', 'Received', 'SenderAddress', 'RecipientAddress', 'ToIP', 'FromIP', 'MessageTraceId', 'StartDate', 'EndDate')
    $GetParams = @{
        RecipientAddress = $null
        StartDate        = $StartDate
        EndDate          = $EndDate
        PageSize         = 5000
        Status           = 'Expanded'
    }
    $Ranges = New-SplitArrayRange -inputArray $Identity -Size $BatchSize
    foreach ($r in $Ranges) {
        $GetParams.RecipientAddress = $Identity[$r.start..$r.end]
        Get-MessageTrace @GetParams | Select-Object -Property $Properties
    }
}