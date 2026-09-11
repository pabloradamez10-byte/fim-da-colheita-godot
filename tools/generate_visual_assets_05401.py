#!/usr/bin/env python3
from pathlib import Path
from html import escape

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'visual_rework'
OUT.mkdir(parents=True, exist_ok=True)
VW, VH = 96, 72
AW, AH = 96, 96

NAMES = [
'Compacto claro','Sedã verde','Perua utilitária','Picape branca','Furgão urbano','Caminhão baú','SUV vermelho','Trator agrícola','Carcaça queimada','Utilitário branco','Utilitário vermelho','Micro-ônibus','Viatura policial','Ambulância','Caminhão carroceria','Caminhão rural','Caminhão-tanque','Colheitadeira','Moto trail vermelha','Moto trail verde','Scooter','Bicicleta','Picape vermelha','SUV expedição verde','SUV expedição clara','Caminhão pequeno azul','Furgão de carga claro','Hatch antigo bege','Sedã médio prata','Popular azul desbotado','Cupê velho marrom','Picape compacta azul','Picape 4x4 preta','Van passageiros branca','Ônibus intermunicipal','Cavalo mecânico + carreta curta','Caminhão leiteiro inox','Trator compacto vermelho','Colheitadeira grande verde','Moto street preta']
KINDS = ['car','car','wagon','pickup','van','box','suv','tractor','wreck','suv','suv','minibus','police','ambulance','stake','stake','tanker','harvester','motorcycle','motorcycle','scooter','bicycle','pickup','suv','suv','stake','van','car','car','car','car','pickup','pickup','van','bus','semi','milk','tractor','harvester','motorcycle']
COLORS = ['#d4d0c5','#667b60','#8f927b','#d8d5cb','#b7b39f','#ded6c4','#87483c','#a83b31','#3c3430','#d8d8cf','#8b4c3d','#7c9aaa','#26384b','#f2eee5','#8b7656','#7e6a4a','#a1a7a2','#627b45','#8e3f32','#4d6d50','#706b62','#6b655d','#a6493c','#566c49','#b8b09a','#557189','#dedbd0','#b99d78','#bfc2bf','#52728b','#72543d','#527a9a','#343b3e','#eee9de','#4e7394','#d4d0c4','#c6c9c4','#a74435','#5c7748','#3b3e42']
ACCENTS = ['#9fa8a7','#bfc8b3','#c7c1a7','#a4b4bd','#676d6b','#8b8a83','#c88b69','#e2aa52','#5c3a2b','#93a9ad','#d5aa73','#d9d6c6','#d9e4ec','#d94f42','#c2a56a','#6d8a58','#c6d1d2','#d1b35d','#d56a55','#88a875','#a9a099','#c5b17a','#c87356','#a8b68f','#dad3b6','#9fb9cf','#c6d1d5','#dcc5a1','#e0e3e2','#8aabc0','#bd8c61','#8db4cf','#6a7476','#cfd9dc','#90aabb','#92989a','#e7eeee','#c96a50','#a9b85a','#8b9293']

def tag(name, attrs='', body=''):
    return f'<{name} {attrs}>{body}</{name}>' if body else f'<{name} {attrs}/>'

def poly(points, fill, stroke='#171b1c', sw=1.4, opacity=1):
    p=' '.join(f'{x:.1f},{y:.1f}' for x,y in points)
    return tag('polygon',f'points="{p}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" opacity="{opacity}"')

def rect(x,y,w,h,fill,stroke='#171b1c',sw=1.2,rx=0):
    return tag('rect',f'x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rx}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"')

def ell(cx,cy,rx,ry,fill,stroke='#171b1c',sw=1.2):
    return tag('ellipse',f'cx="{cx:.1f}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"')

def circle(cx,cy,r,fill,stroke='#171b1c',sw=1.1):
    return tag('circle',f'cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"')

