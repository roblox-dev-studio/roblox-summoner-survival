-- Short, local-only soul flashes; all attack geometry lives on the server.
return function(parent)
 local tween=game:GetService('TweenService');local debris=game:GetService('Debris')
 local function line(a,b,width,color,life)
  local p=Instance.new('Part');p.Name='CommanderSoul';p.Size=Vector3.new(width,width,(b-a).Magnitude);p.CFrame=CFrame.lookAt((a+b)/2,b);p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=.2;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
  tween:Create(p,TweenInfo.new(life),{Transparency=1,Size=Vector3.new(.02,.02,p.Size.Z)}):Play();debris:AddItem(p,life+.05)
 end
 return function(kind,pos,direction)
  local teal=Color3.fromRGB(127,149,186);local steel=Color3.fromRGB(218,226,240)
  local frame=CFrame.lookAt(pos,pos+(direction or Vector3.new(0,0,-1)))
  if kind=='cleave'then
   for i=1,24 do
    local a=math.rad(-85+(i-1)*170/24);local b=math.rad(-85+i*170/24)
    local p=frame:PointToWorldSpace(Vector3.new(math.sin(a)*19.5,1.2,-math.cos(a)*19.5));local q=frame:PointToWorldSpace(Vector3.new(math.sin(b)*19.5,1.2,-math.cos(b)*19.5))
    task.delay((i-1)*.008,function()if parent.Parent then line(p,q,.26,steel,.24)end end)
   end
  elseif kind=='slam'then
   task.delay(.18,function()
    if not parent.Parent then return end
    local center=Vector3.new(pos.X,.28,pos.Z)
    for i=1,32 do local a=i*math.pi*2/32;local dir=Vector3.new(math.cos(a),0,math.sin(a))
     line(center+dir*1.5,center+dir*10,.16,steel,.42)
     if i%4==0 then line(center+dir,center+dir*4+Vector3.new(0,1.2,0),.14,steel,.3)end
    end
    local host=Instance.new('Part');host.Name='CommanderImpactDust';host.Size=Vector3.one*.1;host.Transparency=1;host.Anchored=true;host.CanCollide=false;host.CanTouch=false;host.CanQuery=false;host.Position=center;host.Parent=parent;debris:AddItem(host,1)
    local dust=Instance.new('ParticleEmitter');dust.Texture='rbxasset://textures/particles/smoke_main.dds';dust.Rate=0;dust.Speed=NumberRange.new(7,13);dust.Lifetime=NumberRange.new(.2,.45);dust.SpreadAngle=Vector2.new(80,80);dust.Size=NumberSequence.new(1,3);dust.Transparency=NumberSequence.new(.65,1);dust.Color=ColorSequence.new(Color3.fromRGB(152,128,96));dust.Parent=host;dust:Emit(14)
   end)
  elseif kind=='thrust'then
   task.delay(.12,function()if not parent.Parent then return end
    for _,side in ipairs({-1,1})do line(pos+frame.RightVector*side*.65+Vector3.new(0,.6,0),pos+direction*30+frame.RightVector*side*.65+Vector3.new(0,.6,0),.12,steel,.24)end
   end)
  elseif kind=='charge'then
   for _,side in ipairs({-1,1})do line(pos+frame.RightVector*side*4,pos+direction*42+frame.RightVector*side*4,.18,teal,.35)end
  else
   local radius=kind=='defeat'and 7 or 4
   for i=1,18 do local a=i*math.pi*2/18;local b=(i+1)*math.pi*2/18
    local p=Vector3.new(pos.X,.3,pos.Z)+Vector3.new(math.cos(a),0,math.sin(a))*radius
    local q=Vector3.new(pos.X,.3,pos.Z)+Vector3.new(math.cos(b),0,math.sin(b))*radius
    line(p,q,.12,teal,.65)
    if i%3==0 then line(p,p+Vector3.new(0,kind=='defeat'and 4 or 2,0),.16,teal,.6)end
   end
  end
 end
end
