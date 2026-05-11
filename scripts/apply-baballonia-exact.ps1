param(
    [string]$ShareRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_patch-helpers.ps1')

$expectedBaballoniaCommit = '234a393f2f7ca29ccb8aeee0069e2cae155af628'
$expectedSubmoduleCommit = 'b4b39da5c9fe048c960aa3b9e56742834df6ff36'

$patch1 = Join-Path $ShareRoot 'patches\01-baballonia-app-core.patch'
$patch2b = Join-Path $ShareRoot 'patches\02b-baballonia-vrcft-submodule-core.patch'
$patch3 = Join-Path $ShareRoot 'patches\03-vrcft-babble-module-core.patch'

$repoRoot = Assert-RepositoryRoot `
    -RepoName 'Baballonia' `
    -RequiredPaths @('src\Baballonia.Desktop\Baballonia.Desktop.csproj', 'src\VRCFaceTracking.Baballonia\VRCFaceTracking.Baballonia.csproj', '.gitmodules')
Assert-ExactHead -RepoName 'Baballonia' -ExpectedCommit $expectedBaballoniaCommit

Invoke-Git submodule update --init --recursive

Push-Location 'src\VRCFaceTracking'
try {
    Assert-ExactHead -RepoName 'Baballonia src\VRCFaceTracking submodule' -ExpectedCommit $expectedSubmoduleCommit
}
finally {
    Pop-Location
}

Apply-GitPatchOnce -PatchPath $patch1 -PatchName 'patch 01 (Baballonia app)'
Push-Location 'src\VRCFaceTracking'
try {
    Apply-GitPatchOnce -PatchPath $patch2b -PatchName 'patch 02b (Baballonia pinned VRCFaceTracking submodule)'
}
finally {
    Pop-Location
}
Apply-GitPatchOnce -PatchPath $patch3 -PatchName 'patch 03 (VRCFT-Babble module)'

Set-Location $repoRoot
Write-Host 'Baballonia exact patch flow complete.'
