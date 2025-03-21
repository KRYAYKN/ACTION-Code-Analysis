param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL.exe..."

# ALPATH çevre değişkenini kontrol et
if ([string]::IsNullOrWhiteSpace($env:ALPATH) -or -not (Test-Path "$env:ALPATH\al.exe")) {
    # PATH'de al.exe'yi ara
    $AlPath = Get-Command al.exe -ErrorAction SilentlyContinue
    
    if ($null -eq $AlPath) {
        Write-Host "❌ Error: al.exe not found! Make sure AL Language extension is installed."
        Write-Host "ALPATH: $env:ALPATH"
        Write-Host "PATH: $env:PATH"
        exit 1
    }
    
    $alExePath = $AlPath.Source
} else {
    $alExePath = Join-Path -Path $env:ALPATH -ChildPath "al.exe"
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