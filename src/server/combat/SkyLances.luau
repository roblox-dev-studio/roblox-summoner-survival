-- Narrow falling lances: server-time flight and one hit per enemy per lance.
return function(deps)
 local casts={};local nextId=0
 local offsets={Vector3.zero,Vector3.new(5,0,0),Vector3.new(0,0,5),Vector3.new(-5,0,0),Vector3.new(0,0,-5)}
 local function clear(source)
  for i=#casts,1,-1 do local c=casts[i];if not source or c.source==source then c.anchor:Destroy();table.remove(casts,i)end end
 end
 local function step(s,root,dt)
  if s.offers then return end
  for i=#casts,1,-1 do
   local c=casts[i]
   if c.source==s then
    c.time+=dt;c.anchor:SetAttribute('Elapsed',c.time)
    for index,lance in ipairs(c.lances)do
     local start=.9+(index-1)*.16
     local u=math.clamp((c.time-start)/.85,0,1)
     local tip=lance.point+Vector3.new(0,44*(1-u*u),0)
     if c.time>=start and not lance.done then
      local delta=tip-lance.last;local length=delta:Dot(delta)
      for _,e in ipairs(deps.enemies)do if e.hp>0 and not lance.hits[e] then
       local t=length>.0001 and math.clamp((e.pos-lance.last):Dot(delta)/length,0,1)or 0
       if (e.pos-lance.last-delta*t).Magnitude<=3.3 then lance.hits[e]=true;deps.damage(e,25+c.level*8,s)end
      end end
      if u>=1 then lance.done=true;deps.effect:FireAllClients('skyLanceHit',lance.point,3.3)end
     end
     lance.last=tip
    end
    if c.time>=2.65 then c.anchor:Destroy();table.remove(casts,i)end
   end
  end
  local level=s.skyLances or 0;if level<=0 then return end
  s.skyLancesClock=math.max(0,(s.skyLancesClock or 0)-dt);if s.skyLancesClock>0 then return end
  local target,best=nil,-math.huge
  for _,e in ipairs(deps.enemies)do if e.hp>0 and not e.airborne and (e.pos-root.Position).Magnitude<54 then
   local count=0;for _,other in ipairs(deps.enemies)do if other.hp>0 and (other.pos-e.pos).Magnitude<10 then count+=1 end end
   local score=count*10-(e.pos-root.Position).Magnitude*.05
   if score>best then target,best=e,score end
  end end
  if not target then return end
  local lead=Vector3.zero
  if not target.isBoss and target.kind~='caster'and not target.detonating and(target.frozen or 0)<=0 then
   local delta=Vector3.new(root.Position.X-target.pos.X,0,root.Position.Z-target.pos.Z)
   if delta.Magnitude>.01 then lead=delta.Unit*math.min(math.max(0,delta.Magnitude-3),(target.speed or 0)*1.3)end
  end
  local predicted=target.pos+lead;local point=Vector3.new(predicted.X,.35,predicted.Z)
  -- A ceiling blocks this sky spell; it never damages through an overhead wall.
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={deps.world,s.player.Character};ray.RespectCanCollide=true
  if workspace:Raycast(point+Vector3.new(0,3,0),Vector3.new(0,55,0),ray)then s.skyLancesClock=1;return end
  nextId+=1;local a=Instance.new('Part');a.Name='SkyLanceCast_'..nextId;a.Size=Vector3.one*.1;a.Transparency=1;a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.Position=point
  a:SetAttribute('Level',level);a:SetAttribute('Elapsed',0);a:SetAttribute('Duration',2.65);a:SetAttribute('Radius',8.3);a.Parent=deps.world
  local c={source=s,anchor=a,time=0,level=level,lances={}}
  for _,offset in ipairs(offsets)do local p=point+offset;table.insert(c.lances,{point=p,last=p+Vector3.new(0,44,0),hits={}})end
  table.insert(casts,c);s.skyLancesClock=11-level*.4
  deps.effect:FireAllClients('areaCast',a.Name,'skyLances')
 end
 return {Step=step,Clear=clear}
end
