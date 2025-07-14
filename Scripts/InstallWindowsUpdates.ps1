# Run as Administrator

# Create the Windows Update session
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

# Search for available updates
Write-Output "Searching for available Windows updates..."
$SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")

if ($SearchResult.Updates.Count -eq 0) {
    Write-Output "No updates available."
}
else {
    Write-Output "$($SearchResult.Updates.Count) updates found. Downloading and installing..."

    # Collect updates to install
    $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach ($Update in $SearchResult.Updates) {
        $UpdatesToInstall.Add($Update) | Out-Null
    }

    # Download updates
    $Downloader = $UpdateSession.CreateUpdateDownloader()
    $Downloader.Updates = $UpdatesToInstall
    $Downloader.Download()

    # Install updates
    $Installer = $UpdateSession.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
    $Result = $Installer.Install()

    if ($Result.ResultCode -eq 2) {
        Write-Output "Updates installed successfully. A restart may be required."
    }
    else {
        Write-Output "Some updates may have failed to install. Result code: $($Result.ResultCode)"
    }
}
