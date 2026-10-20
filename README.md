# Benesse TAB-A04-BR3 (Challenge Pad 3) — AOSP 10 device tree

MediaTek MT8167, stock Android 7.0. Values of the stock firmware:
brand `benesse`, manufacturer `STS-TOTTORI`, device/name/board
`TAB-A04-BR3`, model `TAB-A03-BR3`.

This device tree corrects the stock model-name typo to `TAB-A04-BR3` in
both the AOSP product and its generated vendor product properties.
The corrected AOSP10 images were verified on the device: Settings shows
`TAB-A04-BR3`, the same model survives a normal reboot, and the updated recovery
provides ADB/root access and returns to normal boot. This build uses the public
PSI kernel #19 and its four matching connectivity modules. Bluetooth power-on
and two camera devices were observed; this check does not repeat the complete
hardware test suite.

The goal is a Treble vendor plus a pristine AOSP 10 system, so that a generic
system image (GSI) can replace system.

| Part | Source |
| --- | --- |
| system | AOSP `android-10.0.0_r47`, unmodified |
| kernel | [android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3) (MT8167 BSP kernel-4.14 + TAB-A04-BR3 drivers) |
| kernel binaries | `prebuilt/`: Image.gz-dtb and the MT6630 modules built from that repository (see `prebuilt/README.md`) |
| vendor binaries | [android_vendor_benesse_a04br3](https://github.com/mouseos/android_vendor_benesse_a04br3): MT8167 Android 10 BSP (MT8365_Q0_Ayla), `aiot8362am3_64_bsp` vendor build with the TAB-A04-BR3 MT6630 project values; listed in `proprietary-files.txt`, copied by `extract-files.sh`. BSP project values for that build: MT6630 connectivity and `CUSTOM_KERNEL_ACCELEROMETER = yes` in `ProjectConfig.mk` (MMA8652 accelerometer in `sensors.mt8167.so`) |
| /vendor/etc/init/hw, ueventd.rc, vintf | copied from that BSP vendor build, then adapted here |
| sepolicy/vendor/mediatek, mt8167 | BSP `device/mediatek/sepolicy/{basic,bsp}/non_plat`, `device/mediatek/mt8167/sepolicy/{basic,bsp}` (vendor side only) |

Partition sizes follow the GPT on the unit (factory removed, system 4112 MiB,
vendor 1 GiB, cache 512 MiB). The boot image uses the stock LK layout
(header v0, base 0x40000000, page 2048). The stock boot.img also has the
MediaTek mkimg headers on the kernel and ramdisk, the only layout the stock LK
has been seen to boot; `tools/mtk_wrap_bootimg.py` adds them to the AOSP
boot.img.

Board differences handled here: no nvdata partition (NVRAM bind-mounted from
/data/vendor/nvdata), the eMMC alias /dev/block/platform/bootdevice is created
in init.project.rc, display 800x1280 rotated 270 (density 160).

## Build

AOSP `android-10.0.0_r47` is used as is; nothing in the AOSP tree is patched.

```sh
repo init -u https://android.googlesource.com/platform/manifest -b android-10.0.0_r47
mkdir -p .repo/local_manifests
# write .repo/local_manifests/a04br3.xml (below)
repo sync -c -j8
source build/envsetup.sh
lunch aosp_a04br3-userdebug
m bootimage recoveryimage systemimage vendorimage
python3 device/benesse/a04br3/tools/mtk_wrap_bootimg.py "$OUT/boot.img" boot-a04br3.img
python3 device/benesse/a04br3/tools/mtk_wrap_bootimg.py --recovery "$OUT/recovery.img" recovery-a04br3.img
```

`.repo/local_manifests/a04br3.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="mouseos" fetch="https://github.com/mouseos/" />
  <project name="android_device_benesse_a04br3" path="device/benesse/a04br3" remote="mouseos" revision="main" />
  <project name="android_vendor_benesse_a04br3" path="vendor/benesse/a04br3" remote="mouseos" revision="main" />
  <!-- only needed to rebuild prebuilt/ -->
  <project name="android_kernel_benesse_TAB-A04-BR3" path="kernel/benesse/a04br3" remote="mouseos" revision="main" />
</manifest>
```

Host notes: the RenderScript clang of AOSP 10 needs `libncurses.so.5` and
`libtinfo.so.5` (Debian/Ubuntu package `libncurses5`; otherwise put the copies
in `prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/sysroot/usr/lib`
on `LD_LIBRARY_PATH`). `SKIP_ABI_CHECKS=true` skips the VNDK ABI dumps, which
only feed the ABI compatibility check.

Rebuilding the kernel with the toolchains of the same AOSP tree (writes
`prebuilt/`):

```sh
AOSP=$PWD kernel/benesse/a04br3/build-a04br3.sh device/benesse/a04br3
```

## Flash

Prebuilt images: https://github.com/mouseos/android_device_benesse_a04br3/releases
(`gpt.bin`, boot, recovery, system, vendor, `logo.bin`).

The GPT differs from the stock one (factory removed, system 4112 MiB, vendor
1 GiB, cache 512 MiB, eMMC of 30535680 sectors). With mtkclient, write the GPT
first, reconnect, then the partitions. mtkclient writes raw images, so convert
a sparse `system.img`/`vendor.img` with `simg2img` first.

```sh
mtk w gpt gpt.bin
mtk e userdata,cache
mtk w boot,recovery,system,vendor,logo boot-a04br3.img,recovery-a04br3.img,system.raw.img,vendor.raw.img,logo.bin
```

userdata and cache are formatted by init on first boot (fstab: formattable).

To replace only the boot logo, download `logo.bin` and run `mtk w logo logo.bin`.
This does not require changing the GPT or erasing userdata/cache.
The SmileTabLabo logo uses the supplied 1280x800 BMP with identical RGB pixels;
the other 38 logo resources are preserved.


## GSI compatibility policy and device result

Distributed GSI images must remain byte-for-byte unmodified: no filesystem,
property, signature or AVB/footer edits. AOSP and the reference BSP also
remain unpatched. Device adaptation belongs in the public device/vendor/kernel
repositories. Do not use the old locally modified GSI preparation workflow.

The official Android10 arm64 user image QJR1.191112.001/6004257 was tested
with SHA256 18a42a793798294183089e582c56bdf666e9d493523fb4389c6a3f7101ec6b60
verified on the actual written bytes before boot. It booted with SELinux
Enforcing; Settings interaction, Wi-Fi scan, Bluetooth power-on and two
camera service devices were observed. This is not a complete hardware
certification. The NVRAM invalid-MAC warning also occurs on the normal AOSP
and remains an existing board-data issue. See [device trial results](tools/gsi-unmodified/RESULTS.md).

The distributed Andy Yan LineageOS17.1 ARM64 system-as-root GSI also booted
and was left installed after a second successful reboot. Home, Settings,
Wi-Fi scanning, Bluetooth power-on and live camera preview were observed.
This trial used SELinux Permissive; the existing NVRAM warning remains.
See [LineageOS17.1 results and MTK fastboot procedure](tools/gsi-unmodified/LINEAGE17.md).

Newer distributed GSI observations are in [Android 11+ trials](tools/gsi-unmodified/NEWER-ANDROID.md).

Distributed OEM UI trials (Nippon, Erfan and Mystic) are recorded in [OEM UI results](tools/gsi-unmodified/OEM-UI.md); the earlier [MIUI13 trial](tools/gsi-unmodified/MIUI13.md) is recorded separately.

The requested [RestlessOS Android17 trial](tools/gsi-unmodified/RESTLESS17.md) reached ADB but failed framework boot with ashmem access denials.
