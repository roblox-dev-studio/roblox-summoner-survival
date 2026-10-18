-- Original native-part slime family. The server root remains the ground combat anchor.
-- Smooth lobes deform together; mouth, crest and stone mantle distinguish the roles.
local Mesh={}
local profiles={
 slime_blob={name='VerdantSlime',body=Vector3.new(3.6,2.7,3.2),color=Color3.fromRGB(79,126,83),stride=5.2,cycle=.72},
 slime_spitter={name='SlimeSpitter',body=Vector3.new(3.1,3.7,2.9),color=Color3.fromRGB(91,120,68),stride=5.8,cycle=.84},
 slime_bulwark={name='SlimeBulwark',body=Vector3.new(5.1,3.15,4.3),color=Color3.fromRGB(66,106,96),stride=5.4,cycle=1.08},
}
local dark=Color3.fromRGB(27,43,39)
local acid=Color3.fromRGB(187,226,111)
local stone=Color3.fromRGB(69,83,83)
local function piece(rig,name,size,position,color,group,shape,rotation)
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size*rig.scale;p.Color=color
 p.Material=group=='armor'and Enum.Material.Slate or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=group~='glow'
 if shape~='wedge'then p.Shape=Enum.PartType.Ball end
 if group=='glow'then p.Material=Enum.Material.Neon end
 p.Parent=rig.visual
 table.insert(rig.pieces,{part=p,size=size,position=position,rotation=rotation or CFrame.identity,group=group})
 return p
end
function Mesh.create(model)
 local profile=profiles[model:GetAttribute('EnemyKind')];if not profile or not model.Parent then return nil end
 local visual=Instance.new('Model');visual.Name=profile.name
 local rig={model=model,visual=visual,profile=profile,scale=model:GetScale(),stride=profile.stride,pieces={},hidden={}}
 local size=profile.body;local w,h,d=size.X,size.Y,size.Z
 rig.body=piece(rig,'GelBody',size,Vector3.new(0,h*.5+.22,0),profile.color,'gel')
 piece(rig,'LowerLobe',Vector3.new(w*.94,h*.43,d*.92),Vector3.new(0,h*.22,-.12),profile.color,'gel')
 for _,side in ipairs({-1,1})do
  piece(rig,'SidePseudopod',Vector3.new(w*.36,.52,d*.51),Vector3.new(side*w*.34,.3,.18),profile.color,'foot')
  piece(rig,'ForwardPseudopod',Vector3.new(w*.27,.42,d*.42),Vector3.new(side*w*.24,.25,-d*.33),profile.color,'foot')
  local eyeY=h*.62;local eyeX=w*.185;local eyeZ=-d*.437
  piece(rig,'EyeSocket',Vector3.new(.53,.6,.22),Vector3.new(side*eyeX,eyeY,eyeZ),dark,'face',nil,CFrame.Angles(0,side*-.18,-side*.15))
  piece(rig,'AcidEye',Vector3.new(.18,.32,.12),Vector3.new(side*eyeX,eyeY,eyeZ-.11),acid,'glow')
  piece(rig,'HeavyBrow',Vector3.new(.67,.18,.34),Vector3.new(side*eyeX,eyeY+.34,eyeZ-.015),profile.color,'face',nil,CFrame.Angles(0,0,-side*.22))
 end
 piece(rig,'WetHighlight',Vector3.new(w*.15,.17,.13),Vector3.new(-w*.22,h*.83,-d*.31),Color3.fromRGB(157,185,132),'face',nil,CFrame.Angles(-.3,0,-.3))
 if model:GetAttribute('EnemyKind')=='slime_spitter'then
  rig.throat=piece(rig,'VenomThroat',Vector3.new(1.55,1.1,.8),Vector3.new(0,1.4,-1.22),Color3.fromRGB(123,151,73),'throat')
  piece(rig,'RaisedMuzzle',Vector3.new(1.28,.95,.9),Vector3.new(0,2.05,-1.45),profile.color,'mouth')
  rig.mouth=piece(rig,'SpitMouth',Vector3.new(.77,.53,.14),Vector3.new(0,2.12,-1.9),dark,'mouth')
  piece(rig,'LowerLip',Vector3.new(.95,.2,.35),Vector3.new(0,1.76,-1.82),Color3.fromRGB(141,164,88),'mouth')
  for i=-1,1 do
   piece(rig,'LeafCrest',Vector3.new(.48,1.3-math.abs(i)*.25,.85),Vector3.new(i*.48,3.74-math.abs(i)*.18,.25),Color3.fromRGB(64,89,63),'crest','wedge',CFrame.Angles(-.38,0,-i*.28))
  end
  for _,side in ipairs({-1,1})do piece(rig,'VenomSac',Vector3.new(.73,1.05,.95),Vector3.new(side*1.27,1.05,.18),Color3.fromRGB(128,146,71),'throat')end
 elseif model:GetAttribute('EnemyKind')=='slime_bulwark'then
  piece(rig,'GrimMouth',Vector3.new(1.2,.2,.12),Vector3.new(0,1.15,-2.05),dark,'face')
  for _,side in ipairs({-1,1})do
   for row=1,3 do
    piece(rig,'MantlePlate',Vector3.new(1.25,.64,1.42),Vector3.new(side*(row==1 and 1.48 or 1.28),2.5-(row-1)*.13,-1.05+(row-1)*1.1),stone,'armor','wedge',CFrame.Angles(.12,side*.18,-side*.43))
   end
   piece(rig,'CheekGuard',Vector3.new(.64,.86,.9),Vector3.new(side*1.63,1.58,-1.69),Color3.fromRGB(96,112,107),'armor','wedge',CFrame.Angles(0,side*.25,-side*.25))
  end
  for row=1,3 do piece(rig,'DorsalPlate',Vector3.new(1.02,.66,1.26),Vector3.new(0,3.1-(row-1)*.14,-.6+(row-1)*1.05),Color3.fromRGB(91,103,97),'armor','wedge',CFrame.Angles(.22,0,0))end
 else
  piece(rig,'MouthCrease',Vector3.new(.79,.19,.13),Vector3.new(0,1.08,-1.53),dark,'face')
  piece(rig,'CrownBud',Vector3.new(.8,.56,.75),Vector3.new(-.28,2.84,.12),Color3.fromRGB(110,148,90),'gel')
  piece(rig,'TrailingLobe',Vector3.new(1.55,.57,1.34),Vector3.new(.34,.32,1.13),profile.color,'foot')
 end
 if model:GetAttribute('Elite')then
  for i=-1,1 do piece(rig,'EliteAmberStud',Vector3.new(.22,.3,.22),Vector3.new(i*.37,h+.2, -.2),Color3.fromRGB(205,167,83),'crest','wedge')end
 end
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')and p.Name~='Core'and p.Name~='EliteCrown'and p.Name~='ChargeWarning'then rig.hidden[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end end
 visual.Parent=model;model:SetAttribute('SkeletonMeshStatus','Ready');model:SetAttribute('VisualProfile',profile.name);model:SetAttribute('EnemyVisualFamily','slime')
 Mesh.pose(rig,model:GetPivot(),0,'idle');return rig
