
<#PSScriptInfo

.VERSION 1.0

.GUID 723350b1-8f51-4fac-b00d-17eab05a2cbf

.AUTHOR Can Dagdelen

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 This script queries WMI for ADFS SQL server information. It then either returns a result of 'WID' or the SQL server name. Should be run on the ADFS server.
.EXAMPLE
Get-AdfsSQLInfo.ps1
Finds out if WID or SQL Server is used. Returns either 'WID' or the SQL server name.
#> 
Param()

$DBString= (GEt-WmiObject -namespace root/ADFS -class SecurityTokenService).ConfigurationDatabaseConnectionString

$tempname= [regex]::match("$DBString", "(?i)\s*Data\s*Source\s*=\s*.+\s*;\s*Initial\s*Catalog\s*=" ) -replace "\s*Data Source="  -replace ";\s*Initial Catalog="
if ($tempname -like "np:\\.\pipe\microsoft##wid*") {
       Write-Host -ForegroundColor Yellow "ADFS server is using WID as database."}
else { Write-Host -ForegroundColor Yellow "ADFS server is using SQL Server as database. SQL Server name is $tempname"}

