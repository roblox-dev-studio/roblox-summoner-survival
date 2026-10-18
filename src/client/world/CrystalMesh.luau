-- Original native wedge/crystal rigs; no mesh upload, runtime mesh API or extra loop.
local Mesh={}
local profiles={
 crystal_scout={name='CrystalScout',stride=7.4,cycle=.62,color=Color3.fromRGB(72,111,133)},
 crystal_lancer={name='CrystalLancer',stride=8.6,cycle=.78,color=Color3.fromRGB(69,105,124)},
 crystal_mage={name='CrystalMage',stride=6.7,cycle=1.05,color=Color3.fromRGB(91,94,133)},
}
local edge=Color3.fromRGB(113,155,170);local dark=Color3.fromRGB(36,52,66);local light=Color3.fromRGB(155,220,227)
local function part(rig,name,size,color,wedge)
 local p=Instance.new(wedge and'WedgePart'or'Part');p.Name=name;p.Size=size*rig.scale;p.Color=color;p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=rig.visual;return p
end
local function fixed(rig,name,size,frame,color,group,wedge)
 local p=part(rig,name,size,color,wedge);table.insert(rig.pieces,{part=p,frame=frame,group=group or'body'});return p
end
-- Four native triangular prisms form a long, bevelled diamond cross-section.
local function shard(rig,name,size,frame,color,group)
 local w,h,d=size.X,size.Y,size.Z
 for _,vertical in ipairs({-1,1})do
  for _,front in ipairs({-1,1})do
   local rot=vertical==1 and CFrame.Angles(0,front==1 and math.pi or 0,0)or CFrame.Angles(math.pi,front==1 and 0 or math.pi,0)
   fixed(rig,name,Vector3.new(w,h/2,d/2),frame*CFrame.new(0,vertical*h/4,front*d/4)*rot,vertical==1 and color or color:Lerp(dark,.2),group,true)
  end
 end
end
local function segment(p,a,b,width,depth)
 p.Size=Vector3.new(width,depth,(b-a).Magnitude);p.CFrame=CFrame.lookAt((a+b)/2,b)
end
function Mesh.create(model)
 local kind=model:GetAttribute('EnemyKind');local profile=profiles[kind];if not profile or not model.Parent then return nil end
 local visual=Instance.new('Model');visual.Name=profile.name
 local rig={model=model,visual=visual,profile=profile,scale=model:GetScale(),stride=profile.stride,pieces={},legs={},hidden={}}
 local mage=kind=='crystal_mage';local lancer=kind=='crystal_lancer';local y=mage and 2.8 or(lancer and 1.9 or 1.4)
 shard(rig,'HeartCarapace',mage and Vector3.new(1.25,2.1,1.3)or(lancer and Vector3.new(1.45,2.4,2.4)or Vector3.new(1.25,1.55,1.9)),CFrame.new(0,y,0)*CFrame.Angles(mage and 0 or .12,math.pi/4,0),profile.color)
 rig.core=fixed(rig,'SmallArcaneHeart',Vector3.new(.38,.5,.3),CFrame.new(0,y+.07,mage and -.87 or -1.05),light);rig.core.Shape=Enum.PartType.Ball;rig.core.Material=Enum.Material.Neon
 for _,side in ipairs({-1,1})do
  fixed(rig,'SplitVisor',Vector3.new(.6,.2,.34),CFrame.new(side*.36,y+.39,-.97)*CFrame.Angles(0,side*-.2,side*.12),dark,'body',true)
 end
 if mage then
  for i=1,4 do
   local a=i*math.pi/2;fixed(rig,'SuspendedSkirt',Vector3.new(.53,1.1,.66),CFrame.new(math.cos(a)*.7,1.45,math.sin(a)*.7)*CFrame.Angles(.25,a,-.15),profile.color,'skirt',true)
  end
  for i=1,6 do
   local a=(i-1)*math.pi/3
   fixed(rig,'OuterCrownPoint',Vector3.new(.35,1.04,.58),CFrame.new(math.cos(a)*1.45,4.05,math.sin(a)*1.45)*CFrame.Angles(.32,-a,math.cos(a)*.18),edge,'crown',true)
  end
  for i=1,3 do
   local a=(i-1)*math.pi*2/3
   shard(rig,'OrbitingFacet',Vector3.new(.28,.65,.37),CFrame.new(math.cos(a)*1.06,3.52,math.sin(a)*1.06)*CFrame.Angles(0,a,.22),Color3.fromRGB(123,132,174),'orbit')
  end
  local shadow=fixed(rig,'GroundShadow',Vector3.new(2.7,.035,2.5),CFrame.new(0,.03,0),dark,'ground');shadow.Shape=Enum.PartType.Ball;shadow.Transparency=.55;shadow.CastShadow=false
 else
  for _,side in ipairs({-1,1})do
   for front=1,2 do
    local z=front==1 and -.7 or .85
    table.insert(rig.legs,{side=side,z=z,phase=(side==(front==1 and 1 or -1))and 0 or math.pi,
     upper=part(rig,'ArticulatedShardThigh',Vector3.one,profile.color,true),lower=part(rig,'ArticulatedShardShin',Vector3.one,edge,true),foot=part(rig,'GroundClaw',Vector3.new(.42,.28,.72),dark,true)})
   end
   fixed(rig,'SweptShoulder',Vector3.new(.67,lancer and 1.5 or .95,1.14),CFrame.new(side*.94,y+.29,.3)*CFrame.Angles(.35,side*.38,-side*.65),edge,'body',true)
  end
  if lancer then
   shard(rig,'ForwardLance',Vector3.new(.58,3.8,.72),CFrame.new(0,1.72,-2.18)*CFrame.Angles(-math.pi/2,0,0),edge,'lance')
   fixed(rig,'LanceGuardLeft',Vector3.new(.38,.8,.62),CFrame.new(-.53,1.75,-1.14)*CFrame.Angles(0,0,-.65),dark,'body',true)
   fixed(rig,'LanceGuardRight',Vector3.new(.38,.8,.62),CFrame.new(.53,1.75,-1.14)*CFrame.Angles(0,0,.65),dark,'body',true)
   fixed(rig,'RearKeel',Vector3.new(.48,.85,1.58),CFrame.new(0,1.7,1.26)*CFrame.Angles(-.45,0,0),profile.color,'body',true)
  else
   for _,side in ipairs({-1,1})do
    fixed(rig,'ForwardMandible',Vector3.new(.3,.44,.95),CFrame.new(side*.62,.9,-1.23)*CFrame.Angles(.15,-side*.23,0),edge,'body',true)
    fixed(rig,'SplitBackFin',Vector3.new(.31,.95,.88),CFrame.new(side*.39,2.02,.58)*CFrame.Angles(.4,side*.2,-side*.2),profile.color,'body',true)
   end
  end
 end
 if model:GetAttribute('Elite')then
  fixed(rig,'EliteGoldDiadem',Vector3.new(.6,.24,.45),CFrame.new(0,y+.73,-.69),Color3.fromRGB(200,161,82),'body',true)
 end
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')and p.Name~='Core'and p.Name~='EliteCrown'and p.Name~='ChargeWarning'then rig.hidden[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end end
 visual.Parent=model;model:SetAttribute('SkeletonMeshStatus','Ready');model:SetAttribute('VisualProfile',profile.name);model:SetAttribute('EnemyVisualFamily','crystal')
 Mesh.pose(rig,model:GetPivot(),0,'idle');return rig
