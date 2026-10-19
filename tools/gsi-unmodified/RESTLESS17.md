# Requested RestlessOS Android 17 trial

Trial date: 2026-10-19. The user requested this exact distributed release:
[17.0.0-202610142343](https://github.com/cawilliamson/treble_restlessos/releases/tag/17.0.0-202610142343).
The user subsequently said that restoring MIUI was unnecessary, so no MIUI
userdata backup or rollback preparation is part of this trial.

## Input

- RestlessOS-arm64-ab-17.0.0-202610142343.img.xz, 940616448 bytes.
- GitHub-published SHA256 and downloaded SHA256 match:
  `02af2d11f97af66c362dde804fe22414b09cb11803249f72524d33fa01475433`.
- xz integrity passes; the losslessly expanded image is raw ext4,
  3174416384 bytes, within the 4311744512-byte system partition.
- Raw SHA256:
  `edc406efa285868ae5af1c9218065072aaba650c8f7660cb1a3632b569071194`.
- Android17 / SDK37 / REL, build2026101400, based on GrapheneOS2026100600.
- The original image is not edited, repacked, debloated or rebuilt. AOSP and
  the reference BSP remain unchanged.

## VNDK inspection

The main /system/apex directory does not contain VNDK snapshots. An initial
scan limited to that location missed them; the subsequent extended inspection
found VNDK28 through34 in /system/system_ext/apex (also visible via /system_ext).
The metadata was corrected before flashing. The VNDK29 APEX is 103825408 bytes,
ZIP CRC verification passes, and its apex_payload.img is 103677952 bytes.
It is an actual payload, not a Git LFS pointer.

The previously tested LineageOS24.0 Android17 20261008-r2 image has only
VNDK31/32/33/34 in its corresponding system_ext/apex directory. Therefore
RestlessOS is a different compatibility input; the old runtime failure is not
used as proof that this release cannot boot.

## Board and method

TAB-A04-BR3, ARM64, 2 GiB RAM, Android10 vendor / VNDK29, Linux4.14.141+
PSI build #19. Existing public kernel/vendor inputs are retained. Userdata is
formatted for this trial, with the host ADB public key seeded for inspection.
A temporary vendor deadline/capture service is used without editing the GSI.
It must be removed before retaining a working system.

All flash/mtkclient output appends to the existing fixed logs/flash.log.
Continuous UART remains in logs/uart-ttyUSB0-921600.log. Input metadata and
runtime captures are in logs/restless17-trial/ and its restless17 subdirectory.
Use fastboot when available and fastboot oem reboot-recovery for MTK recovery.
No emulator, periodic automation or local GSI build is used.

## Result

Fastboot wrote all 47 chunks successfully (283.141 seconds). With the original
GSI and existing vendor, Android17 reached ADB and zygote, but did not complete
framework boot. SELinux was Enforcing. system_server repeatedly terminated with
`java.lang.RuntimeException: Failed to create ashmem: Permission denied` in
ApplicationSharedMemory.nativeCreate / SystemServer.run. SurfaceFlinger also
logged denied access to the randomized ashmem device labeled
`ashmem_libcutils_device`. There was no working application screen and
sys.boot_completed was unset. VNDK29 payload absence is not the cause established
by this trial.

Production adbd rejected adb root. Runtime properties, crash logs and UART were
saved before requesting recovery through ADB. This result establishes failure
with the current vendor policy; it does not establish that all Android17 images
are impossible on this hardware. No GSI edits or permissive-policy workaround
were applied. The subsequent user request is to correct the device model name,
verify AOSP10, and replace its public release.
