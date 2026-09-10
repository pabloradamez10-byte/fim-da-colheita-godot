#!/usr/bin/env python3
# Generates the engine-safe 40-vehicle x 8-direction atlas for Alpha 0.5.36.2.
# Pure Python/std-lib: deterministic, no external art dependency during CI.
import math, random, struct, zlib, sys
from pathlib import Path

CELL_W, CELL_H = 64, 48
COLS, ROWS = 8, 40
W, H = CELL_W * COLS, CELL_H * ROWS
OUT = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/vehicles/fdc_vehicle_atlas_05362.png")

NAMES = [
    "Compacto claro","Sedã verde","Perua utilitária","Picape branca","Furgão urbano","Caminhão baú",
    "SUV vermelho","Trator agrícola","Carcaça queimada","Utilitário branco","Utilitário vermelho","Micro-ônibus",
    "Viatura policial","Ambulância","Caminhão carroceria","Caminhão rural","Caminhão-tanque","Colheitadeira",
    "Moto trail vermelha","Moto trail verde","Scooter","Bicicleta","Picape vermelha","SUV expedição verde",
    "SUV expedição clara","Caminhão pequeno azul","Furgão de carga claro","Hatch antigo bege","Sedã compacto prata",
    "Hatch urbano azul","Coupé clássico marrom","Picape 4x4 azul","Picape expedição preta","Furgão clássico de passageiros",
    "Ônibus intermunicipal","Carreta baú","Caminhão leiteiro","Trator vermelho clássico","Colheitadeira verde","Moto utilitária preta"
]
CATS = [
    "car","car","wagon","pickup","van","box_truck","suv","tractor","wreck","suv","suv","minibus",
    "police","ambulance","stake_truck","stake_truck","tanker","harvester","motorcycle","motorcycle","scooter","bicycle",
    "pickup","suv","suv","stake_truck","van","car","car","car","car","pickup","pickup","van","bus","semi_truck",
    "tanker","tractor","harvester","motorcycle"
]
COLORS = [
    (214,202,172),(98,128,94),(176,165,126),(215,210,190),(135,145,128),(182,177,160),(143,66,51),(164,67,40),
    (67,55,46),(203,205,194),(151,62,50),(173,170,146),(72,94,115),(213,213,199),(135,101,65),(116,95,61),
    (150,155,149),(105,111,72),(137,58,45),(70,107,67),(121,116,102),(86,83,73),(157,59,47),(77,100,69),
    (202,191,157),(78,102,123),(203,197,169),(173,151,112),(171,175,170),(78,112,143),(115,76,54),(75,105,139),
    (55,58,55),(194,184,153),(205,169,83),(192,189,178),(171,175,169),(152,57,39),(91,108,58),(50,52,49)
]

px = bytearray(W * H * 4)

def setpx(x,y,c):
    if 0 <= x < W and 0 <= y < H:
        i=(y*W+x)*4
        px[i:i+4]=bytes(c)

def blendpx(x,y,c,a=1.0):
    if not (0 <= x < W and 0 <= y < H): return
    i=(y*W+x)*4
    oa=px[i+3]/255.0; na=max(0.0,min(1.0,a))
    outa=na+oa*(1-na)
    if outa <= 0: return
    for k in range(3): px[i+k]=int((c[k]*na + px[i+k]*oa*(1-na))/outa)
    px[i+3]=int(outa*255)

def polygon(points,c,a=1.0):
    ys=[p[1] for p in points]
    y0=max(0,int(math.floor(min(ys)))); y1=min(H-1,int(math.ceil(max(ys))))
    n=len(points)
    for y in range(y0,y1+1):
        scan=y+0.5; xs=[]
        for i in range(n):
            x1,y1p=points[i]; x2,y2p=points[(i+1)%n]
            if (y1p <= scan < y2p) or (y2p <= scan < y1p):
                xs.append(x1+(scan-y1p)*(x2-x1)/(y2p-y1p))
        xs.sort()
        for j in range(0,len(xs)-1,2):
            xa=max(0,int(math.ceil(xs[j]))); xb=min(W-1,int(math.floor(xs[j+1])))
            for x in range(xa,xb+1): blendpx(x,y,c,a)

