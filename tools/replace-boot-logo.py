#!/usr/bin/env python3
"""Replace entry 0 of an MTK logo image, preserving RGB pixels (requires Pillow)."""
import argparse
import hashlib
import json
import struct
import zlib
from pathlib import Path
from PIL import Image


def entries(data):
    assert struct.unpack_from('<I', data)[0] == 0x58881688, 'Not an MTK image'
    length = struct.unpack_from('<I', data, 4)[0]
    payload = data[512:512 + length]
    count, total = struct.unpack_from('<II', payload)
    assert count > 0 and total == length
    offsets = list(struct.unpack_from('<%dI' % count, payload, 8)) + [total]
    assert offsets[0] == 8 + 4 * count
    assert all(a < b for a, b in zip(offsets, offsets[1:]))
    chunks = [payload[offsets[i]:offsets[i + 1]] for i in range(count)]
    for chunk in chunks:
        dec = zlib.decompressobj()
        dec.decompress(chunk)
        dec.flush()
        assert dec.eof and not dec.unused_data, 'Invalid zlib entry'
    return chunks


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('original', type=Path)
    ap.add_argument('bmp', type=Path)
    ap.add_argument('output', type=Path)
    ap.add_argument('--manifest', type=Path)
    args = ap.parse_args()
    assert args.output.resolve() not in [args.original.resolve(), args.bmp.resolve()]
    original = args.original.read_bytes()
    chunks = entries(original)
    with Image.open(args.bmp) as src:
        assert src.format == 'BMP' and src.size == (1280, 800), 'Expected 1280x800 BMP; no resizing'
        rgb = src.convert('RGB')
    pixels = rgb.convert('RGBA').tobytes('raw', 'BGRA', 0, 1)
    assert len(zlib.decompress(chunks[0])) == len(pixels)
    changed = list(chunks)
    changed[0] = zlib.compress(pixels, 9)
    offsets = []
    length = 8 + 4 * len(changed)
    for chunk in changed:
        offsets.append(length)
        length += len(chunk)
    payload = struct.pack('<II', len(changed), length) + struct.pack('<%dI' % len(changed), *offsets) + b''.join(changed)
    header = bytearray(original[:512])
    struct.pack_into('<I', header, 4, length)
    output = bytes(header) + payload
    output += b'\0' * (-len(output) % 16)
    assert len(output) <= len(original), 'Image exceeds original partition dump'
    check = entries(output)
    assert check[1:] == chunks[1:], 'Unexpected change to non-boot entries'
    decoded = Image.frombytes('RGBA', rgb.size, zlib.decompress(check[0]), 'raw', 'BGRA').convert('RGB')
    assert decoded.tobytes() == rgb.tobytes(), 'RGB pixel mismatch'
    args.output.write_bytes(output)
    result = dict(source=str(args.original), bmp=str(args.bmp), output=str(args.output),
                  image_size=len(output), dimensions=list(rgb.size), changed_entries=[0],
                  preserved_entries=len(chunks)-1, rgb_pixels_identical=True,
                  source_sha256=hashlib.sha256(original).hexdigest(),
                  bmp_sha256=hashlib.sha256(args.bmp.read_bytes()).hexdigest(),
                  output_sha256=hashlib.sha256(output).hexdigest())
    if args.manifest:
        args.manifest.write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()
