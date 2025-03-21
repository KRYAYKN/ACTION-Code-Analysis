param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler (alc.exe)..."

$alcExePath = Join-Path $env:ALPATH "alc.exe"
if (-not (Test-Path $alcExePath)) {
    Write-Host "❌ alc.exe not found!"
    Write-Host "ALPATH: $env:ALPATH"
    exit 1
}

Write-Host "✅ alc.exe found at: $alcExePath"

if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
    $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
    Write-Host "ℹ️  No ruleset provided. Using default: $RulesetPath"
}

Write-Host "🚀 Running AL Code Analysis..."
& $alcExePath `
    /project:"$ProjectPath" `
    /packagecachepath:"$PackageCachePath" `
    /out:"$OutputPath" `
    /analyzers:CodeCop,UICop,PerTenantExtensionCop `
    /rulesetpath:"$RulesetPath"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ AL Code Analysis failed!"
    exit $LASTEXITCODE
}

Write-Host "✅ AL Code Analysis Completed Successfully!"
