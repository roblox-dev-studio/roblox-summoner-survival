-- Skeletal greatsword commander on Quaternius CC0 animated horse.
local horseMesh=require(script.Parent.HorseMesh)
local skullMesh=require(script.Parent.CommanderSkull)
local skeletonHorse=require(script.Parent.SkeletonHorse)
local Mount={}
local SCALE=1.8
local function scaled(cf)return CFrame.new(cf.Position*SCALE)*cf.Rotation end
local function riderGroup(group)return group and(group:match('^rider')or group=='weapon'or group=='mount')end
local plate=Color3.fromRGB(55,61,73)
local function piece(rig,name,size,cf,color,shape,group)
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size*SCALE*(riderGroup(group)and 1 or 1.8);p.Color=color;p.Material=riderGroup(group)and Enum.Material.Metal or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
 if shape=='ball'then local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p end
 if name=='ExposedNeck'or name=='UpperArmArmor'or name=='ForearmArmor'or name=='Gauntlet'then p.Material=Enum.Material.SmoothPlastic elseif name:find('Hood')or name=='CommanderCape'then p.Material=Enum.Material.Fabric elseif group=='mount'or name=='LeatherHarness'then p.Material=Enum.Material.SmoothPlastic end
 p.Parent=rig.mountFolder;table.insert(rig.mountParts,{part=p,offset=cf,group=group});return p
end
local function beam(rig,name,a,b,w,color,group)
 return piece(rig,name,Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,'ball',group)
