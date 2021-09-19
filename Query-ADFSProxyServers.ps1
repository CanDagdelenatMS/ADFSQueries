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
 [cmdletBinding(DefaultParameterSetName= '')]
 param (
[string]$ExportPath
  ) 
 Import-Module ADFS


try {$fblevel= (Get-AdfsFarmInformation -ErrorAction Stop).CurrentFarmBehavior}
catch {$fblevel=2} #Get-AdfsFarmInformation not available in Server 2012 R2 ADFS.

    switch ($fblevel) {
    2 
        {$adfsdbname= 'AdfsConfiguration' #Server 2012R2 Farm Behavior Level
        $dbquery = "SELECT ServiceSettingsData FROM [$adfsdbname].[IdentityServerPolicy].[ServiceSettings]"
        $textoutput= "Server 2012 R2"}
    3 
        {$adfsdbname= 'AdfsConfigurationv3' #Server 2016 Farm Behavior Level
        $dbquery = "SELECT [CertificateSubjectName], [CertificateThumbprint] FROM [$adfsdbname].[IdentityServerPolicy].[ProxyTrusts]"
        $textoutput= "Server 2016"}

    4
       {$adfsdbname= 'AdfsConfigurationv4' #Server 2019 Farm Behavior Level
        $dbquery = "SELECT [CertificateSubjectName], [CertificateThumbprint] FROM [$adfsdbname].[IdentityServerPolicy].[ProxyTrusts]"
        $textoutput= "Server 2019"}
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
$result = @()

if ($fblevel -eq 2) {
        $strdata= $dt.ServiceSettingsData.ToString()
        $allwaps= [regex]::matches($strdata,"<d4p1:Key>CN=ADFS ProxyTrust - .{1,50}</d4p1:Key>")
        $allwaps | foreach {
            $currentWAP= New-Object psobject
            $currentWAPName= $_.value -replace("<d4p1:Key>CN=ADFS ProxyTrust - ","") -replace("</d4p1:Key>") 
            $currentWAP | Add-Member -MemberType NoteProperty -name "ServerName" -value "$currentWAPName"
            $result+= $currentWAP
            }
        }

else {
        $dt | foreach {
            $currentWAP= New-Object psobject
            $currentWAPName= $_.CertificateSubjectName -replace("CN=ADFS ProxyTrust - ","")
            $currentWAP | Add-Member -MemberType NoteProperty -name "ServerName" -value "$currentWAPName"
            $currentWAP | Add-Member -MemberType NoteProperty -Name "CertificateThumbprint" -Value $_.CertificateThumbprint
            $result+= $currentWAP

            } 
    }
Write-Host -ForegroundColor Yellow "The Farm Behavior Level is $fblevel. The ADFS Servers are running on Windows $textoutput."

$result
if ($ExportPath) {$result | Export-Csv -Path "$ExportPath" }