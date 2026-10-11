[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path (Join-Path $HOME '.codex-workspace-kit') 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host '没有安装记录；不会尝试删除文件。'
    exit 0
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$remaining = @()
$processed = 0
if (-not $DryRun) {
    $answer = Read-Host '即将恢复/移除本工具包管理的文件，输入 YES 继续'
    if ($answer -cne 'YES') { Write-Host '已取消。'; exit 0 }
}

foreach ($entry in @($manifest.files)) {
    if (-not (Test-Path -LiteralPath $entry.target -PathType Leaf)) {
        Write-Host "文件已不存在：$($entry.target)"
        continue
    }
    $currentHash = (Get-FileHash -LiteralPath $entry.target -Algorithm SHA256).Hash
    if ($currentHash -ne $entry.hash) {
        Write-Warning "保留用户修改过的文件：$($entry.target)"
        $remaining += $entry
        continue
    }
    Write-Host "$(if ($DryRun) { '[预览] ' })恢复或移除：$($entry.target)"
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
    Write-Host "处理了 $processed 个文件；保留所有未管理的目录、配置和登录信息。"
}
