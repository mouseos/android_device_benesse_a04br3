# Benesse TAB-A04-BR3 (Challenge Pad 3) — AOSP 10 device tree

MediaTek MT8167, stock Android 7.0. Values of the stock firmware:
brand `benesse`, manufacturer `STS-TOTTORI`, device/name/board
`TAB-A04-BR3`, model `TAB-A03-BR3`.

The goal is a Treble vendor plus a pristine AOSP 10 system, so that a generic
system image (GSI) can replace system.

| Part | Source |
| --- | --- |
| system | AOSP `android-10.0.0_r47`, unmodified |
| kernel | [android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3) (MT8167 BSP kernel-4.14 + TAB-A04-BR3 drivers) |
| vendor binaries | MT8167 Android 10 BSP (MT8365_Q0_Ayla), `aiot8362am3_64_bsp` vendor build with the TAB-A04-BR3 MT6630 project values; listed in `proprietary-files.txt`, copied by `extract-files.sh` |
| /vendor/etc/init/hw, ueventd.rc, vintf | copied from that BSP vendor build, then adapted here |
| sepolicy/vendor/mediatek, mt8167 | BSP `device/mediatek/sepolicy/{basic,bsp}/non_plat`, `device/mediatek/mt8167/sepolicy/{basic,bsp}` (vendor side only) |

Partition sizes follow the GPT on the unit (factory removed, system 4112 MiB,
vendor 1 GiB, cache 512 MiB). The boot image uses the stock LK layout
(header v0, base 0x40000000, page 2048); the stock LK accepts images with or
without the MediaTek mkimg headers.

Board differences handled here: no nvdata partition (NVRAM bind-mounted from
/data/vendor/nvdata), the eMMC alias /dev/block/platform/bootdevice is created
in init.project.rc, display 800x1280 rotated 270 (density 160).