end
function Mount.create(model)
 local rig={model=model,hidden={}}
 rig.mountFolder=Instance.new('Folder');rig.mountFolder.Name='SpectralWarhorse';rig.mountFolder.Parent=model;rig.mountParts={}
 rig.horse=horseMesh.create(rig.mountFolder,SCALE)
 if not rig.horse then rig.mountFolder:Destroy();return nil end
 rig.barding=skeletonHorse.create(rig.horse,rig.mountFolder)
 for _,v in ipairs(model:GetChildren())do if v:IsA('BasePart')and v.Name~='Core'then rig.hidden[v]=v.LocalTransparencyModifier;v.LocalTransparencyModifier=1 end end
 piece(rig,'Saddle',Vector3.new(2.25,.4,2.3),CFrame.new(0,.05,0),Color3.fromRGB(52,32,28),'ball','mount')
 piece(rig,'SaddleBack',Vector3.new(2.1,.65,.3),CFrame.new(0,.4,1.05),Color3.fromRGB(44,31,28),'wedge','mount')
 for _,side in ipairs({-1,1})do
  piece(rig,'SaddleCloth',Vector3.new(.14,1.3,2.7),CFrame.new(side*1.1,-.5,0),Color3.fromRGB(67,27,36),'wedge','mount')
 end
 -- Weathered steel, leather harness and a torn wine-red cloak; no royal ornament.
 local steel=Color3.fromRGB(86,99,112);local edge=Color3.fromRGB(145,153,165);local dark=Color3.fromRGB(25,30,42);local cloth=Color3.fromRGB(65,25,35)
 piece(rig,'KnightCuirass',Vector3.new(2.6,2.15,1.5),CFrame.new(0,.1,0),plate,'ball','riderTorso')
 piece(rig,'BreastplateRidge',Vector3.new(.28,1.7,.3),CFrame.new(0,.15,-.72),edge,'wedge','riderTorso')
 for _,side in ipairs({-1,1})do
  piece(rig,'LeatherHarness',Vector3.new(.75,.11,.1),CFrame.new(side*.5,.48,-.7)*CFrame.Angles(0,0,side*.5),Color3.fromRGB(66,40,30),nil,'riderTorso')
  piece(rig,'Tasset',Vector3.new(.8,1.35,.28),CFrame.new(side*.75,-1.3,-.7)*CFrame.Angles(-.2,0,side*-.15),plate,'wedge','riderTorso')
  piece(rig,'Collar',Vector3.new(.5,.5,1.3),CFrame.new(side*.62,1.1,0)*CFrame.Angles(0,0,side*-.25),edge,'wedge','riderTorso')
 end
 piece(rig,'KnightBelt',Vector3.new(1.9,.3,1.4),CFrame.new(0,-.85,0),dark,nil,'riderTorso')
 piece(rig,'BeltEmblem',Vector3.new(.4,.5,.16),CFrame.new(0,-.85,-.76),edge,'wedge','riderTorso')
 -- Original warrior skull with exposed teeth/eye sockets and its open knight helmet.
 rig.skull=skullMesh.create(rig.mountFolder,SCALE)
 if not rig.skull then horseMesh.destroy(rig.horse);rig.mountFolder:Destroy();return nil end
 table.insert(rig.mountParts,{part=rig.skull.part,offset=CFrame.new(0,.25,0),group='riderHead'})
 local bone=Color3.fromRGB(215,206,176)
 piece(rig,'ExposedNeck',Vector3.new(.45,.75,.42),CFrame.new(0,1.4,0),bone,'ball','riderTorso')
 for i=1,4 do piece(rig,'CommanderCape',Vector3.new(.8,3.1,.16),CFrame.new((i-2.5)*.68,-.5,.8)*CFrame.Angles(.22,0,(i-2.5)*-.04),cloth,'wedge','riderTorso')end
 for _,side in ipairs({'R','L'})do
  local g='riderUpper'..side
  piece(rig,'LayeredPauldron',Vector3.new(1.4,.85,1.65),CFrame.new(),plate,'ball',g)
  piece(rig,'PauldronRim',Vector3.new(1.55,.14,1.7),CFrame.new(0,.25,0),edge,nil,g)
  for j=1,2 do piece(rig,'PauldronLamella',Vector3.new(1.6,.3,1.7),CFrame.new((side=='R'and 1 or -1)*j*.1,-j*.2,0)*CFrame.Angles(0,0,(side=='R'and 1 or -1)*-.15),j==3 and edge or plate,'wedge',g)end
  piece(rig,'UpperArmArmor',Vector3.new(.36,1.35,.4),CFrame.new(0,-.65,0),bone,'ball',g)
  piece(rig,'ForearmArmor',Vector3.new(.35,1.3,.39),CFrame.new(0,-.65,0),bone,'ball','riderLower'..side)
  piece(rig,'Gauntlet',Vector3.new(.58,.55,.6),CFrame.identity,bone,'ball','riderHand'..side)
  piece(rig,'ThighArmor',Vector3.new(.75,1.65,.8),CFrame.new(0,-.8,0),steel,'ball','riderThigh'..side)
  piece(rig,'KneeGuard',Vector3.new(.9,.65,.65),CFrame.new(0,0,-.2),edge,'wedge','riderShin'..side)
  piece(rig,'Greave',Vector3.new(.67,1.6,.72),CFrame.new(0,-.8,0),plate,'ball','riderShin'..side)
  piece(rig,'Sabatons',Vector3.new(.76,.5,1.25),CFrame.new(0,-1.55,-.3),steel,'wedge','riderShin'..side)
 end
 -- A true two-edged greatsword: short leather grip, steel crossguard and tapered ridge blade.
 local grip=piece(rig,'GreatswordGrip',Vector3.new(.28,1.8,.3),CFrame.new(0,-.3,0),Color3.fromRGB(48,30,27),nil,'weapon')
 for i=0,6 do piece(rig,'GripWrap',Vector3.new(.32,.07,.34),CFrame.new(0,-1.05+i*.23,0),Color3.fromRGB(76,48,36),nil,'weapon')end
 piece(rig,'SwordCrossguard',Vector3.new(2.3,.22,.4),CFrame.new(0,.66,0),edge,nil,'weapon')
 for _,side in ipairs({-1,1})do piece(rig,'GuardQuillon',Vector3.new(.55,.3,.35),CFrame.new(side*1.2,.52,0)*CFrame.Angles(0,0,-side*.3),steel,'wedge','weapon')end
 piece(rig,'SwordPommel',Vector3.new(.5,.5,.45),CFrame.new(0,-1.4,0),edge,'ball','weapon')
 local function triangle(a,b,c,color)
  local ab,ac,bc=b-a,c-a,c-b
  if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b;local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit;local height=math.abs(ab:Dot(up))
  for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do if v[4]>.005 then piece(rig,'GreatswordBladeFacet',Vector3.new(.025,height,v[4]),CFrame.fromMatrix((a+v[1])/2,v[2],up,v[3]),color,'wedge','weapon')end end
 end
 local outline={Vector3.new(-.6,.85,0),Vector3.new(-.5,5.4,0),Vector3.new(0,7.3,0),Vector3.new(.5,5.4,0),Vector3.new(.6,.85,0)}
 for i,a in ipairs(outline)do local b=outline[i%#outline+1];triangle(Vector3.new(0,3.8,.2),a,b,i%2==0 and Color3.fromRGB(174,188,204)or edge);triangle(Vector3.new(0,3.8,-.2),b,a,i%2==0 and edge or Color3.fromRGB(117,133,153));beam(rig,'SwordEdge',a,b,.045,Color3.fromRGB(217,227,235),'weapon')end
 local a=Instance.new('Attachment');a.Position=Vector3.new(0,1,0)*SCALE;a.Parent=grip
 local b=Instance.new('Attachment');b.Position=Vector3.new(0,7.3,0)*SCALE;b.Parent=grip
 local trail=Instance.new('Trail');trail.Name='GreatswordTrail';trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.14;trail.MinLength=.12;trail.LightEmission=.4;trail.Color=ColorSequence.new(Color3.fromRGB(218,226,240),Color3.fromRGB(104,114,139));trail.Transparency=NumberSequence.new(.45,1);trail.Enabled=false;trail.Parent=grip;rig.weaponTrail=trail
 model:SetAttribute('EquipmentCount',1);model:SetAttribute('CommanderStyle','SkeletonKnightCommander');model:SetAttribute('SkeletonMeshStatus','Ready')
 model:SetAttribute('CommanderVisualScale',SCALE);rig.stride=10;Mount.pose(rig,model:GetPivot(),0,'idle');return rig
end
local function ease(t)return t*t*(3-2*t)end
local function downward(a,b)return CFrame.lookAt(a,b)*CFrame.Angles(math.pi/2,0,0)end
function Mount.pose(rig,origin,time,mode)
 rig.mountTime=time;rig.mountMode=mode
 local action=rig.model:GetAttribute('FieldAction')or mode;local progress=rig.model:GetAttribute('FieldProgress')or 0
 local moving=action=='approach'or action=='charge'

 local rear=action=='slamWindup'and ease(progress)*.22 or(action=='slam'and(1-ease(math.min(1,progress*2)))*.22 or 0)
 rig.horseFrame=origin*CFrame.new(0,0,3.5)*CFrame.Angles(rear,0,0)*CFrame.new(0,0,-3.5)
 local horseMode=action=='charge'and'gallop'or(action=='approach'and'walk'or'idle')
 horseMesh.pose(rig.horse,rig.horseFrame,action=='charge'and progress*.8 or time,horseMode)
 skeletonHorse.pose(rig.barding)
 local actualBack=rig.horse.byName.Torso2.TransformedWorldCFrame.Position
 local back=rig.horseFrame:PointToWorldSpace(rig.horseFrame:PointToObjectSpace(actualBack-Vector3.new(0,3*(SCALE-1),0))/SCALE)
 local seat=CFrame.new(back+rig.horseFrame.UpVector*.8)*rig.horseFrame.Rotation
 local torso=seat*CFrame.new(0,1.6,.1)*CFrame.Angles(moving and -.08 or 0,0,0)
 local ready=CFrame.new(1.6,.1,-.7)*CFrame.Angles(-.25,0,-.45);local weapon=ready
 if action=='cleaveWindup'then weapon=ready:Lerp(CFrame.new(.5,.55,-.7)*CFrame.Angles(0,-1.3,0)*CFrame.Angles(-2.2,0,0),ease(progress));torso*=CFrame.Angles(0,-progress*.25,0)
 elseif action=='cleave'then weapon=CFrame.new(.5,.55,-.7)*CFrame.Angles(0,-1.3+2.6*ease(progress),0)*CFrame.Angles(-2.2,0,0);torso*=CFrame.Angles(0,-.25+progress*.5,0)
 elseif action=='slamWindup'then weapon=ready:Lerp(CFrame.new(.2,2.8,.1)*CFrame.Angles(.35,0,.1),ease(progress))
 elseif action=='slam'then weapon=CFrame.new(.2,2.8,.1):Lerp(CFrame.new(.2,-2.8,-2.4),ease(math.min(1,progress*2)))*CFrame.Angles(.35-2.85*ease(math.min(1,progress*2)),0,.1)
 elseif action=='thrustWindup'then weapon=ready:Lerp(CFrame.new(.8,.1,.5)*CFrame.Angles(-math.pi/2,0,0),ease(progress))
 elseif action=='thrust'then weapon=CFrame.new(.8,.1,.5-3.8*math.sin(math.min(1,progress*1.6)*math.pi/2))*CFrame.Angles(-math.pi/2,0,0)
 elseif action=='chargeWindup'or action=='charge'then weapon=CFrame.new(1,.3,-1.5)*CFrame.Angles(-1.3,0,-.12)end
 if action=='recover'then
  if rig.lastAction~='recover'then rig.recoveryWeapon=rig.weaponRelative or ready end
  weapon=rig.recoveryWeapon:Lerp(ready,ease(progress))
 end
 rig.weaponRelative=weapon;rig.lastAction=action
 local lengths={};local frames={mount=seat,riderTorso=torso,riderHead=torso*CFrame.new(0,2.3,0),weapon=torso*weapon}
 for _,side in ipairs({'R','L'})do
  local sign=side=='R'and 1 or -1
  local shoulder=torso:PointToWorldSpace(Vector3.new(sign*1.4,.65,0))
  local hand=frames.weapon:PointToWorldSpace(Vector3.new(0,side=='R'and -.8 or .45,0))
  local elbow=(shoulder+hand)/2+torso.RightVector*sign*.48+torso.LookVector*-.2
  lengths['riderUpper'..side]=(shoulder-elbow).Magnitude;lengths['riderLower'..side]=(elbow-hand).Magnitude
  frames['riderUpper'..side]=downward(shoulder,elbow);frames['riderLower'..side]=downward(elbow,hand);frames['riderHand'..side]=CFrame.new(hand)*frames.weapon.Rotation
  local hip=torso*CFrame.new(sign*.68,-.8,0)*CFrame.Angles(-1.15,0,sign*-.25)
  frames['riderThigh'..side]=hip;frames['riderShin'..side]=hip*CFrame.new(0,-1.55,0)*CFrame.Angles(1.3,0,0)
 end
 for _,v in ipairs(rig.mountParts)do
  local frame=frames[v.group]or rig.horseFrame
  local offset=v.offset
  if(v.part.Name=='UpperArmArmor'or v.part.Name=='ForearmArmor')and lengths[v.group]then local length=lengths[v.group];v.part.Size=Vector3.new(v.part.Size.X,length*SCALE,v.part.Size.Z);offset=CFrame.new(0,-length/2,0)end
  if v.part.Name=='CommanderCape'then offset*=CFrame.Angles(math.sin(time*3+v.offset.Position.X)*.045,0,0)end
  v.part.CFrame=origin*CFrame.new(0,3*(SCALE-1),0)*scaled(origin:ToObjectSpace(frame*offset))
 end
 rig.weaponTrail.Enabled=action=='cleave'or action=='slam'or action=='thrust'or action=='charge'
 rig.model:SetAttribute('CommanderMotion',action)
end
function Mount.place(rig,origin)Mount.pose(rig,origin,rig.mountTime or 0,rig.mountMode or'idle')end
function Mount.duration(_,mode)return horseMesh.duration(mode=='walk'and'walk'or'idle')end
function Mount.releaseUnused()horseMesh.releaseUnused();skullMesh.releaseUnused()end
function Mount.destroy(rig)
 if rig.destroyed then return end;rig.destroyed=true
 if rig.horse then horseMesh.destroy(rig.horse)end
 skullMesh.destroy(rig.skull);skeletonHorse.destroy(rig.barding)
 if rig.mountFolder then rig.mountFolder:Destroy()end
 for part,value in pairs(rig.hidden)do if part.Parent then part.LocalTransparencyModifier=value end end
end
return Mount
