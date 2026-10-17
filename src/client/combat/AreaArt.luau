-- Original procedural art. Active casts follow server time, so menu pauses freeze them.
return function(deps)
 local Run=game:GetService('RunService');local Debris=game:GetService('Debris');local Tween=game:GetService('TweenService')
 local Players=game:GetService('Players')
 local fx=deps.folder
 local skyLances=require(script.Parent.SkyLanceArt)({folder=fx})
 local gold=Color3.fromRGB(255,171,62);local ice=Color3.fromRGB(158,235,255);local mint=Color3.fromRGB(132,255,220)
 local function part(parent,name,color,size,shape)
  local p=Instance.new('Part');p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Color=color;p.Size=size;p.Shape=shape or Enum.PartType.Ball;p.Parent=parent;return p
 end
 local function line(p,a,b,width)
  p.Size=Vector3.new((b-a).Magnitude,width,width);p.CFrame=CFrame.lookAt((a+b)*.5,b)*CFrame.Angles(0,math.pi/2,0)
 end
 local function edge(parent,color,width)return part(parent,'RuneArc',color,Vector3.new(width,width,1),Enum.PartType.Cylinder)end
 local function ring(parent,pos,radius,color,duration)
  for i=1,40 do
   local a=(i-1)*math.pi/20;local b=i*math.pi/20
   local p=edge(parent,color,.16);local dir=Vector3.new(math.cos((a+b)/2),0,math.sin((a+b)/2))
   line(p,pos+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius),pos+Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius),.16)
   Debris:AddItem(p,duration);Tween:Create(p,TweenInfo.new(duration),{Position=p.Position+dir*radius*.25,Transparency=1}):Play()
  end
 end
 local function burst(pos,radius,color)
  local p=part(fx,'ArcaneImpact',color,Vector3.one);p.Position=pos+Vector3.new(0,1,0);p.Transparency=.45;Debris:AddItem(p,.65)
  Tween:Create(p,TweenInfo.new(.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(radius*1.8,2,radius*1.8),Transparency=1}):Play()
  ring(fx,Vector3.new(pos.X,.5,pos.Z),radius,color,.65)
  for i=1,20 do
   local a=i*math.pi/10;local dir=Vector3.new(math.cos(a),0,math.sin(a))
   local shard=part(fx,'ImpactSpark',color,Vector3.new(.25,2,.25));shard.Position=pos+dir*2;Debris:AddItem(shard,.8)
   Tween:Create(shard,TweenInfo.new(.7),{Position=pos+dir*radius+Vector3.new(0,(i%4)*1.5,0),Transparency=1,Size=Vector3.new(.05,.1,.05)}):Play()
  end
 end
 local function meteorImpact(pos,radius)
  burst(pos,radius,gold);ring(fx,Vector3.new(pos.X,.7,pos.Z),radius*.65,Color3.fromRGB(255,239,179),.45)
  local crater=part(fx,'MeteorScorch',Color3.fromRGB(33,24,28),Vector3.new(.09,radius*1.5,radius*1.5),Enum.PartType.Cylinder)
  crater.CFrame=CFrame.new(pos.X,.12,pos.Z)*CFrame.Angles(0,0,math.pi/2);crater.Material=Enum.Material.Slate;crater.Transparency=.25;Debris:AddItem(crater,5);Tween:Create(crater,TweenInfo.new(5),{Transparency=1}):Play()
  for i=1,18 do
   local a=i*math.pi/9;local dir=Vector3.new(math.cos(a),0,math.sin(a))
   local rock=part(fx,'MeteorDebris',Color3.fromRGB(63,42,39),Vector3.new(1.6+(i%3),1.4,2.2));rock.Material=Enum.Material.Slate;rock.CFrame=CFrame.new(pos+dir*3)*CFrame.Angles(i,i*.7,0);Debris:AddItem(rock,2.6)
   local peak=pos+dir*radius*.75+Vector3.new(0,5+i%5,0)
   Tween:Create(rock,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=peak,Orientation=Vector3.new(i*31,i*17,80)}):Play()
   task.delay(.35,function()if rock.Parent then Tween:Create(rock,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=pos+dir*radius,Transparency=1}):Play()end end)
  end
 end
 local function frostImpact(pos,radius)
  burst(pos,radius,ice)
  local flash=part(fx,'FrostWhiteFlash',Color3.fromRGB(232,255,255),Vector3.one*3);flash.Position=pos+Vector3.new(0,1.5,0);flash.Transparency=.3;Debris:AddItem(flash,.3)
  Tween:Create(flash,TweenInfo.new(.25),{Size=Vector3.one*radius*.9,Transparency=1}):Play()
  local light=Instance.new('PointLight');light.Color=ice;light.Range=radius*3;light.Brightness=5;light.Parent=flash;Tween:Create(light,TweenInfo.new(.25),{Brightness=0}):Play()
  for layer=1,3 do
   task.delay((layer-1)*.08,function()
    for i=1,36 do
     local a=i*math.pi/18;local dir=Vector3.new(math.cos(a),0,math.sin(a))
     local start=Vector3.new(pos.X,.4+layer*.12,pos.Z)+dir*2
     local p=edge(fx,layer==2 and Color3.fromRGB(233,255,255)or ice,.3);p.CFrame=CFrame.lookAt(start,start+dir)*CFrame.Angles(0,math.pi/2,0);p.Size=Vector3.new(.7,.18,.18);Debris:AddItem(p,.65)
     Tween:Create(p,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=start+dir*(radius-2),Size=Vector3.new(radius*.19,.06,.2),Transparency=1}):Play()
    end
   end)
  end
  local mist=part(fx,'FrostMist',ice,Vector3.one*.1);mist.Position=pos+Vector3.new(0,.7,0);mist.Transparency=1;Debris:AddItem(mist,1.8)
  local fog=Instance.new('ParticleEmitter');fog.Texture='rbxasset://textures/particles/smoke_main.dds';fog.Rate=0;fog.Lifetime=NumberRange.new(.55,1.2);fog.Speed=NumberRange.new(14,28);fog.SpreadAngle=Vector2.new(85,85);fog.EmissionDirection=Enum.NormalId.Top;fog.Drag=5;fog.Size=NumberSequence.new(4,10);fog.Color=ColorSequence.new(ice);fog.Transparency=NumberSequence.new(.72,1);fog.LightEmission=.4;fog.Parent=mist;fog:Emit(32)
  for i=1,24 do
   local a=i*math.pi/12;local distance=radius*(i%3==0 and .4 or .8);local height=5+i%4
   local p=Instance.new('WedgePart');p.Name='FrostCrown';p.Size=Vector3.new(.7,.1,1.8);p.CFrame=CFrame.new(pos+Vector3.new(math.cos(a)*distance,-1,math.sin(a)*distance))*CFrame.Angles(0,-a,.3);p.Color=i%3==0 and Color3.fromRGB(219,254,255)or ice;p.Material=Enum.Material.Glass;p.Transparency=.15;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,1.8)
   Tween:Create(p,TweenInfo.new(.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=Vector3.new(1.2,height,2.6),Position=p.Position+Vector3.new(0,height*.35,0)}):Play()
   task.delay(.65,function()if p.Parent then Tween:Create(p,TweenInfo.new(.8),{Transparency=1,Position=p.Position-Vector3.new(0,2,0)}):Play()end end)
  end
 end
 local function cast(anchor,kind)
  if kind=='skyLances' then skyLances.Cast(anchor);return end
  -- Instances created this frame can arrive after the remote; resolve a stable name.
  if type(anchor)=='string' then
   local runtime=workspace:WaitForChild('SummonerRuntime',3)
   anchor=runtime and runtime:WaitForChild(anchor,2)
  end
  if not anchor or not anchor.Parent then return end
  local model=Instance.new('Model');model.Name=kind..'Magic';model.Parent=fx
  local deadline=os.clock()+1
  while anchor.Parent and not anchor:GetAttribute('Duration') and os.clock()<deadline do task.wait()end
  local radius=anchor:GetAttribute('Radius');local duration=anchor:GetAttribute('Duration');local level=anchor:GetAttribute('Level')or 1
  if not anchor.Parent or not radius or not duration then model:Destroy();return end
  local color=kind=='meteor' and gold or(kind=='frost' and ice or(kind=='blades' and mint or Color3.fromRGB(255,222,152)))
  local arcs={};if kind~='blades' then for i=1,48 do arcs[i]=edge(model,color,.12)end end
  local pieces={};local cracks={};local shell,core,emitter
  local meteorSize=10+level*.6
  if kind=='meteor' then
   core=part(model,'MeteorBody',Color3.fromRGB(63,43,39),Vector3.one*meteorSize);core.Material=Enum.Material.Slate
   shell=part(model,'FlameAura',gold,Vector3.one*(meteorSize+1.2));shell.Transparency=.95
   local light=Instance.new('PointLight');light.Color=gold;light.Range=45;light.Brightness=4;light.Parent=core
   emitter=Instance.new('ParticleEmitter');emitter.Texture='rbxasset://textures/particles/fire_main.dds';emitter.Rate=120;emitter.Lifetime=NumberRange.new(.35,.65);emitter.Speed=NumberRange.new(7,13);emitter.EmissionDirection=Enum.NormalId.Top;emitter.SpreadAngle=Vector2.new(20,20);emitter.Size=NumberSequence.new(12,0);emitter.Color=ColorSequence.new(Color3.fromRGB(255,241,169),Color3.fromRGB(255,95,32));emitter.Transparency=NumberSequence.new(.15,1);emitter.LightEmission=.9;emitter.Parent=core
   for i=1,12 do
    local rock=part(model,'MeteorCrust',Color3.fromRGB(58+i*2,34+i,31),Vector3.new(4.4,3.2,5.1));rock.Material=Enum.Material.Slate;pieces[i]=rock
   end
   for i=1,18 do cracks[i]=edge(model,Color3.fromRGB(255,157,58),.18)end
   for i=1,3 do
    local a=Instance.new('Attachment');a.Position=Vector3.new(-meteorSize*.36,0,(i-2)*2);a.Parent=core
    local b=Instance.new('Attachment');b.Position=Vector3.new(meteorSize*.36,0,(i-2)*2);b.Parent=core
    local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.7;trail.Color=ColorSequence.new(Color3.fromRGB(255,241,180),Color3.fromRGB(255,92,33));trail.Transparency=NumberSequence.new(.25,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=1;trail.Parent=core
   end
  elseif kind=='blades' then
   for i=1,5 do
    local crystal=Instance.new('Model');crystal.Name='OrbitLight';crystal.Parent=model
    local pivot=part(crystal,'Pivot',mint,Vector3.one*.1);pivot.Transparency=1;crystal.PrimaryPart=pivot
    part(crystal,'LightCore',Color3.fromRGB(222,253,255),Vector3.one*.55)
    local glow=part(crystal,'LightHalo',Color3.fromRGB(112,202,255),Vector3.one*1.15);glow.Transparency=.8
    local outer=part(crystal,'SoftAura',Color3.fromRGB(108,135,255),Vector3.one*1.65);outer.Transparency=.93
    local light=Instance.new('PointLight');light.Color=Color3.fromRGB(129,209,255);light.Range=4;light.Brightness=.65;light.Parent=pivot
    local sparks=Instance.new('ParticleEmitter');sparks.Name='OrbStardust';sparks.Texture='rbxasset://textures/particles/sparkles_main.dds';sparks.Rate=8;sparks.Lifetime=NumberRange.new(.2,.45);sparks.Speed=NumberRange.new(.2,.8);sparks.SpreadAngle=Vector2.new(180,180);sparks.Size=NumberSequence.new(.12,0);sparks.Transparency=NumberSequence.new(.3,1);sparks.Color=ColorSequence.new(Color3.fromRGB(192,242,255));sparks.LightEmission=1;sparks.Parent=pivot
    pieces[i]=crystal
   end
  elseif kind=='ward' then
   shell=part(model,'GuardianDome',color,Vector3.new(9,10,9));shell.Material=Enum.Material.ForceField;shell.Transparency=.45
   for i=1,6 do pieces[i]=part(model,'GuardianRune',color,Vector3.new(.12,.8,.65),Enum.PartType.Block)end
  else
   shell=part(model,'FrostGathering',Color3.fromRGB(222,255,255),Vector3.one*4);shell.Transparency=.3
   local light=Instance.new('PointLight');light.Color=ice;light.Range=16;light.Brightness=2;light.Parent=shell
   for i=1,8 do pieces[i]=part(model,'GatheringShard',ice,Vector3.new(.3,1.1,.3),Enum.PartType.Block)end
  end
  local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;if model.Parent then model:Destroy()end end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent then clear();return end
   local center=anchor.Position
   if kind=='ward'then
    local ownerId=anchor:GetAttribute('OwnerUserId');local owner=ownerId and Players:GetPlayerByUserId(ownerId)
    local root=owner and owner.Character and owner.Character:FindFirstChild('HumanoidRootPart')
    if root then center=root.Position-Vector3.new(0,2.6,0)end
   end
   local t=anchor:GetAttribute('Elapsed')or 0;local u=math.clamp(t/duration,0,1)
   for i,p in ipairs(arcs)do
    local a=(i-1)*math.pi/24;local b=i*math.pi/24
    local r=radius*(kind=='meteor' and (.85+u*.15) or(kind=='frost' and .3+u*.7 or 1))
    local function point(angle)return center+Vector3.new(math.cos(angle)*r,.12,math.sin(angle)*r)end
    line(p,point(a),point(b),i%4==0 and .21 or .09);p.Transparency=kind=='blades' and .75 or .25
   end
   if kind=='meteor' then
    local fall=math.clamp((t-.35)/(duration-.35),0,1);local height=76*(1-fall)^1.3+meteorSize*.3
    local origin=center+Vector3.new(20*(1-fall),height,0)
    core.CFrame=CFrame.new(origin)*CFrame.Angles(t*.7,t*.8,t*.4);shell.CFrame=core.CFrame
    for i,p in ipairs(pieces)do
     local a=i*math.pi/6;local y=(i%3-1)*meteorSize*.24
     p.CFrame=core.CFrame*CFrame.new(math.cos(a)*meteorSize*.37,y,math.sin(a)*meteorSize*.37)*CFrame.Angles(i*.7,i*.4,i*.9)
    end
   for i,p in ipairs(cracks)do
     local a=i*math.pi/6;local y=math.sin(i*2.3)*.48
     local p1=Vector3.new(math.cos(a),y,math.sin(a)).Unit*meteorSize*.51
     local p2=Vector3.new(math.cos(a+.24),y+.12,math.sin(a+.24)).Unit*meteorSize*.51
     line(p,core.CFrame:PointToWorldSpace(p1),core.CFrame:PointToWorldSpace(p2),.18)
    end
   elseif kind=='blades' then
    local count=5;local fired=anchor:GetAttribute('Fired')or 0
    for i,crystal in ipairs(pieces)do
     local a=i/(count+1)*math.pi-math.pi/2
     crystal:PivotTo(anchor.CFrame*CFrame.new(math.sin(a)*4.2,3.2+math.cos(a)*1.7+math.sin(t*2+i)*.08,1.8)*CFrame.Angles(0,t*.5+i,0))
     for _,p in ipairs(crystal:GetDescendants())do
      if p:IsA('BasePart')and p.Name~='Pivot' then p.LocalTransparencyModifier=i<=fired and 1 or 0
      elseif p:IsA('ParticleEmitter')or p:IsA('PointLight')then p.Enabled=i>fired end
     end
    end
   elseif kind=='ward' then
    shell.Position=center+Vector3.new(0,2.6,0);shell.Transparency=.4+math.sin(t*4)*.06
    for i,p in ipairs(pieces)do local a=t*.7+i*math.pi/3;p.CFrame=CFrame.new(center+Vector3.new(math.cos(a)*4.3,3+math.sin(a*2)*.5,math.sin(a)*4.3))*CFrame.Angles(0,-a,math.pi/4)end
   else
    shell.Position=center+Vector3.new(0,1.7,0);shell.Size=Vector3.one*(4*(1-u)+.6)
    for i,p in ipairs(pieces)do local a=i*math.pi/4+t*5;local r=(1-u)*5+1;p.CFrame=CFrame.new(center+Vector3.new(math.cos(a)*r,1.5,math.sin(a)*r))*CFrame.Angles(t*3,a,math.pi/4)end
   end
  end)
 end
 return {Cast=cast,Burst=burst,MeteorImpact=meteorImpact,FrostImpact=frostImpact}
end
