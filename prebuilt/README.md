# Prebuilt kernel

Built by `build-a04br3.sh` of
[android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3)
at commit eb47f42, `a04br3_defconfig`, with the
AOSP android-10.0.0_r47 toolchains (clang-r353983c, aarch64-linux-android-4.9).
Kernel release `4.14.141+`, build #19. PSI is enabled for modern userspace
memory-pressure monitoring. On-device Android 16 testing confirmed
/proc/pressure and lmkd running, with all four connectivity modules loaded.
This does not imply complete Android 16 hardware support.

- `Image.gz-dtb`: kernel with `a04br3.dtb` appended (boot.img kernel)
- `modules/`: MT6630 connectivity modules, installed to /vendor/lib/modules

Regenerate: `AOSP=<aosp top> kernel/benesse/a04br3/build-a04br3.sh device/benesse/a04br3`

```
ba5a6b70008769ccba58f3f1e09cb0c45930cc727795ff993dc62fd923b04b37  Image.gz-dtb
5f8689ddd7b6eee67b553dc2c9863a2e9dbbb2d3605b771cb73078e19a3db1b3  modules/bt_drv.ko
0ae33ae64270a2e3bd8d2053bedc47ae86f5da253d2d1e5311cb4c47a36166b0  modules/wlan_drv_gen3.ko
9255fc37cc821f1c3ac769d912a921e4884d77d7d0bd83e7f20f6617e69f34b8  modules/wmt_chrdev_wifi.ko
585b8a88ecfd833906dc845e3eba4c8c300d25437585e5605aa75c9a306c7624  modules/wmt_drv.ko
```
