param(
    [string]$InstallDir = "D:\SakuraMedia",
    [string]$Repo = "hgmmm25/sakuramedia-mpv-patch"
)

$ErrorActionPreference = "Stop"

$dll = Join-Path $InstallDir "libmpv-2.dll"
if (-not (Test-Path (Join-Path $InstallDir "sakuramedia.exe"))) {
    throw "sakuramedia.exe not found in '$InstallDir' — pass -InstallDir <path>"
}
if (-not (Test-Path $dll)) { throw "libmpv-2.dll not found in '$InstallDir'" }

# 1) stop the client if it is running (dll would be locked otherwise)
$proc = Get-Process sakuramedia -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "stopping sakuramedia.exe (pid $($proc.Id)) ..."
    $proc | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# 2) back up the current dll
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$before = (Get-FileHash $dll -Algorithm SHA256).Hash.ToLower()
Copy-Item $dll "$dll.bak-$stamp"
Write-Host "backup -> libmpv-2.dll.bak-$stamp"

# 3) download the latest patched dll from this repo's releases
$tmp = "$dll.new"
Invoke-WebRequest -Uri "https://github.com/$Repo/releases/latest/download/libmpv-2.dll" -OutFile $tmp

# 4) swap
Move-Item -Force $tmp $dll
$after = (Get-FileHash $dll -Algorithm SHA256).Hash.ToLower()
Write-Host "replaced:"
Write-Host "  before: $before"
Write-Host "  after : $after"
Write-Host "done. re-launch SakuraMedia and retry playback of the affected files."
