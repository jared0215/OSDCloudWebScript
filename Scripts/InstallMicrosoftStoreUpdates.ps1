# PowerShell script to update all Microsoft Store apps
Start-Process winget -ArgumentList "upgrade --source msstore --all --accept-source-agreements --accept-package-agreements" -Wait