def vehicle_cell(kind, direction, color, accent, row):
    side = direction in (2,6)
    front = direction in (0,1,7)
    rear = direction in (3,4,5)
    flip = direction in (5,6,7)
    g=[]
    # ground contact shadow
    g.append(ell(48,58,30 if kind not in ('motorcycle','scooter','bicycle') else 19,6,'#000000','none',0))
    if kind in ('motorcycle','scooter','bicycle'):
        g += [circle(33,54,7,'#22272a'), circle(64,54,7,'#22272a')]
        if kind=='bicycle':
            g += [tag('path',f'd="M33 54 L45 38 L55 54 L40 54 L55 36 L64 54" fill="none" stroke="{color}" stroke-width="3"'),circle(45,37,3,accent,'none',0)]
        else:
            g += [poly([(31,48),(43,38),(58,39),(68,48),(57,52),(38,51)],color),rect(43,33,15,7,accent,'#171b1c',1,3),circle(55,36,2,'#d8e9d8','none',0)]
        return ''.join(g)
    length = 62
    height = 23
    if kind in ('van','minibus','ambulance','bus'): height=30
    if kind in ('box','semi','tanker','milk','harvester'): length=72
    if kind in ('tractor',): length=54
    if side:
        x=12; y=31
        if kind in ('box','semi'):
            g += [rect(31,20,48,29,'#d1c9b7'),rect(14,31,22,21,color),rect(17,34,13,8,'#27343a')]
        elif kind in ('tanker','milk'):
            g += [ell(53,34,28,14,'#c4c9c5'),rect(13,34,20,18,color),rect(16,36,11,7,'#27343a')]
        elif kind=='stake':
            g += [rect(33,31,45,18,'#7a603e'),rect(35,26,2,22,'#4c3927'),rect(48,26,2,22,'#4c3927'),rect(61,26,2,22,'#4c3927'),rect(74,26,2,22,'#4c3927'),rect(13,32,23,18,color),rect(16,34,12,7,'#27343a')]
        elif kind=='tractor':
            g += [circle(27,51,12,'#242728'),circle(67,53,8,'#242728'),rect(25,31,35,18,color),rect(33,21,17,13,accent),rect(52,27,15,13,color)]
        elif kind=='harvester':
            g += [circle(36,52,12,'#242728'),circle(67,54,8,'#242728'),rect(30,24,37,25,color),rect(38,15,22,13,'#27343a'),rect(10,45,67,6,accent),tag('path',f'd="M12 50 L5 59 M22 50 L15 60 M32 50 L25 61" stroke="{accent}" stroke-width="3"')]
        else:
            bodyh=25 if kind in ('van','minibus','ambulance','bus') else 18
            g += [poly([(13,48),(17,34),(30,29),(67,29),(80,38),(82,49)],color)]
            if kind=='pickup': g += [rect(53,31,25,12,'#453c34'),poly([(18,34),(31,26),(52,26),(58,34)],color)]
            elif kind=='wagon' or kind=='suv': g += [poly([(24,31),(34,21),(63,22),(75,32)],accent),rect(36,24,17,8,'#27343a','none',0)]
            else: g += [poly([(27,31),(37,21),(61,22),(71,32)],accent),rect(39,24,16,8,'#27343a','none',0)]
            if kind in ('van','minibus','ambulance','bus'):
                g += [rect(28,25,39,13,'#314047','none',0),rect(69,29,8,10,'#314047','none',0)]
        g += [circle(27,51,7,'#242728'),circle(68,51,7,'#242728'),circle(27,51,3,'#7c7e78'),circle(68,51,3,'#7c7e78')]
    else:
        if kind in ('box','semi'):
            g += [poly([(15,43),(39,22),(78,32),(53,56)],'#d1c9b7'),poly([(13,44),(27,31),(45,37),(32,53)],color)]
        elif kind in ('tanker','milk'):
            g += [ell(54,36,27,13,'#c5ccca'),poly([(13,45),(27,32),(44,37),(31,53)],color)]
        elif kind=='tractor':
            g += [circle(30,49,12,'#242728'),circle(67,48,8,'#242728'),poly([(25,43),(36,26),(62,30),(72,44),(57,51),(37,51)],color),poly([(38,29),(44,18),(58,22),(60,32)],accent)]
        elif kind=='harvester':
            g += [circle(31,51,11,'#242728'),circle(67,48,8,'#242728'),poly([(25,44),(36,22),(66,28),(76,43),(62,52),(36,51)],color),poly([(41,25),(45,14),(63,18),(65,29)],'#314047'),tag('path',f'd="M15 50 L80 50 M18 50 L10 60 M30 50 L22 61 M42 50 L35 62" stroke="{accent}" stroke-width="3"')]
        else:
            g += [poly([(14,45),(31,29),(66,31),(81,43),(63,57),(31,55)],color)]
            g += [poly([(31,30),(40,20),(63,24),(69,33),(58,39),(38,37)],accent),poly([(40,22),(61,25),(65,32),(57,36),(39,34)],'#314047')]
            if kind=='pickup': g += [poly([(54,39),(76,40),(62,53),(47,50)],'#493f35')]
            if kind in ('van','minibus','ambulance','bus'): g += [poly([(25,36),(35,20),(67,25),(77,38),(60,48),(35,45)],color),poly([(36,23),(64,27),(69,34),(58,40),(34,36)],'#314047')]
        g += [ell(26,52,7,5,'#242728'),ell(67,53,7,5,'#242728')]
    # lights and role markings
    if kind=='police':
        g += [rect(42,19,18,4,'#1c63a5','none',0,2),rect(51,19,9,4,'#b83434','none',0,2)]
    if kind=='ambulance':
        g += [rect(44,34,4,13,'#c83232','none',0),rect(39,38,14,4,'#c83232','none',0)]
    if kind=='wreck':
        g += [tag('path','d="M21 35 L73 50 M29 51 L67 30" stroke="#2a211c" stroke-width="5" opacity="0.75"')]
    if front:
        g += [circle(27,47,2.5,'#f1e39a','none',0),circle(69,47,2.5,'#f1e39a','none',0)]
    if rear:
        g += [circle(27,47,2.5,'#b92f27','none',0),circle(69,47,2.5,'#b92f27','none',0)]
    # rust/edge highlights
    g += [tag('path',f'd="M24 42 Q45 30 69 38" fill="none" stroke="#f1e5cb" stroke-width="1.2" opacity="0.32"'),circle(35,44,1.2,'#7b442c','none',0),circle(60,40,1.0,'#7b442c','none',0)]
    if flip:
        return f'<g transform="translate({VW},0) scale(-1,1)">{"".join(g)}</g>'
    return ''.join(g)