def circle(cx,cy,r,c,a=1.0):
    for y in range(int(cy-r),int(cy+r)+1):
        for x in range(int(cx-r),int(cx+r)+1):
            if (x-cx)**2+(y-cy)**2 <= r*r: blendpx(x,y,c,a)

def rotpt(cx,cy,lx,ly,ang,ys=0.70):
    ca,sa=math.cos(ang),math.sin(ang)
    return (cx + lx*ca-ly*sa, cy + (lx*sa+ly*ca)*ys)

def rectpoly(cx,cy,length,width,ang,ys=0.70,offx=0,offy=0):
    return [rotpt(cx,cy,offx+sx*length/2,offy+sy*width/2,ang,ys) for sx,sy in [(-1,-1),(1,-1),(1,1),(-1,1)]]

def shade(c,f): return tuple(max(0,min(255,int(v*f))) for v in c)
def lighten(c,f): return tuple(max(0,min(255,int(v+(255-v)*f))) for v in c)

def line(a,b,r,c,a1=1.0):
    x0,y0=a; x1,y1=b; steps=max(1,int(max(abs(x1-x0),abs(y1-y0))*2))
    for i in range(steps+1):
        t=i/steps; circle(x0+(x1-x0)*t,y0+(y1-y0)*t,r,c,a1)

def vehicle_dims(cat):
    return {
        "car":(34,17),"wagon":(38,18),"pickup":(39,19),"van":(39,20),"suv":(37,20),"wreck":(35,18),
        "minibus":(43,21),"police":(37,19),"ambulance":(41,21),"box_truck":(45,21),"stake_truck":(44,21),
        "tanker":(46,21),"tractor":(32,22),"harvester":(41,28),"motorcycle":(27,7),"scooter":(23,8),
        "bicycle":(25,5),"bus":(50,22),"semi_truck":(52,22)
    }.get(cat,(36,18))

def draw_wheels(cx,cy,L,B,ang,cat):
    if cat in ("motorcycle","scooter","bicycle"):
        for lx in (-L*.36,L*.36):
            x,y=rotpt(cx,cy,lx,0,ang)
            circle(x,y,3.0 if cat!="bicycle" else 3.4,(25,24,22),.95)
            circle(x,y,1.8 if cat!="bicycle" else 2.5,(111,103,87),.9)
        return
    if cat=="harvester":
        poss=[(-L*.22,-B*.42),(-L*.22,B*.42),(L*.25,-B*.42),(L*.25,B*.42)]
        rr=4.0
    elif cat=="tractor":
        poss=[(-L*.28,-B*.43),(-L*.28,B*.43),(L*.30,-B*.40),(L*.30,B*.40)]
        rr=4.0
    else:
        poss=[(-L*.30,-B*.48),(-L*.30,B*.48),(L*.30,-B*.48),(L*.30,B*.48)]
        rr=2.6
    for lx,ly in poss:
        x,y=rotpt(cx,cy,lx,ly,ang)
        circle(x,y,rr,(24,23,21),.98); circle(x,y,max(1,rr*.44),(90,83,69),1)

