#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""给 Mach-O 加一条 LC_LOAD_DYLIB，替代 insert_dylib。
用法: inject_dylib.py <binary> <dylib_install_name>
"""
import struct
import sys

LC_LOAD_DYLIB = 0xC


def align8(n):
    return (n + 7) & ~7


def main():
    if len(sys.argv) < 3:
        print("usage: inject_dylib.py <macho> <install_name>")
        return 2
    path, name = sys.argv[1], sys.argv[2]
    data = bytearray(open(path, "rb").read())

    magic = struct.unpack("<I", data[:4])[0]
    if magic != 0xFEEDFACF:
        print("not a 64-bit little-endian Mach-O: %#x" % magic)
        return 1

    ncmds = struct.unpack("<I", data[16:20])[0]
    sizeofcmds = struct.unpack("<I", data[20:24])[0]
    print("ncmds=%d sizeofcmds=%#x" % (ncmds, sizeofcmds))

    # 已经注入过就跳过
    name_b = name.encode() + b"\x00"
    if name_b in data[:32 + sizeofcmds]:
        print("already injected")
        return 0

    cmd_size = align8(24 + len(name_b))
    cmd = struct.pack("<IIIIII", LC_LOAD_DYLIB, cmd_size, 24, 2, 0, 0)
    cmd += name_b
    cmd += b"\x00" * (cmd_size - len(cmd))

    # load commands 之后的空白：定位第一个 section 的文件偏移
    text_off = None
    off = 32
    for _ in range(ncmds):
        c, cs = struct.unpack("<I I", data[off:off + 8])
        if c == 0x19:  # LC_SEGMENT_64
            segname = bytes(data[off + 8:off + 24]).rstrip(b"\x00").decode(errors="replace")
            fileoff = struct.unpack("<Q", data[off + 40:off + 48])[0]
            if segname == "__TEXT":
                text_off = fileoff
                break
        off += cs
    limit = text_off if text_off else 0x4000
    write_at = 32 + sizeofcmds
    if write_at + cmd_size > limit:
        print("no room: need %d bytes, only %d free" % (cmd_size, limit - write_at))
        return 1

    data[write_at:write_at + cmd_size] = cmd
    struct.pack_into("<I", data, 16, ncmds + 1)
    struct.pack_into("<I", data, 20, sizeofcmds + cmd_size)

    open(path, "wb").write(data)
    print("injected %s (%d bytes) at %#x, ncmds=%d sizeofcmds=%#x"
          % (name, cmd_size, write_at, ncmds + 1, sizeofcmds + cmd_size))
    return 0


if __name__ == "__main__":
    sys.exit(main())
