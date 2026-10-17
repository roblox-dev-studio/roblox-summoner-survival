-- Flat spinning crescent, comet-tip trails and compact wand bolts.
return function(deps)
 local Run=game:GetService('RunService');local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris')
 local fx=deps.folder;local white=Color3.fromRGB(225,251,255);local blue=Color3.fromRGB(105,204,255);local purple=Color3.fromRGB(193,128,255)
 local function part(parent,name,size,color)
  local p=Instance.new('Part');p.Name=name;p.Shape=Enum.PartType.Ball;p.Size=size;p.Material=Enum.Material.Neon;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function resolve(a)
  if type(a)=='string'then local world=workspace:WaitForChild('SummonerRuntime',3);a=world and world:WaitForChild(a,2)end
  return a and a.Parent and a
 end
 local function beam(pivot,color,width,alpha)
  local a=Instance.new('Attachment');a.Parent=pivot;local b=Instance.new('Attachment');b.Parent=pivot
  local e=Instance.new('Beam');e.Attachment0=a;e.Attachment1=b;e.FaceCamera=true;e.Width0=width;e.Width1=width;e.Color=ColorSequence.new(color,white);e.LightEmission=1;e.LightInfluence=0;e.Transparency=NumberSequence.new(alpha or .2);e.Parent=pivot
  return {a=a,b=b,beam=e}
 end
 local function sparks(parent,color,rate)
  local p=Instance.new('ParticleEmitter');p.Name='Starlight';p.Texture='rbxasset://textures/particles/sparkles_main.dds';p.Color=ColorSequence.new(white,color);p.Size=NumberSequence.new(.13,0);p.Transparency=NumberSequence.new(.15,1);p.Lifetime=NumberRange.new(.2,.5);p.Speed=NumberRange.new(1,3);p.SpreadAngle=Vector2.new(180,180);p.LightEmission=1;p.Rate=rate;p.Parent=parent;return p
 end
 -- Crescent = the portion of an outer disk left outside an offset inner disk.
 local radius,cutRadius,cutOffset=3,2.8,1.2
 local intersection=(radius*radius-cutRadius*cutRadius+cutOffset*cutOffset)/(2*cutOffset)
 local top=math.sqrt(radius*radius-intersection*intersection)
 local outerAngle=math.acos(intersection/radius);local innerAngle=math.atan2(top,intersection-cutOffset)
 local function moonPoint(u,inner)
  local start=inner and innerAngle or outerAngle;local angle=start+(math.pi*2-start*2)*u
  local r=inner and cutRadius or radius
  return Vector3.new(math.cos(angle)*r+(inner and cutOffset or 0),math.sin(angle)*r,0)
 end
 local function triangle(parent,a,b,c)
  if(b-a):Cross(c-a).Magnitude<.0001 then return end
  local ab,ac,bc=b-a,c-a,c-b
  if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b;local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
  for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do if v[4]>.005 then
   local p=Instance.new('WedgePart');p.Name='CrescentBody';p.Size=Vector3.new(.035,math.abs(ab:Dot(up)),v[4]);p.CFrame=CFrame.fromMatrix((a+v[1])/2,v[2],up,v[3]);p.Color=purple;p.Material=Enum.Material.Neon;p.Transparency=.45;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
  end end
 end
 local function cast(name,kind)
  if kind~='lightRing' then return end
  local anchor=resolve(name);if not anchor then return end
  local model=Instance.new('Model');model.Name='NebulaCrescent';model.Parent=fx
  local pivot=part(model,'Pivot',Vector3.one*.1,purple);pivot.Transparency=1;model.PrimaryPart=pivot
  for i=1,20 do local u,v=(i-1)/20,i/20;triangle(model,moonPoint(u,false),moonPoint(v,false),moonPoint(v,true));triangle(model,moonPoint(u,false),moonPoint(v,true),moonPoint(u,true))end
  local ribbons={};local inside={}
  for layer=1,3 do
   ribbons[layer]={}
   for i=1,48 do
    local v=beam(pivot,layer==1 and white or purple,layer==1 and .11 or(layer==2 and .4 or 1.1),layer==1 and .08 or(layer==2 and .35 or .85))
    v.a.Position=moonPoint((i-1)/48,false);v.b.Position=moonPoint(i/48,false);ribbons[layer][i]=v
   end
  end
  for i=1,48 do local v=beam(pivot,white,.055,.25);v.a.Position=moonPoint((i-1)/48,true);v.b.Position=moonPoint(i/48,true);inside[i]=v end
  local light=Instance.new('PointLight');light.Color=purple;light.Brightness=2.4;light.Range=16;light.Parent=pivot
  local stars={}
  for i,u in ipairs({0,.5,1})do
   local star=part(model,'CrescentTip',Vector3.one*(i==2 and .16 or .24),white)
   local a=Instance.new('Attachment');a.Position=Vector3.new(-.22,0,0);a.Parent=star
   local b=Instance.new('Attachment');b.Position=Vector3.new(.22,0,0);b.Parent=star
   local trail=Instance.new('Trail');trail.Name='CrescentCometTail';trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.22;trail.MinLength=.08;trail.Color=ColorSequence.new(white,purple);trail.LightEmission=1;trail.WidthScale=NumberSequence.new(1,0);trail.Transparency=NumberSequence.new(.3,1);trail.Parent=star
   local dust=sparks(star,purple,12);dust.Size=NumberSequence.new(.16,0);dust.Speed=NumberRange.new(.5,2)
   stars[i]={p=star,u=u,trail=trail}
  end
  -- A pair of thin trailing arcs makes rotation readable without another solid disk.
  local echoes={}
  for layer=1,2 do
   echoes[layer]={}
   for i=1,24 do echoes[layer][i]=beam(pivot,layer==1 and blue or purple,.08,layer==1 and .65 or .85)end
  end
  local conn,dc;local heading=anchor.CFrame.Rotation
  local function clear()if conn then conn:Disconnect()end;if dc then dc:Disconnect()end;model:Destroy()end
  dc=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent then clear();return end
   local t=anchor:GetAttribute('Elapsed')or 0
   -- Ease into a faster flat spin; use simulation time so previews and pauses agree.
   local spin=8*t-6*.2*(1-math.exp(-t/.2))
   local display=CFrame.new(anchor.Position)*heading*CFrame.Angles(-math.pi/2,0,spin)
   model:PivotTo(display)
   local returning=anchor:GetAttribute('Returning');light.Color=returning and blue or purple
   for _,star in ipairs(stars)do star.p.Position=display:PointToWorldSpace(moonPoint(star.u,false))end
   for layer,row in ipairs(echoes)do
    local turn=CFrame.Angles(0,0,-layer*.22)
    for i,v in ipairs(row)do
     v.a.Position=turn:PointToWorldSpace(moonPoint((i-1)/24,false)*(1+layer*.035))
     v.b.Position=turn:PointToWorldSpace(moonPoint(i/24,false)*(1+layer*.035))
    end
   end
   local pulse=.9+.1*math.sin(t*13);light.Brightness=2.4*pulse
  end)
 end
 local function bolt(name)
  local anchor=resolve(name);if not anchor then return end
  local model=Instance.new('Model');model.Name='WandLightBolt';model.Parent=fx
  local p=part(model,'Core',Vector3.one*.28,white);model.PrimaryPart=p
  local glow=part(model,'Glow',Vector3.one*.65,blue);glow.Transparency=.8
  local a=Instance.new('Attachment');a.Position=Vector3.new(-.13,0,.2);a.Parent=p
  local b=Instance.new('Attachment');b.Position=Vector3.new(.13,0,.2);b.Parent=p
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.18;trail.Color=ColorSequence.new(white,blue);trail.LightEmission=1;trail.Transparency=NumberSequence.new(.1,1);trail.WidthScale=NumberSequence.new(1,0);trail.Parent=p
  sparks(p,blue,18)
  local conn,dc
  local function clear()if conn then conn:Disconnect()end;if dc then dc:Disconnect()end;model:Destroy()end
  dc=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()if not anchor.Parent then clear();return end;model:PivotTo(anchor.CFrame)end)
 end
 local function hit(pos,kind)
  local p=part(fx,'LightImpact',Vector3.one*.4,kind=='lightRing'and purple or blue);p.Position=pos;Debris:AddItem(p,.4)
  Tween:Create(p,TweenInfo.new(.3),{Size=Vector3.one*1.3,Transparency=1}):Play();sparks(p,p.Color,0):Emit(8)
 end
 return {Cast=cast,Bolt=bolt,Hit=hit}
end
