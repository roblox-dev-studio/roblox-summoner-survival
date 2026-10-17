-- Q windup and moving spear are driven by the shared server simulation.
return function(deps)
 local nextCast=0
 local function clear(s)
  if s.activeCast then if s.activeCast.anchor.Parent then s.activeCast.anchor:Destroy()end;s.activeCast=nil end
 end
 local function request(s,origin,direction)
  local kind=s.activeSkill;if kind~='thunder' and kind~='iceRush' and kind~='aetherLance' then return end
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
  for _,e in ipairs(deps.enemies)do
   if e.hp>0 and not e.airborne then
    local delta=Vector3.new(e.pos.X-cast.origin.X,0,e.pos.Z-cast.origin.Z);local along=delta:Dot(cast.direction)
    if along>=0 and along<=cast.range and(delta-cast.direction*along).Magnitude<=6 then
     deps.damage(e,52+(s.ice or 0)*7,s)
     if e.hp>0 then e.slow=math.max(e.slow or 0,2.5);if not e.isBoss then e.frozen=math.max(e.frozen or 0,1.1);e.model:SetAttribute('Frozen',true);e.knockback=cast.direction*28;e.knockTime=.2 end end
    end
   end
  end
  deps.effect:FireAllClients('activeStrike',cast.origin,cast.direction,{kind='iceRush',range=34,width=6});clear(s)
 end
 return {Request=request,Step=step,Clear=clear}
end
