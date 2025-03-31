# iptv
`windows_iptv` is a powershell IPTV player for M3U playlists with fuzzy finding, right in your powershell window.

The playlist will be updated once a day whenever you run `iptv`.

## Dependencies
- [curl](https://github.com/curl/curl)
- [fzf](https://github.com/junegunn/fzf)
- [mpv](https://github.com/mpv-player/mpv)

All dependencies are tested at launch and instructions are provided at launch for installing them. 

## Installation
Download and run from powershell.

Run `iptv.ps1` with your playlist URL to load all the channels (only needed on first run).
```
iptv.ps1 https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8
```

## Usage
Run `iptv`.
