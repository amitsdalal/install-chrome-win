Just run below lines in the powershell and it will get you chrome. 


$Script = Invoke-WebRequest 'https://raw.githubusercontent.com/amitsdalal/install-chrome-win/master/chrome.ps1'
$ScriptBlock = [Scriptblock]::Create($Script.Content)

Invoke-Command -ScriptBlock $ScriptBlock
