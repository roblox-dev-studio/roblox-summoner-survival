"""Convert only pinned KayKit CC0 glTF accessory geometry; no external code execution."""
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parent.parent
ASSET=ROOT/'assets/enemies/kaykit-skeletons';OUT=ROOT/'src/client/world/gearAssets';OUT.mkdir(exist_ok=True)
texture=Image.open(ASSET/'skeleton_texture.png').convert('RGB');width,height=texture.size
C=np.diag([-1.,1.,-1.]);SCALE=3.5
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(list,tuple,np.ndarray)):return '{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,(int,np.integer)):return str(v)
 return f'{float(v):.6g}'
for name in ['Axe','Blade','Shield_Large_A','Shield_Small_A','Staff']:
 file=ASSET/'gear'/('Skeleton_'+name+'.gltf');d=json.loads(file.read_text());buffers=[(file.parent/x['uri']).read_bytes()for x in d['buffers']]
 def acc(i):
  a=d['accessors'][i];view=d['bufferViews'][a['bufferView']];dt={5121:'u1',5123:'<u2',5125:'<u4',5126:'<f4'}[a['componentType']];cols={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']]
  return np.ndarray((a['count'],cols),dtype=dt,buffer=buffers[view['buffer']],offset=view.get('byteOffset',0)+a.get('byteOffset',0),strides=(view.get('byteStride',np.dtype(dt).itemsize*cols),np.dtype(dt).itemsize)).copy()
 positions=[];normals=[];colors=[];triangles=[]
 for m in d['meshes']:
  for primitive in m['primitives']:
   attr=primitive['attributes'];base=len(positions);positions.extend((C@acc(attr['POSITION']).T).T*SCALE);normals.extend((C@acc(attr['NORMAL']).T).T)
   for u,v in acc(attr['TEXCOORD_0']):colors.append(texture.getpixel((int(np.clip(u,0,1)*(width-1)),int(np.clip(v,0,1)*(height-1)))))
   triangles.extend((acc(primitive['indices']).reshape(-1,3)+base+1).tolist())
 positions=np.array(positions);center=(positions.min(0)+positions.max(0))/2;positions-=center
 data={'positions':positions,'normals':normals,'colors':colors,'triangles':triangles,'center':center}
 (OUT/(name+'.luau')).write_text('-- Generated KayKit Skeletons 1.0 CC0 gear. See asset manifest.\nreturn '+lua(data)+'\n');print(name,len(positions),len(triangles),'center',center)
manifest_path=ASSET/'manifest.json';manifest=json.loads(manifest_path.read_text());manifest['files']={str(p.relative_to(ASSET)):hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(ASSET.rglob('*'))if p.suffix in('.glb','.png','.txt','.gltf','.bin')};manifest['gear']=['Axe','Blade','Shield_Large_A','Shield_Small_A','Staff'];manifest['gearConversion']='python3 tools/convert_enemy_gear.py (numpy, Pillow)';manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
