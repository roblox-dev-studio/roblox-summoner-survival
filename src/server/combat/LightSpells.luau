-- Returning crescent boomerang, on the shared server simulation.
local A=require(script.Parent.Parent.flow.Augments)
return function(deps)
 local casts={};local serial=0
 local function clear(source)
  for i=#casts,1,-1 do local c=casts[i];if not source or c.source==source then c.anchor:Destroy();table.remove(casts,i)end end
 end
 local function nearest(point,range)
  local best
  for _,e in ipairs(deps.enemies)do local d=(e.pos-point).Magnitude;if e.hp>0 and not e.airborne and d<range then best,range=e,d end end
  return best
 end
 local function start(s,kind,pos,level,direction,curve)
  serial+=1;local a=Instance.new('Part');a.Name='LightCast_'..serial;a.Size=Vector3.one*.1;a.Transparency=1;a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.CFrame=CFrame.lookAt(pos,pos+(direction or Vector3.zAxis));a:SetAttribute('Elapsed',0);a:SetAttribute('Level',level);a:SetAttribute('Radius',3);a:SetAttribute('Returning',false);a.Parent=deps.world
  table.insert(casts,{source=s,kind=kind,anchor=a,level=level,time=0,distance=0,origin=pos,direction=direction,hits={},returnHits={},pulse=0,returning=false,curve=curve or 1,multiplier=A.Has(s,"lightRing_twin")and .7 or 1})
  deps.effect:FireAllClients('lightCast',a.Name,kind)
 end
 local function stepPlayer(s,root,dt)
  if s.offers then return end
  for _,kind in ipairs({'lightRing'})do
   local level=s[kind]or 0
   if level>0 then
    local key=kind..'Clock';s[key]=math.max(0,(s[key]or 0)-dt)
    if s[key]<=0 then
     local target=nearest(root.Position,46)
     if target then
       local delta=Vector3.new(target.pos.X-root.Position.X,0,target.pos.Z-root.Position.Z);local direction=delta.Magnitude>.01 and delta.Unit or root.CFrame.LookVector
       if A.Has(s,"lightRing_twin")then
        for _,side in ipairs({-1,1})do start(s,kind,root.Position+Vector3.new(0,.8,0),level,CFrame.Angles(0,math.rad(12*side),0):VectorToWorldSpace(direction),side)end
       else start(s,kind,root.Position+Vector3.new(0,.8,0),level,direction)end
      s[key]=A.Cooldown(s,4.8-level*.25)
     end
    end
   end
  end
 end
 local function step(dt)
  for i=#casts,1,-1 do
   local c=casts[i];local root=deps.rootOf(c.source);local remove=not root or not c.anchor.Parent
   if not remove and not c.source.offers then
    c.time+=dt;c.anchor:SetAttribute('Elapsed',c.time)
     local from=c.anchor.Position;local to;local wall
     if c.returning then
      c.returnAge=(c.returnAge or 0)+dt
      local u=math.clamp(c.returnAge/c.returnDuration,0,1)
      local goal=root.Position+Vector3.new(0,.8,0)
      to=c.returnStart:Lerp(goal,u)-c.direction:Cross(Vector3.yAxis)*math.sin(u*math.pi)*2*c.curve
      if u>=1 then remove=true end
     else
      local distance=math.min(38,c.distance+34*dt)
      to=c.origin+c.direction*distance+c.direction:Cross(Vector3.yAxis)*math.sin(distance/38*math.pi)*1.8*c.curve
      local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={deps.world,c.source.player.Character};ray.RespectCanCollide=true
      wall=workspace:Raycast(from,to-from,ray);if wall then to=wall.Position end
      c.distance=wall and math.clamp((to-c.origin):Dot(c.direction),0,38)or distance
     end
     if c.returning then
      local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={deps.world,c.source.player.Character};ray.RespectCanCollide=true
      local obstruction=workspace:Raycast(from,to-from,ray);if obstruction then to=obstruction.Position;remove=true end
     end
     local delta=to-from;local length=delta:Dot(delta);local hits=c.returning and c.returnHits or c.hits
     for _,e in ipairs(deps.enemies)do if e.hp>0 and not hits[e]then
      local t=length>.0001 and math.clamp((e.pos-from):Dot(delta)/length,0,1)or 0
      if(e.pos-from-delta*t).Magnitude<=3.3 then hits[e]=true;deps.damage(e,A.Damage(c.source,"lightRing",(18+c.level*8)*c.multiplier,e,c.returning),c.source);deps.effect:FireAllClients('lightHit',e.pos,'lightRing')end
     end end
     if delta.Magnitude>.001 then c.anchor.CFrame=CFrame.lookAt(to,to+delta.Unit)end
     if not c.returning and(wall or c.distance>=38-.001)then c.returning=true;c.returnStart=to;c.returnAge=0;c.returnDuration=math.max(.1,(to-root.Position-Vector3.new(0,.8,0)).Magnitude/40);c.anchor:SetAttribute('Returning',true)end
     if c.time>=4 then remove=true end
   end
   if remove then c.anchor:Destroy();table.remove(casts,i)end
  end
 end
 return {StepPlayer=stepPlayer,Step=step,Clear=clear}
end
