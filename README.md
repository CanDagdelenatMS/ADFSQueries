For cases ADFS environment is not documented, and/or admins having limited knowledge on ADFS (e.g. Primary ADFS admin leaves the company).

Whatever the reason, you maybe required to query registered WAPs of a given ADFS environment. The script does just that.

For 2016/2019 ADFS Servers: Since WAP servers authenticate via their self-signed ADFS Proxy Trust certificate, and that is stored under a different table, it is easy to query.

For 2012R2 ADFS Servers: WAP / certificate information is not easily discoverable. Therefore, all service settings is queried and filtered with Regex Text filtering.