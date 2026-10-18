-- Client-only augment silhouettes. BeamArc + Animator from the installed MIT VFX skill.
-- All instances are local, pooled and bounded. No damage, RNG, camera shake or authority here.
local BeamArc=require(script.Parent.vfx.BeamArc)
local Animator=require(script.Parent.vfx.Animator)
local styles=require(script.Parent.AugmentStyles)
local known={};for _,entries in pairs(styles)do for _,v in ipairs(entries)do known[v.id]=true end end
local colors={ice=Color3.fromRGB(130,236,255),lightning=Color3.fromRGB(170,192,255),meteor=Color3.fromRGB(255,142,58),blades=Color3.fromRGB(146,255,215),frost=Color3.fromRGB(177,244,255),ward=Color3.fromRGB(255,222,137),missile=Color3.fromRGB(205,155,255),skyLances=Color3.fromRGB(255,222,148),lightRing=Color3.fromRGB(143,218,255),fire=Color3.fromRGB(255,123,48),thunder=Color3.fromRGB(130,188,255),aether=Color3.fromRGB(211,165,255),iceRush=Color3.fromRGB(134,229,255)}
local tau=math.pi*2
local polished={meteor_wide=true,meteor_echo=true,frost_wide=true,frost_echo=true,ward_pulse=true,fire_blast=true}
local white=Color3.fromRGB(242,255,255)
local warm=Color3.fromRGB(255,237,177)
local function phase(t,start,finish)return math.clamp((t-start)/(finish-start),0,1)end
local function outCubic(t)return 1-(1-t)^3 end
local function ids(csv)
 local result={};for id in string.gmatch(type(csv)=='string'and csv or '','[^,]+')do if known[id]then table.insert(result,id)end end;return result
