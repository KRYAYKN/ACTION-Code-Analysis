param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler (alc.exe)..."

$alcPath = Join-Path -Path $env:ALPATH -ChildPath "alc.exe"
if (-not (Test-Path $alcPath)) {
    Write-Host "❌ alc.exe not found!"
    Write-Host "ALPATH: $env:ALPATH"
    exit 1
}

Write-Host "✅ alc.exe found at: $alcPath"

# Continue running the analysis
& $alcPath `
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
