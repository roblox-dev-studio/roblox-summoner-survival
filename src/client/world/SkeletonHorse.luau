-- Original skeletal barding, retargeted to the checked-in Quaternius horse bones.
-- The native mesh remains an invisible animation carrier, not a recolored living horse.
local source=require(script.Parent.horse.Rig)
local Art={}
local bind={};for _,b in ipairs(source.bones)do bind[b.name]=CFrame.new(table.unpack(b.bind))end
local ivory=Color3.fromRGB(206,199,174);local pale=Color3.fromRGB(235,225,194)
local steel=Color3.fromRGB(62,74,88);local rim=Color3.fromRGB(135,151,164);local dark=Color3.fromRGB(20,26,30)
local function scaled(frame,scale)return CFrame.new(frame.Position*scale)*frame.Rotation end
function Art.create(horse,parent)
 local rig={horse=horse,scale=horse.scale,parts={},links={}}
 local folder=Instance.new('Folder');folder.Name='SkeletalHorseBarding';folder.Parent=parent;rig.folder=folder
 local function part(name,size,frame,color,bone,shape)
  local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size*rig.scale;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
  if shape=='ball'then local m=Instance.new('SpecialMesh');m.MeshType=Enum.MeshType.Sphere;m.Parent=p end
  if name:find('Armor')or name:find('Rim')then p.Material=Enum.Material.Metal end
  p.Parent=folder;table.insert(rig.parts,{part=p,bone=horse.byName[bone],offset=bind[bone]:ToObjectSpace(frame)})
  return p
 end
 local function line(name,a,b,width,color,bone)
  return part(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,bone,'ball')
 end
 local function jointLink(a,b,width)
  local p=part('LimbBone',Vector3.new(width,width,1),CFrame.identity,ivory,a,'ball')
  table.insert(rig.links,{part=p,a=horse.byName[a],b=horse.byName[b],width=width*rig.scale})
 end
 -- Open rib cage: paired arcs leave actual empty space between the ribs.
 for i=0,7 do
  local z=-.95+i*.49;local breadth=1.15+math.sin((i+1)/9*math.pi)*.22
  for _,side in ipairs({-1,1})do
   local previous=Vector3.new(0,1.12,z)
   for j=1,6 do
    local a=j/6*math.pi;local nextPoint=Vector3.new(side*math.sin(a)*breadth,.05+math.cos(a)*1.07,z)
    line('RibBone',previous,nextPoint,.16,pale,'Torso2');previous=nextPoint
   end
  end
 end
 for i=0,10 do
  part('SpineVertebra',Vector3.new(.47,.4,.39),CFrame.new(0,1.13,-1.45+i*.52),ivory,'Torso2','ball')
  part('SpinalProcess',Vector3.new(.13,.36,.15),CFrame.new(0,1.44,-1.45+i*.52),pale,'Torso2','wedge')
 end
 line('Sternum',Vector3.new(0,-1.02,-.7),Vector3.new(0,-1.02,2.1),.23,ivory,'Torso2')
 for _,side in ipairs({-1,1})do
  line('PelvicArch',Vector3.new(0,1.38,3.4),Vector3.new(side*.98,.38,3.7),.48,ivory,'Back')
  line('Pelvis',Vector3.new(side*.98,.38,3.7),Vector3.new(side*.8,.35,2.75),.43,ivory,'Back')
 end
 for _,side in ipairs({'L','R'})do
  jointLink('FrontShoulder.'..side,'FrontUpperLeg.'..side,.39)
  jointLink('FrontUpperLeg.'..side,'FrontLowerLeg.'..side,.3)
  jointLink('FrontLowerLeg.'..side,'FrontLowerLeg.'..side..'_end',.23)
  jointLink('BackShoulder.'..side,'BackLeg.'..side,.4)
  jointLink('BackLeg.'..side,'BackUpperLeg.'..side,.37)
  jointLink('BackUpperLeg.'..side,'BackLowerLeg.'..side,.29)
  jointLink('BackLowerLeg.'..side,'BackLowerLeg.'..side..'_end',.23)
  for _,name in ipairs({'FrontUpperLeg.','FrontLowerLeg.','BackUpperLeg.','BackLowerLeg.'})do
   local bone=name..side;part('KneeJoint',Vector3.one*.44,bind[bone],pale,bone,'ball')
  end
  for _,name in ipairs({'FrontLowerLeg.','BackLowerLeg.'})do
   local bone=name..side..'_end';local at=bind[bone].Position
   part('IronHoof',Vector3.new(.59,.55,.8),CFrame.new(at+Vector3.new(0,-.32,-.09)),steel,bone,'wedge')
   part('HoofRim',Vector3.new(.62,.12,.83),CFrame.new(at+Vector3.new(0,-.48,-.09)),rim,bone)
  end
 end
 for i,name in ipairs({'Neck1','Neck2','Neck3'})do
  local nextName=({'Neck2','Neck3','Head'})[i];jointLink(name,nextName,.47)
  local a,b=bind[name].Position,bind[nextName].Position
  for j=0,2 do
   local at=a:Lerp(b,j/3);part('NeckVertebra',Vector3.new(.66,.39,.5),CFrame.new(at),ivory,name,'ball')
   part('NeckArmorFin',Vector3.new(.16,.55,.52),CFrame.new(at+Vector3.new(0,.16,.36))*CFrame.Angles(-.35,0,0),steel,name,'wedge')
  end
 end
 -- Long equine skull: open sockets, cheek arches, thin muzzle and separated jaw/teeth.
 part('HorseCranium',Vector3.new(1.04,1.08,1.18),CFrame.new(0,3.75,-3.75),ivory,'Head','ball')
 part('NasalBridge',Vector3.new(.47,.47,1.67),CFrame.new(0,3.08,-4.64)*CFrame.Angles(-.48,0,0),pale,'Head','wedge')
 part('HorseMuzzle',Vector3.new(.83,.52,.64),CFrame.new(0,2.67,-5.31),ivory,'Head','ball')
 part('LowerJaw',Vector3.new(.68,.21,1.55),CFrame.new(0,2.35,-4.91)*CFrame.Angles(-.2,0,0),pale,'Head','wedge')
 for _,side in ipairs({-1,1})do
  part('EyeSocket',Vector3.new(.12,.49,.58),CFrame.new(side*.52,3.5,-4.04),dark,'Head','ball')
  local eye=part('SpectralHorseEye',Vector3.new(.14,.16,.18),CFrame.new(side*.585,3.5,-4.1),Color3.fromRGB(109,214,190),'Head','ball');eye.Material=Enum.Material.Neon
  line('CheekBone',Vector3.new(side*.53,3.24,-3.97),Vector3.new(side*.34,2.78,-5.02),.18,ivory,'Head')
  line('BrowBone',Vector3.new(side*.54,3.8,-3.84),Vector3.new(side*.5,3.69,-4.35),.19,pale,'Head')
  part('Nostril',Vector3.new(.1,.17,.2),CFrame.new(side*.39,2.75,-5.44),dark,'Head','ball')
  for j=0,5 do part('HorseTooth',Vector3.new(.13,.19,.16),CFrame.new(side*.31,2.52,-4.42-j*.18),pale,'Head')end
  -- Angular chanfron along the forehead, leaving the skull eyes and muzzle exposed.
  part('HeadArmor',Vector3.new(.48,.22,1.38),CFrame.new(side*.32,4.02,-3.87)*CFrame.Angles(-.32,0,side*-.17),steel,'Head','wedge')
  line('HeadArmorRim',Vector3.new(side*.54,4.04,-3.35),Vector3.new(side*.5,3.88,-4.5),.1,rim,'Head')
  line('EarBone',Vector3.new(side*.36,4.12,-3.56),Vector3.new(side*.58,4.84,-3.25),.22,ivory,'Head')
  part('ChestArmor',Vector3.new(.94,1.75,.42),CFrame.new(side*.67,.27,-1.79)*CFrame.Angles(0,side*.35,side*.22),steel,'Torso3','wedge')
  part('ChestArmorRim',Vector3.new(.99,.14,.48),CFrame.new(side*.67,1.02,-1.79)*CFrame.Angles(0,side*.35,side*.22),rim,'Torso3')
  part('HindArmor',Vector3.new(.23,1.38,1.63),CFrame.new(side*1.04,.59,3.35)*CFrame.Angles(0,side*.15,-side*.12),steel,'Back','wedge')
  for j=0,2 do part('FlankArmor',Vector3.new(.16,.52,1),CFrame.new(side*1.28,.67-j*.39,2.3+j*.17)*CFrame.Angles(0,0,-side*.13),steel,'Back','wedge')end
 end
 part('ChestArmorKeel',Vector3.new(.43,1.95,.58),CFrame.new(0,.22,-2),rim,'Torso3','wedge')
 for i=1,6 do
  jointLink('Tail'..i,'Tail'..(i+1),.2-i*.018)
  part('TailJoint',Vector3.one*(.32-i*.025),bind['Tail'..i],ivory,'Tail'..i,'ball')
 end
 horse.part.Transparency=1;horse.part.CastShadow=false
 horse.part:SetAttribute('HorseAppearance','ArmoredSkeleton')
 Art.pose(rig);return rig
end
function Art.pose(rig)
 for _,p in ipairs(rig.parts)do p.part.CFrame=p.bone.TransformedWorldCFrame*scaled(p.offset,rig.scale)end
 for _,p in ipairs(rig.links)do
  local a,b=p.a.TransformedWorldCFrame.Position,p.b.TransformedWorldCFrame.Position
  p.part.Size=Vector3.new(p.width,p.width,math.max(.05,(b-a).Magnitude))
  p.part.CFrame=CFrame.lookAt((a+b)/2,b)
 end
end
function Art.destroy(rig)if rig and rig.folder then rig.folder:Destroy()end end
return Art
