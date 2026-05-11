param(
    [string]$WorkRoot = (Get-Location).Path,
    [switch]$Build
)

$ErrorActionPreference = 'Stop'

$shareRepoUrl = 'https://github.com/Encapsulation/baballonia-vrcft-lowlatency.git'
$baballoniaRepoUrl = 'https://github.com/Project-Babble/Baballonia.git'
$vrcftRepoUrl = 'https://github.com/Project-Babble/VRCFaceTracking.git'

$baballoniaCommit = '234a393f2f7ca29ccb8aeee0069e2cae155af628'
$vrcftCommit = '09539ec4d458ac6a37c5a620fd025c9042bf7933'

function Run-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed"
    }
}

function Ensure-Repo {
    param(
        [string]$Url,
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        if (-not (Test-Path -LiteralPath (Join-Path $Path '.git'))) {
            throw "Path exists but is not a git repo: $Path"
        }
        return
    }

    Run-Git clone $Url $Path
}

function Resolve-ShareRoot {
    try {
        $root = (& git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
        $rootText = (($root -join "`n").Trim())
        if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath (Join-Path $rootText 'patches\02b-baballonia-vrcft-submodule-core.patch'))) {
            return $rootText
        }
    }
    catch {
    }

    $path = Join-Path $WorkRoot 'BaballoniaVRCFT-CoreShare'
    Ensure-Repo -Url $shareRepoUrl -Path $path
    Run-Git @('-C', $path, 'fetch', 'origin', 'main')
    Run-Git @('-C', $path, 'checkout', 'main')
    Run-Git @('-C', $path, 'pull', '--ff-only', 'origin', 'main')
    return $path
}

$WorkRoot = [System.IO.Path]::GetFullPath($WorkRoot)
New-Item -ItemType Directory -Force -Path $WorkRoot | Out-Null

$shareRoot = Resolve-ShareRoot
$baballoniaRoot = Join-Path $WorkRoot 'Baballonia'
$vrcftRoot = Join-Path $WorkRoot 'VRCFaceTracking'

Ensure-Repo -Url $baballoniaRepoUrl -Path $baballoniaRoot
Ensure-Repo -Url $vrcftRepoUrl -Path $vrcftRoot

Push-Location $baballoniaRoot
try {
    Run-Git fetch --all --tags
    Run-Git checkout $baballoniaCommit
    & (Join-Path $shareRoot 'scripts\apply-baballonia-exact.ps1') -ShareRoot $shareRoot

    if ($Build) {
        powershell -NoProfile -ExecutionPolicy Bypass -File .\download_dependencies.ps1
        dotnet publish .\src\Baballonia.Desktop\Baballonia.Desktop.csproj -r win-x64 -c Release --self-contained -f net10.0
        if ($LASTEXITCODE -ne 0) { throw 'Baballonia publish failed' }
        dotnet build .\src\VRCFaceTracking.Baballonia\VRCFaceTracking.Baballonia.csproj -c Release
        if ($LASTEXITCODE -ne 0) { throw 'VRCFaceTracking.Baballonia build failed' }
    }
}
finally {
    Pop-Location
}

Push-Location $vrcftRoot
try {
    Run-Git fetch --all --tags
    Run-Git checkout $vrcftCommit
    & (Join-Path $shareRoot 'scripts\apply-vrcft-host-exact.ps1') -ShareRoot $shareRoot

    if ($Build) {
        dotnet build .\VRCFaceTracking.sln -c Release
        if ($LASTEXITCODE -ne 0) { throw 'VRCFaceTracking build failed' }
    }
}
finally {
    Pop-Location
}

Write-Host "Ready: $baballoniaRoot"
Write-Host "Ready: $vrcftRoot"
