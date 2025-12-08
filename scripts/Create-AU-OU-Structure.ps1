<# 
.SYNOPSIS
Creates departmental OUs and example groups in mylab.test.
#>

Import-Module ActiveDirectory

$root = "DC=mylab,DC=test"

New-ADOrganizationalUnit -Name "ACC"   -Path $root
New-ADOrganizationalUnit -Name "MGT"   -Path $root
New-ADOrganizationalUnit -Name "Admin" -Path $root
New-ADOrganizationalUnit -Name "HR"    -Path $root

New-ADGroup -Name "NetOps_Admins" -GroupScope Global -Path "OU=Admin,$root"
New-ADGroup -Name "HR_Readers"    -GroupScope Global -Path "OU=HR,$root"
