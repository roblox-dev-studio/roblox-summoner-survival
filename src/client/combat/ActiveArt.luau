-- Procedural Q charge portals, jagged lightning and a rising glacial lane.
return function(deps)
 local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris');local Run=game:GetService('RunService')
 local fx=deps.folder;local cyan=Color3.fromRGB(142,225,255);local white=Color3.fromRGB(232,251,255)
 local function part(parent,name,size,cf,color,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Color=color;p.Material=Enum.Material.Neon;p.Parent=parent;return p
 end
 local function line(parent,a,b,width,color,lifetime,alpha)
  local p=part(parent,'ArcaneBolt',Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color);p.Transparency=alpha or 0
  if lifetime then Debris:AddItem(p,lifetime);Tween:Create(p,TweenInfo.new(lifetime),{Transparency=1}):Play()end
  return p
 end
 local function charge(name,kind)
  if kind=='aetherLance' then return end -- Lance ribbons provide the charge; avoid a solid portal obscuring the shimmer.
  local anchor=name
  if type(name)=='string' then local runtime=workspace:WaitForChild('SummonerRuntime',3);anchor=runtime and runtime:WaitForChild(name,1)end
  if typeof(anchor)~='Instance' then return end
  if not anchor or not anchor.Parent then return end
  local model=Instance.new('Model');model.Name=kind..'Charge';model.Parent=fx
  local parts={};for i=1,24 do parts[i]=part(model,'PortalRune',Vector3.one*.1,CFrame.new(),cyan)end
  local orb=part(model,'GatheringCore',Vector3.one*.6,anchor.CFrame,white,Enum.PartType.Ball)
  local length=anchor:GetAttribute('Range')or 34;local width=kind=='thunder' and 2.4 or 6
  for _,side in ipairs({-1,1})do
   local a=anchor.CFrame:PointToWorldSpace(Vector3.new(side*width,-2,0));local b=a+anchor.CFrame.LookVector*length
   local p=line(model,a,b,.1,cyan);p.Transparency=.55
  end
  local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;model:Destroy()end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent or anchor:GetAttribute('Launched') then clear();return end
   local u=math.clamp((anchor:GetAttribute('Elapsed')or 0)/.4,0,1)
   local frame=anchor.CFrame*CFrame.new(0,1.3,-3)
   orb.CFrame=frame;orb.Size=Vector3.one*(.6+u*.9)
   for i,p in ipairs(parts)do
    local a=i*math.pi/12+u*1.5;local b=(i+1)*math.pi/12+u*1.5
    local from=frame:PointToWorldSpace(Vector3.new(math.cos(a)*1.8,math.sin(a)*1.8,0));local to=frame:PointToWorldSpace(Vector3.new(math.cos(b)*1.8,math.sin(b)*1.8,0))
    p.Size=Vector3.new(.09,.09,(to-from).Magnitude);p.CFrame=CFrame.lookAt((from+to)/2,to)
   end
  end)
 end
 local function strike(origin,direction,settings)
  local side=direction:Cross(Vector3.yAxis)
  if settings.kind=='iceRush' then
   for step=1,8 do
    for _,sign in ipairs({-1,1})do
     local point=origin+direction*(step*settings.range/8)+side*sign*(1.2+step%3)
     local height=4+step%3
     local p=Instance.new('WedgePart');p.Name='GlacialRushSpire';p.Size=Vector3.new(.6,.1,2);p.CFrame=CFrame.lookAt(Vector3.new(point.X,-1,point.Z),Vector3.new(point.X,-1,point.Z)+direction)*CFrame.Angles(0,sign*.3,0);p.Color=step%2==0 and white or cyan;p.Material=Enum.Material.Glass;p.Transparency=.12;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,1.8)
     Tween:Create(p,TweenInfo.new(.2),{Size=Vector3.new(1.4,height,2.7),Position=Vector3.new(point.X,height*.35,point.Z)}):Play()
     task.delay(.7,function()if p.Parent then Tween:Create(p,TweenInfo.new(.9),{Transparency=1,Position=p.Position-Vector3.new(0,2,0)}):Play()end end)
    end
   end
   local from=Vector3.new(origin.X,.45,origin.Z);local to=from+direction*settings.range
   local wave=line(fx,from,to,1.1,cyan,.45,.4);wave.Name='GlacialRushLane'
  end
 end
 return {Charge=charge,Strike=strike}
end
