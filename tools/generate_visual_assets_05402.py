#!/usr/bin/env python3
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "visual_rework"
OUT.mkdir(parents=True, exist_ok=True)

ZW, ZH = 96, 128
IW, IH = 64, 64

PROFILES = [
    {"name":"errante","skin":"#8f9a78","shirt":"#5e6658","pants":"#3d443e","accent":"#6e3029","build":1.00},
    {"name":"corredor","skin":"#9ca77d","shirt":"#6d4b42","pants":"#34393a","accent":"#8f3028","build":0.92},
    {"name":"robusto","skin":"#858f72","shirt":"#4b5550","pants":"#333834","accent":"#71342c","build":1.18},
    {"name":"rural","skin":"#9a9270","shirt":"#74623d","pants":"#4f4936","accent":"#75362a","build":1.04},
    {"name":"operario","skin":"#8b9578","shirt":"#8a7540","pants":"#39434a","accent":"#7d332b","build":1.08},
]


def tag(name, attrs="", body=""):
    return f"<{name} {attrs}>{body}</{name}>" if body else f"<{name} {attrs}/>"


def ell(cx, cy, rx, ry, fill, stroke="#202524", sw=1.4, opacity=1.0):
    return tag("ellipse", f'cx="{cx:.1f}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" opacity="{opacity:.2f}"')


def rect(x, y, w, h, fill, stroke="#202524", sw=1.4, rx=2.0, opacity=1.0):
    return tag("rect", f'x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rx:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" opacity="{opacity:.2f}"')


def line(x1,y1,x2,y2,stroke,sw=3.0,opacity=1.0):
    return tag("line", f'x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{stroke}" stroke-width="{sw:.1f}" stroke-linecap="round" opacity="{opacity:.2f}"')


def poly(points, fill, stroke="#202524", sw=1.4, opacity=1.0):
    data = " ".join(f"{x:.1f},{y:.1f}" for x,y in points)
    return tag("polygon", f'points="{data}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" opacity="{opacity:.2f}"')


def path(d, fill="none", stroke="#202524", sw=1.4, opacity=1.0):
    return tag("path", f'd="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round" opacity="{opacity:.2f}"')


