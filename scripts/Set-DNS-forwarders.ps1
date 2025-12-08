<# 
.SYNOPSIS
Configures DNS forwarders on SRV-DC01 to Cloudflare.
#>

Add-DnsServerForwarder -IPAddress 1.1.1.1
Add-DnsServerForwarder -IPAddress 1.0.0.1

Get-DnsServerForwarder
