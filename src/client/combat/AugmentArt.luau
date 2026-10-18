-- Client-only augment silhouettes. BeamArc + Animator from the installed MIT VFX skill.
-- All instances are local, pooled and bounded. No damage, RNG, camera shake or authority here.
local BeamArc=require(script.Parent.vfx.BeamArc)
local Animator=require(script.Parent.vfx.Animator)
local styles=require(script.Parent.AugmentStyles)
local known={};for _,entries in pairs(styles)do for _,v in ipairs(entries)do known[v.id]=true end end
local colors={ice=Color3.fromRGB(130,236,255),lightning=Color3.fromRGB(170,192,255),meteor=Color3.fromRGB(255,142,58),blades=Color3.fromRGB(146,255,215),frost=Color3.fromRGB(177,244,255),ward=Color3.fromRGB(255,222,137),missile=Color3.fromRGB(205,155,255),skyLances=Color3.fromRGB(255,222,148),lightRing=Color3.fromRGB(143,218,255),fire=Color3.fromRGB(255,123,48),thunder=Color3.fromRGB(130,188,255),aether=Color3.fromRGB(211,165,255),iceRush=Color3.fromRGB(134,229,255)}
local tau=math.pi*2
local function ids(csv)
 local result={};for id in string.gmatch(type(csv)=='string'and csv or '','[^,]+')do if known[id]then table.insert(result,id)end end;return result
