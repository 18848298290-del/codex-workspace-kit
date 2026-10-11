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

if ($PSVersionTable.PSVersion.Major -lt 5) { throw '需要 PowerShell 5.1 或更新版本。' }
if ($env:OS -ne 'Windows_NT') { throw '本安装程序仅针对 Windows 编写。' }

foreach ($command in @('codex', 'node', 'npm', 'git')) {
    if (Get-Command $command -ErrorAction SilentlyContinue) { Say "已找到 $command" }
    else { Say "提示：未找到 $command，部分功能可能不可用。" }
}

if ($SkipMcp -and $InstallMcp) { throw '-SkipMcp 与 -InstallMcp 不能同时使用。' }

$modules = @('Rules', 'Skills', 'Agents')
if (-not $InstallAll -and -not $DryRun) {
    Say '将安装 AGENTS.md、Skills 和 Agents。已有同名文件默认跳过。'
    $answer = Read-Host '继续？输入 YES'
    if ($answer -cne 'YES') { Say '已取消。'; exit 0 }
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
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "缺少模板：$source" }
    $target = $item.Target
    $existing = @($records | Where-Object { $_.target -eq $target })
    $sourceHash = RelativeHash $source
    if (Test-Path -LiteralPath $target) {
        $currentHash = RelativeHash $target
        if ($currentHash -eq $sourceHash) { Say "已是最新：$target"; continue }
        if (-not $Force) { Say "跳过已有文件：$target（使用 -Force 才允许备份后覆盖）"; continue }
        if ($existing.Count -gt 0 -and $currentHash -ne $existing[0].hash) {
            Say "警告：文件已被用户修改，仍将按 -Force 请求备份后替换：$target"
        }
    }

    if ($DryRun) { Say "[预览] 安装：$target"; continue }
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
    Say "已安装：$target"
}

if (-not $DryRun) {
    New-Item -Path $stateRoot -ItemType Directory -Force | Out-Null
    $obj = [pscustomobject]@{ version = 1; updated = (Get-Date -Format o); files = @($records) }
    $json = $obj | ConvertTo-Json -Depth 8
    [IO.File]::WriteAllText($manifestPath, $json, (New-Object System.Text.UTF8Encoding($false)))
    Say "安装记录：$manifestPath"
}

if ($InstallMcp -and -not $SkipMcp) {
    $mcpCommands = @(
        'codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp',
        'codex mcp add context7 -- npx -y @upstash/context7-mcp'
    )
    foreach ($line in $mcpCommands) { Say "[MCP 建议] $line" }
    if (-not $DryRun) {
        Say 'MCP 连接不会由脚本自动执行。请审查提供方和命令后，自行逐条运行。'
    }
}

Say '完成。请重启 Codex 并运行 scripts/verify.ps1。'
