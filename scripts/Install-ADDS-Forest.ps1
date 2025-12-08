<# 
.SYNOPSIS
Installs a new AD DS forest for domain mylab.test and DNS on SRV-DC01.
#>

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

$SafeModePassword = ConvertTo-SecureString "ChangeThisP@ss!" -AsPlainText -Force

Install-ADDSForest `
    -DomainName "mylab.test" `
    -DomainNetbiosName "MYLAB" `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns:$true `
    -Force:$true
