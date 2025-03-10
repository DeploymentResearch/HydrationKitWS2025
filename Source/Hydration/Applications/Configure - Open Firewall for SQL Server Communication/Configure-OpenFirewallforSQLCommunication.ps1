<#

************************************************************************************************************************

Created:	2021-10-07
Version:	1.0

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the author or DeploymentArtist.

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com

************************************************************************************************************************

#>

$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$Deployroot = $tsenv.Value("DeployRoot")
$env:PSModulePath = $env:PSModulePath + ";$deployRoot\Tools\Modules"

Import-Module -Name HydrationLogging

Set-HYDLogPath
write-HYDLog -Message "Starting SQL Server firewall configuration... "

New-NetFirewallRule -Name "SQL Ports for ConfigMgr" -DisplayName "SQL Ports for ConfigMgr" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1433,4022

# Validation
if (!(Get-NetFirewallRule -Name "SQL Ports for ConfigMgr")) {
    Write-HYDLog "Could not find SQL Ports for ConfigMgr firewall rule, aborting..." -LogLevel 2
    Break
}


Write-HYDLog "SQL Server firewall rules configured..." 


