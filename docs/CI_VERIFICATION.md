# CI Verification

These checks were run from clean upstream checkouts with the public patch files in this repo. The full stack uses both sections below.

## 1. Baballonia App, Pinned VRCFT Submodule, And Module

Baseline: `Project-Babble/Baballonia` at `234a393f2f7ca29ccb8aeee0069e2cae155af628`.

Pinned submodule baseline after `git submodule update --init --recursive`:
`src/VRCFaceTracking` at `b4b39da5c9fe048c960aa3b9e56742834df6ff36`.

```powershell
$share = Resolve-Path ..\BaballoniaVRCFT-CoreShare
& $share\scripts\apply-baballonia-exact.ps1 -ShareRoot $share
powershell -NoProfile -ExecutionPolicy Bypass -File .\download_dependencies.ps1
dotnet publish .\src\Baballonia.Desktop\Baballonia.Desktop.csproj -r win-x64 -c Release --self-contained -f net10.0
dotnet build .\src\VRCFaceTracking.Baballonia\VRCFaceTracking.Baballonia.csproj -c Release
```

Verified result:

- Patch 1 applies.
- Patch `02b` applies inside Baballonia's pinned `src/VRCFaceTracking`.
- Patch 3 applies.
- Desktop publish succeeds.
- `VRCFaceTracking.Baballonia` module build succeeds.
- Build warnings are present from upstream dependencies/nullability, but there are `0 Error(s)`.

## 2. VRCFaceTracking App

Baseline: `Project-Babble/VRCFaceTracking` at `09539ec4d458ac6a37c5a620fd025c9042bf7933`.

```powershell
$share = Resolve-Path ..\BaballoniaVRCFT-CoreShare
& $share\scripts\apply-vrcft-host-exact.ps1 -ShareRoot $share
dotnet build .\VRCFaceTracking.sln -c Release
```

Verified result:

- Patch 2 applies.
- Release solution build succeeds.
- Build warnings are present from upstream dependencies/nullability, but there are `0 Error(s)`.

## Full Stack Requirement

Matching the verified local stack requires both apply scripts:

- `scripts/apply-baballonia-exact.ps1` applies `01`, `02b`, and `03`.
- `scripts/apply-vrcft-host-exact.ps1` applies `02`.
