[CmdletBinding()]
param([switch]$DryRun, [string]$TestRoot, [switch]$TestAssumeYes)

$ErrorActionPreference = 'Stop'
$kitHome = $HOME
if ($TestRoot) {
    $testPath = [IO.Path]::GetFullPath($TestRoot)
    $testPrefix = Join-Path ([IO.Path]::GetTempPath()) 'codex-kit-test-'
    if (-not $testPath.StartsWith($testPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $testPath -PathType Container)) { throw 'Invalid TestRoot.' }
    $kitHome = $testPath
}
if ($TestAssumeYes -and -not $TestRoot) { throw 'TestAssumeYes requires a validated TestRoot.' }
$manifestPath = Join-Path (Join-Path $kitHome '.codex-workspace-kit') 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host 'No installation manifest found. No files will be removed.'
    exit 0
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$remaining = @()
$processed = 0
if (-not $DryRun -and -not $TestAssumeYes) {
    $answer = Read-Host 'Restore or remove managed files? Type YES (case-insensitive) to continue'
    if ($answer.Trim() -ne 'YES') { Write-Host 'Cancelled.'; exit 0 }
}

foreach ($entry in @($manifest.files)) {
    if (-not (Test-Path -LiteralPath $entry.target -PathType Leaf)) {
        Write-Host "File already missing: $($entry.target)"
        continue
    }
    $currentHash = (Get-FileHash -LiteralPath $entry.target -Algorithm SHA256).Hash
    if ($currentHash -ne $entry.hash) {
        Write-Warning "Preserving user-modified file: $($entry.target)"
        $remaining += $entry
        continue
    }
    if ($entry.backup -and -not (Test-Path -LiteralPath $entry.backup -PathType Leaf)) {
        Write-Warning "Original backup is missing; preserving the installed file: $($entry.target)"
        $remaining += $entry
        continue
    }
    Write-Host "$(if ($DryRun) { '[DRY RUN] ' })Restore or remove: $($entry.target)"
    if ($DryRun) { continue }
    if ($entry.backup -and (Test-Path -LiteralPath $entry.backup -PathType Leaf)) {
        Copy-Item -LiteralPath $entry.backup -Destination $entry.target -Force
    } else {
        Remove-Item -LiteralPath $entry.target -Force
    }
    $processed++
}

if (-not $DryRun) {
    $manifest.files = @($remaining)
    $manifest.updated = Get-Date -Format o
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "Processed $processed files. Unmanaged directories, settings and credentials were preserved."
}
