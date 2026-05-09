param(
    [string]$ShareRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

function Run-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed"
    }
}

$patch1 = Join-Path $ShareRoot 'patches\01-baballonia-app-core.patch'
$patch2b = Join-Path $ShareRoot 'patches\02b-baballonia-vrcft-submodule-core.patch'
$patch3 = Join-Path $ShareRoot 'patches\03-vrcft-babble-module-core.patch'

Run-Git submodule update --init --recursive

Run-Git apply --check $patch1
Push-Location 'src\VRCFaceTracking'
try {
    Run-Git apply --check $patch2b
}
finally {
    Pop-Location
}
Run-Git apply --check $patch3

Run-Git apply $patch1
Push-Location 'src\VRCFaceTracking'
try {
    Run-Git apply $patch2b
}
finally {
    Pop-Location
}
Run-Git apply $patch3

Write-Host 'Applied Baballonia app, VRCFaceTracking submodule, and Babble module exact fork patches.'
