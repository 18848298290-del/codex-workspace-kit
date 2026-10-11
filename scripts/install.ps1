[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$InstallAll,
    [switch]$SkipMcp,
    [switch]$InstallMcp,
    [switch]$Force,
    [string]$TestRoot,
    [switch]$TestFailAfterFirstWrite,
    [switch]$TestAssumeYes
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$kitHome = $HOME
if ($TestRoot) {
    $testPath = [IO.Path]::GetFullPath($TestRoot)
    $testPrefix = Join-Path ([IO.Path]::GetTempPath()) 'codex-kit-test-'
    if (-not $testPath.StartsWith($testPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $testPath -PathType Container)) {
        throw 'TestRoot must be an existing codex-kit-test-* directory under the system temp directory.'
    }
    $kitHome = $testPath
}
if ($TestFailAfterFirstWrite -and -not $TestRoot) {
    throw 'Failure injection is permitted only with a validated TestRoot.'
}
if ($TestAssumeYes -and -not $TestRoot) {
    throw 'TestAssumeYes requires a validated TestRoot.'
}
$stateRoot = Join-Path $kitHome '.codex-workspace-kit'
$manifestPath = Join-Path $stateRoot 'manifest.json'
$runId = (Get-Date -Format 'yyyyMMdd-HHmmssfff') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$backupRoot = Join-Path (Join-Path $stateRoot 'backups') $runId

function Say([string]$message) { Write-Host "[Codex Kit] $message" }
function FileHash([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }

function Assert-SafePath([string]$path) {
    # Reject links and junctions on the source and destination paths.
    $current = [IO.Path]::GetFullPath($path)
    while ($current) {
        if (Test-Path -LiteralPath $current) {
            $entry = Get-Item -LiteralPath $current -Force
            if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Refusing reparse point or symbolic link: $current"
            }
        }
        $parent = Split-Path -Parent $current
        if (-not $parent -or $parent -eq $current) { break }
        $current = $parent
    }
}

if ($PSVersionTable.PSVersion.Major -lt 5 -or
    ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -lt 1)) {
    throw 'PowerShell 5.1 or later is required.'
}
if ($env:OS -ne 'Windows_NT') { throw 'This installer supports Windows only.' }
if ($SkipMcp -and $InstallMcp) { throw 'Do not combine -SkipMcp and -InstallMcp.' }

foreach ($command in @('codex', 'node', 'npm', 'git')) {
    if (Get-Command $command -ErrorAction SilentlyContinue) { Say "Found $command" }
    else { Say "Warning: $command was not found. Some features may not work." }
}

$items = @()
$items += [pscustomobject]@{ Source = 'config/AGENTS.md'; Target = (Join-Path $kitHome '.codex/AGENTS.md') }
foreach ($skill in @(Get-ChildItem -LiteralPath (Join-Path $root 'skills') -Directory)) {
    $items += [pscustomobject]@{ Source = "skills/$($skill.Name)/SKILL.md"; Target = (Join-Path $kitHome ".agents/skills/$($skill.Name)/SKILL.md") }
}
foreach ($agent in @(Get-ChildItem -LiteralPath (Join-Path $root 'agents') -Filter '*.toml' -File)) {
    $items += [pscustomobject]@{ Source = "agents/$($agent.Name)"; Target = (Join-Path $kitHome ".codex/agents/$($agent.Name)") }
}

$records = @()
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    Assert-SafePath $manifestPath
    $oldManifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $records = @($oldManifest.files | Where-Object { $null -ne $_ })
}

