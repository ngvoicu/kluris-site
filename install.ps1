# Kluris 3 installer for Windows:
#
#     powershell -ExecutionPolicy ByPass -c "irm https://kluris.ngvoicu.dev/install.ps1 | iex"
#
# A thin pass-through: it downloads the installer published with the release
# on GitHub (kluris-installer.ps1) and runs it. That installer puts
# kluris.exe in %USERPROFILE%\.kluris\bin and adds that folder to your user
# PATH (never the system PATH); open a new terminal afterwards.
#
# The release installer checks no checksum, so this checks the archive first:
# it downloads this machine's kluris-<target>.zip of the installer's own
# release and the kluris-<target>.zip.sha256 published beside it, compares
# their SHA-256, and only then runs the installer, pointed at the checked
# archive in a temporary folder through the installer's KLURIS_DOWNLOAD_URL
# (given back as it was afterwards). A mismatch, or a .sha256 it cannot
# download, stops it before anything is installed.
#
# The release installer refuses to run under the Restricted and AllSigned
# execution policies, so this sets Bypass for this PowerShell process only
# (it ends with the window) before calling it: a bare `irm ... | iex` in an
# open PowerShell works too. A policy set by Group Policy wins over it.
#
# $env:KLURIS_VERSION = '3.0.0'   install that release instead of the latest
#                                 ('v3.0.0' works too)
# $env:KLURIS_RELEASES_URL        where the releases are, by default
#                                 https://github.com/ngvoicu/kluris/releases
#
# The release installer's own settings pass through as they are: for example
# KLURIS_INSTALL_DIR, KLURIS_NO_MODIFY_PATH=1, KLURIS_GITHUB_TOKEN. Its
# download settings (KLURIS_DOWNLOAD_URL, INSTALLER_DOWNLOAD_URL,
# KLURIS_INSTALLER_GHE_BASE_URL, KLURIS_INSTALLER_GITHUB_BASE_URL, in that
# order) say where this fetches the archive and its .sha256 from.

# Errors are thrown, never `exit`: under `irm | iex` an exit would close the
# PowerShell window it runs in.
& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'

    $releases = if ($env:KLURIS_RELEASES_URL) { $env:KLURIS_RELEASES_URL.TrimEnd('/') } else { 'https://github.com/ngvoicu/kluris/releases' }
    if ($env:KLURIS_VERSION) {
        $version = $env:KLURIS_VERSION -replace '^v', ''
        if ($version -notmatch '^[0-9][0-9A-Za-z.+-]*$') {
            throw "kluris: KLURIS_VERSION must be a release number such as 3.0.0, not '$($env:KLURIS_VERSION)'"
        }
        $url = "$releases/download/v$version/kluris-installer.ps1"
    } else {
        $url = "$releases/latest/download/kluris-installer.ps1"
    }

    try {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    } catch {
        Write-Warning "kluris: could not set the execution policy for this process ($($_.Exception.Message))"
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url
    } catch {
        throw "kluris: could not download ${url}: $($_.Exception.Message)"
    }
    $installer = [Text.Encoding]::UTF8.GetString($response.RawContentStream.ToArray()).TrimStart([char]0xFEFF)

    # The release the installer installs (latest/download/ names none), and
    # where it would fetch that release's archive from.
    if ($installer -notmatch "(?m)^\`$app_version = '([0-9][0-9A-Za-z.+-]*)'\r?$") {
        throw "kluris: $url names no release version, so its archive could not be checked; nothing was installed"
    }
    $release = $Matches[1]
    $base = if ($env:KLURIS_DOWNLOAD_URL) { $env:KLURIS_DOWNLOAD_URL }
        elseif ($env:INSTALLER_DOWNLOAD_URL) { $env:INSTALLER_DOWNLOAD_URL }
        elseif ($env:KLURIS_INSTALLER_GHE_BASE_URL) { "$($env:KLURIS_INSTALLER_GHE_BASE_URL)/ngvoicu/kluris/releases/download/v$release" }
        elseif ($env:KLURIS_INSTALLER_GITHUB_BASE_URL) { "$($env:KLURIS_INSTALLER_GITHUB_BASE_URL)/ngvoicu/kluris/releases/download/v$release" }
        else { "$releases/download/v$release" }
    $base = $base.TrimEnd('/')

    # This machine's archive, chosen the way the release installer chooses it.
    $arch = $null
    try {
        $info = [System.Reflection.Assembly]::LoadWithPartialName('System.Runtime.InteropServices.RuntimeInformation')
        $arch = $info.GetType('System.Runtime.InteropServices.RuntimeInformation').GetProperty('OSArchitecture').GetValue($null).ToString()
    } catch {
        $arch = $null
    }
    if (-not $arch) { $arch = if ([Environment]::Is64BitOperatingSystem) { 'X64' } else { 'X86' } }
    $archive = switch ($arch) {
        'X64' { 'kluris-x86_64-pc-windows-msvc.zip' }
        'Arm64' { 'kluris-aarch64-pc-windows-msvc.zip' }
        default { throw "kluris: there is no Kluris build for this Windows ($arch); nothing was installed" }
    }

    $headers = @{}
    if ($env:KLURIS_GITHUB_TOKEN) { $headers['Authorization'] = "Bearer $($env:KLURIS_GITHUB_TOKEN)" }
    $checked = Join-Path ([IO.Path]::GetTempPath()) ('kluris-' + [guid]::NewGuid().ToString('N'))
    $previous = $env:KLURIS_DOWNLOAD_URL
    try {
        $null = New-Item -ItemType Directory -Path $checked
        $sumUrl = "$base/$archive.sha256"
        try {
            $sum = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $sumUrl
        } catch {
            throw "kluris: could not download $sumUrl, the archive's published SHA-256, so nothing was installed: $($_.Exception.Message)"
        }
        $line = [Text.Encoding]::UTF8.GetString($sum.RawContentStream.ToArray()).TrimStart([char]0xFEFF).Trim()
        if ($line -notmatch '^([0-9A-Fa-f]{64}) [ *]?(\S+)$' -or $Matches[2] -ne $archive) {
            throw "kluris: $sumUrl is not the SHA-256 of $archive, so nothing was installed"
        }
        $expected = $Matches[1].ToLowerInvariant()
        $zip = Join-Path $checked $archive
        try {
            Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri "$base/$archive" -OutFile $zip
        } catch {
            throw "kluris: could not download $base/${archive}: $($_.Exception.Message)"
        }
        $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash.ToLowerInvariant()
        if ($actual -ne $expected) {
            throw "kluris: $archive does not match its published SHA-256, so nothing was installed (expected $expected from $sumUrl, the download has $actual)"
        }
        Write-Output "kluris: $archive matches its published SHA-256 ($actual)"

        # The release installer fetches "$KLURIS_DOWNLOAD_URL/$archive": here,
        # the file just checked.
        $env:KLURIS_DOWNLOAD_URL = ([Uri]$checked).AbsoluteUri.TrimEnd('/')
        $ErrorActionPreference = 'Continue'
        Invoke-Expression $installer
    } finally {
        $env:KLURIS_DOWNLOAD_URL = $previous
        Remove-Item -LiteralPath $checked -Recurse -Force -ErrorAction SilentlyContinue
    }
}
