-- Original gilded knight and spectral warhorse. Server action progress drives weapon and body poses.
local Mount={}
local function riderGroup(group)return group and(group:match('^rider')or group=='weapon')end
local function scaled(cf)return cf.Rotation+cf.Position*1.8 end
local bone=Color3.fromRGB(165,166,150);local armor=Color3.fromRGB(42,49,68);local gold=Color3.fromRGB(178,139,65);local glow=Color3.fromRGB(90,215,196)
local function piece(rig,name,size,cf,color,shape,group)
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size*(riderGroup(group)and 1 or 1.8);p.Color=color;p.Material=riderGroup(group)and Enum.Material.Metal or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
 if shape=='ball'then local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p end
 p.Parent=rig.mountFolder;table.insert(rig.mountParts,{part=p,offset=cf,group=group});return p
end
local function beam(rig,name,a,b,w,color,group)
 return piece(rig,name,Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,'ball',group)
end
function Mount.create(model)
 local rig={model=model,hidden={}};for _,v in ipairs(model:GetDescendants())do if v:IsA('BasePart')and v.Name~='Core'then rig.hidden[v]=v.LocalTransparencyModifier;v.LocalTransparencyModifier=1 end end
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
 piece(rig,'HorseSkull',Vector3.new(1.2,1.55,2.1),CFrame.new(0,3.65,-2.85)*CFrame.Angles(.25,0,0),bone,'ball','neck')
 piece(rig,'Muzzle',Vector3.new(.95,.75,1.65),CFrame.new(0,3.1,-3.8)*CFrame.Angles(.25,0,0),bone,'ball','neck')
 piece(rig,'HorseJaw',Vector3.new(.9,.22,1.8),CFrame.new(0,2.85,-3.7)*CFrame.Angles(.15,0,0),bone,nil,'neck')
 piece(rig,'HorseFaceArmor',Vector3.new(1.12,.35,2.25),CFrame.new(0,4.08,-3.05)*CFrame.Angles(.25,0,0),gold,'wedge','neck')
 piece(rig,'NosePlate',Vector3.new(1.05,.34,.4),CFrame.new(0,2.92,-4.45),armor,nil,'neck')
 for _,side in ipairs({-1,1})do
  piece(rig,'HorseEar',Vector3.new(.3,.65,.45),CFrame.new(side*.42,4.45,-2.55)*CFrame.Angles(-.25,0,side*-.2),armor,'wedge','neck')
  local eye=piece(rig,'SpectralEye',Vector3.new(.08,.13,.23),CFrame.new(side*.6,3.65,-3.3),glow,'ball','neck');eye.Material=Enum.Material.Neon
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
 -- Original closed-helm royal lancer. No skeleton helmet, skull or shield is rendered.
 local steel=Color3.fromRGB(86,99,112);local paleGold=Color3.fromRGB(196,157,76);local dark=Color3.fromRGB(25,30,42);local cloth=Color3.fromRGB(35,46,73)
 piece(rig,'KnightCuirass',Vector3.new(2.6,2.15,1.5),CFrame.new(0,.1,0),gold,'ball','riderTorso')
 piece(rig,'BreastplateRidge',Vector3.new(.28,1.7,.3),CFrame.new(0,.15,-.72),paleGold,'wedge','riderTorso')
 for _,side in ipairs({-1,1})do
  piece(rig,'ChestEngraving',Vector3.new(.75,.11,.1),CFrame.new(side*.5,.48,-.7)*CFrame.Angles(0,0,side*.5),paleGold,nil,'riderTorso')
  piece(rig,'Tasset',Vector3.new(.8,1.35,.28),CFrame.new(side*.75,-1.3,-.7)*CFrame.Angles(-.2,0,side*-.15),gold,'wedge','riderTorso')
  piece(rig,'Collar',Vector3.new(.5,.5,1.3),CFrame.new(side*.62,1.1,0)*CFrame.Angles(0,0,side*-.25),paleGold,'wedge','riderTorso')
 end
 piece(rig,'KnightBelt',Vector3.new(1.9,.3,1.4),CFrame.new(0,-.85,0),dark,nil,'riderTorso')
 piece(rig,'BeltEmblem',Vector3.new(.4,.5,.16),CFrame.new(0,-.85,-.76),paleGold,'wedge','riderTorso')
 piece(rig,'ClosedHelmet',Vector3.new(1.85,2.1,1.65),CFrame.new(0,.15,0),paleGold,'ball','riderHead')
 piece(rig,'HelmetBrow',Vector3.new(1.8,.25,1.3),CFrame.new(0,.48,-.15),paleGold,'wedge','riderHead')
 piece(rig,'KnightVisor',Vector3.new(1.3,.22,.15),CFrame.new(0,.25,-.77),dark,nil,'riderHead')
 piece(rig,'VisorNose',Vector3.new(.2,.82,.28),CFrame.new(0,-.05,-.81),paleGold,'wedge','riderHead')
 for _,side in ipairs({-1,1})do
  local eye=piece(rig,'VisorEye',Vector3.new(.37,.06,.08),CFrame.new(side*.35,.28,-.86),Color3.fromRGB(241,206,117),nil,'riderHead');eye.Material=Enum.Material.Neon
  piece(rig,'CheekGuard',Vector3.new(.45,.85,.4),CFrame.new(side*.61,-.3,-.53)*CFrame.Angles(0,side*-.25,side*.1),gold,'wedge','riderHead')
 end
 for _,side in ipairs({-1,1})do piece(rig,'HelmetWing',Vector3.new(.22,1.5,1.5),CFrame.new(side*.9,1.05,.25)*CFrame.Angles(-.2,0,-side*.35),paleGold,'wedge','riderHead')end
 piece(rig,'HelmetCrest',Vector3.new(.3,1.9,1.4),CFrame.new(0,1.3,.05)*CFrame.Angles(-.22,0,0),paleGold,'wedge','riderHead')
 for j=1,6 do piece(rig,'RoyalPlume',Vector3.new(.35,.7,1.1),CFrame.new(0,1.65-j*.12,.35+j*.28)*CFrame.Angles(-.25-j*.05,0,0),j%2==0 and cloth or Color3.fromRGB(72,78,105),'wedge','riderHead')end
 for i=1,4 do piece(rig,'CommanderCape',Vector3.new(.8,3.1,.16),CFrame.new((i-2.5)*.68,-.5,.8)*CFrame.Angles(.22,0,(i-2.5)*-.04),cloth,'wedge','riderTorso')end
 for _,side in ipairs({'R','L'})do
  local g='riderUpper'..side
  piece(rig,'LayeredPauldron',Vector3.new(1.7,.95,1.9),CFrame.new(),gold,'ball',g)
  piece(rig,'PauldronRim',Vector3.new(1.85,.18,1.95),CFrame.new(0,.25,0),paleGold,nil,g)
  for j=1,3 do piece(rig,'PauldronLamella',Vector3.new(1.6,.3,1.7),CFrame.new((side=='R'and 1 or -1)*j*.1,-j*.2,0)*CFrame.Angles(0,0,(side=='R'and 1 or -1)*-.15),j==3 and paleGold or gold,'wedge',g)end
  piece(rig,'UpperArmArmor',Vector3.new(.62,1.35,.7),CFrame.new(0,-.65,0),steel,'ball',g)
  piece(rig,'ForearmArmor',Vector3.new(.67,1.3,.72),CFrame.new(0,-.65,0),gold,'ball','riderLower'..side)
  piece(rig,'Gauntlet',Vector3.new(.58,.55,.6),CFrame.identity,steel,'ball','riderHand'..side)
  piece(rig,'ThighArmor',Vector3.new(.75,1.65,.8),CFrame.new(0,-.8,0),steel,'ball','riderThigh'..side)
  piece(rig,'KneeGuard',Vector3.new(.9,.65,.65),CFrame.new(0,0,-.2),paleGold,'wedge','riderShin'..side)
  piece(rig,'Greave',Vector3.new(.67,1.6,.72),CFrame.new(0,-.8,0),gold,'ball','riderShin'..side)
  piece(rig,'Sabatons',Vector3.new(.76,.5,1.25),CFrame.new(0,-1.55,-.3),steel,'wedge','riderShin'..side)
 end
 -- A long shaft, forward spike, broad beveled axe and rear hook share one animated frame.
 local shaft=piece(rig,'HalberdShaft',Vector3.new(.19,13.3,.19),CFrame.new(0,0,0),Color3.fromRGB(68,49,35),nil,'weapon')
 local a=Instance.new('Attachment');a.Position=Vector3.new(2.1,4.65,0);a.Parent=shaft
 local b=Instance.new('Attachment');b.Position=Vector3.new(2.65,6.3,0);b.Parent=shaft
 local trail=Instance.new('Trail');trail.Name='HalberdTrail';trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.18;trail.MinLength=.12;trail.LightEmission=.7;trail.Color=ColorSequence.new(Color3.fromRGB(255,225,157),Color3.fromRGB(167,122,48));trail.Transparency=NumberSequence.new(.3,1);trail.Enabled=false;trail.Parent=shaft;rig.weaponTrail=trail
 for i=-6,6 do piece(rig,'HalberdGoldBand',Vector3.new(.29,.15,.29),CFrame.new(0,i,0),paleGold,nil,'weapon')end
 piece(rig,'HalberdButtSpike',Vector3.new(.28,.9,.28),CFrame.new(0,-7,0)*CFrame.Angles(math.pi,0,0),steel,'wedge','weapon')
 piece(rig,'HalberdRearHook',Vector3.new(1.3,.6,.22),CFrame.new(-.6,5.75,0)*CFrame.Angles(0,0,-.35),paleGold,'wedge','weapon')
 local function triangle(a,b,c,color,name)
  local ab,ac,bc=b-a,c-a,c-b
  if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b;local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit;local height=math.abs(ab:Dot(up))
  for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do
   if v[4]>.005 then piece(rig,name or'HalberdBladeFacet',Vector3.new(.025,height,v[4]),CFrame.fromMatrix((a+v[1])/2,v[2],up,v[3]),color,'wedge','weapon')end
  end
 end
 local tip=Vector3.new(0,8.3,0);local collar={Vector3.new(-.28,6.4,0),Vector3.new(0,6.4,.22),Vector3.new(.28,6.4,0),Vector3.new(0,6.4,-.22)}
 for i,a in ipairs(collar)do triangle(tip,a,collar[i%4+1],Color3.fromRGB(217,222,221),'HalberdSpearhead')end
 local outline={Vector3.new(0,3,0),Vector3.new(0,4.1,0),Vector3.new(2.25,4.85,0),Vector3.new(2.65,4.3,0),Vector3.new(2.7,3.8,0),Vector3.new(2.5,3.2,0),Vector3.new(2.1,2.65,0)}
 for i,a in ipairs(outline)do outline[i]=a+Vector3.new(0,2,0)end
 for i,a in ipairs(outline)do local b=outline[i%#outline+1]
  triangle(Vector3.new(1.2,5.7,.22),a,b,i%2==0 and paleGold or gold)
  triangle(Vector3.new(1.2,5.7,-.22),b,a,i%2==0 and gold or paleGold)
  beam(rig,'HalberdBladeEdge',a,b,.055,Color3.fromRGB(237,226,184),'weapon')
 end
 model:SetAttribute('EquipmentCount',1);model:SetAttribute('CommanderStyle','GildedHalberdKnight');model:SetAttribute('SkeletonMeshStatus','Ready')
 rig.stride=10;Mount.pose(rig,model:GetPivot(),0,'idle');return rig
end
local function ease(t)return t*t*(3-2*t)end
local function downward(a,b)return CFrame.lookAt(a,b)*CFrame.Angles(math.pi/2,0,0)end
function Mount.pose(rig,origin,time,mode)
 rig.mountTime=time;rig.mountMode=mode
 local action=rig.model:GetAttribute('FieldAction')or mode;local progress=rig.model:GetAttribute('FieldProgress')or 0
 local phase=time*math.pi*2/1.15;local moving=action=='approach'or action=='charge'
 local bounce=moving and math.abs(math.sin(phase))*.13 or 0
 local rear=action=='slamWindup'and ease(progress)*.22 or(action=='slam'and(1-ease(math.min(1,progress*2)))*.22 or 0)
 rig.horseFrame=origin*CFrame.new(0,.96+bounce,0)*scaled(CFrame.new(0,0,1.9))*CFrame.Angles(rear,0,0)*scaled(CFrame.new(0,0,-1.9))
 local torso=rig.horseFrame*CFrame.new(0,4.95,.2)*CFrame.Angles(moving and -.08 or 0,0,0)
 local ready=CFrame.new(2,.1,-.55)*CFrame.Angles(-.1,0,-.22);local weapon=ready
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
 local lengths={};local frames={riderTorso=torso,riderHead=torso*CFrame.new(0,2.3,0),weapon=torso*weapon}
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
  if v.group=='neck'then frame=frame*scaled(CFrame.new(0,1.4,-1.35))*CFrame.Angles(moving and math.sin(phase)*.055 or 0,0,0)*scaled(CFrame.new(0,-1.4,1.35))
  elseif v.group=='tail'then frame=frame*CFrame.Angles(0,math.sin(time*2)*.12,0)
  elseif v.group and not riderGroup(v.group)then
   local index=tonumber(v.group:match('%d+'));local leg=rig.legs[index];local swing=moving and math.sin(phase+leg.phase)*.55 or 0
   if not leg.rear then swing+=rear*3 end
   frame=frame*scaled(leg.hip)*CFrame.Angles(swing,0,0)
   if v.group:find('lower')then frame=frame*scaled(CFrame.new(0,-1.4,0))*CFrame.Angles(moving and math.max(0,-math.sin(phase+leg.phase))*.9 or .12,0,0)end
  end
  local offset=v.offset
  if(v.part.Name=='UpperArmArmor'or v.part.Name=='ForearmArmor')and lengths[v.group]then local length=lengths[v.group];v.part.Size=Vector3.new(v.part.Size.X,length,v.part.Size.Z);offset=CFrame.new(0,-length/2,0)end
  v.part.CFrame=frame*(riderGroup(v.group)and offset or scaled(offset))
 end
 rig.weaponTrail.Enabled=action=='cleave'or action=='slam'or action=='thrust'or action=='charge'
 rig.model:SetAttribute('CommanderMotion',action)
end
function Mount.place(rig,origin)Mount.pose(rig,origin,rig.mountTime or 0,rig.mountMode or'idle')end
function Mount.duration()return .8 end
function Mount.destroy(rig)
 if rig.destroyed then return end;rig.destroyed=true
 if rig.mountFolder then rig.mountFolder:Destroy()end
 for part,value in pairs(rig.hidden)do if part.Parent then part.LocalTransparencyModifier=value end end
end
return Mount
