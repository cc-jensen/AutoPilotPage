<#

.SYNOPSIS

    This script will download and install AzureAD and WindowsAutoPilotIntune modules and it will
    download and install Get-WindowsAutoPilotInfo script. It will then create autopilot csv file and it will import created csv file in the Autopilot.

.NOTES

    Author: Nedim Mehic
    Site : nedimmehic.org
    The script are provided “AS IS” with no guarantees, no warranties, and it confer no rights.




#>

$progressPreference = 'silentlyContinue'
$serial = (Get-WmiObject -Class win32_bios).serialnumber

# Intune Login Account
Write-Host "Type in the username that has premission to administer Intune and autopilot" -ForegroundColor Cyan
$user = Read-Host "Enter the e-mail address of the user that has premission to administer Intune"


# Downloading and installing Azure AD and WindowsAutoPilotIntune Module
Write-Host "Downloading and installing AzureAD module" -ForegroundColor Cyan
Install-Module AzureAD,WindowsAutoPilotIntune,Microsoft.Graph.Intune -Force

# Importing required modules
Import-Module -Name AzureAD,WindowsAutoPilotIntune,Microsoft.Graph.Intune 


# Downloading and installing get-windowsautopilotinfo script
Write-Host "Downloading and installing get-windowsautopilotinfo script" -ForegroundColor Cyan
#Install-Script -Name Get-WindowsAutoPilotInfo -Force

# Intune Login
Write-Host "Connecting to Microsoft Graph" -ForegroundColor Cyan

Try {
    Connect-MSGraph -Credential (Get-credential -username $user -message "Type in the password")
    write-host "Successfully connected to Microsoft Graph" -foregroundcolor green
}
Catch {
    write-host "Error: Could not connect to Microsoft Graph. Please login with the account that has premissions to administer Intune and autopilot or verify your password" -foregroundcolor red 
Break }


# Creating temporary folder to store autopilot csv file 

Write-Host "Checking if Temp folder exist in C:\" -ForegroundColor Cyan

IF (!(Test-Path C:\Temp) -eq $true) {

    Write-Host "Test folder was not found in C:\. Creating Test Folder..." -ForegroundColor Cyan
    New-Item -Path C:\Temp -ItemType Directory | Out-Null
}

Else { Write-Host "Test folder already exist" -ForegroundColor Green }

# Creating Autopilot csv file
Write-Host "Creating Autopilot CSV File" -ForegroundColor Cyan
Try {
    d:\Get-WindowsAutoPilotInfo.ps1 -OutputFile "C:\Temp\$serial.csv"
    Write-Host "Successfully created autopilot csv file" -ForegroundColor Green}

Catch {
    write-host "Error: Something went wrong. Unable to create csv file." -foregroundcolor red 
Break }
 

#Importing CSV File into Intune
Write-Host "Importing Autopilot CSV File into Intune" -ForegroundColor Cyan
Try {
    Import-AutoPilotCSV -csvFile "C:\Temp\$serial.csv"
    Write-Host "Successfully imported autopilot csv file" -ForegroundColor Green}

Catch {
    Write-Host "Error: Something went wrong. Please check your csv file and try again"
    Break}