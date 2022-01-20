function New-DGMDatabase
{
    [cmdletbinding()]
    param(

    )
    $Configuration = Get-DGMConfiguration -Default
    #Set-Service -name SQLBrowser -StartupType Automatic
    #Start-DBAService -Type Browser

    $dbParams = @{
        SQLInstance = $Configuration.SQLInstance
    }

    $existingDatabase = Get-DbaDatabase @dbParams -Database $Configuration.Name

    $newDatabase =
    if ($null -eq $existingDatabase)
    {
        #add try/catch
        New-DbaDatabase @dbParams -Name $Configuration.Name -RecoveryModel Simple
        Start-Sleep -Seconds 2
        Update-DGMDatabaseSchema
    }
    else
    {
        throw("Database $($Configuration.Name) already exists on $($Configuration.SQLInstance)")
    }

}