# Patch Scope

## 01 Baballonia App

- Frame-driven capture/processing path.
- Duplicate-frame reduction.
- Timestamped capture/processing/send telemetry.
- Semaphore-driven parameter sender.
- `/vrcft/babble/frameReady` marker.
- Process/thread priority and affinity support.
- Corruption detector and tracking hot-path support code.

Patch size: 49 files.

## 02 VRCFaceTracking Host

- Push-capable module support.
- Immediate update request flow.
- Sandbox host/module IPC changes.
- OSC send timing and lower-latency handoff path.
- Module process priority behavior.
- Apply only to standalone VRCFaceTracking at `09539ec4d458ac6a37c5a620fd025c9042bf7933`.

Patch size: 15 files.

## 02b Baballonia VRCFT Submodule

- Same host/SDK changes as patch 02.
- Ported against Baballonia's pinned `src/VRCFaceTracking` submodule baseline.
- Apply only inside Baballonia's `src/VRCFaceTracking` submodule at `b4b39da5c9fe048c960aa3b9e56742834df6ff36`.

Patch size: 15 files.

## 03 VRCFT-Babble Module

- Frame-ready handling.
- Stale data handling.
- Deferred immediate update until the frame is complete.
- Callback into VRCFT for immediate update.

Patch size: 3 files.

## 04 Baballonia Eye Preview State Fix

- Keeps preview-only clearing from marking an active camera as stopped.
- Restores crop-mode eye preview recovery after the window preview has been cleared.
- Included in patch `01` for clean installs; patch `04` is only for already-patched Baballonia trees.

Patch size: 1 file.
