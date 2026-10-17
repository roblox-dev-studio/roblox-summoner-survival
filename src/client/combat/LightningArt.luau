-- Branched white-hot leaders, blue coronas and brief ground discharges.
return function(deps)
 local Run=game:GetService('RunService');local Players=game:GetService('Players');local Debris=game:GetService('Debris')
 local violet=Color3.fromRGB(162,77,255)
 local fx=deps.folder;local blue=Color3.fromRGB(83,157,255);local white=Color3.fromRGB(231,251,255)
 local function ground(pos)
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.RespectCanCollide=true
  local excluded={fx};local runtime=workspace:FindFirstChild('SummonerRuntime');if runtime then excluded[#excluded+1]=runtime end
  for _,p in ipairs(Players:GetPlayers())do if p.Character then excluded[#excluded+1]=p.Character end end
  params.FilterDescendantsInstances=excluded
  local hit=workspace:Raycast(pos+Vector3.new(0,8,0),Vector3.new(0,-60,0),params)
  return hit and hit.Position+Vector3.new(0,.15,0)or Vector3.new(pos.X,.15,pos.Z)
 end
 local function strike(from,to,hop)
  local model=Instance.new('Model');model.Name='BranchedChainLightning';model.Parent=fx;Debris:AddItem(model,1.4)
  local pivot=Instance.new('Part');pivot.Name='LightningPivot';pivot.Size=Vector3.one*.1;pivot.Transparency=1;pivot.Anchored=true;pivot.CanCollide=false;pivot.CanTouch=false;pivot.CanQuery=false;pivot.CFrame=CFrame.identity;pivot.Parent=model
  local strokes={};local landing=ground(to);local rng=Random.new()
  local function line(a,b,width,delay,main)
   for layer=1,main and 3 or 2 do
    local x=Instance.new('Attachment');x.Position=a;x.Parent=pivot;local y=Instance.new('Attachment');y.Position=b;y.Parent=pivot
    local beam=Instance.new('Beam');beam.Name=layer==1 and'LightningWhiteCore'or'LightningCorona';beam.Attachment0=x;beam.Attachment1=y;beam.FaceCamera=true;beam.Width0=width*(layer==1 and .38 or(layer==2 and 1.2 or 2.8));beam.Width1=beam.Width0*.85;beam.Color=ColorSequence.new(layer==1 and white or(layer==3 and violet or blue));beam.LightEmission=1;beam.Brightness=2;beam.LightInfluence=0;if layer>1 then beam.Texture='rbxasset://textures/particles/smoke_main.dds';beam.TextureMode=Enum.TextureMode.Stretch end;beam.Transparency=NumberSequence.new(1);beam.Parent=pivot
    strokes[#strokes+1]={beam=beam,delay=delay,alpha=layer==1 and .02 or(layer==2 and .36 or .78)}
   end
  end
  local function jagged(a,b,segments,width,delay,main)
   local span=b-a;if span.Magnitude<.01 then return {a,b}end;local side=span:Cross(Vector3.yAxis);if side.Magnitude<.1 then side=Vector3.xAxis else side=side.Unit end
   local other=span.Unit:Cross(side);local points={a}
   for i=1,segments-1 do
    local spread=math.sin(i/segments*math.pi)
    points[#points+1]=a:Lerp(b,i/segments)+side*rng:NextNumber(-1.5,1.5)*spread+other*rng:NextNumber(-.6,.6)*spread
   end
   points[#points+1]=b
   for i=1,#points-1 do line(points[i],points[i+1],width*(main and(.8+i/#points*.5)or(1-i/(#points*2))),delay+i*.004,main)end
   return points
  end
  local points=jagged(landing+Vector3.new(0,(hop or 1)==1 and 30 or 11,0),landing,12,2.2,0,true)
  -- Two lower forks merge into the landing rather than narrowing to one thin thread.
  jagged(landing+Vector3.new(-2,9,.5),landing+Vector3.new(.4,0,0),6,.85,.025,true)
  jagged(landing+Vector3.new(1.8,7,-.6),landing,6,.85,.04,true)
  for n=1,4 do
   local index=2+n*2;local a=points[index];local angle=n*2.2+rng:NextNumber(-.3,.3)
   jagged(a,a+Vector3.new(math.cos(angle)*(4+n*.5),-3-n*.3,math.sin(angle)*(4+n*.5)),4,.32,index*.004,false)
  end
  if (hop or 1)>1 and(from-to).Magnitude>.1 then jagged(ground(from)+Vector3.new(0,.25,0),landing+Vector3.new(0,.25,0),8,.6,.025,true)end
  for i=1,6 do
   local angle=i*math.pi/3+rng:NextNumber(-.2,.2)
   local endpoint=ground(landing+Vector3.new(math.cos(angle),0,math.sin(angle))*rng:NextNumber(5,8))
   jagged(landing,endpoint,4,.36,.055+i*.004,false)
  end
  local flash=Instance.new('Part');flash.Name='LightningLandingFlash';flash.Shape=Enum.PartType.Ball;flash.Material=Enum.Material.Neon;flash.Color=white;flash.Size=Vector3.new(1,.25,1);flash.CFrame=CFrame.new(landing);flash.Transparency=1;flash.Anchored=true;flash.CanCollide=false;flash.CanTouch=false;flash.CanQuery=false;flash.CastShadow=false;flash.Parent=model
  local light=Instance.new('PointLight');light.Color=blue;light.Range=22;light.Brightness=0;light.Parent=flash
  local sparks=Instance.new('ParticleEmitter');sparks.Texture='rbxasset://textures/particles/sparkles_main.dds';sparks.Rate=0;sparks.Lifetime=NumberRange.new(.15,.4);sparks.Speed=NumberRange.new(7,18);sparks.EmissionDirection=Enum.NormalId.Top;sparks.SpreadAngle=Vector2.new(75,75);sparks.Size=NumberSequence.new(.22,0);sparks.Color=ColorSequence.new(white,blue);sparks.LightEmission=1;sparks.Parent=flash
  local dust=Instance.new('ParticleEmitter');dust.Texture='rbxasset://textures/particles/smoke_main.dds';dust.Rate=0;dust.Lifetime=NumberRange.new(.3,.6);dust.Speed=NumberRange.new(3,6);dust.SpreadAngle=Vector2.new(80,80);dust.Color=ColorSequence.new(Color3.fromRGB(115,140,166));dust.Size=NumberSequence.new(1.2,3);dust.Transparency=NumberSequence.new(.78,1);dust.Parent=flash
  local function ball(name,size,color,alpha,pos)
   local p=Instance.new('Part');p.Name=name;p.Shape=Enum.PartType.Ball;p.Size=size;p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=alpha;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Position=pos;p.Parent=model;return p
  end
  local scale=(hop or 1)==1 and 1 or .7
  local halo=ball('VioletImpactAura',Vector3.new(1,.2,1),violet,1,landing)
  local inner=ball('CyanImpactAura',Vector3.new(1,.25,1),blue,1,landing+Vector3.new(0,.07,0))
  local column=ball('ArcaneColumn',Vector3.new(2.1,12,2.1),blue,.79,landing+Vector3.new(0,6,0))
  local petals={};local motes={}
  local function tangentFrame(pos,axis)
   local x=axis.Unit;local z=x:Cross(Vector3.zAxis);if z.Magnitude<.1 then z=x:Cross(Vector3.xAxis)end;z=z.Unit;return CFrame.fromMatrix(pos,x,z:Cross(x),z)
  end
  for i=1,16 do
   local angle=i*math.pi/8;local dir=Vector3.new(math.cos(angle),0,math.sin(angle))
   local a=Instance.new('Attachment');a.CFrame=tangentFrame(landing+dir*.4,dir+Vector3.yAxis*1.4);a.Parent=pivot
   local b=Instance.new('Attachment');b.CFrame=tangentFrame(landing+dir*(8+i%3)*scale+Vector3.new(0,.2,0),dir);b.Parent=pivot
   local beam=Instance.new('Beam');beam.Name='ArcaneImpactPetal';beam.Texture='rbxasset://textures/particles/smoke_main.dds';beam.TextureMode=Enum.TextureMode.Stretch;beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Width0=3*scale;beam.Width1=.02;beam.CurveSize0=3*scale;beam.CurveSize1=2*scale;beam.Segments=16;beam.Color=ColorSequence.new(white,i%2==0 and blue or violet);beam.LightEmission=1;beam.Brightness=2;beam.Transparency=NumberSequence.new(1);beam.Parent=pivot;petals[i]=beam
  end
  for i=1,11 do
   local a=i*math.pi*2/11;local p=ball('ArcaneSpark',Vector3.one*.28,white,1,landing)
   local glow=ball('SparkAura',Vector3.one*1.1,blue,1,landing)
   motes[i]={p=p,glow=glow,velocity=Vector3.new(math.cos(a)*(5+i%3),5+i%4,math.sin(a)*(5+i%3))}
  end
  dust.Color=ColorSequence.new(violet,blue);dust.LightEmission=1;dust.Brightness=2;dust.Size=NumberSequence.new(3,10);dust.Transparency=NumberSequence.new(.86,1)
  local bloom=Instance.new('ParticleEmitter');bloom.Name='ArcaneImpactBloom';bloom.Texture='rbxasset://textures/particles/forcefield_glow_main.dds';bloom.Rate=0;bloom.Speed=NumberRange.new(0);bloom.Lifetime=NumberRange.new(.4,.5);bloom.Size=NumberSequence.new(13*scale,20*scale);bloom.Color=ColorSequence.new(Color3.fromRGB(100,224,255),violet);bloom.Transparency=NumberSequence.new(.15,1);bloom.LightEmission=1;bloom.Brightness=5;bloom.Parent=flash
  -- Delayed concentric shock fronts travel out over the floor after contact.
  local rings={}
  for ring=1,((hop or 1)==1 and 2 or 1)do
   local segments={}
   for i=1,24 do
    local a=Instance.new('Attachment');a.Parent=pivot;local b=Instance.new('Attachment');b.Parent=pivot
    for layer=1,2 do
     local beam=Instance.new('Beam');beam.Name='LightningGroundShockRing';beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Width0=layer==1 and .13 or .85;beam.Width1=beam.Width0;beam.LightEmission=1;beam.Brightness=2;beam.Color=ColorSequence.new(ring==1 and blue or violet);beam.Transparency=NumberSequence.new(1);beam.Segments=5
     if layer==2 then beam.Texture='rbxasset://textures/particles/smoke_main.dds';beam.TextureMode=Enum.TextureMode.Stretch end
     beam.Parent=pivot;segments[#segments+1]={beam=beam,a=a,b=b,index=i,layer=layer}
    end
   end
   rings[ring]=segments
  end
  local t=0;local emitted=false;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   if not model.Parent then connection:Disconnect();return end
   t+=dt
   if t>=.055 and not emitted then emitted=true;bloom:Emit(3);sparks:Emit(40);dust:Emit(10)end
   local flicker=(t<.09 or(t>.13 and t<.19)or(t>.23 and t<.27))and 0 or .7
   for _,v in ipairs(strokes)do
    local age=t-v.delay;local fade=age<0 and 1 or math.max(flicker,math.clamp((age-.32)/.32,0,1))
    v.beam.Transparency=NumberSequence.new(v.alpha+(1-v.alpha)*fade)
   end
   local burst=math.clamp((t-.055)/.16,0,1);flash.Size=Vector3.new(1+burst*5,.3+burst*.3,1+burst*5);flash.Transparency=t<.055 and 1 or .3+burst*.7
   local age=math.max(0,t-.055);local fade=math.clamp((age-.12)/.5,0,1)
   halo.Size=Vector3.new(6+age*33,.25,6+age*33)*scale;halo.Transparency=t<.055 and 1 or .77+fade*.23
   inner.Size=Vector3.new(4+age*26,.35,4+age*26)*scale;inner.Transparency=t<.055 and 1 or .68+fade*.32
   column.Transparency=.79+fade*.21
   for _,beam in ipairs(petals)do beam.Transparency=NumberSequence.new(t<.055 and 1 or .35+fade*.65,1)end
   for _,v in ipairs(motes)do v.p.Position=landing+v.velocity*age+Vector3.new(0,-3*age*age,0);v.glow.Position=v.p.Position;v.p.Transparency=t<.055 and 1 or fade;v.glow.Transparency=.85+fade*.15 end
   for ring,segments in ipairs(rings)do
    local u=math.clamp((t-.055-(ring-1)*.1)/.55,0,1)
    local radius=(.8+(ring==1 and 13 or 11)*(1-(1-u)^2))*scale
    local alpha=u<=0 and 1 or .28+u*.72
    for _,v in ipairs(segments)do
     local function frame(index)
      local angle=index/24*math.pi*2;local tangent=Vector3.new(-math.sin(angle),0,math.cos(angle))
      return CFrame.fromMatrix(landing+Vector3.new(math.cos(angle)*radius,.08+ring*.03,math.sin(angle)*radius),tangent,Vector3.yAxis,tangent:Cross(Vector3.yAxis))
     end
     v.a.CFrame=frame(v.index-1);v.b.CFrame=frame(v.index)
     v.beam.CurveSize0=radius*math.pi/36;v.beam.CurveSize1=v.beam.CurveSize0
     v.beam.Transparency=NumberSequence.new(v.layer==1 and alpha or math.min(1,alpha+.35))
    end
   end
   light.Brightness=6*(1-math.clamp((t-.055)/.3,0,1))
   if t>=.85 then connection:Disconnect();model:Destroy()end
  end)
 end
 return {Strike=strike}
end
