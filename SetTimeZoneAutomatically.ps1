# Set the tzautoupdate service to manual
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3

# Restart the tzautoupdate service if present
$service = Get-Service -Name tzautoupdate -ErrorAction SilentlyContinue
if ($service) {
    Restart-Service -Name tzautoupdate
    Write-Output "tzautoupdate service set to manual and restarted."
}
else {
    Write-Output "tzautoupdate service not found."
}