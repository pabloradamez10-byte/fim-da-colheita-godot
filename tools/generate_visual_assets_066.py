#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random

RESAMPLE_LANCZOS = getattr(Image, "Resampling", Image).LANCZOS

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "visual_rework_066"
OUT.mkdir(parents=True, exist_ok=True)

VEH_NAMES = [
"Compacto claro","Sedã verde","Perua utilitária","Picape branca","Furgão urbano","Caminhão baú","SUV vermelho","Trator agrícola",
"Carcaça queimada","Utilitário branco","Utilitário vermelho","Micro-ônibus","Viatura policial","Ambulância","Caminhão carroceria",
"Caminhão rural","Caminhão-tanque","Colheitadeira","Moto trail vermelha","Moto trail verde","Scooter","Bicicleta","Picape vermelha",
"SUV expedição verde","SUV expedição clara","Caminhão pequeno azul","Furgão de carga claro","Hatch antigo bege","Sedã compacto prata",
"Hatch urbano azul","Coupé clássico marrom","Picape 4x4 azul","Picape expedição preta","Furgão clássico de passageiros",
"Ônibus intermunicipal","Carreta baú","Caminhão leiteiro","Trator vermelho clássico","Colheitadeira verde","Moto utilitária preta"]
VEH_CATS = [
"car","car","wagon","pickup","van","box_truck","suv","tractor","wreck","suv","suv","minibus","police","ambulance","stake_truck",
"stake_truck","tanker","harvester","motorcycle","motorcycle","scooter","bicycle","pickup","suv","suv","stake_truck","van","car",
"car","car","car","pickup","pickup","van","bus","semi_truck","tanker","tractor","harvester","motorcycle"]
VEH_COLORS = [
(210,205,191),(90,119,91),(139,136,111),(219,216,205),(164,166,153),(200,195,179),(148,64,54),(173,69,50),(72,63,58),
(216,216,207),(152,69,58),(116,145,161),(48,71,95),(236,235,226),(133,107,77),(113,94,67),(170,176,174),(101,126,72),
(156,65,55),(74,110,78),(115,112,106),(95,91,84),(172,75,62),(76,103,74),(190,183,162),(79,111,143),(211,208,194),
(183,157,117),(186,190,187),(76,111,145),(121,85,61),(76,113,151),(56,64,68),(225,222,214),(74,113,151),(206,201,191),
(192,196,193),(168,67,54),(91,120,68),(53,57,61)]
VEH_DIMS = {
"car":(72,34),"wagon":(78,36),"pickup":(82,38),"van":(82,42),"suv":(78,40),"wreck":(76,36),"minibus":(88,44),
"police":(78,38),"ambulance":(86,44),"box_truck":(94,44),"stake_truck":(92,44),"tanker":(96,44),"tractor":(68,46),
"harvester":(90,58),"motorcycle":(60,18),"scooter":(52,20),"bicycle":(56,12),"bus":(104,46),"semi_truck":(108,46)}
VW,VH = 128,96

def shade(c,f): return tuple(max(0,min(255,int(v*f))) for v in c)
def light(c,f): return tuple(max(0,min(255,int(v+(255-v)*f))) for v in c)
def tp(points,cx,cy,a,sy=.68):
    ca,sa=math.cos(a),math.sin(a); out=[]
    for x,y in points:
        out.append((cx+x*ca-y*sa, cy+(x*sa+y*ca)*sy))
    return out
def rp(l,w,ox=0,oy=0): return [(ox-l/2,oy-w/2),(ox+l/2,oy-w/2),(ox+l/2,oy+w/2),(ox-l/2,oy+w/2)]

