"""Pinned KayKit CC0 GLB -> native skinned EditableMesh data + three local clips.
Offline dependency: numpy, Pillow. No imported scripts or network at conversion time.
"""
from pathlib import Path
import argparse,hashlib,json,struct
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parent.parent
ASSET=ROOT/'assets/enemies/kaykit-skeletons'
parser=argparse.ArgumentParser();parser.add_argument('--character',choices=['Warrior','Mage','Rogue','Minion'],default='Warrior');args=parser.parse_args()
character=args.character
OUT=ROOT/('src/client/world/skeleton'+(''if character=='Warrior'else character))
OUT.mkdir(parents=True,exist_ok=True)
b=(ASSET/('Skeleton_'+character+'.glb')).read_bytes()
n=struct.unpack_from('<I',b,12)[0];d=json.loads(b[20:20+n]);buf=b[28+n:]
def acc(i):
 a=d['accessors'][i];v=d['bufferViews'][a['bufferView']];dt={5121:'u1',5123:'<u2',5125:'<u4',5126:'<f4'}[a['componentType']];cols={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']]
 return np.ndarray((a['count'],cols),dtype=dt,buffer=buf,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(v.get('byteStride',np.dtype(dt).itemsize*cols),np.dtype(dt).itemsize)).copy()
def mat(t=(0,0,0),q=(0,0,0,1),s=(1,1,1)):
 x,y,z,w=np.array(q)/np.linalg.norm(q);m=np.eye(4)
 m[:3,:3]=np.array([[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]])@np.diag(s);m[:3,3]=t;return m
nodes=d['nodes'];parents={j:i for i,node in enumerate(nodes)for j in node.get('children',[])}
rest=[mat(x.get('translation',(0,0,0)),x.get('rotation',(0,0,0,1)),x.get('scale',(1,1,1)))for x in nodes]
globals={}
def glob(i):
 if i not in globals:globals[i]=(glob(parents[i])if i in parents else np.eye(4))@rest[i]
 return globals[i]
# glTF front +Z -> Roblox front -Z. Preserve original proportions at 3.5 studs/unit.
C=np.diag([-1.,1.,-1.,1.]);SCALE=3.5
def converted(m):
 m=C@m@C;m[:3,3]*=SCALE;return m
def cf(m):return [*m[:3,3],*m[:3,:3].reshape(-1)]
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(list,tuple,np.ndarray)):return '{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,(int,np.integer)):return str(v)
 return f'{float(v):.6g}'
def write(name,x):(OUT/(name+'.luau')).write_text('-- Generated from KayKit Skeletons 1.0 CC0. See assets/enemies/kaykit-skeletons/manifest.json.\nreturn '+lua(x)+'\n')
skin=d['skins'][0];order=[]
def visit(i):
 if 'mesh'not in nodes[i]:order.append(i)
 for j in nodes[i].get('children',[]):visit(j)
for scene_root in d['scenes'][d.get('scene',0)]['nodes']:visit(scene_root)
mapping={node:i+1 for i,node in enumerate(order)}
positions=[];normals=[];colors=[];weights=[];triangles=[]
image=Image.open(ASSET/'skeleton_texture.png').convert('RGB');w,h=image.size
for node_index,node in enumerate(nodes):
 if 'mesh'not in node:continue
 for p in d['meshes'][node['mesh']]['primitives']:
  attr=p['attributes'];verts=acc(attr['POSITION']);norm=acc(attr['NORMAL']);uv=acc(attr['TEXCOORD_0']);base=len(positions)
  if 'JOINTS_0'in attr:
   joints=acc(attr['JOINTS_0']);ww=acc(attr['WEIGHTS_0']);xf=np.eye(4)
   vw=[[[mapping[skin['joints'][int(j)]],float(v)]for j,v in zip(js,ws)if v>1e-6]for js,ws in zip(joints,ww)]
  else:
   xf=glob(node_index);vw=[[[mapping[parents[node_index]],1.]] for _ in verts]
  transformed=(xf[:3,:3]@verts.T).T+xf[:3,3];transformed=(C[:3,:3]@transformed.T).T*SCALE
  positions.extend(transformed);normals.extend((C[:3,:3]@xf[:3,:3]@norm.T).T);weights.extend(vw)
  for u,v in uv:
   colors.append(list(image.getpixel((int(np.clip(u,0,1)*(w-1)),int(np.clip(v,0,1)*(h-1)))))if p.get('material',0)==0 else [255,244,120])
  triangles.extend((acc(p['indices']).reshape(-1,3)+base+1).tolist())
positions=np.array(positions);center=(positions.min(0)+positions.max(0))/2
# Center mesh explicitly so native Bone bind and MeshPart origins agree.
positions-=center
bones=[]
for i in order:
 g=converted(glob(i));g[:3,3]-=center
 bones.append({'name':nodes[i]['name'],'parent':mapping.get(parents.get(i),0),'bind':cf(g),'rest':cf(converted(rest[i]))})
