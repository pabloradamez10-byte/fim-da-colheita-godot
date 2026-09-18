#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random

ROOT = Path(__file__).resolve().parents[1]
VEH_OUT = ROOT / "assets/vehicles/fdc_vehicle_atlas_066.png"
ZOM_OUT = ROOT / "assets/zombies/fdc_zombie_atlas_066.png"

VCELL = 128
CATS = [
"car","car","wagon","pickup","van","box_truck","suv","tractor","car","suv","suv","minibus",
"police","ambulance","stake_truck","stake_truck","tanker","harvester","motorcycle","motorcycle","scooter","bicycle",
"pickup","suv","suv","stake_truck","van","car","car","car","car","pickup","pickup","van",
"bus","semi_truck","tanker","tractor","harvester","motorcycle"
]
COLORS = [
"#d5d0c2","#677d61","#8d907a","#dedbd0","#b9b5a3","#d8d0bd","#984b3d","#af4335",
"#88939b","#dadbd4","#984f40","#7d9caf","#24384e","#f2eee5","#8b7656","#7b694c",
"#aab2ae","#617f47","#9a4637","#527653","#77726a","#6f685f","#b04d3e","#536d4b",
"#beb69d","#56738d","#ddd9ce","#bea27d","#c2c5c2","#547590","#755640","#557fa0",
"#343c40","#efeade","#52789a","#d5d0c5","#c8ceca","#ae4939","#5d7c4b","#3c4146"
]

def rgb(v):
    v=v.lstrip("#"); return tuple(int(v[i:i+2],16) for i in (0,2,4))
def shade(c,f): return tuple(max(0,min(255,int(x*f))) for x in c)
def light(c,a): return tuple(max(0,min(255,int(x+(255-x)*a))) for x in c)

