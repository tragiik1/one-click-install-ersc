# One-click Elden Ring Seamless Co-op installer

Installs the latest [Seamless Co-op](https://www.nexusmods.com/eldenring/mods/510) release with a preset configuration.

## Install

1. **[Download Elden-Ring-Co-op-Setup.zip](https://github.com/tragiik1/one-click-install-ersc/releases/latest/download/Elden-Ring-Co-op-Setup.zip)**
2. Close Elden Ring.
3. Open the zip and run **Elden Ring Co-op Setup**.
   - If Windows shows "Windows protected your PC", select **More info**, then **Run anyway**.
   - If Windows asks for permission to make changes, select **Yes**.
4. Enter the session password.
5. When setup reports **Setup complete**, press any key to close the window.

Run setup again whenever the mod updates; all players need the same mod version to connect. On later runs, leave the password blank to keep the current one.

## Play

- Open Steam, then launch **Elden Ring Co-op** from your desktop. Launching from Steam starts the game without Seamless Co-op.
- The host uses the **Tiny Great Pot**; other players join with the **Effigy of Meleina**.
- Seamless Co-op uses separate save files (`.co2`), so standard saves are unaffected.

## What setup does

1. Stops if Elden Ring is running.
2. Locates the Elden Ring `Game` folder: the default Steam location first, then every Steam library listed in `libraryfolders.vdf`.
3. If the folder is not writable, requests administrator permission and restarts.
4. Prompts for the session password. No password is stored in this repository.
5. Downloads the latest official release from [yuiamoroll/EldenRingSeamlessCoopRelease](https://github.com/yuiamoroll/EldenRingSeamlessCoopRelease/releases/latest) to a temporary folder. The mod is not redistributed here.
6. Backs up any existing `SeamlessCoop\ersc_settings.ini` as `ersc_settings.backup-<date-time>.ini`.
7. Copies `ersc_launcher.exe` and the `SeamlessCoop` folder into the `Game` folder, replacing older versions of those files. **No files are deleted**; other files and mods are left in place.
8. Writes the preset settings below, with the password, to `SeamlessCoop\ersc_settings.ini`, then verifies that all files are present.
9. Creates an **Elden Ring Co-op** desktop shortcut to `ersc_launcher.exe`.
10. Removes its temporary download.

Save files in `%APPDATA%\EldenRing` are never modified.

## Preset settings

| Setting | Value |
|---|---|
| Invaders | Off |
| Death debuffs (Rot Essence) | Off |
| Spirit summons | On |
| Enemy health per additional player | +35% |
| Enemy damage per additional player | +0% |
| Enemy posture per additional player | +15% |
| Boss health per additional player | +100% |
| Boss damage per additional player | +0% |
| Boss posture per additional player | +20% |

The complete settings file is embedded in `Elden Ring Co-op Setup.bat` and can be viewed in any text editor.
