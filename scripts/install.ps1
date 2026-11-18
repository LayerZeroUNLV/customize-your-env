# Copies the workshop Starship config into place on Windows and hooks it into PowerShell
# Windows Terminal settings are merged by hand, see the README
# Usage (from the repo folder): powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path -Parent $PSScriptRoot
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Write-Step($Message) { Write-Host "==> $Message" -ForegroundColor Magenta }
function Write-Warn($Message) { Write-Host "[!] $Message" -ForegroundColor Yellow }

# Remember what was there before the first install so reset.ps1 can put it back
# Only runs once, later installs leave the record alone
function Save-Original($Destination) {
    if ((Test-Path "$Destination.original") -or (Test-Path "$Destination.original-none")) {
        return
    }
    if (Test-Path $Destination) {
        Copy-Item $Destination "$Destination.original"
    } else {
        New-Item -ItemType File -Path "$Destination.original-none" | Out-Null
    }
}

# Copy src to dest, backing up whatever is already there
function Install-File($Source, $Destination) {
    if (-not (Test-Path $Source)) {
        throw "Missing $Source, is the repo cloned fully?"
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Save-Original $Destination
    if (Test-Path $Destination) {
        Copy-Item $Destination "$Destination.bak-$Timestamp"
        Write-Step "Backed up $Destination -> $Destination.bak-$Timestamp"
    }
    Copy-Item $Source $Destination
    Write-Step "Installed $Destination"
}

Install-File (Join-Path $RepoDir 'starship\starship.toml') (Join-Path $HOME '.config\starship.toml')

if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Warn 'starship is not installed yet, run: winget install --id Starship.Starship --source winget  then rerun this'
    exit 0
}

# Windows blocks profile scripts by default, so the starship line would never run
# RemoteSigned for just this user lets local scripts run, no admin needed
$Policy = Get-ExecutionPolicy -Scope CurrentUser
if ($Policy -eq 'Undefined' -or $Policy -eq 'Restricted') {
    # Leave a note so reset.ps1 knows it can put the old policy back
    $PolicyMarker = Join-Path $HOME '.config\customize-your-env-policy-changed'
    if (-not (Test-Path $PolicyMarker)) {
        Set-Content -Path $PolicyMarker -Value $Policy
    }
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    Write-Step "Set PowerShell execution policy to RemoteSigned for $env:USERNAME so your profile can load"
}

# Add the starship init line to the PowerShell profile if it is not there yet
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}
if (Select-String -Path $PROFILE -Pattern 'starship init' -Quiet) {
    Write-Step "Starship already hooked in $PROFILE"
} else {
    Add-Content -Path $PROFILE -Value "`n# Starship prompt`nInvoke-Expression (&starship init powershell)"
    Write-Step "Added starship init to $PROFILE"
}

Write-Step 'Done! Open a new Windows Terminal tab to see it'
