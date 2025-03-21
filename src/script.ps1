param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler..."

$alcExePath = Join-Path -Path $env:ALPATH -ChildPath "alc.exe"

if (-not (Test-Path $alcExePath)) {
    Write-Host "❌ alc.exe not found at $alcExePath"
    exit 1
}

Write-Host "✅ alc.exe found at: $alcExePath"

if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
    $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
    Write-Host "ℹ️ No ruleset provided. Using default: $RulesetPath"
}

Write-Host "🚀 Running AL Code Analysis with analyzers..."
& $alcExePath `
    /project:"$ProjectPath" `
    /packagecachepath:"$PackageCachePath" `
    /out:"$OutputPath" `
    /analyzers:"$env:ALPATH\Analyzers\Microsoft.Dynamics.Nav.CodeCop.dll","$env:ALPATH\Analyzers\Microsoft.Dynamics.Nav.UICop.dll","$env:ALPATH\Analyzers\Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll" `
    /rulesetpath:"$RulesetPath"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ AL Code Analysis failed!"
    exit $LASTEXITCODE
}

Write-Host "✅ AL Code Analysis completed successfully!"
