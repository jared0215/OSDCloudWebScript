Write-Host -ForegroundColor Green "Starting OSDCloud ZTI"
Start-Sleep -Seconds 5

# Set update variables before running Start-OSDCloud
$Global:MyOSDCloud.WindowsUpdate = $true
$Global:MyOSDCloud.WindowsUpdateDrivers = $true
$Global:MyOSDCloud.WindowsDefenderUpdate = $true

Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 24H2 -OSEdition Pro -OSLanguage en-us -OSLicense Retail -ZTI

# Restart from WinPE
Write-Host -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
