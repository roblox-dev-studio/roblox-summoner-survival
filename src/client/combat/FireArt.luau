-- Adapted layering from AetherFX Fire Bolt / Lesser Fireball (MIT).
-- See assets/vfx/aetherfx/LICENSE and the pinned reference recipes.
return function(deps)
 local Tween=game:GetService('TweenService');local Run=game:GetService('RunService');local Debris=game:GetService('Debris')
 local fx=deps.folder
 local flame='rbxasset://textures/particles/fire_main.dds';local smoke='rbxasset://textures/particles/smoke_main.dds';local ember='rbxasset://textures/particles/fire_sparks_main.dds'
 local orange=Color3.fromRGB(255,124,32);local red=Color3.fromRGB(195,43,18)
 local function host(name,cf,life)
  local p=Instance.new('Part');p.Name=name;p.Size=Vector3.one*.15;p.CFrame=cf;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,life);return p
 end
 local function emitter(p,texture,rate,lifetime,size,color)
  local e=Instance.new('ParticleEmitter');e.Texture=texture;e.Rate=rate;e.Lifetime=lifetime;e.Size=size;e.Color=color;e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.65,.35),NumberSequenceKeypoint.new(1,1)});e.LightEmission=.7;e.LightInfluence=0;e.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;e.Rotation=NumberRange.new(-35,35);e.RotSpeed=NumberRange.new(-90,90);e.SpreadAngle=Vector2.new(20,20);e.EmissionDirection=Enum.NormalId.Back;e.Speed=NumberRange.new(3,7);e.Drag=1;e.Parent=p;return e
 end
 local colors=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,224,140)),ColorSequenceKeypoint.new(.35,orange),ColorSequenceKeypoint.new(1,red)})
 local function impact(point,radius)
  local p=host('FireballImpact',CFrame.new(point),1.4)
  local fire=emitter(p,flame,0,NumberRange.new(.22,.55),NumberSequence.new({NumberSequenceKeypoint.new(0,1.2),NumberSequenceKeypoint.new(.25,radius),NumberSequenceKeypoint.new(1,0)}),colors);fire.Speed=NumberRange.new(5,13);fire.SpreadAngle=Vector2.new(180,180);fire.Acceleration=Vector3.new(0,5,0);fire:Emit(18)
  local sparks=emitter(p,ember,0,NumberRange.new(.3,.7),NumberSequence.new(.5,0),ColorSequence.new(orange));sparks.Speed=NumberRange.new(9,18);sparks.SpreadAngle=Vector2.new(180,180);sparks.Acceleration=Vector3.new(0,-14,0);sparks:Emit(18)
  local soot=emitter(p,smoke,0,NumberRange.new(.45,1),NumberSequence.new(1,radius*1.5),ColorSequence.new(Color3.fromRGB(66,53,48)));soot.LightEmission=0;soot.Transparency=NumberSequence.new(.6,1);soot.Speed=NumberRange.new(2,5);soot.Acceleration=Vector3.new(0,4,0);soot:Emit(6)
  local light=Instance.new('PointLight');light.Color=orange;light.Range=radius*4;light.Brightness=2;light.Parent=p;Tween:Create(light,TweenInfo.new(.25),{Brightness=0}):Play()
 end
 local function bolt(a,b,radius)
  local distance=(b-a).Magnitude;if distance<.1 then return end
  local p=host('MoltenFireball',CFrame.lookAt(a,b),1.6);p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*.55;p.Color=Color3.fromRGB(255,143,35);p.Material=Enum.Material.Neon;p.Transparency=0
  local sheath=emitter(p,flame,160,NumberRange.new(.2,.38),NumberSequence.new({NumberSequenceKeypoint.new(0,1.4),NumberSequenceKeypoint.new(.25,3),NumberSequenceKeypoint.new(1,0)}),colors);sheath.Speed=NumberRange.new(1,4);sheath:Emit(12)
  local core=emitter(p,flame,70,NumberRange.new(.1,.18),NumberSequence.new(1.1,0),ColorSequence.new(Color3.fromRGB(255,225,153),orange));core.Speed=NumberRange.new(0,2)
  local tail=emitter(p,ember,35,NumberRange.new(.2,.45),NumberSequence.new(.5,0),ColorSequence.new(orange));tail.Speed=NumberRange.new(6,12)
  local soot=emitter(p,smoke,18,NumberRange.new(.25,.55),NumberSequence.new(1.1,2.8),ColorSequence.new(Color3.fromRGB(65,49,42)));soot.LightEmission=0;soot.Transparency=NumberSequence.new(.7,1)
  local light=Instance.new('PointLight');light.Color=orange;light.Range=9;light.Brightness=.9;light.Parent=p
  local duration=math.clamp(distance/85,.18,.42)
  Tween:Create(p,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Position=b}):Play()
  task.delay(duration,function()
   if not p.Parent then return end
   p.Transparency=1;sheath.Enabled=false;core.Enabled=false;tail.Enabled=false;soot.Enabled=false;light.Enabled=false;impact(b,math.clamp(radius,2,5))
  end)
 end
 local function jet(origin,target,duration,follow,density)
  density=density or 1
  local p=host('DragonVolumetricBreath',CFrame.lookAt(origin,target),duration+1.5)
  local body=emitter(p,flame,300*density,NumberRange.new(.35,.7),NumberSequence.new({NumberSequenceKeypoint.new(0,1.2),NumberSequenceKeypoint.new(.3,5.2),NumberSequenceKeypoint.new(.7,8),NumberSequenceKeypoint.new(1,0)}),colors)
  body.EmissionDirection=Enum.NormalId.Front;body.SpreadAngle=Vector2.new(12,10);body.Orientation=Enum.ParticleOrientation.FacingCamera
  local core=emitter(p,flame,100*density,NumberRange.new(.25,.5),NumberSequence.new(1.6,4.5),ColorSequence.new(Color3.fromRGB(255,221,137),orange));core.EmissionDirection=Enum.NormalId.Front;core.SpreadAngle=Vector2.new(5,5)
  local soot=emitter(p,smoke,25*density,NumberRange.new(.55,1),NumberSequence.new(2,8),ColorSequence.new(Color3.fromRGB(52,44,39)));soot.EmissionDirection=Enum.NormalId.Front;soot.LightEmission=0;soot.Transparency=NumberSequence.new(.75,1)
  local sparks=emitter(p,ember,55*density,NumberRange.new(.35,.7),NumberSequence.new(.7,0),ColorSequence.new(orange));sparks.EmissionDirection=Enum.NormalId.Front;sparks.SpreadAngle=Vector2.new(16,14)
  local t=0;local conn
  conn=Run.RenderStepped:Connect(function(dt)
   t+=dt
   if not p.Parent or t>=duration then conn:Disconnect();for _,e in ipairs({body,core,soot,sparks})do e.Enabled=false end;return end
   local start,finish=origin,target
   if follow then start,finish=follow(t/duration)end
   local speed=math.clamp((finish-start).Magnitude/.55,30,95)
   p.CFrame=CFrame.lookAt(start,finish)
   body.Speed=NumberRange.new(speed*.85,speed*1.1);core.Speed=NumberRange.new(speed,speed*1.1);soot.Speed=NumberRange.new(speed*.5,speed*.75);sparks.Speed=NumberRange.new(speed*.8,speed*1.1)
  end)
 end
 local function charge(model,duration)
  if not model or not model.Parent then return end
  local p=host('DragonThroatCharge',model:GetPivot(),duration+.8)
  local e=emitter(p,ember,70,NumberRange.new(.15,.4),NumberSequence.new(.65,0),colors);e.Speed=NumberRange.new(2,5);e.SpreadAngle=Vector2.new(180,180)
  local glow=Instance.new('PointLight');glow.Color=orange;glow.Range=13;glow.Brightness=0;glow.Parent=p;Tween:Create(glow,TweenInfo.new(duration),{Brightness=3}):Play()
  local t=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   t+=dt
   if not p.Parent or not model.Parent or t>=duration then connection:Disconnect();if p.Parent then e.Enabled=false;glow.Enabled=false end;return end
   p.Position=model:GetAttribute('DragonMouth')or model:GetPivot():PointToWorldSpace(Vector3.new(0,19.2,-10.2))
  end)
 end
 local function mouth(model,fallback)
  return model and model.Parent and model:GetAttribute('DragonMouth')or fallback
 end
 local function breath(origin,direction,settings)
  -- Five volumetric jets show the complete wide fan instead of a narrow centre ray.
  for i=-2,2 do
   local d=CFrame.Angles(0,math.rad(i*(settings.angle or 45)*.4),0):VectorToWorldSpace(direction)
   local target=Vector3.new(origin.X,.7,origin.Z)+d*(settings.range*.92)
   jet(origin,target,1.05,function()return mouth(settings.model,origin),target end,.38)
  end
 end
 local function fireLine(from,finish,settings)
  local span=finish-from;local length=span.Magnitude;if length<.1 then return end
  local count=math.clamp(math.ceil(length/6),1,16)
  for i=0,count-1 do
   local pos=from:Lerp(finish,(i+.5)/count);pos=Vector3.new(pos.X,.35,pos.Z)
   local p=host('DragonFireLane',CFrame.lookAt(pos,pos+span),1.4)
   p.Size=Vector3.new(settings.halfWidth*2,.15,length/count)
   local e=emitter(p,flame,0,NumberRange.new(.35,.8),NumberSequence.new({NumberSequenceKeypoint.new(0,2),NumberSequenceKeypoint.new(.25,6),NumberSequenceKeypoint.new(1,0)}),colors)
   e.EmissionDirection=Enum.NormalId.Top;e.Speed=NumberRange.new(10,19);e.SpreadAngle=Vector2.new(25,25);e:Emit(20)
   local sparks=emitter(p,ember,0,NumberRange.new(.35,.7),NumberSequence.new(.55,0),ColorSequence.new(orange));sparks.EmissionDirection=Enum.NormalId.Top;sparks.Speed=NumberRange.new(12,20);sparks:Emit(5)
  end
  local origin=mouth(settings.model,from+Vector3.new(0,18,0))
  jet(origin,from,settings.duration,function(alpha)return mouth(settings.model,origin),from:Lerp(finish,alpha)end,.6)
 end
 local function airBreath(model,points,duration)
  if not model or not model.Parent then return end
  local root=model.PrimaryPart;if not root then return end
  jet(root.Position,points[1],duration,function(alpha)
   local index=math.clamp(alpha*(#points-1)+1,1,#points);local lo=math.floor(index);local hi=math.min(#points,lo+1)
   local target=points[lo]:Lerp(points[hi],index-lo)
   return model:GetAttribute('DragonMouth')or root.CFrame:PointToWorldSpace(Vector3.new(0,19.2,-10.2)),Vector3.new(target.X,.5,target.Z)
  end)
 end
 local function wave(origin,direction,range)
  for i=-2,2 do
   local dir=CFrame.Angles(0,math.rad(i*14),0):VectorToWorldSpace(direction)
   local p=host('SpellFlameFront',CFrame.lookAt(origin+dir*2,origin+dir*3),1.6)
   local e=emitter(p,flame,180,NumberRange.new(.16,.35),NumberSequence.new({NumberSequenceKeypoint.new(0,1.8),NumberSequenceKeypoint.new(.3,3.6),NumberSequenceKeypoint.new(1,0)}),colors);e.EmissionDirection=Enum.NormalId.Top;e.Speed=NumberRange.new(2,8);e.Acceleration=Vector3.new(0,6,0);e:Emit(10)
   local emb=emitter(p,ember,25,NumberRange.new(.2,.55),NumberSequence.new(.45,0),ColorSequence.new(orange));emb.Speed=NumberRange.new(5,10)
   Tween:Create(p,TweenInfo.new(.42,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=origin+dir*range}):Play()
   task.delay(.42,function()if p.Parent then e.Enabled=false;emb.Enabled=false end end)
  end
 end
 return {FireLine=fireLine,Charge=charge,Bolt=bolt,Breath=breath,AirBreath=airBreath,Wave=wave,Impact=impact}
end
