param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler (alc.exe)..."

function Run-Analysis {
    param (
        [string]$AlcPath
    )

    # Sürüm kontrolü
    $versionOutput = & $AlcPath --version
    Write-Host "🧪 AL Compiler Version: $versionOutput"

    if ($versionOutput -match "^0\.|^1\.|^2\.|^3\.|^4\.") {
        Write-Host "❌ AL Compiler version is too old and does not support analyzers or ruleset. Exiting."
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
        $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
        Write-Host "ℹ️  No ruleset provided. Using default: $RulesetPath"
    }

    Write-Host "🚀 Running AL Code Analysis..."
    & $AlcPath `
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

# Önce ALPATH ortam değişkeninden dene
if (-not [string]::IsNullOrWhiteSpace($env:ALPATH)) {
    $alcExePath = Join-Path -Path $env:ALPATH -ChildPath "alc.exe"
    if (Test-Path $alcExePath) {
        Write-Host "✅ alc.exe found at: $alcExePath (from ALPATH)"
        Run-Analysis -AlcPath $alcExePath
    }
}

# Standart PATH içinde ara
$alcCommand = Get-Command alc.exe -ErrorAction SilentlyContinue
if ($null -ne $alcCommand) {
    Write-Host "✅ alc.exe found at: $($alcCommand.Source) (from PATH)"
    Run-Analysis -AlcPath $alcCommand.Source
}

# Bulunamazsa hata ver
Write-Host "❌ alc.exe not found in ALPATH or system PATH!"
Write-Host "ALPATH: $env:ALPATH"
Write-Host "PATH: $env:PATH"

if (-not [string]::IsNullOrWhiteSpace($env:ALPATH)) {
    Write-Host "📋 Files in ALPATH directory:"
    Get-ChildItem -Path $env:ALPATH -Filter "*.exe" | ForEach-Object { Write-Host "  - $($_.Name)" }
}

exit 1
