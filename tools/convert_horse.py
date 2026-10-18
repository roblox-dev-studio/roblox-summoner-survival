"""Quaternius CC0 Horse GLB to Roblox native skinned mesh and local animation frames.
Offline numpy only. Bake glTF ancestor scales before extracting rigid bone frames.
"""
from pathlib import Path
import hashlib,json,struct
import numpy as np
ROOT=Path(__file__).resolve().parents[1];ASSET=ROOT/'assets/enemies/quaternius-horse';OUT=ROOT/'src/client/world/horse';OUT.mkdir(exist_ok=True)
b=(ASSET/'Horse.glb').read_bytes();n=struct.unpack_from('<I',b,12)[0];d=json.loads(b[20:20+n]);buf=b[28+n:]
def acc(i):
 a=d['accessors'][i];v=d['bufferViews'][a['bufferView']];dt={5121:'u1',5123:'<u2',5125:'<u4',5126:'<f4'}[a['componentType']];cols={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']]
 return np.ndarray((a['count'],cols),dtype=dt,buffer=buf,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(v.get('byteStride',np.dtype(dt).itemsize*cols),np.dtype(dt).itemsize)).copy()
def mat(t=(0,0,0),q=(0,0,0,1),s=(1,1,1)):
 x,y,z,w=np.array(q)/np.linalg.norm(q);m=np.eye(4);m[:3,:3]=np.array([[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]])@np.diag(s);m[:3,3]=t;return m
nodes=d['nodes'];parents={j:i for i,node in enumerate(nodes)for j in node.get('children',[])};order=[i for i,node in enumerate(nodes)if 'mesh'not in node];mapping={j:i+1 for i,j in enumerate(order)}
rest=[mat(x.get('translation',(0,0,0)),x.get('rotation',(0,0,0,1)),x.get('scale',(1,1,1)))for x in nodes]
def globals_of(local):
 g={}
 def get(i):
  if i not in g:g[i]=(get(parents[i])if i in parents else np.eye(4))@local[i]
  return g[i]
 for i in range(len(nodes)):get(i)
 return g
global_rest=globals_of(rest);C=np.diag([-1.,1.,-1.,1.]);SCALE=2.0
mesh_node=next(i for i,x in enumerate(nodes)if 'mesh'in x);xf=global_rest[mesh_node];skin=d['skins'][nodes[mesh_node]['skin']]
positions=[];normals=[];colors=[];weights=[];triangles=[]
for p in d['meshes'][nodes[mesh_node]['mesh']]['primitives']:
 a=p['attributes'];v=acc(a['POSITION']);base=len(positions);world=(xf[:3,:3]@v.T).T+xf[:3,3];positions.extend((C[:3,:3]@world.T).T*SCALE)
 nm=(C[:3,:3]@np.linalg.inv(xf[:3,:3]).T@acc(a['NORMAL']).T).T;nm/=np.linalg.norm(nm,axis=1)[:,None];normals.extend(nm)
 factor=np.array(d['materials'][p['material']]['pbrMetallicRoughness']['baseColorFactor'][:3]);rgb=np.where(factor<=.0031308,factor*12.92,1.055*np.power(factor,1/2.4)-.055);colors.extend([list(np.rint(rgb*255).astype(int))]*len(v))
 for js,ws in zip(acc(a['JOINTS_0']),acc(a['WEIGHTS_0'])):weights.append([[mapping[skin['joints'][int(j)]],float(w)]for j,w in zip(js,ws)if w>1e-6])
 triangles.extend((acc(p['indices']).reshape(-1,3)+base+1).tolist())
positions=np.array(positions);floor=-positions[:,1].min();positions[:,1]+=floor;center=(positions.min(0)+positions.max(0))/2;positions-=center

def converted_globals(global_poses):
 out={}
 for i in order:
  raw=C@global_poses[i]@C;m=np.eye(4);rot=raw[:3,:3];m[:3,:3]=rot/np.linalg.norm(rot,axis=0)[None,:];m[:3,3]=raw[:3,3]*SCALE+np.array([0,floor,0])-center;out[i]=m
 return out
def cf(m):return [*m[:3,3],*m[:3,:3].reshape(-1)]
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(list,tuple,np.ndarray)):return '{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,(int,np.integer)):return str(v)
 return f'{float(v):.6g}'
