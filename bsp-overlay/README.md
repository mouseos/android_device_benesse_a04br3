# BSP overlay for the vendor blob build

Files to place over the read-only MT8167 Android 10 BSP (MT8365_Q0_Ayla)
before building the vendor blobs that extract-files.sh copies.

- ProjectConfig.mk: TAB-A04-BR3 values (MT6630, CUSTOM_KERNEL_ACCELEROMETER = yes,
  HI556 main camera with dummy_lens)
- custom/mt8167/hal/imgsensor{,_metadata}/hi556_mipi_raw: HI556 HAL tuning and
  static metadata, derived from the BSP ov5675_mipi_raw (also 2592x1944 RAW),
  color filter GBRG (kernel driver outputs RAW_Gb)
- custom/mt8167/hal/imgsensor_src/sensorlist.cpp: HI556 entry

Build in the BSP: m camerahalserver sensors.mt8167 libcameracustom ... then
device/benesse/a04br3/extract-files.sh <BSP out/target/product/aiot8362am3_64_bsp>
