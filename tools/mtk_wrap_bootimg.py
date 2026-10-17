#!/usr/bin/env python3
"""Give the kernel and ramdisk of an AOSP v0 boot.img the 512-byte MediaTek
mkimg headers (KERNEL / ROOTFS) that the stock TAB-A04-BR3 boot.img has.

  mtk_wrap_bootimg.py <out>/boot.img <flashable boot.img>

The header layout is that of the stock 02.00.000 OTA boot.img: magic
0x58881688, payload size, section name (32 bytes), then 0xff up to 512 bytes.
Every boot image header field except the two section sizes and the id is
kept from the input image.
"""
import argparse
import hashlib
import struct
from pathlib import Path

MAGIC = 0x58881688


def mtk_header(name: bytes, size: int) -> bytes:
    return struct.pack("<II32s", MAGIC, size, name) + b"\xff" * 472


def pad(data: bytes, page: int) -> bytes:
    return data + b"\0" * (-len(data) % page)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("input", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    img = args.input.read_bytes()
    if img[:8] != b"ANDROID!":
        raise SystemExit("not an Android boot image")
    ksz, _, rsz, _, ssz, _, _, page, version = struct.unpack_from("<9I", img, 8)
    if version != 0 or ssz != 0:
        raise SystemExit("expected a v0 boot image without a second stage")
    roff = page + ksz + (-ksz % page)
    kernel, ramdisk = img[page:page + ksz], img[roff:roff + rsz]
    for data, kind in ((kernel, "kernel"), (ramdisk, "ramdisk")):
        if struct.unpack_from("<I", data)[0] == MAGIC:
            raise SystemExit(f"{kind} already has an MTK header")
    kernel = mtk_header(b"KERNEL", len(kernel)) + kernel
    ramdisk = mtk_header(b"ROOTFS", len(ramdisk)) + ramdisk
    hdr = bytearray(img[:page])
    struct.pack_into("<I", hdr, 8, len(kernel))
    struct.pack_into("<I", hdr, 16, len(ramdisk))
    sha = hashlib.sha1()
    for blob in (kernel, ramdisk, b""):
        sha.update(blob)
        sha.update(struct.pack("<I", len(blob)))
    hdr[576:608] = sha.digest().ljust(32, b"\0")
    args.output.write_bytes(bytes(hdr) + pad(kernel, page) + pad(ramdisk, page))
    print(f"{args.output}: kernel={len(kernel):#x} ramdisk={len(ramdisk):#x}")


if __name__ == "__main__":
    main()
