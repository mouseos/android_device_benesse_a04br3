DEVICE_PATH := device/benesse/a04br3

$(call inherit-product, $(DEVICE_PATH)/vendor_props.mk)
$(call inherit-product-if-exists, vendor/benesse/a04br3/a04br3-vendor.mk)

PRODUCT_SHIPPING_API_LEVEL := 24
PRODUCT_CHARACTERISTICS := tablet
PRODUCT_AAPT_CONFIG := normal mdpi
PRODUCT_AAPT_PREF_CONFIG := mdpi

# Kernel (build_kernel.sh, kernel-4.14 repository) and its MT6630
# connectivity modules; AOSP takes the boot image kernel from $(PRODUCT_OUT)/kernel
PRODUCT_COPY_FILES += $(DEVICE_PATH)/prebuilt/Image.gz-dtb:kernel

# Keymaster: the BSP's MTEE keymaster 4.0 needs a TEE application that the
# unit's stock (Android 7) TEE firmware does not have; it aborts with
# "Could not Initialize for MTEEKeymaster 4.0 (-65526)". Use the AOSP
# software keymaster 4.0 instead.
PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service

PRODUCT_COPY_FILES += \
    $(foreach m,$(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko),$(m):$(TARGET_COPY_OUT_VENDOR)/lib/modules/$(notdir $(m)))

# fstab for first-stage init and for mount_all
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/fstab.mt8167:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt8167 \
    $(DEVICE_PATH)/rootdir/etc/fstab.mt8167:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt8167

# init (BSP /vendor/etc/init/hw + board rc) and ueventd
PRODUCT_COPY_FILES += \
    $(foreach f,$(wildcard $(DEVICE_PATH)/rootdir/etc/init/hw/*.rc),$(f):$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/$(notdir $(f))) \
    $(DEVICE_PATH)/rootdir/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc

# Display: 800x1280 panel mounted at 270 degrees (stock: hwrotation 270, density 160)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=160 \
    ro.sf.hwrotation=270 \
    ro.surface_flinger.primary_display_orientation=ORIENTATION_270
