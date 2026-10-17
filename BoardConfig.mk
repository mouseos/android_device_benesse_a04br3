DEVICE_PATH := device/benesse/a04br3

# Architecture (MT8167, 4x Cortex-A35; the BSP builds for cortex-a53)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a53
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

TARGET_BOARD_PLATFORM := mt8167
TARGET_BOOTLOADER_BOARD_NAME := TAB-A04-BR3
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Kernel: build_kernel.sh output (kernel-4.14 repository), stock LK image layout
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_OFFSET := 0x00080000
# The stock layout puts the ramdisk at 0x44000000, which leaves 4 MiB before
# the ram_console/pstore/minirdump areas at 0x44400000; the AOSP recovery
# ramdisk is larger. 0x47000000 is clear of those, of the LK staging buffer
# (0x45000000, image size), the LK logo buffer (0x4d000000) and the dtb
# (0x4e000000).
BOARD_RAMDISK_OFFSET := 0x07000000
BOARD_TAGS_OFFSET := 0x0e000000
BOARD_KERNEL_PAGESIZE := 2048
# The stock LK passes console=ttyMT0 (kernel-4.4 MTK UART driver); kernel-4.14
# names the same UART ttyS0 (8250_mtk). The later console= wins.
# The LK replaces the dtb bootargs with its own base line plus this cmdline, so
# the dtb-only firmware_class.path and loop.max_part are repeated here.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 console=ttyS0,921600n1 \
    androidboot.selinux=permissive androidboot.boot_devices=soc/11120000.mmc \
    firmware_class.path=/vendor/firmware loop.max_part=7
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_TAGS_OFFSET) \
    --header_version 0

# Partitions: GPT already on the unit (factory removed, system/vendor/cache
# relocated). Sizes in bytes.
BOARD_FLASH_BLOCK_SIZE := 4096
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
# AOSP recovery (replaces the stock Android 7 one), same fstab as the system
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt8167
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 4311744512
BOARD_VENDORIMAGE_PARTITION_SIZE := 1073741824
BOARD_CACHEIMAGE_PARTITION_SIZE := 536870912
BOARD_USERDATAIMAGE_PARTITION_SIZE := 9510060032
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS := metadata

# Android 10 first-stage init in the boot ramdisk; system.img keeps the root
# layout (system-as-root), so a generic system image can be used.
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false

# Treble
BOARD_VNDK_VERSION := current
PRODUCT_FULL_TREBLE_OVERRIDE := true
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/vintf/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/vintf/compatibility_matrix.xml

# Graphics (BSP mt8167 BoardConfig.mk)
TARGET_USES_HWC2 := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS := true

# Audio: the BSP vendor ships audio_policy_configuration.xml
USE_XML_AUDIO_POLICY_CONF := 1

# Wi-Fi: MT6630 through WMT. wpa_supplicant, hostapd, libwifi-hal and the
# Wi-Fi HAL come prebuilt from the BSP vendor (proprietary-files.txt), so
# BOARD_WLAN_DEVICE stays unset and AOSP does not rebuild them.

# SELinux: vendor policy of the BSP (non_plat parts only, so the system side
# stays AOSP and a GSI keeps working)
# The BSP non_plat policy refers to types that MediaTek declares in its
# system-side plat_public. The system here is plain AOSP, so those
# declarations come with the vendor policy, and neverallow checks (only
# allowed to be skipped on userdebug/eng) are not enforced at build time.
SELINUX_IGNORE_NEVERALLOWS := true
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/vendor/mediatek/basic/plat_public \
    $(DEVICE_PATH)/sepolicy/vendor/mediatek/bsp/plat_public \
    $(DEVICE_PATH)/sepolicy/vendor/mediatek/basic/non_plat \
    $(DEVICE_PATH)/sepolicy/vendor/mediatek/bsp/non_plat \
    $(DEVICE_PATH)/sepolicy/vendor/mt8167/basic \
    $(DEVICE_PATH)/sepolicy/vendor/mt8167/bsp \
    $(DEVICE_PATH)/sepolicy/vendor/board

# Vendor blobs extracted from the BSP build (extract-files.sh)
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_DUP_RULES := true
-include vendor/benesse/a04br3/BoardConfigVendor.mk