def zombie_cell(profile, frame):
    p = PROFILES[profile]
    phase = frame / 8.0 * math.tau
    swing = math.sin(phase) * 8.0
    bob = math.sin(phase * 2.0) * 1.6
    lean = 3.5 if profile == 1 else (-1.5 if profile == 2 else 1.5)
    cx = 48 + lean
    build = p["build"]
    torso_w = 25 * build
    parts = []
    parts.append(ell(48, 114, 24 * build, 5.5, "#000000", "none", 0, 0.30))
    # legs - asymmetric 8-frame walk cycle
    hip_y = 79 + bob
    parts.append(line(cx-7, hip_y, cx-9+swing*0.45, 108, p["pants"], 8.0*build))
    parts.append(line(cx+7, hip_y, cx+9-swing*0.45, 108, p["pants"], 8.0*build))
    parts.append(line(cx-10+swing*0.45, 108, cx-15+swing*0.58, 113, "#282c2c", 6.0))
    parts.append(line(cx+10-swing*0.45, 108, cx+15-swing*0.58, 113, "#282c2c", 6.0))
    # torso and torn shirt
    parts.append(poly([(cx-torso_w/2,47+bob),(cx+torso_w/2,48+bob),(cx+11*build,82+bob),(cx-12*build,82+bob)], p["shirt"]))
    parts.append(path(f"M{cx-torso_w/2+3:.1f} {58+bob:.1f} L{cx-3:.1f} {62+bob:.1f} L{cx-7:.1f} {71+bob:.1f}", "none", "#262c29", 2.2, .65))
    # arms
    shoulder_y = 52+bob
    parts.append(line(cx-torso_w/2+2, shoulder_y, cx-26-swing*0.50, 78+bob, p["skin"], 7.0))
    parts.append(line(cx+torso_w/2-2, shoulder_y, cx+27+swing*0.50, 75+bob, p["skin"], 7.0))
    parts.append(line(cx-26-swing*0.50, 78+bob, cx-23-swing*0.60, 89+bob, p["skin"], 5.0))
    parts.append(line(cx+27+swing*0.50, 75+bob, cx+30+swing*0.55, 86+bob, p["skin"], 5.0))
    # neck/head with profile variation
    head_y = 35+bob
    parts.append(rect(cx-4,43+bob,8,8,p["skin"],"#202524",1.0,2))
    parts.append(ell(cx, head_y, 10.5*build, 13.0, p["skin"]))
    parts.append(path(f"M{cx-7:.1f} {head_y-5:.1f} Q{cx:.1f} {head_y-11:.1f} {cx+8:.1f} {head_y-4:.1f}", "#34362f", "#202524", 1.2))
    # face and wounds
    parts.append(ell(cx-3.8, head_y-1.0, 1.4, 1.1, "#d6c98d", "none", 0))
    parts.append(ell(cx+4.0, head_y-0.5, 1.4, 1.1, "#d6c98d", "none", 0))
    parts.append(path(f"M{cx-4:.1f} {head_y+7:.1f} Q{cx:.1f} {head_y+10:.1f} {cx+5:.1f} {head_y+6:.1f}", "none", "#56231f", 2.0))
    wound_shift = [-6,7,0,-9,8][profile]
    parts.append(ell(cx+wound_shift, 62+bob, 4.3, 6.0, p["accent"], "#54231f", 1.0, .92))
    parts.append(path(f"M{cx+wound_shift-3:.1f} {58+bob:.1f} L{cx+wound_shift+4:.1f} {67+bob:.1f}", "none", "#b2634e", 1.2, .7))
    # role-specific readability
    if profile == 3:  # rural cap + suspenders
        parts.append(path(f"M{cx-10:.1f} {head_y-9:.1f} Q{cx:.1f} {head_y-15:.1f} {cx+9:.1f} {head_y-8:.1f} L{cx+15:.1f} {head_y-6:.1f}", p["shirt"], "#202524", 1.2))
        parts.append(line(cx-6,51+bob,cx-3,76+bob,"#b89d63",2.0,.8))
        parts.append(line(cx+6,51+bob,cx+3,76+bob,"#b89d63",2.0,.8))
    elif profile == 4:  # work vest/reflective stripe
        parts.append(line(cx-torso_w/2+2,59+bob,cx+torso_w/2-2,60+bob,"#d8c66b",3.0,.85))
        parts.append(rect(cx-11,49+bob,22,28,"none","#d8c66b",1.8,2,.65))
    elif profile == 2:  # robust torn jacket shoulder
        parts.append(ell(cx-14,52+bob,7,6,"#46504b","#202524",1.2))
        parts.append(ell(cx+14,52+bob,7,6,"#46504b","#202524",1.2))
    elif profile == 1:  # runner torn sports stripe
        parts.append(line(cx-9,52+bob,cx-5,76+bob,"#b69070",2.2,.7))
    # grime scratches
    parts.append(path(f"M{cx-9:.1f} {68+bob:.1f} L{cx-2:.1f} {65+bob:.1f} M{cx+3:.1f} {73+bob:.1f} L{cx+9:.1f} {70+bob:.1f}", "none", "#2f342f", 1.0, .55))
    return "".join(parts)


