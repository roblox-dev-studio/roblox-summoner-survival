-- Short, local-only soul flashes; all attack geometry lives on the server.
return function(parent)
 local tween=game:GetService('TweenService');local debris=game:GetService('Debris')
 local function line(a,b,width,color,life)
  local p=Instance.new('Part');p.Name='CommanderSoul';p.Size=Vector3.new(width,width,(b-a).Magnitude);p.CFrame=CFrame.lookAt((a+b)/2,b);p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=.2;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
  tween:Create(p,TweenInfo.new(life),{Transparency=1,Size=Vector3.new(.02,.02,p.Size.Z)}):Play();debris:AddItem(p,life+.05)
 end
 return function(kind,pos,direction)
  local teal=Color3.fromRGB(114,225,209);local gold=Color3.fromRGB(255,195,113)
  local frame=CFrame.lookAt(pos,pos+(direction or Vector3.new(0,0,-1)))
  if kind=='cleave'then
   for i=1,24 do
    local a=math.rad(-75+(i-1)*150/24);local b=math.rad(-75+i*150/24)
    local p=frame:PointToWorldSpace(Vector3.new(math.sin(a)*13,1.2,-math.cos(a)*13));local q=frame:PointToWorldSpace(Vector3.new(math.sin(b)*13,1.2,-math.cos(b)*13))
    task.delay((i-1)*.008,function()if parent.Parent then line(p,q,.26,gold,.24)end end)
   end
  elseif kind=='charge'then
   for _,side in ipairs({-1,1})do line(pos+frame.RightVector*side*2,pos+direction*22+frame.RightVector*side*2,.18,teal,.35)end
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
