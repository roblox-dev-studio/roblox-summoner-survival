-- Q windup and moving spear are driven by the shared server simulation.
return function(deps)
 local nextCast=0
 local function clear(s)
  if s.activeCast then if s.activeCast.anchor.Parent then s.activeCast.anchor:Destroy()end;s.activeCast=nil end
 end
 local function request(s,origin,direction)
  local kind=s.activeSkill;if kind~='fire' and kind~='thunder' and kind~='iceRush' and kind~='aetherLance' then return end
  if kind=='fire' then
   nextCast+=1
   local anchor=Instance.new('Part');anchor.Name='ActiveFireball_'..nextCast;anchor.Anchored=true;anchor.Transparency=1;anchor.Size=Vector3.one*.1;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false
   local start=origin+direction*3+Vector3.new(0,1.2,0);anchor.CFrame=CFrame.lookAt(start,start+direction);anchor.Parent=deps.world
   s.activeCast={kind=kind,time=0,origin=start,direction=direction,range=42,travelled=0,hits={},anchor=anchor};s.cooldown=7
   deps.effect:FireAllClients('fireProjectile',anchor.Name);return true
  end
  nextCast+=1
  local anchor=Instance.new('Part');anchor.Name='ActiveCast_'..nextCast;anchor.Anchored=true;anchor.Transparency=1;anchor.Size=Vector3.one*.1;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false
  anchor.CFrame=CFrame.lookAt(origin,origin+direction);anchor:SetAttribute('Elapsed',0);anchor:SetAttribute('Duration',.4);anchor:SetAttribute('Range',kind~='iceRush' and 52 or 34);anchor:SetAttribute('Launched',false);anchor.Parent=deps.world
  s.activeCast={kind=kind,time=0,origin=origin,direction=direction,range=kind~='iceRush' and 52 or 34,travelled=0,hits={},anchor=anchor};s.cooldown=7
  deps.effect:FireAllClients('activeCast',anchor.Name,kind)
  if kind~='iceRush' then deps.effect:FireAllClients(kind=='thunder'and'thunderSpear'or'aetherSpear',anchor.Name)end
  return true
 end
 local function segmentDistance(point,a,b,horizontalScale)
  local delta=b-a;local offset=point-a
  -- Widen only the energy lance's horizontal footprint; preserve vertical reach.
  if horizontalScale then
   delta=Vector3.new(delta.X*horizontalScale,delta.Y,delta.Z*horizontalScale)
   offset=Vector3.new(offset.X*horizontalScale,offset.Y,offset.Z*horizontalScale)
  end
  local square=delta:Dot(delta)
  local t=square>.0001 and math.clamp(offset:Dot(delta)/square,0,1)or 0
  return (offset-delta*t).Magnitude
 end
 local function step(s,dt)
  local cast=s.activeCast;if not cast then return end
  cast.time+=dt;cast.anchor:SetAttribute('Elapsed',cast.time)
  if cast.kind=='fire' then
   local previous=cast.origin+cast.direction*cast.travelled
   local travel=math.min(58*dt,cast.range-cast.travelled);local pos=previous+cast.direction*travel
   local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={deps.world,s.player.Character};params.RespectCanCollide=true
   local wall=workspace:Raycast(previous,pos-previous,params);if wall then pos=wall.Position end
   local target,nearest=nil,math.huge
   for _,e in ipairs(deps.enemies)do
    local along=(e.pos-previous):Dot(cast.direction)
    if e.hp>0 and along>=-2.4 and along<=(pos-previous).Magnitude and segmentDistance(e.pos,previous,pos)<=2.4 and along<nearest then target=e;nearest=along end
   end
   if target then pos=previous+cast.direction*math.clamp(nearest,0,(pos-previous).Magnitude)end
   cast.travelled+=(pos-previous).Magnitude;cast.anchor.CFrame=CFrame.lookAt(pos,pos+cast.direction)
   if target or wall then
    for _,e in ipairs(deps.enemies)do if e.hp>0 and (e==target or(e.pos-pos).Magnitude<=5)then deps.damage(e,75,s)end end
    clear(s)
   elseif cast.travelled>=cast.range-.001 then clear(s)end
   return
  end
  if cast.time<.4 then return end
  if cast.kind=='thunder'or cast.kind=='aetherLance' then
   cast.anchor:SetAttribute('Launched',true)
   local start=cast.origin+cast.direction*3+Vector3.new(0,1.2,0)
   local previous=start+cast.direction*cast.travelled
   local travel=math.min(48*math.min(dt,cast.time-.4),cast.range-cast.travelled)
   local pos=previous+cast.direction*travel
   local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={deps.world,s.player.Character};params.RespectCanCollide=true
   local wall=travel>.001 and workspace:Raycast(previous,pos-previous,params)or nil
   if wall then pos=wall.Position end
   for _,e in ipairs(deps.enemies)do
    if e.hp>0 and not cast.hits[e] and segmentDistance(e.pos,previous,pos,cast.kind=='aetherLance'and .5 or nil)<=2.4 then
     cast.hits[e]=true;deps.damage(e,72+(s.lightning or 0)*8,s);deps.effect:FireAllClients(cast.kind=='thunder'and'thunderHit'or'aetherHit',e.pos)
    end
   end
   cast.travelled+=(pos-previous).Magnitude;cast.anchor.CFrame=CFrame.lookAt(pos,pos+cast.direction)
   if wall or cast.travelled>=cast.range-.001 then deps.effect:FireAllClients(cast.kind=='thunder'and'thunderHit'or'aetherHit',pos);clear(s)end
   return
  end
  if not cast.eruptionStarted then
   cast.eruptionStarted=true;cast.anchor:SetAttribute('Launched',true)
   deps.effect:FireAllClients('activeStrike',cast.origin,cast.direction,{kind='iceRush',range=cast.range,width=6,anchorName=cast.anchor.Name})
  end
  -- Each ground strip erupts and hits once as the ice travels away from the caster.
  cast.iceRow=cast.iceRow or 0
  while cast.iceRow<7 and cast.time>=.4+.07+cast.iceRow*.075 do
   local row=cast.iceRow;cast.iceRow+=1
   for _,e in ipairs(deps.enemies)do
    if e.hp>0 and not e.airborne and not cast.hits[e]then
     local delta=Vector3.new(e.pos.X-cast.origin.X,0,e.pos.Z-cast.origin.Z);local along=delta:Dot(cast.direction)
     if along>=row*cast.range/7 and along<=(row+1)*cast.range/7 and(delta-cast.direction*along).Magnitude<=6 then
      cast.hits[e]=true;deps.damage(e,52+(s.ice or 0)*7,s)
      if e.hp>0 then e.slow=math.max(e.slow or 0,2.5);if not e.isBoss and not e.isFieldBoss then e.frozen=math.max(e.frozen or 0,1.1);e.model:SetAttribute('Frozen',true);e.knockback=cast.direction*28;e.knockTime=.2 end end
     end
    end
   end
  end
  if cast.iceRow>=7 then clear(s)end
 end
 return {Request=request,Step=step,Clear=clear}
end
