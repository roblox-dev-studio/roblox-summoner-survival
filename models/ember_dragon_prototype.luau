-- Original articulated dragon made from reproducible Roblox geometry.
local Dragon={}
local dark=Color3.fromRGB(48,30,44)
local plate=Color3.fromRGB(92,44,53)
local copper=Color3.fromRGB(185,104,65)
local ivory=Color3.fromRGB(235,213,172)
local glow=Color3.fromRGB(255,130,48)
local function piece(parent,name,size,cf,color,shape)
 local p=Instance.new(shape=='wedge' and 'WedgePart' or 'Part')
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or dark;p.Material=Enum.Material.Slate
 if shape=='ball' then local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p end
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent
 return p
end
local function bone(parent,name,a,b,width,color)
 return piece(parent,name,Vector3.new(width,width,(b-a).Magnitude+width*.2),CFrame.lookAt((a+b)*.5,b),color,'ball')
end
local function triangle(parent,a,b,c)
 local ab,ac,bc=b-a,c-a,c-b
 if ab.Magnitude>ac.Magnitude and ab.Magnitude>bc.Magnitude then c,a=a,c
 elseif ac.Magnitude>bc.Magnitude then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
 local height=math.abs(ab:Dot(up))
 local p=piece(parent,'WingMembrane',Vector3.new(.12,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((a+b)/2,right,up,back),Color3.fromRGB(114,35,55),'wedge')
 local q=piece(parent,'WingMembrane',Vector3.new(.12,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((a+c)/2,-right,up,-back),Color3.fromRGB(114,35,55),'wedge')
 p.Material=Enum.Material.SmoothPlastic;q.Material=p.Material
end
function Dragon.create(parent,cf)
 local model=Instance.new('Model');model.Name='EmberDragon';model:SetAttribute('DisplayName','잿불 비룡 · 아그니스');model:SetAttribute('IsBoss',true)
 local root=piece(model,'Root',Vector3.one,cf);root.Transparency=1;model.PrimaryPart=root
 local groups={}
 local function group(name,pivot)local m=Instance.new('Model');m.Name=name;m.Parent=model;groups[name]={model=m,pivot=pivot,parts={}};return m end
 local body=group('Body',CFrame.new(0,6,1))
 piece(body,'Ribcage',Vector3.new(5.5,4.3,7.8),CFrame.new(0,6,1),dark,'ball')
 piece(body,'Haunch',Vector3.new(4.6,3.7,4.8),CFrame.new(0,5.8,4),plate,'ball')
 for i=1,5 do
  piece(body,'ChestScale',Vector3.new(3.3-i*.19,.27,1.4),CFrame.new(0,4.8+i*.21,3-i*1.15)*CFrame.Angles(.18,0,0),copper,'ball')
  local s=piece(body,'DorsalSpine',Vector3.new(.45,1.7,1.5),CFrame.new(0,8.1,4-i*1.15)*CFrame.Angles(-.35,0,0),plate,'wedge')
  local tip=piece(body,'EmberSpine',Vector3.new(.17,.6,.6),s.CFrame*CFrame.new(0,.6,0),glow,'wedge');tip.Material=Enum.Material.Neon
 end
 local neck=group('Neck',CFrame.new(0,7,-2))
 bone(neck,'LowerNeck',Vector3.new(0,6.6,-1.8),Vector3.new(0,8.4,-4.3),2.9,dark)
 bone(neck,'UpperNeck',Vector3.new(0,8.4,-4.3),Vector3.new(0,8.8,-6),2.35,plate)
 for i=1,3 do piece(neck,'NeckScale',Vector3.new(1.6,.28,1),CFrame.new(0,6.9+i*.45,-2.5-i*.9)*CFrame.Angles(-.35,0,0),copper,'ball') end
 local head=group('Head',CFrame.new(0,8.5,-5.5))
 piece(head,'Cranium',Vector3.new(3.1,2.45,3.5),CFrame.new(0,8.9,-6),plate,'ball')
 piece(head,'LongMuzzle',Vector3.new(2.3,1.25,3.3),CFrame.new(0,8.35,-8.1),dark,'ball')
 piece(head,'NoseRidge',Vector3.new(.65,.55,2.2),CFrame.new(0,9,-7.9),plate,'wedge')
 for _,side in ipairs({-1,1}) do
  local eye=piece(head,'GoldenEye',Vector3.new(.28,.38,.9),CFrame.new(side*1.32,9.25,-6.8)*CFrame.Angles(0,side*-.15,-side*.2),glow,'ball');eye.Material=Enum.Material.Neon
  piece(head,'EyeBrow',Vector3.new(.5,.38,1.45),CFrame.new(side*1.25,9.65,-6.7)*CFrame.Angles(0,side*.2,side*-.2),dark,'wedge')
  bone(head,'HornBase',Vector3.new(side*1,9.9,-5.6),Vector3.new(side*1.7,11.3,-4.5),.65,ivory)
  piece(head,'HornPoint',Vector3.new(.38,1.6,.7),CFrame.new(side*1.95,11.8,-3.8)*CFrame.Angles(.7,0,-side*.3),ivory,'wedge')
  piece(head,'CheekFin',Vector3.new(.4,1.3,2.7),CFrame.new(side*1.6,8.5,-4.9)*CFrame.Angles(0,side*.35,side*.2),plate,'wedge')
  for j=1,3 do piece(head,'Fang',Vector3.new(.22,.65,.35),CFrame.new(side*.85,7.9,-7-j*.65)*CFrame.Angles(math.pi,0,0),ivory,'wedge') end
 end
 local mouth=piece(head,'Mouth',Vector3.new(1.3,.45,.35),CFrame.new(0,7.95,-9.5),glow,'ball');mouth.Material=Enum.Material.Neon
 local light=Instance.new('PointLight');light.Color=glow;light.Range=12;light.Brightness=1;light.Parent=mouth
 local jaw=group('Jaw',CFrame.new(0,7.8,-6.3))
 piece(jaw,'LowerJaw',Vector3.new(1.9,.65,3.9),CFrame.new(0,7.65,-7.8),copper,'ball')
 for _,side in ipairs({-1,1}) do
  local wing=group(side==1 and 'RightWing' or 'LeftWing',CFrame.new(side*2,8,.5))
  local a=Vector3.new(side*2,8,.5);local elbow=Vector3.new(side*6,10.8,-.8)
  local points={Vector3.new(side*14,12.3,1),Vector3.new(side*12,8.8,5.1),Vector3.new(side*8,7.3,7),Vector3.new(side*3,7.2,5)}
  bone(wing,'WingArm',a,elbow,.8,plate)
  for i=1,3 do triangle(wing,elbow,points[i],points[i+1]) end
  triangle(wing,a,elbow,points[4])
  for _,v in ipairs(points) do bone(wing,'WingFinger',elbow,v,.22,copper) end
  bone(wing,'LeadingEdge',elbow,points[1],.4,plate)
  piece(wing,'WingClaw',Vector3.new(.35,1.1,.7),CFrame.new(points[1])*CFrame.Angles(0,0,-side*.5),ivory,'wedge')
  for _,front in ipairs({true,false}) do
   local name=(side==1 and 'Right' or 'Left')..(front and 'FrontLeg' or 'BackLeg')
   local x=side*(front and 2.05 or 1.95);local z=front and -1.9 or 3.7
   local leg=group(name,CFrame.new(x,5.6,z))
   local knee=Vector3.new(x+side*.55,3.3,z+(front and .7 or -1))
   bone(leg,'UpperLimb',Vector3.new(x,5.6,z),knee,1.6,plate)
   bone(leg,'LowerLimb',knee,Vector3.new(x+side*.35,1.1,z-.7),1.0,dark)
   piece(leg,'Foot',Vector3.new(1.5,.75,2.4),CFrame.new(x+side*.35,.8,z-1),plate,'ball')
   for j=-1,1 do piece(leg,'Claw',Vector3.new(.32,.45,1),CFrame.new(x+side*.35+j*.4,.62,z-2)*CFrame.Angles(0,math.pi,0),ivory,'wedge') end
  end
 end
 local previous=Vector3.new(0,5.5,5)
 for i=1,7 do
  local v=Vector3.new(math.sin(i*.35)*i*.38,5.3-i*.33,5+i*1.55)
  local tail=group('Tail'..i,CFrame.new(previous))
  bone(tail,'TailSegment',previous,v,2.45-i*.29,i%2==0 and plate or dark)
  if i<6 then piece(tail,'TailSpine',Vector3.new(.27,1.1,.8),CFrame.new(v+Vector3.new(0,.65,0))*CFrame.Angles(-.4,0,0),copper,'wedge') end
  if i==7 then piece(tail,'TailBlade',Vector3.new(.25,1.7,2.4),CFrame.new(v)*CFrame.Angles(.2,0,0),plate,'wedge') end
  previous=v
 end
 for _,g in pairs(groups) do for _,p in ipairs(g.model:GetDescendants()) do if p:IsA('BasePart') then table.insert(g.parts,{part=p,offset=g.pivot:ToObjectSpace(p.CFrame)}) end end end
 model.Parent=parent
 local rig={model=model,root=root,groups=groups,origin=cf};Dragon.pose(rig,0);return rig
end
function Dragon.pose(rig,t,attack,progress,phase)
 local wing=math.sin(t*2.5)*.12
 local lift=math.sin(t*1.8)*.16
 if attack=='eruption' then wing=.3*math.sin(progress*math.pi);lift+=math.sin(progress*math.pi)*.7 end
 if attack=='dive' then lift+=math.sin(progress*math.pi)*2;wing=-.3 end
 local base=rig.origin*CFrame.new(0,lift,0);rig.root.CFrame=rig.origin
 for name,g in pairs(rig.groups) do
  local extra=CFrame.identity
  if name=='LeftWing' then extra=CFrame.Angles(0,0,-wing)
  elseif name=='RightWing' then extra=CFrame.Angles(0,0,wing)
  elseif name=='Head' then extra=CFrame.Angles(attack=='breath' and -.12 or math.sin(t)*.025,0,0)
  elseif name=='Jaw' then extra=CFrame.Angles(attack=='breath' and -.38 or -.04,0,0)
  elseif string.find(name,'Tail') then local i=tonumber(string.match(name,'%d+'));extra=CFrame.Angles(0,math.sin(t*1.5-i*.4)*.12,0)
  elseif string.find(name,'Leg') then local side=string.find(name,'Left') and 1 or -1;local front=string.find(name,'Front') and 1 or -1;extra=CFrame.Angles(math.sin(t*3)*.08*side*front,0,0) end
  local frame=base*g.pivot*extra
  for _,v in ipairs(g.parts) do v.part.CFrame=frame*v.offset end
 end
 local mouth=rig.groups.Head.model.Mouth
 mouth.Color=phase==2 and Color3.fromRGB(255,73,37) or glow
 mouth.PointLight.Brightness=attack=='breath' and 3 or 1
end
return Dragon
