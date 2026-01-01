# Baballonia / VRCFaceTracking Low-Latency Core Changes

This repo contains reviewable patches for the low-latency Baballonia to VRCFaceTracking path.

## Contents

- `patches/01-baballonia-app-core.patch` - Baballonia capture, processing, OSC send, telemetry, and affinity changes.
- `patches/02-vrcft-host-core.patch` - VRCFaceTracking host, sandbox, push-update, and OSC send changes.
- `patches/03-vrcft-babble-module-core.patch` - VRCFT-Babble module frame-ready / immediate-update changes.
- `docs/RESULTS.md` - short benchmark summary.
- `docs/REPRODUCE.md` - clean apply/build/benchmark method.
- `docs/real_e2e_stock_vs_fork_20260508.csv` - benchmark numbers.
- `tools/real_probe_proxy.py` - sanitized UDP timing proxy used for the real-path benchmark.

## Baselines

- Baballonia upstream commit: `5de170b`
- VRCFaceTracking upstream commit: `fbafdd5`

## Apply

From a clean Baballonia checkout at `5de170b`:

```bash
git apply patches/01-baballonia-app-core.patch
git apply patches/03-vrcft-babble-module-core.patch
```

From a clean VRCFaceTracking checkout at `fbafdd5`:

```bash
git apply patches/02-vrcft-host-core.patch
```

## Not Included

No compiled apps, runtime data, logs, calibration data, model weights, PDBs, local settings, user-local app data, or machine-specific paths are included.
