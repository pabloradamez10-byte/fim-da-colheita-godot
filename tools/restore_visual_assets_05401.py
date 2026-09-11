#!/usr/bin/env python3
import base64
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "visual_rework" / "generated"
OUT = ROOT / "assets" / "visual_rework"


def restore(prefix: str, filename: str, expected_size: tuple[int, int]) -> Path:
    parts = sorted(SRC.glob(f"{prefix}_*.b64"))
    if not parts:
        raise SystemExit(f"missing chunks for {prefix}")
    encoded = "".join(p.read_text(encoding="ascii").strip() for p in parts)
    raw = base64.b64decode(encoded, validate=True)
    if raw[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"invalid PNG signature for {filename}")
    width, height = struct.unpack(">II", raw[16:24])
    if (width, height) != expected_size:
        raise SystemExit(f"invalid dimensions for {filename}: {(width, height)} != {expected_size}")
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / filename
    path.write_bytes(raw)
    print(f"RESTORED {filename}: {width}x{height} {len(raw)} bytes from {len(parts)} chunks")
    return path


if __name__ == "__main__":
    restore("vehicle05401", "fdc_vehicle_atlas_05401.png", (704, 2640))
    restore("animal05401", "fdc_animal_atlas_05401.png", (1024, 512))
