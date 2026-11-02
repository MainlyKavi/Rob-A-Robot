# Copies a saved .rbxl into backups\ with a timestamp. Usage:
#   .\tools\backup-place.ps1 "C:\path\to\RobARobot.rbxl"
param([Parameter(Mandatory)][string]$PlaceFile)

if (-not (Test-Path $PlaceFile)) { throw "Place file not found: $PlaceFile" }
$dest = Join-Path $PSScriptRoot "..\backups"
New-Item -ItemType Directory -Force $dest | Out-Null
$name = "{0}-{1:yyyyMMdd-HHmmss}{2}" -f [IO.Path]::GetFileNameWithoutExtension($PlaceFile), (Get-Date), [IO.Path]::GetExtension($PlaceFile)
Copy-Item $PlaceFile (Join-Path $dest $name)
"Backed up to backups\$name"
