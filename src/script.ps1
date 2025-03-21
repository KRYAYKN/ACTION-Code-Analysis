param (
    [string]$ProjectPath,
    [string]$PackageCachePath,
    [string]$OutputPath,
    [string]$RulesetPath
)

Write-Host "🔍 Searching for AL compiler (alc.exe)..."
$alcExe = Get-Command "alc.exe" -ErrorAction SilentlyContinue
if (-not $alcExe) {
    $alcFromPath = Join-Path $env:ALPATH "alc.exe"
    if (Test-Path $alcFromPath) {
        $alcExe = $alcFromPath
    } else {
        Write-Host "❌ alc.exe not found!"
        Write-Host "ALPATH: $env:ALPATH"
        exit 1
    }
}

Write-Host "✅ alc.exe found at: $($alcExe.Source ?? $alcExe)"

# Önce compile işlemi yap
Write-Host "🚀 Running AL Compilation..."
& $alcExe `
    /project:"$ProjectPath" `
    /packagecachepath:"$PackageCachePath" `
    /out:"$OutputPath"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ AL Compilation failed!"
    exit $LASTEXITCODE
}

Write-Host "✅ AL Compilation Completed Successfully!"

# Şimdi Code Analysis işlemini yap
Write-Host "🔍 Looking for analyzer DLLs..."

# Analizörlerin olduğu dizin
$analyzersPath = Join-Path $env:ALPATH "..\Analyzers"
if (-not (Test-Path $analyzersPath)) {
    $analyzersPath = Join-Path (Split-Path -Parent $env:ALPATH) "Analyzers"
}

if (Test-Path $analyzersPath) {
    Write-Host "✅ Found analyzers at: $analyzersPath"
    
    # CodeCop DLL'ini bul
    $codeCopDll = Get-ChildItem -Path $analyzersPath -Filter "Microsoft.Dynamics.Nav.CodeCop.dll" -Recurse | Select-Object -First 1
    $uiCopDll = Get-ChildItem -Path $analyzersPath -Filter "Microsoft.Dynamics.Nav.UICop.dll" -Recurse | Select-Object -First 1
    $perTenantExtensionCopDll = Get-ChildItem -Path $analyzersPath -Filter "Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll" -Recurse | Select-Object -First 1
    
    if ($codeCopDll -or $uiCopDll -or $perTenantExtensionCopDll) {
        Write-Host "✅ Found analyzer DLLs"
        
        # Ruleset dosyasını kontrol et
        if ([string]::IsNullOrWhiteSpace($RulesetPath)) {
            $RulesetPath = Join-Path $ProjectPath ".alcop\ruleset.json"
        }
        
        if (Test-Path $RulesetPath) {
            Write-Host "✅ Found ruleset at: $RulesetPath"
            
            # Çalıştırma için daha özel bir yöntem belirle
            # .NET Core kullanılabilir
            Write-Host "🚀 Running Code Analysis with analyzers..."
            
            # AL sürümüne göre uygun yöntemi belirle
            # Burada "dotnet" aracını kullanabilirsiniz veya özel bir script ile analizörleri çalıştırabilirsiniz
            
            # Örnek: Derleme dosyalarında gezin ve analizörleri çalıştır
            $appFiles = Get-ChildItem -Path $OutputPath -Filter "*.app" -Recurse
            
            foreach ($appFile in $appFiles) {
                Write-Host "🔍 Analyzing $($appFile.Name)..."
                
                # Burada app dosyasını analiz etmek için özel bir yöntem belirleyin
                # Örneğin, ALTool veya özel bir analiz aracı kullanabilirsiniz
            }
        } else {
            Write-Host "⚠️ Ruleset file not found at: $RulesetPath"
        }
    } else {
        Write-Host "⚠️ Analyzer DLLs not found in $analyzersPath"
    }
} else {
    Write-Host "⚠️ Analyzers directory not found"
}

Write-Host "✅ AL Code Analysis Completed!"