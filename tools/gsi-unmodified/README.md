# Unmodified distributed GSI compatibility control

The GSI must remain byte-for-byte identical to its distribution. Do not
change filesystem contents, properties, mountpoints, signatures or AVB.
Do not use the old locally modified system-gsi-android10.img workflow.
Do not build a replacement GSI. Keep AOSP and the reference BSP unmodified.

Input: aosp_arm64-exp-QJR1.191112.001-6004257.zip, Android10 arm64 user.
Extracted system.img is 1498497024 bytes, SHA256:
18a42a793798294183089e582c56bdf666e9d493523fb4389c6a3f7101ec6b60
Use port/gsi/gsi/android10-aosp-arm64-system.img and verify this digest
before and after testing, including the written partition prefix.
The board has no vbmeta partition; do not invent one or edit the GSI footer.

Before flashing, preserve boot, recovery, system, vendor, misc/para and
userdata. Check the backup sizes and hashes. When streaming with adb
exec-out, redirect remote dd stderr on-device: otherwise its statistics
are appended to the binary stream. Back up userdata offline in recovery.
A static ARM64 lz4 CLI built from unmodified external/lz4 in AOSP r47 may
compress the backup stream without requiring software inside the GSI.

Use the released USB-fixed v1.0 recovery (SHA256
4caa7b7f0c9a3fa3c4d0143aecb9b8196798749b990a5680d34aea1a12c0c0f8).
Validate recovery USB/root control before replacing system.
trial-watch.rc is a TEMPORARY vendor test harness. It launches the standard
shell domain, then requests reboot,recovery after 240 seconds; it edits
neither GSI nor its SELinux policy. First validate this path on the original
AOSP with a 60-second deadline. Remove it after testing. A failure before
second-stage init can prevent this service from starting; keep UART and
preloader recovery available. An armed service alone is not verified recovery.

Record UART continuously to port/gsi/logs/uart-ttyUSB0-921600.log.
Append all mtkclient/flash output to port/gsi/logs/flash.log.
Evaluate actual boot completion, display/input and required vendor services;
static compatibility checks alone are insufficient. If incompatible, retain
the evidence and restore the normal AOSP rather than editing the GSI.
