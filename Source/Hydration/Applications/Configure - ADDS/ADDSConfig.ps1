$domainName = "corp.viamonstra.com"
$domainNetbiosName = "VIAMONSTRA"
$forestMode = "Win2025"
$domainMode = "Win2025"
$DSRM = "P@ssw0rd"

<#
Install-ADDSForest -DomainName $domainName -DomainNetbiosName $domainNetbiosname -ForestMode $forestMode -DomainMode $domainMode -SafeModeAdministratorPassword $DSRM


ReplicaOrNewDomain=Domain
NewDomain=Forest 
NewDomainDNSName=corp.viamonstra.com
DomainNetBiosName=VIAMONSTRA 
ForestLevel=4 
DomainLevel=4 
AutoConfigDNS=Yes 
ConfirmGC=Yes 
CriticalReplicationOnly=No 
;DatabasePath=D:\NTDS 
;ADDSLogPath=D:\NTDS
;SysVolPath=D:\SYSVOL 
SafeModeAdminPassword=P@ssw0rd 
SiteName=NewYork
#>