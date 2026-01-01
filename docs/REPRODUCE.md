# Reproduce

## Code

Clone upstream, checkout the listed baseline commits, then apply the patches from this repo.

```bash
git clone https://github.com/Project-Babble/Baballonia.git
cd Baballonia
git checkout 5de170b
git apply ../patches/01-baballonia-app-core.patch
git apply ../patches/03-vrcft-babble-module-core.patch
```

```bash
git clone https://github.com/benaclejames/VRCFaceTracking.git
cd VRCFaceTracking
git checkout fbafdd5
git apply ../patches/02-vrcft-host-core.patch
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

