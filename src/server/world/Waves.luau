-- Mixed packs, flanking skitters, strafing casters and telegraphed chargers.
return function(deps)
 local applyDamage=require(script.Parent.Parent.shared.PlayerDamage)
 local states,enemies,rng=deps.states,deps.enemies,deps.rng
 local creature,rootOf,roundLength=deps.creature,deps.rootOf,deps.roundLength
 local spawnClock,nextEnemy,time=0,0,0
 local nextPack=18
 local shots={}
 local function flat(v)return Vector3.new(v.X,0,v.Z)end
 local function bound(p)local f=flat(p);if f.Magnitude>81 then f=f.Unit*81 end;return Vector3.new(f.X,p.Y,f.Z)end
 local function create(kind,pos,elapsed)
  if #enemies>=84 then return end
  nextEnemy+=1
  local m=creature('Shade_'..nextEnemy,Color3.new(),false,kind);m:PivotTo(CFrame.new(pos))
  local elite=elapsed>=65 and nextEnemy%9==0
  local hpScale=kind=='brute'and 1.5 or(kind=='skitter'and .7 or(kind=='charger'and 1.15 or 1))
  local speedScale=kind=='brute'and .68 or(kind=='skitter'and 1.18 or(kind=='caster'and .85 or 1))
  local hp=math.floor((26+elapsed*.35)*hpScale*(elite and 1.75 or 1))
  if elite then
   m:ScaleTo(1.2);m:SetAttribute('Elite',true)
   local crest=Instance.new('Part');crest.Name='EliteCrown';crest.Shape=Enum.PartType.Ball;crest.Size=Vector3.new(.6,.6,.6);crest.Position=pos+Vector3.new(0,4.8,0);crest.Material=Enum.Material.Neon;crest.Color=Color3.fromRGB(255,215,111);crest.Anchored=true;crest.CanCollide=false;crest.CanTouch=false;crest.CanQuery=false;crest.Parent=m
  end
  m:SetAttribute('HP',hp)
  table.insert(enemies,{model=m,pos=pos,hp=hp,kind=kind,elite=elite,speed=(9+math.min(4.8,elapsed/36))*speedScale,hitClock=0,slow=0,castClock=rng:NextNumber(1,3),seed=nextEnemy})
 end
 local function spawn(dt,alive,elapsed)
  if elapsed>=roundLength or(deps.clock and deps.clock.phase~='survival')then return end
  spawnClock-=dt
  if spawnClock>0 or #enemies>=84 then return end
  local fieldActive=deps.clock and deps.clock.fieldBoss~=nil
  spawnClock=math.max(.28,.8-elapsed*.0035)/math.max(1,alive*.65)/(fieldActive and .6 or 1)
  local pool={'stalker','stalker','stalker','stalker','stalker','stalker'}
  if elapsed>=12 then table.insert(pool,'skitter');table.insert(pool,'skitter');table.insert(pool,'skitter')end
  if elapsed>=28 then table.insert(pool,'brute');table.insert(pool,'brute')end
  if elapsed>=42 then table.insert(pool,'caster');table.insert(pool,'caster')end
  if elapsed>=60 and not fieldActive then table.insert(pool,'ember')end
  if elapsed>=32 then table.insert(pool,'charger');table.insert(pool,'charger')end
  local a=rng:NextNumber(0,math.pi*2)
  create(pool[rng:NextInteger(1,#pool)],Vector3.new(math.cos(a)*77,3,math.sin(a)*77),elapsed)
  if elapsed>=nextPack and not fieldActive then
   nextPack=elapsed+18
   -- A readable pair of flanking groups; no spawning directly on the player.
   for side=0,1 do for member=1,3 do
    local angle=a+side*math.pi+(member-2)*.085
    create(elapsed>=32 and(member==2 and 'charger'or'skitter')or'stalker',Vector3.new(math.cos(angle)*77,3,math.sin(angle)*77),elapsed)
   end end
  end
 end
 local function harm(s,amount)
  local _,h=rootOf(s)
  if h and not s.offers and(s.invulnerable or 0)<=0 then applyDamage(s,h,amount,deps.effect);return true end
 end
 local function shoot(e,direction)
  e.model:SetAttribute('AttackSequence',(e.model:GetAttribute('AttackSequence')or 0)+1)
  if #shots>=20 then return end
  local p=Instance.new('Part');p.Name='EnemyArcaneBolt';p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*.75;p.Color=Color3.fromRGB(226,126,255);p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Position=e.pos+Vector3.new(0,1.1,0);p.Parent=deps.world
  local a=Instance.new('Attachment');a.Position=Vector3.new(0,.2,0);a.Parent=p;local b=Instance.new('Attachment');b.Position=Vector3.new(0,-.2,0);b.Parent=p
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.23;trail.Color=ColorSequence.new(Color3.fromRGB(239,179,255));trail.Transparency=NumberSequence.new(.15,1);trail.LightEmission=1;trail.Parent=p
  table.insert(shots,{part=p,pos=p.Position,direction=direction,life=3.4})
 end
 local function stepShots(dt)
  for i=#shots,1,-1 do
   local s=shots[i];s.life-=dt
   local previous=s.pos;s.pos+=s.direction*22*dt
   local remove=s.life<=0 or not s.part.Parent or flat(s.pos).Magnitude>86
   if not remove then
    local segment=s.pos-previous;local length=segment:Dot(segment)
    for _,state in pairs(states)do local r=rootOf(state);if r then
     local alpha=length>.001 and math.clamp((r.Position-previous):Dot(segment)/length,0,1)or 0
     if(r.Position-(previous+segment*alpha)).Magnitude<2 and harm(state,6)then remove=true;break end
    end end
   end
   if remove then s.part:Destroy();table.remove(shots,i)else s.part.Position=s.pos end
  end
 end
 local function step(dt)
  time+=dt;stepShots(dt)
  for i=#enemies,1,-1 do
   local e=enemies[i]
   if e.isBoss or e.isFieldBoss then continue end
   if e.hp<=0 then table.remove(enemies,i);continue end
   local target,dist=nil,math.huge
   for _,s in pairs(states)do local r=rootOf(s);if r then local d=flat(r.Position-e.pos).Magnitude;if d<dist then target,dist=s,d end end end
   if not target then continue end
   local r=rootOf(target);local diff=flat(r.Position-e.pos)
   e.slow=math.max(0,e.slow-dt);e.hitClock=math.max(0,e.hitClock-dt);e.frozen=math.max(0,(e.frozen or 0)-dt);e.model:SetAttribute('Frozen',e.frozen>0)
   if(e.knockTime or 0)>0 then local duration=math.min(dt,e.knockTime);e.pos=bound(e.pos+e.knockback*duration);e.knockback*=math.exp(-dt*4);e.knockTime-=duration end
   local moving=e.frozen<=0
   local move=diff.Magnitude>.01 and diff.Unit or Vector3.zero
   local speed=e.speed*(e.slow>0 and .45 or 1)
   if e.kind=='charger'then
    e.castClock=math.max(0,(e.castClock or 0)-(moving and dt or 0))
    if e.chargeTime then
     if moving then e.chargeTime-=dt end
     move=e.chargeDirection;speed=34
     if e.chargeTime<=0 then e.chargeTime=nil;e.castClock=4.5;moving=false end
    elseif (e.chargeWindup or 0)>0 or(dist<32 and dist>6 and e.castClock<=0)then
     if not e.chargeDirection then e.chargeDirection=move end
     if moving then e.chargeWindup=(e.chargeWindup or 0)+dt end
     moving=false
     local marker=e.model:FindFirstChild('ChargeWarning')
     if not marker then
      marker=Instance.new('Part');marker.Name='ChargeWarning';marker.Size=Vector3.new(4,.06,23);marker.Color=Color3.fromRGB(255,151,75);marker.Material=Enum.Material.Neon;marker.Transparency=.7;marker.Anchored=true;marker.CanCollide=false;marker.CanTouch=false;marker.CanQuery=false;marker.Parent=e.model
     end
     local start=Vector3.new(e.pos.X,.18,e.pos.Z);marker.CFrame=CFrame.lookAt(start+e.chargeDirection*11.5,start+e.chargeDirection*23)
     if (e.chargeWindup or 0)>=.85 then marker:Destroy();e.chargeTime=.65;e.chargeWindup=0 end
    else e.chargeDirection=nil end
   elseif e.kind=='caster'then
    e.castClock-=moving and dt or 0
    if moving and dist<34 and e.castClock<=0 then
     moving=false;e.windup=(e.windup or 0)+dt
     if not e.castDirection then e.castDirection=move end
     local orb=e.model:FindFirstChild('StaffOrb');if orb then orb.Color=Color3.fromRGB(255,230,255)end
     if e.windup>=.8 then shoot(e,e.castDirection);e.windup=0;e.castDirection=nil;e.castClock=2.5;if orb then orb.Color=Color3.fromRGB(214,127,255)end end
    elseif dist<18 then
     if moving then move=Vector3.new(-move.Z,0,move.X)*(e.seed%2==0 and 1 or -1);speed*=.65 end
    end
   elseif e.kind=='ember'and(e.detonating or dist<8)then
    if not e.detonating then
     e.detonating=true;e.blastPoint=e.pos;e.fuse=0
     local marker=Instance.new('Part');marker.Name='EnemyBlastWarning';marker.Shape=Enum.PartType.Cylinder;marker.Size=Vector3.new(.08,12,12);marker.CFrame=CFrame.new(e.pos.X,.17,e.pos.Z)*CFrame.Angles(0,0,math.pi/2);marker.Material=Enum.Material.Neon;marker.Color=Color3.fromRGB(255,74,45);marker.Transparency=.78;marker.Anchored=true;marker.CanCollide=false;marker.CanTouch=false;marker.CanQuery=false;marker.Parent=e.model
    end
    if moving then e.fuse+=dt end
    moving=false
    local core=e.model:FindFirstChild('FurnaceCore');if core then core.Color=Color3.fromRGB(255,180+math.floor(60*math.sin(time*16)),90)end
    if e.fuse>=1.2 then
     if deps.effect then deps.effect:FireAllClients('enemyExplosion',e.blastPoint,6)end
     for _,s in pairs(states)do local root=rootOf(s);if root and flat(root.Position-e.blastPoint).Magnitude<=6 then harm(s,12)end end
     if deps.drop then deps.drop(e.pos)end;e.hp=0;e.model:Destroy();continue
    end
   end
   if e.kind=='skitter'and dist>7 and dist<35 then
    local tangent=Vector3.new(-move.Z,0,move.X)*(e.seed%2==0 and 1 or -1)
    move=(move+tangent*.65).Unit
   end
   if moving and dist>2.5 then e.pos=bound(e.pos+move*math.min(dist-2.5,speed*dt))end
   if e.model.Parent then e.model:SetAttribute('Preparing',(e.windup or 0)>0);e.model:SetAttribute('Detonating',e.detonating==true)end
   if e.model.Parent and diff.Magnitude>.01 then
    local bob=e.kind=='caster'and math.sin(time*2+e.seed)*.25 or math.sin(time*(e.kind=='skitter'and 9 or 4)+e.seed)*.08
    e.model:PivotTo(CFrame.lookAt(e.pos+Vector3.new(0,bob,0),e.pos+Vector3.new(0,bob,0)+move))
   end
   if e.kind~='caster'and e.kind~='ember'and dist<4 and e.hitClock<=0 and e.frozen<=0 then
    if harm(target,e.kind=='brute'and 11 or(e.kind=='charger'and 12 or(e.kind=='skitter'and 6 or 8)))then e.hitClock=.95;e.model:SetAttribute('AttackSequence',(e.model:GetAttribute('AttackSequence')or 0)+1)end
   end
  end
 end
 local function resetSpawn()
  spawnClock=0;time=0;nextPack=18
  for _,s in ipairs(shots)do s.part:Destroy()end;table.clear(shots)
 end
 return {Spawn=spawn,Step=step,ResetSpawn=resetSpawn}
end
