<#

************************************************************************************************************************

Created:	2025-4-3
Version:	1.0

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the author or DeploymentArtist.

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : https://deploymentresearch.com
Author - Andrew Johnson
    Twitter: @andrewjnet
    Blog   : https://deploymentresearch.com

************************************************************************************************************************

#>
New-Item -Path "C:\" -Name "Logfiles" -ItemType "Directory"
Start-Transcript -Path "C:\Logfiles\Transcript.log"

whoami
Import-Module SQLPS

$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$Deployroot = $tsenv.Value("DeployRoot")
$env:PSModulePath = $env:PSModulePath + ";$deployRoot\Tools\Modules"
$LogPath = $tsenv.Value("LogPath")

Import-Module -Name HydrationLogging

# Figure out Source path
If ($psISE) {
    $SourcePath = Split-Path -parent $psISE.CurrentFile.FullPath
}
else {
    $SourcePath = $PSScriptRoot
}
Set-HYDLogPath
Write-HYDLog -Message "Starting setup... "

#Check if SQL Server service is running and if not, start it
$SqlServiceName = "MSSQLSERVER"
$service = Get-Service -Name $SqlServiceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-HYDLog -Message "SQL Server service not found. Ensure SQL Server is installed and the service name is correct."
} elseif ($service.Status -eq 'Running') {
    Write-HYDLog -Message "SQL Server is already running."
} else {
    Write-HYDLog -Message "SQL Server is not running. Attempting to start the service..."
    try {
        Start-Service -Name $SqlServiceName
        Write-HYDLog -Message "SQL Server has been started successfully."
    } catch {
        Write-HYDLog -Message "Failed to start SQL Server: $_"
    }
}



$SiteServer = "PS1"
$SQLFile = "$($sourcePath)\New-HYDConfigMgrDatabase.sql"
$SQLServer = "localhost"

Write-HYDLog -Message "Using Site Server: $($SiteServer)"
Write-HYDLog -Message "Using SQL Creation Script: $($SQLFile)"
Write-HYDLog -Message "Using SQL Server: $($SQLServer)"

Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile $SQLFile -Verbose

try {
    Get-SqlDatabase -ServerInstance $SQLServer -Name "CM_$($SiteServer)" -ErrorAction Stop
}
catch {
    Write-HYDLog -Message "Failed to create database CM_$($SiteServer)"
}

Stop-Transcript