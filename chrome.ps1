<#
.SYNOPSIS
    Install (or update) Google Chrome on Windows and Windows Server from PowerShell.

.DESCRIPTION
    Downloads Google's 64-bit enterprise MSI over HTTPS, refuses it unless its
    Authenticode signature is valid and issued to Google LLC, installs it
    machine-wide and silently, then reads the installed version back.

    Safe to re-run. When the installed Chrome is already the same or newer, the
    install is a no-op and the script says so.

.PARAMETER AdblockPlus
    Also set Chrome's ExtensionSettings policy so Adblock Plus installs the first
    time Chrome opens a profile. Users can still disable it. Existing
    ExtensionSettings entries are kept.

.EXAMPLE
    # In an elevated PowerShell:
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    & ([scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1'))) -AdblockPlus

.NOTES
    Needs an elevated PowerShell (Run as Administrator), Windows PowerShell 5.1 or
    PowerShell 7, on 64-bit Windows 10/11 or Windows Server 2016 and later.
#>
[CmdletBinding()]
param(
    [switch]$AdblockPlus
)

$ErrorActionPreference = 'Stop'
# Invoke-WebRequest is many times slower on Windows PowerShell 5.1 with its progress bar on.
$ProgressPreference = 'SilentlyContinue'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this from an elevated PowerShell (Run as Administrator).'
}
if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'This installs 64-bit Chrome, and this Windows is 32-bit.'
}

# Older Windows PowerShell does not offer TLS 1.2 by default; Google requires it.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$url = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
$msi = Join-Path $env:TEMP 'googlechromestandaloneenterprise64.msi'
$log = Join-Path $env:TEMP 'chrome-install.log'

Write-Host "Downloading $url"
Invoke-WebRequest -Uri $url -OutFile $msi -UseBasicParsing

# The URL is unversioned, so there is no fixed hash to compare against. The
# signature is the check: valid, and issued to Google LLC.
$sig = Get-AuthenticodeSignature -FilePath $msi
if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'O=Google LLC') {
    Remove-Item $msi -Force -ErrorAction SilentlyContinue
    throw "Refusing the download: its signature is '$($sig.Status)', signed by '$($sig.SignerCertificate.Subject)'."
}
Write-Host "Signature OK: $($sig.SignerCertificate.Subject)"

$arguments = '/i "{0}" /qn /norestart /L*v "{1}"' -f $msi, $log
$process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
Remove-Item $msi -Force -ErrorAction SilentlyContinue

switch ($process.ExitCode) {
    0       { Write-Host 'Chrome installed.' }
    3010    { Write-Host 'Chrome installed; Windows wants a restart to finish.' }
    1641    { Write-Host 'Chrome installed; Windows started a restart.' }
    1638    { Write-Host 'This or a newer Chrome is already installed; nothing to do.' }
    default {
        # When the installed Chrome has already auto-updated past the MSI,
        # msiexec fails and the log says so. That is not a failure.
        if ((Test-Path $log) -and (Select-String -Path $log -Pattern 'More recent version|newer version' -Quiet)) {
            Write-Host 'A newer Chrome is already installed; nothing to do.'
        } else {
            throw "msiexec exited $($process.ExitCode); the log is $log"
        }
    }
}

$chrome = @(
    (Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe')
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) {
    throw "msiexec reported success, but chrome.exe is not in Program Files; the log is $log"
}
Write-Host "Chrome $((Get-Item $chrome).VersionInfo.ProductVersion) at $chrome"

if ($AdblockPlus) {
    $key = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
    if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    $settings = @{}
    $current = (Get-ItemProperty -Path $key -Name ExtensionSettings -ErrorAction SilentlyContinue).ExtensionSettings
    if ($current) {
        ($current | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $settings[$_.Name] = $_.Value }
    }
    # Adblock Plus on the Chrome Web Store, by eyeo GmbH.
    $settings['cfhdojbkjhnklbpkdaibdccddilifddb'] = @{
        installation_mode = 'normal_installed'
        update_url        = 'https://clients2.google.com/service/update2/crx'
    }
    Set-ItemProperty -Path $key -Name ExtensionSettings -Value ($settings | ConvertTo-Json -Compress -Depth 5) -Type String
    Write-Host 'Adblock Plus policy set: it installs the first time Chrome opens a profile.'
}
