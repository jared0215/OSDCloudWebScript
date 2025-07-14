# Run as Administrator

# Ensure script running is enabled for this session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

function Invoke-ScriptWithMessages {
    param (
        [string]$ScriptPath,
        [string]$DisplayName
    )
    Write-Output "========== Starting: $DisplayName =========="
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptPath`"" -Wait
    $sw.Stop()
    Write-Output "========== Finished: $DisplayName (Elapsed: $($sw.Elapsed.ToString())) =========="
}

Invoke-ScriptWithMessages ".\Scripts\EnableLocationServices.ps1" "Enable Location Services"
Invoke-ScriptWithMessages ".\Scripts\SetTimeZoneAutomatically.ps1" "Set Time Zone Automatically"
Invoke-ScriptWithMessages ".\Scripts\InstallWindowsUpdates.ps1" "Install Windows Updates"
Invoke-ScriptWithMessages ".\Scripts\InstallMicrosoftStoreUpdates.ps1" "Install Microsoft Store Updates"

Write-Output "========== All tasks complete =========="
