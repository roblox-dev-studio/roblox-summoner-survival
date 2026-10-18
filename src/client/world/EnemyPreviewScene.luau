-- Local WorldModel demonstration; exact combat model clones, illustrative timing, no AI/damage.
return function(deps)
 local world=deps.world
 local skeleton=require(script.Parent.EnemyVisuals)
 local variation=require(script.Parent.EnemyMotion)
 local rig;local generation=0
 local function part(name,size,cf,color,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=world;return p
 end
 local floor=part('DisplayFloor',Vector3.new(42,.2,42),CFrame.new(0,-.15,0),Color3.fromRGB(37,48,65));floor.Material=Enum.Material.SmoothPlastic
 local effects=Instance.new('Folder');effects.Name='Demonstration';effects.Parent=world
 local actor;local kind,mode,time='stalker','idle',0
 local orb,warning,burst
 local function clear()
  generation+=1;if rig then skeleton.destroy(rig);rig=nil end
  if typeof(actor)=='Instance'then actor:Destroy()end;actor=nil
  effects:ClearAllChildren();orb=nil;warning=nil;burst=nil
 end
 local function visual(name,size,cf,color,shape)local p=part(name,size,cf,color,shape);p.Parent=effects;return p end
 local function disc(name,radius,point,color)
  local p=visual(name,Vector3.new(.06,radius*2,radius*2),CFrame.new(point)*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder);p.Transparency=.65;return p
 end
 local function play(template,isElite,action)
  clear();kind=template.Name;mode=action;time=0
  actor=template:Clone();actor.Name='PreviewEnemy';actor.Parent=world
  if isElite then
   actor:ScaleTo(1.2);actor:SetAttribute('Elite',true)
   local crown=part('EliteCrown',Vector3.one*.6,CFrame.new(actor:GetPivot().Position+Vector3.new(0,4.8,0)),Color3.fromRGB(255,215,111),Enum.PartType.Ball);crown.Parent=actor
  end
  actor:PivotTo(CFrame.new(0,3,3))
  if actor:GetAttribute('EnemyKind')then
   local current=actor;local token=generation
   task.spawn(function()local result=skeleton.create(current);if token~=generation then skeleton.destroy(result)else rig=result;if rig then rig.motion=variation.create(kind..':preview',skeleton.duration(rig,'walk'));rig.previous=actor:GetPivot().Position end end end)
  end
  if mode=='attack'then disc('TargetArea',2,Vector3.new(0,.06,-11),Color3.fromRGB(115,174,201))end
 end
 local function step(dt)
  if not actor then return end
  time+=dt;local t=time%4;local pos=Vector3.new(0,3,3);local bob=math.sin(time*(kind=='skitter'and 9 or 4))*.08
  if mode=='walk'then
   local speed=kind=='brute'and .68 or(kind=='skitter'and 1.18 or(kind=='caster'and .85 or 1));local progress=(time*speed/4)%1;pos=Vector3.new(kind=='skitter'and math.sin(progress*math.pi)*3 or(kind=='caster'and math.sin(progress*math.pi*2)*3 or 0),3,6-progress*10)
  elseif mode=='attack'then
   if kind=='charger'then
    if t<.85 then
     if not warning then warning=visual('ChargeWarning',Vector3.new(4,.06,23),CFrame.new(0,.1,-8.5),Color3.fromRGB(255,151,75));warning.Transparency=.7 end
    else if warning then warning:Destroy();warning=nil end;pos=Vector3.new(0,3,3-math.min(t-.85,.65)*34)end
   elseif kind=='caster'then
    local staff=actor:FindFirstChild('StaffOrb');if staff then staff.Color=t<.8 and Color3.fromRGB(255,230,255)or Color3.fromRGB(214,127,255)end
    if t>=.8 and t<2 then
     if not orb then orb=visual('EnemyArcaneBolt',Vector3.one*.75,CFrame.new(),Color3.fromRGB(226,126,255),Enum.PartType.Ball)end
     orb.Position=Vector3.new(0,4.1,3-(t-.8)*22)
    elseif orb then orb:Destroy();orb=nil end
   elseif kind=='ember'then
    if t<1.2 then
     if not warning then warning=disc('EnemyBlastWarning',6,Vector3.new(0,.08,3),Color3.fromRGB(255,74,45))end
     local core=actor:FindFirstChild('FurnaceCore');if core then core.Color=Color3.fromRGB(255,180+math.floor(60*math.sin(time*16)),90)end
    else
     if warning then warning:Destroy();warning=nil end
     if t<1.7 then
      if not burst then burst=visual('ExplosionRange',Vector3.one,CFrame.new(0,2,3),Color3.fromRGB(255,113,43),Enum.PartType.Ball)end
      local progress=(t-1.2)/.5;burst.Size=Vector3.one*(2+progress*10);burst.Transparency=.3+progress*.7
     elseif burst then burst:Destroy();burst=nil end
    end
   else
    pos=Vector3.new(kind=='skitter'and math.sin(math.min(t,1.1)/1.1*math.pi)*3 or 0,3,3-math.min(t,1.1)*8)
    if t>=1.1 and t<1.5 and not warning then warning=disc('ContactAttack',kind=='brute'and 4 or 2,Vector3.new(pos.X,.1,pos.Z-1.4),Color3.fromRGB(231,89,92))end
    if t>=1.5 and warning then warning:Destroy();warning=nil end
   end
   if t<.03 then if orb then orb:Destroy();orb=nil end;if burst then burst:Destroy();burst=nil end end
  end
  actor:PivotTo(CFrame.new(pos+Vector3.new(0,bob,0)))
  if rig then
   local motion=mode;local clock=time
   if mode=='attack'then
    if kind=='caster'then motion=t<.8 and'prepare'or(t<1.6 and'attack'or'idle');clock=motion=='attack'and(t-.8)or t
    elseif kind=='ember'then motion=t<1.2 and'idle'or'attack';clock=math.max(0,t-1.2)
    elseif kind=='charger'then motion=t<.85 and'idle'or(t<1.5 and'attack'or'idle');clock=t
    else motion=t<1.1 and'walk'or(t<2.1 and'attack'or'idle');clock=motion=='attack'and(t-1.1)or time end
   end
   rig.charging=mode=='attack'and((kind=='caster'and t<.8)or(kind=='ember'and t<1.2))
   local origin=actor:GetPivot();local delta=origin.Position-rig.previous;rig.previous=origin.Position
   variation.advance(rig.motion,dt,Vector3.new(delta.X,0,delta.Z).Magnitude,rig.stride,false)
   if motion=='walk'then clock=rig.motion.gait elseif motion=='idle'then clock=rig.motion.time end
   skeleton.pose(rig,variation.frame(rig.motion,origin,dt,motion=='walk',false),clock,motion)
  end
  return time
 end
 return {Play=play,Step=step,Clear=clear,Destroy=function()clear();floor:Destroy();effects:Destroy()end}
end
