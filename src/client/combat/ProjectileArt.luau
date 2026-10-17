-- Reusable moving lightning lance and compact homing missiles; presentation only.
return function(deps)
 local Run=game:GetService('RunService');local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris')
 local aether=require(script.Parent.AetherLanceArt)(deps)
 local fx=deps.folder;local cyan=Color3.fromRGB(113,207,255);local white=Color3.fromRGB(231,252,255);local violet=Color3.fromRGB(206,140,255)
 local function part(parent,name,size,cf,color,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Shape=shape or Enum.PartType.Block;p.Material=Enum.Material.Neon;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function resolve(name)
  if typeof(name)=='Instance'then return name end
  if type(name)~='string'then return nil end
  local runtime=workspace:WaitForChild('SummonerRuntime',3);return runtime and runtime:WaitForChild(name,2)
 end
 local function cast(name,kind)
  if kind=='aetherLance'then aether.Cast(name,kind);return end
  local anchor=resolve(name);if not anchor or not anchor.Parent then return end
  local spear=kind=='thunder';local crystal=kind=='crystal'
  local model=Instance.new('Model');model.Name=spear and 'LightningSpear' or(crystal and 'CrystalBolt' or 'HomingMissile');model.Parent=fx
  local pivot=part(model,'Pivot',Vector3.one*.1,CFrame.identity,white);pivot.Transparency=1;model.PrimaryPart=pivot
  local color=(spear or crystal)and cyan or violet
  local currents={};local tipSparks;local age=0
  if spear then
   local shaft=part(model,'SpearShaft',Vector3.new(17,.24,.24),CFrame.new(0,0,2)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(42,78,121),Enum.PartType.Cylinder);shaft.Material=Enum.Material.Metal
   part(model,'SpearSpine',Vector3.new(17,.07,.07),CFrame.new(0,.14,2)*CFrame.Angles(0,math.pi/2,0),white,Enum.PartType.Cylinder)
   local aura=part(model,'SpearAura',Vector3.new(16,.36,.36),CFrame.new(0,0,2)*CFrame.Angles(0,math.pi/2,0),cyan,Enum.PartType.Cylinder);aura.Transparency=.65
   local function face(a,b,c,color)
    local ab,ac,bc=b-a,c-a,c-b
    local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
    if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
    ab,ac,bc=b-a,c-a,c-b
    local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
    local function half(v,axis,depth)
     if depth<.005 then return end
     local p=Instance.new('WedgePart');p.Name='LightningSpearFacet';p.Size=Vector3.new(.03,math.abs(ab:Dot(up)),depth);p.CFrame=CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back);p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.12;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=model
    end
    half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
   end
   local tip=Vector3.new(0,0,-13);local tail=Vector3.new(0,0,-4.5)
   local ring={Vector3.new(.72,0,-7),Vector3.new(0,.72,-7),Vector3.new(-.72,0,-7),Vector3.new(0,-.72,-7)}
   for i=1,4 do
    local a,b=ring[i],ring[i%4+1];face(tip,a,b,i%2==0 and white or cyan);face(tail,b,a,cyan)
    part(model,'SpearRidge',Vector3.new(.045,.045,(tip-a).Magnitude),CFrame.lookAt((tip+a)/2,a),white)
   end
   local gold=Color3.fromRGB(255,222,146)
   for i=1,6 do
    local cuff=part(model,'GildedShaftBand',Vector3.new(.12,.36,.36),CFrame.new(0,0,-2+i*2)*CFrame.Angles(0,math.pi/2,0),gold,Enum.PartType.Cylinder);cuff.Material=Enum.Material.Metal
    for _,side in ipairs({-1,1})do part(model,'ShaftEngraving',Vector3.new(.035,.055,.55),CFrame.new(side*.125,.02,-2+i*2.1)*CFrame.Angles(0,0,side*.3),cyan)end
   end
   for _,side in ipairs({-1,1})do face(Vector3.new(side*.18,0,-3.8),Vector3.new(side*1.65,0,-5.5),Vector3.new(side*.65,0,-7.5),gold)end
   part(model,'SpearPommel',Vector3.new(.4,.4,.7),CFrame.new(0,0,10.8),cyan,Enum.PartType.Ball)
   local function beam(a,b,width,c)
    local aa=Instance.new('Attachment');aa.Position=a;aa.Parent=pivot
    local bb=Instance.new('Attachment');bb.Position=b;bb.Parent=pivot
    local e=Instance.new('Beam');e.Attachment0=aa;e.Attachment1=bb;e.FaceCamera=true;e.Width0=width;e.Width1=width;e.Color=ColorSequence.new(c);e.LightEmission=1;e.LightInfluence=0;e.Transparency=NumberSequence.new(.25);e.Parent=pivot
    return aa,bb
   end
   for ringIndex=1,2 do for i=1,12 do
    local a=i*math.pi/6;local b=(i+1)*math.pi/6;local r=ringIndex==1 and 1 or 1.35;local z=ringIndex==1 and 7.5 or -3.5
    beam(Vector3.new(math.cos(a)*r,math.sin(a)*r,z),Vector3.new(math.cos(b)*r,math.sin(b)*r,z),.065,i%3==0 and gold or cyan)
   end end
   for i=1,12 do local a,b=beam(Vector3.zero,Vector3.new(0,0,1),.09,i%3==0 and white or cyan);currents[i]={a=a,b=b}end
   local tipHost=Instance.new('Attachment');tipHost.Position=tip;tipHost.Parent=pivot
   tipSparks=Instance.new('ParticleEmitter');tipSparks.Texture='rbxasset://textures/particles/sparkles_main.dds';tipSparks.Rate=38;tipSparks.Lifetime=NumberRange.new(.12,.28);tipSparks.Speed=NumberRange.new(1,4);tipSparks.SpreadAngle=Vector2.new(180,180);tipSparks.Size=NumberSequence.new(.25,0);tipSparks.Color=ColorSequence.new(white,gold);tipSparks.LightEmission=1;tipSparks.Transparency=NumberSequence.new(.15,1);tipSparks.Parent=tipHost
   for i=1,10 do
    local a=Vector3.new(math.sin(i*4)*.25,math.cos(i*3)*.23,-2.7+i*.55);local b=Vector3.new(math.sin((i+1)*4)*.25,math.cos((i+1)*3)*.23,-2.7+(i+1)*.55)
    part(model,'SpearCurrent',Vector3.new(.08,.08,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),cyan)
   end
  else
   part(model,'MissileCore',Vector3.one*(crystal and .5 or .45),CFrame.identity,white,Enum.PartType.Ball)
   local aura=part(model,'MissileAura',Vector3.one*(crystal and .95 or .9),CFrame.identity,color,Enum.PartType.Ball);aura.Transparency=.55
   if not crystal then for i=1,4 do local a=i*math.pi/2;part(model,'MissileFin',Vector3.new(.12,.12,1.2),CFrame.new(math.cos(a)*.3,math.sin(a)*.3,.35),color)end end
  end
  local a=Instance.new('Attachment');a.Position=Vector3.new(-.3,0,spear and 9.5 or .3);a.Parent=pivot
  local b=Instance.new('Attachment');b.Position=Vector3.new(.3,0,spear and 9.5 or .3);b.Parent=pivot
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=spear and .3 or .2;trail.Color=ColorSequence.new(white,color);trail.Transparency=NumberSequence.new(.2,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=1;trail.Parent=pivot
  local light=Instance.new('PointLight');light.Color=color;light.Range=spear and 12 or 6;light.Brightness=1.5;light.Parent=pivot
  local current=anchor.CFrame;local scale=1;local hasLaunched=false;local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;model:Destroy()end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function(dt)
   if not anchor.Parent then clear();return end
   age+=dt
   local launched=not spear or anchor:GetAttribute('Launched')
   local target=anchor.CFrame
   if spear then
    local wanted=1
    if not launched then target=target*CFrame.new(0,1.2,-3);wanted=.35+.4*math.clamp((anchor:GetAttribute('Elapsed')or 0)/.4,0,1)end
    if math.abs(wanted-scale)>.005 then model:ScaleTo(wanted);scale=wanted end
   end
   current=current:Lerp(target,1-math.exp(-dt*35));model:PivotTo(current);trail.Enabled=launched
   if spear then
    for i,v in ipairs(currents)do
     local z=-11+i*1.65;local phase=age*24+i*2.1
     v.a.Position=Vector3.new(math.sin(phase)*.55,math.cos(phase*1.3)*.5,z)
     v.b.Position=Vector3.new(math.sin(phase+1.9)*.55,math.cos((phase+1.9)*1.3)*.5,z+1.65)
    end
    if launched and not hasLaunched then hasLaunched=true;tipSparks:Emit(28)end
   end
  end)
 end
 local function impact(pos,kind)
  local color=(kind=='thunder' or kind=='aetherLance' or kind=='crystal')and cyan or violet
  local flash=part(fx,'ProjectileImpact',Vector3.one*.6,CFrame.new(pos),white,Enum.PartType.Ball);Debris:AddItem(flash,.3)
  Tween:Create(flash,TweenInfo.new(.25),{Size=Vector3.one*(kind=='crystal' and 1.1 or 2.5),Transparency=1}):Play()
  for i=1,10 do
   local direction=Vector3.new(math.sin(i*7),math.cos(i*5),math.cos(i*3)).Unit
   local p=part(fx,'ProjectileSpark',Vector3.new(.1,.1,.9),CFrame.lookAt(pos,pos+direction),color);Debris:AddItem(p,.5)
   Tween:Create(p,TweenInfo.new(.4),{Position=pos+direction*3,Transparency=1}):Play()
  end
 end
 return {Cast=cast,Impact=impact}
end
