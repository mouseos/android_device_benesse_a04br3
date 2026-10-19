# Distributed OEM UI GSI trials

Target: TAB-A04-BR3, ARM64, 2 GiB RAM, Android 10 vendor / VNDK 29,
4311744512-byte system partition, PSI-enabled kernel #19. Trial date: 2026-10-19.
The user requested distributed Nippon, Erfan and Mystic images with an OEM UI.
GSI editing, repacking, debloating and local GSI builds are prohibited. Only
lossless archive extraction and sparse/raw representation conversion are used.
AOSP and the reference BSP are unchanged. Userdata may be erased.

## Selection

- [Nippon OxygenOS](https://sourceforge.net/projects/nippongsi/files/oos/):
  OnePlus6-AB-10-20210722-nippongsi.img.gz. Published compressed SHA256
  `291b768480f8c44ca96338b266a73815b8a6725e9fe37a1dfd2afed1c3868514`.
  Downloaded SHA256 matches; gzip CRC passes. Sparse 2487742732 bytes expands
  losslessly to raw 2616799232 bytes, SHA256
  `d47ad5bf8803e811dadc1d4a18cfbdd877788c4f98e297b4857a6709c9551a1f`.
  Android 10 SDK29, OxygenOS 10.3.12, ARM64, VNDK29 payload present. Hardware result is below.
- [Erfan OxygenOS](https://mirrors.lolinet.com/firmware/gsi/OxygenOS/):
  OxygenOS-AB-10-20191102-ErfanGSI.img-2325.7z. Downloaded archive 846435923 bytes;
  locally calculated compressed SHA256
  `29211b0f5cd75db5baa8c8f756fa1727bf8e487458e26abb5326c8e62c797477`.
  This hash is not described as a publisher-provided hash. 7z extraction verifies
  archive CRC. Sparse image 2411352332 bytes expands to raw 2537775104 bytes,
  SHA256 `f230b9b5dec8bf401ad5031db100ae31b18d83591be1ffe94ff26b74fd2b1a54`.
  Android 10 SDK29, ro.oxygen.version=10.0, OnePlus6T source fingerprint,
  VNDK29 shared library payload present. The initial hardware trial failed as described below.
- [Mystic MIUI](https://sourceforge.net/projects/mystic-gsi-updates/files/MIUI/):
  Miui-laurel_sprout-11-V12.0.22.0.RFQMIXM-AB-20250330-MysticGSI.zip
  expands to raw 3032604672 bytes, but is excluded before flashing. Its
  com.android.vndk.v29.apex is only a 134-byte Git LFS pointer, not an APEX
  payload. Its system_ext launcher is SearchLauncherQuickStep (Android One).
  The generic MIUI properties in the image do not establish a MIUI UI.
- Mystic XtbUI-surya-12-V14.0.2.0.SJGMIXM-AB-20230822-MysticGSI.zip:
  ZIP directory reports image size 3261829120 bytes. Published compressed SHA256
  `19de66ac7dd76f842adff0a6b2cf8182247f2dd375919e0fc2b5282c680c6e25`.
  Published SHA256 matched; ZIP CRC verified. Raw ext4 is 3261829120 bytes,
  SHA256 `578f5719ef020e63c9cea1ab3773ceaca91544f23ab57cde9101baf8dd8d26cd`.
  Android 12 SDK31, MIUI V140/code14. No VNDK29 APEX or vndk-29 library
  directory was found. Not flashed in the current VNDK29 configuration.

## Validation and logs

Boot animation, sys.boot_completed, actual Settings/Home rendering, and network
communication are recorded separately. An image is not called compatible merely
because it fits or flashes. Failed images are not repeated without new evidence.
The known working LineageOS 23.2 / Android 16 distributed image remains the
rollback input. A successful unofficial OEM UI image is retained.

All fastboot/mtkclient output appends to the existing fixed logs/flash.log.
Continuous UART uses logs/uart-ttyUSB0-921600.log. Per-input checks and boot
captures use logs/oem-ui-trial/. Temporary vendor deadline/capture services are
removed before retaining a working image. Recovery uses fastboot oem
reboot-recovery where applicable. No emulator or scheduled automation is used.

## Erfan OxygenOS 10.0 hardware result

The initial boot mounted userdata and ran ADB and SurfaceFlinger, but
ro.crypto.state and vold.decrypt were empty and no zygote started. Sending
`adb shell setprop vold.decrypt trigger_restart_framework` started both zygotes,
installd and system_server without editing the GSI. Initial app optimization
progressed for several minutes.

SystemServer then repeatedly aborted with:
`Signature|privileged permissions not in privapp-permissions whitelist:
{me.phh.treble.app: android.permission.INTERACT_ACROSS_USERS}`.
The image did not reach boot_completed. Its missing privileged-permission entry
was not patched. A proposed board-only startup action was removed from the
source before testing the next image; it was never installed on hardware.

The newer Nippon OxygenOS10.3.12 original already sets
ro.control_privapp_permissions=log in system/build.prop (and disable in
system/etc/prop.default), unlike this failing Erfan case. That gives new evidence
for trying the newer distributed image without repeating the same original.
The Nippon image was subsequently flashed in 334.813 seconds. It set
ro.crypto.state=unsupported and started zygote/system_server without intervention.
Boot completion was observed, with the host trial finishing after 419.3 seconds.
However, SystemUI repeatedly crashed in
com.oneplus.systemui.biometrics.OpBiometricDialogImpl.start because its
WindowManager reference was null. The Settings attempt screenshot was black.
This is recorded as boot_completed=true and usable_ui=false, not a successful
OEM UI installation. The device was returned to recovery.

Next input under inspection:
[MIUI EU 12.5.7 / Redmi Note 7 / Android10 AB / 20211123](https://sourceforge.net/projects/nippongsi/files/MIUI%20-%20HMNote7_EU_12.5.7%20-%20PQ3B161QQM/HMNote7_EU_12.5.7-AB-10-20211123-NipponGSI.img.gz/download).
Published compressed SHA256:
`03633117668aee1659d00dafd774074e12ca6a97a8b0238ea4d1d1e10e95035b`.
The downloaded SHA256 matches the published value; gzip CRC passes. The image
is raw ext4, 2724708352 bytes, SHA256
`a3112566fcc3a2f8876365bd81c04c0a18df041aa17a0f56d8a2e579d6c1a0b6`.
Android10 SDK29, ARM64, MIUI V125, VNDK29 shared library payload present.
The original image reached boot_completed=true; the host trial ended after
210.7 seconds including captures. The user independently confirmed that the
MIUI UI was working. This image is retained instead of reverting to AOSP or
LineageOS.

## Retained MIUI and density correction

The image initially used a 440-dpi display density on the 1280x800 panel,
which the user reported as too large. `wm density 160` was rejected with
WRITE_SECURE_SETTINGS; `pm grant` was also rejected, and ADB root was unavailable
on this production image. Input injection also lacked INJECT_EVENTS permission.
These limitations were not hidden or bypassed by editing the GSI.

Recovery root was used to back up userdata's settings_secure.xml and set only
`display_density_forced=160` for user 0. The written XML was read back and
verified. The GSI, framework, APKs, properties, signatures and AVB were not edited.
The temporary vendor trial init file was removed and normal boot selection
restored before a normal reboot.

After reboot, boot_completed=1, physical density=440 and override density=160
were observed. SystemServer and SystemUI were running, the display was awake/on,
and a Settings window with smaller text was captured. The retained MIUI is
V125 / Android10 SDK29. This validates density persistence and UI startup;
full interactive Settings coverage and internet communication were not tested.

A remaining bundled-app failure is recorded: com.xiaomi.finddevice throws
NoClassDefFoundError for miui.cloud.os.MultiuserUtils. Therefore this is a
working OEM UI boot and user-confirmed display result, not complete feature
compatibility. No Mi account or find-device function was tested. No permanent
kernel/vendor/device adaptation was needed for the retained image; the only
persistent display adjustment is in userdata and will be lost on data wipe.
