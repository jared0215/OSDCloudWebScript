Write-Host -ForegroundColor Green "Starting OSDCloud ZTI"
Start-Sleep -Seconds 5

# --- SET ALL OPTIONS HERE (set and forget) ---
$Global:MyOSDCloud.WindowsUpdate          = $true   # Auto install Windows updates
$Global:MyOSDCloud.WindowsUpdateDrivers   = $true   # Auto install driver updates
$Global:MyOSDCloud.WindowsDefenderUpdate  = $true   # Auto update Defender signatures
$Global:MyOSDCloud.DriverPackName         = '*'     # Get latest drivers from cloud (or pick specific pack)
$Global:MyOSDCloud.ZTI                    = $true   # Zero Touch Install—no prompts
$Global:MyOSDCloud.ClearDiskConfirm       = $false  # No confirmation for disk wipe

# --- ALWAYS USE THE SAME WINDOWS BUILD/EDITION/LANGUAGE ---
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSActivation Retail -OSLanguage en-us -ZTI

# --- AUTO-RESTART OUT OF WINPE ---
Write-Host -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
