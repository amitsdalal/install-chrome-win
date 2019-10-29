This Script is written for Installing the Chrome browser using PowerShell as the new Windows OS ask for a lot to download the Chrome using Internet Explorer and Duh :P who likes IE at this day.

Goto PowerShell and put this three simple Line one by one and wallah you'll have a brand new Chrome Broswer installed.

Please raise issue if you're seening any bug.

This script is free to use/copy/modify and no copyright is applied the same.




$Script = Invoke-WebRequest 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1'

$ScriptBlock = [Scriptblock]::Create($Script.Content)

Invoke-Command -ScriptBlock $ScriptBlock



