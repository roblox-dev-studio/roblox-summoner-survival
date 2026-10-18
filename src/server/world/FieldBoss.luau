-- Mounted miniboss. Server owns locked telegraphs, swept hits, reward and retreat.
return function(deps)
 local damage=require(script.Parent.Parent.shared.PlayerDamage)
 local world,enemies,states,clock=deps.world,deps.enemies,deps.states,deps.clock
 local boss,markers;local spawned=false
 local SOLO_HEALTH=1560
 local function flat(v)return Vector3.new(v.X,0,v.Z)end
 local function bound(v)local f=flat(v);if f.Magnitude>77 then f=f.Unit*77 end;return f+Vector3.new(0,3,0)end
 local function emit(kind,pos,dir)if deps.effect then deps.effect:FireAllClients('fieldBoss',kind,pos,dir)end end
 local function clearMarkers()if markers then markers:Destroy();markers=nil end end
 local function remove()
  clearMarkers()
  if boss then for i=#enemies,1,-1 do if enemies[i]==boss then table.remove(enemies,i)end end;boss.model:Destroy()end
  boss=nil;clock.fieldBoss=nil
 end
 local function resolve()
  if not boss or boss.hp>0 then return end
  emit('defeat',boss.pos,boss.direction)
  remove()
  for _,s in pairs(states)do if deps.rootOf(s)and not s.bossTest then deps.reward(s)end end
 end
 local function nearest(pos)
  local best,dist
  for _,s in pairs(states)do local root=deps.rootOf(s);if root then local d=flat(root.Position-pos).Magnitude;if not dist or d<dist then best,dist=root,d end end end
  return best,dist
 end
 local function part(name,size,cf,alpha)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=Color3.fromRGB(255,148,68);p.Material=Enum.Material.Neon;p.Transparency=alpha or .76;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=markers;return p
 end
 local function warning(kind)
  clearMarkers();markers=Instance.new('Folder');markers.Name='FieldBossTelegraphs';markers.Parent=world
  local origin=Vector3.new(boss.pos.X,.19,boss.pos.Z);local frame=CFrame.lookAt(origin,origin+boss.direction)
  if kind=='cleaveWindup'then
   for i=0,20 do local a=math.rad(-75+i*7.5);local ray=frame*CFrame.Angles(0,a,0)
    part('CleaveSector',Vector3.new(.45,.045,14),ray*CFrame.new(0,0,-7),.82)
    part('CleaveEdge',Vector3.new(1.8,.06,.17),ray*CFrame.new(0,0,-14),.25)
   end
  else
   part('ChargeLane',Vector3.new(7,.05,boss.chargeLength+6),frame*CFrame.new(0,0,-(boss.chargeLength/2+2)),.78)
   for _,x in ipairs({-3.5,3.5})do part('ChargeEdge',Vector3.new(.12,.07,boss.chargeLength+6),frame*CFrame.new(x,0,-(boss.chargeLength/2+2)),.3)end
  end
 end
 local durations={arrival=1.05,approach=1,cleaveWindup=.75,cleave=.4,chargeWindup=.8,charge=.5,recover=.8,retreat=1}
 local function action(name)
  boss.action=name;boss.actionTime=0;boss.hits={};boss.model:SetAttribute('FieldAction',name);boss.model:SetAttribute('FieldProgress',0)
  if name=='cleaveWindup'or name=='chargeWindup'then warning(name)
  elseif name=='cleave'or name=='charge'then clearMarkers();emit(name,boss.pos,boss.direction)
  elseif name=='retreat'then clearMarkers();emit('retreat',boss.pos,boss.direction)end
 end
 local function hitPlayers(previous,current,cleave)
  for _,s in pairs(states)do local root,h=deps.rootOf(s)
   if root and h and not boss.hits[s]and not s.offers and(s.invulnerable or 0)<=0 and math.abs(root.Position.Y-boss.pos.Y)<8 then
    local point=flat(root.Position);local caught=false
    if cleave then
     local delta=point-flat(boss.pos);caught=delta.Magnitude<=14 and(delta.Magnitude<.01 or delta.Unit:Dot(boss.direction)>=math.cos(math.rad(75)))
    else
     local a=flat(previous)-boss.direction*1;local b=flat(current)+boss.direction*5;local delta=b-a
     local along=(point-a):Dot(delta)/math.max(.001,delta:Dot(delta))
     caught=along>=0 and along<=1 and(point-(a+delta*along)).Magnitude<=3.5
    end
    if caught then boss.hits[s]=true;damage(s,h,cleave and 18 or 21,deps.effect)end
   end
  end
 end
 local function spawn()
  spawned=true
  local root=nearest(Vector3.zero);if not root then return end
  local origin=flat(root.Position);local outward=origin.Magnitude>5 and origin.Unit or Vector3.new(0,0,-1)
  local pos=bound(origin+outward*32);if flat(pos-origin).Magnitude<24 then pos=bound(origin-outward*32)end
  local count=0;for _,s in pairs(states)do if deps.rootOf(s)then count+=1 end end
  local hp=math.floor(SOLO_HEALTH*(1+math.max(0,count-1)*.65))
  local model=deps.creature('SkeletonCommander',Color3.new(),false,'commander')
  local dir=flat(root.Position-pos);dir=dir.Magnitude>.01 and dir.Unit or Vector3.new(0,0,-1)
  boss={model=model,pos=pos,hp=hp,maxHp=hp,kind='commander',name='망령 기마 군단장',isFieldBoss=true,slow=0,frozen=0,direction=dir,nextCharge=false,participants=count}
  clock.fieldBoss=boss;table.insert(enemies,boss)
  model:SetAttribute('IsFieldBoss',true);model:SetAttribute('HP',hp);model:SetAttribute('MaxHP',hp);model:PivotTo(CFrame.lookAt(pos,pos+dir))
  action('arrival');emit('arrival',pos,dir)
 end
 local function step(dt)
  resolve()
  local skip=clock.phase~='survival'or clock.elapsed>=clock.roundLength
  for _,s in pairs(states)do if s.bossTest and deps.rootOf(s)then skip=true end end
  if skip then if boss then remove()end;return end
  if not spawned and clock.elapsed>=(deps.spawnAt or 60)and clock.elapsed<math.min(105,clock.roundLength-10)then spawn()end
  if not boss then return end
  if not boss.model.Parent then remove();return end
  if clock.elapsed>=math.min(105,clock.roundLength-10)and boss.action~='retreat'then action('retreat')end
  local root,dist=nearest(boss.pos);if not root then return end
  local participants=0;for _,s in pairs(states)do if deps.rootOf(s)then participants+=1 end end
  if participants>0 and participants<boss.participants then
   local nextHp=math.floor(SOLO_HEALTH*(1+math.max(0,participants-1)*.65))
   boss.hp=math.max(1,boss.hp/boss.maxHp*nextHp);boss.maxHp=nextHp;boss.participants=participants
   boss.model:SetAttribute('HP',boss.hp);boss.model:SetAttribute('MaxHP',nextHp)
  end
  boss.slow=math.max(0,boss.slow-dt);boss.frozen=0;boss.knockTime=0
  boss.actionTime+=dt;local name=boss.action;local t=boss.actionTime
  boss.model:SetAttribute('FieldProgress',math.clamp(t/(durations[name]or 1),0,1))
  if name=='approach'then
   local delta=flat(root.Position-boss.pos);local desired=delta.Magnitude>.01 and delta.Unit or boss.direction
   local angle=math.atan2(boss.direction:Cross(desired).Y,boss.direction:Dot(desired));local turn=math.clamp(angle,-dt*2.8,dt*2.8)
   boss.direction=CFrame.Angles(0,turn,0):VectorToWorldSpace(boss.direction)
   if dist>11 then boss.pos=bound(boss.pos+boss.direction*math.min(dist-11,15*(boss.slow>0 and .75 or 1)*dt))end
   if t>=.35 and(dist<=14 or t>=1.6)then
    -- Lock before the visible windup; no tracking after a telegraph appears.
    if boss.nextCharge or dist>17 then
     boss.chargeStart=boss.pos;boss.chargeEnd=bound(boss.pos+boss.direction*30);boss.chargeLength=(boss.chargeEnd-boss.pos).Magnitude;action('chargeWindup')
    else action('cleaveWindup')end
   end
  elseif name=='cleave'then
   if t>=.16 then hitPlayers(boss.pos,boss.pos,true)end
   if t>=durations.cleave then boss.nextCharge=true;action('recover')end
  elseif name=='charge'then
   local previous=boss.pos;boss.pos=boss.chargeStart:Lerp(boss.chargeEnd,math.clamp(t/durations.charge,0,1));hitPlayers(previous,boss.pos,false)
   if t>=durations.charge then boss.nextCharge=false;action('recover')end
  elseif t>=(durations[name]or 1)then
   if name=='retreat'then remove();return
   elseif name=='cleaveWindup'then action('cleave')
   elseif name=='chargeWindup'then action('charge')
   else action('approach')end
  end
  if boss then boss.model:PivotTo(CFrame.lookAt(boss.pos,boss.pos+boss.direction))end
 end
 return {Step=step,Resolve=resolve,Reset=function()remove();spawned=false end}
end