end
return function(deps)
 local folder=deps.folder
 local container,arcFree,shardFree,particleFree,jobs=nil,{},{},{},{}
 local arcCount,shardCount,particleCount,active=0,0,0,0
 local function ensure()
  if not container or not container.Parent then
   container=Instance.new('Folder');container.Name='AugmentVisuals';container.Parent=folder
   arcFree={};shardFree={};particleFree={};arcCount=0;shardCount=0;particleCount=0
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
 -- 24 holders, each with two disabled emitters. An impact emits 24 particles;
 -- cast emissions are >=.16s apart with <=.46s lifetime (at most nine alive).
 -- One owner keeps the holder until its particles expire; cancellation clears both.
 local function particles(id,casting)
  ensure();local q=table.remove(particleFree)
  if not q then
   if particleCount>=24 then return end
   particleCount+=1
   local holder=Instance.new('Part');holder.Name='AugmentParticles';holder.Size=Vector3.one*.1
   holder.Anchored=true;holder.Transparency=1;holder.CanCollide=false;holder.CanTouch=false;holder.CanQuery=false;holder.CastShadow=false;holder.Parent=container
   local sparks=Instance.new('ParticleEmitter');sparks.Name='Sparks';sparks.Parent=holder
   local haze=Instance.new('ParticleEmitter');haze.Name='Haze';haze.Parent=holder
   q={holder=holder,sparks=sparks,haze=haze}
  end
  local hot=id=='meteor_wide'or id=='meteor_echo'or id=='fire_blast'
  local color=colors[id:match('^([^_]+)')]or colors.aether
  q.holder:SetAttribute('Augment',id);q.holder:SetAttribute('Phase',casting and 'cast'or 'impact')
  for _,em in ipairs({q.sparks,q.haze})do
   em:Clear();em.Enabled=false;em.Rate=0;em.LockedToPart=false;em.VelocityInheritance=0
   em.EmissionDirection=Enum.NormalId.Top;em.SpreadAngle=Vector2.new(casting and 24 or 65,casting and 24 or 65)
   em.Color=ColorSequence.new(hot and warm or white,color);em.LightEmission=hot and .8 or .6;em.LightInfluence=0
   em.Rotation=NumberRange.new(0,360);em.RotSpeed=NumberRange.new(-40,40)
  end
  q.sparks.Texture=hot and 'rbxasset://textures/particles/fire_sparks_main.dds'or 'rbxasset://textures/particles/sparkles_main.dds'
  q.sparks.Lifetime=NumberRange.new(casting and .2 or .35,casting and .38 or .65)
  q.sparks.Speed=NumberRange.new(casting and 2 or 7,casting and 5 or 14);q.sparks.Drag=4
  q.sparks.Acceleration=Vector3.new(0,hot and -9 or 1,0)
  q.sparks.Orientation=Enum.ParticleOrientation.VelocityParallel
  q.sparks.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,casting and .18 or .3),NumberSequenceKeypoint.new(.2,casting and .28 or .5),NumberSequenceKeypoint.new(1,0)})
  q.sparks.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.55,.3),NumberSequenceKeypoint.new(1,1)})
  q.haze.Texture=id=='fire_blast'and 'rbxasset://textures/particles/fire_main.dds'or 'rbxasset://textures/particles/smoke_main.dds'
  q.haze.Lifetime=NumberRange.new(casting and .25 or .4,casting and .46 or .7)
  q.haze.Speed=NumberRange.new(casting and 1 or 2,casting and 3 or 6);q.haze.Drag=3
  q.haze.Acceleration=Vector3.new(0,2,0);q.haze.Orientation=Enum.ParticleOrientation.FacingCamera
  q.haze.Size=NumberSequence.new(casting and .6 or 1.2,casting and 1.5 or 3.5)
  q.haze.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.86),NumberSequenceKeypoint.new(.16,.77),NumberSequenceKeypoint.new(1,1)})
  return q
 end
 local function emit(q,frame,sparks,haze)
  if not q then return end
  q.holder.CFrame=frame -- Emit samples the position immediately.
  q.sparks:Emit(sparks);q.haze:Emit(haze)
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
 local function release(a,p,q)
  for _,v in ipairs(a)do if container and container.Parent and v.holder.Parent==container then v:setEnabled(false);table.insert(arcFree,v)end end
  for _,v in ipairs(p)do if container and container.Parent and v.Parent==container then v.Transparency=1;v.CFrame=CFrame.new(0,-50000,0);table.insert(shardFree,v)end end
  if q and container and container.Parent and q.holder.Parent==container then
   q.sparks:Clear();q.haze:Clear();q.holder.CFrame=CFrame.new(0,-50000,0);table.insert(particleFree,q)
  end
 end
 local function run(seconds,a,p,step,q)
  active+=1;local handle;local ownerContainer=container
  handle=Animator.play(seconds,function(t,dt,age)
   if not folder.Parent or not ownerContainer or not ownerContainer.Parent or container~=ownerContainer then handle:cancel();return end
   if step(t,dt,age)==false then handle:cancel()end
  end,{onComplete=function()release(a,p,q);active-=1;jobs[handle]=nil end})
  jobs[handle]=true;return handle
 end
 local function curve(a,frame,r,start,sweep,width,alpha)
  if not a then return end
  a:setFrame(frame);a:set(r,start,start+sweep,function(u)return width*(.18+.82*math.sin(math.pi*u))end,alpha)
 end
 local function facet(p,frame,size,alpha)
  if not p then return end;p.CFrame=frame;p.Size=size;p.Transparency=math.clamp(alpha,0,1)
 end
 local function stroke(p,from,to,width,alpha)
  local length=(to-from).Magnitude
  if length<.01 then if p then p.Transparency=1 end;return end
  facet(p,CFrame.lookAt((from+to)*.5,to),Vector3.new(width,width,length),alpha)
 end
 local function accents(a,p,id)
  local hot=id=='meteor_wide'or id=='meteor_echo'or id=='fire_blast'
  for i,v in ipairs(a)do if i%2==1 then v:setColor(hot and warm or white)end end
  for i,v in ipairs(p)do if i%3==0 then v.Color=hot and warm or white end end
 end
 local function castOne(anchor,kind,id,role)
  if role=='aura'and kind=='blades'and id~='blades_volley'then return end
  if active>=40 or not visible(anchor.Position)then return end
  local ground=kind=='meteor'or kind=='frost'or kind=='ward'or kind=='skyLances'
  local a,p=construct(id,(kind=='ward'or polished[id])and 3 or 2,polished[id]and 12 or((id=='blades_volley'or id=='skyLances_rain')and 7 or 6))
  local q=polished[id]and id~='ward_pulse'and particles(id,true)or nil
  if polished[id]then accents(a,p,id)end
  local returning=false;local lastEmission=-1
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
    local duration=anchor:GetAttribute('Duration')or 3.2
    local charge=phase(t,0,duration)
    local center=frame*CFrame.new(0,.2,0)
    if id=='meteor_wide'then
     -- Keep the core exactly on AreaArt's diagonal fall and level-dependent size.
     local fall=math.clamp((t-.35)/math.max(duration-.35,.01),0,1)
     local size=10+(anchor:GetAttribute('Level')or 1)*.6
     center=CFrame.new(point+Vector3.new(20*(1-fall),76*(1-fall)^1.3+size*.3,0))
     for i,v in ipairs(a)do
      local orbit=center*CFrame.Angles(.35+i*.3,spin*(i%2==0 and -1 or 1)+(i-1)*tau/3,.18*i)
      curve(v,orbit,size*(.66+i*.055),-.5,math.pi*1.35,.16+.1*charge,.25+(i-1)*.1)
     end
     for i,v in ipairs(p)do
      local ang=i*tau/#p-spin;local reach=size*(.63+(i%2)*.1)
      local cf=center*CFrame.new(math.cos(ang)*reach,(i%3)*.8,math.sin(ang)*reach)*CFrame.Angles(.4,-ang,.25)
      facet(v,cf,Vector3.new(.12,.3+(i%3)*.2,1.6+charge*1.6),.24)
     end
     if t>=lastEmission+.16 then emit(q,center*CFrame.new(0,size*.6,0),2,1);lastEmission=t end
    else
     -- Six broken seams close toward the landing point before the delayed rupture.
     for i,v in ipairs(a)do curve(v,center*CFrame.Angles(0,(i-1)*tau/3-spin*.16,0),radius*(.8-.12*charge),-.72,1.44,.14+.08*charge,.42-.18*charge)end
     for i,v in ipairs(p)do
      local spoke=math.floor((i-1)/2);local ang=spoke*tau/6
      local inner=radius*(i%2==1 and .25 or .47);local outer=radius*(i%2==1 and .5 or .73)
      local base=center.Position;local bend=ang+(i%2==1 and .05 or -.1)
      stroke(v,base+Vector3.new(math.cos(ang)*inner,.02,math.sin(ang)*inner),base+Vector3.new(math.cos(bend)*outer,.02,math.sin(bend)*outer),.08+.06*charge,.55-.25*charge)
     end
     if t>=lastEmission+.16 then local ang=t*2;emit(q,center*CFrame.new(math.cos(ang)*radius*.55,.15,math.sin(ang)*radius*.55),2,0);lastEmission=t end
    end
   elseif id=='frost_wide'or id=='frost_echo' then
    local charge=phase(t,0,anchor:GetAttribute('Duration')or .75)
    local wide=id=='frost_wide';local reach=radius*(wide and(.88-.3*charge)or(.7-.46*charge))
    for i,v in ipairs(a)do
     local plane=frame*CFrame.new(0,wide and .1 or .7+charge*.7,0)*CFrame.Angles(0,(i-1)*tau/3+(wide and spin*.2 or -spin),0)
     curve(v,plane,reach,-.82,1.64,.12+.1*charge,.48-.2*charge)
    end
    for i,v in ipairs(p)do
     local spoke=math.floor((i-1)/2);local ang=spoke*tau/6+(wide and 0 or -spin*.6)
     local cf=frame*CFrame.Angles(0,ang,0)*CFrame.new((i%2==0 and .22 or -.22)*(1-charge*.3),wide and .45 or 1.2+charge*1.4,-reach)
     facet(v,cf*CFrame.Angles(0,0,(i%2==0 and 1 or -1)*.42),Vector3.new(.09,.7+charge*1.5,.7+charge*.7),.38-charge*.18)
    end
    if t>=lastEmission+.16 then
     local ang=t*7;emit(q,frame*CFrame.new(math.cos(ang)*reach,.4,math.sin(ang)*reach),2,0);lastEmission=t
    end
   elseif id=='ward_pulse' then
    -- Open arches above six paired rune panels; leave the protected player readable.
    for i,v in ipairs(a)do
     local cf=frame*CFrame.new(0,2.4,0)*CFrame.Angles(0,(i-1)*tau/3+spin*.18,0)*CFrame.Angles(math.pi/2,0,0)
     curve(v,cf,4.6,-.74,1.48,.12,.48)
    end
    for i,v in ipairs(p)do
     local ang=math.floor((i-1)/2)*tau/6-spin*.2;local side=i%2==0 and 1 or -1
     local cf=frame*CFrame.Angles(0,ang,0)*CFrame.new(side*.22,3.1+math.sin(t*1.3+ang)*.2,-4.6)*CFrame.Angles(0,0,side*.55)
     facet(v,cf,Vector3.new(.1,1.05,.7),.25)
    end
   elseif id=='fire_blast' then
    -- Tapered corkscrew wake, aligned with the actual projectile frame (+Z trails).
    for i,v in ipairs(a)do
     local cf=frame*CFrame.new(0,0,.6+i*.9)*CFrame.Angles(math.pi/2,0,spin*3+(i-1)*tau/3)
     curve(v,cf,1.8-i*.28,-.4,math.pi*1.2,.32-i*.06,.16+i*.13)
    end
    for i,v in ipairs(p)do
     local ang=math.floor((i-1)/2)*tau/6+spin*2;local rear=i%2==0
     facet(v,frame*CFrame.new(math.cos(ang)*(rear and .85 or 1.3),math.sin(ang)*(rear and .85 or 1.3),rear and 3 or 1.1)*CFrame.Angles(0,0,ang),Vector3.new(.1,rear and .3 or .6,rear and 2.8 or 1.5),rear and .5 or .18)
    end
    if t>=lastEmission+.16 then
     local tail=frame:PointToWorldSpace(Vector3.new(0,0,2.5))
     emit(q,CFrame.lookAt(tail,tail+frame.ZVector)*CFrame.Angles(-math.pi/2,0,0),2,1);lastEmission=t
    end
   elseif id=='missile_hunter'or id=='blades_pierce'or id=='ice_shatter' then
    for i,v in ipairs(a)do curve(v,frame*CFrame.new(0,0,i*.8)*CFrame.Angles(math.pi/2,spin,0),id=='ice_shatter'and 1.6 or .65,0,math.pi*1.5,.09,.3)end
    for i,v in ipairs(p)do
     local theta=i*tau/#p+(id=='ice_shatter'and spin or 0)
     local reach=id=='ice_shatter'and 1.6 or .55
     facet(v,frame*CFrame.new(math.cos(theta)*reach,math.sin(theta)*reach,-.5)*CFrame.Angles(0,0,theta),Vector3.new(.12,id=='ice_shatter'and 1.1 or .5,id=='blades_pierce'and 3.8 or 1.8),.12)
    end
   else
    local scale=id=='iceRush_wide'and 3.6 or 1
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
  end,q)
 end
 local function cast(anchor,kind,role)
  if type(anchor)=='string'then local world=workspace:FindFirstChild('SummonerRuntime');anchor=world and world:FindFirstChild(anchor)end
  if not anchor or not anchor.Parent then return end
  for _,id in ipairs(ids(anchor:GetAttribute('VFXAugments')))do castOne(anchor,kind,id,role)end
 end
 local function polishedImpact(point,radius,id)
  local r=math.clamp(radius or 4,1,24)
  local a,p=construct(id,3,id=='frost_wide'and 18 or 12)
  local q=particles(id,false);accents(a,p,id)
  local duration=id=='ward_pulse'and 1.15 or 1.3
  local emitted=false
  run(duration,a,p,function(_,_,age)
   local out=outCubic(phase(age,0,.48));local fade=phase(age,.38,duration)
   local center=CFrame.new(point+Vector3.new(0,.3,0))
   if not emitted then
    -- Six local bursts give the rim some texture without covering the whole area.
    for i=1,6 do local angle=i*tau/6;emit(q,center*CFrame.new(math.cos(angle)*r*.35,.3,math.sin(angle)*r*.35),3,1)end
    emitted=true
   end
   if id=='meteor_wide'then
    for i,v in ipairs(a)do
     local u=phase(age,(i-1)*.065,.6+(i-1)*.065)
     local cf=center*CFrame.new(0,.15+i*.08,0)*CFrame.Angles(0,(i-1)*tau/3,0)*CFrame.Angles(.16,0,.1)
     curve(v,cf,r*(.18+.82*outCubic(u)),-.9,1.8,.62*(1-u)+.04,math.max(fade,u*.8))
    end
    for i,v in ipairs(p)do
     local ang=i*tau/#p;local travel=r*(.17+.75*out);local height=math.max(0,(5+i%3*1.4)*math.sin(math.min(age/.95,1)*math.pi))
     local cf=center*CFrame.new(math.cos(ang)*travel,height,math.sin(ang)*travel)*CFrame.Angles(age*3,ang,age*1.6)
     facet(v,cf,Vector3.new(.14,1.8*(1-fade)+.15,.7*(1-fade)+.12),.18+.82*fade)
    end
   elseif id=='meteor_echo'then
    for i,v in ipairs(a)do
     local u=phase(age,(i-1)*.06,.65+(i-1)*.06)
     local cf=center*CFrame.Angles(0,(i-1)*tau/3,0)*CFrame.new(0,.2,0)*CFrame.Angles(.5,0,0)
     curve(v,cf,r*(.25+.68*outCubic(u)),-.65,1.3,.5*(1-u),.2+.8*math.max(fade,u*.7))
    end
    for i,v in ipairs(p)do
     local ang=math.floor((i-1)/2)*tau/6;local odd=i%2==1
     local base=center.Position;local inner=r*(odd and .08 or .4)*out;local outer=r*(odd and .43 or .82)*out
     stroke(v,base+Vector3.new(math.cos(ang)*inner,.03,math.sin(ang)*inner),base+Vector3.new(math.cos(ang+(odd and .08 or -.1))*outer,.03,math.sin(ang+(odd and .08 or -.1))*outer),(.26-.2*fade)*(odd and 1 or .7),.18+.82*fade)
    end
   elseif id=='frost_wide'then
    for i,v in ipairs(a)do
     local u=phase(age,(i-1)*.05,.55+(i-1)*.05)
     curve(v,center*CFrame.Angles(0,(i-1)*tau/3,0),r*(.25+.7*outCubic(u)),-.7,1.4,.18*(1-u)+.025,.35+.65*fade)
    end
    -- A six-arm, forked snowflake grows outward in a readable low plane.
    for i,v in ipairs(p)do
     local spoke=math.floor((i-1)/3);local branch=(i-1)%3;local ang=spoke*tau/6
     local radial=Vector3.new(math.cos(ang),0,math.sin(ang));local base=center.Position
     local from=base+radial*r*(branch==0 and .05 or .51)*out
     local to
     if branch==0 then to=base+radial*r*.93*out
     else local theta=ang+(branch==1 and 1 or -1)*math.pi/3;to=from+Vector3.new(math.cos(theta),0,math.sin(theta))*r*.28*out end
     stroke(v,from,to,(branch==0 and .18 or .12)*(1-fade)+.025,.23+.77*fade)
    end
   elseif id=='frost_echo'then
    local unfurl=outCubic(phase(age,0,.32))
    for i,v in ipairs(a)do
     local cf=center*CFrame.new(0,.5+unfurl*.8,0)*CFrame.Angles(0,(i-1)*tau/3-age*2,0)*CFrame.Angles(.22,0,0)
     curve(v,cf,r*(.2+.64*out),-.8,1.6,.22*(1-fade),.25+.75*fade)
    end
    for i,v in ipairs(p)do
     local ang=math.floor((i-1)/2)*tau/6-age*.45;local side=i%2==0 and 1 or -1
     local reach=r*(.28+.4*unfurl);local height=(1.2+(i%3)*.6)*math.sin(math.min(age,1)*math.pi)
     local cf=center*CFrame.Angles(0,ang,0)*CFrame.new(side*(.15+.5*unfurl),.4+height,-reach)*CFrame.Angles(side*.2,0,side*(.18+.8*unfurl))
     facet(v,cf,Vector3.new(.1,(1.1+r*.12)*(1-fade)+.1,.75*(1-fade)+.1),.2+.8*fade)
    end
   elseif id=='ward_pulse'then
    local open=outCubic(phase(age,0,.45));local split=phase(age,.16,.65)
    for i,v in ipairs(a)do
     local cf=center*CFrame.new(0,2.3*(1-open),0)*CFrame.Angles(0,(i-1)*tau/3,0)*CFrame.Angles(math.pi/2*(1-open),0,0)
     curve(v,cf,3.8+(r-3.8)*open,-.78,1.56,.25*(1-fade),.3+.7*fade)
    end
    for i,v in ipairs(p)do
     local ang=math.floor((i-1)/2)*tau/6;local side=i%2==0 and 1 or -1
     local cf=center*CFrame.Angles(0,ang,0)*CFrame.new(side*(.25+split*.65),2.4+math.sin(open*math.pi)*.8,-r*(.35+.6*open))*CFrame.Angles(0,side*split*.8,side*(.5+split))
     facet(v,cf,Vector3.new(.12,1.6*(1-fade)+.1,.95*(1-fade)+.1),.18+.82*fade)
    end
   elseif id=='fire_blast'then
    for i,v in ipairs(a)do
     local u=phase(age,(i-1)*.06,.48+(i-1)*.06)
     local cf=center*CFrame.new(0,.4+(1-u)*i*.25,0)*CFrame.Angles(.14,age*1.8+(i-1)*tau/3,.12)
     curve(v,cf,r*(.16+.8*outCubic(u)),-.95,1.9,.55*(1-u)+.025,.18+.82*math.max(fade,u*.65))
    end
    for i,v in ipairs(p)do
     local ang=math.floor((i-1)/2)*tau/6+age*.35;local tip=i%2==0
     local rise=math.sin(math.min(age/.75,1)*math.pi);local reach=r*(.16+.55*out)+(tip and .5 or 0)
     local cf=center*CFrame.new(math.cos(ang)*reach,.5+rise*(tip and 4.2 or 2.4),math.sin(ang)*reach)*CFrame.Angles(.25,-ang,.2+age*1.3)
     facet(v,cf,Vector3.new(.14,(tip and 1.5 or 2.7)*(1-fade)+.08,.65*(1-fade)+.1),.2+.8*fade)
    end
   end
  end,q)
 end
 local function impact(point,radius,meta)
  if type(meta)~='table'or active>=40 or not visible(point)then return end
  for _,id in ipairs(ids(meta.ids))do
   if active>=40 then break end
   local bonus=id=='missile_hunter'or id=='skyLances_execute'or id=='aether_execute'or id=='lightning_frozen'
   local echo=id=='meteor_echo'or id=='frost_echo'
   if (not bonus or meta.empowered)and(not echo or meta.phase=='echo')and(id~='lightRing_return'or meta.phase=='return')then
    if polished[id]then polishedImpact(point,radius,id);continue end
    local a,p=construct(id,2,12)
    local r=math.clamp(radius or 4,1,24)
    run(.7,a,p,function(t)
     local out=1-(1-t)^3;local fade=math.clamp((t-.18)/.82,0,1)
     local center=CFrame.new(point+Vector3.new(0,.2,0))
     for i,v in ipairs(a)do
      local u=math.clamp((t-(i-1)*.08)*1.3,0,1)
      local plane=bonus and CFrame.Angles(math.pi/2,0,(i-1)*math.pi/2)or CFrame.Angles(0,i*t,0)
      curve(v,center*plane,r*(.12+.88*(1-(1-u)^3)),0,bonus and math.pi*1.6 or tau,(bonus and .45 or .3)*(1-u),fade)
     end
     for i,v in ipairs(p)do
      local theta=i*tau/#p
      local y=math.sin(t*math.pi)*(i%3)*.65
      local cf=center*CFrame.new(math.cos(theta)*r*out,y,math.sin(theta)*r*out)*CFrame.Angles(.3,theta,bonus and math.pi/4 or t*2)
      if bonus and i<=4 then
       cf=center*CFrame.Angles(0,0,(i-1)*math.pi/2)*CFrame.new(0,2*out,0)
       facet(v,cf,Vector3.new(.14,5*(1-t)+.1,.3),fade)
      elseif id=='lightning_frozen'then
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
  arcFree={};shardFree={};particleFree={};arcCount=0;shardCount=0;particleCount=0
 end
 return {Cast=cast,Impact=impact,Arc=connection,Corridor=corridor,Clear=clear,Stats=function()return {active=active,arcs=arcCount,shards=shardCount,freeArcs=#arcFree,freeShards=#shardFree,particles=particleCount,freeParticles=#particleFree}end}
end
