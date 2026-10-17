# Prebuilt kernel

Built by `build-a04br3.sh` of
[android_kernel_benesse_TAB-A04-BR3](https://github.com/mouseos/android_kernel_benesse_TAB-A04-BR3)
at commit a5b699c, `a04br3_defconfig`, with the
AOSP android-10.0.0_r47 toolchains (clang-r353983c, aarch64-linux-android-4.9).
Kernel release `4.14.141+`.

- `Image.gz-dtb`: kernel with `a04br3.dtb` appended (boot.img kernel)
- `modules/`: MT6630 connectivity modules, installed to /vendor/lib/modules

Regenerate: `AOSP=<aosp top> kernel/benesse/a04br3/build-a04br3.sh device/benesse/a04br3`

```
eb01aec4cd3ca2b149f0ddb4c2776a49d79c3cf22cf9f84a582dcb102af057be  Image.gz-dtb
5fae0dbcabce9afd99121fcbb6cf825dd8af82193ce452b87c74ed15dd02ff8c  modules/bt_drv.ko
9d6854f662e903e142b7f5f91a70c4748a69bd8f4f878dc27808c89200b7b781  modules/wlan_drv_gen3.ko
faff9fc4911298472d59d4ce8c4ec457a921ccb93fd8ed38f03700095f905b52  modules/wmt_chrdev_wifi.ko
fb7b8caf264d85e87cde357b66597fc901d86f17fddbaeac370642c00ad79da9  modules/wmt_drv.ko
```