end
function Mesh.duration(rig,mode)return mode=='walk'and rig.profile.cycle or(mode=='prepare'and .8 or .72)end
function Mesh.pose(rig,origin,time,mode)
 if rig.destroyed then return end
 local heavy=rig.model:GetAttribute('EnemyKind')=='slime_bulwark'
 local phase=time/rig.profile.cycle*math.pi*2
 local walk=mode=='walk';local prepare=mode=='prepare';local attack=mode=='attack'
 local lift=walk and math.max(0,math.sin(phase))*(heavy and .14 or .48)or 0
 local impact=attack and math.sin(math.clamp(time/.72,0,1)*math.pi)or 0
 local charge=prepare and math.min(time/.8,1)or 0
 local squash=walk and math.cos(phase*2)*(heavy and .035 or .105)or math.sin(time*2.4)*.025
 squash-=charge*.12;squash+=impact*.12
 local width=1-squash*.42;local height=1+squash
 local recoil=attack and math.sin(math.clamp(time/.4,0,1)*math.pi)*.24 or 0
 local base=origin*CFrame.new(0,-3,0);local scale=rig.scale
 for _,v in ipairs(rig.pieces)do
  local p=v.position;local size=v.size;local group=v.group
  local foot=group=='foot';local armor=group=='armor';local stiffness=armor and .25 or 1
  local sx=1+(width-1)*stiffness;local sy=1+(height-1)*stiffness
  local pos=Vector3.new(p.X*width,p.Y*height+(foot and 0 or lift),p.Z*(1+charge*.12)+recoil)
  local rotation=v.rotation
  if group=='crest'then rotation=CFrame.Angles(math.sin(time*3+p.X)*.08+charge*.25,0,0)*rotation end
  if group=='mouth'then sy*=1+charge*.5;pos+=Vector3.new(0,charge*.12,-charge*.15)end
  if group=='throat'then sx*=1+charge*.23;sy*=1+charge*.24 end
  if foot then sy=1+math.cos(phase+p.X)* (walk and .14 or .02);pos=Vector3.new(pos.X,.3*sy,p.Z)end
  v.part.Size=Vector3.new(size.X*sx,size.Y*sy,size.Z*(1+charge*.08))*scale
  v.part.CFrame=base*CFrame.new(pos*scale)*rotation
 end
 rig.origin=origin;rig.time=time;rig.mode=mode;rig.model:SetAttribute('SkeletonMotion',mode)
end
function Mesh.place(rig,origin)Mesh.pose(rig,origin,rig.time or 0,rig.mode or'idle')end
function Mesh.destroy(rig)
 if not rig or rig.destroyed then return end;rig.destroyed=true
 for p,previous in pairs(rig.hidden)do if p.Parent then p.LocalTransparencyModifier=previous end end
 rig.visual:Destroy()
end
return Mesh
