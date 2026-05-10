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

Patch size: 15 files.

## 02b Baballonia VRCFT Submodule

- Same host/SDK changes as patch 02.
- Ported against Baballonia's pinned `src/VRCFaceTracking` submodule baseline.

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
