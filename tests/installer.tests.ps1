[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$install = Join-Path $root 'scripts/install.ps1'
$uninstall = Join-Path $root 'scripts/uninstall.ps1'
$testDirs = @()

function Assert([bool]$pass, [string]$message) {
    if (-not $pass) { throw "Assertion failed: $message" }
    Write-Host "[PASS] $message"
}

function New-TestHome {
    $path = Join-Path ([IO.Path]::GetTempPath()) ('codex-kit-test-' + [guid]::NewGuid().ToString('N'))
    New-Item -Path $path -ItemType Directory -Force | Out-Null
    $script:testDirs += $path
    return $path
}

try {
    $dryHome = New-TestHome
    & $install -TestRoot $dryHome -DryRun | Out-Null
    Assert (-not (Test-Path -LiteralPath (Join-Path $dryHome '.codex-workspace-kit'))) 'Dry run creates no state directory'

    # Identical user-owned files must never become uninstall-owned files.
    $kitHome = New-TestHome
    $userSkill = Join-Path $kitHome '.agents/skills/bug-fix/SKILL.md'
    New-Item -Path (Split-Path -Parent $userSkill) -ItemType Directory -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root 'skills/bug-fix/SKILL.md') -Destination $userSkill

    & $install -TestRoot $kitHome -InstallAll -SkipMcp | Out-Null
    $manifestPath = Join-Path $kitHome '.codex-workspace-kit/manifest.json'
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert (@($manifest.files).Count -eq 8) 'Eight new files are owned by the installer'
    Assert (@($manifest.observed | Where-Object { $_.target -eq $userSkill }).Count -eq 1) 'Identical pre-existing Skill is observed, not adopted'

    & $install -TestRoot $kitHome -InstallAll -SkipMcp | Out-Null
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert (@($manifest.files).Count -eq 8) 'Repeated installation is idempotent'

    & $uninstall -TestRoot $kitHome -TestAssumeYes | Out-Null
    Assert (Test-Path -LiteralPath $userSkill) 'Pre-existing identical Skill survives uninstall'
    Assert (-not (Test-Path -LiteralPath (Join-Path $kitHome '.codex/AGENTS.md'))) 'Installer-owned file removed on uninstall'

    # Deliberately interrupt after a write; the destination must be rolled back.
    $failureHome = New-TestHome
    $didFail = $false
    try {
        & $install -TestRoot $failureHome -InstallAll -SkipMcp -TestFailAfterFirstWrite | Out-Null
    } catch { $didFail = $true }
    Assert $didFail 'Injected failure reaches rollback handler'
    Assert (-not (Test-Path -LiteralPath (Join-Path $failureHome '.codex/AGENTS.md'))) 'Partial file is rolled back'
    Assert (-not (Test-Path -LiteralPath (Join-Path $failureHome '.codex-workspace-kit/manifest.json'))) 'Partial manifest is absent'

    $overwriteFailureHome = New-TestHome
    $originalRules = Join-Path $overwriteFailureHome '.codex/AGENTS.md'
    New-Item -Path (Split-Path -Parent $originalRules) -ItemType Directory -Force | Out-Null
    [IO.File]::WriteAllText($originalRules, 'Keep this original', [Text.Encoding]::ASCII)
    $didFail = $false
    try {
        & $install -TestRoot $overwriteFailureHome -InstallAll -SkipMcp -Force -TestAssumeYes -TestFailAfterFirstWrite | Out-Null
    } catch { $didFail = $true }
    Assert $didFail 'Injected replacement failure triggers rollback'
    Assert ((Get-Content -LiteralPath $originalRules -Raw).Trim() -eq 'Keep this original') 'Overwritten original is restored after failure'

    # A pre-existing different file can be backed up and restored on uninstall.
    $replaceHome = New-TestHome
    $userRules = Join-Path $replaceHome '.codex/AGENTS.md'
    New-Item -Path (Split-Path -Parent $userRules) -ItemType Directory -Force | Out-Null
    [IO.File]::WriteAllText($userRules, 'Original user instructions', [Text.Encoding]::ASCII)
    & $install -TestRoot $replaceHome -InstallAll -SkipMcp -Force -TestAssumeYes | Out-Null
    Assert ((Get-Content -LiteralPath $userRules -Raw) -ne 'Original user instructions') 'Approved replacement is installed'
    & $uninstall -TestRoot $replaceHome -TestAssumeYes | Out-Null
    Assert ((Get-Content -LiteralPath $userRules -Raw).Trim() -eq 'Original user instructions') 'Original user instructions are restored'

    Write-Host 'All isolated installer tests passed.'
} finally {
    foreach ($directory in $testDirs) {
        if ($directory -and (Test-Path -LiteralPath $directory)) {
            Remove-Item -LiteralPath $directory -Recurse -Force
        }
    }
}
