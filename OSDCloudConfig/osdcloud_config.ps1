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

$ScriptName = 'Jared Provisioning Script'
$ScriptVersion = '1.0'
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


# --- AUTO-RESTART OUT OF WINPE ---
Write-Host -ForegroundColor Green "Restarting in 10 seconds!"
Start-Sleep -Seconds 10
wpeutil reboot
