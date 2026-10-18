-- All spell timing and damage belong to the shared server simulation clock.
local A=require(script.Parent.Parent.flow.Augments)
return function(deps)
 local enemies,world,effect=deps.enemies,deps.world,deps.effect
 local nextCast=0
 local function flat(v)return Vector3.new(v.X,0,v.Z)end
 local function targetPoint(origin)
  local best,score=nil,-math.huge
  for _,e in ipairs(enemies)do
   if e.hp>0 and not e.airborne and (e.pos-origin).Magnitude<52 then
    local count=0
    for _,other in ipairs(enemies)do if other.hp>0 and not other.airborne and (other.pos-e.pos).Magnitude<15 then count+=1 end end
    local value=count*10-(e.pos-origin).Magnitude*.1
    if value>score then best,score=e.pos,value end
   end
  end
  return best and Vector3.new(best.X,.35,best.Z)
 end
 local function clear(s)
  for _,cast in ipairs(s.areaCasts or {})do if cast.anchor.Parent then cast.anchor:Destroy()end end
  s.areaCasts={};s.shield=0;s.areaEchoes={}
 end
 local function start(s,kind,point,level)
  local radius=kind=='meteor' and 14+level or(kind=='frost' and 12+level or(kind=='blades' and 11+level*.7 or 4))
  if kind=='meteor'and A.Has(s,'meteor_wide')then radius*=1.35 elseif kind=='frost'and A.Has(s,'frost_wide')then radius*=1.3 end
  local duration=kind=='meteor' and 3.2 or(kind=='frost' and .75 or(kind=='blades' and 6 or 5))
  if kind=='ward'and A.Has(s,'ward_reservoir')then duration=7 end
  nextCast+=1
  local anchor=Instance.new('Part');anchor.Name='AreaCast_'..nextCast;anchor:SetAttribute('Kind',kind);anchor.Size=Vector3.one*.1;anchor.Position=point;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false
  anchor:SetAttribute('Elapsed',0);anchor:SetAttribute('Radius',radius);anchor:SetAttribute('Duration',duration);anchor:SetAttribute('Level',level)
  if kind=='ward' then
   s.shield=(30+level*12)*(A.Has(s,'ward_reservoir')and 1.5 or 1)
   if s.player and type(s.player.UserId)=='number'then anchor:SetAttribute('OwnerUserId',s.player.UserId)end
  end
  anchor.Parent=world
  table.insert(s.areaCasts,{kind=kind,pos=point,level=level,radius=radius,duration=duration,time=0,hits={},anchor=anchor,shield=s.shield or 0})
  effect:FireAllClients('areaCast',anchor.Name,kind)
 end
 local function hit(cast,s,amount)
  for _,e in ipairs(enemies)do
   if e.hp>0 and not e.airborne and flat(e.pos-cast.pos).Magnitude<=cast.radius then
    deps.damage(e,amount,s)
    if cast.kind=='frost' and e.hp>0 then
     e.slow=math.max(e.slow or 0,2.5)
     if not e.isBoss and not e.isFieldBoss then e.frozen=math.max(e.frozen or 0,.8+cast.level*.2);e.model:SetAttribute('Frozen',true)end
    end
   end
  end
 end
 local function step(s,root,dt)
  s.areaCasts=s.areaCasts or {};s.areaEchoes=s.areaEchoes or {}
  for i=#s.areaEchoes,1,-1 do
   local echo=s.areaEchoes[i];echo.delay-=dt
   if echo.delay<=0 then
    if echo.kind=='frost'then echo.pos=Vector3.new(root.Position.X,.35,root.Position.Z)end
    hit(echo,s,echo.amount);effect:FireAllClients(echo.kind=='meteor'and'meteorHit'or'frostHit',echo.pos,echo.radius)
    table.remove(s.areaEchoes,i)
   end
  end
  for i=#s.areaCasts,1,-1 do
   local cast=s.areaCasts[i];cast.time+=dt
   if cast.kind~='meteor' then cast.pos=Vector3.new(root.Position.X,.35,root.Position.Z);cast.anchor.Position=cast.pos end
   cast.anchor:SetAttribute('Elapsed',cast.time)
   local done=cast.time>=cast.duration or(cast.kind=='ward' and (s.shield or 0)<=0)
   if done then
    if cast.kind=='meteor' or cast.kind=='frost' then
     hit(cast,s,cast.kind=='meteor' and 65+cast.level*22 or 18+cast.level*8)
     effect:FireAllClients(cast.kind=='meteor' and 'meteorHit' or 'frostHit',cast.pos,cast.radius)
     if A.Has(s,cast.kind..'_echo')then
      table.insert(s.areaEchoes,{kind=cast.kind,pos=cast.pos,radius=cast.radius,level=cast.level,amount=(cast.kind=='meteor'and 65+cast.level*22 or 18+cast.level*8)*.5,delay=cast.kind=='meteor'and .65 or .6})
     end
    elseif cast.kind=='ward' then
     s.shield=0
     if A.Has(s,'ward_pulse')then hit({kind='ward',pos=cast.pos,radius=8},s,cast.shield*.75);effect:FireAllClients('augmentPulse',cast.pos,8)end
    end
    cast.anchor:Destroy();table.remove(s.areaCasts,i)
   end
  end
  for _,kind in ipairs({'meteor','frost','ward'})do
   local level=s[kind] or 0
   if level>0 then
    local key=kind..'Clock';s[key]=math.max(0,(s[key]or 0)-dt)
    if s[key]<=0 then
     local point=kind=='ward' and Vector3.new(root.Position.X,.35,root.Position.Z) or targetPoint(root.Position)
     if kind=='frost' then
      point=nil;for _,e in ipairs(enemies)do if e.hp>0 and not e.airborne and flat(e.pos-root.Position).Magnitude<=(12+level)*(A.Has(s,"frost_wide")and 1.3 or 1)then point=e.pos;break end end
     end
     if point then
      start(s,kind,kind=='meteor' and point or Vector3.new(root.Position.X,.35,root.Position.Z),level)
      s[key]=A.Cooldown(s,(kind=='meteor' and 9 or(kind=='blades' and 8.5 or(kind=='frost' and 6 or 12)))-level*.3)
     end
    end
   end
  end
 end
 return {Step=step,Clear=clear}
end