# Roblox Script.Source is limited to 200,000 characters. Keep generated modules small.
rows=[[p,n,c,w] for p,n,c,w in zip(positions,normals,colors,weights)]
chunks=[]
for offset in range(0,len(rows),1200):
 name='Vertices'+str(offset//1200+1);write(name,rows[offset:offset+1200]);chunks.append(name)
write('Triangles',triangles)
index="-- Generated KayKit CC0 geometry; chunks respect Studio Source size limits.\nlocal data={positions={},normals={},colors={},weights={},triangles=require(script.Parent.Triangles)}\n"
for name in chunks:
 index+="for _,v in ipairs(require(script.Parent."+name+"))do table.insert(data.positions,v[1]);table.insert(data.normals,v[2]);table.insert(data.colors,v[3]);table.insert(data.weights,v[4])end\n"
(OUT/'Geometry.luau').write_text(index+'return data\n')
write('Rig',{'bones':bones,'center':center})
selected={
 'Warrior':{'Idle':'Idle','Walk':'Walking_A','Attack':'Unarmed_Melee_Attack_Punch_A','Armed':'1H_Melee_Attack_Chop','Sweep':'1H_Melee_Attack_Slice_Horizontal','Guard':'Blocking','Bash':'Block_Attack','Sit':'Sit_Chair_Idle'},
 'Mage':{'Idle':'Idle_Combat','Walk':'Walking_C','Attack':'Spellcast_Shoot','Prepare':'Spellcast_Raise'},
 'Rogue':{'Idle':'Idle_Combat','Walk':'Running_A','Attack':'Dualwield_Melee_Attack_Slice'},
 'Minion':{'Idle':'Unarmed_Idle','Walk':'Running_B','Attack':'Cheer'},
}[character]
for label,name in selected.items():
 animation=next(a for a in d['animations']if a['name']==name);channels={};duration=0
 for ch in animation['channels']:
  s=animation['samplers'][ch['sampler']];times=acc(s['input']).reshape(-1);values=acc(s['output']);target=ch['target'];channels[target['node'],target['path']]=(times,values);duration=max(duration,float(times[-1]));assert s.get('interpolation','LINEAR')=='LINEAR'
 frames=[];fps=20;count=int(np.ceil(duration*fps))
 def sample(i,path,t,default):
  if(i,path)not in channels:return np.array(default)
  ts,vs=channels[i,path];k=max(0,min(len(ts)-2,int(np.searchsorted(ts,t,side='right')-1)));a=float(np.clip((t-ts[k])/max(1e-9,ts[k+1]-ts[k]),0,1));v0=vs[k];v1=vs[k+1]
  if path=='rotation'and np.dot(v0,v1)<0:v1=-v1
  result=v0*(1-a)+v1*a
  return result/np.linalg.norm(result)if path=='rotation'else result
 for f in range(count+1):
  t=duration*f/count;poses=[]
  for i in order:
   node=nodes[i];local=mat(sample(i,'translation',t,node.get('translation',(0,0,0))),sample(i,'rotation',t,node.get('rotation',(0,0,0,1))))
   poses.append(cf(converted(local)))
  frames.append(poses)
 payload={'duration':duration,'frames':frames}
 if len(lua(payload))<180000:write(label,payload)
 else:
  frame_names=[]
  for offset in range(0,len(frames),16):
   name=label+'Frames'+str(offset//16+1);write(name,frames[offset:offset+16]);frame_names.append(name)
  lines=['-- Generated KayKit CC0 animation chunks.','local frames={}']
  for name in frame_names:lines.append('for _,f in ipairs(require(script.Parent.'+name+'))do table.insert(frames,f)end')
  lines.append('return {duration='+str(duration)+',frames=frames}')
  (OUT/(label+'.luau')).write_text('\n'.join(lines)+'\n')
manifest_path=ASSET/'manifest.json'
manifest=json.loads(manifest_path.read_text())
manifest['files']={str(p.relative_to(ASSET)):hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(ASSET.rglob('*'))if p.suffix in('.glb','.png','.txt','.gltf','.bin')}
manifest['conversion']='python3 tools/convert_skeleton.py --character Warrior|Mage|Rogue|Minion (numpy, Pillow)'
manifest['presentation']='Shared fixed-size native skinned EditableMeshes with per-instance Bones; shared accessory meshes; UV palette baked into vertex colors'
if character=='Warrior':manifest['clips']=selected
manifest.setdefault('characters',{})[character]={'clips':selected,'vertices':len(positions),'triangles':len(triangles),'bones':len(bones),'output':str(OUT.relative_to(ROOT))}
manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
print(character,manifest['characters'][character])
