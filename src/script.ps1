param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "📥 Downloading AL Language v11..."

$alDownloadUrl = "https://ms-dynamics-smb.gallerycdn.vsassets.io/extensions/ms-dynamics-smb/al/11.0.950504/1701354321747/Microsoft.Dynamics.Nav.Language.vsix"
$vsixPath = "$env:RUNNER_TEMP\al_language.vsix"
$extractPath = "$env:RUNNER_TEMP\al"

Invoke-WebRequest -Uri $alDownloadUrl -OutFile $vsixPath -UseBasicParsing
Expand-Archive -Path $vsixPath -DestinationPath $extractPath -Force

$alPath = Join-Path -Path $extractPath -ChildPath "extension\bin"
$alcPath = Join-Path -Path $alPath -ChildPath "alc.exe"

if (-not (Test-Path -Path $alcPath)) {
    Write-Host "❌ alc.exe not found!"
    exit 1
}

Write-Host "✅ AL Language extracted to: $alPath"
Write-Host "🚀 Running AL Code Analysis..."

& $alcPath `
    /project:$ProjectPath `
    /packagecachepath:$PackageCachePath `
    /out:$OutputPath\output.app `
    /analyzers:"$alPath\Analyzers" `
    /rulesetpath:$RulesetPath

Write-Host "✅ AL Code Analysis Completed."
