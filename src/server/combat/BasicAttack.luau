-- Clients request a swing/shot, never a target, weapon profile or damage value.
return function(deps)
 local weapons=require(script.Parent.Weapons)
 local shots={};local serial=0
 local function clear(source)
  for i=#shots,1,-1 do local p=shots[i];if not source or p.source==source then p.anchor:Destroy();table.remove(shots,i)end end
 end
 local function request(s)
  if s.over or s.lobby or s.offers or deps.paused()or(s.basicCooldown or 0)>.0001 then return end
  local root=deps.rootOf(s);if not root then return end
  local profile=weapons.Get(s.weaponId)
  local direction=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
  direction=direction.Magnitude>.01 and direction.Unit or Vector3.new(0,0,-1)
  local origin=root.Position+Vector3.new(0,.8,0)+direction*2
  serial+=1;local a=Instance.new('Part');a.Name='BasicBolt_'..serial;a.Size=Vector3.one*.1;a.Transparency=1;a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.CFrame=CFrame.lookAt(origin,origin+direction);a:SetAttribute('Style',profile.style);a.Parent=deps.world
  table.insert(shots,{source=s,anchor=a,direction=direction,profile=profile,distance=0})
  s.basicCooldown=profile.interval;deps.effect:FireAllClients('basicBolt',a.Name);return true
 end
 local function step(dt)
  for i=#shots,1,-1 do
   local p=shots[i];local root=deps.rootOf(p.source);local remove=not root or not p.anchor.Parent
   if not remove and not p.source.offers then
    local from=p.anchor.Position;local travel=math.min(p.profile.speed*dt,p.profile.range-p.distance);local to=from+p.direction*travel
    local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={deps.world,p.source.player.Character};ray.RespectCanCollide=true
    local wall=workspace:Raycast(from,to-from,ray);if wall then to=wall.Position end
    local delta=to-from;local length=delta:Dot(delta);local hit,first=nil,math.huge
    for _,e in ipairs(deps.enemies)do if e.hp>0 then
     local t=length>.0001 and math.clamp((e.pos-from):Dot(delta)/length,0,1)or 0
     if(e.pos-from-delta*t).Magnitude<=p.profile.radius and t<first then hit,first=e,t end
    end end
    p.distance+=travel
    if hit then deps.damage(hit,p.profile.damage,p.source);deps.effect:FireAllClients('basicHit',hit.pos);remove=true
    elseif wall or p.distance>=p.profile.range then remove=true
    else p.anchor.CFrame=CFrame.lookAt(to,to+p.direction)end
   end
   if remove then p.anchor:Destroy();table.remove(shots,i)end
  end
 end
 local function stepPlayer(s,dt)if not s.offers then s.basicCooldown=math.max(0,(s.basicCooldown or 0)-dt)end end
 return {Request=request,Step=step,StepPlayer=stepPlayer,Clear=clear}
end
