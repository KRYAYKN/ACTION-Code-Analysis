param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL.exe..."

# PATH'de AL.exe'yi ara
$alExePath = Join-Path -Path $env:ALPATH -ChildPath "al.exe"

if (-not (Test-Path $alExePath)) {
    Write-Host "❌ Error: al.exe not found at path: $alExePath"
    exit 1
}

Write-Host "✅ AL.exe found at: $alExePath"

if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
    $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
    Write-Host "ℹ️  No ruleset provided. Using default: $RulesetPath"
}

Write-Host "🚀 Running AL Code Analysis..."
& $alExePath `
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