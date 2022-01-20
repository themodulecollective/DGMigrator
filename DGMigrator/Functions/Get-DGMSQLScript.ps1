function  Get-DGMSQLScript
{
    [cmdletbinding()]
    param(
        $Name
    )

    $Script:SQLScripts.$Name
}