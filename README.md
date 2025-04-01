# iptv
Front end for watching streaming video channels (IPTV), playback is via mpv.


`windows_iptv` is a powershell IPTV player for M3U playlists with fuzzy finding, right in your powershell window.

The playlist will be updated once a day whenever you run `iptv.ps1`.

## Dependencies
- [curl](https://github.com/curl/curl)
- [fzf](https://github.com/junegunn/fzf)
- [mpv](https://github.com/mpv-player/mpv)

All dependencies are tested at launch and instructions are provided at launch for installing them if they are not already installed. 

## Installation
Download and run from powershell.

Run `iptv.ps1` with your playlist URL to load all the channels (only needed on first run).

Two example playlists are given below (note that both may have inactive or out of date channels - please take that up with the respective maintainers of those repos)

```
iptv.ps1 https://iptv-org.github.io/iptv/index.m3u
```
```
iptv.ps1 https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8
```

## Usage
Run `iptv.ps1`.
