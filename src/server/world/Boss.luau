-- Server-owned dragon choreography. Every large hit has a locked ground warning.
return function(deps)
 local applyDamage=require(script.Parent.Parent.shared.PlayerDamage)
 local world,enemies,states,clock=deps.world,deps.enemies,deps.states,deps.clock
 local rootOf,effect,factory=deps.rootOf,deps.effect,deps.modelFactory
 local boss,rig,action=nil,nil,nil
 local t,cooldown,pattern=0,1,0
 local tailReadyAt=0
 local order={'breath','airBreath','dive','eruption','flameCross','airCross','airRing'}
 local markers=Instance.new('Folder');markers.Name='BossTelegraphs';markers.Parent=world
 local red=Color3.fromRGB(255,91,61)
 local function flat(v)return Vector3.new(v.X,0,v.Z)end
 local function directionTo(a,b)local d=flat(b-a);return d.Magnitude>.01 and d.Unit or Vector3.new(0,0,1)end
 local function bounded(p)local f=flat(p);if f.Magnitude>68 then f=f.Unit*68 end;return Vector3.new(f.X,3,f.Z)end
 local function clear()markers:ClearAllChildren()end
 local function part(name,size,cf,alpha,class,parent)
  local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=red;p.Transparency=alpha or .4;p.CastShadow=false;p.Parent=parent or markers;return p
 end
 local function disc(pos,radius,name)
  name=name or 'EruptionWarning'
  local p=part(name,Vector3.new(.07,radius*2,radius*2),CFrame.new(pos.X,.14,pos.Z)*CFrame.Angles(0,0,math.pi/2),.85);p.Shape=Enum.PartType.Cylinder
  if name=='LandingWarning'then p.Color=Color3.fromRGB(255,191,72)end
  for i=1,32 do local a=i*math.pi/16;local edge=part(name..'Edge',Vector3.new(radius*.18,.07,.16),CFrame.new(pos.X,.2,pos.Z)*CFrame.Angles(0,a,0)*CFrame.new(0,0,-radius),.12);edge.Color=p.Color end
 end
 local function line(center,direction,length,halfWidth,delay)
  local folder=Instance.new('Folder');folder.Name='FireLineWarning';folder.Parent=markers
  local from=center-direction*length/2;local finish=center+direction*length/2
  local cf=CFrame.lookAt(Vector3.new(center.X,.16,center.Z),Vector3.new(center.X,.16,center.Z)+direction)
  part('FireLane',Vector3.new(halfWidth*2,.06,length),cf,.85,nil,folder)
  for _,side in ipairs({-1,1})do part('LaneEdge',Vector3.new(.15,.08,length),cf*CFrame.new(side*halfWidth,.06,0),.1,nil,folder)end
  return {from=from,finish=finish,direction=direction,length=length,halfWidth=halfWidth,at=delay,warning=folder}
 end
 local function insideLine(p,l)
  local d=flat(p-(l.from+l.finish)/2)
  return math.abs(d:Dot(l.direction))<=l.length/2 and math.abs(d:Dot(l.direction:Cross(Vector3.yAxis)))<=l.halfWidth
 end
 local function segmentDistance(p,a,b)
  local ab=flat(b-a);local ap=flat(p-a);local alpha=ab:Dot(ab)>.001 and math.clamp(ap:Dot(ab)/ab:Dot(ab),0,1) or 0;return (ap-ab*alpha).Magnitude
 end
 local function hit(predicate,amount,record)
  for _,s in pairs(states)do local r,h=rootOf(s);if r and not s.offers and(s.invulnerable or 0)<=0 and not record[s]and predicate(r.Position)then record[s]=true;applyDamage(s,h,amount,deps.effect)end end
 end
 local function fireLines(a)
  for _,l in ipairs(a.lines)do
   if a.time>=l.at and not l.fired then
    l.fired=true;if l.warning.Parent then l.warning:Destroy()end
    effect:FireAllClients('dragonFireLine',l.from,l.finish,{halfWidth=l.halfWidth,model=boss.model,duration=.5})
    hit(function(p)return insideLine(p,l)end,22,a.hit)
   end
  end
 end
 local function frame()return CFrame.lookAt(flat(boss.pos),flat(boss.pos)+boss.heading)end
 local function spawn()
  if boss then return end
  for _,e in ipairs(enemies)do if e.hp>0 and not e.isBoss then deps.drop(e.pos);e.hp=0;e.model:Destroy()end end
  if deps.clearEnemyShots then deps.clearEnemyShots()end
  local count,testMode=0,false;for _,s in pairs(states)do if rootOf(s)then count+=1;if s.bossTest then testMode=true end end end
  rig=factory.create(world,CFrame.new(0,0,-34));rig.model.Name='EmberDragon'
  local hp=2880*(testMode and 2 or 1)*(1+.7*math.max(0,count-1))
  boss={name='흑염룡 · 아그니스',model=rig.model,pos=Vector3.new(0,3,-34),hp=hp,maxHp=hp,isBoss=true,slow=0,frozen=0,speed=16,heading=Vector3.new(0,0,1),phase=1,altitude=0}
  boss.model:SetAttribute('HP',hp);boss.model:SetAttribute('MaxHP',hp);boss.model:SetAttribute('BossTest',testMode)
  table.insert(enemies,boss);clock.boss=boss;clock.phase='boss';clock.bossElapsed=0;t,cooldown,pattern=0,1,0
  effect:FireAllClients('dragonArrival',boss.pos,16)
 end
 local function fanWarning(a)
  local function triangle(x,y,z)
   local ab,ac,bc=y-x,z-x,z-y
   if ab.Magnitude>ac.Magnitude and ab.Magnitude>bc.Magnitude then z,x=x,z elseif ac.Magnitude>bc.Magnitude then x,y=y,x end
   ab,ac,bc=y-x,z-x,z-y
   local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit;local height=math.abs(ab:Dot(up))
   part('BreathWarning',Vector3.new(.045,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((x+y)/2,right,up,back),.86,'WedgePart')
   part('BreathWarning',Vector3.new(.045,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((x+z)/2,-right,up,-back),.86,'WedgePart')
  end
  local center=Vector3.new(a.mouth.X,.15,a.mouth.Z)
  for i=0,11 do
   local x=math.rad(-a.angle+i*a.angle*2/12);local y=math.rad(-a.angle+(i+1)*a.angle*2/12)
   triangle(center,center+CFrame.Angles(0,x,0):VectorToWorldSpace(a.direction)*a.range,center+CFrame.Angles(0,y,0):VectorToWorldSpace(a.direction)*a.range)
  end
  for _,angle in ipairs({-a.angle,a.angle})do local d=CFrame.Angles(0,math.rad(angle),0):VectorToWorldSpace(a.direction);part('BreathEdge',Vector3.new(.16,.08,a.range),CFrame.lookAt(center+d*a.range/2,center+d*(a.range/2+1)),.1)end
 end
 local function rearTarget(target)
  local offset=flat(target-boss.pos);local distance=offset.Magnitude
  return t>=tailReadyAt and distance>1 and distance<=30 and boss.heading:Dot(offset.Unit)<-.35
 end
 local function begin(target)
  clear()
  local kind
  if rearTarget(target)then kind='tail';tailReadyAt=t+8
  else pattern=pattern%#order+1;kind=order[pattern];boss.heading=directionTo(boss.pos,target)end
  action={kind=kind,time=0,hit={},origin=flat(boss.pos),direction=boss.heading,phase=boss.phase}
  local a=action;local right=a.direction:Cross(Vector3.yAxis)
  if kind=='eruption'then
   a.windup=1.05;a.total=1.6;a.radius=boss.phase==2 and 14 or 12;a.points={}
   for _,offset in ipairs(boss.phase==2 and {-36,-18,0,18,36}or{-18,0,18})do local p=bounded(target+right*offset);table.insert(a.points,p);disc(p,a.radius)end
  elseif kind=='breath'then
   a.windup=.95;a.total=2.05;a.range=55;a.angle=boss.phase==2 and 50 or 45;a.mouth=frame():PointToWorldSpace(Vector3.new(0,19.2,-10.2));fanWarning(a)
  elseif kind=='flameCross'then
   a.windup=1;a.total=2.05
   a.lines={line(target,a.direction,72,9,a.windup),line(target,right,72,9,a.windup+.5)}
  elseif kind=='airBreath'or kind=='airCross'or kind=='airRing'then
   a.air=true;a.windup=1;a.sweepDuration=1.4;a.landStart=a.windup+a.sweepDuration;a.landAt=a.landStart+.7;a.total=a.landAt+.3
   a.finish=bounded(target-a.direction*8);a.slamRadius=boss.phase==2 and 22 or 18;a.slamHit={};a.points={}
   if kind=='airCross'then
    a.lines={line(target,a.direction,76,10,a.windup),line(target,right,76,10,a.windup+.6)}
   elseif kind=='airRing'then
    a.radius=boss.phase==2 and 11 or 10
    for i=0,7 do local angle=i*math.pi/4;local p=bounded(target+Vector3.new(math.cos(angle)*25,0,math.sin(angle)*25));table.insert(a.points,p);disc(p,a.radius)end
    table.insert(a.points,a.points[1]) -- Close the visible breath loop; damage each patch once.
   else
    a.radius=boss.phase==2 and 11 or 10
    for i=1,7 do local p=bounded(target+right*(i-4)*9);table.insert(a.points,p);disc(p,a.radius)end
   end
  elseif kind=='tail'then
   a.windup=1;a.spinDuration=1.35;a.total=2.55;a.radius=boss.phase==2 and 24 or 22
   a.finish=a.origin
   local turnDirection=directionTo(boss.pos,target)
   a.turnAngle=math.atan2(a.direction:Cross(turnDirection).Y,a.direction:Dot(turnDirection))
   a.coilAngle=-(a.turnAngle>=0 and 1 or -1)*math.rad(18)
   disc(a.finish,a.radius,'TailWarning')
  else
   a.windup=.9;a.travelDuration=.55;a.total=1.8;a.halfWidth=11;a.radius=16;a.finish=flat(bounded(boss.pos+a.direction*46))
   local length=flat(a.finish-a.origin).Magnitude
   part('DiveWarning',Vector3.new(a.halfWidth*2,.06,math.max(1,length)),CFrame.lookAt(a.origin+a.direction*length*.5+Vector3.new(0,.15,0),a.origin+a.direction*(length*.5+1)+Vector3.new(0,.15,0)),.8)
   disc(a.finish,a.radius,'LandingWarning')
  end
  if kind=='breath'or kind=='flameCross'or a.air then effect:FireAllClients('dragonCharge',boss.model,a.windup)end
  boss.model:SetAttribute('Attack',kind)
 end
 local function stepAir(a)
  local travel=math.clamp(a.time/a.landStart,0,1);travel=travel*travel*(3-2*travel)
  boss.pos=a.origin:Lerp(flat(a.finish),travel)
  local pose='fly'
  if a.time<a.windup then boss.altitude=24*math.sin(a.time/a.windup*math.pi/2)
  elseif a.time<a.landStart then
   boss.altitude=24;pose='airBreath'
   if a.lines then fireLines(a)
   else
    if not a.started then a.started=true;clear();effect:FireAllClients('dragonAirBreath',boss.model,a.points,a.sweepDuration)end
    local count=a.kind=='airRing'and #a.points-1 or #a.points
    local index=math.clamp(math.floor((a.time-a.windup)/a.sweepDuration*count)+1,1,count)
    for i=1,index do if not a['patch'..i]then
     a['patch'..i]=true;local p=a.points[i];effect:FireAllClients('dragonEruption',p,a.radius)
     hit(function(pos)return flat(pos-p).Magnitude<=a.radius end,20,a.hit)
    end end
   end
  else
   local fall=math.clamp((a.time-a.landStart)/(a.landAt-a.landStart),0,1)
   boss.altitude=24*(1-fall*fall)
  end
  if a.time>=a.landStart-.25 and not a.warned then a.warned=true;disc(a.finish,a.slamRadius,'LandingWarning')end
  if a.time>=a.landAt then
   boss.altitude=0;pose='land'
   if not a.landed then
    a.landed=true;clear();effect:FireAllClients('dragonSlam',a.finish,a.slamRadius)
    hit(function(p)return flat(p-a.finish).Magnitude<=a.slamRadius end,26,a.slamHit)
   end
  end
  return pose
 end
 local function step(dt)
  if clock.phase=='survival'then if clock.elapsed>=clock.roundLength then spawn()end;return end
  if clock.phase~='boss'or not boss or boss.hp<=0 then return end
  clock.bossElapsed+=dt;t+=dt;boss.phase=boss.hp<=boss.maxHp*.5 and 2 or 1
  boss.slow=math.max(0,boss.slow-dt);boss.frozen=0;boss.knockTime=0;boss.model:SetAttribute('Frozen',false)
  local target,best=nil,math.huge
  for _,s in pairs(states)do local r=rootOf(s);if r then local d=flat(r.Position-boss.pos).Magnitude;if d<best then best=d;target=r.Position end end end
  if not target then return end
  local pose,progress=nil,0;boss.altitude=0
  if action then
   local a=action;a.time+=dt;pose=a.kind;progress=a.time/a.total
   if a.air then
    pose=stepAir(a)
    if pose=='land'then progress=math.clamp((a.time-a.landAt)/(a.total-a.landAt),0,1)end
   elseif a.kind=='flameCross'then pose='breath';fireLines(a)
   elseif a.kind=='eruption'then
    if a.time>=a.windup and not a.impacted then
     a.impacted=true;clear();for _,p in ipairs(a.points)do effect:FireAllClients('dragonEruption',p,a.radius)end
     hit(function(pos)for _,p in ipairs(a.points)do if flat(pos-p).Magnitude<=a.radius then return true end end;return false end,22,a.hit)
    end
   elseif a.kind=='breath'then
    if a.time>=a.windup and not a.impacted then
     a.impacted=true;clear();effect:FireAllClients('dragonBreath',a.mouth,a.direction,{range=a.range,angle=a.angle,model=boss.model})
     hit(function(p)local d=flat(p-a.mouth);return d.Magnitude<=a.range and(d.Magnitude<.1 or d.Unit:Dot(a.direction)>=math.cos(math.rad(a.angle)))end,17,a.hit)
    end
   elseif a.kind=='tail'then
    local move=math.clamp(a.time/a.windup,0,1);boss.pos=a.origin:Lerp(a.finish,move*move*(3-2*move))
    local coil=math.clamp((a.time-.5)/(a.windup-.5),0,1)
    if a.time<a.windup then
     pose='tailWindup';progress=coil
     boss.heading=CFrame.Angles(0,a.coilAngle*coil*coil*(3-2*coil),0):VectorToWorldSpace(a.direction)
    end
    if a.time>=a.windup then
     local spin=math.clamp((a.time-a.windup)/a.spinDuration,0,1)
     local eased=spin*spin*spin*(spin*(spin*6-15)+10)
     progress=spin
     boss.heading=CFrame.Angles(0,a.coilAngle+(a.turnAngle-a.coilAngle)*eased,0):VectorToWorldSpace(a.direction)
     if not a.started then a.started=true;clear();effect:FireAllClients('dragonTailSpin',boss.model,a.radius,a.spinDuration)end
     if spin>=.12 and spin<=.85 then
      hit(function(p)local offset=flat(p-a.finish);return offset.Magnitude<=a.radius and(offset.Magnitude<1 or offset.Unit:Dot(-boss.heading)>=math.cos(math.rad(70)))end,20,a.hit)
     end
    end
   else
    if a.time<a.windup then boss.altitude=12*math.sin(a.time/a.windup*math.pi/2);pose='fly'
    elseif not a.done then
     if not a.started then a.started=true;clear();effect:FireAllClients('dragonDive',boss.model,a.travelDuration)end
     local previous=boss.pos;local alpha=math.clamp((a.time-a.windup)/a.travelDuration,0,1);boss.pos=a.origin:Lerp(a.finish,alpha);boss.altitude=12*(1-alpha)+math.sin(alpha*math.pi)*12
     if boss.altitude<10 then hit(function(p)return segmentDistance(p,previous,boss.pos)<=a.halfWidth end,20,a.hit)end
     if alpha>=1 then a.done=true;effect:FireAllClients('dragonSlam',a.finish,a.radius);hit(function(p)return flat(p-a.finish).Magnitude<=a.radius end,20,a.hit)end
    else pose='land'end
    if pose=='land'then progress=math.clamp((a.time-a.windup-a.travelDuration)/(a.total-a.windup-a.travelDuration),0,1)end
   end
   if a.time>=a.total then action=nil;cooldown=boss.phase==2 and .5 or .7;clear();boss.model:SetAttribute('Attack','Recover')end
  else
   cooldown-=dt
   -- Long-range attacks engage immediately; no chase-until-38-studs gate.
   if cooldown<=0 then begin(target)
   elseif best>15 and t>1 and not rearTarget(target)then
    pose='walk';local desired=directionTo(boss.pos,target);local alpha=1-math.exp(-dt*8)
    boss.heading=CFrame.lookAt(Vector3.zero,boss.heading):Lerp(CFrame.lookAt(Vector3.zero,desired),alpha).LookVector
    boss.pos=bounded(boss.pos+boss.heading*math.min(best-15,boss.speed*(boss.slow>0 and .8 or 1)*dt))
   end
  end
  boss.airborne=boss.altitude>8;boss.pos=Vector3.new(boss.pos.X,3+boss.altitude,boss.pos.Z)
  if t<1 and not action then pose='roar';progress=t end
  rig.origin=frame()*CFrame.new(0,boss.altitude,0);factory.pose(rig,t,pose,math.clamp(progress,0,1),boss.phase)
 end
 local function resolve()
  if clock.phase~='boss'or not boss then return end
  if boss.hp<=0 then
   clock.phase='victory';clear();effect:FireAllClients('dragonArrival',boss.pos,18)
   if boss.model.Parent then boss.model:Destroy()end
   for _,s in pairs(states)do if not s.over then deps.endPlayer(s,'victory')end end
  end
 end
 local function reset()
  if boss and boss.model.Parent then boss.model:Destroy()end
  boss,rig,action=nil,nil,nil;clock.boss=nil;clock.bossElapsed=0;clock.phase='survival';t,cooldown,pattern=0,1,0;tailReadyAt=0
  if not markers.Parent then markers=Instance.new('Folder');markers.Name='BossTelegraphs';markers.Parent=world else clear()end
 end
 return {Step=step,Resolve=resolve,Reset=reset}
end
