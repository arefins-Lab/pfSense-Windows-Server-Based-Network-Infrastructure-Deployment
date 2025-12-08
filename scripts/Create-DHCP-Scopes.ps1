<# 
.SYNOPSIS
Creates DHCP scopes for 192.168.1.0/24 and 192.168.2.0/24 on SRV-DHCP01.
#>

$dhcpServer = "SRV-DHCP01"
$dnsServer  = "192.168.1.210"

# Internal-01: 192.168.1.0/24
Add-DhcpServerv4Scope `
    -ComputerName $dhcpServer `
    -Name "LAN/Internal-01" `
    -ScopeId 192.168.1.0 `
    -StartRange 192.168.1.100 `
    -EndRange 192.168.1.250 `
    -SubnetMask 255.255.255.0

Set-DhcpServerv4OptionValue `
    -ComputerName $dhcpServer `
    -ScopeId 192.168.1.0 `
    -Router 192.168.1.1 `
    -DnsServer $dnsServer `
    -DnsDomain "mylab.test"

# Internal-02: 192.168.2.0/24
Add-DhcpServerv4Scope `
    -ComputerName $dhcpServer `
    -Name "LAN/Internal-02" `
    -ScopeId 192.168.2.0 `
    -StartRange 192.168.2.100 `
    -EndRange 192.168.2.250 `
    -SubnetMask 255.255.255.0

Set-DhcpServerv4OptionValue `
    -ComputerName $dhcpServer `
    -ScopeId 192.168.2.0 `
    -Router 192.168.2.1 `
    -DnsServer $dnsServer `
    -DnsDomain "mylab.test"

# Exclusions (optional)
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer -ScopeId 192.168.1.0 -StartRange 192.168.1.251 -EndRange 192.168.1.254
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer -ScopeId 192.168.2.0 -StartRange 192.168.2.251 -EndRange 192.168.2.254

Get-DhcpServerv4Scope -ComputerName $dhcpServer | Format-Table ScopeId, Name, State
