<#

************************************************************************************************************************

Created:	2025-09-02 
Version:	1.2

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

Set-HYDLogPath
Write-HYDLog -Message "Starting ADDS Configuration for domain $domainName... "

# Read Task Sequence Variables for AD Setup
$NewDomainDNSName = $tsenv.Value("NewDomainDNSName")
$DomainNetBiosName = $tsenv.Value("DomainNetBiosName")
$ForestLevel = $tsenv.Value("ForestLevel")
$DomainLevel = $tsenv.Value("DomainLevel")
$SafeModeAdminPassword = $tsenv.Value("SafeModeAdminPassword")

# Validate Variables
$RequiredVars = @(
    'NewDomainDNSName'
    'DomainNetBiosName'
    'ForestLevel'
    'DomainLevel'
    'SafeModeAdminPassword'
)

$missing = foreach($RequiredVar in $RequiredVars){
    $var = (Get-Variable $RequiredVar -ErrorAction SilentlyContinue).Value
    if($null -eq $var -or [string]::IsNullOrWhiteSpace("$var")){
        Write-HYDLog "Missing: $RequiredVar"; $RequiredVar
    } 
    else {
        $out = if($RequiredVar -match '(?i)password|secret|token|key'){ '[value present]' } else { $var }
        Write-HYDLog "$RequiredVar`: $out"
    }
}

if($missing){ 
    Write-HYDLog ("Missing variables: {0}" -f ($missing -join ', '))
    Write-HYDLog "Aborting script..."
    Exit 1
} 
else { 
    Write-HYDLog -Message "All required variables present." 
}

# Configuring Active Directory
Try{
    Write-HYDLog -Message "Configuring Active Directory Domain Services"
    $secureDSRM = ConvertTo-SecureString -String $SafeModeAdminPassword -AsPlainText -Force

    $HashArguments = @{
        DomainName                    = $NewDomainDNSName
        DomainNetbiosName             = $DomainNetBiosName
        ForestMode                    = $ForestLevel
        DomainMode                    = $DomainLevel
        SafeModeAdministratorPassword = $secureDSRM
        NoRebootOnCompletion          = $true
        Confirm                       = $false
    }
    Install-ADDSForest @HashArguments 
    Write-HYDLog -Message "Active Directory Domain Services configured successfully"
}
Catch{
    Write-HYDLog -Message $("Failed to configure Active Directory Domain Services. Error: "+ $_.Exception.Message)
    Exit 1
}

