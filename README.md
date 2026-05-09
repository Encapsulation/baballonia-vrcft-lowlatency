# Baballonia / VRCFaceTracking Low-Latency Core Changes

This repo contains reviewable patches for the low-latency Baballonia to VRCFaceTracking path.

## Contents

- `patches/01-baballonia-app-core.patch` - Baballonia capture, processing, OSC send, telemetry, and affinity changes.
- `patches/02-vrcft-host-core.patch` - VRCFaceTracking host, sandbox, push-update, and OSC send changes.
- `patches/02b-baballonia-vrcft-submodule-core.patch` - Same VRCFT host changes rebased for Baballonia's pinned `src/VRCFaceTracking` submodule.
- `patches/03-vrcft-babble-module-core.patch` - VRCFT-Babble module frame-ready / immediate-update changes.
- `scripts/apply-baballonia-exact.ps1` - one-command apply path for Baballonia plus its VRCFaceTracking submodule.
- `scripts/apply-vrcft-host-exact.ps1` - one-command apply path for a standalone VRCFaceTracking checkout.
- `docs/RESULTS.md` - short benchmark summary.
- `docs/REPRODUCE.md` - clean apply/build/benchmark method.
- `docs/CI_VERIFICATION.md` - exact clean-checkout build verification commands.
- `docs/real_e2e_stock_vs_fork_20260508.csv` - benchmark numbers.
- `tools/real_probe_proxy.py` - sanitized UDP timing proxy used for the real-path benchmark.

## Baselines

- Baballonia upstream commit: `234a393f2f7ca29ccb8aeee0069e2cae155af628`
- Baballonia pinned `src/VRCFaceTracking` submodule commit: `b4b39da5c9fe048c960aa3b9e56742834df6ff36`
- Standalone VRCFaceTracking upstream commit: `09539ec4d458ac6a37c5a620fd025c9042bf7933`

## License

MIT. See `LICENSE`.

## Apply

From a clean Baballonia checkout at `234a393`, with this repo next to it:

```powershell
..\BaballoniaVRCFT-CoreShare\scripts\apply-baballonia-exact.ps1
```

From a clean standalone VRCFaceTracking checkout at `09539ec`:

```powershell
..\BaballoniaVRCFT-CoreShare\scripts\apply-vrcft-host-exact.ps1
```

Patch 3 intentionally expects the VRCFaceTracking SDK hooks. For Baballonia CI, use patch `02b` inside `src/VRCFaceTracking`; for a standalone VRCFaceTracking repo, use patch `02`.

## Not Included

No compiled apps, runtime data, logs, calibration data, model weights, PDBs, local settings, user-local app data, or machine-specific paths are included.
