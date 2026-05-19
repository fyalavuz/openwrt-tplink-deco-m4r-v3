#!/usr/bin/env python3
import os
import socket
import struct
import sys
import time


ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "artifacts")
DEFAULT_BLKSIZE = 512


def parse_rrq(payload):
    parts = payload[2:].split(b"\0")
    parts = [p for p in parts if p]
    if len(parts) < 2:
        raise ValueError("malformed RRQ")
    filename = parts[0].decode("utf-8", "replace").lstrip("/")
    mode = parts[1].decode("ascii", "replace").lower()
    opts = {}
    for i in range(2, len(parts) - 1, 2):
        opts[parts[i].decode("ascii", "replace").lower()] = parts[i + 1].decode("ascii", "replace")
    return filename, mode, opts


def send_error(sock, addr, code, message):
    sock.sendto(struct.pack("!HH", 5, code) + message.encode() + b"\0", addr)


def wait_ack(sock, addr, block, timeout=2.0):
    end = time.time() + timeout
    while time.time() < end:
        sock.settimeout(max(0.1, end - time.time()))
        try:
            data, peer = sock.recvfrom(2048)
        except socket.timeout:
            return False
        if peer != addr or len(data) < 4:
            continue
        opcode, ack_block = struct.unpack("!HH", data[:4])
        if opcode == 4 and ack_block == block:
            return True
    return False


def serve_file(sock, addr, path, opts):
    blksize = DEFAULT_BLKSIZE
    if "blksize" in opts:
        try:
            blksize = max(8, min(int(opts["blksize"]), 1468))
        except ValueError:
            blksize = DEFAULT_BLKSIZE
        oack = b"blksize\0" + str(blksize).encode() + b"\0"
        sock.sendto(struct.pack("!H", 6) + oack, addr)
        if not wait_ack(sock, addr, 0):
            raise TimeoutError("no ACK for OACK")

    size = os.path.getsize(path)
    print(f"RRQ {os.path.basename(path)} from {addr[0]}:{addr[1]} ({size} bytes, blksize={blksize})", flush=True)
    with open(path, "rb") as f:
        block = 1
        sent = 0
        while True:
            chunk = f.read(blksize)
            packet = struct.pack("!HH", 3, block) + chunk
            for attempt in range(8):
                sock.sendto(packet, addr)
                if wait_ack(sock, addr, block):
                    break
            else:
                raise TimeoutError(f"no ACK for block {block}")

            sent += len(chunk)
            if block % 512 == 0 or len(chunk) < blksize:
                print(f"sent {sent}/{size}", flush=True)
            if len(chunk) < blksize:
                print("transfer complete", flush=True)
                return
            block = (block + 1) & 0xFFFF


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", 69))
    print(f"TFTP listening on 0.0.0.0:69, root={ROOT}", flush=True)
    while True:
        sock.settimeout(None)
        data, addr = sock.recvfrom(4096)
        if len(data) < 2:
            continue
        opcode = struct.unpack("!H", data[:2])[0]
        if opcode != 1:
            continue
        try:
            filename, mode, opts = parse_rrq(data)
            path = os.path.abspath(os.path.join(ROOT, filename))
            if not path.startswith(ROOT + os.sep) or not os.path.isfile(path):
                send_error(sock, addr, 1, "file not found")
                print(f"missing {filename} for {addr}", flush=True)
                continue
            if mode not in ("octet", "binary"):
                send_error(sock, addr, 0, "unsupported mode")
                continue
            serve_file(sock, addr, path, opts)
        except Exception as exc:
            print(f"error: {exc}", flush=True)


if __name__ == "__main__":
    main()
