<#
.SYNOPSIS
    Запуск SEO-дашборда (веб-сервер + планировщик сбора в одном процессе).

.DESCRIPTION
    Адрес и порт берутся из .env (APP_HOST, APP_PORT). Приложение должно работать
    в одном процессе: планировщик сбора запускается внутри него.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $Root "backend\.venv\Scripts\python.exe"
if (-not (Test-Path $Python)) { throw "Сначала выполните .\scripts\setup.ps1" }

# Значения APP_HOST / APP_PORT из .env (по умолчанию 127.0.0.1:8000).
$appHost = "127.0.0.1"; $appPort = "8000"
Get-Content (Join-Path $Root ".env") | ForEach-Object {
    if ($_ -match '^\s*APP_HOST\s*=\s*(.+)$') { $appHost = $Matches[1].Trim() }
    if ($_ -match '^\s*APP_PORT\s*=\s*(.+)$') { $appPort = $Matches[1].Trim() }
}

Push-Location (Join-Path $Root "backend")
try {
    $uvicornArgs = @("-m", "uvicorn", "app.main:app", "--host", $appHost, "--port", $appPort)
    Write-Host "SEO-дашборд слушает ${appHost}:$appPort (снаружи — адрес PUBLIC_BASE_URL через прокси). Ctrl+C — остановить" -ForegroundColor Green
    & $Python @uvicornArgs
} finally {
    Pop-Location
}
