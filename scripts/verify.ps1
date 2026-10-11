[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$stateRoot = Join-Path $HOME '.codex-workspace-kit'
$manifestPath = Join-Path $stateRoot 'manifest.json'
$failed = 0

function Check([bool]$pass, [string]$description) {
    if ($pass) { Write-Host "[OK] $description" }
    else { Write-Warning "[检查失败] $description"; $script:failed++ }
}

Check ([bool](Get-Command codex -ErrorAction SilentlyContinue)) 'codex 命令可用'
Check (Test-Path -LiteralPath (Join-Path $HOME '.codex/AGENTS.md')) '全局 AGENTS.md 存在'
Check (Test-Path -LiteralPath $manifestPath) '安装记录存在'

if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($entry in @($manifest.files)) {
        $exists = Test-Path -LiteralPath $entry.target -PathType Leaf
        Check $exists $entry.target
        if ($exists) {
            $hash = (Get-FileHash -LiteralPath $entry.target -Algorithm SHA256).Hash
            Check ($hash -eq $entry.hash) "内容未变化：$($entry.target)"
        }
    }
}

$skillRoot = Join-Path $HOME '.agents/skills'
if (Test-Path $skillRoot) {
    foreach ($skill in @(Get-ChildItem $skillRoot -Directory)) {
        $file = Join-Path $skill.FullName 'SKILL.md'
        if (-not (Test-Path $file)) { continue }
        $body = Get-Content $file -Raw -Encoding UTF8
        Check ([bool]($body -match '(?s)\A---\s*\r?\nname:\s*[^\r\n]+\r?\ndescription:\s*[^\r\n]+')) "Skill 元数据：$($skill.Name)"
    }
}

if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host 'MCP 服务器列表：'
    & codex mcp list
}

if ($failed -gt 0) { Write-Warning "$failed 项未通过；请检查上方提示。"; exit 1 }
Write-Host '静态检查完成；仍需在 Codex 新会话里确认 Skills 和 Agents 可见。'
