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

Most people should use one of the two scripts below. Do not manually mix patch `02` and patch `02b`.

### If You Are Installing Into Baballonia

Use this when you have the full `Baballonia` repo and want the low-latency Baballonia -> VRCFaceTracking path.

From a clean Baballonia checkout at `234a393`, with this repo next to it:

```powershell
..\BaballoniaVRCFT-CoreShare\scripts\apply-baballonia-exact.ps1
```

This script does all required Baballonia-side patching:

- Applies patch `01` to Baballonia.
- Initializes `src/VRCFaceTracking`.
- Applies patch `02b` inside `src/VRCFaceTracking`.
- Applies patch `03` to the Baballonia VRCFT-Babble module.

Manual equivalent:

```bash
git submodule update --init --recursive
git apply ../BaballoniaVRCFT-CoreShare/patches/01-baballonia-app-core.patch
(cd src/VRCFaceTracking && git apply ../../../BaballoniaVRCFT-CoreShare/patches/02b-baballonia-vrcft-submodule-core.patch)
git apply ../BaballoniaVRCFT-CoreShare/patches/03-vrcft-babble-module-core.patch
```

### If You Are Installing Into Standalone VRCFaceTracking

Use this only when you have the separate `VRCFaceTracking` repo by itself, not the full Baballonia repo.

From a clean standalone VRCFaceTracking checkout at `09539ec`:

```powershell
..\BaballoniaVRCFT-CoreShare\scripts\apply-vrcft-host-exact.ps1
```

This script applies patch `02` only. Do not apply patch `02b` or patch `03` to standalone VRCFaceTracking.

Manual equivalent:

```bash
git apply ../BaballoniaVRCFT-CoreShare/patches/02-vrcft-host-core.patch
```

### Patch Choice Plain English

- Patch `02` is for a normal standalone `VRCFaceTracking` checkout.
- Patch `02b` is the same host change rebased for Baballonia's pinned `src/VRCFaceTracking` submodule.
- Patch `03` is only for the Baballonia module. The Baballonia apply script handles it. Do not use it with standalone VRCFaceTracking.

If you are unsure, start with `scripts/apply-baballonia-exact.ps1` from a clean Baballonia checkout.

## Not Included

No compiled apps, runtime data, logs, calibration data, model weights, PDBs, local settings, user-local app data, or machine-specific paths are included.
