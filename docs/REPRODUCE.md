# Reproduce

## Code

Clone upstream, checkout the listed baseline commits, then apply the patches from this repo.

Use one install path only:

- Full Baballonia repo: run `scripts/apply-baballonia-exact.ps1`.
- Standalone VRCFaceTracking repo: run `scripts/apply-vrcft-host-exact.ps1`.

Patch `02` is for standalone VRCFaceTracking. Patch `02b` is for Baballonia's pinned `src/VRCFaceTracking` submodule. Patch `03` is for Baballonia's VRCFT-Babble module only.

```bash
git clone https://github.com/Project-Babble/Baballonia.git
cd Baballonia
git checkout 234a393f2f7ca29ccb8aeee0069e2cae155af628
```

```powershell
..\BaballoniaVRCFT-CoreShare\scripts\apply-baballonia-exact.ps1
```

That script applies patch `01` to Baballonia, patch `02b` inside `src/VRCFaceTracking`, then patch `03` to the Baballonia module.

Manual equivalent:

```bash
git submodule update --init --recursive
git apply ../BaballoniaVRCFT-CoreShare/patches/01-baballonia-app-core.patch
(cd src/VRCFaceTracking && git apply ../../../BaballoniaVRCFT-CoreShare/patches/02b-baballonia-vrcft-submodule-core.patch)
git apply ../BaballoniaVRCFT-CoreShare/patches/03-vrcft-babble-module-core.patch
```

```bash
git clone https://github.com/Project-Babble/VRCFaceTracking.git
cd VRCFaceTracking
git checkout 09539ec4d458ac6a37c5a620fd025c9042bf7933
```

```powershell
..\BaballoniaVRCFT-CoreShare\scripts\apply-vrcft-host-exact.ps1
```

Manual equivalent:

```bash
git apply ../BaballoniaVRCFT-CoreShare/patches/02-vrcft-host-core.patch
```

## Build Checks

Baballonia:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\download_dependencies.ps1
dotnet publish .\src\Baballonia.Desktop\Baballonia.Desktop.csproj -r win-x64 -c Release --self-contained -f net10.0
dotnet build .\src\VRCFaceTracking.Baballonia\VRCFaceTracking.Baballonia.csproj -c Release
```

VRCFaceTracking:

```powershell
dotnet build .\VRCFaceTracking.sln -c Release
```

## Benchmark Method

1. Build patched Baballonia, patched VRCFaceTracking, and patched `VRCFaceTracking.Baballonia`.
2. Stop VRChat or move its OSC receive port so `127.0.0.1:9000` is free.
3. Start the proxy:

```bash
python tools/real_probe_proxy.py
```

4. Configure Baballonia to send its VRCFT/module OSC stream to `127.0.0.1:18888`.
5. The proxy forwards Baballonia to VRCFT at `127.0.0.1:8888`.
6. VRCFT sends output to `127.0.0.1:9000`, where the proxy records timing.
7. Compare `probe-output/summary-*.txt` with `docs/real_e2e_stock_vs_fork_20260508.csv`.

Exact numbers depend on camera, model, CPU, smoothing settings, detector settings, and runtime load.
