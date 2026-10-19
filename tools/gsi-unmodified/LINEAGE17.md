# LineageOS 17.1 distributed GSI trial

Tested on TAB-A04-BR3 on 2026-10-19. The user requested leaving a working unofficial GSI installed instead of restoring AOSP. Userdata preservation was not required.

## Image and unchanged inputs

[Andy Yan distribution](https://sourceforge.net/projects/andyyan-gsi/files/lineage-17.x/):
`lineage-17.1-20210808-UNOFFICIAL-treble_arm64_bvS.img.xz`.
Android 10, ARM64, system-as-root, vanilla, includes PHH Superuser.

- XZ SHA256: `7749042ef4993ee45a85ff5db38acf94132fa459b76407b2a470d182b84982b7`.
- Extracted Android sparse SHA256: `9ec6dbe6eb647dd844a04c5c50f9e9409dac34af57ba3d5a4601fdd8d3db1972`.
- Raw, 1970069504 bytes: `3ca18c14f6c19ef747a43d3cadcbb4b6c16c856fbdd603117abcb349e89370fb`.

XZ decompression and `simg2img` are representation conversions only. No filesystem, property, signature, policy or AVB edits were made to the GSI. AOSP and the reference BSP were not patched. The existing USB-fixed kernel 4.14.141+ #18 boot and normal no-FM vendor were used. Recovery is the corrected v1.0 image.

## Installation and recovery

Use `fastboot -S 64M flash system <raw-image>`; the raw-to-sparse conversion writes zero blocks as FILL rather than leaving old bytes under distribution DONT_CARE ranges. Allow sufficient command time: the observed large transfer exceeded 180 seconds.

**This MTK LK uses `fastboot oem reboot-recovery`.** `fastboot reboot recovery` does not select recovery here. Prefer fastboot flashing when it is available. ADB recovery is available for inspection.

The host timeout interrupted the first full transfer during segment 29/30. UART confirmed segment 29 finished through logical block 0x74f28. Only the final 0x7a6 blocks were then sent as a sparse suffix containing bytes from the same raw image. Because there was an interrupted write, the final entire written raw prefix was read in recovery and matched the SHA above. Original boot was restored and verified before booting LineageOS.

Latest user instruction: do readback comparison when a trial fails or a write is abnormal; do not add mandatory full readback to every successful flash. Successful transfers should proceed directly to actual runtime testing.

A temporary vendor-only 300-second recovery guard was stopped after successful boot and its rc file removed. No GSI init or policy was changed. A subsequent normal reboot checks that the test service does not remain.

## Runtime observations

- `sys.boot_completed=1`, `ro.lineage.version=17.1-20210808-UNOFFICIAL-`.
- System fingerprint: `Android/treble_arm64_bvS/phhgsi_arm64_ab:10/QQ3A.200805.001/crossgate08081659:userdebug/test-keys`.
- Japanese initial setup completed; home and Settings screens rendered and accepted input. Timezone set to Asia/Tokyo. Diagnostic telemetry disabled in setup.
- Wi-Fi enabled and surrounding APs detected. No successful association or internet transfer is claimed.
- Bluetooth enabled, state ON; pairing/traffic untested.
- Camera service enumerated two cameras; the Camera app rendered a live preview. Still capture and video recording untested.
- AudioFlinger hardware status 0; playback/recording untested.
- SELinux **Permissive** under the existing boot configuration. This result is not an Enforcing compatibility result.
- ADB shell authentication uses the host public key stored in userdata. ADB root is disabled by the distribution's developer setting; the shipped PHH su worked for vendor guard cleanup.

Wi-Fi `NVRAM WARNING: Err = 0x10` remains. This is the driver's invalid stored MAC warning, not a real AP. It was also reproduced on normal AOSP and the official GSI before this trial; the saved MAC field was zero. AP scanning does not prove association or internet connectivity, and the warning has not been repaired.

## Excluded failed variant

The initial `arm64_avS` image was written correctly but failed at first-stage `SwitchRoot`: the required `/dev` under the new root did not exist. It was not a LineageOS success. `ro.build.system_root_image=false` alone was misleading: this Android 10 boot pivots to a system-as-root image. The distribution's `arm64_bvS` matches the actual boot requirement despite the board having one system partition. The image was replaced with the appropriate distributed variant, not edited to bypass the mismatch.

## Local evidence

`logs/flash.log` (fixed append-only flash log), `logs/uart-ttyUSB0-921600.log`, `logs/lineage17-sar-written-sha.txt`, `logs/lineage17-runtime/`, `logs/lineage17-final-state.txt`, and `analysis/lineage17-{home,settings,camera,final-home}.png` under port/gsi.

## Final state

A second normal reboot completed in about56seconds with the same LineageOS17.1 system, Japanese home, setup completion1, Asia/Tokyo, no gsi_trial_watch service property and no vendor guard rc. The device is left running this unofficial GSI. No return to official GSI or normal AOSP was performed.
