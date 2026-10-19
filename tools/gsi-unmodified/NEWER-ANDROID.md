# Distributed Android 11+ GSI trials

Hardware: TAB-A04-BR3 / MT8167, Android 10 vendor (VNDK 29), kernel
4.14.141+ with the USB fix, corrected MediaTek recovery header. Observed
on 2026-10-19. These are individual image trials, not a claim about every
GSI of the same Android release.

## Image and source policy

Download and decompress the published image. Lossless sparse/raw conversion
is permitted. Do not edit its filesystem, properties, signatures, policy,
or AVB data; do not build a replacement GSI. AOSP and the reference BSP
remain unpatched. Board changes belong in the public device/vendor/kernel
repositories. Userdata was erased for each new image. Initial setup flags
and package enable/disable states below are userdata settings.

The Android 16 image ships an rw-system.sh which remounts system, calls
resize2fs and returns it to read-only during boot. This upstream runtime
behavior changes filesystem metadata; a post-boot raw partition hash is
therefore not an identity check against the original downloaded image.
The input image remains untouched. Do not report a post-boot raw mismatch
alone as transfer corruption, or report full equality without evidence.

## Observations

| Android | Distributed build | Result |
| --- | --- | --- |
| 11 | Andy Yan Lineage18.1 20240121 arm64_bvS | Boot complete, Settings rendered, Wi-Fi scan, Bluetooth ON, two camera devices, AudioFlinger hardware status 0. |
| 12L (SDK 32) | Andy Yan Lineage19.1 20250606 arm64_bvS | Boot complete, Settings rendered and Home resolved; Wi-Fi scan, Bluetooth ON, two camera devices, audio status 0. |
| 13 | Andy Yan Lineage20 20251021 arm64_bvS | Boot complete, Home and Settings rendered; Wi-Fi scan, Bluetooth ON, two camera devices, audio status 0. |
| 14 | Andy Yan Lineage21 20250621 arm64_bvS | Boot complete after a second boot with the same system/data. Settings rendered. A 5 GHz Wi-Fi connection obtained DHCP and passed external-IP and DNS ping tests. Phone repeatedly crashes in RadioVoiceProxy.isEmpty; Bluetooth stays OFF. |
| 15 | MisterZtr Lineage22.2 20260105 VANILLA EXT4 | ADB/APEX/partial framework, no completed boot in about 360 s. audioserver repeatedly SIGSEGV in AudioFlinger::onFirstRef. configstore HAL also SIGSYS. Post-failure readback verification was not completed; transfer corruption has not been independently excluded. |
| 16 | MisterZtr Lineage23.2 20260524 VANILLA EXT4 | With vendor MP2 metadata, PSI kernel #19 and userdata workarounds: boot complete, Home/Settings rendered, 5 GHz DHCP, external-IP ping 3/3 and DNS ping 1/1. Earlier kernel #18 trials had UI/ART/Bluetooth failures; Bluetooth is retained OFF. Retained after removal of the temporary vendor services and a successful reboot with automatic Wi-Fi reconnection. |
| 17 | Kyros70 Lineage24 20261008-r2 arm64_ab vanilla | No completed boot. linkerconfig aborts for missing VNDK 29 / undefined SANITIZER_DEFAULT_VENDOR; automatic recovery return in about 69 s. Publisher requires VNDK 31+. |

Observed SELinux mode for these unofficial trials was Permissive. Enforcing,
CTS, Bluetooth pairing/data, audio playback/recording and camera capture
are not certified by service enumeration. The pre-existing NVRAM invalid-MAC
warning persists; it did not prevent the Android 14 Wi-Fi network test.

Android 13's 32-bit BoringSSL self-test took about 50 seconds and succeeded.
Android 14's first attempt was interrupted by the old host timeout while
compilation was still progressing; this was not sufficient evidence of
incompatibility. Rebooting the unchanged image/data completed successfully.

## Android 16 diagnostics

