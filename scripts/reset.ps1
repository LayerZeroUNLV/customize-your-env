# Puts your Starship config and PowerShell profile back to how they were before install.ps1
# Add -ResetTerminal to also wipe Windows Terminal back to stock settings
# Usage (from the repo folder):
#   powershell -ExecutionPolicy Bypass -File .\scripts\reset.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\reset.ps1 -ResetTerminal
param([switch]$ResetTerminal)
$ErrorActionPreference = 'Stop'

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$HookComment = '# Starship prompt'
$PolicyMarker = Join-Path $HOME '.config\customize-your-env-policy-changed'
$TerminalSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

function Write-Step($Message) { Write-Host "==> $Message" -ForegroundColor Magenta }
function Write-Warn($Message) { Write-Host "[!] $Message" -ForegroundColor Yellow }

# Restore one config file to its pre-workshop state
function Reset-File($Destination) {
    $HasRecord = (Test-Path "$Destination.original") -or (Test-Path "$Destination.original-none")
    if (-not $HasRecord) {
        if (Test-Path $Destination) {
            Write-Warn "No install record for $Destination, leaving it alone. Older backups (if any) are at $Destination.bak-*"
        }
        return
    }
    # Keep whatever you have now in case you want your tweaks back
    if (Test-Path $Destination) {
        Copy-Item $Destination "$Destination.reset-$Timestamp"
        Write-Step "Saved current $Destination -> $Destination.reset-$Timestamp"
    }
    if (Test-Path "$Destination.original") {
        Move-Item -Force "$Destination.original" $Destination
        Write-Step "Restored your original $Destination"
        return
    }
    Remove-Item -Force -ErrorAction SilentlyContinue $Destination
    Remove-Item -Force "$Destination.original-none"
    Write-Step "Removed $Destination, you had no config there before the workshop"
}

# Remove the lines install.ps1 appended to the PowerShell profile
function Remove-StarshipHook {
    if (-not (Test-Path $PROFILE)) {
        return
    }
    $Lines = @(Get-Content -Path $PROFILE -Encoding UTF8)
    if ($Lines -notcontains $HookComment) {
        return
    }
    Copy-Item $PROFILE "$PROFILE.reset-$Timestamp"
    $Kept = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $IsHook = $Lines[$i] -eq $HookComment
        $IsBlankBeforeHook = ($Lines[$i] -eq '') -and ($i + 1 -lt $Lines.Count) -and ($Lines[$i + 1] -eq $HookComment)
        if ($IsBlankBeforeHook) { continue }
        if ($IsHook) {
            # Skip the comment and the init line right after it
            if (($i + 1 -lt $Lines.Count) -and ($Lines[$i + 1] -match 'starship init')) { $i++ }
            continue
        }
        $Kept.Add($Lines[$i])
    }
    Set-Content -Path $PROFILE -Value $Kept -Encoding UTF8
    Write-Step "Removed the starship hook from $PROFILE (old copy at $PROFILE.reset-$Timestamp)"
}

# Put the execution policy back only if install.ps1 changed it
function Reset-Policy {
    if (-not (Test-Path $PolicyMarker)) {
        return
    }
    $OldPolicy = (Get-Content -Path $PolicyMarker -Raw).Trim()
    if (-not $OldPolicy) { $OldPolicy = 'Undefined' }
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $OldPolicy -Force
    Remove-Item -Force $PolicyMarker
    Write-Step "Set PowerShell execution policy back to $OldPolicy"
}

# Back up settings.json and delete it, Windows Terminal makes a fresh one on next launch
function Reset-Terminal {
    if (-not (Test-Path $TerminalSettings)) {
        Write-Warn "Couldn't find Windows Terminal settings at $TerminalSettings, skipping"
        return
    }
    Copy-Item $TerminalSettings "$TerminalSettings.reset-$Timestamp"
    Remove-Item -Force $TerminalSettings
    Write-Step "Windows Terminal settings saved to $TerminalSettings.reset-$Timestamp and reset to stock"
    Write-Warn 'Close EVERY Windows Terminal window, it rebuilds default settings when you open it again'
}

Reset-File (Join-Path $HOME '.config\starship.toml')
Remove-StarshipHook
Reset-Policy
if ($ResetTerminal) {
    Reset-Terminal
} else {
    Write-Step 'Left Windows Terminal settings alone, rerun with -ResetTerminal to reset those too'
}
Write-Step 'Done! Open a new tab to see the original look'
Write-Step 'Fonts and installed apps were left alone, uninstall those yourself if you want'
