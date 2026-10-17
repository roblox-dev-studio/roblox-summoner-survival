-- Original soft blue/violet ribbon lance, inspired by the user-provided reference.
return function(deps)
 local Run=game:GetService('RunService');local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris')
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
  local anchor=resolve(name);if not anchor or not anchor.Parent then return end
  local spear=kind=='aetherLance';local crystal=false
  local model=Instance.new('Model');model.Name=spear and 'AetherLance' or(crystal and 'CrystalBolt' or 'HomingMissile');model.Parent=fx
  local pivot=part(model,'Pivot',Vector3.one*.1,CFrame.identity,white);pivot.Transparency=1;model.PrimaryPart=pivot
  local color=(spear or crystal)and cyan or violet
  local currents={};local tipSparks;local age=0
  if spear then
   -- Thin luminous lance, formed inside soft blue/violet ribbons.
   local shaft=part(model,'SpearShaft',Vector3.new(17,.085,.085),CFrame.new(0,0,2)*CFrame.Angles(0,math.pi/2,0),cyan,Enum.PartType.Cylinder);shaft.Transparency=.2
   part(model,'SpearSpine',Vector3.new(20,.035,.035),CFrame.new(0,0,.7)*CFrame.Angles(0,math.pi/2,0),white,Enum.PartType.Cylinder)
   local aura=part(model,'SpearAura',Vector3.new(19,.2,.2),CFrame.new(0,0,1)*CFrame.Angles(0,math.pi/2,0),cyan,Enum.PartType.Cylinder);aura.Transparency=.78
   local function face(a,b,c,color)
    local ab,ac,bc=b-a,c-a,c-b
    local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
    if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
    ab,ac,bc=b-a,c-a,c-b
    local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
    local function half(v,axis,depth)
     if depth<.005 then return end
     local p=Instance.new('WedgePart');p.Name='LightningSpearFacet';p.Size=Vector3.new(.015,math.abs(ab:Dot(up)),depth);p.CFrame=CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back);p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.2;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=model
    end
    half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
   end
   local tip=Vector3.new(0,0,-13);local tail=Vector3.new(0,0,-6.8)
   local ring={Vector3.new(.17,0,-8.5),Vector3.new(0,.17,-8.5),Vector3.new(-.17,0,-8.5),Vector3.new(0,-.17,-8.5)}
   for i=1,4 do local a,b=ring[i],ring[i%4+1];face(tip,a,b,i%2==0 and white or cyan);face(tail,b,a,cyan)end
   for strand=1,3 do
    for i=1,8 do
     local a=Instance.new('Attachment');a.Parent=pivot;local b=Instance.new('Attachment');b.Parent=pivot
     local beam=Instance.new('Beam');beam.Name='WaveringLanceRibbon';beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=8;beam.LightEmission=1;beam.LightInfluence=0
     beam.Color=ColorSequence.new(strand==3 and Color3.fromRGB(128,116,255)or cyan,white)
     if strand>1 then beam.Texture='rbxasset://textures/particles/smoke_main.dds';beam.TextureMode=Enum.TextureMode.Stretch;beam.TextureSpeed=.35 end
     beam.Transparency=NumberSequence.new(strand==1 and .28 or .72);beam.Width0=strand==1 and .055 or 1.1;beam.Width1=beam.Width0;beam.Parent=pivot
     table.insert(currents,{a=a,b=b,beam=beam,index=i,strand=strand})
    end
   end
   local tipHost=Instance.new('Attachment');tipHost.Position=Vector3.new(0,0,-7.5);tipHost.Parent=pivot
   tipSparks=Instance.new('ParticleEmitter');tipSparks.Name='LanceStardust';tipSparks.Texture='rbxasset://textures/particles/sparkles_main.dds';tipSparks.Rate=35;tipSparks.Lifetime=NumberRange.new(.18,.4);tipSparks.Speed=NumberRange.new(.5,2);tipSparks.SpreadAngle=Vector2.new(180,180);tipSparks.Size=NumberSequence.new(.14,0);tipSparks.Color=ColorSequence.new(white,cyan);tipSparks.LightEmission=1;tipSparks.Transparency=NumberSequence.new(.2,1);tipSparks.Parent=tipHost
   local host=Instance.new('Attachment');host.Position=Vector3.new(0,0,5);host.Parent=pivot
   local mist=Instance.new('ParticleEmitter');mist.Name='LanceHaze';mist.Texture='rbxasset://textures/particles/smoke_main.dds';mist.Rate=22;mist.Lifetime=NumberRange.new(.25,.55);mist.Speed=NumberRange.new(.5,2);mist.SpreadAngle=Vector2.new(25,25);mist.Size=NumberSequence.new(1.8,0);mist.Color=ColorSequence.new(cyan,Color3.fromRGB(118,99,255));mist.Transparency=NumberSequence.new(.9,1);mist.LightEmission=.65;mist.Parent=host

  end
  local a=Instance.new('Attachment');a.Position=Vector3.new(-.3,0,spear and 9.5 or .3);a.Parent=pivot
  local b=Instance.new('Attachment');b.Position=Vector3.new(.3,0,spear and 9.5 or .3);b.Parent=pivot
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=spear and .3 or .2;trail.Color=ColorSequence.new(white,color);trail.Transparency=NumberSequence.new(.2,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=1;trail.Parent=pivot
  local light=Instance.new('PointLight');light.Color=color;light.Range=spear and 12 or 6;light.Brightness=1.5;light.Parent=pivot
  local current=anchor.CFrame;local bodyParts={};if spear then for _,p in ipairs(model:GetChildren())do if p:IsA('BasePart')and p~=pivot then table.insert(bodyParts,{part=p,alpha=p.Transparency})end end end;local hasLaunched=false;local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;model:Destroy()end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function(dt)
   if not anchor.Parent then clear();return end
   age+=dt
   local launched=not spear or anchor:GetAttribute('Launched')
   local target=anchor.CFrame
   local charge=math.clamp((anchor:GetAttribute('Elapsed')or 0)/.4,0,1)
   if spear then
    if not launched then target=target*CFrame.new(0,1.2,-3)end
    local formed=launched and 1 or math.clamp((charge-.4)/.6,0,1)
    for _,v in ipairs(bodyParts)do v.part.Transparency=1-(1-v.alpha)*formed end
   end
   current=current:Lerp(target,1-math.exp(-dt*35));model:PivotTo(current);trail.Enabled=launched
   if spear then
    for _,v in ipairs(currents)do
     local function point(index)
      local z=-8+index*2.5;local phase=age*5+index*.9+v.strand*2.1
      local width=(launched and 1.25 or 1.7)*(v.strand==1 and .75 or 1)
      return Vector3.new(math.sin(phase)*width,math.cos(phase*.85)*width*.7,z)
     end
     v.a.Position=point(v.index-1);v.b.Position=point(v.index)
     v.beam.CurveSize0=math.sin(age*3+v.index)*.22;v.beam.CurveSize1=-v.beam.CurveSize0
    end
    if launched and not hasLaunched then hasLaunched=true;tipSparks:Emit(28)end
   end
  end)
 end
 return {Cast=cast}
end