def draw_cell(v,d):
    ox=d*CELL_W; oy=v*CELL_H; cx=ox+CELL_W/2; cy=oy+CELL_H/2+1
    cat=CATS[v]; base=COLORS[v]; ang=d*math.pi/4
    L,B=vehicle_dims(cat)
    rng=random.Random(53062000+v*97+d*11)
    # soft grounding shadow
    polygon([(x+2,y+3) for x,y in rectpoly(cx,cy,L+5,B+4,ang)],(8,8,7),.38)
    if cat=="bicycle":
        draw_wheels(cx,cy,L,B,ang,cat)
        p1=rotpt(cx,cy,-5,0,ang); p2=rotpt(cx,cy,5,0,ang); p3=rotpt(cx,cy,0,-4,ang)
        line(p1,p2,1,(105,92,72)); line(p1,p3,1,(105,92,72)); line(p2,p3,1,(105,92,72)); return
    if cat in ("motorcycle","scooter"):
        draw_wheels(cx,cy,L,B,ang,cat)
        line(rotpt(cx,cy,-7,0,ang),rotpt(cx,cy,8,0,ang),2.0,base)
        polygon(rectpoly(cx,cy,10,5,ang,offx=1),lighten(base,.12),1)
        circle(*rotpt(cx,cy,-2,0,ang),2.2,(35,35,33),1)
        return
    draw_wheels(cx,cy,L,B,ang,cat)
    body=rectpoly(cx,cy,L,B,ang)
    polygon(body,shade(base,.72),1)
    # body inner panel creates painted bevel
    polygon(rectpoly(cx,cy,L-3,B-3,ang),base,1)
    # category-specific silhouette
    if cat in ("box_truck","stake_truck","tanker","semi_truck"):
        cab_len=15 if cat!="semi_truck" else 16
        cargo_len=L-cab_len-2
        polygon(rectpoly(cx,cy,cab_len,B-3,ang,offx=-L/2+cab_len/2+1),lighten(base,.08),1)
        # windshield
        polygon(rectpoly(cx,cy,5,B-7,ang,offx=-L/2+cab_len-3),(43,57,59),.95)
        if cat=="tanker":
            # rounded tank impression
            polygon(rectpoly(cx,cy,cargo_len,B-5,ang,offx=7),lighten((157,157,149),.18),1)
            for k in (-5,0,5): line(rotpt(cx,cy,7+k,-(B-5)/2,ang),rotpt(cx,cy,7+k,(B-5)/2,ang),.6,(95,91,80),.8)
        elif cat=="stake_truck":
            polygon(rectpoly(cx,cy,cargo_len,B-5,ang,offx=7),shade(base,.58),1)
            for k in range(-6,10,5): line(rotpt(cx,cy,7+k,-(B-5)/2,ang),rotpt(cx,cy,7+k,(B-5)/2,ang),.55,(81,58,39),.95)
        else:
            polygon(rectpoly(cx,cy,cargo_len,B-4,ang,offx=7),lighten(base,.16),1)
            line(rotpt(cx,cy,7,-(B-4)/2,ang),rotpt(cx,cy,7,(B-4)/2,ang),.5,shade(base,.55),.8)
    elif cat in ("van","minibus","bus","ambulance"):
        polygon(rectpoly(cx,cy,L-7,B-5,ang,offx=1),lighten(base,.08),1)
        # side glass band
        polygon(rectpoly(cx,cy,L-13,B-9,ang,offx=-1),(42,56,58),.92)
        for k in (-8,0,8):
            if abs(k) < L/2-5: line(rotpt(cx,cy,k,-(B-9)/2,ang),rotpt(cx,cy,k,(B-9)/2,ang),.45,(133,126,108),.9)
        if cat=="ambulance":
            # red emergency stripe/light
            line(rotpt(cx,cy,-2,-B*.48,ang),rotpt(cx,cy,9,-B*.48,ang),1.2,(150,43,37),.95)
            circle(*rotpt(cx,cy,-4,0,ang),1.4,(183,45,41),1)
    elif cat=="harvester":
        polygon(rectpoly(cx,cy,L-12,B-8,ang,offx=2),lighten(base,.06),1)
        # large front header
        a=rotpt(cx,cy,-L*.48,-B*.63,ang); b=rotpt(cx,cy,-L*.48,B*.63,ang)
        line(a,b,1.8,shade(base,.48),1)
        for q in (-.45,-.22,0,.22,.45):
            line(rotpt(cx,cy,-L*.50,q*B,ang),rotpt(cx,cy,-L*.62,q*B,ang),.65,(70,62,45),1)
        polygon(rectpoly(cx,cy,11,B-9,ang,offx=-6),(45,62,57),.9)
    elif cat=="tractor":
        polygon(rectpoly(cx,cy,13,B-6,ang,offx=-4),(45,57,51),.85)
        polygon(rectpoly(cx,cy,15,B-9,ang,offx=7),lighten(base,.08),1)
        # exhaust
        x1,y1=rotpt(cx,cy,8,-B*.30,ang); x2,y2=rotpt(cx,cy,8,-B*.30-4,ang)
        line((x1,y1),(x2,y2),.8,(39,36,31),1)
    else:
        # passenger vehicle cabin + glass
        cabinL=L*(.50 if cat=="pickup" else .58)
        off=-2 if cat=="pickup" else 0
        polygon(rectpoly(cx,cy,cabinL,B-5,ang,offx=off),lighten(base,.09),1)
        polygon(rectpoly(cx,cy,cabinL-5,B-8,ang,offx=off),(41,54,56),.94)
        line(rotpt(cx,cy,off,-(B-8)/2,ang),rotpt(cx,cy,off,(B-8)/2,ang),.45,(112,103,88),.9)
        if cat=="pickup":
            polygon(rectpoly(cx,cy,L*.31,B-5,ang,offx=L*.30),shade(base,.48),1)
            polygon(rectpoly(cx,cy,L*.25,B-9,ang,offx=L*.30),(53,48,41),.9)
    if cat=="police":
        polygon(rectpoly(cx,cy,L*.48,B-7,ang),(219,219,207),1)
        line(rotpt(cx,cy,-1,-3,ang),rotpt(cx,cy,-1,3,ang),1.5,(41,72,112),1)
        circle(*rotpt(cx,cy,0,-1.8,ang),1.2,(39,81,142),1); circle(*rotpt(cx,cy,0,1.8,ang),1.2,(170,48,42),1)
    if cat=="wreck":
        polygon(rectpoly(cx,cy,L-4,B-4,ang),(58,47,40),.55)
        for _ in range(16):
            lx=rng.uniform(-L*.4,L*.4); ly=rng.uniform(-B*.4,B*.4); circle(*rotpt(cx,cy,lx,ly,ang),rng.uniform(.4,1.2),(24,22,20),.75)
    # grime/rust detailing, different per model but deterministic
    for _ in range(9 if cat not in ("police","ambulance") else 5):
        lx=rng.uniform(-L*.42,L*.42); ly=rng.uniform(-B*.38,B*.38)
        circle(*rotpt(cx,cy,lx,ly,ang),rng.uniform(.35,.85),(100,55,34),rng.uniform(.30,.65))
    # headlights/tail lights improve directional readability
    for ly in (-B*.28,B*.28):
        circle(*rotpt(cx,cy,-L*.46,ly,ang),.75,(222,199,127),.9)
        circle(*rotpt(cx,cy,L*.46,ly,ang),.65,(128,36,31),.9)

for v in range(ROWS):
    for d in range(COLS): draw_cell(v,d)

def chunk(tag,data):
    return struct.pack(">I",len(data))+tag+data+struct.pack(">I",zlib.crc32(tag+data)&0xffffffff)
raw=bytearray()
stride=W*4
for y in range(H): raw.append(0); raw.extend(px[y*stride:(y+1)*stride])
png=b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR",struct.pack(">IIBBBBB",W,H,8,6,0,0,0))+chunk(b"IDAT",zlib.compress(bytes(raw),9))+chunk(b"IEND",b"")
OUT.parent.mkdir(parents=True,exist_ok=True); OUT.write_bytes(png)
print(f"generated {OUT} {W}x{H} vehicles={ROWS} directions={COLS} bytes={len(png)}")
