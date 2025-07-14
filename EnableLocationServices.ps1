# Enable Location Services
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Allow"

# Enable "Let apps access your location"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Allow"

# Restart the location service (if present)
$service = Get-Service -Name lfsvc -ErrorAction SilentlyContinue
if ($service -and $service.Status -ne 'Running') {
    Start-Service lfsvc
}

Write-Output "Location Services enabled."