# Resolve all actions before writing anything.
$plan = @()
foreach ($item in $items) {
    $source = Join-Path $root ($item.Source.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing template: $source" }
    Assert-SafePath $source
    Assert-SafePath $item.Target
    $sourceHash = FileHash $source
    $tracked = @($records | Where-Object { $_.target -eq $item.Target })
    $targetExists = Test-Path -LiteralPath $item.Target
    $targetHash = $null
    $action = 'Install'
    if ($targetExists) {
        if (-not (Test-Path -LiteralPath $item.Target -PathType Leaf)) { throw "Target is not a file: $($item.Target)" }
        $targetHash = FileHash $item.Target
        if ($sourceHash -eq $targetHash) {
            $action = if ($tracked.Count -gt 0) { 'AlreadyManaged' } else { 'IdenticalUnmanaged' }
        } elseif ($Force) { $action = 'Replace' }
        else { $action = 'SkipExisting' }
    }
    $plan += [pscustomobject]@{
        sourceRelative = $item.Source; source = $source; target = $item.Target
        sourceHash = $sourceHash; targetHash = $targetHash
        action = $action; tracked = $tracked
    }
}

foreach ($item in $plan) {
    switch ($item.action) {
        'Install' { Say "$(if ($DryRun) { '[DRY RUN] ' })Add: $($item.target)" }
        'Replace' { Say "$(if ($DryRun) { '[DRY RUN] ' })Back up and replace: $($item.target) -> $backupRoot" }
        'AlreadyManaged' { Say "Already managed: $($item.target)" }
        'IdenticalUnmanaged' { Say "Identical pre-existing file, left unmanaged: $($item.target)" }
        'SkipExisting' { Say "Skipped pre-existing file: $($item.target)" }
    }
}

if ($InstallMcp -and -not $SkipMcp) {
    Say 'Optional MCP commands (not executed):'
    Say 'codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp'
    Say 'codex mcp add context7 -- npx -y @upstash/context7-mcp'
}
if ($DryRun) { Say 'Dry run complete. No files were changed.'; exit 0 }

$changes = @($plan | Where-Object { $_.action -eq 'Install' -or $_.action -eq 'Replace' })
$replacements = @($plan | Where-Object { $_.action -eq 'Replace' })
if ((-not $InstallAll -or $replacements.Count -gt 0) -and -not $TestAssumeYes) {
    $answer = Read-Host "Apply $($changes.Count) changes ($($replacements.Count) replacements)? Type YES"
    if ($answer.Trim() -ne 'YES') { Say 'Cancelled.'; exit 0 }
}

$changed = New-Object System.Collections.ArrayList
$manifestSnapshot = $null
$manifestExisted = Test-Path -LiteralPath $manifestPath -PathType Leaf
$tempManifest = $null
try {
    Assert-SafePath $backupRoot
    New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null
    if ($manifestExisted) {
        $manifestSnapshot = Join-Path $backupRoot 'manifest-before.json'
        Copy-Item -LiteralPath $manifestPath -Destination $manifestSnapshot -ErrorAction Stop
    }

    foreach ($item in $changes) {
        Assert-SafePath $item.source
        Assert-SafePath $item.target
        if ((FileHash $item.source) -ne $item.sourceHash) { throw "Source changed during install: $($item.source)" }

        $currentExists = Test-Path -LiteralPath $item.target
        if ($item.action -eq 'Install' -and $currentExists) { throw "Target appeared during install: $($item.target)" }
        if ($item.action -eq 'Replace') {
            if (-not $currentExists -or (FileHash $item.target) -ne $item.targetHash) {
                throw "Target changed during install: $($item.target)"
            }
        }

        $rollbackBackup = $null
        if ($currentExists) {
            $rollbackBackup = Join-Path $backupRoot ($item.sourceRelative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            New-Item -Path (Split-Path -Parent $rollbackBackup) -ItemType Directory -Force | Out-Null
            Copy-Item -LiteralPath $item.target -Destination $rollbackBackup -ErrorAction Stop
        }

        New-Item -Path (Split-Path -Parent $item.target) -ItemType Directory -Force | Out-Null
        # Track the destination BEFORE copying, so a partial write is reversible.
        [void]$changed.Add([pscustomobject]@{ target = $item.target; rollbackBackup = $rollbackBackup })
        Copy-Item -LiteralPath $item.source -Destination $item.target -Force -ErrorAction Stop
        if ((FileHash $item.target) -ne $item.sourceHash) { throw "Hash mismatch after copy: $($item.target)" }
        if ($TestFailAfterFirstWrite -and $changed.Count -eq 1) {
            throw 'Injected failure after first write for rollback test.'
        }

        # Keep the original user's backup across managed upgrades.
        $originalBackup = $rollbackBackup
        if ($item.tracked.Count -gt 0) { $originalBackup = $item.tracked[0].backup }
        $records = @($records | Where-Object { $_.target -ne $item.target })
        $records += [pscustomobject]@{
            source = $item.sourceRelative; target = $item.target
            hash = $item.sourceHash; backup = $originalBackup
        }
        Say "Installed: $($item.target)"
    }

    # An identical pre-existing file is OBSERVED, never adopted as owned.
    # Otherwise uninstall could delete a file that predates this toolkit.
    $observed = @($plan | Where-Object { $_.action -eq 'IdenticalUnmanaged' -or $_.action -eq 'SkipExisting' } |
        ForEach-Object { [pscustomobject]@{ source = $_.sourceRelative; target = $_.target; status = $_.action; hash = $_.targetHash } })

    New-Item -Path $stateRoot -ItemType Directory -Force | Out-Null
    $manifest = [pscustomobject]@{
        version = 2; updated = (Get-Date -Format o)
        files = @($records); observed = @($observed)
    }
    $tempManifest = Join-Path $stateRoot ('.manifest-' + $runId + '.tmp')
    [IO.File]::WriteAllText($tempManifest, ($manifest | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding($false)))
    Move-Item -LiteralPath $tempManifest -Destination $manifestPath -Force -ErrorAction Stop
    Say "Installation manifest: $manifestPath"
} catch {
    $failure = $_
    Write-Warning "Install failed. Rolling back $($changed.Count) changed files."
    for ($i = $changed.Count - 1; $i -ge 0; $i--) {
        $entry = $changed[$i]
        try {
            if ($entry.rollbackBackup) {
                Copy-Item -LiteralPath $entry.rollbackBackup -Destination $entry.target -Force -ErrorAction Stop
            } elseif (Test-Path -LiteralPath $entry.target) {
                Remove-Item -LiteralPath $entry.target -Force -ErrorAction Stop
            }
        } catch { Write-Warning "Manual recovery required for $($entry.target): $_" }
    }
    try {
        if ($manifestSnapshot) {
            Copy-Item -LiteralPath $manifestSnapshot -Destination $manifestPath -Force -ErrorAction Stop
        } elseif (-not $manifestExisted -and (Test-Path -LiteralPath $manifestPath)) {
            Remove-Item -LiteralPath $manifestPath -Force -ErrorAction Stop
        }
        if ($tempManifest -and (Test-Path -LiteralPath $tempManifest)) {
            Remove-Item -LiteralPath $tempManifest -Force -ErrorAction Stop
        }
    } catch { Write-Warning "Manifest recovery needs attention: $_" }
    throw $failure
}

Say 'Done. Restart Codex and run scripts/verify.ps1.'
