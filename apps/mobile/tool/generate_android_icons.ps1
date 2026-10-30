[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$appDirectory = Split-Path -Parent $PSScriptRoot
$repoDirectory = Split-Path -Parent (Split-Path -Parent $appDirectory)
$vectorSourcePath = Join-Path $repoDirectory 'logo/Logo EntreHuellas 512 vector inner v2-16.svg'
$resourcesDirectory = Join-Path $appDirectory 'android/app/src/main/res'
$utf8Encoding = New-Object System.Text.UTF8Encoding($false)

[xml]$vectorSource = Get-Content -LiteralPath $vectorSourcePath -Raw
$namespaces = New-Object System.Xml.XmlNamespaceManager($vectorSource.NameTable)
$namespaces.AddNamespace('svg', 'http://www.w3.org/2000/svg')
$sourcePaths = $vectorSource.SelectNodes('/svg:svg/svg:g/svg:g/svg:path', $namespaces)
$sourceGradient = $vectorSource.SelectSingleNode('/svg:svg/svg:defs/svg:linearGradient', $namespaces)
if ($vectorSource.svg.viewBox -ne '0 0 512 512' -or $sourcePaths.Count -ne 5 -or !$sourceGradient) {
    throw 'El SVG no coincide con la estructura prevista. Revisar el adaptador antes de regenerar.'
}

# Keep every shipped copy in sync with the official exports, including Nuxt.
$rasterSourcePath = Join-Path $repoDirectory 'logo/Logo EntreHuellas 512 vector inner v2@2x.png'
foreach ($relativePath in @(
    'apps/mobile/assets/branding/app_icon.png',
    'apps/mobile/android/app/src/main/res/drawable-nodpi/startup_brand.png',
    'apps/platform/public/brand.png'
)) {
    Copy-Item -LiteralPath $rasterSourcePath -Destination (Join-Path $repoDirectory $relativePath) -Force
}
Copy-Item -LiteralPath $vectorSourcePath -Destination (Join-Path $repoDirectory 'apps/platform/public/brand.svg') -Force
Copy-Item -LiteralPath (Join-Path $repoDirectory 'logo/only-black.svg') -Destination (Join-Path $repoDirectory 'apps/mobile/assets/branding/only-black.svg') -Force
Copy-Item -LiteralPath (Join-Path $repoDirectory 'logo/Logo EntreHuellas 512 vector inner v2-256.png') -Destination (Join-Path $repoDirectory 'apps/platform/public/brand-icon.png') -Force

Push-Location -LiteralPath $appDirectory
try {
    & dart run flutter_launcher_icons
    if ($LASTEXITCODE -ne 0) { throw 'Falló la generación de iconos PNG.' }
} finally {
    Pop-Location
}

# flutter_launcher_icons 0.14.4 can mistake the Swift asset flag for an icon name.
# Preserve that unrelated Xcode boolean after regenerating icon catalogs.
$iosProjectPath = Join-Path $appDirectory 'ios/Runner.xcodeproj/project.pbxproj'
$iosProject = [System.IO.File]::ReadAllText($iosProjectPath)
$fixedIosProject = $iosProject.Replace('ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;', 'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;')
if ($fixedIosProject -ne $iosProject) { [System.IO.File]::WriteAllText($iosProjectPath, $fixedIosProject, $utf8Encoding) }

function Write-IconResource {
    param([string]$RelativePath, [string]$XmlContent)
    $outputPath = Join-Path $resourcesDirectory $RelativePath
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force
    [void]([xml]$XmlContent)
    [System.IO.File]::WriteAllText($outputPath, $XmlContent + "`n", $utf8Encoding)
}

function Get-SymbolVector {
    param([switch]$Monochrome)
    $paths = foreach ($sourcePath in $sourcePaths) {
        $pathData = [System.Security.SecurityElement]::Escape($sourcePath.GetAttribute('d'))
        $fillColor = if ($Monochrome) { '#000000' } else { $sourcePath.GetAttribute('fill') }
        "        <path android:fillColor=`"$fillColor`" android:pathData=`"$pathData`" />"
    }
    # Scale the original symbol into the adaptive icon's central safe region.
    # SVG texture/inner-shadow filters are not supported by VectorDrawable.
    @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="512" android:viewportHeight="512">
    <group android:pivotX="256" android:pivotY="256"
        android:scaleX="0.72" android:scaleY="0.72">
$($paths -join "`n")
    </group>
</vector>
"@
}

$gradientStops = foreach ($stop in $sourceGradient.SelectNodes('svg:stop', $namespaces)) {
    $offset = if ($stop.HasAttribute('offset')) { $stop.GetAttribute('offset') } else { '0' }
    "                <item android:offset=`"$offset`" android:color=`"$($stop.GetAttribute('stop-color'))`" />"
}
$backgroundXml = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:aapt="http://schemas.android.com/aapt"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="512" android:viewportHeight="512">
    <path android:pathData="M0,0H512V512H0Z">
        <aapt:attr name="android:fillColor">
            <gradient android:type="linear"
                android:startX="$($sourceGradient.GetAttribute('x1'))" android:startY="$($sourceGradient.GetAttribute('y1'))"
                android:endX="$($sourceGradient.GetAttribute('x2'))" android:endY="$($sourceGradient.GetAttribute('y2'))">
$($gradientStops -join "`n")
            </gradient>
        </aapt:attr>
    </path>
</vector>
"@

Write-IconResource 'drawable/ic_launcher_foreground.xml' (Get-SymbolVector)
Write-IconResource 'drawable/ic_launcher_monochrome.xml' (Get-SymbolVector -Monochrome)
Write-IconResource 'drawable/ic_launcher_background.xml' $backgroundXml
Write-IconResource 'mipmap-anydpi-v26/ic_launcher.xml' @'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
'@
Write-IconResource 'mipmap-anydpi-v33/ic_launcher.xml' @'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
'@

Write-Output 'Marca Flutter/web, splash e iconos Android clásicos/adaptativos/monocromáticos y catálogos iOS/web/Windows/macOS generados.'
