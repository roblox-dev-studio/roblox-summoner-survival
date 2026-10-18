-- Original low-poly spectral warhorse; mounted rider reuses the pinned CC0 skeleton.
local skeleton=require(script.Parent.SkeletonMesh)
local Mount={}
local function scaled(cf)return cf.Rotation+cf.Position*1.8 end
local bone=Color3.fromRGB(165,166,150);local armor=Color3.fromRGB(42,49,68);local gold=Color3.fromRGB(156,123,65);local glow=Color3.fromRGB(90,215,196)
local function piece(rig,name,size,cf,color,shape,group)
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size*((group=='crown'or group=='cape')and 1 or 1.8);p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
 if shape=='ball'then local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p end
 p.Parent=rig.mountFolder;table.insert(rig.mountParts,{part=p,offset=cf,group=group});return p
end
local function beam(rig,name,a,b,w,color,group)
 return piece(rig,name,Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,'ball',group)
end
function Mount.create(model)
 local rig=skeleton.create(model);if not rig then return nil end
 rig.mountFolder=Instance.new('Folder');rig.mountFolder.Name='SpectralWarhorse';rig.mountFolder.Parent=model;rig.mountParts={}
 -- A long equine barrel, high withers, sloping neck and narrow muzzle distinguish it from the hound.
 piece(rig,'HorseBarrel',Vector3.new(2.3,2.1,4.6),CFrame.new(0,1.25,.25),armor,'ball')
 piece(rig,'HorseRump',Vector3.new(2.25,2,2.1),CFrame.new(0,1.25,2.2),armor,'ball')
 piece(rig,'Saddle',Vector3.new(2.35,.45,2.2),CFrame.new(0,2.35,.2),Color3.fromRGB(74,40,43),'ball')
 piece(rig,'SaddleBack',Vector3.new(2.2,.8,.35),CFrame.new(0,2.65,1.15)*CFrame.Angles(-.2,0,0),gold,'wedge')
 for _,side in ipairs({-1,1})do
  piece(rig,'Barding',Vector3.new(.22,1.6,3.1),CFrame.new(side*1.18,1.25,.3)*CFrame.Angles(0,0,side*.12),Color3.fromRGB(37,49,80),'wedge')
  for j=1,4 do beam(rig,'HorseRib',Vector3.new(side*.85,1.9,-.9+j*.65),Vector3.new(side*1.3,.7,-.8+j*.65),.18,bone)end
  piece(rig,'BardingTrim',Vector3.new(.26,.12,3.2),CFrame.new(side*1.28,.65,.3),gold)
 end
 beam(rig,'Neck',Vector3.new(0,1.4,-1.35),Vector3.new(0,3.4,-2.7),1.35,armor,'neck')
 piece(rig,'HorseSkull',Vector3.new(1.2,1.55,2.1),CFrame.new(0,3.65,-2.85)*CFrame.Angles(.25,0,0),bone,'wedge','neck')
 piece(rig,'Muzzle',Vector3.new(.95,.75,1.65),CFrame.new(0,3.1,-3.8)*CFrame.Angles(.25,0,0),bone,'wedge','neck')
 piece(rig,'HorseJaw',Vector3.new(.9,.22,1.8),CFrame.new(0,2.85,-3.7)*CFrame.Angles(.15,0,0),bone,nil,'neck')
 piece(rig,'NosePlate',Vector3.new(1.05,.34,.4),CFrame.new(0,2.92,-4.45),armor,nil,'neck')
 for _,side in ipairs({-1,1})do
  piece(rig,'HorseEar',Vector3.new(.3,.95,.45),CFrame.new(side*.42,4.45,-2.55)*CFrame.Angles(-.25,0,side*-.2),armor,'wedge','neck')
  local eye=piece(rig,'SpectralEye',Vector3.new(.12,.22,.4),CFrame.new(side*.6,3.65,-3.3),glow,'ball','neck');eye.Material=Enum.Material.Neon
  beam(rig,'Reins',Vector3.new(side*.65,3.15,-3.45),Vector3.new(side*.55,3.15,-.4),.07,Color3.fromRGB(110,90,62),'neck')
 end
 for j=1,7 do piece(rig,'Mane',Vector3.new(.48,.65,.5),CFrame.new(0,3.3-j*.2,-2.15+j*.18)*CFrame.Angles(-.45,0,0),Color3.fromRGB(26,32,48),'wedge','neck')end
 -- Each leg has a hip hinge and a separate knee; motion is distance driven.
 rig.legs={}
 for _,side in ipairs({-1,1})do for _,rear in ipairs({false,true})do
  local index=#rig.legs+1;local z=rear and 1.9 or -1.25
  table.insert(rig.legs,{hip=CFrame.new(side*.82,.85,z),rear=rear,phase=(side==1 and math.pi or 0)+(rear and math.pi or 0)})
  local group='upper'..index;beam(rig,'HorseUpperLeg',Vector3.zero,Vector3.new(0,-1.4,0),.42,bone,group)
  piece(rig,'HorseKnee',Vector3.one*.57,CFrame.new(0,-1.35,0),armor,'ball',group)
  group='lower'..index;beam(rig,'HorseShin',Vector3.zero,Vector3.new(0,-1.5,.1),.26,bone,group)
  piece(rig,'Hoof',Vector3.new(.65,.48,.8),CFrame.new(0,-1.45,-.15),armor,nil,group)
 end end
 for j=1,5 do beam(rig,'Tail',Vector3.new(0,1.65,2.8+(j-1)*.4),Vector3.new(0,1.65-j*.24,2.8+j*.4),.4-j*.045,Color3.fromRGB(35,40,57),'tail')end
 -- Royal silhouette: original chipped crown, long navy cape and narrow greatsword.
 for i=1,7 do local a=i*math.pi*2/7;piece(rig,'CrownPoint',Vector3.new(.22,i==3 and .35 or .65,.28),CFrame.new(math.cos(a)*.75,1.9,math.sin(a)*.65),gold,'wedge','crown')end
 for _,side in ipairs({-1,1})do piece(rig,'CrownBand',Vector3.new(.15,.22,1.4),CFrame.new(side*.7,1.6,0),gold,nil,'crown')end
 for i=1,3 do piece(rig,'CommanderCape',Vector3.new(1.25,3.4,.2),CFrame.new((i-2)*1.05,-1.3,1.05)*CFrame.Angles(.18,0,(i-2)*-.04),Color3.fromRGB(32,44,75),'wedge','cape')end
 rig.stride=10;Mount.pose(rig,model:GetPivot(),0,'idle');return rig
