param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler (alc.exe)..."

# ALPATH ile belirlenen al.exe'yi kontrol et
if (-not [string]::IsNullOrWhiteSpace($env:ALPATH)) {
    $alcExePath = Join-Path -Path $env:ALPATH -ChildPath "alc.exe"
    if (Test-Path $alcExePath) {
        Write-Host "✅ alc.exe found at: $alcExePath"
    } else {
        Write-Host "❌ alc.exe not found in ALPATH!"
        exit 1
    }
} else {
    Write-Host "❌ ALPATH environment variable not set."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
    $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
    Write-Host "ℹ️ No ruleset provided. Using default: $RulesetPath"
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
