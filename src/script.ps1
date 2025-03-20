param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL.exe..."

# al.exe'nin sistemde olup olmadığını kontrol et
$AlPath = Get-Command al.exe -ErrorAction SilentlyContinue

if ($null -eq $AlPath) {
    Write-Host "❌ Error: al.exe not found! Make sure AL Language extension is installed."
    exit 1
}

Write-Host "✅ AL.exe found at: $($AlPath.Source)"
Write-Host "🚀 Running AL Code Analysis..."

# AL.exe'yi çalıştır ve analiz yap
& $AlPath.Source `
    /project:$ProjectPath `
    /packagecachepath:$PackageCachePath `
    /out:$OutputPath `
    /analyzers:CodeCop, UICop, PerTenantExtensionCop `
    /rulesetpath:$RulesetPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ AL Code Analysis failed!"
    exit $LASTEXITCODE
}

Write-Host "✅ AL Code Analysis Completed Successfully!"
