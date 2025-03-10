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
write-HYDLog -Message "Starting MDT firewall configuration... "

New-NetFirewallRule -Name "Ports for SQL Server Browser" -DisplayName "Ports for SQL Server Browser" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 1434

# Validation
if (!(Get-NetFirewallRule -Name "Ports for SQL Server Browser")) {
    Write-HYDLog "Could not find SQL Server Browser firewall rule, aborting..." -LogLevel 2
    Break
}

Write-HYDLog "Firewall rules for MDT configured..." 


