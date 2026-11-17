<div align="center">

# Customize Your Coding Environment

**Your terminal doesn't have to be a sad black box. Make it yours!**

A Layer Zero x Software Engineering Club x Girls Who Code workshop at UNLV

Tue Nov 17, 2026 · 5:30 to 6:45 PM · AEB Flexatorium

</div>

<!--TODO: Add a screenshot of the finished setup here-->

## About

So this repo is the starting point for the terminal part of the workshop, it has a base config for each terminal plus a shared prompt, so you can pull it, run one script, and then focus on tweaking things instead of staring at docs.

Now the basic idea is that everyone starts from the same base and then customizes it, swap the theme, change the font, mess with the transparency, whatever you want to do. There is no "correct" setup, just whatever you feel like.

| OS      | Terminal             | Prompt       |
| ------- | -------------------- | ------------ |
| Windows | **Windows Terminal** | **Starship** |
| macOS   | **Ghostty**          | **Starship** |
| Linux   | **Ghostty**          | **Starship** |

## Features

- [Catppuccin](https://catppuccin.com) Mocha theme across the terminal and prompt, with Latte in light mode on Ghostty
- [JetBrains Mono Nerd Font](https://www.nerdfonts.com) so icons show up in your prompt
- Slight transparency + blur, padding, bar cursor
- vim style `ctrl+alt+h/j/k/l` to move between splits
- [Starship](https://starship.rs) prompt that shows your OS, folder, git branch and language versions, and the same config works on every OS
- Install scripts that back up your old configs before touching anything

## Installation

### 1. Install a Nerd Font

Nerd Fonts are normal coding fonts patched with a bunch of icons, without one your prompt shows boxes instead of logos.

| OS                       | Command                                                                                                                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Windows                  | Download `JetBrainsMono.zip` from [nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads), unzip, select all the `.ttf` files, right click → **Install** |
| macOS                    | `brew install --cask font-jetbrains-mono-nerd-font`                                                                                                                       |
| Arch                     | `sudo pacman -S ttf-jetbrains-mono-nerd`                                                                                                                                  |
| Ubuntu / Debian / Fedora | See below                                                                                                                                                                 |

```sh
# Ubuntu / Debian / Fedora
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -f
```

### 2. Install your terminal

| OS              | Command                                                              |
| --------------- | -------------------------------------------------------------------- |
| Windows 11      | Already installed, search "Terminal"                                 |
| Windows 10      | `winget install --id Microsoft.WindowsTerminal`                      |
| macOS           | `brew install --cask ghostty`                                        |
| Arch            | `sudo pacman -S ghostty`                                             |
| Fedora          | `sudo dnf copr enable scottames/ghostty && sudo dnf install ghostty` |
| Ubuntu / Debian | `sudo snap install ghostty --classic`                                |

> Using WSL? Use Windows Terminal, Ghostty doesn't run on Windows.

### 3. Install Starship

| OS          | Command                                         |
| ----------- | ----------------------------------------------- |
| Windows     | `winget install --id Starship.Starship`         |
| macOS       | `brew install starship`                         |
| Arch        | `sudo pacman -S starship`                       |
| Other Linux | `curl -sS https://starship.rs/install.sh \| sh` |

### 4. Grab the configs

```sh
# TODO: Swap in the real URL once this is pushed
git clone https://github.com/LayerZeroUnlv/customize-your-env.git
cd customize-your-env
```

No git? Hit the green **Code** button on GitHub → **Download ZIP** and unzip it.

## Usage

### macOS / Linux

```sh
./scripts/install.sh
```

That copies `ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty`, `starship/starship.toml` to `~/.config/starship.toml`, and adds the Starship line to your `.bashrc`, `.zshrc` or fish config. Anything already there gets backed up as `*.bak-<timestamp>` first.

Open a new Ghostty window and you're set.

> macOS note: if you already have a config in `~/Library/Application Support/com.mitchellh.ghostty/`, Ghostty loads that one too and it'll take priority, rename it or move your changes over.

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

That handles Starship. For Windows Terminal itself:

1. Open Windows Terminal, hit `ctrl+,` to open Settings
2. Bottom left, click **Open JSON file**
3. Copy the `"Catppuccin Mocha"` object from [`windows-terminal/settings-snippet.json`](windows-terminal/settings-snippet.json) into the `"schemes": [ ... ]` list
4. Copy everything inside `"defaults": { ... }` from the snippet into your `"profiles": { "defaults": { ... } }`
5. Optional: copy the entries from `"actions"` into your `"actions"` list for the split keybinds
6. Save, it reloads by itself

Don't paste over the whole file, your profiles have IDs unique to your machine.

## Make it yours

This is the fun part, try stuff and see what you like.

| Want to...              | Ghostty                                                        | Windows Terminal                                                                                              | Starship                                           |
| ----------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| Change the theme        | `ghostty +list-themes`, preview and copy a name into `theme =` | Settings → **Color schemes**, or grab one from [windowsterminalthemes.dev](https://windowsterminalthemes.dev) | Change `palette =` or try `starship preset --list` |
| Change the font         | `font-family =` (try `Iosevka Nerd Font`)                      | `"font": { "face": ... }`                                                                                     | Uses your terminal's font                          |
| More / less see through | `background-opacity =` (0 to 1)                                | `"opacity":` (0 to 100)                                                                                       | n/a                                                |
| Add space around text   | `window-padding-x/y =`                                         | `"padding":`                                                                                                  | `add_newline =`                                    |
| Change the cursor       | `cursor-style =` (block, bar, underline)                       | `"cursorShape":`                                                                                              | `[character]` symbols                              |
| Background image        | Uncomment the `background-image` lines, full path, PNG/JPEG    | Settings → Defaults → Appearance → **Background image**, or `"backgroundImage"` + `"backgroundImageOpacity"` | n/a                                                |

Reload Ghostty with `ctrl+shift+,` on Linux or `cmd+shift+,` on mac. Windows Terminal and Starship reload on save.

Every Ghostty option with docs: `ghostty +show-config --default --docs`

## Resources

- [Ghostty docs](https://ghostty.org/docs/config)
- [Windows Terminal docs](https://learn.microsoft.com/windows/terminal/customize-settings/profile-general)
- [Starship config](https://starship.rs/config/) and [presets](https://starship.rs/presets/)
- [Nerd Fonts](https://www.nerdfonts.com) and [Iosevka](https://typeof.net/Iosevka/)
- [Catppuccin ports](https://catppuccin.com/ports) for basically every app you use
- [r/unixporn](https://reddit.com/r/unixporn) for Linux ricing inspo

<!--TODO: Add links to SEC and GWC section materials-->
