# Prebuilt kernel

Built by `build-a04br3.sh` of
[android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3)
at commit 76ec3fb, `a04br3_defconfig`, with the
AOSP android-10.0.0_r47 toolchains (clang-r353983c, aarch64-linux-android-4.9).
Kernel release `4.14.141+`.

- `Image.gz-dtb`: kernel with `a04br3.dtb` appended (boot.img kernel)
- `modules/`: MT6630 connectivity modules, installed to /vendor/lib/modules

Regenerate: `AOSP=<aosp top> kernel/benesse/a04br3/build-a04br3.sh device/benesse/a04br3`

```
f6a909a47d3784b93237793c2988f3156dfc27608563489ac8cf4d0cbb16164d  Image.gz-dtb
5fae0dbcabce9afd99121fcbb6cf825dd8af82193ce452b87c74ed15dd02ff8c  modules/bt_drv.ko
65102f69a62d74a5a91c005340fe3a789d5ea2629131a8e4542f4f66ce04f797  modules/wlan_drv_gen3.ko
faff9fc4911298472d59d4ce8c4ec457a921ccb93fd8ed38f03700095f905b52  modules/wmt_chrdev_wifi.ko
fb7b8caf264d85e87cde357b66597fc901d86f17fddbaeac370642c00ad79da9  modules/wmt_drv.ko
```
