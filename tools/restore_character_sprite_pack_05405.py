#!/usr/bin/env python3
from pathlib import Path
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
archive = ROOT / "assets" / "characters" / "generated" / "fdc_character_pack_05405.zip"
target = ROOT / "assets" / "characters" / "player" / "sprite_pack_05405"

if not archive.is_file():
    raise SystemExit(f"Arquivo ausente: {archive}")

if target.exists():
    shutil.rmtree(target)
target.mkdir(parents=True, exist_ok=True)

with zipfile.ZipFile(archive, "r") as zf:
    zf.extractall(target)

required = [
    "idle_8dir.png", "walk_8dir.png",
    "melee_1h_8dir.png", "melee_2h_8dir.png",
    "firearm_1h_8dir.png", "firearm_2h_8dir.png",
    "bow_8dir.png", "harvest_animal_8dir.png",
    "manifest.json",
]
missing = [name for name in required if not (target / name).is_file()]
if missing:
    raise SystemExit("Assets ausentes após extração: " + ", ".join(missing))

print(f"0.5.40.5 character sprite pack restaurado em {target}")