def write(name,obj):(OUT/(name+'.luau')).write_text('-- Generated Quaternius CC0 Horse. See assets/enemies/quaternius-horse/manifest.json.\nreturn '+lua(obj)+'\n')
bind=converted_globals(global_rest);bones=[]
for i in order:
 parent=parents.get(i);local=np.linalg.inv(bind[parent])@bind[i]if parent in mapping else bind[i]
 bones.append({'name':nodes[i]['name'],'parent':mapping.get(parent,0),'bind':cf(bind[i]),'rest':cf(local)})
write('Rig',{'center':center,'bones':bones})
chunks=[];rows=list(zip(positions,normals,colors,weights))
for offset in range(0,len(rows),1000):name='Vertices'+str(offset//1000+1);write(name,rows[offset:offset+1000]);chunks.append(name)
write('Triangles',triangles)
index='local d={positions={},normals={},colors={},weights={},triangles=require(script.Parent.Triangles)}\n'
for name in chunks:index+='for _,v in ipairs(require(script.Parent.'+name+'))do table.insert(d.positions,v[1]);table.insert(d.normals,v[2]);table.insert(d.colors,v[3]);table.insert(d.weights,v[4])end\n'
(OUT/'Geometry.luau').write_text(index+'return d\n')
clips={'Idle':'Idle','Walk':'Walk','Gallop':'Gallop'}
for label,name in clips.items():
 animation=next(x for x in d['animations']if x['name']==name);channels={};duration=0
 for ch in animation['channels']:
  sampler=animation['samplers'][ch['sampler']];ts=acc(sampler['input']).reshape(-1);vs=acc(sampler['output']);channels[ch['target']['node'],ch['target']['path']]=(ts,vs);duration=max(duration,float(ts[-1]));assert sampler.get('interpolation','LINEAR')=='LINEAR'
 def sample(i,path,t,default):
  if(i,path)not in channels:return np.array(default)
  ts,vs=channels[i,path];k=max(0,min(len(ts)-2,int(np.searchsorted(ts,t,side='right')-1)));a=float(np.clip((t-ts[k])/max(1e-9,ts[k+1]-ts[k]),0,1));v0=vs[k];v1=vs[k+1]
  if path=='rotation'and np.dot(v0,v1)<0:v1=-v1
  value=v0*(1-a)+v1*a;return value/np.linalg.norm(value)if path=='rotation'else value
 frames=[];count=int(np.ceil(duration*20))
 for f in range(count+1):
  t=duration*f/count;local=[mat(sample(i,'translation',t,x.get('translation',(0,0,0))),sample(i,'rotation',t,x.get('rotation',(0,0,0,1))),sample(i,'scale',t,x.get('scale',(1,1,1))))for i,x in enumerate(nodes)];g=converted_globals(globals_of(local));poses=[]
  for i in order:
   parent=parents.get(i);poses.append(cf(np.linalg.inv(g[parent])@g[i]if parent in mapping else g[i]))
  frames.append(poses)
 names=[]
 for offset in range(0,len(frames),12):part=label+'Frames'+str(offset//12+1);write(part,frames[offset:offset+12]);names.append(part)
 (OUT/(label+'.luau')).write_text('local frames={}\n'+''.join('for _,f in ipairs(require(script.Parent.'+x+'))do table.insert(frames,f)end\n'for x in names)+'return {duration='+str(duration)+',frames=frames}\n')
 print(label,duration,len(frames))
manifest={'author':'Quaternius','asset':'Horse, Ultimate Animated Animal Pack','source':'https://quaternius.com/packs/ultimateanimatedanimals.html','distribution':'https://poly.pizza/m/qvTrSG9pZF','download':'https://static.poly.pizza/d37dbc87-ca61-4b2c-a2da-d2f0c4240bef.glb','license':'CC0 1.0','sha256':hashlib.sha256(b).hexdigest(),'vertices':len(positions),'triangles':len(triangles),'bones':len(bones),'clips':clips,'conversion':'python3 tools/convert_horse.py (numpy), baked ancestor scale, glTF +Z to Roblox -Z, sRGB material vertex colors, height ~9.65 studs','generated':'src/client/world/horse','scriptsImported':False}
(ASSET/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('bounds',positions.min(0),positions.max(0),'center',center)
