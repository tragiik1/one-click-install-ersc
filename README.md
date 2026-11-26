# One-click Elden Ring Seamless Co-op installer

Sets up [Seamless Co-op](https://www.nexusmods.com/eldenring/mods/510) with our group's settings so we can play together.

## Install

1. **[Download Elden-Ring-Co-op-Setup.zip](https://github.com/tragiik1/one-click-install-ersc/releases/latest/download/Elden-Ring-Co-op-Setup.zip)**
2. Close Elden Ring.
3. Open the zip and double-click **Elden Ring Co-op Setup**.
   - If a blue "Windows protected your PC" box appears: click **More info**, then **Run anyway**.
   - If Windows asks "Do you want to allow this app to make changes?": click **Yes**.
4. Type the co-op password Noah gave you and press Enter.
5. Wait for **ALL DONE!**, then press any key to close the window.

Run it again whenever the mod updates. Everyone has to be on the same mod version to connect. When you run it again, press Enter at the password prompt to keep your current password.

## Play

- Open Steam, then start the game with the **Elden Ring Co-op** shortcut on your desktop. Steam's Play button starts the normal game without co-op.
- The host uses the **Tiny Great Pot**. Everyone else joins with the **Effigy of Meleina**.
- Co-op uses its own save files (`.co2`), so your normal save isn't touched.

## What it does, exactly

1. Stops if Elden Ring is running.
2. Finds your Elden Ring `Game` folder. It checks the default Steam folder first, then every Steam library listed in Steam's `libraryfolders.vdf`.
3. If Windows won't let it write there, it asks for admin permission and starts again.
4. Asks for the co-op password. The password is never stored in this repo.
5. Downloads the latest official release zip from [yuiamoroll/EldenRingSeamlessCoopRelease](https://github.com/yuiamoroll/EldenRingSeamlessCoopRelease/releases/latest) into a temporary folder. The mod itself is not included here, because its author doesn't allow redistribution.
6. If you already have `SeamlessCoop\ersc_settings.ini`, copies it to `ersc_settings.backup-<date-time>.ini` next to it.
7. Copies `ersc_launcher.exe` and the `SeamlessCoop` folder from the release into the `Game` folder. Files from the release overwrite older copies. **Nothing is deleted.** Other files and mods in the folder are left alone.
8. Writes the group settings (below) plus your password to `SeamlessCoop\ersc_settings.ini`, then checks that every file is in place.
9. Puts an **Elden Ring Co-op** shortcut on your desktop that starts `ersc_launcher.exe`.
10. Deletes its temporary download.

It never touches your save files, which are in `%APPDATA%\EldenRing`.

## Group settings

| Setting | Value |
|---|---|
| Invaders | off |
| Death debuffs | on |
| Spirit summons | on |
| Enemy health per extra player | +35% |
| Enemy damage per extra player | +0% |
| Enemy posture per extra player | +15% |
| Boss health per extra player | +100% |
| Boss damage per extra player | +0% |
| Boss posture per extra player | +20% |

The full settings file is inside `Elden Ring Co-op Setup.bat`, which you can open in Notepad to read.
