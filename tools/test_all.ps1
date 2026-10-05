param(
    [string]$GodotPath = 'godot',
    [ValidateRange(5, 300)][int]$TimeoutSeconds = 45
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$godotCommand = Get-Command $GodotPath -ErrorAction Stop
$testFiles = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'tests') -Filter '*_tests.gd' | Sort-Object Name)
if ($testFiles.Count -eq 0) { throw 'No se encontraron pruebas.' }
$runId = [Guid]::NewGuid().ToString('N')
$logRoot = Join-Path $projectRoot ".godot/test-runs/$runId"
New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
$failedSuites = @()
foreach ($testFile in $testFiles) {
    $outLog = Join-Path $logRoot "$($testFile.BaseName).out.log"
    $errLog = Join-Path $logRoot "$($testFile.BaseName).err.log"
    $engineLog = Join-Path $logRoot "$($testFile.BaseName).engine.log"
    $arguments = @('--headless', '--path', ('"{0}"' -f $projectRoot), '--script', "res://tests/$($testFile.Name)", '--log-file', ('"{0}"' -f $engineLog))
    $process = Start-Process -FilePath $godotCommand.Source -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $outLog -RedirectStandardError $errLog
    $finished = $process.WaitForExit($TimeoutSeconds * 1000)
    if (-not $finished) {
        # Only terminate the test process created immediately above, never the editor.
        $process.Kill()
        $process.WaitForExit()
    } else {
        $process.WaitForExit()
    }
    $output = (Get-Content -LiteralPath $outLog -Raw) + (Get-Content -LiteralPath $errLog -Raw)
    $passed = $finished -and $process.ExitCode -eq 0 -and $output -notmatch '(?m)^(SCRIPT ERROR:|FAIL:)'
    if ($passed) {
        Write-Output "OK  $($testFile.Name)"
    } else {
        $failedSuites += $testFile.Name
        Write-Output "FAIL $($testFile.Name) (terminado: $finished, salida: $($process.ExitCode))"
        Write-Output $output
    }
    $process.Dispose()
}
Write-Output "Total: $($testFiles.Count). Fallos: $($failedSuites.Count)."
Write-Output "Registros: $logRoot"
if ($failedSuites.Count -gt 0) { exit 1 }
exit 0
