# CI Verification

These checks were run from clean upstream checkouts with the public patch files in this repo.

## 0. Recommended Setup Wrapper

Command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-clean-exact.ps1 -WorkRoot <clean-work-root> -Build
```

Verified result:

- Clones/checks out Baballonia at `234a393f2f7ca29ccb8aeee0069e2cae155af628`.
- Applies patch `01`, patch `02b` inside the pinned `src/VRCFaceTracking` submodule, and patch `03`.
- Clones/checks out standalone VRCFaceTracking at `09539ec4d458ac6a37c5a620fd025c9042bf7933`.
- Applies patch `02` only to standalone VRCFaceTracking.
- Re-running the setup wrapper reports the patches as already applied.
- Running the standalone VRCFT patch script from Baballonia's submodule is rejected.
- Baballonia publish, `VRCFaceTracking.Baballonia` build, and standalone VRCFaceTracking build all complete with `0 Error(s)`.

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
