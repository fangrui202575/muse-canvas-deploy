param(
    [string]$Destination = 'C:\MuseCanvas',
    [switch]$AutoStart,
    [switch]$NoShortcut
)
$ErrorActionPreference = 'Stop'
$source = $PSScriptRoot
$Destination = [IO.Path]::GetFullPath($Destination)

function Get-MissingRequired($root) {
    $required = @('scripts\Manage.ps1', 'node\node.exe', 'pool\MusePool.exe', 'agent\agent.cjs', 'services\entry.cjs', 'services\web.jsc', 'services\merge.jsc', 'web\index.html', 'tools\ffmpeg.exe', 'tools\ffprobe.exe')
    return @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) })
}

# 1) Validate the install SOURCE first. Nothing is touched before this passes.
$missing = Get-MissingRequired $source
if ($missing.Count -gt 0) { throw ('Install source is incomplete (missing: ' + ($missing -join ', ') + '). Re-download and re-extract the package. Nothing was changed.') }
if ($source.TrimEnd('\') -ieq $Destination.TrimEnd('\')) { throw 'Source and destination are the same folder. Extract the package somewhere else first, then run Install.ps1 from there.' }

# 2) Destination safety: never install into a protected location, and never
#    overwrite a folder that holds other files and is not a MuseCanvas install.
$protected = @([IO.Path]::GetPathRoot($Destination), $env:USERPROFILE, $env:WINDIR, $env:SystemRoot, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:ProgramData)
foreach ($p in $protected) { if ($p -and ($Destination.TrimEnd('\') -ieq $p.TrimEnd('\'))) { throw ('Refusing to install into ' + $Destination + '. Choose a dedicated folder such as C:\MuseCanvas.') } }
$destManage = Join-Path $Destination 'scripts\Manage.ps1'
$hadInstall = Test-Path -LiteralPath $destManage
if ((Test-Path -LiteralPath $Destination) -and -not $hadInstall) {
    $existing = @(Get-ChildItem -LiteralPath $Destination -Force -ErrorAction SilentlyContinue)
    if ($existing.Count -gt 0) { throw ('Destination ' + $Destination + ' already contains other files and is not a MuseCanvas installation, so it will not be overwritten. Choose an empty folder, or the folder of an existing MuseCanvas install.') }
}

# 3) Stage the new tree next to the destination and verify it BEFORE the old
#    install is stopped or moved. A broken source therefore changes nothing.
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$staging = $Destination + '.new-' + $stamp
$backup = $Destination + '.old-' + $stamp
& robocopy $source $staging /MIR /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue; throw ('Staging copy failed (robocopy ' + $LASTEXITCODE + '). Nothing was changed.') }
$missingStaged = Get-MissingRequired $staging
if ($missingStaged.Count -gt 0) { Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue; throw ('Staged copy is incomplete (missing: ' + ($missingStaged -join ', ') + '). Nothing was changed.') }

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

# 5) Stop the old install, then swap folders. If the swap fails, the previous
#    install is put back (rollback).
if ($hadInstall) {
    Write-Output 'Stopping the existing installation...'
    & $destManage -Action Stop | Out-Null
    Start-Sleep -Seconds 3
}
try {
    if (Test-Path -LiteralPath $Destination) { Move-Item -LiteralPath $Destination -Destination $backup }
    Move-Item -LiteralPath $staging -Destination $Destination
} catch {
    if ((Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $Destination)) { Move-Item -LiteralPath $backup -Destination $Destination }
    throw ('Install failed during the folder swap; the previous installation was restored. ' + $_.Exception.Message)
}
$marker = [pscustomobject]@{ product = 'MuseCanvas'; version = '0.20.0-preview.1'; installedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') }
[IO.File]::WriteAllText((Join-Path $Destination 'musecanvas.json'), ($marker | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))
if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction SilentlyContinue }
Write-Output ('Installed MuseCanvas to ' + $Destination)

# 6) Shortcut and optional auto-start.
if (!$NoShortcut) {
    $desktop = [Environment]::GetFolderPath('Desktop')
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
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
    Register-ScheduledTask -TaskName 'MuseCanvas' -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
    Write-Output 'Auto-start at logon registered (scheduled task: MuseCanvas).'
}
Write-Output ''
Write-Output 'To start: double-click the MuseCanvas desktop shortcut, or run:'
Write-Output ('  powershell -ExecutionPolicy Bypass -File "' + $destManage + '" -Action Start')
Write-Output 'To stop: the same command with -Action Stop. Status: -Action Status.'
Write-Output 'Your data lives outside the program folder in %LOCALAPPDATA%\MuseCanvas\data and is never touched by install or update.'
Write-Output 'To uninstall: stop the app, delete the program folder above. Delete the data folder too only if you no longer need your settings, agent workspace and merged videos - that deletion cannot be undone.'
Write-Output 'First run opens the canvas in your browser. Sign in to the generation pool with YOUR OWN Muse account, and connect Codex or Claude with your own account/API key. No account data is included in this package.'
