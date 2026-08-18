Set-Location $PSScriptRoot\..
Write-Host "Running DT-Teeth performance tests (all real, no synthetic/tautological tests)..."
flutter test test/performance/ --reporter expanded

Write-Host ""
Write-Host "For real device profiling, use:"
Write-Host "    flutter run --profile -d <device-id>"
Write-Host "Then open Flutter DevTools and capture CPU / Memory / Frame data."
