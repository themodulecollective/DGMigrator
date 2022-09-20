function Get-DistributionGroupMessageTrace
{
    [cmdletbinding(DefaultParameterSetName = 'SpecifiedDistributionGroups')]
    param(
        [parameter(Mandatory, ParameterSetName = 'SpecifiedDistributionGroups')]
        [string[]]$Identity
        ,
        [parameter(Mandatory, ParameterSetName = 'All')]
        [switch]$all
        ,
        [parameter(Mandatory)]
        [datetime]$StartDate
        ,
        [parameter(Mandatory)]
        [datetime]$EndDate
        ,
        [parameter()]
        [int]$BatchSize = 100
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'All'
        {
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
    foreach ($r in $Ranges)
    {
        $GetParams.RecipientAddress = $Identity[$r.start..$r.end]
        Get-MessageTrace @GetParams | Select-Object -Property $Properties
    }
}