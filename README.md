# Enterprise-lab Project(pfSense + Windows Server)
Enterprise‑style home lab using pfSense and Windows Server. Includes subnet segmentation, DHCP failover (SRV‑DHCP01 &amp; SRV‑DHCP02), and AD DS domain mylab.test, DNS forwarders (1.1.1.1 &amp; 1.0.0.1), and PowerShell automation for scopes, OU structure, and validation. Portfolio‑ready and reproducible.
Repository structure
/docs
architecture-and-ip-plan.md
runbook-phase-1.md
/configs
pfSense-interface-and-firewall-notes.md
/scripts
Install-ADDS-Forest.ps1
Set-DNS-Forwarders.ps1
Create-DHCP-Scopes.ps1
Configure-DHCP-Failover.ps1
Create-AD-OU-Structure.ps1
Validate-Connectivity.ps1
# Enterprise Lab Segmentation (pfSense + Windows Server)
## Overview
A segmented, enterprise-style home lab using pfSense (router/firewall) and Windows Server (AD DS, DNS, DHCP). It demonstrates clean subnet design, DHCP failover, DNS forwarders to Cloudflare, and reproducible automation via PowerShell.
## Architecture
- pfSense:
  - WAN: 192.168.0.50/24 (Gateway: 192.168.0.1)
  - LAN/Internal-01: 192.168.1.1/24
  - LAN/Internal-02: 192.168.2.1/24
- Windows Server:
  - SRV-DC01 (Domain Controller): 192.168.1.210 — Domain: mylab.test
  - SRV-DHCP01 (Primary DHCP): 192.168.1.215
  - SRV-DHCP02 (Failover DHCP): 192.168.1.216
- DNS Forwarders (SRV-DC01): 1.1.1.1, 1.0.0.1

## Subnet plan
- LAN/Internal-01 (Corp/Services): 192.168.1.0/24 — GW 192.168.1.1
- LAN/Internal-02 (Lab/Test): 192.168.2.0/24 — GW 192.168.2.1
- Departmental expansion (Phase‑2):
  - LAN/Internal-04 (ACC): 192.168.4.0/24 — GW 192.168.4.1
  - LAN/Internal-05 (MGT): 192.168.5.0/24 — GW 192.168.5.1
  - LAN/Internal-06 (Admin): 192.168.6.0/24 — GW 192.168.6.1
  - LAN/Internal-07 (HR): 192.168.7.0/24 — GW 192.168.7.1

## DHCP scope ranges (Phase‑1)
- Internal‑01: 192.168.1.100 – 192.168.1.250 (GW 192.168.1.1, DNS 192.168.1.210)
- Internal‑02: 192.168.2.100 – 192.168.2.250 (GW 192.168.2.1, DNS 192.168.1.210)

## Prerequisites
- Hyper‑V/VMware VMs with pfSense ISO and Windows Server 2019/2022 ISO
- Static IPs set per plan
- Administrative PowerShell on Windows servers

## Setup steps (Phase‑1)
1. pfSense:
   - Assign WAN, Internal‑01, Internal‑02.
   - Outbound NAT (automatic) for both subnets.
2. Windows Server:
   - Promote SRV‑DC01 to a domain controller (mylab.test).
   - Configure DNS forwarders to 1.1.1.1 & 1.0.0.1.
   - Install DHCP on SRV‑DHCP01 & SRV‑DHCP02.
   - Create scopes for Internal‑01 & Internal‑02.
   - Configure DHCP failover between SRV‑DHCP01 and SRV‑DHCP02.
3. Validate:
   - Run validation scripts and capture screenshots.

## Scripts
All automation is in /scripts: AD DS, DNS forwarders, DHCP scopes, failover, OU structure, and validation.

## Security notes
- Apply least‑privilege firewall rules between subnets; allow only required ports (DNS, ICMP, RDP/SMB where needed).
- Prefer Windows DNS for internal name resolution; pfSense uses forwarders or remains stateless for DNS.

## Roadmap
- Phase‑2: Add ACC/MGT/Admin/HR (Internal‑04..07) via VLANs or extra NICs, then extend DHCP and firewall policies.
- Phase‑3: Diagrams, screenshots, and README polish with test outcomes.

# Promote SRV-DC01 to a domain controller and install DNS
# Run as Administrator on SRV-DC01

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
  -DomainName "mylab.test" `
  -DomainNetbiosName "MYLAB" `
  -SafeModeAdministratorPassword (ConvertTo-SecureString "ChangeThisP@ss!" -AsPlainText -Force) `
  -InstallDns:$true `
  -Force:$true

# After reboot, verify
Get-ADDomain
Get-WindowsFeature DNS
Set-DNS-Forwarders.ps1
powershell
# Configure DNS forwarders on SRV-DC01 to Cloudflare public resolvers
# Run on SRV-DC01

Add-DnsServerForwarder -IPAddress 1.1.1.1
Add-DnsServerForwarder -IPAddress 1.0.0.1

# Verify
Get-DnsServerForwarder
Create-DHCP-Scopes.ps1
# Create DHCP scopes using specified ranges on SRV-DHCP01
# Run on SRV-DHCP01 (192.168.1.215) with DHCP role installed

$dhcpServer = "SRV-DHCP01"
$dnsServer  = "192.168.1.210"

# Internal-01: 192.168.1.0/24
Add-DhcpServerv4Scope -ComputerName $dhcpServer -Name "LAN/Internal-01" `
  -ScopeId 192.168.1.0 -StartRange 192.168.1.100 -EndRange 192.168.1.250 -SubnetMask 255.255.255.0

Set-DhcpServerv4OptionValue -ComputerName $dhcpServer -ScopeId 192.168.1.0 `
  -Router 192.168.1.1 -DnsServer $dnsServer -DnsDomain "mylab.test"