def item_icon(item_id):
    g=[]
    g.append(ell(32,53,20,4,"#000000","none",0,.20))
    if item_id == "machete":
        g += [path("M18 47 L42 17 L49 20 L29 51 Z", "#c7c9c2", "#252a29", 2), rect(18,43,13,7,"#6c432b","#252a29",1.5,2)]
    elif item_id == "axe":
        g += [line(22,51,42,17,"#744a2c",6), poly([(35,15),(51,18),(45,31),(31,27)],"#aeb4b0")]
    elif item_id == "spear":
        g += [line(16,52,45,20,"#7a5734",4), poly([(43,20),(51,11),(53,23)],"#b9bfba")]
    elif item_id == "pistol":
        g += [poly([(15,24),(47,24),(49,33),(34,34),(29,49),(20,47),(24,34),(15,33)],"#41494a"),rect(18,20,31,7,"#687073","#252a29",1.4,2)]
    elif item_id == "shotgun":
        g += [line(11,34,50,22,"#474e4e",6),line(31,29,51,42,"#765033",7),rect(11,29,16,8,"#765033","#252a29",1.2,2)]
    elif item_id == "bandage":
        g += [rect(14,23,36,23,"#e8e3d7","#9a978f",1.2,6),rect(27,18,10,33,"#f5f0e5","none",0,3),rect(14,30,36,9,"#f5f0e5","none",0,3)]
    elif item_id == "water":
        g += [path("M25 15 L39 15 L41 22 L44 47 Q32 54 20 47 L23 22 Z","#5e9fc2","#284b5b",1.6,.90),rect(27,11,10,7,"#d9e6e8","#40565d",1,2),path("M23 33 Q32 29 42 33","none","#c8e8f0",2,.8)]
    elif item_id == "food":
        g += [rect(15,19,34,31,"#9c6b3f","#4f3827",1.7,5),rect(18,22,28,8,"#d7ba76","none",0,3),path("M22 38 Q32 31 43 39","none","#d9c79b",3)]
    elif item_id == "antiseptic":
        g += [rect(20,20,24,31,"#7ba6a1","#38514f",1.5,5),rect(25,13,14,9,"#d3d5c8","#555c59",1.2,2),rect(24,31,16,9,"#ece9df","none",0,2),path("M32 32 L32 39 M28 35.5 L36 35.5","none","#b64a42",2)]
    elif item_id == "raw_game_meat":
        g += [path("M16 35 Q20 17 37 18 Q53 21 49 39 Q44 54 25 50 Q14 47 16 35 Z","#a4473d","#582b29",1.7),ell(36,30,7,5,"#d58d77","none",0,.8)]
    elif item_id == "cooked_game_meat":
        g += [path("M16 36 Q20 18 38 20 Q52 24 47 42 Q40 53 24 49 Q14 46 16 36 Z","#7a4327","#40271e",1.7),path("M22 31 Q34 25 44 32","none","#c3824c",2,.7)]
    elif item_id == "animal_hide":
        g += [path("M18 18 Q32 25 46 18 L42 31 L49 48 Q32 42 15 48 L22 31 Z","#8b6847","#4e3b2c",1.7),path("M23 28 Q32 33 41 28","none","#b79366",2,.6)]
    elif item_id == "feathers":
        g += [path("M17 48 Q20 19 43 14 Q43 35 21 49 Z","#d4d1c4","#6f756f",1.3),line(20,50,42,16,"#797a71",2),path("M25 40 L18 34 M30 34 L23 28 M35 28 L29 22","none","#8c8d82",1.2)]
    elif item_id == "wood":
        g += [rect(14,20,13,32,"#795333","#4b3324",1.5,5),rect(32,14,13,38,"#8b6040","#4b3324",1.5,5),line(18,26,24,45,"#b17b50",1.3),line(36,20,42,44,"#ba8458",1.3)]
    elif item_id == "stone":
        g += [poly([(14,43),(20,24),(36,16),(51,29),(47,47),(28,52)],"#777b78"),poly([(20,24),(36,16),(42,31),(28,36)],"#a1a39f","none",0,.8)]
    elif item_id == "fiber":
        g += [path("M19 49 Q23 23 31 15 M31 49 Q32 25 40 14 M42 49 Q41 28 49 21","none","#71894d",4),path("M23 31 Q15 25 18 20 M36 29 Q47 23 46 18 M41 38 Q51 34 53 29","none","#90a963",3)]
    return "".join(g)


def write_zombies():
    W,H=ZW*8,ZH*5
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
    for r in range(5):
        for f in range(8):
            out.append(f'<g transform="translate({f*ZW},{r*ZH})">{zombie_cell(r,f)}</g>')
    out.append('</svg>')
    p=OUT/'fdc_zombie_atlas_05402.svg'
    p.write_text(''.join(out),encoding='utf-8')
    print('WROTE',p,W,H,p.stat().st_size)


def write_items():
    ids=["machete","axe","spear","pistol","shotgun","bandage","water","food","antiseptic","raw_game_meat","cooked_game_meat","animal_hide","feathers","wood","stone","fiber"]
    W,H=IW*4,IH*4
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
    for i,item_id in enumerate(ids):
        x=(i%4)*IW; y=(i//4)*IH
        out.append(f'<g transform="translate({x},{y})">{item_icon(item_id)}</g>')
    out.append('</svg>')
    p=OUT/'fdc_item_atlas_05402.svg'
    p.write_text(''.join(out),encoding='utf-8')
    print('WROTE',p,W,H,p.stat().st_size)


if __name__ == '__main__':
    write_zombies()
    write_items()
