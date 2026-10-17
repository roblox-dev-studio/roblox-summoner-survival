-- Local effect gallery. No damage, remotes, live actor movement, or XP changes.
return function(deps)
 local root=Instance.new('Folder');root.Name='SkillPreviewStage';root.Parent=workspace
 local stage=Instance.new('Folder');stage.Name='Stage';stage.Parent=root
 local actors=Instance.new('Folder');actors.Name='Actors';actors.Parent=root
 local fx=Instance.new('Folder');fx.Name='Effects';fx.Parent=root
 local origin=Vector3.new(6000,0,6000)
 local forward=Vector3.new(0,0,-1)
 local casterPoint=origin+Vector3.new(0,3,18)
 local targetPoint=origin+Vector3.new(0,3,-12)
 local function block(parent,name,size,cf,color,material,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
 end
 local floor=block(stage,'PreviewFloor',Vector3.new(112,1,124),CFrame.new(origin-Vector3.new(0,.5,0)),Color3.fromRGB(36,45,60));floor.CanQuery=true
 for i=-5,5 do
  local color=Color3.fromRGB(49,66,82)
  block(stage,'Grid',Vector3.new(.06,.03,120),CFrame.new(origin+Vector3.new(i*10,.025,0)),color)
  block(stage,'Grid',Vector3.new(110,.03,.06),CFrame.new(origin+Vector3.new(0,.025,i*10)),color)
 end
 local function mannequin(name,point,color)
  local m=Instance.new('Model');m.Name=name;m.Parent=actors
  local pivot=block(m,'HumanoidRootPart',Vector3.one*.1,CFrame.new(point),color);pivot.Transparency=1;m.PrimaryPart=pivot
  block(m,'Body',Vector3.new(2,2.6,1.2),CFrame.new(point),color)
  block(m,'Head',Vector3.one*1.35,CFrame.new(point+Vector3.new(0,2,0)),color,nil,Enum.PartType.Ball)
  for _,side in ipairs({-1,1})do
   block(m,'Arm',Vector3.new(.7,2,.7),CFrame.new(point+Vector3.new(side*1.4,.1,0)),color)
   block(m,'Leg',Vector3.new(.75,2,.8),CFrame.new(point+Vector3.new(side*.55,-2,0)),color)
  end
  return m
 end
 local caster=mannequin('Caster',casterPoint,Color3.fromRGB(107,181,203))
 local targets={};for i=1,3 do targets[i]=mannequin('Target'..i,targetPoint+Vector3.new((i-2)*9,0,0),Color3.fromRGB(133,108,155))end
 local renderer=require(script.Parent.Effects)({player=deps.player,net=deps.net,gui=deps.gui,folder=fx,listen=false})
 local time,duration,id,rank=0,3,'meteor',1
 local events,anchors={},{}
 local pet
 local function at(t,fn)table.insert(events,{time=t,run=fn,done=false})end
 local function play(kind,a,b,c)renderer.Play(kind,a,b,c)end
 local function anchor(kind,point,radius,seconds)
  local p=block(fx,'PreviewAnchor',Vector3.one*.1,CFrame.new(point),Color3.new());p.Transparency=1
  p:SetAttribute('Elapsed',0);p:SetAttribute('Duration',seconds);p:SetAttribute('Radius',radius);p:SetAttribute('Level',rank);p:SetAttribute('Launched',false)
  table.insert(anchors,p);return p
 end
 local function clear()
  table.clear(events);table.clear(anchors);fx:ClearAllChildren()
  if pet then pet:Destroy();pet=nil end
  caster:PivotTo(CFrame.lookAt(casterPoint,casterPoint+forward))
  for _,m in ipairs(targets)do m:SetAttribute('Frozen',false)end
 end
 local function begin(spell,level)
  clear();time=0;id=spell;rank=level
  if id=='meteor' or id=='frost' or id=='ward' then
   local seconds=id=='meteor' and 3.2 or(id=='blades' and 6 or(id=='frost' and .75 or 5))
   local point=id=='meteor' and targetPoint or casterPoint
   point=Vector3.new(point.X,.35,point.Z)
   local radius=id=='meteor' and 14+rank or(id=='blades' and 11+rank*.7 or(id=='frost' and 12+rank or 4))
   local a=anchor(id,point,radius,seconds);play('areaCast',a,id)
   at(seconds,function()
    a:Destroy()
    if id=='meteor' then play('meteorHit',point,radius)
    elseif id=='frost' then play('frostHit',point,radius)
    elseif id=='ward' then play('wardHit',casterPoint,true)end
   end)
   if id=='ward' then at(2,function()play('wardHit',casterPoint,false)end)end
   duration=seconds+(id=='meteor' and 2.5 or 1.6)
  elseif id=='blades' then
   local a=anchor(id,casterPoint,2,5);a.CFrame=CFrame.lookAt(casterPoint,casterPoint+forward);a:SetAttribute('Fired',0);play('areaCast',a,id)
   for shot=1,5 do
    local born=.8+(shot-1)*.18
    at(born,function()
     a:SetAttribute('Fired',shot)
     local angle=shot/6*math.pi-math.pi/2
     local point=casterPoint+Vector3.new(math.sin(angle)*4.2,3.2+math.cos(angle)*1.7,1.8)
     local target=targets[(shot-1)%3+1]:GetPivot().Position
     local delta=target-point;local bolt=anchor(id,point,0,2);bolt:SetAttribute('Role','bolt');bolt:SetAttribute('Born',born);bolt:SetAttribute('Origin',point);bolt:SetAttribute('Direction',delta.Unit);bolt.CFrame=CFrame.lookAt(point,target);play('crystalBolt',bolt)
     at(born+delta.Magnitude/48,function()bolt:Destroy();play('crystalHit',target)end)
    end)
   end
   at(4.3,function()a:SetAttribute('Fired',0)end)
   at(5,function()a:Destroy()end);duration=5.5
  elseif id=='skyLances' then
   local point=Vector3.new(targetPoint.X,.35,targetPoint.Z);local a=anchor(id,point,8.3,2.65);play('areaCast',a,id)
   for i,offset in ipairs({Vector3.zero,Vector3.new(5,0,0),Vector3.new(0,0,5),Vector3.new(-5,0,0),Vector3.new(0,0,-5)})do at(1.75+(i-1)*.16,function()play('skyLanceHit',point+offset,3.3)end)end
   at(2.65,function()a:Destroy()end);duration=4.1
  elseif id=='fire' then
   at(.2,function()play('fire',casterPoint,targetPoint,2.5+rank*.6)end);duration=2.4
  elseif id=='lightning' then
   for hop=1,1+rank do
    at(.2+(hop-1)*.14,function()
     local target=targets[(hop-1)%3+1]:GetPivot().Position
     play('lightning',casterPoint,target,hop)
    end)
   end;duration=3
  elseif id=='ice' then
   local point=casterPoint+forward*3.5+Vector3.new(0,1.2,0)
   local frame=CFrame.lookAt(point,point+forward)
   local seconds=.42+(targetPoint-point).Magnitude/36
   local a=anchor('ice',point,0,seconds);a.CFrame=frame
   play('iceCast',a,frame,.42)
   at(seconds,function()a:Destroy();targets[2]:SetAttribute('Frozen',true);play('iceHit',targets[2],targetPoint,1.2)end)
   at(seconds+1.2,function()targets[2]:SetAttribute('Frozen',false)end);duration=seconds+2
  elseif id=='fireWave' then
   at(.25,function()play('fireWave',casterPoint,forward,30)end);duration=2.4
  elseif id=='thunder'or id=='aetherLance' then
   local a=anchor(id,casterPoint,0,.4);a.CFrame=CFrame.lookAt(casterPoint,casterPoint+forward);a:SetAttribute('Range',52)
   play('activeCast',a,id);play(id=='thunder'and'thunderSpear'or'aetherSpear',a)
   at(.4+27/48,function()play(id=='thunder'and'thunderHit'or'aetherHit',targetPoint)end)
   at(.4+52/48,function()a:Destroy()end);duration=3.2
  elseif id=='iceRush' then
   local a=anchor(id,casterPoint,0,.4);a.CFrame=CFrame.lookAt(casterPoint,casterPoint+forward);a:SetAttribute('Range',34)
   play('activeCast',a,id)
   at(.4,function()a:Destroy();play('activeStrike',casterPoint,forward,{kind=id,range=34,width=6})end);duration=3
  elseif id=='missile' then
   local count=2+math.floor(rank/2)
   for index=1,count do
    local point=casterPoint+Vector3.new((index-(count+1)/2)*1.6,1.2,0)
    local seconds=(targetPoint-point).Magnitude/44
    local a=anchor(id,point,0,seconds);a.CFrame=CFrame.lookAt(point,targetPoint);a:SetAttribute('Index',index);a:SetAttribute('Count',count)
    play('homingMissile',a)
    at(seconds,function()a:Destroy();play('missileHit',targetPoint)end)
   end;duration=2.8
  elseif id=='golem' then
   local runtime=workspace:FindFirstChild('SummonerRuntime');local live=runtime and runtime:FindFirstChild(deps.player.Name..'_Golem')
   if live and live.Archivable then
    pet=live:Clone()
    for _,v in ipairs(pet:GetDescendants())do
     if v:IsA('LuaSourceContainer')then v:Destroy()elseif v:IsA('BasePart')then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
    end
    pet.Name='PreviewGolem';pet.Parent=actors;pet:PivotTo(CFrame.new(origin+Vector3.new(0,3.6,-1)))
    play('golemCharge',pet,.65)
   end
   at(.77,function()play('golemHeavy',origin+Vector3.new(0,.35,-4),11+rank,rank)end);duration=3.5
  elseif id=='dash' then
   at(.3,function()play('dash',caster,.23,forward)end);duration=2.2
  end
  return duration
 end
 local function step(dt)
  time+=dt
  for _,a in ipairs(anchors)do
   if a.Parent then
    a:SetAttribute('Elapsed',time)
    if id=='blades' and a:GetAttribute('Role')=='bolt' then
     local point=a:GetAttribute('Origin')+a:GetAttribute('Direction')*math.max(0,time-a:GetAttribute('Born'))*48;a.CFrame=CFrame.lookAt(point,point+a:GetAttribute('Direction'))
    elseif (id=='thunder'or id=='aetherLance')and time>=.4 then
     a:SetAttribute('Launched',true);local p=casterPoint+forward*(3+math.min(52,(time-.4)*48))+Vector3.new(0,1.2,0);a.CFrame=CFrame.lookAt(p,p+forward)
    elseif id=='missile' then
     local index=a:GetAttribute('Index');local count=a:GetAttribute('Count')
     local start=casterPoint+Vector3.new((index-(count+1)/2)*1.6,1.2,0);local delta=targetPoint-start
     local p=start+delta.Unit*math.min(delta.Magnitude,time*44);a.CFrame=CFrame.lookAt(p,p+delta.Unit)
    elseif id=='ice' and time>=.42 then
     a:SetAttribute('Launched',true)
     local start=casterPoint+forward*3.5+Vector3.new(0,1.2,0)
     local delta=targetPoint-start;local p=start+delta.Unit*math.min(delta.Magnitude,(time-.42)*36)
     a.CFrame=CFrame.lookAt(p,p+delta.Unit)
    end
   end
  end
  if id=='dash' then local p=casterPoint+forward*64*math.clamp(time-.3,0,.23);caster:PivotTo(CFrame.lookAt(p,p+forward))end
  for _,event in ipairs(events)do if not event.done and time>=event.time then event.done=true;event.run()end end
  return time>=duration,time,duration
 end
 return {Root=root,Origin=origin,Effects=fx,Play=begin,Step=step,Clear=clear,Destroy=function()clear();renderer.Disconnect();game:GetService('Debris'):AddItem(root,3)end}
end
