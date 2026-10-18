# Prebuilt kernel

Built by `build-a04br3.sh` of
[android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3)
at commit b239fec, `a04br3_defconfig`, with the
AOSP android-10.0.0_r47 toolchains (clang-r353983c, aarch64-linux-android-4.9).
Kernel release `4.14.141+`.

- `Image.gz-dtb`: kernel with `a04br3.dtb` appended (boot.img kernel)
- `modules/`: MT6630 connectivity modules, installed to /vendor/lib/modules

Regenerate: `AOSP=<aosp top> kernel/benesse/a04br3/build-a04br3.sh device/benesse/a04br3`

```
fa33fb9f1c49cc473c45e3777de0309bde1d8eebcca46d1d81ccdd9ec2e13542  Image.gz-dtb
5fae0dbcabce9afd99121fcbb6cf825dd8af82193ce452b87c74ed15dd02ff8c  modules/bt_drv.ko
42a4861c0cb22a447cd1024b9bd535acea1e840e43da47f2aff058c3c8879c74  modules/wlan_drv_gen3.ko
faff9fc4911298472d59d4ce8c4ec457a921ccb93fd8ed38f03700095f905b52  modules/wmt_chrdev_wifi.ko
fb7b8caf264d85e87cde357b66597fc901d86f17fddbaeac370642c00ad79da9  modules/wmt_drv.ko
```
