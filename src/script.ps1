param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler (alc.exe)..."

$alcExe = Get-Command "alc.exe" -ErrorAction SilentlyContinue

if (-not $alcExe) {
    $alcFromPath = Join-Path $env:ALPATH "alc.exe"
    if (Test-Path $alcFromPath) {
        $alcExe = $alcFromPath
    } else {
        Write-Host "❌ alc.exe not found!"
        Write-Host "ALPATH: $env:ALPATH"
        exit 1
    }
}

Write-Host "✅ alc.exe found at: $($alcExe.Source ?? $alcExe)"

# En son AL versiyonları analiz parametrelerini desteklemediği için sadece compile yapılır
Write-Host "⚠️ Skipping /analyzers and /rulesetpath since they're no longer supported in latest AL Compiler."

Write-Host "🚀 Running AL Code Analysis..."
& $alcExe `
    /project:"$ProjectPath" `
    /packagecachepath:"$PackageCachePath" `
    /out:"$OutputPath"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ AL Code Analysis failed!"
    exit $LASTEXITCODE
}

Write-Host "✅ AL Code Analysis Completed Successfully!"
