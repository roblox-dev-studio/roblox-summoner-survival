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
 local gold=Color3.fromRGB(255,211,86);local white=Color3.fromRGB(255,247,205)
 local function glow(parent,name,size,color,alpha)
  local p=Instance.new('Part');p.Name=name;p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*size;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=alpha;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
 end
 -- Attached flame body with only a brief, faint wake; no ground fire or burst.
 local function fireballBody(p,size)
  -- The luminous core sits inside flame, rather than reading as a bare white sphere.
  local core=glow(p,'WhiteHotCore',size*.22,Color3.fromRGB(255,155,48),.8)
  local shell=glow(p,'AmberFlameHalo',size*.52,Color3.fromRGB(225,60,15),.9)
  core.CFrame=p.CFrame;shell.CFrame=p.CFrame
  local layers={}
  for i=0,3 do
   local attachment=Instance.new('Attachment');attachment.Name='FlameBodyLayer';attachment.Parent=p
   local scale=i==0 and .82 or .84-i*.035
   local body=emitter(attachment,flame,i==0 and 90 or 48,NumberRange.new(.1,.18),NumberSequence.new({NumberSequenceKeypoint.new(0,size*scale*.65),NumberSequenceKeypoint.new(.25,size*scale),NumberSequenceKeypoint.new(1,size*scale*.45)}),colors)
   body.Name=i==0 and 'AttachedFlame'or'AttachedFlameTongue';body.LockedToPart=true;body.Speed=NumberRange.new(0);body.Acceleration=Vector3.zero;body.Drag=0;body.VelocityInheritance=0
   body.Orientation=Enum.ParticleOrientation.FacingCamera;body.Rotation=NumberRange.new(-12,12);body.RotSpeed=NumberRange.new(65,115);body.Squash=NumberSequence.new(0);body.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,212,95)),ColorSequenceKeypoint.new(.45,Color3.fromRGB(255,128,24)),ColorSequenceKeypoint.new(1,Color3.fromRGB(225,48,8))});if i>0 then body.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,112,22)),ColorSequenceKeypoint.new(.4,Color3.fromRGB(235,53,12)),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,18,8))})end;body.LightEmission=1;body.Brightness=i==0 and 2 or 1.4;body.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(.2,.08),NumberSequenceKeypoint.new(.7,.28),NumberSequenceKeypoint.new(1,1)});body:Emit(i==0 and 8 or 4)
   layers[#layers+1]={attachment=attachment,body=body,index=i}
  end
  -- Tail belongs to the projectile, so its silhouette is independent of wake lifetime.
  local tailLayers={}
  for i=1,11 do
   local attachment=Instance.new('Attachment');attachment.Name='FlameTailLayer';attachment.Position=Vector3.new(0,0,size*i*.35);attachment.Parent=p
   local scale=1.06-i*.065
   local e=emitter(attachment,flame,36-i,NumberRange.new(.1,.18),NumberSequence.new({NumberSequenceKeypoint.new(0,size*scale*.7),NumberSequenceKeypoint.new(.25,size*scale),NumberSequenceKeypoint.new(1,size*scale*.3)}),ColorSequence.new(Color3.fromRGB(255,144,35),Color3.fromRGB(182,30,9)))
   e.Name='AttachedTailFlame';e.LockedToPart=true;e.Speed=NumberRange.new(0);e.Acceleration=Vector3.zero;e.VelocityInheritance=0;e.Orientation=Enum.ParticleOrientation.FacingCamera;e.Rotation=NumberRange.new(-15,15);e.RotSpeed=NumberRange.new(-35,35);e.Squash=NumberSequence.new(-.25);e.LightEmission=1;e.Brightness=2.2;e.Transparency=NumberSequence.new(.1+i*.012,1);e:Emit(4)
   tailLayers[#tailLayers+1]={attachment=attachment,body=e,index=i}
  end
  -- Continuous tapered tongues provide a single flame silhouette instead of beads.
  local tongues={}
  for i=1,3 do
   local a=Instance.new('Attachment');a.Parent=p;local b=Instance.new('Attachment');b.Parent=p
   local beam=Instance.new('Beam');beam.Name='FlameTongue';beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=16;beam.Width0=size*(i==1 and 1.05 or .7);beam.Width1=.02;beam.Texture=flame;beam.TextureMode=Enum.TextureMode.Stretch;beam.TextureSpeed=.9+i*.3;beam.LightEmission=1;beam.Brightness=1.8
   beam.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,i==1 and Color3.fromRGB(235,64,15)or orange),ColorSequenceKeypoint.new(.35,Color3.fromRGB(218,43,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(205,32,8))});beam.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.55,.2),NumberSequenceKeypoint.new(1,.85)});beam.Parent=p
   local inner=beam:Clone();inner.Name='FlameTailCore';inner.Texture='';inner.Brightness=.65;inner.Width0=size*(i==1 and .23 or .13);inner.Color=ColorSequence.new(Color3.fromRGB(255,168,51),Color3.fromRGB(235,66,17));inner.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.57),NumberSequenceKeypoint.new(.55,.73),NumberSequenceKeypoint.new(1,1)});inner.Parent=p
   tongues[#tongues+1]={a=a,b=b,beam=beam,inner=inner,index=i}
  end
  local left=Instance.new('Attachment');left.Position=Vector3.new(-size*.12,0,size*.2);left.Parent=p
  local right=Instance.new('Attachment');right.Position=Vector3.new(size*.12,0,size*.2);right.Parent=p
  local wake=Instance.new('Trail');wake.Name='SoftFlameWake';wake.Attachment0=left;wake.Attachment1=right;wake.Lifetime=.14;wake.MinLength=.12;wake.FaceCamera=true;wake.LightEmission=1;wake.Color=ColorSequence.new(gold,orange);wake.Transparency=NumberSequence.new(.6,1);wake.WidthScale=NumberSequence.new(1,0);wake.Texture=flame;wake.TextureMode=Enum.TextureMode.Stretch;wake.Parent=p
  local rear=Instance.new('Attachment');rear.Name='BriefFlameAfterglow';rear.Position=Vector3.new(0,0,size*.45);rear.Parent=p
  local remnants=emitter(rear,flame,22,NumberRange.new(.08,.16),NumberSequence.new({NumberSequenceKeypoint.new(0,size*.4),NumberSequenceKeypoint.new(.2,size*.5),NumberSequenceKeypoint.new(1,0)}),ColorSequence.new(gold,orange))
  remnants.Name='BriefFlameRemnants';remnants.LockedToPart=false;remnants.Speed=NumberRange.new(.4,1.2);remnants.SpreadAngle=Vector2.new(12,12);remnants.Acceleration=Vector3.new(0,2,0);remnants.VelocityInheritance=0;remnants.LightEmission=1;remnants.Brightness=2;remnants.Transparency=NumberSequence.new(.5,1)
  local light=Instance.new('PointLight');light.Color=gold;light.Range=8;light.Brightness=.8;light.Parent=p
  local function animate(t)
   core.CFrame=p.CFrame;core.Size=Vector3.one*(size*.22+math.sin(t*24)*size*.018)
   shell.CFrame=p.CFrame;shell.Size=Vector3.one*(size*.52+math.sin(t*19)*size*.03)
   local angle=0;local camera=workspace.CurrentCamera
   if camera then
    local head=camera:WorldToViewportPoint(p.Position)
    local tail=camera:WorldToViewportPoint(p.Position-p.CFrame.LookVector*size)
    angle=math.deg(math.atan2(tail.X-head.X,head.Y-tail.Y))
   end
   for _,v in ipairs(tongues)do
    local i=v.index;local phase=t*7+i*math.pi*2/3
    local length=size*(i==1 and 4.3 or (i==2 and 3.7 or 3.2))+math.sin(t*19-i)*size*.12
    v.a.CFrame=CFrame.new(math.cos(phase)*size*.12,math.sin(phase)*size*.12,size*.12)*CFrame.Angles(0,-math.pi/2+math.sin(phase)*.65,0)
    v.b.CFrame=CFrame.new(math.sin(t*12-i)*size*.25,math.cos(t*15-i)*size*.2,length)*CFrame.Angles(0,-math.pi/2+math.cos(phase)*.6,0)
    v.beam.CurveSize0=size*(1.4+math.sin(t*13+i)*.4);v.beam.CurveSize1=-size*(.9+math.cos(t*11+i)*.3)
    v.inner.CurveSize0=v.beam.CurveSize0;v.inner.CurveSize1=v.beam.CurveSize1
   end
   for _,v in ipairs(tailLayers)do
    local i=v.index;local bend=math.sin(t*19-i*1.1)*size*.035*i
    v.attachment.Position=Vector3.new(bend,math.cos(t*16-i)*size*.018*i,size*i*.35)
    local flicker=angle+math.sin(t*15-i)*18
    v.body.Rotation=NumberRange.new(flicker-12,flicker+12)
   end
   for _,v in ipairs(layers)do
    local i=v.index;local curl=t*9+i/3*math.pi*2
    local radius=i==0 and 0 or size*(.28+math.sin(t*13+i)*.045)
    local spin=angle+t*155+i*105
    v.body.Rotation=NumberRange.new(spin-18,spin+18)
    v.body.Squash=NumberSequence.new(math.sin(t*15+i)*.08)
    v.attachment.Position=Vector3.new(math.cos(curl)*radius,math.sin(curl)*radius, i==0 and 0 or size*(.12+math.sin(curl*.85)*.12))
   end
  end
  local function finish()
   core.Transparency=1;shell.Transparency=1;light.Enabled=false;wake.Enabled=false;remnants.Enabled=false
   for _,v in ipairs(tongues)do v.beam.Enabled=false;v.inner.Enabled=false end
   for _,group in ipairs({layers,tailLayers})do for _,v in ipairs(group)do v.body.Enabled=false;v.body:Clear()end end
  end
  return animate,finish
 end
 local function bolt(a,b,radius)
  local distance=(b-a).Magnitude;if distance<.1 then return end
  local p=host('SolarFireball',CFrame.lookAt(a,b),1.8)
  local animate,finish=fireballBody(p,2.8)
  local t=0;local duration=math.clamp(distance/58,.24,.65);local connection
  connection=Run.RenderStepped:Connect(function(dt)
   if not p.Parent then connection:Disconnect();return end
   t+=dt;local u=math.clamp(t/duration,0,1);p.CFrame=CFrame.lookAt(a:Lerp(b,u),b+(b-a).Unit)
   animate(t)
   if u>=1 then connection:Disconnect();finish();Debris:AddItem(p,.18)end
  end)
 end
 local function projectile(name)
  local anchor=name
  if type(name)=='string'then local runtime=workspace:WaitForChild('SummonerRuntime',3);anchor=runtime and runtime:WaitForChild(name,1)end
  if typeof(anchor)~='Instance'or not anchor.Parent or not fx.Parent then return end
  local p=host('ActiveFireball',anchor.CFrame,2)
  local animate,finish=fireballBody(p,2.8)
  local t=0;local connection,destroyConnection;local ended=false
  local function stop()
   if ended then return end;ended=true
   if connection then connection:Disconnect()end;if destroyConnection then destroyConnection:Disconnect()end
   if p.Parent then finish();Debris:AddItem(p,.18)end
  end
  destroyConnection=anchor.Destroying:Connect(stop)
  connection=Run.RenderStepped:Connect(function(dt)
   if not p.Parent or not anchor.Parent then stop();return end
   t+=dt;p.CFrame=p.CFrame:Lerp(anchor.CFrame,1-math.exp(-dt*35));animate(t)
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
  local model=Instance.new('Model');model.Name='RollingFlameWave';model.Parent=fx;Debris:AddItem(model,1.25)
  local frame=CFrame.lookAt(Vector3.new(origin.X,1.3,origin.Z),Vector3.new(origin.X,1.3,origin.Z)+direction)
  local plumes={}
  for i=-1,1 do
   local p=host('FlamePlume',frame,1.25);p.Size=Vector3.new(1.8,1.4,2.2);p.Parent=model
   local animate,finish=fireballBody(p,i==0 and 3.3 or 3)
   plumes[#plumes+1]={p=p,animate=animate,finish=finish,index=i,angle=math.rad(i*18)}
  end
  local t=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   if not model.Parent then connection:Disconnect();return end
   t+=dt;local u=math.clamp(t/.65,0,1);local travel=2+(range-2)*(1-(1-u)^1.25)
   for _,v in ipairs(plumes)do
    local localFrame=frame*CFrame.Angles(0,v.angle,0)
    local sway=math.sin(t*12)*.2*math.sin(u*math.pi)
    v.p.CFrame=localFrame*CFrame.new(sway,math.sin(t*12+v.index)*.25,-travel)*CFrame.Angles(0,0,math.sin(t*11+v.index)*.2)
    v.animate(t)
   end
   if u>=1 then connection:Disconnect();for _,v in ipairs(plumes)do v.finish()end;Debris:AddItem(model,.18)end
  end)
 end

 return {FireLine=fireLine,Charge=charge,Bolt=bolt,Projectile=projectile,Breath=breath,AirBreath=airBreath,Wave=wave}
end