end
return function(deps)
 local folder=deps.folder
 local container,arcFree,shardFree,jobs=nil,{},{},{}
 local arcCount,shardCount,active=0,0,0
 local function ensure()
  if not container or not container.Parent then
   container=Instance.new('Folder');container.Name='AugmentVisuals';container.Parent=folder
   arcFree={};shardFree={};arcCount=0;shardCount=0
  end
 end
 local function visible(point)
  local camera=workspace.CurrentCamera
  return folder.Parent and(not camera or(camera.CFrame.Position-point).Magnitude<220)
 end
 local function arc(color)
  ensure();local a=table.remove(arcFree)
  if not a then if arcCount>=128 then return end;arcCount+=1;a=BeamArc.new(container,4,{color=color,segmentsPerPiece=10})end
  a:setColor(color);a:setEnabled(true);return a
 end
 local function shard(color)
  ensure();local p=table.remove(shardFree)
  if not p then
   if shardCount>=192 then return end;shardCount+=1;p=Instance.new('WedgePart');p.Name='AugmentFacet';p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Parent=container
  end
  p.Color=color;p.Transparency=1;return p
 end
 local function construct(id,narcs,nshards)
  local color=colors[id:match('^([^_]+)')]or colors.aether
  local a,p={},{}
  for i=1,narcs do local v=arc(color);if v then table.insert(a,v)end end
  for i=1,nshards do local v=shard(color);if v then table.insert(p,v)end end
  for _,v in ipairs(a)do v.holder:SetAttribute('Augment',id)end
  for _,v in ipairs(p)do v:SetAttribute('Augment',id)end
  return a,p
 end
 local function release(a,p)
  for _,v in ipairs(a)do if v.holder.Parent then v:setEnabled(false);table.insert(arcFree,v)end end
  for _,v in ipairs(p)do if v.Parent then v.Transparency=1;v.CFrame=CFrame.new(0,-50000,0);table.insert(shardFree,v)end end
 end
 local function run(seconds,a,p,step)
  active+=1;local handle
  handle=Animator.play(seconds,function(t,dt,age)
   if not folder.Parent or not container or not container.Parent then handle:cancel();return end
   if step(t,dt,age)==false then handle:cancel()end
  end,{onComplete=function()release(a,p);active-=1;jobs[handle]=nil end})
  jobs[handle]=true;return handle
 end
 local function curve(a,frame,r,start,sweep,width,alpha)
  if not a then return end
  a:setFrame(frame);a:set(r,start,start+sweep,function(u)return width*(.18+.82*math.sin(math.pi*u))end,alpha)
 end
 local function facet(p,frame,size,alpha)
  if not p then return end;p.CFrame=frame;p.Size=size;p.Transparency=math.clamp(alpha,0,1)
 end
 local function castOne(anchor,kind,id,role)
  if role=='aura'and kind=='blades'and id~='blades_volley'then return end
  if active>=40 or not visible(anchor.Position)then return end
  local ground=kind=='meteor'or kind=='frost'or kind=='ward'or kind=='skyLances'
  local a,p=construct(id,kind=='ward'and 3 or 2,(id=='blades_volley'or id=='skyLances_rain')and 7 or 6)
  local returning=false
  run(math.huge,a,p,function(_,_,age)
   if not anchor.Parent then return false end
   local t=anchor:GetAttribute('Elapsed')or age
   local radius=anchor:GetAttribute('Radius')or 3
   local frame=anchor.CFrame;local point=frame.Position
   if kind=='ward'then
    local ownerId=anchor:GetAttribute('OwnerUserId');local owner=ownerId and game:GetService('Players'):GetPlayerByUserId(ownerId)
    local r=owner and owner.Character and owner.Character:FindFirstChild('HumanoidRootPart')
    if r then point=r.Position-Vector3.new(0,2.6,0)end
   end
   if ground then frame=CFrame.new(point+Vector3.new(0,.35,0))end
   local alpha=.2;local spin=t*1.4
   if id=='lightRing_return' then
    returning=anchor:GetAttribute('Returning')==true
    alpha=returning and .08 or .82
    frame=CFrame.new(point)*CFrame.Angles(0,t*9,0)
    for i,v in ipairs(a)do curve(v,frame*CFrame.Angles(0,(i-1)*math.pi,0),returning and 4.1 or 2.7,-1.2,2.4,returning and .8 or .12,alpha)end
    for _,v in ipairs(p)do v.Transparency=1 end
   elseif id=='ward_reservoir' then
    for i,v in ipairs(a)do curve(v,frame*CFrame.new(0,3.7,0)*CFrame.Angles(0,spin+i*math.pi/3,0)*CFrame.Angles(math.pi/2,0,0),5.1,0,tau,.13,.22)end
    for i,v in ipairs(p)do local ang=i*tau/#p+spin;facet(v,frame*CFrame.new(math.cos(ang)*4.8,3.4+math.sin(t*.8+i)*.65,math.sin(ang)*4.8)*CFrame.Angles(0,-ang,math.pi/4),Vector3.new(.12,1.1,.65),.25)end
   elseif id=='blades_volley'and role=='aura' then
    local center=frame*CFrame.new(0,3.5,2.1)*CFrame.Angles(math.pi/2,0,0)
    for i,v in ipairs(a)do curve(v,center,4.8+(i-1)*.4,-1.35,2.7,.09,.35)end
    local fired=anchor:GetAttribute('Fired')or 0
    for i,v in ipairs(p)do local theta=i/(#p+1)*math.pi-math.pi/2;facet(v,frame*CFrame.new(math.sin(theta)*4.2,3.2+math.cos(theta)*1.7,1.8)*CFrame.Angles(0,0,t*.8+i),Vector3.new(.14,.8,.8),i<=fired and 1 or .12)end
   elseif id=='skyLances_rain'or id=='skyLances_execute' then
    local high=frame*CFrame.new(0,43,0)
    for i,v in ipairs(a)do curve(v,high*CFrame.Angles(0,spin*(i==1 and 1 or -1),0),6+i,0,tau,.16,.22)end
    for i,v in ipairs(p)do local ang=i*tau/#p;facet(v,high*CFrame.new(math.cos(ang)*7,math.sin(t+i)*.3,math.sin(ang)*7)*CFrame.Angles(0,ang,math.pi/4),Vector3.new(.17,id=='skyLances_execute'and 3 or 1.4,.7),.12)end
   elseif id=='meteor_wide'or id=='meteor_echo' then
    local center=frame*CFrame.new(0,.2,0)
    if id=='meteor_wide'then
     -- Match AreaArt's actual diagonal fall, including windup and level size.
     local duration=anchor:GetAttribute('Duration')or 3.2
     local fall=math.clamp((t-.35)/math.max(duration-.35,.01),0,1)
     local size=10+(anchor:GetAttribute('Level')or 1)*.6
     center=CFrame.new(point+Vector3.new(20*(1-fall),76*(1-fall)^1.3+size*.3,0))
    end
    for i,v in ipairs(a)do curve(v,center*CFrame.Angles(id=='meteor_wide'and .35*i or 0,spin*(i==1 and 1 or -1),0),id=='meteor_wide'and(7+i)or radius*(.65+i*.12),-.3,tau*.84,.22,.25)end
    for i,v in ipairs(p)do local ang=i*tau/#p-spin;facet(v,center*CFrame.new(math.cos(ang)*8,.3,math.sin(ang)*8)*CFrame.Angles(.5,ang,1),Vector3.new(.18,2.4,.7),.18)end
   elseif id=='frost_wide'or id=='frost_echo' then
    for i,v in ipairs(a)do curve(v,frame*CFrame.Angles(0,spin*(i==1 and 1 or -1),0),radius*(.65+.13*i),0,tau,.12,.3)end
    for i,v in ipairs(p)do local ang=i*tau/#p;facet(v,frame*CFrame.Angles(0,ang,0)*CFrame.new(0,.3,-radius*.72)*CFrame.Angles(0,0,math.pi/2),Vector3.new(.1,2.8,1.3),.28)end
   elseif id=='ward_pulse' then
    for i,v in ipairs(a)do curve(v,frame*CFrame.new(0,.4+i*.2,0)*CFrame.Angles(0,spin,0),4.4,0,tau,.13,.35)end
    for i,v in ipairs(p)do local ang=i*tau/#p-spin;facet(v,frame*CFrame.new(math.cos(ang)*4.8,3.6,math.sin(ang)*4.8)*CFrame.Angles(0,-ang,math.pi/4),Vector3.new(.22,1.7,1.2),.15)end
   elseif id=='missile_hunter'or id=='blades_pierce'or id=='ice_shatter' then
    for i,v in ipairs(a)do curve(v,frame*CFrame.new(0,0,i*.8)*CFrame.Angles(math.pi/2,spin,0),id=='ice_shatter'and 1.6 or .65,0,math.pi*1.5,.09,.3)end
    for i,v in ipairs(p)do
     local theta=i*tau/#p+(id=='ice_shatter'and spin or 0)
     local reach=id=='ice_shatter'and 1.6 or .55
     facet(v,frame*CFrame.new(math.cos(theta)*reach,math.sin(theta)*reach,-.5)*CFrame.Angles(0,0,theta),Vector3.new(.12,id=='ice_shatter'and 1.1 or .5,id=='blades_pierce'and 3.8 or 1.8),.12)
    end
   else
    local scale=id=='fire_blast'and 1.7 or(id=='iceRush_wide'and 3.6 or 1)
    if kind=='lightRing'then frame=CFrame.new(point)*CFrame.Angles(0,t*7,0);scale=2.8 end
    for i,v in ipairs(a)do
     local cf=frame*CFrame.new(0,0,(i-1)*1.8)*CFrame.Angles(math.pi/2,spin+(i-1)*math.pi,0)
     curve(v,cf,scale*(1+(i-1)*.3),0,math.pi*1.6,.12*scale,.2)
    end
    for i,v in ipairs(p)do
     local ang=i*tau/#p+spin;local size=id=='blades_pierce'and Vector3.new(.12,.65,2.3)or Vector3.new(.12,.65,1.1)
     facet(v,frame*CFrame.new(math.cos(ang)*scale,math.sin(ang)*scale,.8)*CFrame.Angles(0,0,ang),size,.18)
    end
   end
  end)
 end
 local function cast(anchor,kind,role)
  if type(anchor)=='string'then local world=workspace:FindFirstChild('SummonerRuntime');anchor=world and world:FindFirstChild(anchor)end
  if not anchor or not anchor.Parent then return end
  for _,id in ipairs(ids(anchor:GetAttribute('VFXAugments')))do castOne(anchor,kind,id,role)end
 end
 local function impact(point,radius,meta)
  if type(meta)~='table'or active>=40 or not visible(point)then return end
  for _,id in ipairs(ids(meta.ids))do
   if active>=40 then break end
   local bonus=id=='missile_hunter'or id=='skyLances_execute'or id=='aether_execute'or id=='lightning_frozen'
   local echo=id=='meteor_echo'or id=='frost_echo'
   if (not bonus or meta.empowered)and(not echo or meta.phase=='echo')and(id~='lightRing_return'or meta.phase=='return')then
    local crown=id=='fire_blast'or id=='meteor_wide'
    local a,p=construct(id,crown and 4 or(echo and 3 or 2),12)
    local r=math.clamp(radius or 4,1,24)
    run(echo and 1.05 or .7,a,p,function(t)
     local out=1-(1-t)^3;local fade=math.clamp((t-.18)/.82,0,1)
     local center=CFrame.new(point+Vector3.new(0,.2,0))
     if id=='ward_pulse'then center=CFrame.new(point+Vector3.new(0,2,0))end
     for i,v in ipairs(a)do
      local u=math.clamp((t-(i-1)*.08)*1.3,0,1)
      local plane=crown and (CFrame.Angles(0,(i-1)*math.pi/2,0)*CFrame.Angles(math.pi/2,0,0))or(bonus and CFrame.Angles(math.pi/2,0,(i-1)*math.pi/2)or CFrame.Angles(0,i*t,0))
      curve(v,center*plane,r*(.12+.88*(1-(1-u)^3)),crown and -math.pi/2 or 0,crown and math.pi or(bonus and math.pi*1.6 or tau),(bonus and .45 or .3)*(1-u),fade)
     end
     for i,v in ipairs(p)do
      local theta=i*tau/#p
      local y=(id=='fire_blast'or id=='meteor_wide')and math.sin(t*math.pi)*4 or math.sin(t*math.pi)*(i%3)*.65
      local cf=center*CFrame.new(math.cos(theta)*r*out,y,math.sin(theta)*r*out)*CFrame.Angles(.3,theta,bonus and math.pi/4 or t*2)
      if bonus and i<=4 then
       cf=center*CFrame.Angles(0,0,(i-1)*math.pi/2)*CFrame.new(0,2*out,0)
       facet(v,cf,Vector3.new(.14,5*(1-t)+.1,.3),fade)
      elseif id=='frost_wide'or id=='lightning_frozen'then
       cf=center*CFrame.Angles(0,theta,0)*CFrame.new(0,.12,-r*.5*out)
       facet(v,cf,Vector3.new(.08,.22,i%2==0 and r*.85*out+.1 or r*.3*out+.1),fade)
      else facet(v,cf,Vector3.new(.12,(id=='ice_shatter'and 3 or 1.6)*(1-t)+.1,.7*(1-t)+.08),fade)end
     end
    end)
   end
  end
 end
 local function connection(from,to,csv)
  if active>=40 or not visible(to)then return end
  local delta=to-from;if delta.Magnitude<.1 then return end
  local id=ids(csv)[1];if not id then return end
  local a,p=construct(id,2,0)
  run(.38,a,p,function(t)
   -- Two circular ribbons linking the actual server-selected targets.
   local mid=(from+to)/2;local axis=delta.Unit
   local normal=axis:Cross(Vector3.yAxis);if normal.Magnitude<.01 then normal=Vector3.xAxis end
   local cf=CFrame.fromMatrix(mid,axis,normal.Unit)
   for i,v in ipairs(a)do curve(v,cf*CFrame.Angles(0,0,(i-1)*math.pi),delta.Magnitude/2,-math.pi/2,math.pi,.22*(1-t),.25+t*.75)end
  end)
 end
 local function corridor(point,direction,length,width)
  if active>=40 or not visible(point)then return end
  local a,p=construct('iceRush_wide',4,0)
  run(1.3,a,p,function(t)
   for i,v in ipairs(a)do
    local u=math.clamp((t-(i-1)*.1)*1.7,0,1)
    local center=point+direction*(length*i/5)
    curve(v,CFrame.lookAt(center,center+direction)*CFrame.Angles(math.pi/2,0,0),width*(.3+.7*(1-(1-u)^3)),-math.pi/2,math.pi,.28*(1-u),.2+.8*u)
   end
  end)
 end
 local function clear()
  local pending={};for h in pairs(jobs)do table.insert(pending,h)end
  for _,h in ipairs(pending)do h:cancel()end
  if container then container:Destroy();container=nil end
  arcFree={};shardFree={};arcCount=0;shardCount=0
 end
 return {Cast=cast,Impact=impact,Arc=connection,Corridor=corridor,Clear=clear,Stats=function()return {active=active,arcs=arcCount,shards=shardCount,freeArcs=#arcFree,freeShards=#shardFree}end}
end
