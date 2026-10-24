# Opens the Claude desktop app on a new chat and starts voice mode (fast version)
param([switch]$Log)
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
$A  = [System.Windows.Automation.AutomationElement]
$TS = [System.Windows.Automation.TreeScope]
$logf = Join-Path ([Environment]::GetFolderPath('Desktop')) "claude_voice_log.txt"
function L($m) { if ($Log) { Add-Content -Encoding utf8 $logf $m } }
if ($Log) { Set-Content -Encoding utf8 $logf "start" }

function GetWin { Get-Process claude -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1 }

# If Claude is already open, don't wait for it to start
$p = GetWin
Start-Process explorer.exe 'shell:AppsFolder\Claude_pzs8sxrjxfjjc!Claude'
for ($i=0; $i -lt 60 -and -not $p; $i++) { Start-Sleep -Milliseconds 150; $p = GetWin }
if (-not $p) { L "window not found"; exit }
$win = $A::FromHandle($p.MainWindowHandle)
L "window ok"

# A single scan with cached properties (much faster than reading each button)
$cond = New-Object System.Windows.Automation.PropertyCondition($A::ControlTypeProperty, [System.Windows.Automation.ControlType]::Button)
$cache = New-Object System.Windows.Automation.CacheRequest
$cache.Add($A::NameProperty); $cache.Add($A::IsOffscreenProperty); $cache.Add($A::BoundingRectangleProperty)
$cache.Add([System.Windows.Automation.InvokePattern]::Pattern)
function Buttons { $c = $cache.Activate(); try { $win.FindAll($TS::Descendants, $cond) } finally { $c.Dispose() } }
function Find($rx, $tries=20) {
  for ($t=0; $t -lt $tries; $t++) {
    foreach ($b in Buttons) { if (-not $b.Cached.IsOffscreen -and $b.Cached.Name -match $rx) { return $b } }
    Start-Sleep -Milliseconds 150
  }
  return $null
}
function Dump($pre) { if ($Log) { foreach ($b in Buttons) { if (-not $b.Cached.IsOffscreen) { L ("$pre " + $b.Cached.Name) } } } }

function Press($b) {
  try { $b.GetCachedPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke(); L "invoked: $($b.Cached.Name)" }
  catch {
    # Mouse-click fallback: compiled only when needed
    if (-not ('M' -as [type])) { Add-Type @"
using System; using System.Runtime.InteropServices;
public class M { [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
[DllImport("user32.dll")] public static extern void mouse_event(int f,int x,int y,int d,int e);
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h); }
"@ }
    $r = $b.Cached.BoundingRectangle
    [M]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
    [M]::SetCursorPos([int]($r.X + $r.Width/2), [int]($r.Y + $r.Height/2)) | Out-Null
    Start-Sleep -Milliseconds 50
    [M]::mouse_event(2,0,0,0,0); [M]::mouse_event(4,0,0,0,0)
    L "clicked: $($b.Cached.Name)"
  }
}

# new chat (button names in Italian and English)
$rxNew = '^(Nuovo|Nuova chat|New chat|New)$'
$n = Find $rxNew 15
if (-not $n) { $s = Find '^Mostra barra laterale' 3; if ($s) { Press $s; $n = Find $rxNew 15 } }
if ($n) { Press $n; Start-Sleep -Milliseconds 400 } else { L "new chat not found. Buttons:"; Dump " *" }

# voice mode: no fixed delay, press the button as soon as it appears
$v = Find '(modalit. vocale|voice mode|Avvia.*voc|conversazione vocale)' 40
if ($v) { Press $v } else { L "voice mode not found. Visible buttons:"; Dump " -" }
