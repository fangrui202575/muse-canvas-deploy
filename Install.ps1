param(
    [string]$Destination = 'C:\MuseCanvas',
    [string]$ForUser = $env:USERNAME,
    [string]$DataDirectory = '',
    [switch]$AutoStart,
    [switch]$NoShortcut
)
$ErrorActionPreference = 'Stop'
try {
$source = $PSScriptRoot
$Destination = [IO.Path]::GetFullPath($Destination)
if (!(Test-Path -LiteralPath (Join-Path $source 'Installer-Common.ps1'))) { throw '安装检查组件缺失。请重新完整解压安装包后重试。' }
. (Join-Path $source 'Installer-Common.ps1')
Assert-PackageFolderSafe $source

function Get-MissingRequired($root) {
    $required = @('Installer-Common.ps1', 'scripts\Manage.ps1', 'node\node.exe', 'pool\MusePool.exe', 'protocol\MuseProtocol.exe', 'agent\agent.cjs', 'services\entry.cjs', 'services\web.jsc', 'services\merge.jsc', 'services\license.jsc', 'web\index.html', 'tools\ffmpeg.exe', 'tools\ffprobe.exe')
    return @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) })
}

# 1) Validate the install SOURCE first. Nothing is touched before this passes.
$missing = Get-MissingRequired $source
if ($missing.Count -gt 0) { throw ('安装包不完整，请重新下载并完整解压。详情：Install source is incomplete (missing: ' + ($missing -join ', ') + '). Re-download and re-extract the package. Nothing was changed.') }
if ($source.TrimEnd('\') -ieq $Destination.TrimEnd('\')) { throw '请把安装包解压到其他文件夹后再安装。详情：Source and destination are the same folder. Extract the package somewhere else first, then run Install.ps1 from there.' }

# 2) Destination safety: never install into a protected location, and never
#    overwrite a folder that holds other files and is not a MuseCanvas install.
$protected = @([IO.Path]::GetPathRoot($Destination), $env:USERPROFILE, $env:WINDIR, $env:SystemRoot, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:ProgramData)
foreach ($p in $protected) { if ($p -and ($Destination.TrimEnd('\') -ieq $p.TrimEnd('\'))) { throw ('不能安装到这个系统文件夹，请另选专用文件夹。详情：Refusing to install into ' + $Destination + '. Choose a dedicated folder such as C:\MuseCanvas.') } }
$destManage = Join-Path $Destination 'scripts\Manage.ps1'
$hadInstall = Test-Path -LiteralPath $destManage
$prevDataDirectory = ''
if ($hadInstall) {
    $prevInstancePath = Join-Path $Destination 'instance.json'
    if (!(Test-Path -LiteralPath $prevInstancePath)) { throw '旧版缺少数据目录记录，已停止覆盖。请联系维护者确认原来的数据位置。' }
    try { $prevInstance = Get-Content -Raw -Encoding UTF8 -LiteralPath $prevInstancePath | ConvertFrom-Json }
    catch { throw ('旧版的数据目录记录读不出来，已停止覆盖。请联系维护者处理。' + "`n详情：" + $_.Exception.Message) }
    if (!$prevInstance.dataDirectory -or !(Test-Path -LiteralPath $prevInstance.dataDirectory -PathType Container)) { throw '旧版记录的数据目录不存在，已停止覆盖。请先确认原来的数据位置。' }
    $prevDataDirectory = [string]$prevInstance.dataDirectory
    if (!$PSBoundParameters.ContainsKey('ForUser') -and $prevInstance.forUser) { $ForUser = [string]$prevInstance.forUser }
}
if ((Test-Path -LiteralPath $Destination) -and -not $hadInstall) {
    $existing = @(Get-ChildItem -LiteralPath $Destination -Force -ErrorAction SilentlyContinue)
    if ($existing.Count -gt 0) { throw ('这个文件夹里有其他文件，已停止覆盖。请选择空文件夹或旧版 MuseCanvas 目录。详情：Destination ' + $Destination + ' already contains other files and is not a MuseCanvas installation, so it will not be overwritten. Choose an empty folder, or the folder of an existing MuseCanvas install.') }
}

# Resolve the original instance before any staging/config write. Never stop a running user app.
if (!$DataDirectory) {
    if ($prevDataDirectory) { $DataDirectory = $prevDataDirectory }
    else {
        $localApp = if ($ForUser -ieq $env:USERNAME) { [Environment]::GetFolderPath('LocalApplicationData') } else { Join-Path (Join-Path $env:SystemDrive ('Users\' + $ForUser)) 'AppData\Local' }
        $DataDirectory = Join-Path $localApp 'MuseCanvas\data'
    }
}
$DataDirectory = [IO.Path]::GetFullPath($DataDirectory)
if (Test-PathInside $DataDirectory $Destination) { throw '数据目录不能放在程序安装文件夹里。请先把数据迁到独立文件夹后再升级。' }
if ($hadInstall) { Assert-InstallClosed $Destination $DataDirectory }
$browserConfig = Join-Path $DataDirectory 'browser.json'
$browser = Invoke-BrowserLookup $source $browserConfig

# 3) Stage the new tree next to the destination and verify it BEFORE the old
#    install is stopped or moved. A broken source therefore changes nothing.
$stamp = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
$staging = $Destination + '.new-' + $stamp
$backup = $Destination + '.old-' + $stamp
$allowedParent = Split-Path -Parent $Destination
if (!(Test-PathInside $staging $allowedParent) -or !(Test-PathInside $backup $allowedParent)) { throw '安装临时目录不正确，已停止安装。' }
& robocopy $source $staging /MIR /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue; throw ('安装文件复制失败，旧版没有改动。详情：Staging copy failed (robocopy ' + $LASTEXITCODE + '). Nothing was changed.') }
$missingStaged = Get-MissingRequired $staging
if ($missingStaged.Count -gt 0) { Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue; throw ('安装文件不完整，旧版没有改动。详情：Staged copy is incomplete (missing: ' + ($missingStaged -join ', ') + '). Nothing was changed.') }

# 4) Preserve files the user added inside the old install (speech model weights
#    live under models\); everything else in the program folder is replaced.
if ($hadInstall) {
    $oldModels = Join-Path $Destination 'models'
    if (Test-Path -LiteralPath $oldModels) {
        $extras = @(Get-ChildItem -LiteralPath $oldModels -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'README.txt' })
        foreach ($f in $extras) {
            $rel = $f.FullName.Substring($oldModels.Length)
            $target = Join-Path (Join-Path $staging 'models') $rel.TrimStart('\')
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
            Copy-Item -LiteralPath $f.FullName -Destination $target -Force
        }
        if ($extras.Count -gt 0) { Write-Output ('Preserved ' + $extras.Count + ' user-added model file(s) from the previous install.') }
    }
}

# 5) Recheck immediately before replacing files; AV locks get a bounded retry.
if ($hadInstall) { Assert-InstallClosed $Destination $DataDirectory }
# The runtime launcher needs this same helper after installation.
Copy-Item -LiteralPath (Join-Path $source 'Installer-Common.ps1') -Destination (Join-Path $staging 'scripts\Installer-Common.ps1') -Force
$null = Invoke-BrowserLookup $source $browserConfig -Save
$marker = [pscustomobject]@{ product = 'MuseCanvas'; version = '0.23.0'; installedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') }
[IO.File]::WriteAllText((Join-Path $staging 'musecanvas.json'), ($marker | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))

# 5b) Pin the instance: record which data directory belongs to this install, so
# every later Start/Stop/Status - from any Windows account - resolves the same
# data directory instead of the caller's own profile folder.
$instance = [pscustomobject]@{ product = 'MuseCanvas'; version = '0.23.0'; installDir = $Destination; dataDirectory = $DataDirectory; forUser = $ForUser }
[IO.File]::WriteAllText((Join-Path $staging 'instance.json'), ($instance | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))
Invoke-InstallSwap $Destination $staging $backup
Write-Output ('Instance data directory: ' + $DataDirectory)
if (Test-Path -LiteralPath $backup) { Write-Output ('旧版文件已保留备份：' + $backup) }
Write-Output ('Installed MuseCanvas to ' + $Destination)

# 6) Shortcut and optional auto-start.
if (!$NoShortcut) {
    $desktop = [Environment]::GetFolderPath('CommonDesktopDirectory')
    try {
        if (!(Test-Path -LiteralPath $desktop)) { throw 'public desktop unavailable' }
        $probe = Join-Path $desktop ('.musecanvas-write-test-' + [Guid]::NewGuid().ToString('N'))
        [IO.File]::WriteAllText($probe, '')
        Remove-Item -LiteralPath $probe -Force
    } catch {
        if ($ForUser -ieq $env:USERNAME) { $desktop = [Environment]::GetFolderPath('Desktop') }
        else { $desktop = Join-Path (Join-Path $env:SystemDrive ('Users\' + $ForUser)) 'Desktop' }
        Write-Output ('Public desktop is not writable; the shortcut will be created on the desktop of user ' + $ForUser + ' instead.')
    }
    $lnkPath = Join-Path $desktop 'MuseCanvas.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($lnkPath)
    $lnk.TargetPath = 'powershell.exe'
    $lnk.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $destManage + '" -Action Start'
    $lnk.WorkingDirectory = $Destination
    $lnk.Description = 'Start MuseCanvas (local canvas, agent, generation pool and export service)'
    $lnk.Save()
    Write-Output ('Desktop shortcut created: ' + $lnkPath)
}
if ($AutoStart) {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $destManage + '" -Action Start -NoBrowser')
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $ForUser
    $principal = New-ScheduledTaskPrincipal -UserId $ForUser -LogonType Interactive -RunLevel Limited
    Register-ScheduledTask -TaskName 'MuseCanvas' -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
    Write-Output 'Auto-start at logon registered (scheduled task: MuseCanvas).'
}
Write-Output ''
Write-Output 'To start: double-click the MuseCanvas desktop shortcut, or run:'
Write-Output ('  powershell -ExecutionPolicy Bypass -File "' + $destManage + '" -Action Start')
Write-Output 'To stop: the same command with -Action Stop. Status: -Action Status.'
Write-Output ('Your data lives outside the program folder in ' + $DataDirectory + ' and is never touched by install or update. The install records this location in instance.json inside the program folder, so Start/Stop/Status use the same data directory no matter which Windows account runs them.')
Write-Output 'To uninstall: stop the app, delete the program folder above. Delete the data folder too only if you no longer need your settings, agent workspace and merged videos - that deletion cannot be undone.'
Write-Output 'First run opens the canvas in your browser. Sign in to the generation pool with YOUR OWN Muse account, and connect Codex or Claude with your own account/API key. No account data is included in this package.'

} catch {
    if ($_.Exception.Message -match '^[\p{IsCJKUnifiedIdeographs}]') { throw }
    throw ('安装没有完成。请先关闭 MuseCanvas，确认安装文件未被占用后重试。' + "`n详情：" + $_.Exception.Message)
}
