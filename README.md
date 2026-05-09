# Baballonia VRCFT Low Latency Patch Set

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
