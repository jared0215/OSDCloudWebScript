#region Initialization
function Write-DarkGrayDate {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]
        $Message
    )
    if ($Message) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $Message"
    }
    else {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    }
}
function Write-DarkGrayHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Message
    )
    Write-Host -ForegroundColor DarkGray $Message
}
function Write-DarkGrayLine {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray '========================================================================='
}
function Write-SectionHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Message
    )
    Write-DarkGrayLine
    Write-DarkGrayDate
    Write-Host -ForegroundColor Cyan $Message
}
function Write-SectionSuccess {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.String]
        $Message = 'Success!'
    )
    Write-DarkGrayDate
    Write-Host -ForegroundColor Green $Message
}
#endregion

$ScriptName = 'win11.garytown.com'
$ScriptVersion = '25.01.22.1'
Write-Host -ForegroundColor Green "$ScriptName $ScriptVersion"


#Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer)
$OSVersion = 'Windows 11' #Used to Determine Driver Pack
$OSReleaseID = '24H2' #Used to Determine Driver Pack
$OSName = 'Windows 11 24H2 x64'
$OSEdition = 'Pro'
$OSActivation = 'Retail'
$OSLanguage = 'en-us'


#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    Restart               = [bool]$False
    RecoveryPartition     = [bool]$False
    OEMActivation         = [bool]$True
    WindowsUpdate         = [bool]$true
    WindowsUpdateDrivers  = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone           = [bool]$true
    ClearDiskConfirm      = [bool]$False
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB  = [bool]$true
    CheckSHA1             = [bool]$true
}


#Used to Determine Driver Pack
$DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID

if ($DriverPack) {
    $Global:MyOSDCloud.DriverPackName = $DriverPack.Name
}


#write variables to console
Write-SectionHeader "OSDCloud Variables"
Write-Output $Global:MyOSDCloud


#Launch OSDCloud
Write-SectionHeader -Message "Starting OSDCloud"
write-host "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage"

Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage

Write-SectionHeader -Message "OSDCloud Process Complete, Running Custom Actions From Script Before Reboot"


#Copy CMTrace Local:
if (Test-path -path "x:\windows\system32\cmtrace.exe") {
    $destDir = "C:\Windows\System"
    if (-not (Test-Path -Path $destDir)) {
        New-Item -Path $destDir -ItemType Directory -Force | Out-Null
    }
    Copy-Item "x:\windows\system32\cmtrace.exe" -Destination "$destDir\cmtrace.exe" -Verbose
}

if ($Manufacturer -match "Lenovo") {
    $PowerShellSavePath = 'C:\Program Files\WindowsPowerShell'
    Write-Host "Copy-PSModuleToFolder -Name LSUClient to $PowerShellSavePath\Modules"
    Copy-PSModuleToFolder -Name LSUClient -Destination "$PowerShellSavePath\Modules"
    Write-Host "Copy-PSModuleToFolder -Name Lenovo.Client.Scripting to $PowerShellSavePath\Modules"
    Copy-PSModuleToFolder -Name Lenovo.Client.Scripting -Destination "$PowerShellSavePath\Modules"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jared0215/OSDCloudWebScript/master/PostActionsTask.ps1" -OutFile "C:\OSDCloud\Scripts\PostActionsTask.ps1" -ErrorAction Stop
        Write-Host -ForegroundColor Green "PostActionsTask.ps1 downloaded successfully."
    }
    catch {
        Write-Host -ForegroundColor Red "Failed to download PostActionsTask.ps1: $($_.Exception.Message)"
    }
    #restart-computer
    # --- AUTO-RESTART OUT OF WINPE ---
    Write-Host -ForegroundColor Green "Restarting in 10 seconds!"
    Start-Sleep -Seconds 10
    if (Test-Path "X:\Windows\System32\wpeutil.exe") {
        wpeutil reboot
    }
}
else {
    Write-Host -ForegroundColor Yellow "Not running in WinPE. Skipping wpeutil reboot."
}
#Restart
#restart-computer
# --- AUTO-RESTART OUT OF WINPE ---
Write-Host -ForegroundColor Green "Restarting in 10 seconds!"
Start-Sleep -Seconds 10
wpeutil reboot