end
function Mesh.duration(rig,mode)return mode=='walk'and rig.profile.cycle or(mode=='prepare'and .8 or .7)end
function Mesh.pose(rig,origin,time,mode)
 if rig.destroyed then return end
 local kind=rig.model:GetAttribute('EnemyKind');local mage=kind=='crystal_mage';local lancer=kind=='crystal_lancer';local scale=rig.scale
 local phase=time/rig.profile.cycle*math.pi*2;local moving=mode=='walk'or(lancer and mode=='attack')
 local prepare=mode=='prepare'and math.min(time/.8,1)or 0
 local impact=mode=='attack'and math.sin(math.clamp(time/.7,0,1)*math.pi)or 0
 local bob=mage and math.sin(time*2.1)*.14 or(moving and math.sin(phase*2)*.075 or math.sin(time*2)*.025)
 local tilt=lancer and(prepare*.16-impact*.12)or impact*-.09
 local base=origin*CFrame.new(0,-3,0);local body=base*CFrame.new(0,bob*scale,0)*CFrame.Angles(tilt,0,0)
 for _,v in ipairs(rig.pieces)do
  local frame=v.frame;local group=v.group;local target=body
  if group=='ground'then target=base
  elseif group=='crown'then frame=CFrame.Angles(0,time*.52,0)*CFrame.new(0,prepare*.3+impact*.16,0)*frame
  elseif group=='orbit'then frame=CFrame.Angles(0,-time*.86,0)*CFrame.new(0,-prepare*.25,0)*frame
  elseif group=='skirt'then frame=CFrame.Angles(0,math.sin(time*1.5)*.07,0)*frame
  elseif group=='lance'then frame=CFrame.new(0,prepare*-.1,-impact*.22)*frame end
  v.part.CFrame=target*CFrame.new(frame.Position*scale)*frame.Rotation
 end
 for _,leg in ipairs(rig.legs)do
  local wave=moving and math.sin(phase+leg.phase)or 0;local lift=moving and math.max(0,math.cos(phase+leg.phase))*.35 or 0
  local spread=lancer and 1.55 or 1.4;local height=lancer and 1.7 or 1.25
  local hip=body*Vector3.new(leg.side*.65*scale,height*scale,leg.z*scale)
  local foot=base*Vector3.new(leg.side*(spread+prepare*.1)*scale,(.16+lift)*scale,(leg.z+wave*.6)*scale)
  local knee=base*Vector3.new(leg.side*(spread+.15)*scale,(height*.8+lift*.2)*scale,(leg.z+wave*.18+.23)*scale)
  segment(leg.upper,hip,knee,.35*scale,.4*scale);segment(leg.lower,knee,foot,.2*scale,.3*scale)
  leg.foot.CFrame=CFrame.new(foot)*origin.Rotation*CFrame.Angles(0,leg.side*-.18,0)
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
