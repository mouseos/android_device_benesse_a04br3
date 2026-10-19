# AOSP product for Benesse TAB-A04-BR3 (Challenge Pad 3), MediaTek MT8167.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, device/benesse/a04br3/device.mk)

# Identify the actual product. Stock 01.06.000 incorrectly reports A03
# in ro.product.model, although its device/name/board identify A04.
PRODUCT_NAME := aosp_a04br3
PRODUCT_DEVICE := a04br3
PRODUCT_BRAND := benesse
PRODUCT_MANUFACTURER := STS-TOTTORI
PRODUCT_MODEL := TAB-A04-BR3
