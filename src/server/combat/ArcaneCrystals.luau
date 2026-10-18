-- Five stored crystals launch separately, then recharge on the server clock.
local A=require(script.Parent.Parent.flow.Augments)
return function(deps)
 local auras,shots={},{};local nextId=0
 local function muzzle(frame,index,count)
  local angle=index/(count+1)*math.pi-math.pi/2
  return frame:PointToWorldSpace(Vector3.new(math.sin(angle)*4.2,3.2+math.cos(angle)*1.7,1.8))
 end
 local function clear(source)
  for s,aura in pairs(auras)do if not source or s==source then aura.anchor:Destroy();auras[s]=nil end end
  for i=#shots,1,-1 do if not source or shots[i].source==source then shots[i].anchor:Destroy();table.remove(shots,i)end end
 end
 local function stepPlayer(s,root,dt)
  local level=s.blades or 0;if level<=0 then return end
  local count=A.Has(s,"blades_volley")and 7 or 5
  local aura=auras[s]
  if aura and (aura.level~=level or aura.count~=count) then aura.anchor:Destroy();auras[s]=nil;aura=nil end
  if not aura then
   nextId+=1;local anchor=Instance.new('Part');anchor.Name='CrystalAura_'..nextId;anchor.Size=Vector3.one*.1;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=root.CFrame
   anchor:SetAttribute('Count',count);anchor:SetAttribute('Radius',2);anchor:SetAttribute('Duration',1000000);anchor:SetAttribute('Elapsed',0);anchor:SetAttribute('Level',level);A.Stamp(anchor,s,"blades");anchor.Parent=deps.world
   aura={anchor=anchor,time=0,index=0,level=level,recharge=0,count=count};auras[s]=aura;deps.effect:FireAllClients('areaCast',anchor.Name,'blades')
  end
  aura.time+=dt;aura.anchor.CFrame=root.CFrame;aura.anchor:SetAttribute('Elapsed',aura.time);aura.anchor:SetAttribute('Level',level);A.Stamp(aura.anchor,s,'blades')
  aura.recharge=math.max(0,aura.recharge-dt)
  if aura.recharge>0 then return end
  if aura.index>=count then aura.index=0;aura.anchor:SetAttribute('Fired',0)end
  s.crystalClock=math.max(0,(s.crystalClock or 0)-dt);if s.crystalClock>0 then return end
  local candidates={}
  for _,e in ipairs(deps.enemies)do if e.hp>0 and (e.pos-root.Position).Magnitude<48 then table.insert(candidates,e)end end
  table.sort(candidates,function(a,b)return (a.pos-root.Position).Magnitude<(b.pos-root.Position).Magnitude end)
  if #candidates==0 then return end
  aura.index+=1
  local target=candidates[(aura.index-1)%math.min(count,#candidates)+1]
  local pos=muzzle(root.CFrame,aura.index,count);local delta=target.pos-pos;if delta.Magnitude<.01 then delta=root.CFrame.LookVector end
  nextId+=1;local anchor=Instance.new('Part');anchor.Name='CrystalBolt_'..nextId;anchor.Size=Vector3.one*.1;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=CFrame.lookAt(pos,pos+delta);A.Stamp(anchor,s,"blades");anchor.Parent=deps.world
  s.crystalClock=.18
  aura.anchor:SetAttribute('Fired',aura.index)
  if aura.index==count then aura.recharge=A.Cooldown(s,4.4-level*.35);s.crystalClock=0 end
  table.insert(shots,{source=s,level=level,anchor=anchor,time=0,direction=delta.Unit,target=target,hits={},remaining=A.Has(s,"blades_pierce")and 2 or 1})
  deps.effect:FireAllClients('crystalBolt',anchor.Name)
 end
 local function segmentDistance(p,a,b)
  local ab=b-a;local length=ab:Dot(ab);local t=length>.0001 and math.clamp((p-a):Dot(ab)/length,0,1)or 0
  return (p-a-ab*t).Magnitude,t
 end
 local function step(dt)
  for i=#shots,1,-1 do
   local shot=shots[i];local r=deps.rootOf(shot.source);local remove=not r or not shot.anchor.Parent
   if not remove and not shot.source.offers then
    shot.time+=dt
    local from=shot.anchor.Position
    if shot.target and shot.target.hp>0 then
     local delta=shot.target.pos-from
     if delta.Magnitude>.01 then local direction=shot.direction:Lerp(delta.Unit,math.min(1,dt*7));if direction.Magnitude>.01 then shot.direction=direction.Unit end end
    end
    local to=from+shot.direction*48*dt
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={deps.world,shot.source.player.Character};params.RespectCanCollide=true
    local wall=workspace:Raycast(from,to-from,params);if wall then to=wall.Position end
    local contacts={}
    for _,e in ipairs(deps.enemies)do if e.hp>0 and not shot.hits[e]then local d,t=segmentDistance(e.pos,from,to);if d<=1.3 then table.insert(contacts,{enemy=e,t=t})end end end
    table.sort(contacts,function(a,b)return a.t<b.t end)
    for _,contact in ipairs(contacts)do
     local hit=contact.enemy
     shot.hits[hit]=true;shot.remaining-=1;shot.target=nil
     deps.damage(hit,10+shot.level*4,shot.source);deps.effect:FireAllClients('crystalHit',hit.pos);A.Impact(deps.effect,shot.source,'blades',hit.pos,2.5,'hit')
     if shot.remaining<=0 then remove=true;break end
    end
    if wall or shot.time>=2 then remove=true end
    if not remove then shot.anchor.CFrame=CFrame.lookAt(to,to+shot.direction)end
   end
   if remove then if shot.anchor.Parent then shot.anchor:Destroy()end;table.remove(shots,i)end
  end
 end
 return {StepPlayer=stepPlayer,Step=step,Clear=clear}
end
