-- Original magic artwork. Local geometry and beams never apply damage.
return function(deps)
 local Tween=game:GetService('TweenService')
 local Debris=game:GetService('Debris')
 local Run=game:GetService('RunService')
 local fx=deps.folder
 local gold=Color3.fromRGB(255,184,66)
 local white=Color3.fromRGB(255,248,206)
 local cyan=Color3.fromRGB(106,236,255)
 local red=Color3.fromRGB(255,70,37)
 local fire='rbxasset://textures/particles/fire_main.dds'
 local spark='rbxasset://textures/particles/sparkles_main.dds'
 local function host(name,cf,life)
  local p=Instance.new('Part');p.Name=name;p.Size=Vector3.one*.1;p.CFrame=cf;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,life);return p
 end
 local function attachment(p,position,tangent)
  local a=Instance.new('Attachment');a.CFrame=CFrame.fromMatrix(position,tangent,Vector3.yAxis,tangent:Cross(Vector3.yAxis));a.Parent=p;return a
 end
 local function ribbon(p,a,b,width,color,texture)
  local beam=Instance.new('Beam');beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=8;beam.Width0=width;beam.Width1=width;beam.Color=ColorSequence.new(color);beam.Transparency=NumberSequence.new(.1);beam.LightEmission=1;beam.LightInfluence=0
  if texture then beam.Texture=texture;beam.TextureLength=3;beam.TextureSpeed=1.5 end
  beam.Parent=p;return beam
 end
 local function particles(parent,color,count,size)
  local e=Instance.new('ParticleEmitter');e.Texture=spark;e.Rate=0;e.Lifetime=NumberRange.new(.25,.6);e.Speed=NumberRange.new(3,9);e.SpreadAngle=Vector2.new(180,180);e.Size=NumberSequence.new(size,0);e.Transparency=NumberSequence.new(.15,1);e.Color=ColorSequence.new(white,color);e.LightEmission=1;e.Drag=2;e.Parent=parent;e:Emit(count);return e
 end
 local function circle(p,radius,color,width,vertical)
  local beams={}
  for i=0,15 do
   local a=i*math.pi/8;local b=(i+1)*math.pi/8
   local pa=vertical and Vector3.new(math.cos(a)*radius,math.sin(a)*radius,0) or Vector3.new(math.sin(a)*radius,0,-math.cos(a)*radius)
   local pb=vertical and Vector3.new(math.cos(b)*radius,math.sin(b)*radius,0) or Vector3.new(math.sin(b)*radius,0,-math.cos(b)*radius)
   -- Use straight short segments for vertical sigils; no degenerate tangent frame.
   local aa=Instance.new('Attachment');aa.Position=pa;aa.Parent=p
   local bb=Instance.new('Attachment');bb.Position=pb;bb.Parent=p
   table.insert(beams,ribbon(p,aa,bb,width,color))
  end
  return beams
 end
 local function fade(p,duration)
  for _,b in ipairs(p:GetDescendants())do if b:IsA('Beam')then b.Transparency=NumberSequence.new(.25)end end
  local elapsed=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   elapsed+=dt
   if not p.Parent or elapsed>=duration then connection:Disconnect();if p.Parent then p:Destroy()end;return end
   for _,b in ipairs(p:GetDescendants())do if b:IsA('Beam')then b.Transparency=NumberSequence.new(math.clamp(elapsed/duration,.1,1))end end
  end)
 end
 local function sigil(origin,direction)
  local p=host('SolarCastSigil',CFrame.lookAt(origin+direction*2.5+Vector3.new(0,.5,0),origin+direction*3.5+Vector3.new(0,.5,0)),.65)
  circle(p,2.4,gold,.13,true);circle(p,1.95,cyan,.07,true)
  for i=1,6 do
   local angle=i*math.pi/3
   local a=Instance.new('Attachment');a.Position=Vector3.new(math.cos(angle)*1.5,math.sin(angle)*1.5,0);a.Parent=p
   local b=Instance.new('Attachment');b.Position=Vector3.new(math.cos(angle+math.pi*2/3)*1.5,math.sin(angle+math.pi*2/3)*1.5,0);b.Parent=p
   ribbon(p,a,b,.07,gold)
   particles(a,gold,2,.22)
  end
  Tween:Create(p,TweenInfo.new(.5),{CFrame=p.CFrame*CFrame.Angles(0,0,.7)}):Play();fade(p,.55)
 end
 local function wave(origin,direction,range,enemy,spread,duration)
  direction=Vector3.new(direction.X,0,direction.Z).Unit
  local p=host(enemy and 'DragonBreathWave' or 'SolarCrescent',CFrame.new(),duration+.2)
  local right=direction:Cross(Vector3.yAxis)
  local center=enemy and red or gold
  local strips={}
  for i=0,11 do
   local a=math.rad(-spread+i*spread*2/12);local b=math.rad(-spread+(i+1)*spread*2/12)
   local aa=attachment(p,Vector3.zero,right);local bb=attachment(p,Vector3.zero,right)
   local halo=ribbon(p,aa,bb,enemy and 4.2 or 4.4,center,fire)
   local under=ribbon(p,aa,bb,enemy and 2 or 1.25,center)
   local core=ribbon(p,aa,bb,enemy and .5 or .2,enemy and gold or white)
   local start=math.sin(i/12*math.pi)^.65;local finish=math.sin((i+1)/12*math.pi)^.65
   halo.Width0*=start;halo.Width1*=finish;under.Width0*=start;under.Width1*=finish;core.Width0*=start;core.Width1*=finish
   local e=particles(aa,center,2,enemy and .7 or .35);e.Rate=9;e.Lifetime=NumberRange.new(.12,.3);e.Speed=NumberRange.new(1,4);e.Texture=fire;e.Rate=18;e.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.3),NumberSequenceKeypoint.new(.4,2.5),NumberSequenceKeypoint.new(1,0)});e.Color=ColorSequence.new(white,center)
   table.insert(strips,{a=a,b=b,aa=aa,bb=bb,halo=halo,core=core,under=under})
  end
  local elapsed=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   elapsed+=dt
   if not p.Parent or elapsed>=duration then connection:Disconnect();if p.Parent then p:Destroy()end;return end
   local alpha=elapsed/duration;local radius=3+(range-3)*alpha
   local height=enemy and math.max(.9,origin.Y*(1-alpha)) or 2.3+math.sin(alpha*math.pi)*.8
   local opacity=math.clamp((alpha-.65)/.35,0,.95)
   for _,v in ipairs(strips)do
    for _,pair in ipairs({{v.aa,v.a},{v.bb,v.b}})do
     local a=pair[2];local tangent=right*math.cos(a)-direction*math.sin(a)
     local position=Vector3.new(origin.X,height,origin.Z)+(direction*math.cos(a)+right*math.sin(a))*radius
     pair[1].CFrame=CFrame.fromMatrix(position,tangent,Vector3.yAxis,tangent:Cross(Vector3.yAxis))
    end
    local curvature=radius*(v.b-v.a)/3
    v.halo.CurveSize0=curvature;v.halo.CurveSize1=curvature;v.core.CurveSize0=curvature;v.core.CurveSize1=curvature
    v.under.CurveSize0=curvature;v.under.CurveSize1=curvature;v.under.Transparency=NumberSequence.new(.45+opacity*.55);v.halo.Transparency=NumberSequence.new(.05+opacity*.95);v.core.Transparency=NumberSequence.new(opacity)
   end
  end)
 end
 local function fireWave(origin,direction,range)
  sigil(origin,direction);wave(origin,direction,range,false,35,.65)
  task.delay(.13,function()if fx.Parent then wave(origin,direction,range*.93,false,32,.6)end end)
 end
 local function rupture(point,radius,small)
  local life=small and 1.1 or 1.8
  local p=host('EmberEruption',CFrame.new(point.X,.24,point.Z),life)
  circle(p,radius,red,small and .22 or .45,false);circle(p,radius*.72,gold,.18,false)
  -- A fast expanding halo stays inside the authoritative damage boundary.
  local halo=host('EruptionShockwave',p.CFrame,.65)
  circle(halo,radius*.18,white,.28,false)
  for _,a in ipairs(halo:GetChildren())do if a:IsA('Attachment')then Tween:Create(a,TweenInfo.new(.38,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=a.Position/.18}):Play()end end
  fade(halo,.55)
  local scorch=host('EruptionScorch',CFrame.new(point.X,.09,point.Z)*CFrame.Angles(0,0,math.pi/2),2.3)
  scorch.Shape=Enum.PartType.Cylinder;scorch.Size=Vector3.new(.035,radius*1.85,radius*1.85);scorch.Material=Enum.Material.SmoothPlastic;scorch.Color=Color3.fromRGB(49,26,29);scorch.Transparency=.42
  Tween:Create(scorch,TweenInfo.new(2.1),{Transparency=1}):Play()
  local function plume(parent,scale,count)
   local e=Instance.new('ParticleEmitter');e.Texture=fire;e.Rate=0;e.EmissionDirection=Enum.NormalId.Top;e.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;e.Lifetime=NumberRange.new(.35,.8);e.Speed=NumberRange.new(13*scale,26*scale);e.Acceleration=Vector3.new(0,-12,0);e.SpreadAngle=Vector2.new(25,25)
   e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.4*scale),NumberSequenceKeypoint.new(.22,4.6*scale),NumberSequenceKeypoint.new(1,0)});e.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,white),ColorSequenceKeypoint.new(.25,gold),ColorSequenceKeypoint.new(1,red)});e.Transparency=NumberSequence.new(.12,1);e.LightEmission=.85;e.LightInfluence=0;e.Parent=parent;e:Emit(count)
  end
  plume(p,small and .65 or 1.15,small and 18 or 26)
  if not small then
   for i=1,5 do local a=Instance.new('Attachment');local angle=i*math.pi*2/5;a.Position=Vector3.new(math.cos(angle)*radius*.52,0,math.sin(angle)*radius*.52);a.Parent=p;plume(a,.85,12)end
   local smoke=Instance.new('ParticleEmitter');smoke.Texture='rbxasset://textures/particles/smoke_main.dds';smoke.Rate=0;smoke.Lifetime=NumberRange.new(.7,1.3);smoke.Speed=NumberRange.new(4,8);smoke.EmissionDirection=Enum.NormalId.Top;smoke.SpreadAngle=Vector2.new(70,70);smoke.Size=NumberSequence.new(radius*.4,radius);smoke.Color=ColorSequence.new(Color3.fromRGB(72,52,54));smoke.Transparency=NumberSequence.new(.7,1);smoke.Rotation=NumberRange.new(0,360);smoke.Parent=p;smoke:Emit(9)
  end
  local embers=particles(p,gold,small and 12 or 30,.55);embers.Texture='rbxasset://textures/particles/fire_sparks_main.dds';embers.EmissionDirection=Enum.NormalId.Top;embers.Speed=NumberRange.new(12,26);embers.Acceleration=Vector3.new(0,-17,0)
  local light=Instance.new('PointLight');light.Color=gold;light.Range=radius*3;light.Brightness=2.5;light.Parent=p;Tween:Create(light,TweenInfo.new(.6),{Brightness=0}):Play();fade(p,life)
 end
 local function slam(point,radius)
  rupture(point,radius,false)
  local p=host('DragonLandingShock',CFrame.new(point.X,.4,point.Z),1.25)
  circle(p,radius*.4,white,.5,false)
  for _,a in ipairs(p:GetChildren())do if a:IsA('Attachment')then Tween:Create(a,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=a.Position/.4}):Play()end end
  local dust=Instance.new('ParticleEmitter');dust.Texture='rbxasset://textures/particles/smoke_main.dds';dust.Rate=0;dust.Lifetime=NumberRange.new(.4,.9);dust.Size=NumberSequence.new(3,9);dust.Speed=NumberRange.new(15,24);dust.SpreadAngle=Vector2.new(85,85);dust.Color=ColorSequence.new(Color3.fromRGB(124,103,90));dust.Transparency=NumberSequence.new(.5,1);dust.Drag=5;dust.Parent=p;dust:Emit(22)
  for i=1,12 do
   local angle=i*math.pi/6;local dir=Vector3.new(math.cos(angle),0,math.sin(angle))
   local rock=host('LandingDebris',CFrame.new(point+dir*radius*.35+Vector3.new(0,.4,0)),1.1)
   rock.Transparency=0;rock.Size=Vector3.new(1.4+(i%3)*.5,1.2,2);rock.Material=Enum.Material.Slate;rock.Color=Color3.fromRGB(66,53,54)
   local peak=point+dir*radius*.7+Vector3.new(0,3+i%3,0)
   Tween:Create(rock,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=peak,Orientation=Vector3.new(i*23,i*41,38)}):Play()
   task.delay(.22,function()if rock.Parent then Tween:Create(rock,TweenInfo.new(.55,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=Vector3.new(peak.X,.2,peak.Z),Transparency=1}):Play()end end)
  end
  fade(p,1.1)
 end
 local function tailSpin(model,radius,duration)
  if not model or not model.Parent then return end
  local root=model.PrimaryPart;if not root then return end
  local p=host('DragonTailArc',CFrame.new(root.Position.X,1.8,root.Position.Z),duration+.4)
  local arcs={}
  for i=1,5 do
   local a=Instance.new('Attachment');a.Parent=p;local b=Instance.new('Attachment');b.Parent=p
   table.insert(arcs,{a=a,b=b,beam=ribbon(p,a,b,2.5,red,fire)})
  end
  local e=particles(p,gold,18,.6);e.Texture='rbxasset://textures/particles/smoke_main.dds';e.Rate=45;e.Lifetime=NumberRange.new(.15,.35);e.Size=NumberSequence.new(2,5);e.Transparency=NumberSequence.new(.6,1)
  local time=0;local conn
  conn=Run.RenderStepped:Connect(function(dt)
   time+=dt
   if not p.Parent or not root.Parent or time>=duration then conn:Disconnect();if p.Parent then e.Enabled=false;fade(p,.2)end;return end
   p.Position=Vector3.new(root.Position.X,1.8,root.Position.Z)
   local heading=root.CFrame.LookVector
   local sweep=math.atan2(-heading.Z,-heading.X)
   local strength=math.sin(math.clamp(time/duration,0,1)*math.pi)
   e.Rate=20+45*strength
   for i,v in ipairs(arcs)do
    local a=sweep-(i-1)*.2;local b=sweep-i*.2
    v.beam.Transparency=NumberSequence.new(.8-strength*.65);v.beam.Width0=1+strength*1.5;v.beam.Width1=v.beam.Width0
    v.a.Position=Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
    v.b.Position=Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius)
   end
  end)
 end
 local function breath(origin,direction,settings)
  for i=0,3 do task.delay(i*.14,function()if fx.Parent then wave(origin,direction,settings.range,true,settings.angle,.55)end end)end
 end
 local function dive(model,duration)
  if not model or not model.Parent then return end
  local root=model.PrimaryPart;if not root then return end
  local a=Instance.new('Attachment');a.Position=Vector3.new(-6,8,3);a.Parent=root
  local b=Instance.new('Attachment');b.Position=Vector3.new(6,8,3);b.Parent=root
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.45;trail.Color=ColorSequence.new(gold,red);trail.Transparency=NumberSequence.new(.3,1);trail.LightEmission=1;trail.Parent=a
  local rush=Instance.new('ParticleEmitter');rush.Texture=fire;rush.Rate=70;rush.Lifetime=NumberRange.new(.18,.4);rush.Speed=NumberRange.new(4,9);rush.EmissionDirection=Enum.NormalId.Back;rush.SpreadAngle=Vector2.new(20,20);rush.Size=NumberSequence.new(3,0);rush.Color=ColorSequence.new(gold,red);rush.Transparency=NumberSequence.new(.4,1);rush.LightEmission=1;rush.Parent=a
  task.delay(duration,function()if rush.Parent then rush.Enabled=false end end)
  Debris:AddItem(a,duration+.5);Debris:AddItem(b,duration+.5)
 end
 return {Slam=slam,TailSpin=tailSpin,FireWave=fireWave,Rupture=rupture,Breath=breath,Dive=dive}
end