def vehicle_cell(row,direction):
    S=2; im=Image.new("RGBA",(VW*S,VH*S),(0,0,0,0)); dr=ImageDraw.Draw(im)
    cx,cy=VW*S/2,VH*S*.53; cat=VEH_CATS[row]; base=VEH_COLORS[row]; L,B=VEH_DIMS.get(cat,(76,36)); L*=S; B*=S
    ang=direction*math.pi/4; rng=random.Random(660000+row*97+direction*13)
    def poly(points,fill,outline=None,width=1):
        pts=tp(points,cx,cy,ang)
        dr.polygon(pts,fill=fill)
        if outline: dr.line(pts+[pts[0]],fill=outline,width=width*S,joint="curve")
    def rect(l,w,fill,ox=0,oy=0,outline=None,width=1): poly(rp(l,w,ox,oy),fill,outline,width)
    def circ(lx,ly,r,fill,outline=None,width=1):
        x,y=tp([(lx,ly)],cx,cy,ang)[0]; rr=r*S
        dr.ellipse((x-rr,y-rr,x+rr,y+rr),fill=fill,outline=outline,width=width*S if outline else 1)
    def line(a,b,fill,width=1): dr.line([tp([a],cx,cy,ang)[0],tp([b],cx,cy,ang)[0]],fill=fill,width=width*S)
    sh=Image.new("RGBA",im.size,(0,0,0,0)); sd=ImageDraw.Draw(sh)
    sd.ellipse((cx-L*.48,cy+B*.12,cx+L*.48,cy+B*.58),fill=(0,0,0,76)); sh=sh.filter(ImageFilter.GaussianBlur(7)); im.alpha_composite(sh); dr=ImageDraw.Draw(im)
    if cat=="bicycle":
        for lx in (-L*.32,L*.32): circ(lx,0,5,(29,31,32,255),(12,14,15,255))
        line((-L*.32,0),(0,-B*.22),(*base,255),2); line((0,-B*.22),(L*.30,0),(*base,255),2); line((-L*.1,B*.1),(L*.12,-B*.15),(*base,255),2)
        return im.resize((VW,VH),RESAMPLE_LANCZOS)
    if cat in ("motorcycle","scooter"):
        for lx in (-L*.35,L*.35): circ(lx,0,5.5,(28,29,30,255),(9,10,11,255))
        rect(L*.56,B*.46,(*base,255),outline=(35,38,39,255)); rect(L*.26,B*.54,(*light(base,.15),255),L*.05,-B*.03)
        return im.resize((VW,VH),RESAMPLE_LANCZOS)
    wr=5.5*S if cat not in ("tractor","harvester") else 7.5*S
    for lx,ly in [(-L*.30,-B*.48),(-L*.30,B*.48),(L*.30,-B*.48),(L*.30,B*.48)]:
        x,y=tp([(lx,ly)],cx,cy,ang)[0]; dr.ellipse((x-wr,y-wr,x+wr,y+wr),fill=(28,29,29,255),outline=(9,10,10,255),width=3)
        dr.ellipse((x-wr*.43,y-wr*.43,x+wr*.43,y+wr*.43),fill=(103,100,92,255))
    rect(L,B,(*shade(base,.70),255),0,B*.05,(24,29,30,255),2); rect(L*.93,B*.86,(*base,255),0,-B*.01,(37,42,42,255))
    if cat in ("box_truck","stake_truck","tanker","semi_truck"):
        cab=L*.28; cargo=L*.62; cabx=-L*.31; cargox=L*.16
        rect(cab,B*.80,(*light(base,.08),255),cabx,0,(30,35,36,255)); rect(cab*.35,B*.58,(45,61,67,255),cabx+cab*.22,-B*.02)
        if cat=="tanker":
            rect(cargo,B*.62,(178,184,184,255),cargox,0,(68,73,74,255))
            for q in (-.2,0,.2): line((cargox+q*cargo,-B*.28),(cargox+q*cargo,B*.28),(104,110,110,220))
        elif cat=="stake_truck":
            rect(cargo,B*.66,(*shade(base,.55),255),cargox,0,(60,50,41,255))
            for q in (-.35,-.12,.12,.35): line((cargox+q*cargo,-B*.36),(cargox+q*cargo,B*.36),(84,60,39,255),2)
        else: rect(cargo,B*.72,(*light(base,.13),255),cargox,0,(47,53,54,255))
    elif cat in ("van","minibus","bus","ambulance"):
        rect(L*.70,B*.67,(*light(base,.08),255),L*.02,0,(34,39,40,255)); rect(L*.57,B*.45,(45,61,67,255),-L*.03,-B*.02)
        for q in (-.2,0,.2): line((q*L,-B*.22),(q*L,B*.22),(113,122,122,255))
        if cat=="ambulance": rect(L*.05,B*.26,(194,47,44,255)); rect(L*.18,B*.07,(194,47,44,255))
    elif cat=="tractor":
        rect(L*.35,B*.58,(48,63,58,255),-L*.12,-B*.04,(29,34,34,255)); rect(L*.32,B*.54,(*light(base,.08),255),L*.22,0,(35,40,40,255))
        line((L*.28,-B*.25),(L*.28,-B*.52),(49,47,43,255),2)
    elif cat=="harvester":
        rect(L*.58,B*.66,(*light(base,.05),255),L*.08,0,(34,40,39,255)); rect(L*.25,B*.44,(45,64,61,255),-L*.18,-B*.05)
        line((-L*.50,-B*.62),(-L*.50,B*.62),(*shade(base,.45),255),4)
        for q in (-.4,-.2,0,.2,.4): line((-L*.48,q*B),(-L*.65,q*B),(72,65,50,255),2)
    else:
        cabin=L*(.48 if cat=="pickup" else .56); off=-L*.04 if cat=="pickup" else 0
        rect(cabin,B*.64,(*light(base,.10),255),off,-B*.02,(39,44,45,255)); rect(cabin*.76,B*.45,(42,58,64,255),off,-B*.03,(25,31,34,255))
        line((off,-B*.21),(off,B*.21),(115,126,129,210))
        if cat=="pickup": rect(L*.30,B*.60,(61,54,47,255),L*.30,0,(38,34,31,255))
    if cat=="police":
        rect(L*.45,B*.13,(233,235,230,255)); circ(0,-B*.06,2.2,(42,95,166,255)); circ(0,B*.06,2.2,(193,49,46,255))
    if cat=="wreck":
        rect(L*.88,B*.75,(45,42,40,145))
        for _ in range(15): circ(rng.uniform(-L*.38,L*.38),rng.uniform(-B*.32,B*.32),rng.uniform(1.5,4),(35,30,28,155))
    rect(L*.18,B*.70,(*light(base,.18),255),-L*.38,0); rect(L*.16,B*.68,(*shade(base,.82),255),L*.39,0)
    for ly in (-B*.27,B*.27):
        circ(-L*.47,ly,2.0,(243,224,150,255)); circ(L*.47,ly,1.7,(171,47,43,255))
    line((-L*.49,-B*.32),(-L*.49,B*.32),(210,213,208,180)); line((L*.49,-B*.32),(L*.49,B*.32),(88,92,90,180))
    if cat not in ("police","ambulance"):
        for _ in range(7): circ(rng.uniform(-L*.35,L*.35),rng.uniform(-B*.28,B*.28),rng.uniform(.6,1.8),(112,69,45,120))
    line((-L*.25,-B*.34),(L*.25,-B*.34),(248,239,219,95))
    return im.resize((VW,VH),RESAMPLE_LANCZOS)

