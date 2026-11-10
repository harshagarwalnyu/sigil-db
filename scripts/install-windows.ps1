# Run in your own PowerShell. MySQL may request Windows administrator approval.
# Installation does not initialize a database or choose/store a root password.
$ErrorActionPreference = 'Stop'
$failedPackages = @()
foreach ($packageId in @('Oracle.MySQL', 'JetBrains.DataGrip')) {
    & winget install --id $packageId --exact --source winget --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "winget returned exit $LASTEXITCODE for $packageId. Check whether it is already installed."
        $failedPackages += $packageId
    }
}
if ($failedPackages.Count -gt 0) {
    throw "Installation needs attention: $($failedPackages -join ', ')."
}
Write-Host 'Open MySQL Configurator to configure a local server and root password.'
Write-Host 'Then connect DataGrip to localhost:3306 using your MySQL credentials.'
