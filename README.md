# iptv
Front end for watching streaming video channels (IPTV), playback is via mpv or VLC.


`windows_iptv` is a powershell IPTV player for M3U playlists with fuzzy finding, right in your powershell window.

The playlist will be updated once a day whenever you run `iptv.ps1`.

The default player is now vlc, but if that isn't detectable, it will drop back to mpv. VLC was choosen as it has a bit more debugging messages

## Dependencies
- [curl](https://github.com/curl/curl)
- [fzf](https://github.com/junegunn/fzf)
- [mpv](https://github.com/mpv-player/mpv) and/or [vlc](https://www.videolan.org/vlc/download-windows.html)

All dependencies are tested at launch and instructions are provided at launch for installing them if they are not already installed. 

## Installation
Download and run from powershell.

Run `iptv.ps1` with your playlist URL to load all the channels (only needed on first run).

Two example playlists are given below 

(note that both may have inactive or out of date channels - please take that up with the respective maintainers of those repos)

```
iptv.ps1 https://iptv-org.github.io/iptv/index.m3u
```
```
iptv.ps1 https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8
```

## Usage
Run `iptv.ps1`.