The initial vendor configuration repeatedly aborted system_server and
mediaserver32 in AudioCapabilities::getDefaultFormat with UBSAN sub-overflow,
after the unsupported audio/mpeg-L2 warning. Declaring the MP2 decoder's
stereo channel limit stopped that abort in subsequent observations. The
change is in public vendor commit
[0c756f4](https://github.com/mouseos/android_vendor_benesse_a04br3/commit/0c756f4).

CellBroadcastService then ANRed in the shared networkstack process, leading
to a system_server Lost network stack exception. The successful observation
used both of these userdata changes; their individual necessity has not
been separated:

```sh
adb shell pm disable-user --user 0 com.android.cellbroadcastservice
adb shell pm disable-user --user 0 com.android.phone
```

The image's setup wizard was bypassed for UI comparison using:

```sh
adb shell settings put global device_provisioned 1
adb shell settings put secure user_setup_complete 1
adb shell pm disable-user --user 0 org.lineageos.setupwizard
adb shell cmd package set-home-activity --user 0 com.android.launcher3/.uioverrides.QuickstepLauncher
```

This reached boot_completed and Settings, but later UI automation timed out
and the screen could show only wallpaper. A reboot also recorded ART
SuspendAll timeout and Bluetooth's unexpected status event for
READ_DEFAULT_ERRONEOUS_DATA_REPORTING. lmkd repeatedly exited because PSI
was unavailable and the current memory hierarchy could not use the cgroup
v1 pressure fallback. A separate kernel build enables CONFIG_PSI (public kernel commit
[eb47f42](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3/commit/eb47f42)).
Hardware verified /proc/pressure, lmkd running and all four MT6630 modules
loaded with build #19. The PSI trial subsequently completed its first boot in about 321 seconds.
Home and Settings rendered; standard Wi-Fi settings accepted the test
network, obtained DHCP, and passed three external-IP pings and one DNS
lookup/ping with no packet loss. The crash buffer was empty at that
checkpoint. Matching kernel/modules are included in prebuilt/.
Bluetooth was not re-enabled after the previously observed HCI failure;
keep its power-on/data support unverified on this retained configuration.

## Final retained configuration

The device retains the distributed Android 16 image above. Temporary vendor
capture/recovery services were removed, userdata and the saved network were
preserved, then the device rebooted normally. At about 92 seconds uptime,
boot_completed was 1, lmkd was running and all four connectivity modules
were loaded. The recovery/capture rc and its init service definitions were
absent. Wi-Fi reconnected automatically and again passed external-IP ping
3/3 and DNS ping 1/1. Home and Settings rendering were visually checked.
The crash buffer remained empty at the final checkpoints.

Initial final-reboot screenshots were black because the display had timed
out into Doze, not because the framework crashed (dumpsys power recorded
mLastSleepReason=timeout). Waking it with a temporary stay-awake setting
restored normal drawing. The original stay_on_while_plugged_in=0 setting
was restored afterward. Check power state before classifying a black
screenshot as a graphics failure.

Bluetooth remains OFF because of the earlier HCI failure. The existing
NVRAM warning is unresolved. No claim of complete hardware compatibility,
Enforcing or CTS compliance is made.

## Android 17 boundary

The distributed image itself contains VNDK APEX 31/32/33/34, with no 29
(checked read-only with debugfs). The actual boot reports missing
/apex/com.android.vndk.v29 and linkerconfig aborts. This is an input-image
compatibility limit for this VNDK 29 vendor, not evidence that every
Android 17 GSI or a future vendor port is impossible. Do not spoof the
VNDK property or copy libraries into the GSI to label this image compatible.
The post-boot partition also grew from 557299 to 1052672 blocks, so its
raw readback hash differs from the untouched input; full equality was not
claimed.

## Flashing and recovery

Use fastboot when available, with the distributed raw image:

```sh
fastboot -s SERIAL -S 64M flash system DISTRIBUTED_RAW_IMAGE.img
fastboot -s SERIAL reboot
```

MediaTek recovery entry is:

```sh
fastboot -s SERIAL oem reboot-recovery
```

Temporary vendor recovery/capture services used for unattended trials must
be removed before the final retained system is rebooted. Keep continuous
UART and append flashing output to the established fixed log. Check written
bytes when a failure warrants it; a command accepting a flash is not a
successful OS boot. Do not use the recovery head implementation for >2 GiB
reads; use dd with a checked block count.

## Distribution sources

- [11](https://sourceforge.net/projects/andyyan-gsi/files/lineage-18.x/)
- [12L](https://sourceforge.net/projects/andyyan-gsi/files/lineage-19.x/)
- [13](https://sourceforge.net/projects/andyyan-gsi/files/lineage-20-td/)
- [14](https://sourceforge.net/projects/andyyan-gsi/files/lineage-21-td/)
- [15](https://sourceforge.net/projects/misterztr-gsi/files/LineageOS/Android%2015/)
- [16](https://sourceforge.net/projects/misterztr-gsi/files/LineageOS/Android%2016/)
- [17](https://github.com/Kyros70/Lineage_treble/releases/tag/20261008-r2)
