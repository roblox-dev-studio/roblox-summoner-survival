-- Original procedural ash-hound: articulated paws/jaw/tail, no external model/code.
local Mesh={}
local dark=Color3.fromRGB(45,43,54);local bone=Color3.fromRGB(185,164,137);local iron=Color3.fromRGB(87,65,64)
local function piece(parent,name,size,color,shape)
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size;p.Color=color;p.Material=Enum.Material.Slate;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 if shape=='ball'then local m=Instance.new('SpecialMesh');m.MeshType=Enum.MeshType.Sphere;m.Parent=p end
 p.Parent=parent;return p
end
function Mesh.create(model)
 if not model.Parent then return nil end
 local visual=Instance.new('Model');visual.Name='AshHound';local scale=model:GetScale()
 local rig={model=model,visual=visual,scale=scale,hidden={},static={},legs={},stride=9}
 local function fixed(name,size,position,color,shape,rotation)
  local p=piece(visual,name,size*scale,color,shape);table.insert(rig.static,{part=p,cf=CFrame.new(position*scale)*(rotation or CFrame.identity)});return p
 end
 fixed('Ribcage',Vector3.new(2.25,2,4.6),Vector3.new(0,-.45,.25),dark,'ball')
 fixed('HunchedShoulders',Vector3.new(2.7,2.4,2.35),Vector3.new(0,-.1,-1.05),dark,'ball')
 fixed('Skull',Vector3.new(1.65,1.4,2.05),Vector3.new(0,.05,-2.65),bone,'ball')
 fixed('Snout',Vector3.new(1.05,.65,1.65),Vector3.new(0,-.3,-3.65),bone,'ball')
 rig.jaw=piece(visual,'LowerJaw',Vector3.new(1.2,.34,1.7)*scale,Color3.fromRGB(119,105,93),'ball')
 for _,side in ipairs({-1,1})do
  fixed('EyeSocket',Vector3.new(.42,.4,.58),Vector3.new(side*.66,.25,-3.2),Color3.fromRGB(25,23,29),'ball')
  fixed('AngryBrow',Vector3.new(.6,.22,.6),Vector3.new(side*.66,.49,-3.18),bone,'wedge',CFrame.Angles(0,0,-side*.2))
  local eye=fixed('EmberEye',Vector3.new(.22,.24,.5),Vector3.new(side*.67,.26,-3.24),Color3.fromRGB(255,106,60),'ball');eye.Material=Enum.Material.Neon
  fixed('BackSweptHorn',Vector3.new(.32,1.75,1.05),Vector3.new(side*.69,.95,-2.1),bone,'wedge',CFrame.Angles(-.65,0,side*.25))
  for j=1,3 do fixed('RibArmor',Vector3.new(.35,1.5,.6),Vector3.new(side*1.06,-.35,j*.78-1),iron,'wedge',CFrame.Angles(0,0,side*.15))end
  for j=1,2 do
   local z=j==1 and -1.1 or 1.7;local x=side*(j==1 and .95 or .8)
   table.insert(rig.legs,{side=side,z=z,x=x,phase=(side==(j==1 and 1 or -1))and 0 or math.pi,upper=piece(visual,'UpperLeg',Vector3.one,iron,'ball'),lower=piece(visual,'LowerLeg',Vector3.one,bone,'ball'),paw=piece(visual,'ClawedPaw',Vector3.new(.64,.32,.85)*scale,dark,'ball')})
  end
 end
 for _,x in ipairs({-.38,.38})do fixed('Fang',Vector3.new(.18,.62,.28),Vector3.new(x,-.55,-3.8),Color3.fromRGB(231,215,181),'wedge',CFrame.Angles(math.pi,0,0))end
 for j=1,4 do fixed('SpineSpur',Vector3.new(.28,.7+(5-j)*.15,.9),Vector3.new(0,1.05-j*.055,j*.78-1.3),bone,'wedge',CFrame.Angles(.25,0,0))end
 rig.tail={};for i=1,4 do rig.tail[i]=piece(visual,'TailSegment'..i,Vector3.one,iron,'ball')end
 if model:GetAttribute('Elite')then fixed('EliteHeadArmor',Vector3.new(1.75,.4,1.6),Vector3.new(0,.7,-2.7),Color3.fromRGB(167,129,62),'wedge')end
 for _,v in ipairs(model:GetDescendants())do if v:IsA('BasePart')and v.Name~='Core'and v.Name~='EliteCrown'and v.Name~='ChargeWarning'then rig.hidden[v]=v.LocalTransparencyModifier;v.LocalTransparencyModifier=1 end end
 visual.Parent=model;model:SetAttribute('SkeletonMeshStatus','Ready');model:SetAttribute('VisualProfile','AshHound');Mesh.pose(rig,model:GetPivot(),0,'idle');return rig
end
local function segment(part,a,b,width)
 part.Size=Vector3.new(width,width,(b-a).Magnitude);part.CFrame=CFrame.lookAt((a+b)/2,b)
end
function Mesh.pose(rig,origin,time,mode)
 local scale=rig.scale;local running=mode=='walk'or mode=='attack';local phase=time*(mode=='attack'and 13 or 8)
 local breathe=math.sin(time*3)*.035;local bob=running and math.sin(phase*2)*.045 or breathe
 local frame=origin*CFrame.new(0,3*(scale-1)+bob,0)
 for _,v in ipairs(rig.static)do v.part.CFrame=frame*v.cf end
 for _,v in ipairs(rig.legs)do
  local wave=running and math.sin(phase+v.phase)or 0;local lift=running and math.max(0,math.cos(phase+v.phase))*.42 or 0
  local hip=frame*Vector3.new(v.x*scale,-.65*scale,v.z*scale)
  local paw=frame*Vector3.new(v.x*scale,(-2.82+lift)*scale,(v.z+wave*.65)*scale)
  local knee=(hip+paw)/2+frame:VectorToWorldSpace(Vector3.new(v.side*.18,.05,v.z<0 and .35 or -.45)*scale)
  segment(v.upper,hip,knee,.48*scale);segment(v.lower,knee,paw,.29*scale);v.paw.CFrame=CFrame.new(paw)*origin.Rotation
 end
 rig.jaw.CFrame=frame*CFrame.new(0,-.62*scale,-3.48*scale)*CFrame.Angles(mode=='attack'and .35 or(.06+math.sin(time*2)*.035),0,0)
 local start=frame*Vector3.new(0,-.15*scale,2.2*scale)
 for i,p in ipairs(rig.tail)do
  local a=i*.35+math.sin(time*3-i*.45)*.18;local finish=start+frame:VectorToWorldSpace(Vector3.new(math.sin(a)*.6,.15-i*.08,1)*scale)
  segment(p,start,finish,(.52-i*.08)*scale);start=finish
 end
 rig.origin=origin;rig.model:SetAttribute('SkeletonMotion',mode)
end
function Mesh.place(rig,origin)Mesh.pose(rig,origin,0,'idle')end
function Mesh.destroy(rig)if not rig or rig.destroyed then return end;rig.destroyed=true;for p,previous in pairs(rig.hidden)do if p.Parent then p.LocalTransparencyModifier=previous end end;rig.visual:Destroy()end
return Mesh