# Internal-02: 192.168.2.0/24
Add-DhcpServerv4Scope -ComputerName $dhcpServer -Name "LAN/Internal-02" `
  -ScopeId 192.168.2.0 -StartRange 192.168.2.100 -EndRange 192.168.2.250 -SubnetMask 255.255.255.0

Set-DhcpServerv4OptionValue -ComputerName $dhcpServer -ScopeId 192.168.2.0 `
  -Router 192.168.2.1 -DnsServer $dnsServer -DnsDomain "mylab.test"

# Exclusions (reserve high range for static servers if desired)
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer -ScopeId 192.168.1.0 -StartRange 192.168.1.251 -EndRange 192.168.1.254
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer -ScopeId 192.168.2.0 -StartRange 192.168.2.251 -EndRange 192.168.2.254

# Health check
Get-DhcpServerv4Scope -ComputerName $dhcpServer | Format-Table ScopeId, Name, State

Configure-DHCP-Failover.ps1
# Configure DHCP failover between SRV-DHCP01 and SRV-DHCP02
# Run on SRV-DHCP01. Ensure the DHCP role is installed on both servers.

$Primary = "SRV-DHCP01"
$Partner = "SRV-DHCP02"
$Secret  = "LabSecret123!"

# Scopes to pair (existing on Primary)
$Scopes = @(192.168.1.0, 192.168.2.0)

# Create failover relationship (Load Balance 50/50)
Add-DhcpServerv4Failover -ComputerName $Primary `
  -Name "DHCP-Failover" `
  -PartnerServer $Partner `
  -ScopeId $Scopes `
  -SharedSecret $Secret `
  -Mode LoadBalance `
  -LoadBalancePercent 50

# Verify on both servers
Get-DhcpServerv4Failover -ComputerName $Primary
Get-DhcpServerv4Failover -ComputerName $Partner

Create-AD-OU-Structure.ps1
# Departmental OUs aligned to future segmentation
# Run on SRV-DC01 after domain promotion

Import-Module ActiveDirectory

New-ADOrganizationalUnit -Name "ACC"   -Path "DC=mylab, DC=test"
New-ADOrganizationalUnit -Name "MGT"   -Path "DC=mylab, DC=test"
New-ADOrganizationalUnit -Name "Admin" -Path "DC=mylab, DC=test" 
New-ADOrganizationalUnit -Name "HR"    -Path "DC=mylab, DC=test"

# Example groups
New-ADGroup -Name "NetOps_Admins" -GroupScope Global -Path "OU=Admin,DC=mylab,DC=test"
New-ADGroup -Name "HR_Readers"    -GroupScope Global -Path "OU=HR,DC=mylab,DC=test"

Validate-Connectivity.ps1# Run from a management VM joined to mylab.test

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

/configs
pfSense-interface-and-firewall-notes.md
# pfSense Interface and Firewall Notes

## Interfaces
- WAN: 192.168.0.50/24 — Gateway 192.168.0.1
- LAN/Internal-01: 192.168.1.1/24 — DHCP Disabled (Windows handles)
- LAN/Internal-02: 192.168.2.1/24 — DHCP Disabled (Windows handles)

## DNS
- Internal DNS: SRV-DC01 (192.168.1.210) with forwarders 1.1.1.1, 1.0.0.1.

## NAT
- Outbound NAT: Automatic for both internal subnets (default).
- If Manual: add mappings for 192.168.1.0/24 and 192.168.2.0/24 to WAN.

## Firewall Rules (baseline intent)
- Internal-01 → WAN: Allow any (tighten later).
- Internal-02 → WAN: Allow any (tighten later).
- Internal-01 ↔ Internal-02: Allow ICMP/DNS/RDP/SMB as needed; block others.

/docs
architecture-and-ip-plan.md
# Architecture and IP Plan

## Core components
- pfSense with WAN + two LAN interfaces (Internal-01, Internal-02)
- Windows Server:
  - SRV-DC01: 192.168.1.210 (mylab.test)
  - SRV-DHCP01: 192.168.1.215
  - SRV-DHCP02: 192.168.1.216 (failover)

## IP plan
- WAN: 192.168.0.0/24 — pfSense 192.168.0.50
- Internal-01: 192.168.1.0/24 — GW 192.168.1.1 — Scope 192.168.1.100–192.168.1.250
- Internal-02: 192.168.2.0/24 — GW 192.168.2.1 — Scope 192.168.2.100–192.168.2.250
- Future: Internal-04..07 — Departmental subnets (ACC/MGT/Admin/HR)

## Checkpoints
- pfSense interfaces assigned and online
- AD DS installed (mylab.test), and DNS forwarders set
- DHCP scopes created, and the failover relationship is healthy
- Cross-subnet connectivity validated

runbook-phase-1.md
# Runbook — Phase 1 (Internal-01 / Internal-02)

## Sequence
1. pfSense: assign interfaces; confirm WAN reachability.
2. SRV-DC01: run Install-ADDS-Forest.ps1, then Set-DNS-Forwarders.ps1.
3. SRV-DHCP01: install DHCP; run Create-DHCP-Scopes.ps1.
4. SRV-DHCP02: install DHCP.
5. SRV-DHCP01: run Configure-DHCP-Failover.ps1.
6. Validation: run Validate-Connectivity.ps1 from a client VM.

## Expected results
- Domain mylab.test online; DNS forwarders set to 1.1.1.1 & 1.0.0.1.
- Clients receive leases in specified ranges with the correct gateway and DNS.
- DHCP failover shows a healthy LoadBalance relationship.
- Cross-subnet pings and name resolution succeed.