end
function Mount.pose(rig,origin,time,mode)
 rig.mountTime=time;rig.mountMode=mode
 local phase=time*math.pi*2/1.15;local moving=mode=='walk'or rig.model:GetAttribute('FieldAction')=='charge'
 local bounce=moving and math.abs(math.sin(phase))*.13 or math.sin(time*1.6)*.025
 rig.horseFrame=origin*CFrame.new(0,.96+bounce,0)
 -- Skeleton origin normally has its feet at Y=0; lift the seated rider onto the saddle.
 local rider=rig.horseFrame*CFrame.new(0,5.65,.18)*CFrame.Angles(moving and -.08 or 0,0,0)
 skeleton.pose(rig,rider,time,mode=='walk'and'guard'or mode)
 for _,v in ipairs(rig.mountParts)do
  local frame=rig.horseFrame
  if v.group=='crown'then frame=rig.byName.head.TransformedWorldCFrame
  elseif v.group=='cape'then frame=rig.origin
  elseif v.group=='neck'then frame=frame*scaled(CFrame.new(0,1.4,-1.35))*CFrame.Angles(moving and math.sin(phase)*.055 or 0,0,0)*scaled(CFrame.new(0,-1.4,1.35))
  elseif v.group=='tail'then frame=frame*CFrame.Angles(0,math.sin(time*2)*.12,0)
  elseif v.group then
   local index=tonumber(v.group:match('%d+'));local leg=rig.legs[index];local swing=moving and math.sin(phase+leg.phase)*.55 or 0
   frame=frame*scaled(leg.hip)*CFrame.Angles(swing,0,0)
   if v.group:find('lower')then frame=frame*scaled(CFrame.new(0,-1.4,0))*CFrame.Angles(moving and math.max(0,-math.sin(phase+leg.phase))*.9 or .12,0,0)end
  end
  v.part.CFrame=frame*((v.group=='crown'or v.group=='cape')and v.offset or scaled(v.offset))
 end
 -- Enlarge the blade along its original length while keeping the imported handle attached.
 for _,item in ipairs(rig.gear or{})do if item.part:GetAttribute('Weapon')=='Blade'then item.part.Size=item.source.part.Size*rig.scale*Vector3.new(1.1,1.65,1.1)end end
end
function Mount.place(rig,origin)Mount.pose(rig,origin,rig.mountTime or 0,rig.mountMode or'idle')end
function Mount.duration(rig,mode)return skeleton.duration(rig,mode)end
function Mount.destroy(rig)if rig.mountFolder then rig.mountFolder:Destroy()end;skeleton.destroy(rig)end
return Mount
