"""Convert the CC0 Cethiel/Drummyfish Collada mesh, skin and clips to Luau.
Requires numpy and Pillow for offline conversion only. Runtime is self-contained.
"""
from pathlib import Path
import xml.etree.ElementTree as E
import zipfile,json,hashlib,io
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'src/client/world/dragon'
NS={'c':'http://www.collada.org/2005/11/COLLADASchema'}
C=np.array([[-1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]],float)
SCALE=36

def matrix(text):return np.array(list(map(float,text.split()))).reshape(4,4)
def cf(m):
 m=C@m@np.linalg.inv(C);m[:3,3]*=SCALE
 return list(m[:3,3])+list(m[:3,:3].reshape(-1))
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(list,tuple,np.ndarray)):return '{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 if isinstance(v,(int,np.integer)):return str(v)
 return f'{float(v):.6g}'
def write(name,data):
 (OUT/(name+'.luau')).write_text('-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.\nreturn '+lua(data)+'\n')
def sources(root):
 out={}
 for s in root.findall('.//c:source',NS):
  a=s.find('c:float_array',NS)
  if a is not None:out[s.attrib['id']]=list(map(float,a.text.split()))
 return out
with zipfile.ZipFile(ROOT/'assets/dragon/cethiel-dragon-cc0.zip') as z:
 root=E.fromstring(z.read('dragon.dae'));src=sources(root)
 positions=np.array(src['dragon-mesh-positions']).reshape(-1,3)
 pos=(C[:3,:3]@positions.T).T*SCALE
 print('converted bounds',pos.min(0),pos.max(0))
 tri=root.find('.//c:mesh/c:triangles',NS)
 inputs={v.attrib['semantic']:int(v.attrib['offset'])for v in tri.findall('c:input',NS)}
 stride=max(inputs.values())+1
 corners=np.array(list(map(int,tri.find('c:p',NS).text.split()))).reshape(-1,stride)
 indices=corners[:,inputs['VERTEX']].reshape(-1,3)+1
 uv=np.array(src['dragon-mesh-map-0']).reshape(-1,2)
 image=Image.open(io.BytesIO(z.read('dragon_black.png'))).convert('RGB');w,h=image.size
 colors=[]
 for c in corners:
  u,v=uv[c[inputs['TEXCOORD']]]
  rgb=image.getpixel((int(np.clip(u,0,1)*(w-1)),int((1-np.clip(v,0,1))*(h-1))))
  # Preserve hand-painted dark scales while avoiding unreadable crushed blacks.
  colors.append([int(min(255,x*.92+12))for x in rgb])
 skin=root.find('.//c:skin',NS)
 names=skin.find('c:source/c:Name_array',NS).text.split()
 inv=np.array(src['Armature_dragon-skin-bind_poses']).reshape(-1,4,4)
 weights=src['Armature_dragon-skin-weights']
 counts=list(map(int,skin.find('c:vertex_weights/c:vcount',NS).text.split()))
 refs=list(map(int,skin.find('c:vertex_weights/c:v',NS).text.split()))
 vertex_weights=[];offset=0
 for count in counts:
  pairs=[(refs[offset+i*2]+1,weights[refs[offset+i*2+1]])for i in range(count)];offset+=count*2
  pairs=sorted(pairs,key=lambda x:-x[1])[:4];total=sum(x[1]for x in pairs)
  vertex_weights.append([[bone,weight/total]for bone,weight in pairs])
 scene=root.find('.//c:visual_scene',NS);arm=scene.find("c:node[@id='Armature']",NS)
 nodes=[]
 def visit(node,parent=0):
  if node.attrib.get('type')=='JOINT':
   index=names.index(node.attrib['sid'])+1
   nodes.append({'index':index,'name':node.attrib['sid'],'parent':parent,'rest':cf(matrix(node.find('c:matrix',NS).text)),'inverse':cf(inv[index-1])})
   parent=index
  for child in node.findall('c:node',NS):visit(child,parent)
 visit(arm)
 write('Geometry',{'positions':pos.tolist(),'triangles':indices.tolist(),'colors':colors,'weights':vertex_weights})
 write('Rig',{'bones':nodes,'armature':cf(matrix(arm.find('c:matrix',NS).text)),'groundOffset':float(-pos[:,1].min()+.4)})
 for label,file in [('Idle','dragon_idle.dae'),('Walk','dragon_walk.dae'),('Attack','dragon_attack.dae'),('Die','dragon_die.dae')]:
  r=E.fromstring(z.read(file));ss=sources(r);channels={};duration=0
  for a in r.findall('.//c:animation',NS):
   ch=a.find('c:channel',NS)
   if ch is None:continue
   sampler=a.find('c:sampler',NS);bindings={v.attrib['semantic']:v.attrib['source'][1:]for v in sampler}
   times=ss[bindings['INPUT']];mats=np.array(ss[bindings['OUTPUT']]).reshape(-1,4,4)
   target=ch.attrib['target'].split('/')[0].removeprefix('Armature_')
   # This source uses _L/_R in both channels and skin joints. Preserve exact names.
   if target not in names:continue
   duration=max(duration,times[-1]);channels[str(names.index(target)+1)]={'times':times,'poses':[cf(m)for m in mats]}
  # Exporters omit static joints. Every animated source channel must still resolve.
  expected=sum(1 for ch in r.findall('.//c:channel',NS) if ch.attrib['target'].split('/')[0].removeprefix('Armature_') in names)
  assert len(channels)==expected, f'{label}: dropped animated joint tracks'
  if label=='Walk':
   for joint in ['leg_front_upper_L','leg_front_upper_R','leg_back_upper_L','leg_back_upper_R','wing_lower_L','wing_lower_R']:
    assert str(names.index(joint)+1) in channels, f'Walk: missing {joint}'
  print(label, len(channels), 'animated joints')
  write(label,{'duration':duration,'tracks':channels})
 manifest={'source':'https://opengameart.org/content/cethiels-dragon-3d','download':'https://opengameart.org/sites/default/files/dragon_oga.zip','authors':['Drummyfish','Cethiel'],'license':'CC0-1.0','archive_sha256':hashlib.sha256((ROOT/'assets/dragon/cethiel-dragon-cc0.zip').read_bytes()).hexdigest(),'vertices':len(pos),'triangles':len(indices),'bones':len(names),'scale':SCALE,'notes':'Original geometry, weights and four animation clips. Hand-painted black texture sampled to corner colors; no external Roblox image upload required.'}
 (ROOT/'assets/dragon/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
