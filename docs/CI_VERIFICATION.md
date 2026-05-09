# CI Verification

These checks were run from clean upstream checkouts with the public patch files in this repo.

## Baballonia

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

## VRCFaceTracking

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

## Exact-Fork Note

Patch 3 is exact to the fork and uses the SDK hooks added by patch `02b` inside Baballonia's pinned submodule. Applying only patch 1 and patch 3 to Baballonia is expected to fail module CI because the stock submodule SDK does not yet have `SupportsPushUpdates` or `RequestImmediateUpdate`.
