# install-chrome-win

Install or update Google Chrome on Windows and Windows Server from PowerShell, with
no browser needed. It is handy on a fresh server where the only browser is Edge or
Internet Explorer.

## Use it

Open PowerShell **as Administrator** and run:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
& ([scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1')))
```

Add `-AdblockPlus` at the end to also have Adblock Plus installed the first time
Chrome opens a profile:

```powershell
& ([scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1'))) -AdblockPlus
```

Or download it and run it as a file:

```powershell
Invoke-WebRequest 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1' -OutFile chrome.ps1 -UseBasicParsing
powershell -ExecutionPolicy Bypass -File .\chrome.ps1 -AdblockPlus
```

## What it does

1. Downloads Google's 64-bit **enterprise MSI** over **HTTPS**
   (`dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi`).
2. **Refuses it** unless its Authenticode signature is valid and issued to Google LLC.
3. Installs it machine-wide and silently (`msiexec /qn /norestart`, with a log in `%TEMP%\chrome-install.log`).
4. Reads the installed `chrome.exe` version back, and fails if Chrome is not actually there.
5. With `-AdblockPlus`, adds Adblock Plus to Chrome's `ExtensionSettings` policy, keeping any existing entries.

It is safe to re-run. If the same or a newer Chrome is already installed, it says
so and changes nothing. Chrome keeps itself updated afterwards.

Requirements: 64-bit Windows 10/11 or Windows Server 2016 and later, Windows
PowerShell 5.1 or PowerShell 7, and an elevated prompt.

Please raise an issue if you find a bug. MIT licensed.

![POC](https://github.com/amitsdalal/install-chrome-win/raw/master/Screenshot%20from%202019-10-29%2019-17-21.png)

The screenshot is from the original 2019 version.
