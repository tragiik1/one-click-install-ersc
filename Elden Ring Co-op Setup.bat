@echo off
title Elden Ring Seamless Co-op Setup
set "ERSC_SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$t = [IO.File]::ReadAllText($env:ERSC_SELF); iex $t.Substring($t.LastIndexOf('#PS-START') + 9)"
echo.
pause
exit /b
#PS-START
# One-click installer for Elden Ring Seamless Co-op (https://github.com/tragiik1/one-click-install-ersc)
# Downloads the latest official release from https://github.com/yuiamoroll/EldenRingSeamlessCoopRelease
# and installs it with the shared group settings below. Never deletes anything.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# The group's settings. The co-op password is asked for during setup and put in place of __PASSWORD__.
$Settings = @'
[GAMEPLAY]

; Invaders are other players that will join your world uninvited and try to kill you and your party.  0=FALSE  1=TRUE
allow_invaders = 0

; Debuffs (Rot Essence) will be acquired when you die, and will only be cured when you sit at a bonfire.  0=FALSE  1=TRUE
death_debuffs = 1

; Spirit summons can aid you in multiplayer.  0=FALSE  1=TRUE
allow_summons = 1

; 0 = Normal | 1 = None | 2 = Display player ping | 3 = Display player soul level | 4 = Display player death count | 5 = Soul level AND ping
overhead_player_display = 0

; Whether to skip the intro logos when booting the game. 0 = FALSE 1 = TRUE
skip_splash_screens = 0

; 0 = No change | 1 = Will add the player's unique Steam ID to the end of their overhead display. Can be useful for identifying and blocking cheaters
append_steam_id_to_players = 0

; 0 = Spectate only during boss fights and invasion encounters | 1 = Always spectate other players on death until party wipeout or bonfire rest
always_spectate_on_death = 0 

; Game volume before initial save load. 0 = MUTE 10 = MAX
default_boot_master_volume = 5

[SCALING]

; Amount of enemy health (%) per player for each enemy. (Default: 35 = 35% more enemy health per player)
enemy_health_scaling = 35

; Amount of enemy damage (%) per player for each enemy. (Default: 0 = 0% more enemy damage per player)
enemy_damage_scaling = 0

; Amount of enemy posture absorption (%) per player for each enemy. (Default: 15 = 15% more per player)
enemy_posture_scaling = 15

; Amount of boss health (%) per player for bosses. (Default: 100 = 100% more boss health per player)
boss_health_scaling = 100

; Amount of enemy damage (%) per player for bosses. (Default: 0 = 0% more enemy damage towards players, per player)
boss_damage_scaling = 0

; Amount of boss posture absorption (%) per player for bosses. (Default: 20 = 20% more boss posture per player)
boss_posture_scaling = 20

[PASSWORD]

; Session password
cooppassword = __PASSWORD__

[SAVE]

;Your save file extension (in the vanilla game this is .sl2). Use any alphanumeric characters (limit = 120)
save_file_extension = co2

[LANGUAGE]

;Leave this blank unless you want to load a custom locale file. The mod will default to your game language.
mod_language_override =
'@
$Repos = @('yuiamoroll/EldenRingSeamlessCoopRelease', 'LukeYui/EldenRingSeamlessCoopRelease')

function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }
function Fail($msg) {
    Write-Host ''
    Say '  SETUP DID NOT FINISH' 'Red'
    Say "  $msg" 'Yellow'
    Write-Host ''
    Say '  Send Noah a screenshot of this window.' 'Gray'
}

function Test-GameDir($dir) {
    return $dir -and (Test-Path -LiteralPath (Join-Path $dir 'eldenring.exe'))
}

