# Results Summary

Real-path benchmark measured Baballonia/VRCFT software latency from real camera processing to the VRCFT OSC packet sent toward VRChat.

| Metric | Stock | Fork | Reduction | Speedup |
|---|---:|---:|---:|---:|
| Mean processing/camera to VRCFT output | 18.455 ms | 5.017 ms | 72.8% | 3.68x |
| P90 estimate | 27.619 ms | 5.515 ms | 80.0% | 5.01x |
| VRCFT handoff mean | 8.938 ms | 0.143 ms | 98.4% | 62.49x |
| VRCFT handoff P90 | 17.875 ms | 0.165 ms | 99.1% | 108.33x |

Scope: this does not measure VRChat avatar/render response after the OSC packet, and it does not timestamp physical eye movement before the camera frame exists.

