# Prebuilt kernel

Built by `build-a04br3.sh` of
[android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3)
at commit eaf6558, `a04br3_defconfig`, with the
AOSP android-10.0.0_r47 toolchains (clang-r353983c, aarch64-linux-android-4.9).
Kernel release `4.14.141+`.

- `Image.gz-dtb`: kernel with `a04br3.dtb` appended (boot.img kernel)
- `modules/`: MT6630 connectivity modules, installed to /vendor/lib/modules

Regenerate: `AOSP=<aosp top> kernel/benesse/a04br3/build-a04br3.sh device/benesse/a04br3`

```
d3aad1a862760ea311bc8a2e44b3d431df58f5d74e31dbab67e12bdf69f07cb2  Image.gz-dtb
5fae0dbcabce9afd99121fcbb6cf825dd8af82193ce452b87c74ed15dd02ff8c  modules/bt_drv.ko
fbf6e7ff5cf5ec4f6c5dc79b086b35d87663aba63441c6bee170e9f1bf1389da  modules/wlan_drv_gen3.ko
faff9fc4911298472d59d4ce8c4ec457a921ccb93fd8ed38f03700095f905b52  modules/wmt_chrdev_wifi.ko
fb7b8caf264d85e87cde357b66597fc901d86f17fddbaeac370642c00ad79da9  modules/wmt_drv.ko
```
