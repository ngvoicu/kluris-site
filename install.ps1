# Kluris 3 installer for Windows:
#
#     powershell -ExecutionPolicy ByPass -c "irm https://kluris.ngvoicu.dev/install.ps1 | iex"
#
# A thin pass-through: it downloads the installer published with the release
# on GitHub (kluris-installer.ps1) and runs it. That installer puts
# kluris.exe in %USERPROFILE%\.kluris\bin and adds that folder to your user
# PATH (never the system PATH); open a new terminal afterwards.
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
# KLURIS_INSTALL_DIR, KLURIS_NO_MODIFY_PATH=1, KLURIS_GITHUB_TOKEN.

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
    $ErrorActionPreference = 'Continue'
    Invoke-Expression $installer
}
