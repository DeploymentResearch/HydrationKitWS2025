<#

************************************************************************************************************************

Created:	2025-02-26
Version:	1.0

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the author or DeploymentArtist.

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
Author - Andrew Johnson
    Twitter: @andrewjnet
    Blog   : http://andrewj.net

************************************************************************************************************************

#>


$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$Deployroot = $tsenv.Value("DeployRoot")
$env:PSModulePath = $env:PSModulePath + ";$deployRoot\Tools\Modules"

Import-Module -Name HydrationLogging

# Figure out Source path
If($psISE){
    $SourcePath = Split-Path -parent $psISE.CurrentFile.FullPath
}
else{
    $SourcePath = $PSScriptRoot
}

#Load config file containing install parameters
. "$($sourcePath)\ADDSConfig.ps1"

Set-HYDLogPath
Write-HYDLog -Message "Starting ADDS Configuration for domain $domainName... "

$secureDSRM = ConvertTo-SecureString -String $DSRM
Install-ADDSForest -DomainName $domainName -DomainNetbiosName $domainNetbiosname -ForestMode $forestMode -DomainMode $domainMode -SafeModeAdministratorPassword (ConvertTo-SecureString -String $DSRM -AsPlainText -Force) -NoRebootOnCompletion -Confirm:$false

#Install Validation
$newDomain = Get-ADDomain
$newForest = Get-ADForest

if (!$newDomain) {
    Write-HYDLog -Message "Domain configuration failed! aborting..." -LogLevel 2; Break
}
else {
    Write-HYDLog -Message "Domain configuration completed successfully."
}