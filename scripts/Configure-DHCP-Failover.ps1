<# 
.SYNOPSIS
Configures DHCP failover between SRV-DHCP01 and SRV-DHCP02.
#>

$Primary = "SRV-DHCP01"
$Partner = "SRV-DHCP02"
$Secret  = "LabSecret123!"

# Scopes to pair
$Scopes = @(192.168.1.0, 192.168.2.0)

Add-DhcpServerv4Failover `
    -ComputerName $Primary `
    -Name "DHCP-Failover" `
    -PartnerServer $Partner `
    -ScopeId $Scopes `
    -SharedSecret $Secret `
    -Mode LoadBalance `
    -LoadBalancePercent 50

Get-DhcpServerv4Failover -ComputerName $Primary
Get-DhcpServerv4Failover -ComputerName $Partner
