-- Single-target pressure. Each projectile hits one enemy; no explosion damage.
return function(deps)
 local shots={};local nextShot=0
 local function target(origin)
  local best,score=nil,-math.huge
  for _,e in ipairs(deps.enemies)do
   local distance=(e.pos-origin).Magnitude
   if e.hp>0 and distance<=58 then
    local value=((e.isBoss or e.isFieldBoss) and 1000000 or 0)+math.min(e.hp,100000)*4-distance
    if value>score then best,score=e,value end
   end
  end
  return best
 end
 local function clear(source)
  for i=#shots,1,-1 do if not source or shots[i].source==source then shots[i].anchor:Destroy();table.remove(shots,i)end end
 end
 local function stepPlayer(s,root,dt)
  local level=s.missile or 0;if level<=0 then return end
  s.missileClock=math.max(0,(s.missileClock or 0)-dt);if s.missileClock>0 then return end
  local enemy=target(root.Position);if not enemy then return end
  s.missileClock=3.8-level*.2
  local count=2+math.floor(level/2)
  for index=1,count do
   local pos=root.Position+root.CFrame.RightVector*((index-(count+1)/2)*1.6)+Vector3.new(0,1.2,0)
   nextShot+=1
   local anchor=Instance.new('Part');anchor.Name='HomingMissile_'..nextShot;anchor.Size=Vector3.one*.1;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=CFrame.lookAt(pos,enemy.pos);anchor.Parent=deps.world
   table.insert(shots,{source=s,target=enemy,level=level,time=0,anchor=anchor})
   deps.effect:FireAllClients('homingMissile',anchor.Name)
  end
 end
 local function step(dt)
  for i=#shots,1,-1 do
   local shot=shots[i];local root=deps.rootOf(shot.source);local remove=not root or not shot.anchor.Parent
   if not remove and not shot.source.offers then
    shot.time+=dt
    if shot.target.hp<=0 then shot.target=target(root.Position)end
    if not shot.target or shot.time>3.5 then remove=true
    else
     local delta=shot.target.pos-shot.anchor.Position;local travel=44*dt
     if delta.Magnitude<=travel+1.3 then
      deps.damage(shot.target,18+shot.level*7,shot.source)
      deps.effect:FireAllClients('missileHit',shot.target.pos);remove=true
     else
      local move=delta.Unit*travel
      local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={deps.world,shot.source.player.Character};params.RespectCanCollide=true
      local hit=workspace:Raycast(shot.anchor.Position,move,params)
      if hit then deps.effect:FireAllClients('missileHit',hit.Position);remove=true
      else local pos=shot.anchor.Position+move;shot.anchor.CFrame=CFrame.lookAt(pos,pos+delta.Unit)end
     end
    end
   end
   if remove then if shot.anchor.Parent then shot.anchor:Destroy()end;table.remove(shots,i)end
  end
 end
 return {StepPlayer=stepPlayer,Step=step,Clear=clear}
end
