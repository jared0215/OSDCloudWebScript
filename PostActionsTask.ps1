$RegistryPath = "HKLM:\SOFTWARE\OSDCloud"
$ScriptFolder = Join-Path $env:ProgramData 'OSDCloud'
$ScriptPath = Join-Path $ScriptFolder 'PostActions.ps1'
$ScheduledTaskName = 'OSDCloudPostAction'

# Ensure script directory exists
if (!(Test-Path -Path $ScriptFolder)) {
    New-Item -Path $ScriptFolder -ItemType Directory -Force | Out-Null
}

# Registry keys for tracking
New-Item -Path $RegistryPath -ItemType Directory -Force | Out-Null
New-ItemProperty -Path $RegistryPath -Name "TriggerPostActions" -PropertyType dword -Value 1 -Force | Out-Null

# Register Scheduled Task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -RunOnlyIfNetworkAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
$principal = New-ScheduledTaskPrincipal "NT Authority\SYSTEM" -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Description "OSDCloud Post Action" -Principal $principal
Register-ScheduledTask $ScheduledTaskName -InputObject $task -User "SYSTEM"

# Write the PostActions script
$PostActionScript = @'

$RegistryPath = "HKLM:\SOFTWARE\OSDCloud"
$ScheduledTaskName = 'OSDCloudPostAction'

#Get Current Run, Cleanup if = 5
[int] $CurrentRun = Get-ItemPropertyValue -Path $RegistryPath -Name 'TriggerPostActions'
if ($CurrentRun -ge 5){Unregister-ScheduledTask -TaskName $ScheduledTaskName -confirm:$false -ErrorAction SilentlyContinue}
    
#Update Post Actions Count
$UpdateCountTo = $CurrentRun + 1
New-ItemProperty -Path $RegistryPath -Name "TriggerPostActions" -PropertyType dword -Value $UpdateCountTo -force | Out-Null

#Import Functions from GitHUb
iex (irm https://functions.garytown.com)

#Update TimeZone 
Set-TimeZoneFromIP

#Trigger Store Updates
Invoke-UpdateScanMethodMSStore

#Enable Microsoft Other Updates:
# The following GUID enables Microsoft Update for Windows Update (adds Microsoft Update service)
(New-Object -com "Microsoft.Update.ServiceManager").AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")

if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Force | Out-Null
}
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name RestartNotificationsAllowed2 -PropertyType dword -Value 1 -Force | Out-Null
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name RestartNotificationsAllowed2 -PropertyType dword -Value 1


#Wait and retrigger Store Updates
Start-Sleep -Seconds 100
Invoke-UpdateScanMethodMSStore


if (($CurrentRun -ge 2) -and ($CurrentRun -lt 5)){
    # Chocolatey + Dell Command Update
    Write-Host "Installing Chocolatey and Dell Command Update..." -ForegroundColor Cyan

    if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey already installed" -ForegroundColor Green
    }

    $env:Path += ";$env:ProgramData\chocolatey\bin"
    Write-Host "Running Dell Command Update to apply updates..." -ForegroundColor Cyan
    $dcuCliPath = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
    if (Test-Path $dcuCliPath) {
        Start-Process $dcuCliPath -ArgumentList "/silent /applyupdates /reboot=enable"
    } else {
        Write-Host "Dell Command Update CLI not found at $dcuCliPath" -ForegroundColor Red
    # Reboot notice
    Start-Process shutdown -ArgumentList "/r /t 120 /c ""In 2 Minutes - Currently Performing Initial Setup Modifications - Reboot $CurrentRun of 5""  /f /d p:4:1"
    # Reboot notice
    Start-Process shutdown -ArgumentList "/r /t 120 /c ""In 2 Minutes - Currently Performing Intial Setup Modifications - Reboot $CurrentRun of 5""  /f /d p:4:1"

    # Reboot notice
    Start-Process shutdown -ArgumentList "/r /t 120 /c ""In 2 Minutes - Currently Performing Intial Setup Modifications - Reboot $CurrentRun of 5""  /f /d p:4:1"
}


if ($CurrentRun -ge 5){
    Start-Process shutdown -ArgumentList "/s /t 120 /c ""In 2 Minutes - !! -- Shutting down PC to signal process completed -- !!""  /f /d p:4:1"
    #Start-Sleep -Seconds 60
    #stop-Computer -force
}

'@

$PostActionScript | Out-File -FilePath $ScriptPath -Force -Encoding UTF8
