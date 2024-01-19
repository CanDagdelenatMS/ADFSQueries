
<#PSScriptInfo

.VERSION 1.0

.GUID 5853034f-da8c-4347-aad2-d003af21cdfd

.AUTHOR Canadmin

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
 Query ADFS Farm Servers. Supported ADFS Operating Systems are: Windows Server 2016/2019. Server 2012R2 or Server 2022, not tested.

.EXAMPLE
Query-ADFSFarmServers.ps1
ADFS is using WID. Can be run without any parameter. i.e. defaults to WID


.EXAMPLE
Query-ADFSFarmServers.ps1 -SQLServerName "sqlserver1.contoso.com"
ADFS is using a seperate SQL Server named sqlserver1.

 #>
 
 param (

[string]$SQLServerName= "WID"
  ) 
 Import-Module ADFS

 #region determine Farm Behavior Level
try {$fblevel= (Get-AdfsFarmInformation -ErrorAction Stop).CurrentFarmBehavior}
catch {$fblevel=2} #Get-AdfsFarmInformation not available in Server 2012 R2 ADFS.

    switch ($fblevel) {
    2 
        {Write-Host "This script has not been tested on Windows Server 2012 R2. Exiting..." -ForegroundColor 'red'  ;exit}
    3 
        {$adfsdbname= 'AdfsConfigurationv3' #Server 2016 Farm Behavior Level
        $dbquery = "SELECT [FQDN], [Nodetype] FROM [AdfsConfigurationV4].[IdentityServerPolicy].[FarmNodes]"
        $textoutput= "Server 2016"}

    4
       {$adfsdbname= 'AdfsConfigurationv4' #Server 2019 Farm Behavior Level
        $dbquery = "SELECT [FQDN], [Nodetype] FROM [AdfsConfigurationV4].[IdentityServerPolicy].[FarmNodes]"
        $textoutput= "Server 2019"
        }
    }
#endregion

if ($SQLServerName -eq "WID") {$SQLServerName= "server=\\.\pipe\MICROSOFT##WID\tsql\query"}
else {$SQLServerName = "Server=" + "$SQLServerName"}

#region Prepare SQL Connection String
$sqlConn = "$SQLServerName;database=$adfsdbname;trusted_connection=true;"
$conn = New-Object System.Data.SQLClient.SQLConnection($sqlConn)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = $dbquery
$rdr = $cmd.ExecuteReader()
$dt = New-Object System.Data.DataTable
$dt.Load($rdr)
$conn.Close()
$result = @()
#endregion


Write-Host -ForegroundColor Yellow "The Farm Behavior Level is $fblevel. The ADFS Servers are running on Windows $textoutput."

Write-Host "ADFS Farm Server information:"
$dt | select fqdn, @{N= 'nodetype'; E= {$_.nodetype -replace("#\w{3}",'')}}
