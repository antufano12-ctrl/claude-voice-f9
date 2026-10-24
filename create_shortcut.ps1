# Creates a "Claude Voice" desktop shortcut that runs open_voice.ps1 with the F9 hotkey
$script  = Join-Path $PSScriptRoot 'open_voice.ps1'
$desktop = [Environment]::GetFolderPath('Desktop')
$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut((Join-Path $desktop 'Claude Voice.lnk'))
$lnk.TargetPath  = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$lnk.Arguments   = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
$lnk.Hotkey      = 'F9'
$lnk.WindowStyle = 7   # start minimized
$lnk.Save()
Write-Host "'Claude Voice' shortcut created on the Desktop: press F9 to launch it."
