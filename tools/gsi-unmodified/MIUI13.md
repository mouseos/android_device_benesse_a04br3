# Nippon MIUI 13 distributed GSI trial

Input: MIUI Global 13.0.1, Redmi Note 11 / spes, Android 12, SAR/AB,
20220807 NipponGSI. Trial date: 2026-10-19.

[Original download](https://sourceforge.net/projects/nippongsi/files/MIUI%20-%20MIUI-Global-%5B13.0.1%5D-spes%20-%20KHCTVGVRP1/MIUI-Global-%5B13.0.1%5D-spes-AB-12-20220807-NipponGSI.img.gz/download)

Published compressed SHA256:
`c9b6f5f754b175cbccf944989aace0233d299dcc9d89e9ed3d53816625b99e83`.
Compressed size: 1771907260 bytes. Publisher reports a 3.52 GiB image;
actual expanded image is raw ext4, 3789115392 bytes, within the system partition.

Board environment: TAB-A04-BR3, Cortex-A35 / ARM64, 2 GiB RAM,
Android 10 vendor / VNDK 29, 4311744512-byte system partition,
PSI-enabled kernel build #19. Public source revisions: device 49d8dae,
kernel eb47f42, vendor 0c756f4. The vendor MP2 metadata fix remains in use.

The downloaded image is not edited, rebuilt, debloated or repacked.
Only lossless decompression and sparse/raw representation conversion are
permitted. AOSP and the reference BSP remain unchanged. Temporary vendor
recovery/capture services are removed before final retention. Userdata may
be erased. Flash output and continuous UART use the existing fixed logs.

## Result

The unmodified Android 12 image did not complete boot during the 486.6-second
host observation. UART showed missing `/apex/com.android.vndk.v29`, a linkerconfig
abort (`LLNDK_LIBRARIES_VENDOR is not defined`), and repeated adbd execution
failure because `/apex/com.android.adbd/bin/adbd` was absent. These are observed
failures; VNDK absence alone is not established as the sole cause.

The Android 11 MIUI 13.0.12/spes/20220831 alternative was downloaded and its
published SHA256 matched, but it also lacked a VNDK 29 payload and was not flashed.
Its raw ext4 size is 3555987456 bytes. Compressed SHA256:
`b7f3bbaf75a9a677ecdb67708dc01f5d274645a4079620fff4f6b14e0003707a`.

Recovery ADB and UID 0 were confirmed again at approximately 14:43 JST. The
subsequent user request broadens testing to other distributed OEM UI GSIs from
Nippon, Erfan and Mystic. This MIUI image is recorded as incompatible in the tested
configuration, not as a successful MIUI port.
