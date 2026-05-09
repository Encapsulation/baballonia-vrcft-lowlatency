# Baballonia / VRCFaceTracking Low-Latency Core Changes

This repo contains reviewable patches for the low-latency Baballonia to VRCFaceTracking path.

## Contents

- `patches/01-baballonia-app-core.patch` - Baballonia capture, processing, OSC send, telemetry, and affinity changes.
- `patches/02-vrcft-host-core.patch` - VRCFaceTracking app host, sandbox, push-update, and OSC send changes.
- `patches/02b-baballonia-vrcft-submodule-core.patch` - Same VRCFT host changes rebased for Baballonia's pinned `src/VRCFaceTracking` submodule.
- `patches/03-vrcft-babble-module-core.patch` - VRCFT-Babble module frame-ready / immediate-update changes.
- `scripts/apply-baballonia-exact.ps1` - applies the Baballonia app, pinned VRCFT submodule, and VRCFT-Babble module patches.
- `scripts/apply-vrcft-host-exact.ps1` - applies the VRCFaceTracking app patch.
- `docs/RESULTS.md` - short benchmark summary.
- `docs/REPRODUCE.md` - clean apply/build/benchmark method.
- `docs/CI_VERIFICATION.md` - exact clean-checkout build verification commands.
- `docs/real_e2e_stock_vs_fork_20260508.csv` - benchmark numbers.
- `tools/real_probe_proxy.py` - sanitized UDP timing proxy used for the real-path benchmark.

## Baselines

- Baballonia upstream commit: `234a393f2f7ca29ccb8aeee0069e2cae155af628`
- Baballonia pinned `src/VRCFaceTracking` submodule commit: `b4b39da5c9fe048c960aa3b9e56742834df6ff36`
- VRCFaceTracking app upstream commit: `09539ec4d458ac6a37c5a620fd025c9042bf7933`

## License

MIT. See `LICENSE`.

## Apply Full Stack

To match the verified local stack, patch both upstream apps:

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

That applies the complete patch set:

- `01` to the Baballonia app.
- `02b` to Baballonia's pinned `src/VRCFaceTracking` submodule.
- `03` to the Baballonia VRCFT-Babble module.
- `02` to the VRCFaceTracking app.

## Not Included

No compiled apps, runtime data, logs, calibration data, model weights, PDBs, local settings, user-local app data, or machine-specific paths are included.