def animal_cell(species, direction):
    side=direction in (1,2,3,5,6,7); flip=direction in (5,6,7)
    g=[ell(48,80,28 if species!='rabbit' else 20,5,'#000000','none',0)]
    if species=='rabbit':
        g += [ell(47,57,24,15,'#805c3f'),ell(65 if side else 48,50,10,10,'#8f6848'),ell(60 if side else 43,35,4,14,'#9a7452'),ell(68 if side else 53,35,4,14,'#9a7452'),circle(68 if side else 52,48,1.8,'#151515','none',0),circle(30,59,5,'#e7e0d5','none',0)]
    elif species=='deer':
        g += [ell(45,58,27,15,'#9a6034'),rect(31,67,5,17,'#694329','none',0),rect(55,67,5,17,'#694329','none',0),ell(68 if side else 48,43,10,12,'#a66a39'),tag('path','d="M64 34 L58 21 M64 31 L54 25 M72 34 L77 21 M72 31 L82 25" fill="none" stroke="#593d28" stroke-width="3"'),circle(71 if side else 52,42,1.8,'#141414','none',0),tag('path','d="M20 57 Q30 60 34 58" stroke="#eee4d6" stroke-width="4" fill="none"')]
    elif species=='boar':
        g += [ell(45,59,29,18,'#4d3a2e'),ell(70 if side else 48,55,12,11,'#574033'),tag('path','d="M74 61 Q82 66 84 59" fill="none" stroke="#ded4bf" stroke-width="2.5"'),circle(72 if side else 52,52,1.7,'#101010','none',0),tag('path','d="M24 45 L30 36 L35 47" fill="#3e3029" stroke="#171b1c" stroke-width="1"'),rect(30,70,6,13,'#322820','none',0),rect(55,70,6,13,'#322820','none',0)]
    else:
        g += [ell(46,60,20,18,'#9d6735'),circle(65 if side else 48,48,10,'#ad723a'),tag('path','d="M62 38 L65 30 L68 38 L71 31 L73 41" fill="#bb2d21" stroke="#6b1c16" stroke-width="1"'),tag('path','d="M73 49 L84 54 L73 57" fill="#d9a23f"'),rect(37,73,3,10,'#bf8a34','none',0),rect(53,73,3,10,'#bf8a34','none',0),circle(68 if side else 52,46,1.6,'#111','none',0)]
    # painterly highlight
    g += [tag('path','d="M30 52 Q45 43 58 50" fill="none" stroke="#f2d4a4" stroke-width="2" opacity="0.35"')]
    body=''.join(g)
    if flip:
        return f'<g transform="translate({AW},0) scale(-1,1)">{body}</g>'
    return body

def write_vehicle():
    W,H=VW*8,VH*40
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">', '<rect width="100%" height="100%" fill="none"/>']
    for r,(kind,color,accent) in enumerate(zip(KINDS,COLORS,ACCENTS)):
        for d in range(8):
            out.append(f'<g transform="translate({d*VW},{r*VH})">{vehicle_cell(kind,d,color,accent,r)}</g>')
    out.append('</svg>')
    p=OUT/'fdc_vehicle_atlas_05401.svg'; p.write_text(''.join(out),encoding='utf-8'); print('WROTE',p,W,H,p.stat().st_size)

def write_animals():
    species=['rabbit','deer','boar','chicken']; W,H=AW*8,AH*4
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">','<rect width="100%" height="100%" fill="none"/>']
    for r,s in enumerate(species):
        for d in range(8): out.append(f'<g transform="translate({d*AW},{r*AH})">{animal_cell(s,d)}</g>')
    out.append('</svg>')
    p=OUT/'fdc_animal_atlas_05401.svg'; p.write_text(''.join(out),encoding='utf-8'); print('WROTE',p,W,H,p.stat().st_size)

if __name__=='__main__':
    write_vehicle(); write_animals()
