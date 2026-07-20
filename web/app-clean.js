(() => {
'use strict';
const canvas=document.querySelector('#game'),ctx=canvas.getContext('2d');
const status=document.querySelector('#status'),toast=document.querySelector('#toast');
const woodEl=document.querySelector('#wood'),stoneEl=document.querySelector('#stone'),campfireEl=document.querySelector('#campfire');
const TILE_W=64,TILE_H=32,MAP_W=32,MAP_H=32;
const RAW='https://raw.githubusercontent.com/pabloradamez10-byte/fim-da-colheita-godot/main/web/assets';
const VERSION='20260720-06';
const FILES={down:`${RAW}/characters/CHR_M_SURVIVOR_0001_S.png?v=${VERSION}`,right:`${RAW}/characters/CHR_M_SURVIVOR_0001_E.png?v=${VERSION}`,up:`${RAW}/characters/CHR_M_SURVIVOR_0001_N.png?v=${VERSION}`,left:`${RAW}/characters/CHR_M_SURVIVOR_0001_W.png?v=${VERSION}`};
const GRASS_FILE=`${RAW}/terrain/TERRAIN_GRASS_001.png?v=${VERSION}`;
const colors={water:'#245d72',wetland:'#4f7055',grass:'#668b4f',soil:'#816b48',dry:'#927b58',rock:'#71746e'};
const sprites={},loaded=new Set();
for(const [dir,src] of Object.entries(FILES)){const im=new Image();im.crossOrigin='anonymous';im.onload=()=>{sprites[dir]=im;loaded.add(dir);};im.onerror=()=>console.error('Falha sprite',src);im.src=src;}
const grassImage=new Image();let grassReady=false;grassImage.crossOrigin='anonymous';grassImage.onload=()=>{grassReady=true;showToast('Primeiro terreno de grama carregado.');};grassImage.onerror=()=>console.error('Falha ao carregar terreno',GRASS_FILE);grassImage.src=GRASS_FILE;
let seed=Number(localStorage.getItem('awe_seed'))||104729,world=[],objects=[],camera={x:0,y:0},player={x:0,y:0,wood:0,stone:0,campfire:0,direction:'down'};
function rng(a){return()=>{let t=a+=0x6D2B79F5;t=Math.imul(t^t>>>15,t|1);t^=t+Math.imul(t^t>>>7,t|61);return((t^t>>>14)>>>0)/4294967296;};}
function noise(x,y,s){const n=Math.sin(x*12.9898+y*78.233+s*.001)*43758.5453;return(n-Math.floor(n))*2-1;}
function smooth(x,y){let total=0,amp=1,f=.08,norm=0;for(let o=0;o<4;o++){total+=noise(x*f,y*f,seed+o*971)*amp;norm+=amp;amp*=.5;f*=2;}return total/norm;}
function terrain(v){if(v<-.38)return'water';if(v<-.18)return'wetland';if(v<.25)return'grass';if(v<.48)return'soil';if(v<.67)return'dry';return'rock';}
function generate(){const r=rng(seed);world=[];objects=[];for(let y=0;y<MAP_H;y++){const row=[];for(let x=0;x<MAP_W;x++){const t=terrain(smooth(x,y));row.push(t);const z=r();if(t==='grass'&&z<.105)objects.push({x,y,type:'tree',alive:true});else if((t==='soil'||t==='dry')&&z<.045)objects.push({x,y,type:'stone',alive:true});else if(t==='wetland'&&z<.035)objects.push({x,y,type:'bush',alive:true});}world.push(row);}player.x=16;player.y=16;while(world[player.y][player.x]==='water')player.x++;save();}
const iso=(x,y)=>({x:(x-y)*TILE_W/2,y:(x+y)*TILE_H/2});
function resize(){const r=canvas.getBoundingClientRect(),d=Math.min(devicePixelRatio||1,2);canvas.width=r.width*d;canvas.height=r.height*d;ctx.setTransform(d,0,0,d,0,0);}
function diamondPath(x,y){ctx.beginPath();ctx.moveTo(x,y-TILE_H/2);ctx.lineTo(x+TILE_W/2,y);ctx.lineTo(x,y+TILE_H/2);ctx.lineTo(x-TILE_W/2,y);ctx.closePath();}
function tile(x,y,type){diamondPath(x,y);ctx.fillStyle=colors[type];ctx.fill();if(type==='grass'&&grassReady){ctx.save();diamondPath(x,y);ctx.clip();ctx.drawImage(grassImage,45,165,935,665,x-TILE_W/2,y-TILE_H/2,TILE_W,TILE_H);ctx.restore();}diamondPath(x,y);ctx.strokeStyle='rgba(15,25,17,.22)';ctx.stroke();}
function obj(o,x,y){if(!o.alive)return;if(o.type==='tree'){ctx.fillStyle='#5e422d';ctx.fillRect(x-3,y-24,6,24);ctx.fillStyle='#2e5634';ctx.beginPath();ctx.arc(x,y-31,14,0,Math.PI*2);ctx.fill();}else if(o.type==='stone'){ctx.fillStyle='#5d625e';ctx.beginPath();ctx.ellipse(x,y-7,11,8,-.2,0,Math.PI*2);ctx.fill();}else{ctx.fillStyle='#466f43';ctx.beginPath();ctx.arc(x,y-7,8,0,Math.PI*2);ctx.fill();}}
function fallback(x,y){ctx.fillStyle='#e6c49b';ctx.beginPath();ctx.arc(x,y-20,8,0,Math.PI*2);ctx.fill();ctx.fillStyle='#365f42';ctx.fillRect(x-7,y-12,14,19);}
function drawPlayer(x,y){const s=sprites[player.direction]||sprites.down;if(!s)return fallback(x,y);const h=108,w=h*(s.naturalWidth/s.naturalHeight);ctx.drawImage(s,x-w/2,y-h+18,w,h);}
function render(){const w=canvas.clientWidth,h=canvas.clientHeight;ctx.clearRect(0,0,w,h);const pi=iso(player.x,player.y);camera.x+=(w/2-pi.x-camera.x)*.12;camera.y+=(h/2-pi.y-camera.y)*.12;const ds=[];for(let y=0;y<MAP_H;y++)for(let x=0;x<MAP_W;x++){const p=iso(x,y);tile(p.x+camera.x,p.y+camera.y,world[y][x]);}for(const o of objects)if(o.alive)ds.push({s:o.x+o.y,k:'o',d:o});ds.push({s:player.x+player.y+.1,k:'p'});ds.sort((a,b)=>a.s-b.s);for(const d of ds){if(d.k==='p'){const p=iso(player.x,player.y);drawPlayer(p.x+camera.x,p.y+camera.y);}else{const p=iso(d.d.x,d.d.y);obj(d.d,p.x+camera.x,p.y+camera.y);}}status.textContent=`Alpha 0.2.5 • grama ${grassReady?'ATIVA':'carregando'} • sprites ${loaded.size}/4 • posição ${player.x},${player.y}`;requestAnimationFrame(render);}
function can(x,y){return x>=0&&y>=0&&x<MAP_W&&y<MAP_H&&world[y][x]!=='water';}
function move(dx,dy){if(dx>0)player.direction='right';else if(dx<0)player.direction='left';else if(dy>0)player.direction='down';else player.direction='up';const x=player.x+dx,y=player.y+dy;if(can(x,y)){player.x=x;player.y=y;save();}}
function interact(){const t=objects.find(o=>o.alive&&Math.abs(o.x-player.x)+Math.abs(o.y-player.y)<=1&&(o.type==='tree'||o.type==='stone'));if(!t)return showToast('Chegue perto de uma árvore ou pedra.');t.alive=false;t.type==='tree'?player.wood++:player.stone++;if(player.wood>=3&&player.stone>=2&&!player.campfire){player.wood-=3;player.stone-=2;player.campfire=1;}hud();save();}
function hud(){woodEl.textContent=player.wood;stoneEl.textContent=player.stone;campfireEl.textContent=player.campfire;}
let tt;function showToast(t){toast.textContent=t;toast.classList.add('show');clearTimeout(tt);tt=setTimeout(()=>toast.classList.remove('show'),1600);}
function save(){localStorage.setItem('awe_seed',seed);localStorage.setItem('awe_save',JSON.stringify({seed,player,objects}));}
function load(){try{const d=JSON.parse(localStorage.getItem('awe_save'));if(!d||d.seed!==seed)return;player={direction:'down',...d.player};objects=d.objects;}catch{}}
const keys={ArrowUp:[0,-1],w:[0,-1],W:[0,-1],ArrowDown:[0,1],s:[0,1],S:[0,1],ArrowLeft:[-1,0],a:[-1,0],A:[-1,0],ArrowRight:[1,0],d:[1,0],D:[1,0]};addEventListener('keydown',e=>{if(keys[e.key]){e.preventDefault();move(...keys[e.key]);}if(e.key==='e'||e.key==='E'||e.key===' ')interact();});document.querySelectorAll('[data-dir]').forEach(b=>{const d={up:[0,-1],down:[0,1],left:[-1,0],right:[1,0]};b.onpointerdown=e=>{e.preventDefault();move(...d[b.dataset.dir]);};});document.querySelector('#interact').onclick=interact;document.querySelector('#newWorld').onclick=()=>{seed++;player={x:0,y:0,wood:0,stone:0,campfire:0,direction:'down'};generate();hud();};addEventListener('resize',resize);resize();generate();load();hud();requestAnimationFrame(render);
})();