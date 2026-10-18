-- Narrow falling lances: server-time flight and one hit per enemy per lance.
local A=require(script.Parent.Parent.flow.Augments)
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
       if (e.pos-lance.last-delta*t).Magnitude<=3.3 then lance.hits[e]=true;local empowered=A.Damage(s,"skyLances",1,e)>1;deps.damage(e,A.Damage(s,"skyLances",25+c.level*8,e),s);if empowered then A.Impact(deps.effect,s,"skyLances",e.pos,3.3,"hit",true)end end
      end end
      if u>=1 then lance.done=true;deps.effect:FireAllClients('skyLanceHit',lance.point,3.3)end
     end
     lance.last=tip
    end
    if c.time>=c.duration then c.anchor:Destroy();table.remove(casts,i)end
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
  if not target.isBoss and not target.isFieldBoss and(target.role or target.kind)~='caster'and not target.detonating and(target.frozen or 0)<=0 then
   local delta=Vector3.new(root.Position.X-target.pos.X,0,root.Position.Z-target.pos.Z)
   if delta.Magnitude>.01 then lead=delta.Unit*math.min(math.max(0,delta.Magnitude-3),(target.speed or 0)*1.3)end
  end
  local predicted=target.pos+lead;local point=Vector3.new(predicted.X,.35,predicted.Z)
  -- A ceiling blocks this sky spell; it never damages through an overhead wall.
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={deps.world,s.player.Character};ray.RespectCanCollide=true
  if workspace:Raycast(point+Vector3.new(0,3,0),Vector3.new(0,55,0),ray)then s.skyLancesClock=1;return end
  nextId+=1;local a=Instance.new('Part');a.Name='SkyLanceCast_'..nextId;a.Size=Vector3.one*.1;a.Transparency=1;a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.Position=point
  local count=A.Has(s,'skyLances_rain')and 7 or 5;local duration=2.65+(count-5)*.16
  a:SetAttribute('Count',count);a:SetAttribute('Level',level);a:SetAttribute('Elapsed',0);a:SetAttribute('Duration',duration);a:SetAttribute('Radius',8.3);A.Stamp(a,s,"skyLances");a.Parent=deps.world
  local c={source=s,anchor=a,time=0,level=level,lances={},duration=duration}
  local positions=table.clone(offsets);if count==7 then table.insert(positions,Vector3.new(3.5,0,3.5));table.insert(positions,Vector3.new(-3.5,0,-3.5))end
  for _,offset in ipairs(positions)do local p=point+offset;table.insert(c.lances,{point=p,last=p+Vector3.new(0,44,0),hits={}})end
  table.insert(casts,c);s.skyLancesClock=A.Cooldown(s,11-level*.4)
  deps.effect:FireAllClients('areaCast',a.Name,'skyLances')
 end
 return {Step=step,Clear=clear}
end
