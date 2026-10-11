[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$InstallAll,
    [switch]$SkipMcp,
    [switch]$InstallMcp,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$stateRoot = Join-Path $HOME '.codex-workspace-kit'
$manifestPath = Join-Path $stateRoot 'manifest.json'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path (Join-Path $stateRoot 'backups') $timestamp

function Say([string]$message) { Write-Host "[Codex Kit] $message" }
function RelativeHash([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }

if ($PSVersionTable.PSVersion.Major -lt 5) { throw 'PowerShell 5.1 or later is required.' }
if ($env:OS -ne 'Windows_NT') { throw 'This installer supports Windows only.' }

foreach ($command in @('codex', 'node', 'npm', 'git')) {
    if (Get-Command $command -ErrorAction SilentlyContinue) { Say "Found $command" }
    else { Say "Warning: $command was not found. Some features may not work." }
}

if ($SkipMcp -and $InstallMcp) { throw 'Do not combine -SkipMcp and -InstallMcp.' }

if (-not $InstallAll -and -not $DryRun) {
    Say 'Installing AGENTS.md, Skills and Agents. Existing files will be skipped.'
    $answer = Read-Host 'Continue? Type YES'
    if ($answer -cne 'YES') { Say 'Cancelled.'; exit 0 }
}

$items = @()
$items += [pscustomobject]@{ Source = 'config/AGENTS.md'; Target = (Join-Path $HOME '.codex/AGENTS.md') }
foreach ($skill in @(Get-ChildItem (Join-Path $root 'skills') -Directory)) {
    $items += [pscustomobject]@{ Source = "skills/$($skill.Name)/SKILL.md"; Target = (Join-Path $HOME ".agents/skills/$($skill.Name)/SKILL.md") }
}
foreach ($agent in @(Get-ChildItem (Join-Path $root 'agents') -Filter '*.toml' -File)) {
    $items += [pscustomobject]@{ Source = "agents/$($agent.Name)"; Target = (Join-Path $HOME ".codex/agents/$($agent.Name)") }
}

$records = @()
if (Test-Path -LiteralPath $manifestPath) {
    $oldManifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $records = @($oldManifest.files | Where-Object { $null -ne $_ })
}

foreach ($item in $items) {
    $source = Join-Path $root ($item.Source.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing template: $source" }
    $target = $item.Target
    $existing = @($records | Where-Object { $_.target -eq $target })
    $sourceHash = RelativeHash $source
    if (Test-Path -LiteralPath $target) {
        $currentHash = RelativeHash $target
        if ($currentHash -eq $sourceHash) { Say "Already up to date: $target"; continue }
        if (-not $Force) { Say "Skipping existing file: $target (use -Force only after review)"; continue }
        if ($existing.Count -gt 0 -and $currentHash -ne $existing[0].hash) {
            Say "Warning: local changes detected. Backing up before approved replacement: $target"
        }
    }

    if ($DryRun) { Say "[DRY RUN] Would install: $target"; continue }
    $backup = $null
    if (Test-Path -LiteralPath $target) {
        $backup = Join-Path $backupRoot ($item.Source.Replace('/', [IO.Path]::DirectorySeparatorChar))
        New-Item -Path (Split-Path $backup -Parent) -ItemType Directory -Force | Out-Null
        Copy-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
    }
    New-Item -Path (Split-Path $target -Parent) -ItemType Directory -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Force
    $records = @($records | Where-Object { $_.target -ne $target })
    $records += [pscustomobject]@{ source = $item.Source; target = $target; hash = (RelativeHash $target); backup = $backup }
    Say "Installed: $target"
}

if (-not $DryRun) {
    New-Item -Path $stateRoot -ItemType Directory -Force | Out-Null
    $obj = [pscustomobject]@{ version = 1; updated = (Get-Date -Format o); files = @($records) }
    $json = $obj | ConvertTo-Json -Depth 8
    [IO.File]::WriteAllText($manifestPath, $json, (New-Object System.Text.UTF8Encoding($false)))
    Say "Installation manifest: $manifestPath"
}

if ($InstallMcp -and -not $SkipMcp) {
    $mcpCommands = @(
        'codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp',
        'codex mcp add context7 -- npx -y @upstash/context7-mcp'
    )
    foreach ($line in $mcpCommands) { Say "[Optional MCP command] $line" }
    if (-not $DryRun) {
        Say 'MCP commands were not executed. Review their providers and run them manually if approved.'
    }
}

Say 'Done. Restart Codex and run scripts/verify.ps1.'
