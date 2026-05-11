# Baballonia VRCFT Low Latency Patch Set

Clean install, apply, and build:

```powershell
mkdir BaballoniaVRCFTPatch
cd .\BaballoniaVRCFTPatch
curl.exe -L -o setup-clean-exact.ps1 https://raw.githubusercontent.com/Encapsulation/baballonia-vrcft-lowlatency/main/scripts/setup-clean-exact.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-clean-exact.ps1 -Build
```

Existing patched Baballonia tree:

```powershell
curl.exe -L https://raw.githubusercontent.com/Encapsulation/baballonia-vrcft-lowlatency/main/patches/04-baballonia-eye-preview-state-fix.patch | git apply -
```

Manual clean install:

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

cd ..\Baballonia
powershell -NoProfile -ExecutionPolicy Bypass -File .\download_dependencies.ps1
dotnet publish .\src\Baballonia.Desktop\Baballonia.Desktop.csproj -r win-x64 -c Release --self-contained -f net10.0
dotnet build .\src\VRCFaceTracking.Baballonia\VRCFaceTracking.Baballonia.csproj -c Release

cd ..\VRCFaceTracking
dotnet build .\VRCFaceTracking.sln -c Release
```

Patch `02b` is only for Baballonia's pinned `src\VRCFaceTracking` submodule. Standalone VRCFaceTracking uses patch `02` at `09539ec4d458ac6a37c5a620fd025c9042bf7933`.
