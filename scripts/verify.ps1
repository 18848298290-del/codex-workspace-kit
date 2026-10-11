[CmdletBinding()]
param([string]$TestRoot)

$ErrorActionPreference = 'Stop'
$kitHome = $HOME
if ($TestRoot) {
    $testPath = [IO.Path]::GetFullPath($TestRoot)
    $testPrefix = Join-Path ([IO.Path]::GetTempPath()) 'codex-kit-test-'
    if (-not $testPath.StartsWith($testPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $testPath -PathType Container)) { throw 'Invalid TestRoot.' }
    $kitHome = $testPath
}
$stateRoot = Join-Path $kitHome '.codex-workspace-kit'
$manifestPath = Join-Path $stateRoot 'manifest.json'
$failed = 0

function Check([bool]$pass, [string]$description) {
    if ($pass) { Write-Host "[OK] $description" }
    else { Write-Warning "[FAILED] $description"; $script:failed++ }
}

Check ([bool](Get-Command codex -ErrorAction SilentlyContinue)) 'codex command available'
Check (Test-Path -LiteralPath (Join-Path $kitHome '.codex/AGENTS.md')) 'Global AGENTS.md exists'
Check (Test-Path -LiteralPath $manifestPath) 'Installation manifest exists'

if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($entry in @($manifest.files)) {
        $exists = Test-Path -LiteralPath $entry.target -PathType Leaf
        Check $exists $entry.target
        if ($exists) {
            $hash = (Get-FileHash -LiteralPath $entry.target -Algorithm SHA256).Hash
            Check ($hash -eq $entry.hash) "Content hash unchanged: $($entry.target)"
        }
    }
}

$skillRoot = Join-Path $kitHome '.agents/skills'
if (Test-Path $skillRoot) {
    foreach ($skill in @(Get-ChildItem $skillRoot -Directory)) {
        $file = Join-Path $skill.FullName 'SKILL.md'
        if (-not (Test-Path $file)) { continue }
        $body = Get-Content $file -Raw -Encoding UTF8
        Check ([bool]($body -match '(?s)\A---\s*\r?\nname:\s*[^\r\n]+\r?\ndescription:\s*[^\r\n]+')) "Skill metadata: $($skill.Name)"
    }
}

if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host 'MCP servers:'
    & codex mcp list
}

if ($failed -gt 0) { Write-Warning "$failed checks failed. Review the output above."; exit 1 }
Write-Host 'Static verification complete. Confirm Skills and Agents in a new Codex session.'
