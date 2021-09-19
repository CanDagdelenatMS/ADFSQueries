<#PSScriptInfo

.VERSION 1.0

.GUID 55383ee5-3a82-4206-9e95-8b8ca2b5dafd

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
 Query WAP / ADFS Proxy Servers for ADFS 

 #> 
 Import-Module ADFS
$exportlocation= "c:\script"
if (Test-Path "$exportlocation\2012WAPList.txt") {Remove-Item "2012WAPList.txt"}



try {$fblevel= (Get-AdfsFarmInformation -ErrorAction Stop).CurrentFarmBehavior}
catch {$fblevel=2} #Get-AdfsFarmInformation not available in Server 2012 R2 ADFS.

    switch ($fblevel) {
    2 
        {$adfsdbname= 'AdfsConfiguration' #Server 2012R2 Farm Behavior Level
        $dbquery = "SELECT ServiceSettingsData FROM [$adfsdbname].[IdentityServerPolicy].[ServiceSettings]"}
    3 
        {$adfsdbname= 'AdfsConfigurationv3' #Server 2016 Farm Behavior Level
        $dbquery = "SELECT [CertificateSubjectName], [CertificateThumbprint] FROM [$adfsdbname].[IdentityServerPolicy].[ProxyTrusts]"}

    4
       {$adfsdbname= 'AdfsConfigurationv4' #Server 2019 Farm Behavior Level
        $dbquery = "SELECT [CertificateSubjectName], [CertificateThumbprint] FROM [$adfsdbname].[IdentityServerPolicy].[ProxyTrusts]"}
    }

$sqlConn = "server=\\.\pipe\MICROSOFT##WID\tsql\query;database=$adfsdbname;trusted_connection=true;"
$conn = New-Object System.Data.SQLClient.SQLConnection($sqlConn)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = $dbquery
$rdr = $cmd.ExecuteReader()
$dt = New-Object System.Data.DataTable
$dt.Load($rdr)
$conn.Close()
if ($fblevel -eq 2) {
        $strdata= $dt.ServiceSettingsData.ToString()
        $allwaps= [regex]::matches($strdata,"<d4p1:Key>CN=ADFS ProxyTrust - .{1,50}</d4p1:Key>")
        $allwaps | foreach {$_.value -replace("<d4p1:Key>CN=ADFS ProxyTrust - ","") -replace("</d4p1:Key>") >> "$exportlocation\2012WAPList.txt"}
        }

else { $dt | Export-csv -Path "$exportlocation\2016_2019WAPList.txt" }