def write_vehicles():
    atlas=Image.new("RGBA",(VW*8,VH*40),(0,0,0,0))
    for row in range(40):
        for direction in range(8): atlas.alpha_composite(vehicle_cell(row,direction),(direction*VW,row*VH))
    path=OUT/"fdc_vehicle_atlas_066.png"; atlas.save(path,optimize=True); print("WROTE",path,atlas.size,path.stat().st_size)

ZPROFILES=[
{"skin":(132,148,113),"shirt":(79,91,80),"pants":(53,59,56),"wound":(116,47,40),"hair":(47,49,43)},
{"skin":(148,160,120),"shirt":(111,71,62),"pants":(47,53,55),"wound":(150,48,41),"hair":(53,43,39)},
{"skin":(124,137,109),"shirt":(61,74,69),"pants":(43,49,46),"wound":(108,45,39),"hair":(42,45,40)},
{"skin":(148,139,104),"shirt":(112,92,55),"pants":(69,63,47),"wound":(119,53,43),"hair":(58,50,36)},
{"skin":(133,146,115),"shirt":(131,111,58),"pants":(51,63,70),"wound":(126,49,41),"hair":(43,47,42)}]
ZW,ZH=128,160

def zombie_cell(pi,direction,frame):
    S=3; im=Image.new("RGBA",(ZW*S,ZH*S),(0,0,0,0)); dr=ImageDraw.Draw(im); p=ZPROFILES[pi]
    cx=ZW*S/2; ground=ZH*S*.90; a=direction*math.pi/4; front=-math.cos(a); side=math.sin(a); phase=[-1,-.25,1,.25][frame]
    build=1.18 if pi==2 else (.94 if pi==1 else 1.0); hip=ground-42*S; sh=ground-83*S; hy=ground-112*S
    tw=(32 if abs(front)>.5 else 24)*S*build; sep=(8+4*abs(side))*S; stride=phase*10*S
    dr.ellipse((cx-24*S,ground-3*S,cx+24*S,ground+7*S),fill=(0,0,0,62))
    for idx,sgn in enumerate((-1,1)):
        xh=cx+sgn*sep; kx=xh+sgn*stride*.18; fx=xh+sgn*stride*.45; col=shade(p["pants"],.78 if idx==0 else .98)
        dr.line([(xh,hip),(kx,ground-23*S),(fx,ground-4*S)],fill=(*col,255),width=int(9*S*build),joint="curve")
        dr.line([(fx-2*S,ground-4*S),(fx+sgn*5*S,ground-2*S)],fill=(31,34,34,255),width=5*S)
    torso=[(cx-tw*.55,sh),(cx+tw*.55,sh+S),(cx+tw*.44,hip),(cx-tw*.46,hip)]
    dr.polygon(torso,fill=(*p["shirt"],255)); dr.line(torso+[torso[0]],fill=(29,35,34,255),width=S)
    dr.polygon([(cx-tw*.45,sh+3*S),(cx-2*S,sh+2*S),(cx-4*S,hip-2*S),(cx-tw*.34,hip-S)],fill=(*light(p["shirt"],.08),120))
    dr.polygon([(cx+2*S,sh+3*S),(cx+tw*.48,sh+4*S),(cx+tw*.36,hip),(cx+4*S,hip-2*S)],fill=(*shade(p["shirt"],.72),120))
    armphase=phase*10*S; sho=tw*.50
    for sgn,far in ((-1,True),(1,False)):
        shoulder=(cx+sgn*sho,sh+5*S); elbow=(cx+sgn*(sho+7*S)+sgn*armphase*.18,sh+25*S-armphase*.08); hand=(cx+sgn*(sho+4*S)+sgn*armphase*.30,sh+46*S+armphase*.08)
        col=shade(p["skin"],.78 if far else .98); dr.line([shoulder,elbow,hand],fill=(*col,255),width=int(8*S*build),joint="curve")
        dr.ellipse((hand[0]-3*S,hand[1]-3*S,hand[0]+3*S,hand[1]+3*S),fill=(*col,255))
    dr.rectangle((cx-5*S,hy+13*S,cx+5*S,sh+5*S),fill=(*shade(p["skin"],.9),255))
    hx=cx+side*4*S; hr=(12 if abs(side)<.7 else 10)*S*build
    dr.ellipse((hx-hr,hy-16*S,hx+hr,hy+16*S),fill=(*p["skin"],255),outline=(30,35,33,255),width=S)
    dr.pieslice((hx-hr-S,hy-17*S,hx+hr+S,hy+5*S),180,360,fill=(*p["hair"],255))
    if front>-.15:
        if abs(side)>.7:
            ex=hx+(3*S if side>0 else -3*S); dr.ellipse((ex-1.3*S,hy-2*S,ex+1.3*S,hy+S),fill=(224,211,150,255))
        else:
            for sgn in (-1,1):
                ex=hx+sgn*4*S; dr.ellipse((ex-1.4*S,hy-2*S,ex+1.4*S,hy+S),fill=(224,211,150,255))
            dr.ellipse((hx+4*S,hy+2*S,hx+9*S,hy+8*S),fill=(*p["wound"],200))
        dr.line([(hx-4*S,hy+7*S),(hx+5*S,hy+8*S)],fill=(82,32,29,255),width=2*S)
    else: dr.ellipse((hx-4*S,hy-4*S,hx+4*S,hy+4*S),fill=(76,67,52,170))
    wx=cx+(8*S if pi%2==0 else -9*S); dr.ellipse((wx-5*S,sh+18*S,wx+5*S,sh+30*S),fill=(*p["wound"],210))
    if pi==3:
        dr.polygon([(hx-12*S,hy-11*S),(hx+10*S,hy-12*S),(hx+16*S,hy-8*S),(hx-12*S,hy-7*S)],fill=(*shade(p["shirt"],.88),255))
        for sgn in (-1,1): dr.line([(cx+sgn*6*S,sh+5*S),(cx+sgn*2*S,hip-3*S)],fill=(185,157,94,220),width=2*S)
    elif pi==4:
        dr.line([(cx-tw*.43,sh+17*S),(cx+tw*.43,sh+17*S)],fill=(224,207,105,235),width=4*S)
    elif pi==2:
        dr.ellipse((cx-sho-6*S,sh-2*S,cx-sho+7*S,sh+13*S),fill=(58,71,66,255)); dr.ellipse((cx+sho-7*S,sh-2*S,cx+sho+6*S,sh+13*S),fill=(58,71,66,255))
    elif pi==1: dr.line([(cx-6*S,sh+3*S),(cx-4*S,hip-3*S)],fill=(188,145,113,210),width=3*S)
    return im.resize((ZW,ZH),RESAMPLE_LANCZOS)

def write_zombies():
    atlas=Image.new("RGBA",(ZW*4,ZH*40),(0,0,0,0))
    for pi in range(5):
        for direction in range(8):
            row=pi*8+direction
            for frame in range(4): atlas.alpha_composite(zombie_cell(pi,direction,frame),(frame*ZW,row*ZH))
    path=OUT/"fdc_zombie_atlas_066.png"; atlas.save(path,optimize=True); print("WROTE",path,atlas.size,path.stat().st_size)

if __name__=="__main__":
    write_vehicles()
    write_zombies()