function Find-GameDir {
    if ($env:ERSC_GAME_DIR) { return $env:ERSC_GAME_DIR }   # testing only
    $rel = 'steamapps\common\ELDEN RING\Game'
    $candidates = New-Object System.Collections.Generic.List[string]
    $candidates.Add("C:\Program Files (x86)\Steam\$rel")
    $steamRoots = @()
    foreach ($key in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        try {
            $k = Get-ItemProperty -LiteralPath $key -ErrorAction Stop
            foreach ($v in $k.SteamPath, $k.InstallPath) { if ($v) { $steamRoots += ($v -replace '/', '\') } }
        } catch {}
    }
    foreach ($root in ($steamRoots | Select-Object -Unique)) {
        $candidates.Add((Join-Path $root $rel))
        $vdf = Join-Path $root 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            try {
                foreach ($m in [regex]::Matches([IO.File]::ReadAllText($vdf), '"path"\s+"([^"]+)"')) {
                    $candidates.Add((Join-Path ($m.Groups[1].Value -replace '\\\\', '\') $rel))
                }
            } catch {}
        }
    }
    foreach ($c in $candidates) { if (Test-GameDir $c) { return $c } }
    return $null
}

function Test-CanWrite($dir) {
    $probe = Join-Path $dir ('.ersc_setup_' + [guid]::NewGuid().ToString('N'))
    try { [IO.File]::WriteAllText($probe, 'x'); Remove-Item -LiteralPath $probe -Force; return $true } catch { return $false }
}

function Get-CurrentPassword($iniPath) {
    if (-not (Test-Path -LiteralPath $iniPath)) { return $null }
    try {
        $m = [regex]::Match([IO.File]::ReadAllText($iniPath), '(?m)^\s*cooppassword\s*=[ \t]*(.*?)\s*$')
        if ($m.Success -and $m.Groups[1].Value -and $m.Groups[1].Value -ne 'yourpasswordhere') { return $m.Groups[1].Value }
    } catch {}
    return $null
}

$tmp = $null
try {
    Write-Host ''
    Say '  Elden Ring Seamless Co-op setup' 'Cyan'
    Write-Host ''

    # 1. Game must be closed
    Say '  [1/6] Checking Elden Ring is closed...'
    if (Get-Process -Name 'eldenring', 'start_protected_game', 'ersc_launcher' -ErrorAction SilentlyContinue) {
        Fail 'Elden Ring is running. Close the game completely, then run this file again.'; return
    }

    # 2. Find the game
    Say '  [2/6] Looking for your Elden Ring folder...'
    $game = Find-GameDir
    if (-not (Test-GameDir $game)) { Fail 'Could not find Elden Ring. Is it installed through Steam on this PC?'; return }
    Say "        Found: $game" 'DarkGray'

    if (-not (Test-CanWrite $game)) {
        if (-not $env:ERSC_ELEVATED) {
            Say '        Windows needs permission to write there. Click "Yes" on the next prompt.' 'Yellow'
            try {
                Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', "set ERSC_ELEVATED=1&& `"$env:ERSC_SELF`"" -Verb RunAs
                Say '        Setup continues in the new window. You can close this one.' 'Gray'
            } catch { Fail 'Permission was refused. Run this file again and click "Yes" when Windows asks.' }
            return
        }
        Fail "Windows will not let this setup write to: $game"; return
    }

    $coopDir = Join-Path $game 'SeamlessCoop'
    $iniPath = Join-Path $coopDir 'ersc_settings.ini'

    # 3. Co-op password
    Say '  [3/6] Co-op password'
    $current = Get-CurrentPassword $iniPath
    $password = $null
    $tries = 0
    while (-not $password) {
        if (++$tries -gt 5) { Fail 'No password was entered.'; return }
        if ($current) { $typed = Read-Host '        Type the co-op password Noah gave you (or just press Enter to keep your current one)' }
        else { $typed = Read-Host '        Type the co-op password Noah gave you, then press Enter' }
        $typed = "$typed".Trim()
        if ($typed) { $password = $typed }
        elseif ($current) { $password = $current }
        else { Say '        The password cannot be empty.' 'Yellow' }
    }

    # 4. Download the latest official release
    Say '  [4/6] Downloading the latest Seamless Co-op from the official GitHub page...'
    $headers = @{ 'User-Agent' = 'one-click-install-ersc' }
    $release = $null
    foreach ($r in $Repos) {
        try { $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$r/releases/latest" -Headers $headers; break } catch {}
    }
    if (-not $release) { Fail 'Could not reach GitHub. Check your internet connection and try again.'; return }
    $asset = $release.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
    if (-not $asset) { Fail "The latest release ($($release.tag_name)) has no zip file."; return }
    Say "        Version $($release.tag_name)" 'DarkGray'

    $tmp = Join-Path $env:TEMP ('ersc_setup_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    $zip = Join-Path $tmp 'release.zip'
    try { Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip -UseBasicParsing -Headers $headers }
    catch { Fail 'The download failed. Check your internet connection and try again.'; return }
    $out = Join-Path $tmp 'files'
    try { Expand-Archive -LiteralPath $zip -DestinationPath $out -Force }
    catch { Fail 'The downloaded file could not be opened. Try again.'; return }

    $srcLauncher = Get-ChildItem -LiteralPath $out -Recurse -Filter 'ersc_launcher.exe' | Select-Object -First 1
    if (-not $srcLauncher -or -not (Test-Path -LiteralPath (Join-Path $srcLauncher.DirectoryName 'SeamlessCoop\ersc.dll'))) {
        Fail 'The download did not contain the expected mod files (your antivirus may have removed them).'; return
    }
    $srcRoot = $srcLauncher.DirectoryName
    $srcCoop = Join-Path $srcRoot 'SeamlessCoop'

    # 5. Install: back up old settings, copy release files over (adds/overwrites only), write settings
    Say '  [5/6] Installing the mod and the group settings...'
    if (Test-Path -LiteralPath $iniPath) {
        $backup = Join-Path $coopDir ('ersc_settings.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.ini')
        Copy-Item -LiteralPath $iniPath -Destination $backup
        Say "        Your old settings were saved as $(Split-Path $backup -Leaf)" 'DarkGray'
    }
    $iniText = ($Settings -replace "`r?`n", "`r`n").Replace('__PASSWORD__', $password)
    try {
        Copy-Item -LiteralPath $srcLauncher.FullName -Destination (Join-Path $game 'ersc_launcher.exe') -Force
        foreach ($f in Get-ChildItem -LiteralPath $srcCoop -Recurse -File) {
            $dst = Join-Path $coopDir $f.FullName.Substring($srcCoop.Length).TrimStart('\')
            $dstDir = Split-Path $dst -Parent
            if (-not (Test-Path -LiteralPath $dstDir)) { New-Item -ItemType Directory -Path $dstDir | Out-Null }
            Copy-Item -LiteralPath $f.FullName -Destination $dst -Force
        }
        [IO.File]::WriteAllText($iniPath, $iniText, (New-Object Text.UTF8Encoding $false))
    } catch { Fail "Could not copy the files into the game folder: $($_.Exception.Message)"; return }

    $ok = (Test-Path -LiteralPath (Join-Path $coopDir 'ersc.dll')) -and
          (Test-Path -LiteralPath (Join-Path $game 'ersc_launcher.exe')) -and
          ([IO.File]::ReadAllText($iniPath) -ceq $iniText)
    if (-not $ok) { Fail 'The files were copied but something is missing (your antivirus may have removed ersc.dll).'; return }

    # 6. Desktop shortcut
    Say '  [6/6] Adding the "Elden Ring Co-op" shortcut to your desktop...'
    $desktop = if ($env:ERSC_DESKTOP) { $env:ERSC_DESKTOP }               # testing only
               elseif ($env:ERSC_ELEVATED) { [Environment]::GetFolderPath('CommonDesktopDirectory') }
               else { [Environment]::GetFolderPath('Desktop') }
    try {
        $sh = New-Object -ComObject WScript.Shell
        $lnk = $sh.CreateShortcut((Join-Path $desktop 'Elden Ring Co-op.lnk'))
        $lnk.TargetPath = Join-Path $game 'ersc_launcher.exe'
        $lnk.WorkingDirectory = $game
        $lnk.IconLocation = (Join-Path $game 'eldenring.exe') + ',0'
        $lnk.Description = 'Start Elden Ring with Seamless Co-op'
        $lnk.Save()
    } catch { Fail "The mod is installed, but the desktop shortcut could not be made. Start the game with ersc_launcher.exe in: $game"; return }

    Write-Host ''
    Say "  ALL DONE! Seamless Co-op $($release.tag_name) is installed with the group settings." 'Green'
    Write-Host ''
    Say '  To play: open Steam, then double-click "Elden Ring Co-op" on your desktop.' 'White'
    Say '  (Steam''s Play button starts the normal game without co-op.)' 'Gray'
}
catch {
    Fail "Unexpected problem: $($_.Exception.Message)"
}
finally {
    if ($tmp -and (Test-Path -LiteralPath $tmp)) { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}
