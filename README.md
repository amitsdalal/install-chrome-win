Welcome to the install-chrome-win wiki!

This Script is written for Installing the Chrome browser using PowerShell as the new Windows OS asks for a lot to download Chrome using Internet Explorer and Duh :P who likes IE at this day.

Goto PowerShell and put these three simple Lines one by one and wallah you'll have a brand new Chrome Browser installed.

Please raise the issue if you're seeing any bug.

This script is free to use/copy/modify and no copyright is applied the same.

$Script = Invoke-WebRequest 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1'

$ScriptBlock = [Scriptblock]::Create($Script.Content)

Invoke-Command -ScriptBlock $ScriptBlock


![POC](https://github.com/amitsdalal/install-chrome-win/raw/master/Screenshot%20from%202019-10-29%2019-17-21.png)

