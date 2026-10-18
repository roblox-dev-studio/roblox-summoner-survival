-- Original gold/blue ceremonial lances descend from a suspended arcane seal.
return function(deps)
 local Run=game:GetService('RunService');local fx=deps.folder
 local gold=Color3.fromRGB(255,218,143);local white=Color3.fromRGB(230,250,255);local blue=Color3.fromRGB(105,178,255)
 local function part(parent,name,size,cf,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function line(parent,a,b,width,color)
  return part(parent,'SealLine',Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
 end
 local function triangle(parent,a,b,c,color)
  local ab,ac,bc=b-a,c-a,c-b
  if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b
  local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
  for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do
   if v[4]>.005 then
    local p=Instance.new('WedgePart');p.Name='LanceBlade';p.Size=Vector3.new(.025,math.abs(ab:Dot(up)),v[4]);p.CFrame=CFrame.fromMatrix((a+v[1])/2,v[2],up,v[3]);p.Material=Enum.Material.Neon;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
   end
  end
 end
 local function cast(anchor)
  if type(anchor)=='string'then local world=workspace:WaitForChild('SummonerRuntime',3);anchor=world and world:WaitForChild(anchor,2)end
  if not anchor or not anchor.Parent then return end
  local model=Instance.new('Model');model.Name='CelestialLanceRain';model.Parent=fx
  local seal=Instance.new('Model');seal.Name='SkyMagicCircle';seal.Parent=model
  local pivot=part(seal,'Pivot',Vector3.one*.1,CFrame.identity,gold);pivot.Transparency=1;seal.PrimaryPart=pivot
  for layer=1,2 do for i=1,48 do local a=i*math.pi/24;local b=(i+1)*math.pi/24;local r=layer==1 and 8.5 or 6.9;line(seal,Vector3.new(math.cos(a)*r,0,math.sin(a)*r),Vector3.new(math.cos(b)*r,0,math.sin(b)*r),layer==1 and .1 or .06,layer==1 and gold or blue)end end
  for i=1,8 do
   local a=i*math.pi/4;local b=a+math.pi*.75
   line(seal,Vector3.new(math.cos(a)*6.4,0,math.sin(a)*6.4),Vector3.new(math.cos(b)*6.4,0,math.sin(b)*6.4),.055,blue)
   local frame=CFrame.Angles(0,-a,0)*CFrame.new(7.6,0,0)
   for j=-1,1 do part(seal,'SealRune',Vector3.new(.12,.08,.35),frame*CFrame.new(0,0,j*.25)*CFrame.Angles(0,j*.6,0),gold)end
  end
  local lances={};local offsets={Vector3.zero,Vector3.new(5,0,0),Vector3.new(0,0,5),Vector3.new(-5,0,0),Vector3.new(0,0,-5)}
  if(anchor:GetAttribute('Count')or 5)==7 then table.insert(offsets,Vector3.new(3.5,0,3.5));table.insert(offsets,Vector3.new(-3.5,0,-3.5))end
  for i,offset in ipairs(offsets)do
   local m=Instance.new('Model');m.Name='FallingMagicLance';m.Parent=model
   local p=part(m,'Pivot',Vector3.one*.1,CFrame.identity,white);p.Transparency=1;m.PrimaryPart=p
   part(m,'LanceShaft',Vector3.new(.16,13,.16),CFrame.new(0,12,0),Color3.fromRGB(62,104,156),Enum.Material.Metal)
   part(m,'LanceSpine',Vector3.new(.055,13,.055),CFrame.new(0,12,-.12),white)
   local ring={Vector3.new(.6,5,0),Vector3.new(0,5,.6),Vector3.new(-.6,5,0),Vector3.new(0,5,-.6)}
   for j=1,4 do triangle(m,Vector3.zero,ring[j],ring[j%4+1],j%2==0 and white or blue);triangle(m,Vector3.new(0,7,0),ring[j%4+1],ring[j],blue)end
   for _,side in ipairs({-1,1})do triangle(m,Vector3.new(0,7,0),Vector3.new(side*1.15,5.8,0),Vector3.new(side*.4,8.5,0),gold)end
   local a=Instance.new('Attachment');a.Position=Vector3.new(-.3,17,0);a.Parent=p;local b=Instance.new('Attachment');b.Position=Vector3.new(.3,17,0);b.Parent=p
   local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Color=ColorSequence.new(white,blue);trail.Lifetime=.3;trail.Transparency=NumberSequence.new(.15,1);trail.LightEmission=1;trail.Parent=p
   local light=Instance.new('PointLight');light.Color=blue;light.Range=8;light.Brightness=1;light.Parent=p
   lances[i]={model=m,offset=offset,trail=trail}
  end
  local conn,dc
  local function clear()if conn then conn:Disconnect()end;if dc then dc:Disconnect()end;model:Destroy()end
  dc=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent then clear();return end
   local t=anchor:GetAttribute('Elapsed')or 0
   seal:PivotTo(CFrame.new(anchor.Position+Vector3.new(0,44,0))*CFrame.Angles(0,t*.3,0))
   for i,lance in ipairs(lances)do
    local u=math.clamp((t-.9-(i-1)*.16)/.85,0,1)
    local h=44*(1-u*u);lance.model:PivotTo(CFrame.new(anchor.Position+lance.offset+Vector3.new(0,h,0)));lance.trail.Enabled=u>0 and u<1
    for _,p in ipairs(lance.model:GetDescendants())do if p:IsA('BasePart')and p.Name~='Pivot'then p.LocalTransparencyModifier=u>=1 and math.clamp((t-(1.75+(i-1)*.16))/.25,0,1)or 0 end end
   end
  end)
 end
 return {Cast=cast}
end
