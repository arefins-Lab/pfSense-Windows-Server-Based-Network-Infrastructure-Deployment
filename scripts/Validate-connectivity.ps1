<# 
.SYNOPSIS
Validates gateway reachability, DNS, routing, and DHCP failover.
#>

Write-Host "=== Gateway reachability ==="
Test-Connection 192.168.1.1 -Count 2 | Select-Object Address, ResponseTime
Test-Connection 192.168.2.1 -Count 2 | Select-Object Address, ResponseTime

Write-Host "`n=== DNS resolution via SRV-DC01 ==="
Resolve-DnsName www.microsoft.com -Server 192.168.1.210
Resolve-DnsName www.cloudflare.com -Server 192.168.1.210

Write-Host "`n=== Cross-subnet routing test ==="
Test-NetConnection -ComputerName 192.168.2.100 -InformationLevel Detailed

Write-Host "`n=== DHCP Failover status ==="
Invoke-Command -ComputerName SRV-DHCP01 -ScriptBlock { Get-DhcpServerv4Failover }
Invoke-Command -ComputerName SRV-DHCP02 -ScriptBlock { Get-DhcpServerv4Failover }
