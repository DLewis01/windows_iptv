#!/usr/bin/env pwsh

<#
.SYNOPSIS
Robust IPTV channel selector with URL validation
#>

# Configuration paths
$config_path = "$HOME/.config/iptv/"
$channels_file = "$config_path/channels"
$m3u_url_file = "$config_path/m3u_url"
$tmp_playlist = "$env:TEMP/iptvplaylist"
$player_pid_file = "$env:TEMP/iptvplayerpid"

# Dependency checks
if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Write-Error "fzf required. Install with: winget install fzf"
    exit 1
}

if (-not (Get-Command mpv -ErrorAction SilentlyContinue)) {
    Write-Error "mpv required. Install with: winget install mpv"
    exit 1
}

function Save-Channels {
    if (-not (Test-Path $m3u_url_file)) {
        Write-Error "No M3U URL configured. First run with: iptv [M3U_URL]"
        exit 1
    }

    $m3u_url = Get-Content $m3u_url_file
    Write-Host "Downloading playlist..." -NoNewline

    try {
        Invoke-WebRequest -Uri $m3u_url -OutFile $tmp_playlist -ErrorAction Stop
        Write-Host " Done"
    } catch {
        Write-Host " Failed"
        Write-Error "Download error: $_"
        exit 1
    }

    Write-Host "Parsing channels..." -NoNewline
    $valid_channels = @()
    $current_name = $null

    Get-Content $tmp_playlist | ForEach-Object {
        if ($_ -match '#EXTINF:-1.*,(.*)') {
            $current_name = $Matches[1].Trim()
        } 
        elseif ($_ -match '^(https?://[^\s]+)') {
            if ($current_name -and $Matches[1]) {
                $valid_channels += "$current_name|$($Matches[1])"
                $current_name = $null
            }
        }
    }

    if ($valid_channels.Count -eq 0) {
        Write-Error "No valid channels found in playlist!"
        exit 1
    }

    $valid_channels | Out-File $channels_file -Force
    Write-Host " Done ($($valid_channels.Count) valid channels)"
}

# Initialize config directory
if (-not (Test-Path $config_path)) {
    New-Item -ItemType Directory -Path $config_path -Force | Out-Null
}

# First-run setup with M3U URL
if ($args[0] -and $args[0] -notin @('-h','--help')) {
    $args[0] | Out-File $m3u_url_file -Force
    Save-Channels
    Write-Host "Playlist saved. Run without arguments to select channels."
    exit
}

# Help display
if ($args[0] -in @('-h','--help')) {
    Write-Host @"
Usage: iptv [M3U_URL]

First run:
  iptv http://your-provider.com/playlist.m3u

Subsequent runs:
  iptv
"@
    exit
}

# Auto-update if channels file is older than 1 day
if ((Test-Path $channels_file) -and 
    (Get-Item $channels_file).LastWriteTime -lt (Get-Date).AddDays(-1)) {
    Write-Host "Updating channel list..."
    Save-Channels
}

# Verify we have channels
if (-not (Test-Path $channels_file)) {
    Write-Error "No channels found. First run with an M3U URL."
    exit 1
}

# Load only valid channels (name|url format)
$channels = Get-Content $channels_file | Where-Object {
    $_ -match '^.+?\|https?://.+$'
}

if (-not $channels) {
    Write-Error "No valid channels in playlist. Update with: iptv [NEW_URL]"
    exit 1
}

# Channel selection with fzf (only shows valid entries)
$selected = $channels | ForEach-Object {
    $name, $url = $_ -split '\|', 2
    if ($url -match '^https?://') { $name.Trim() }
} | Where-Object { $_ } | fzf --height 40% --reverse

if (-not $selected) { exit }

# Extract URL with strict validation
$selected_line = $channels -match "^$([regex]::Escape($selected))\|"
$selected_url = ($selected_line -split '\|')[1].Trim()

if (-not $selected_url -or -not $selected_url.StartsWith('http')) {
    Write-Error "Invalid URL for '$selected': '$selected_url'"
    exit 1
}

Write-Host "`nPlaying: $selected"
Write-Host "URL: $selected_url`n"

# Stop existing MPV instance
if (Test-Path $player_pid_file) {
    $mpv_pid = Get-Content $player_pid_file
    if ($mpv_pid -match '^\d+$') {
        try {
            Stop-Process -Id $mpv_pid -Force -ErrorAction Stop
        } catch {
            Write-Warning ("Could not stop previous MPV (PID {0})" -f $mpv_pid)
        }
    }
    Remove-Item $player_pid_file -Force -ErrorAction SilentlyContinue
}

# Launch MPV
try {
    $mpv_process = Start-Process -FilePath "mpv" -ArgumentList $selected_url -PassThru
    if (-not $mpv_process) {
        throw "Failed to start MPV process"
    }
    
    $mpv_process.Id | Out-File $player_pid_file -Force
    Write-Host "MPV started (PID: $($mpv_process.Id))"
    
    # Wait for playback to complete
    while (-not $mpv_process.HasExited) {
        Start-Sleep -Seconds 1
    }
}
catch {
    Write-Error "Playback failed: $_"
    exit 1
}
finally {
    if (Test-Path $player_pid_file) {
        Remove-Item $player_pid_file -Force -ErrorAction SilentlyContinue
    }
}
