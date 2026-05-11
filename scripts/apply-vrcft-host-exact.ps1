param(
    [string]$ShareRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_patch-helpers.ps1')

$expectedVrcftCommit = '09539ec4d458ac6a37c5a620fd025c9042bf7933'

$patch2 = Join-Path $ShareRoot 'patches\02-vrcft-host-core.patch'

$repoRoot = Assert-RepositoryRoot `
    -RepoName 'standalone VRCFaceTracking' `
    -RequiredPaths @('VRCFaceTracking.sln', 'VRCFaceTracking.Core\VRCFaceTracking.Core.csproj', 'VRCFaceTracking.ModuleProcess\VRCFaceTracking.ModuleProcess.csproj')

$maybeBaballoniaRoot = Split-Path (Split-Path $repoRoot -Parent) -Parent
if (Test-Path -LiteralPath (Join-Path $maybeBaballoniaRoot 'src\Baballonia.Desktop\Baballonia.Desktop.csproj')) {
    throw "This is Baballonia's src\VRCFaceTracking submodule. Do not apply patch 02 here; run scripts\apply-baballonia-exact.ps1 from the Baballonia root."
}

Assert-ExactHead -RepoName 'standalone VRCFaceTracking' -ExpectedCommit $expectedVrcftCommit
Apply-GitPatchOnce -PatchPath $patch2 -PatchName 'patch 02 (standalone VRCFaceTracking host)'

Write-Host 'Standalone VRCFaceTracking exact patch flow complete.'
