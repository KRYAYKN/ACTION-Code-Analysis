param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL.exe..."

# ALPATH çevre değişkenini kontrol et ve alc.exe'yi ara
if (-not [string]::IsNullOrWhiteSpace($env:ALPATH)) {
    $alcExePath = Join-Path -Path $env:ALPATH -ChildPath "alc.exe"
    
    if (Test-Path $alcExePath) {
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
        exit 0
    }
}

# Standart yol ile AL.exe'yi aramayı dene
$AlPath = Get-Command alc.exe -ErrorAction SilentlyContinue

if ($null -eq $AlPath) {
    Write-Host "❌ Error: al.exe not found! Make sure AL Language extension is installed."
    Write-Host "ALPATH: $env:ALPATH"
    Write-Host "PATH: $env:PATH"
    
    # Win32 dizinindeki tüm exe dosyalarını listele
    if (-not [string]::IsNullOrWhiteSpace($env:ALPATH)) {
        Write-Host "📋 Files in ALPATH directory:"
        Get-ChildItem -Path $env:ALPATH -Filter "*.exe" | ForEach-Object { Write-Host "  - $($_.Name)" }
    }
    
    exit 1
}

Write-Host "✅ AL.exe found at: $($AlPath.Source)"

if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
    $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
    Write-Host "ℹ️  No ruleset provided. Using default: $RulesetPath"
}

Write-Host "🚀 Running AL Code Analysis..."
& $AlPath.Source `
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