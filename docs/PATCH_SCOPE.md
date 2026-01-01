# Patch Scope

## 01 Baballonia App

- Frame-driven capture/processing path.
- Duplicate-frame reduction.
- Timestamped capture/processing/send telemetry.
- Semaphore-driven parameter sender.
- `/vrcft/babble/frameReady` marker.
- Process/thread priority and affinity support.
- Corruption detector and tracking hot-path support code.

Patch size: 31 files.

## 02 VRCFaceTracking Host

- Push-capable module support.
- Immediate update request flow.
- Sandbox host/module IPC changes.
- OSC send timing and lower-latency handoff path.
- Module process priority behavior.

Patch size: 14 files.

## 03 VRCFT-Babble Module

- Frame-ready handling.
- Stale data handling.
- Deferred immediate update until the frame is complete.
- Callback into VRCFT for immediate update.

Patch size: 3 files.