def vehicle_base(idx,cat,col):
    S=256
    im=Image.new("RGBA",(S,S),(0,0,0,0))
    sh=Image.new("RGBA",(S,S),(0,0,0,0)); sd=ImageDraw.Draw(sh)
    sd.ellipse((48,76,208,190),fill=(0,0,0,95))
    im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(12)))
    d=ImageDraw.Draw(im)
    base=rgb(col); outline=(23,28,29,255); glass=(29,43,51,245)
    chrome=(150,154,151,255); red=(169,45,39,255); lamp=(239,224,153,255)
    rust=(110,62,42,190); rng=random.Random(660000+idx)

    if cat in ("motorcycle","scooter","bicycle"):
        for y in (52,196):
            d.ellipse((104,y-18,152,y+18),fill=(25,25,24,255),outline=outline,width=4)
            d.ellipse((116,y-10,140,y+10),fill=(104,104,98,255))
        if cat=="bicycle":
            d.line((128,70,103,162,128,188,153,162,128,70),fill=base+(255,),width=8,joint="curve")
            d.line((103,162,153,162),fill=base+(255,),width=7)
        else:
            d.rounded_rectangle((108,75,148,181),radius=15,fill=base+(255,),outline=outline,width=4)
            d.rounded_rectangle((114,103,142,149),radius=10,fill=shade(base,.58)+(255,))
            d.line((101,82,155,82),fill=chrome,width=5)
            d.ellipse((120,69,136,85),fill=lamp)
        return im

    dims={
      "bus":(92,180),"semi_truck":(92,184),"box_truck":(90,166),"stake_truck":(90,166),
      "tanker":(90,166),"minibus":(88,164),"ambulance":(88,164),"van":(88,160),
      "harvester":(120,160),"tractor":(104,138),"pickup":(90,154),"suv":(90,154),
      "police":(90,154),"wagon":(88,154)
    }
    bw,bh=dims.get(cat,(84,148)); x0=128-bw//2; x1=128+bw//2; y0=128-bh//2; y1=128+bh//2

    if cat=="harvester":
        boxes=[(x0-14,y0+34,x0+12,y0+94),(x1-12,y0+34,x1+14,y0+94),(x0-10,y1-50,x0+9,y1-10),(x1-9,y1-50,x1+10,y1-10)]
    elif cat=="tractor":
        boxes=[(x0-13,y0+30,x0+13,y0+92),(x1-13,y0+30,x1+13,y0+92),(x0-9,y1-42,x0+8,y1-8),(x1-8,y1-42,x1+9,y1-8)]
    else:
        boxes=[]
        for yy in (y0+34,y1-58):
            boxes += [(x0-10,yy,x0+9,yy+37),(x1-9,yy,x1+10,yy+37)]
    for b in boxes: d.rounded_rectangle(b,radius=7,fill=(25,26,25,255),outline=(11,12,12,255),width=3)

    if cat in ("box_truck","stake_truck","tanker","semi_truck"):
        cab=62
        d.rounded_rectangle((x0,y0,x1,y0+cab),radius=16,fill=base+(255,),outline=outline,width=5)
        cy=y0+cab-3
        if cat=="tanker":
            d.rounded_rectangle((x0+7,cy,x1-7,y1),radius=30,fill=(185,191,187,255),outline=outline,width=5)
            for yy in (cy+30,cy+62,cy+94): d.line((x0+12,yy,x1-12,yy),fill=(105,109,106,255),width=3)
        elif cat=="stake_truck":
            d.rounded_rectangle((x0+5,cy,x1-5,y1),radius=5,fill=shade(base,.62)+(255,),outline=outline,width=5)
            for xx in range(x0+12,x1-4,14): d.line((xx,cy+5,xx,y1-5),fill=(89,62,39,255),width=5)
        else:
            d.rounded_rectangle((x0+3,cy,x1-3,y1),radius=7,fill=light(base,.12)+(255,),outline=outline,width=5)
        d.polygon([(x0+13,y0+13),(x1-13,y0+13),(x1-8,y0+36),(x0+8,y0+36)],fill=glass,outline=outline)
    elif cat in ("bus","minibus","van","ambulance"):
        d.rounded_rectangle((x0,y0,x1,y1),radius=18,fill=base+(255,),outline=outline,width=5)
        d.rounded_rectangle((x0+12,y0+14,x1-12,y0+62),radius=9,fill=glass,outline=outline,width=3)
        for yy in range(y0+78,y1-12,27): d.line((x0+9,yy,x1-9,yy),fill=shade(base,.70)+(255,),width=3)
        if cat=="ambulance":
            d.rectangle((x0+8,121,x1-8,135),fill=red); d.rectangle((121,103,135,153),fill=red)
            d.rounded_rectangle((111,y0+5,145,y0+14),radius=4,fill=(45,105,183,255))
            d.rectangle((128,y0+5,145,y0+14),fill=(195,50,43,255))
    elif cat=="harvester":
        d.rounded_rectangle((x0+10,y0+18,x1-10,y1-12),radius=20,fill=base+(255,),outline=outline,width=5)
        d.polygon([(x0+23,y0+22),(x1-23,y0+22),(x1-12,y0+70),(x0+12,y0+70)],fill=glass,outline=outline)
        d.rounded_rectangle((x0-10,y0-10,x1+10,y0+14),radius=7,fill=shade(base,.55)+(255,),outline=outline,width=4)
        for xx in range(x0-2,x1+2,18): d.line((xx,y0-5,xx-8,y0-22),fill=(94,76,48,255),width=4)
    elif cat=="tractor":
        d.rounded_rectangle((x0+8,y0+24,x1-8,y1-10),radius=20,fill=base+(255,),outline=outline,width=5)
        d.rounded_rectangle((x0+22,y0+32,x1-22,y0+84),radius=9,fill=glass,outline=outline,width=4)
        d.rounded_rectangle((x0+23,y1-50,x1-23,y1-12),radius=8,fill=light(base,.1)+(255,),outline=outline,width=3)
    else:
        pts=[(x0+12,y0),(x1-12,y0),(x1,y0+31),(x1,y1-28),(x1-12,y1),(x0+12,y1),(x0,y1-28),(x0,y0+31)]
        d.polygon(pts,fill=base+(255,),outline=outline)
        d.polygon([(x0+10,y0+8),(x1-10,y0+8),(x1-5,y0+39),(x0+5,y0+39)],fill=light(base,.09)+(255,))
        top=y0+43; bot=y1-45
        d.polygon([(x0+14,top),(x1-14,top),(x1-10,bot),(x0+10,bot)],fill=glass,outline=outline)
        d.line((128,top+3,128,bot-3),fill=(86,111,121,210),width=3)
        d.line((x0+16,(top+bot)//2,x1-16,(top+bot)//2),fill=(65,82,89,255),width=3)
        if cat=="pickup":
            d.rounded_rectangle((x0+8,y1-54,x1-8,y1-8),radius=6,fill=(59,52,43,255),outline=outline,width=3)
        if cat=="police":
            d.rectangle((x0+3,116,x1-3,132),fill=(225,226,219,255))
            d.rectangle((112,118,128,128),fill=(43,92,165,255)); d.rectangle((128,118,144,128),fill=(186,48,43,255))

    d.rounded_rectangle((x0+12,y0+4,x0+28,y0+10),radius=2,fill=lamp)
    d.rounded_rectangle((x1-28,y0+4,x1-12,y0+10),radius=2,fill=lamp)
    d.rounded_rectangle((x0+12,y1-10,x0+28,y1-4),radius=2,fill=red)
    d.rounded_rectangle((x1-28,y1-10,x1-12,y1-4),radius=2,fill=red)
    for _ in range(8):
        x=rng.randint(x0+10,x1-10); y=rng.randint(y0+18,y1-18); rr=rng.randint(1,3)
        d.ellipse((x-rr,y-rr,x+rr,y+rr),fill=(110,62,42,150))
    return im

def vehicles():
    atlas=Image.new("RGBA",(VCELL*8,VCELL*40),(0,0,0,0))
    for row,(cat,col) in enumerate(zip(CATS,COLORS)):
        base=vehicle_base(row,cat,col)
        for direction in range(8):
            rot=base.rotate(direction*45.0,resample=getattr(Image, "Resampling", Image).BICUBIC,expand=False,center=(128,128))
            cell=rot.resize((VCELL,VCELL),getattr(Image, "Resampling", Image).LANCZOS)
            atlas.alpha_composite(cell,(direction*VCELL,row*VCELL))
    VEH_OUT.parent.mkdir(parents=True,exist_ok=True)
    atlas.save(VEH_OUT,optimize=True)

ZP=[
((122,139,98),(73,83,72),(43,49,47),(118,48,42),(45,44,37),1.00),
((132,147,103),(121,70,57),(43,48,50),(145,47,39),(48,47,39),0.92),
((113,128,91),(58,72,67),(42,47,44),(111,49,42),(42,43,37),1.18),
((146,132,91),(137,107,55),(75,68,51),(120,50,40),(74,59,37),1.02),
((119,137,98),(147,124,53),(48,61,68),(127,51,43),(44,45,39),1.05),
]

def seg(d,a,b,color,width):
    d.line((a[0],a[1],b[0],b[1]),fill=color,width=width)
    r=max(2,width//2)
    d.ellipse((a[0]-r,a[1]-r,a[0]+r,a[1]+r),fill=color)
    d.ellipse((b[0]-r,b[1]-r,b[0]+r,b[1]+r),fill=color)

def zombie(profile,frame):
    sc=3; W=128*sc; H=160*sc
    im=Image.new("RGBA",(W,H),(0,0,0,0))
    sh=Image.new("RGBA",(W,H),(0,0,0,0)); sd=ImageDraw.Draw(sh)
    sd.ellipse((35*sc,139*sc,94*sc,154*sc),fill=(0,0,0,105))
    im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(5*sc)))
    d=ImageDraw.Draw(im)
    skin,shirt,pants,wound,hair,build=ZP[profile]
    skin=skin+(255,); shirt=shirt+(255,); pants=pants+(255,); wound=wound+(255,); hair=hair+(255,)
    dark=(28,31,29,255); boot=(27,29,29,255)
    ph=frame/8.0*math.tau; bob=math.sin(ph*2)*1.4; step=math.sin(ph)*8.5; swing=-math.sin(ph)*7.5
    lean=3.0 if profile==1 else (-2.5 if profile==2 else 1.5)
    cx=64+lean
    P=lambda x,y:(int(x*sc),int(y*sc))
    # rear leg
    seg(d,P(cx-7*build,96+bob),P(cx-10-step*.38,120+bob),pants,int(10*build*sc))
    seg(d,P(cx-10-step*.38,120+bob),P(cx-14-step*.64,147),pants,int(8*build*sc))
    d.rounded_rectangle((int((cx-21-step*.64)*sc),143*sc,int((cx-6-step*.64)*sc),151*sc),radius=3*sc,fill=boot)
    # front leg
    seg(d,P(cx+7*build,96+bob),P(cx+10+step*.38,120+bob),pants,int(10*build*sc))
    seg(d,P(cx+10+step*.38,120+bob),P(cx+15+step*.64,147),pants,int(8*build*sc))
    d.rounded_rectangle((int((cx+8+step*.64)*sc),143*sc,int((cx+23+step*.64)*sc),151*sc),radius=3*sc,fill=boot)
    # torso
    tw=21*build
    torso=[P(cx-tw,57+bob),P(cx+tw,59+bob),P(cx+16*build,98+bob),P(cx-18*build,98+bob)]
    d.polygon(torso,fill=shirt,outline=dark)
    # shoulders/arms
    seg(d,P(cx-tw+2,63+bob),P(cx-29-swing*.45,87+bob),shirt,int(10*build*sc))
    seg(d,P(cx-29-swing*.45,87+bob),P(cx-24-swing*.72,109+bob),skin,7*sc)
    seg(d,P(cx+tw-2,65+bob),P(cx+28+swing*.45,89+bob),shirt,int(10*build*sc))
    seg(d,P(cx+28+swing*.45,89+bob),P(cx+31+swing*.72,108+bob),skin,7*sc)
    # neck/head
    d.rounded_rectangle((int((cx-6)*sc),int((49+bob)*sc),int((cx+6)*sc),int((62+bob)*sc)),radius=3*sc,fill=skin,outline=dark,width=2*sc)
    d.ellipse((int((cx-13*build)*sc),int((23+bob)*sc),int((cx+13*build)*sc),int((55+bob)*sc)),fill=skin,outline=dark,width=2*sc)
    if profile==3:
        d.pieslice((int((cx-16)*sc),int((16+bob)*sc),int((cx+16)*sc),int((40+bob)*sc)),180,360,fill=hair)
        d.rectangle((int((cx-17)*sc),int((27+bob)*sc),int((cx+20)*sc),int((31+bob)*sc)),fill=hair)
    else:
        d.pieslice((int((cx-14*build)*sc),int((19+bob)*sc),int((cx+14*build)*sc),int((42+bob)*sc)),180,360,fill=hair)
    eye=(213,220,159,255)
    d.ellipse((int((cx-8)*sc),int((36+bob)*sc),int((cx-4)*sc),int((40+bob)*sc)),fill=eye)
    d.ellipse((int((cx+4)*sc),int((36+bob)*sc),int((cx+8)*sc),int((40+bob)*sc)),fill=eye)
    d.line((int((cx-6)*sc),int((47+bob)*sc),int(cx*sc),int((49+bob)*sc),int((cx+7)*sc),int((46+bob)*sc)),fill=(74,30,29,255),width=2*sc)
    wx=cx+(-10,8,-7,10,6)[profile]
    d.ellipse((int((wx-5)*sc),int((72+bob)*sc),int((wx+5)*sc),int((84+bob)*sc)),fill=wound,outline=(72,27,25,255),width=sc)
    # details per profile
    if profile==2:
        d.ellipse((int((cx-25)*sc),int((57+bob)*sc),int((cx-11)*sc),int((72+bob)*sc)),fill=(63,76,70,255),outline=dark,width=sc)
        d.ellipse((int((cx+11)*sc),int((57+bob)*sc),int((cx+25)*sc),int((72+bob)*sc)),fill=(63,76,70,255),outline=dark,width=sc)
    if profile==4:
        d.rectangle((int((cx-17)*sc),int((66+bob)*sc),int((cx+17)*sc),int((71+bob)*sc)),fill=(220,198,88,230))
        d.line((int((cx-11)*sc),int((60+bob)*sc),int((cx-4)*sc),int((95+bob)*sc)),fill=(220,198,88,220),width=3*sc)
        d.line((int((cx+11)*sc),int((60+bob)*sc),int((cx+4)*sc),int((95+bob)*sc)),fill=(220,198,88,220),width=3*sc)
    rng=random.Random(661000+profile*31+frame)
    for _ in range(12):
        x=rng.uniform(cx-18*build,cx+18*build); y=rng.uniform(60+bob,96+bob); rr=rng.uniform(.7,1.8)
        d.ellipse((int((x-rr)*sc),int((y-rr)*sc),int((x+rr)*sc),int((y+rr)*sc)),fill=(39,43,39,95))
    return im.resize((128,160),getattr(Image, "Resampling", Image).LANCZOS)

def zombies():
    atlas=Image.new("RGBA",(128*8,160*5),(0,0,0,0))
    for r in range(5):
        for f in range(8):
            atlas.alpha_composite(zombie(r,f),(f*128,r*160))
    ZOM_OUT.parent.mkdir(parents=True,exist_ok=True)
    atlas.save(ZOM_OUT,optimize=True)

if __name__=="__main__":
    vehicles(); zombies()
    print("0.6.6 vehicle atlas",VEH_OUT,VEH_OUT.stat().st_size)
    print("0.6.6 zombie atlas",ZOM_OUT,ZOM_OUT.stat().st_size)
