Hello ADFS admins,
For cases ADFS environment is not documented, and/or admins having limited knowledge on ADFS (e.g. Primary ADFS admin leaves the company).

Whatever the reason, you maybe required to query registered WAPs or find out whether ADFS uses WID or SQL.

2 scripts to get info about the ADFS environment.
1.  Query-ADFSProxyServers
    For **2016**/**2019** ADFS Servers: Since WAP servers authenticate via their self-signed ADFS Proxy Trust certificate, and that is stored under a different table, it is easy   to query.
    For **2012R2** ADFS Servers: WAP / certificate information is not easily discoverable. Therefore, all service settings is queried and filtered with Regex Text filtering.
    Script can query both the WID DB and the SQL DB (by default queries for WID). 
    If you know the SQL Server name, can use -SQLServerName parameter.
2. Get-ADFSSQLInfo
    Is a real simple script to query WMI and find out the name of the SQL Server or if ADFS uses WID. Hence it either returns 'WID' or the SQL server name.

    
  
