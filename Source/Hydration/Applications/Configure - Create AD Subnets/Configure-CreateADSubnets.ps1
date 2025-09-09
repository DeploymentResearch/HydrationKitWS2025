<#
Solution: Hydration
Purpose: Used to create AD Sites and Subnets
Version: 1.2 - January 10, 2013

This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or Deployment Artist. 

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
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
Write-HYDLog -Message "Starting Creation of AD Subnets..."

# Read Task Sequence Variables for AD configuration
$SiteName = $tsenv.Value("SiteName")

if($null -eq $SiteName -or [string]::IsNullOrWhiteSpace("$SiteName")){
    Write-HYDLog "Sitename value is missing, aborting..."
    Exit 1
} 
else {
    Write-HYDLog "Sitename value is $Sitename"
}

# Rename the default Active Directory Site
Write-HYDLog -Message "Rename the default AD site to $SiteName"
Try{
    Get-ADReplicationSite Default-First-Site-Name | Rename-ADObject -NewName $SiteName -ErrorAction Stop
    Write-HYDLog -Message "Successfully renamed Default-First-Site-Name to $SiteName"
}
Catch{
    Write-HYDLog -Message $("Failed to rename site in AD Sites and Services. Error: "+ $_.Exception.Message) -LogLevel 2
    Exit 1
}

# Create Empty AD Sites (sites with no domain controllers, for lab purpose only)
Write-HYDLog -Message "Creating Empty AD Sites (sites with no domain controllers, for lab purpose only)"
New-ADReplicationSite -Name Stockholm
New-ADReplicationSite -Name Liverpool

# Create AD Subnets 
Write-HYDLog -Message "Creating AD Subnets"
New-ADReplicationSubnet -Name "192.168.25.0/24" -Site NewYork
New-ADReplicationSubnet -Name "192.168.26.0/24" -Site Stockholm
New-ADReplicationSubnet -Name "192.168.27.0/24" -Site Liverpool

Write-HYDLog -Message "Done" 

