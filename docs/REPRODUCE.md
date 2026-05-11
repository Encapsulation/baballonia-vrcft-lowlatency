# Reproduce

## Code

Recommended:

```powershell
mkdir BaballoniaVRCFTPatch
cd .\BaballoniaVRCFTPatch
curl.exe -L -o setup-clean-exact.ps1 https://raw.githubusercontent.com/Encapsulation/baballonia-vrcft-lowlatency/main/scripts/setup-clean-exact.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-clean-exact.ps1 -Build
```

Manual:

```powershell
git clone https://github.com/Project-Babble/Baballonia.git
git clone https://github.com/Project-Babble/VRCFaceTracking.git
git clone https://github.com/Encapsulation/baballonia-vrcft-lowlatency.git BaballoniaVRCFT-CoreShare

cd .\Baballonia
git checkout 234a393f2f7ca29ccb8aeee0069e2cae155af628
..\BaballoniaVRCFT-CoreShare\scripts\apply-baballonia-exact.ps1

cd ..\VRCFaceTracking
git checkout 09539ec4d458ac6a37c5a620fd025c9042bf7933
..\BaballoniaVRCFT-CoreShare\scripts\apply-vrcft-host-exact.ps1
```

This applies patch `01`, patch `02b`, patch `03`, and patch `02`.
Patch `02b` is submodule-only. Do not apply it to the standalone VRCFaceTracking app repo.

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
