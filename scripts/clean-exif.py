#!/usr/bin/env python3
"""Strip location and other personal metadata from JPEGs, in place and losslessly.

Used by add-photos.sh. The photo copies in content/photography/ are committed to
a public GitHub repository, so they must not carry the camera's GPS position.
All EXIF/XMP/IPTC metadata is removed (the image data itself is not re-encoded)
and replaced by a minimal EXIF block holding only:
  - the orientation (so portrait photos still display upright),
  - the date taken,
  - a copyright notice.
The colour profile (ICC) is kept.

Usage: clean-exif.py "Copyright notice" photo1.jpg [photo2.jpg ...]
Standard library only.
"""
import struct
import sys


def read_ifd0(tiff):
    """Return {tag: (type, count, value_bytes_or_offset_field)} for IFD0 plus the byte order."""
    order = "<" if tiff[:2] == b"II" else ">"
    (ifd_off,) = struct.unpack(order + "I", tiff[4:8])
    (n,) = struct.unpack(order + "H", tiff[ifd_off:ifd_off + 2])
    tags = {}
    for i in range(n):
        e = tiff[ifd_off + 2 + 12 * i: ifd_off + 14 + 12 * i]
        tag, typ, count = struct.unpack(order + "HHI", e[:8])
        tags[tag] = (typ, count, e[8:12])
    return order, tags


def exif_fields(app1):
    """Orientation (int) and DateTimeOriginal/DateTime (bytes) from an Exif APP1 payload."""
    tiff = app1[6:]
    orientation, date = 1, None
    try:
        order, ifd0 = read_ifd0(tiff)
        if 0x0112 in ifd0:
            orientation = struct.unpack(order + "H", ifd0[0x0112][2][:2])[0]
        # DateTimeOriginal lives in the Exif sub-IFD (pointer tag 0x8769).
        if 0x8769 in ifd0:
            (sub,) = struct.unpack(order + "I", ifd0[0x8769][2])
            (n,) = struct.unpack(order + "H", tiff[sub:sub + 2])
            for i in range(n):
                e = tiff[sub + 2 + 12 * i: sub + 14 + 12 * i]
                tag, typ, count = struct.unpack(order + "HHI", e[:8])
                if tag == 0x9003 and count >= 19:
                    (off,) = struct.unpack(order + "I", e[8:12])
                    date = tiff[off:off + 19]
        if date is None and 0x0132 in ifd0:
            typ, count, field = ifd0[0x0132]
            (off,) = struct.unpack(order + "I", field)
            date = tiff[off:off + 19]
    except (struct.error, IndexError):
        pass
    return orientation, date


def build_exif(orientation, date, notice):
    """Minimal big-endian Exif APP1 payload: Orientation, DateTime, Copyright."""
    entries = [(0x0112, 3, 1, struct.pack(">HH", orientation, 0))]
    blobs = []
    if date:
        blobs.append((0x0132, date + b"\0"))
    blobs.append((0x8298, notice.encode("ascii", "replace") + b"\0"))
    data_off = 8 + 2 + 12 * (len(entries) + len(blobs)) + 4
    data = b""
    for tag, blob in blobs:
        entries.append((tag, 2, len(blob), struct.pack(">I", data_off + len(data))))
        data += blob
    entries.sort()
    ifd = struct.pack(">H", len(entries))
    for tag, typ, count, field in entries:
        ifd += struct.pack(">HHI", tag, typ, count) + field
    ifd += struct.pack(">I", 0)
    return b"Exif\0\0" + b"MM\0*" + struct.pack(">I", 8) + ifd + data


def clean(path, notice):
    with open(path, "rb") as f:
        jpg = f.read()
    if jpg[:2] != b"\xff\xd8":
        raise ValueError(f"{path}: not a JPEG")
    pos, kept, orientation, date = 2, [], 1, None
    while pos < len(jpg):
        if jpg[pos] != 0xFF:
            raise ValueError(f"{path}: malformed JPEG")
        marker = jpg[pos + 1]
        if marker == 0xDA:  # start of scan: the rest is image data
            break
        (length,) = struct.unpack(">H", jpg[pos + 2:pos + 4])
        seg = jpg[pos:pos + 2 + length]
        payload = seg[4:]
        if marker == 0xE1:  # APP1: Exif or XMP
            if payload.startswith(b"Exif\0\0"):
                orientation, date = exif_fields(payload)
        elif marker == 0xED:  # APP13: Photoshop/IPTC (can hold location)
            pass
        elif marker == 0xE2 and payload.startswith(b"MPF\0"):  # iPhone HDR gain-map index
            pass
        else:
            kept.append(seg)
        pos += 2 + length
    exif = build_exif(orientation, date, notice)
    app1 = b"\xff\xe1" + struct.pack(">H", len(exif) + 2) + exif
    # Keep JFIF (APP0) first if present, then the new Exif block.
    if kept and kept[0][1] == 0xE0:
        head = kept[0] + app1 + b"".join(kept[1:])
    else:
        head = app1 + b"".join(kept)
    # Stop at the end of the main image: drop anything appended after it (e.g. an
    # iPhone HDR gain map, which is a second JPEG with its own metadata).
    # 0xFFD9 cannot occur inside JPEG image data, so the first one is the end.
    end = jpg.find(b"\xff\xd9", pos)
    end = len(jpg) if end < 0 else end + 2
    with open(path, "wb") as f:
        f.write(b"\xff\xd8" + head + jpg[pos:end])


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    for p in sys.argv[2:]:
        clean(p, sys.argv[1])
