-- Run in a NEW, empty Studio project's Command Bar, in edit mode.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installing")
assert(not workspace:FindFirstChild("SummonerArena"), "SummonerArena already exists; installation cancelled")
assert(not game.ReplicatedStorage:FindFirstChild("SummonerNet"), "SummonerNet already exists; installation cancelled")
assert(not game.ServerScriptService:FindFirstChild("SummonerServer"), "SummonerServer already exists; installation cancelled")
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("SummonerClient"), "SummonerClient already exists; installation cancelled");
assert(not game.ReplicatedStorage:FindFirstChild("EmberDragonModel"), "EmberDragonModel already exists; installation cancelled")
assert(not game.ServerScriptService:FindFirstChild("WardenPreview"), "WardenPreview already exists; installation cancelled")
assert(not workspace:FindFirstChild("RiftWardenPreview"), "RiftWardenPreview already exists; installation cancelled");
(function()
-- Run in Studio edit mode. Only creates the prototype's own arena.
local Lighting = game:GetService("Lighting")
local arena = Instance.new("Folder")
arena.Name = "SummonerArena"
local function part(name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Slate
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = arena
	return p
end
local floor = part("ArenaFloor", Vector3.new(186, 3, 186), CFrame.new(0,-1.5,0), Color3.fromRGB(38,51,55))
local base = workspace:FindFirstChild("Baseplate")
if base then base.Transparency = 1; base.CanCollide = false end
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then spawn.Position=Vector3.new(0,0.5,0); spawn.Transparency=1; spawn.CanCollide=false; spawn.Neutral=true; spawn.Duration=0 end
for i=1,48 do
	local a=i*math.pi*2/48
	local cf=CFrame.new(math.cos(a)*88, 2.5, math.sin(a)*88)*CFrame.Angles(0,-a,0)
	part("BoundaryStone",Vector3.new(6,5+(i%3),5),cf,Color3.fromRGB(51,65,69))
	if i%4==0 then
		local p=part("RuneLantern",Vector3.new(1.5,1.5,1.5),cf*CFrame.new(0,4,0),Color3.fromRGB(72,232,205),Enum.Material.Neon)
		p.CanCollide=false
		local light=Instance.new("PointLight"); light.Color=p.Color; light.Range=18; light.Brightness=1.3; light.Parent=p
	end
end
for i=1,40 do
	local a=i*math.pi*2/40
	local p=part("SummoningCircle",Vector3.new(2.4,0.04,0.16),CFrame.new(math.cos(a)*10,0.035,math.sin(a)*10)*CFrame.Angles(0,-a-math.pi/2,0),Color3.fromRGB(64,133,127),Enum.Material.Neon)
	p.CanCollide=false
end
for i=1,28 do
	local a=i*2.39996; local radius=24+(i%6)*9
	local p=part("OldPaving",Vector3.new(5+i%3,0.06,4),CFrame.new(math.cos(a)*radius,0.04,math.sin(a)*radius)*CFrame.Angles(0,a,0),Color3.fromRGB(46,61,64))
	p.CanCollide=false
end
for _,edge in ipairs({{0,94,190,4},{0,-94,190,4},{94,0,4,190},{-94,0,4,190}}) do
	local p=part("InvisibleBoundary",Vector3.new(edge[3],30,edge[4]),CFrame.new(edge[1],12,edge[2]),Color3.new())
	p.Transparency=1
end
arena.Parent=workspace
Lighting.ClockTime=14.5
Lighting.Brightness=2
Lighting.Ambient=Color3.fromRGB(135,151,166)
Lighting.OutdoorAmbient=Color3.fromRGB(145,163,175)
Lighting.FogColor=Color3.fromRGB(44,65,75)
Lighting.FogStart=140; Lighting.FogEnd=350
local atmosphere=Instance.new("Atmosphere")
atmosphere.Density=0.22; atmosphere.Color=Color3.fromRGB(164,191,191); atmosphere.Decay=Color3.fromRGB(62,82,99); atmosphere.Parent=Lighting
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(0,95,80),Vector3.new(0,0,0))
return "SummonerArena created"

end)()
local folder=Instance.new("Folder"); folder.Name="SummonerNet"
for _,name in ipairs({"State","Action","Effect"}) do local r=Instance.new("RemoteEvent"); r.Name=name; r.Parent=folder end
folder.Parent=game.ReplicatedStorage
-- Optional public mesh. Built-in dust and procedural debris work if import is unavailable.
do
    local ok, model = pcall(function() return game:GetService("InsertService"):LoadAsset(12192129638) end)
    if ok and model then
        local source = model:FindFirstChild("GroundSpikes", true)
        if source and source:IsA("MeshPart") and not game.ReplicatedStorage:FindFirstChild("SummonerVFXAssets") then
            local folder = Instance.new("Folder"); folder.Name = "SummonerVFXAssets"
            local mesh = source:Clone(); mesh:ClearAllChildren(); mesh.Name = "GroundSpikes"
            mesh.Anchored = true; mesh.CanCollide = false; mesh.CanTouch = false; mesh.CanQuery = false; mesh.CastShadow = false
            mesh:SetAttribute("Source", "https://create.roblox.com/store/asset/12192129638")
            mesh:SetAttribute("Creator", "clotuder"); mesh:SetAttribute("Terms", "Roblox Creator Store Terms; not CC0")
            mesh.Parent = folder; folder.Parent = game.ReplicatedStorage
        end
        model:Destroy()
    end
end

-- Generated below. Edit src/ and entrypoints, then rebuild.
local function addModule(parent, path, source)
    for i=1,#path-1 do
        local folder=parent:FindFirstChild(path[i])
        if not folder then folder=Instance.new("Folder");folder.Name=path[i];folder.Parent=parent end
        parent=folder
    end
    local module=Instance.new("ModuleScript")
    module.Name=path[#path];module.Source=source;module.Parent=parent
end
local extra=Instance.new("ModuleScript");extra.Name="EmberDragonModel";extra.Source=[====[
-- Server hit anchor for the CC0 Cethiel/Drummyfish dragon, rendered on each client.
local Dragon={}
function Dragon.create(parent,cf)
 local model=Instance.new('Model');model.Name='EmberDragon';model:SetAttribute('DisplayName','흑염룡 · 아그니스');model:SetAttribute('IsBoss',true);model:SetAttribute('Animation','idle')
 local root=Instance.new('Part');root.Name='Root';root.Size=Vector3.new(7,9,15);root.CFrame=cf;root.Anchored=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Transparency=1;root.Parent=model;model.PrimaryPart=root;model.Parent=parent
 return {model=model,root=root,origin=cf}
end
function Dragon.pose(rig,t,attack,progress,phase)
 rig.root.CFrame=rig.origin
 rig.model:SetAttribute('Animation',attack or'idle')
 rig.model:SetAttribute('PoseProgress',progress or 0)
 rig.model:SetAttribute('DragonPhase',phase or 1)
end
return Dragon
]====];extra.Parent=game.ReplicatedStorage

do
local entry=Instance.new("Script")
entry.Name="SummonerServer"
entry.Source=[====[
-- Composition root. Feature behavior lives in src/server; see docs/ARCHITECTURE.md.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local modules = script:WaitForChild("Modules")
local net = RS:WaitForChild("SummonerNet")
Players.CharacterAutoLoads = false
local world = Instance.new("Folder")
world.Name = "SummonerRuntime"
world.Parent = workspace
local states, enemies, gems = {}, {}, {}
local rng = Random.new()
local clock = {elapsed = 0, roundLength = script:GetAttribute("BossSpawnAt") or 120, bossElapsed = 0, phase = "survival"}
local actors = require(modules.shared.Actors)({world = world})
local players = require(modules.shared.PlayerState)({states = states})
local movement = require(modules.combat.Movement)({
    world = world, rootOf = players.RootOf, paused = players.Paused, effect = net.Effect,
})
local progression = require(modules.flow.Progression)({
    world = world, states = states, gems = gems, rng = rng, block = actors.Block,
    rootOf = players.RootOf, paused = players.Paused, finishDash = movement.FinishDash,
    update = net.State, clock = clock, spellOptions = require(modules.flow.Loadout).Options, activeOptions = require(modules.flow.Loadout).ActiveOptions,
})
local combat = require(modules.combat.Combat)({
    world = world, enemies = enemies, rng = rng, block = actors.Block,
    rootOf = players.RootOf, paused = players.Paused, effect = net.Effect, drop = progression.Drop,
})
local waves = require(modules.world.Waves)({
    states = states, enemies = enemies, rng = rng, creature = actors.Create,
    rootOf = players.RootOf, roundLength = clock.roundLength, clock = clock, world = world, effect = net.Effect, drop = progression.Drop,
})
local lobbySpawn=require(modules.world.LobbyWorld)()
local boss
local session = require(modules.flow.Session)({
    world = world, states = states, enemies = enemies, gems = gems, rng = rng,
    creature = actors.Create, finishDash = movement.FinishDash,
    clearIceShots = combat.ClearProjectiles, sync = progression.Sync,
    clock = clock, lobbySpawn=lobbySpawn, resetSpawn = waves.ResetSpawn, resetBoss = function() if boss then boss.Reset() end end,
})
boss = require(modules.world.Boss)({
    world = world, enemies = enemies, states = states, clock = clock,
    rootOf = players.RootOf, effect = net.Effect, drop = progression.Drop,
    modelFactory = require(RS:WaitForChild("EmberDragonModel")), endPlayer = session.EndPlayer, clearEnemyShots = waves.ResetSpawn,
})
net.Action.OnServerEvent:Connect(function(player,kind,id,activeId)
    local s = states[player]
    if not s then return end
    if kind == "ready" then progression.Sync(s); return end
    if kind == "previewDragon" then
        if not RunService:IsStudio() or type(id) ~= "boolean" then return end
        s.previewDragon=id
        if id then movement.FinishDash(s) end
        progression.Sync(s)
        return
    end
    if kind == "previewSkills" then
        if not RunService:IsStudio() or type(id) ~= "boolean" then return end
        s.previewSkills=id
        if id then movement.FinishDash(s) end
        progression.Sync(s)
        return
    end
    if s.previewDragon or s.previewSkills then return end
    if kind == "startRound" then session.StartRound(s,id,activeId); return end
    if kind == "cancelReady" then session.CancelReady(s); return end
    if s.lobby then return end
    if kind == "restart" then if s.over then session.Restart() end; return end
    if s.over then return end
    if kind == "choose" then progression.Choose(s,id)
    elseif kind == "dash" then
        if movement.RequestDash(s,id) then progression.Sync(s) end
    elseif kind == "fireWave" then
        if combat.RequestWave(s,id) then progression.Sync(s) end
    end
end)
Players.PlayerAdded:Connect(function(p) task.spawn(session.AddPlayer,p) end)
Players.PlayerRemoving:Connect(session.RemovePlayer)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(session.AddPlayer,p) end

local tickClock, sendClock = 0, 0
RunService.Heartbeat:Connect(function(dt)
    tickClock += dt
    if tickClock < .05 then return end
    dt = math.min(tickClock,.15)
    tickClock = 0
    local alive = players.LiveCount()
    if alive > 0 and not players.Paused() then
        clock.elapsed += dt
        boss.Step(dt)
        -- Keep the prototype's simulation order; changing it can change hits and XP timing.
        waves.Spawn(dt,alive,clock.elapsed)
        for _,s in pairs(states) do movement.Step(s,dt) end
        combat.StepProjectiles(dt)
        waves.Step(dt)
        for _,s in pairs(states) do
            local r = players.RootOf(s)
            if r then
                local flat = Vector3.new(r.Position.X,0,r.Position.Z)
                if flat.Magnitude > 82 then r.CFrame=CFrame.new(flat.Unit*81+Vector3.new(0,r.Position.Y,0)) end
                if r.Position.Y < -10 then session.EndPlayer(s,"defeat") end
                combat.StepPlayer(s,r,dt)
            end
        end
        progression.Collect(dt)
        boss.Resolve()
    end
    sendClock += dt
    if sendClock >= .2 then
        sendClock = 0
        for _,s in pairs(states) do progression.Sync(s) end
    end
end)
print("[Summoner] Survival server ready")
]====]
local modules=Instance.new("Folder");modules.Name="Modules";modules.Parent=entry
-- Source: src/server/combat/ActiveSpells.luau
addModule(modules,{"combat","ActiveSpells"},[====[
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
]====])
-- Source: src/server/combat/ArcaneCrystals.luau
addModule(modules,{"combat","ArcaneCrystals"},[====[
-- Five stored crystals launch separately, then recharge on the server clock.
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
  local aura=auras[s]
  if aura and aura.level~=level then aura.anchor:Destroy();auras[s]=nil;aura=nil end
  if not aura then
   nextId+=1;local anchor=Instance.new('Part');anchor.Name='CrystalAura_'..nextId;anchor.Size=Vector3.one*.1;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=root.CFrame
   anchor:SetAttribute('Radius',2);anchor:SetAttribute('Duration',1000000);anchor:SetAttribute('Elapsed',0);anchor:SetAttribute('Level',level);anchor.Parent=deps.world
   aura={anchor=anchor,time=0,index=0,level=level,recharge=0};auras[s]=aura;deps.effect:FireAllClients('areaCast',anchor.Name,'blades')
  end
  aura.time+=dt;aura.anchor.CFrame=root.CFrame;aura.anchor:SetAttribute('Elapsed',aura.time);aura.anchor:SetAttribute('Level',level)
  aura.recharge=math.max(0,aura.recharge-dt)
  if aura.recharge>0 then return end
  if aura.index>=5 then aura.index=0;aura.anchor:SetAttribute('Fired',0)end
  s.crystalClock=math.max(0,(s.crystalClock or 0)-dt);if s.crystalClock>0 then return end
  local candidates={}
  for _,e in ipairs(deps.enemies)do if e.hp>0 and (e.pos-root.Position).Magnitude<48 then table.insert(candidates,e)end end
  table.sort(candidates,function(a,b)return (a.pos-root.Position).Magnitude<(b.pos-root.Position).Magnitude end)
  if #candidates==0 then return end
  aura.index+=1
  local target=candidates[(aura.index-1)%math.min(5,#candidates)+1]
  local pos=muzzle(root.CFrame,aura.index,5);local delta=target.pos-pos;if delta.Magnitude<.01 then delta=root.CFrame.LookVector end
  nextId+=1;local anchor=Instance.new('Part');anchor.Name='CrystalBolt_'..nextId;anchor.Size=Vector3.one*.1;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=CFrame.lookAt(pos,pos+delta);anchor.Parent=deps.world
  s.crystalClock=.18
  aura.anchor:SetAttribute('Fired',aura.index)
  if aura.index==5 then aura.recharge=4.4-level*.35;s.crystalClock=0 end
  table.insert(shots,{source=s,level=level,anchor=anchor,time=0,direction=delta.Unit,target=target})
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
    local hit,best=nil,math.huge
    for _,e in ipairs(deps.enemies)do if e.hp>0 then local d,t=segmentDistance(e.pos,from,to);if d<=1.3 and t<best then hit,best=e,t end end end
    if hit then deps.damage(hit,10+shot.level*4,shot.source);deps.effect:FireAllClients('crystalHit',hit.pos);remove=true
    elseif wall or shot.time>=2 then remove=true
    else shot.anchor.CFrame=CFrame.lookAt(to,to+shot.direction)end
   end
   if remove then if shot.anchor.Parent then shot.anchor:Destroy()end;table.remove(shots,i)end
  end
 end
 return {StepPlayer=stepPlayer,Step=step,Clear=clear}
end
]====])
-- Source: src/server/combat/AreaSpells.luau
addModule(modules,{"combat","AreaSpells"},[====[
-- All spell timing and damage belong to the shared server simulation clock.
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
  s.areaCasts={};s.shield=0
 end
 local function start(s,kind,point,level)
  local radius=kind=='meteor' and 14+level or(kind=='frost' and 12+level or(kind=='blades' and 11+level*.7 or 4))
  local duration=kind=='meteor' and 3.2 or(kind=='frost' and .75 or(kind=='blades' and 6 or 5))
  nextCast+=1
  local anchor=Instance.new('Part');anchor.Name='AreaCast_'..nextCast;anchor:SetAttribute('Kind',kind);anchor.Size=Vector3.one*.1;anchor.Position=point;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false
  anchor:SetAttribute('Elapsed',0);anchor:SetAttribute('Radius',radius);anchor:SetAttribute('Duration',duration);anchor:SetAttribute('Level',level)
  if kind=='ward' then s.shield=30+level*12 end
  anchor.Parent=world
  table.insert(s.areaCasts,{kind=kind,pos=point,level=level,radius=radius,duration=duration,time=0,hits={},anchor=anchor})
  effect:FireAllClients('areaCast',anchor.Name,kind)
 end
 local function hit(cast,s,amount)
  for _,e in ipairs(enemies)do
   if e.hp>0 and not e.airborne and flat(e.pos-cast.pos).Magnitude<=cast.radius then
    deps.damage(e,amount,s)
    if cast.kind=='frost' and e.hp>0 then
     e.slow=math.max(e.slow or 0,2.5)
     if not e.isBoss then e.frozen=math.max(e.frozen or 0,.8+cast.level*.2);e.model:SetAttribute('Frozen',true)end
    end
   end
  end
 end
 local function step(s,root,dt)
  s.areaCasts=s.areaCasts or {}
  for i=#s.areaCasts,1,-1 do
   local cast=s.areaCasts[i];cast.time+=dt
   if cast.kind~='meteor' then cast.pos=Vector3.new(root.Position.X,.35,root.Position.Z);cast.anchor.Position=cast.pos end
   cast.anchor:SetAttribute('Elapsed',cast.time)
   local done=cast.time>=cast.duration or(cast.kind=='ward' and (s.shield or 0)<=0)
   if done then
    if cast.kind=='meteor' or cast.kind=='frost' then
     hit(cast,s,cast.kind=='meteor' and 65+cast.level*22 or 18+cast.level*8)
     effect:FireAllClients(cast.kind=='meteor' and 'meteorHit' or 'frostHit',cast.pos,cast.radius)
    elseif cast.kind=='ward' then s.shield=0 end
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
      point=nil;for _,e in ipairs(enemies)do if e.hp>0 and not e.airborne and flat(e.pos-root.Position).Magnitude<=12+level then point=e.pos;break end end
     end
     if point then
      start(s,kind,kind=='meteor' and point or Vector3.new(root.Position.X,.35,root.Position.Z),level)
      s[key]=(kind=='meteor' and 9 or(kind=='blades' and 8.5 or(kind=='frost' and 6 or 12)))-level*.3
     end
    end
   end
  end
 end
 return {Step=step,Clear=clear}
end
]====])
-- Source: src/server/combat/Combat.luau
addModule(modules,{"combat","Combat"},[====[
-- Automatic spells, ice projectiles, summon AI and damage. No client-owned damage.
return function(deps)
	local world, enemies, rng = deps.world, deps.enemies, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local effect, drop = deps.effect, deps.drop
	local iceShots = {}
	local nextIceShot = 0
	local areaSpells,activeSpells,missiles,crystals,skyLances
	-- Temporary visual preview: all golems show the final-tier presentation.
	-- Damage, fragment damage and extra damage hits still use the actual upgrade level.
	local PREVIEW_MAX_GOLEM_EFFECTS = true

	local function damage(e,amount,s)
		if e.hp<=0 then return end
		e.hp-=amount
		e.model:SetAttribute("HP",math.max(0,e.hp))
		effect:FireAllClients("hit",e.pos,amount)
		if e.hp<=0 then
			s.kills+=1
			if not e.isBoss then drop(e.pos);if e.elite then drop(e.pos+Vector3.new(1,0,0));drop(e.pos-Vector3.new(1,0,0))end; e.model:Destroy() end
		end
	end
	areaSpells=require(script.Parent.AreaSpells)({world=world,enemies=enemies,effect=effect,damage=damage})
	activeSpells=require(script.Parent.ActiveSpells)({world=world,enemies=enemies,effect=effect,damage=damage})
	missiles=require(script.Parent.HomingMissiles)({world=world,enemies=enemies,effect=effect,damage=damage,rootOf=rootOf})
	crystals=require(script.Parent.ArcaneCrystals)({world=world,enemies=enemies,effect=effect,damage=damage,rootOf=rootOf})
	skyLances=require(script.Parent.SkyLances)({world=world,enemies=enemies,effect=effect,damage=damage})
	local function nearest(pos,range)
		local found,dist=nil,range
		for _,e in ipairs(enemies) do if e.hp>0 then local d=(e.pos-pos).Magnitude; if d<dist then found,dist=e,d end end end
		return found
	end
	local function clearIceShots(source)
		missiles.Clear(source);crystals.Clear(source);skyLances.Clear(source)
		if source then areaSpells.Clear(source);activeSpells.Clear(source) end
		for i=#iceShots,1,-1 do
			local shot=iceShots[i]
			if not source or shot.source==source then shot.anchor:Destroy();table.remove(iceShots,i) end
		end
	end
	local function castIceSpear(s,root,target)
		local delta=Vector3.new(target.pos.X-root.Position.X,0,target.pos.Z-root.Position.Z)
		local forward=delta.Magnitude>.01 and delta.Unit or Vector3.new(0,0,-1)
		local portalPos=root.Position+forward*3.5+Vector3.new(0,1.2,0)
		local portal=CFrame.lookAt(portalPos,portalPos+forward)
		nextIceShot+=1
		local anchor=block(world,"IceSpearAnchor_"..nextIceShot,Vector3.new(.1,.1,.1),portalPos,Color3.fromRGB(170,237,255))
		anchor.Transparency=1;anchor.CFrame=portal
		anchor:SetAttribute("Launched",false)
		table.insert(iceShots,{source=s,target=target,anchor=anchor,time=0,charge=.42,speed=36,level=s.ice})
		effect:FireAllClients("iceCast",anchor.Name,portal,.42)
	end
	local function advanceIceSpears(dt)
		for i=#iceShots,1,-1 do
			local shot=iceShots[i]
			local alive=rootOf(shot.source)
			local remove=not alive or not shot.anchor.Parent
			if not remove and not shot.source.offers then
				shot.time+=dt
				if shot.target.hp<=0 then shot.target=nearest(shot.anchor.Position,46) end
				if not shot.target or shot.time>2.8 then remove=true
				elseif shot.time>=shot.charge then
					shot.anchor:SetAttribute("Launched",true)
					local travelDt=math.min(dt,shot.time-shot.charge)
					local delta=shot.target.pos-shot.anchor.Position
					local step=shot.speed*travelDt
					if delta.Magnitude<=step+1 then
						local target=shot.target;local pos=target.pos
						local duration=.55+shot.level*.1
						duration=target.isBoss and 0 or duration
						target.frozen=math.max(target.frozen or 0,duration)
						target.slow=math.max(target.slow,2+shot.level*.4)
						target.model:SetAttribute("Frozen",duration>0)
						damage(target,10+shot.level*8,shot.source)
						if target.hp>0 and not target.isBoss then
							local forward=shot.anchor.CFrame.LookVector
							local flat=Vector3.new(forward.X,0,forward.Z)
							if flat.Magnitude>.01 then target.knockback=flat.Unit*34;target.knockTime=.23 end
						end
						effect:FireAllClients("iceHit",target.hp>0 and target.model or nil,pos,duration)
						remove=true
					else
						local move=delta.Unit*step
						local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={world,shot.source.player.Character};params.RespectCanCollide=true
						local hit=workspace:Raycast(shot.anchor.Position,move,params)
						if hit then effect:FireAllClients("iceHit",nil,hit.Position,.4);remove=true
						else shot.anchor.CFrame=CFrame.lookAt(shot.anchor.Position+move,shot.target.pos) end
					end
				end
			end
			if remove then if shot.anchor.Parent then shot.anchor:Destroy() end;table.remove(iceShots,i) end
		end
	end
	local function blast(pos,radius,amount,s,knock,slow)
		for _,e in ipairs(enemies) do
			if e.hp>0 and (e.pos-pos).Magnitude<=radius then
				damage(e,amount,s)
				if e.hp>0 then
					if slow then e.slow=math.max(e.slow,slow) end
					if knock and knock>0 and not e.isBoss then
						local dir=Vector3.new(e.pos.X-pos.X,0,e.pos.Z-pos.Z)
						if dir.Magnitude>.01 then e.pos+=dir.Unit*knock end
						local flat=Vector3.new(e.pos.X,0,e.pos.Z)
						if flat.Magnitude>82 then e.pos=flat.Unit*82+Vector3.new(0,e.pos.Y,0) end
					end
				end
			end
		end
	end
	local function beginGolemAttack(s,heavy,repeatStrike)
		if heavy and not repeatStrike then s.petHeavyCooldown=9; s.petSlamTarget=nil; s.petSlamPoint=nil end
		s.petHand=not s.petHand
		s.petAttack={time=0,heavy=heavy,windup=heavy and (repeatStrike and .3 or .65) or .3,hit=false,hand=s.petHand,repeatStrike=repeatStrike,visualOnly=repeatStrike and PREVIEW_MAX_GOLEM_EFFECTS and s.golem<5}
		if heavy then effect:FireAllClients("golemCharge",s.pet,s.petAttack.windup) end
		s.golemClock=heavy and 1.8 or 1.5
	end
	local function planGolemSlam(s,ownerPos,petPos,dt)
		s.petHeavyCooldown=math.max(0,(s.petHeavyCooldown or 0)-dt)
		if s.petHeavyCooldown>0 or s.petReturning then s.petSlamTarget=nil; s.petSlamPoint=nil; return end
		if s.petAttack then return end
		s.petScanClock=(s.petScanClock or 0)-dt
		if s.petScanClock>0 then return end
		s.petScanClock=.35
		local danger=0
		for _,e in ipairs(enemies) do if e.hp>0 and (e.pos-ownerPos).Magnitude<10 then danger+=1 end end
		local best,bestPoint,bestScore=nil,nil,-math.huge
		local radius=(11+s.golem)*.75
		for _,candidate in ipairs(enemies) do
			local ownerDistance=(candidate.pos-ownerPos).Magnitude
			local petDistance=(candidate.pos-petPos).Magnitude
			if candidate.hp>0 and ownerDistance<44 and petDistance<32 then
				local count,total=0,Vector3.zero
				for _,e in ipairs(enemies) do
					if e.hp>0 and (e.pos-candidate.pos).Magnitude<radius then count+=1; total+=e.pos end
				end
				local emergency=danger>=3 and ownerDistance<12
				if count>=3 or emergency or candidate.model:GetAttribute("IsBoss")==true then
					local score=count*100-petDistance-ownerDistance*.2+(emergency and 200 or 0)+(candidate==s.petSlamTarget and 20 or 0)
					if score>bestScore then best,bestPoint,bestScore=candidate,total/count,score end
				end
			end
		end
		s.petSlamTarget=best
		s.petSlamPoint=bestPoint and Vector3.new(bestPoint.X,3.6,bestPoint.Z) or nil
	end
	local function poseGolem(s)
		local pivot=s.pet:GetPivot()
		local attack=s.petAttack
		local raised,impact=0,0
		if attack then
			local t=attack.time
			if t<attack.windup then
				raised=math.clamp(t/attack.windup,0,1)
			elseif t<attack.windup+.12 then
				impact=math.clamp((t-attack.windup)/.12,0,1); raised=1-impact
			else
				impact=1-math.clamp((t-attack.windup-.12)/.38,0,1)
			end
		end
		for part,rest in pairs(s.petRig) do
			if part.Parent and part~=s.pet.PrimaryPart then
				local cf=rest
				if part.Name=="LeftArm" or part.Name=="RightArm" then
					local active=attack and (attack.heavy or (attack.hand and part.Name=="RightArm") or (not attack.hand and part.Name=="LeftArm"))
					if active then
						local side=part.Name=="LeftArm" and -1 or 1
						local raisedPose=CFrame.new(side*2.1,3.3,-.65)*CFrame.Angles(math.rad(155),0,side*math.rad(-12))
						local impactPose=CFrame.new(side*(attack.heavy and 1.7 or 2),-1.7,-2.1)*CFrame.Angles(math.rad(25),0,0)
						cf=rest:Lerp(raisedPose,raised):Lerp(impactPose,impact)
					end
				elseif part.Name=="Head" then cf=rest*CFrame.new(0,-impact*.35,0) end
				part.CFrame=pivot*cf
			end
		end
		local rune=s.pet:FindFirstChild("Rune")
		if rune then rune.Color=attack and attack.heavy and Color3.fromRGB(255,204,104) or Color3.fromRGB(96,255,222) end
		s.pet:SetAttribute("AttackPhase",attack and (attack.hit and "Recover" or "Windup") or "Idle")
	end
	local function advanceGolemAttack(s,dt)
		local attack=s.petAttack
		if not attack then return end
		attack.time+=dt
		-- Resolve the hit when the fist reaches the ground, on the simulation clock.
		if not attack.hit and attack.time>=attack.windup+.12 then
			attack.hit=true
			local pivot=s.pet:GetPivot()
			local pos=pivot.Position+(attack.heavy and Vector3.zero or pivot.LookVector*2.5)
			local radius=attack.heavy and 11+s.golem or 4+s.golem*.5
			local effectLevel=PREVIEW_MAX_GOLEM_EFFECTS and 5 or s.golem
			local effectRadius=attack.heavy and 11+effectLevel or 4+effectLevel*.5
			effect:FireAllClients(attack.heavy and "golemHeavy" or "golemLight",pos,effectRadius,effectLevel)
			if not attack.visualOnly then blast(pos,radius,attack.heavy and 22+s.golem*10 or 12+s.golem*8,s,attack.heavy and 10 or nil,attack.heavy and 2 or nil) end
			if attack.heavy and s.golem>=3 and not attack.visualOnly then
				for i=1,6 do
					local a=i*math.pi/3
					local fragment=pos+Vector3.new(math.cos(a),0,math.sin(a))*radius*.75
					blast(fragment,2.8,8+s.golem*2,s,nil,1)
				end
			end
			s.pet:SetAttribute("LastImpactPosition",pos)
			s.pet:SetAttribute("LastImpactHeavy",attack.heavy)
			s.pet:SetAttribute("ImpactCount",(s.pet:GetAttribute("ImpactCount") or 0)+1)
		end
		if attack.time>=attack.windup+.5 then
			if attack.heavy and (s.golem>=5 or PREVIEW_MAX_GOLEM_EFFECTS) and not attack.repeatStrike then beginGolemAttack(s,true,true)
			else s.petAttack=nil end
		end
	end
	local function requestWave(s,aim)
		if s.over or s.cooldown>0 or s.offers or paused() then return end
		local root=rootOf(s); if not root then return end
		local origin=root.Position
		local facing=root.CFrame.LookVector
        if aim~=nil then
            if typeof(aim)~="Vector3" or aim.X~=aim.X or aim.Z~=aim.Z or math.abs(aim.X)>10000 or math.abs(aim.Z)>10000 then return end
            facing=aim
        end
        local direction=Vector3.new(facing.X,0,facing.Z)
		if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
		if s.activeSkill and s.activeSkill~="fireWave" then return activeSpells.Request(s,origin,direction) end
		s.cooldown=7
		effect:FireAllClients("fireWave",origin,direction,30)
		for _,e in ipairs(enemies) do
			local delta=Vector3.new(e.pos.X-origin.X,0,e.pos.Z-origin.Z)
			local distance=delta.Magnitude
			if e.hp>0 and not e.airborne and distance<=30 and (distance<.1 or delta.Unit:Dot(direction)>=math.cos(math.rad(35))) then
				damage(e,40+s.fire*10,s)
				if e.hp>0 then
					if not e.isBoss then e.pos+=direction*5 end; e.slow=math.max(e.slow,.7)
					local flat=Vector3.new(e.pos.X,0,e.pos.Z)
					if flat.Magnitude>82 then e.pos=flat.Unit*82+Vector3.new(0,e.pos.Y,0) end
				end
			end
		end
		return true
	end
	local function stepPlayer(s,r,dt)
		-- The golem commits to its own target instead of staying at an owner offset.
		local old=s.pet:GetPivot().Position
		local ownerPos=Vector3.new(r.Position.X,3.6,r.Position.Z)
		local ownerDistance=(old-ownerPos).Magnitude
		if ownerDistance>52 then s.petReturning=true; s.petTarget=nil end
		if s.petReturning and ownerDistance<10 then s.petReturning=false end
		if not s.offers then planGolemSlam(s,ownerPos,old,dt) end
		if s.petSlamTarget and s.petSlamTarget.hp<=0 then s.petSlamTarget=nil; s.petSlamPoint=nil; s.petScanClock=0 end
		local petTarget=s.petTarget
		if petTarget and (petTarget.hp<=0 or (petTarget.pos-ownerPos).Magnitude>48) then petTarget=nil end
		if not s.petReturning and not petTarget then
			local best=32
			for _,e in ipairs(enemies) do
				local d=(e.pos-old).Magnitude
				if e.hp>0 and d<best and (e.pos-ownerPos).Magnitude<44 then petTarget=e; best=d end
			end
		end
		s.petTarget=petTarget
		local goal,look,speed
		if s.petSlamPoint and not s.petReturning then
			goal=s.petSlamPoint; look=goal; speed=26
		elseif petTarget then
			local targetPos=Vector3.new(petTarget.pos.X,3.6,petTarget.pos.Z)
			local diff=targetPos-old
			goal=diff.Magnitude>3.5 and targetPos-diff.Unit*3.5 or old
			look=targetPos; speed=24
		elseif s.petReturning or ownerDistance>15 then
			goal=ownerPos+Vector3.new(4,0,3); look=goal; speed=32
			s.petPatrol=nil
		else
			s.petPatrolClock=(s.petPatrolClock or 0)-dt
			if not s.petPatrol or s.petPatrolClock<=0 or (s.petPatrol-ownerPos).Magnitude>16 then
				local a=rng:NextNumber(0,math.pi*2)
				local radius=rng:NextNumber(5,10)
				s.petPatrol=ownerPos+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
				s.petPatrolClock=rng:NextNumber(2,4)
			end
			goal=s.petPatrol; look=goal; speed=9
		end
		local flatGoal=Vector3.new(goal.X,0,goal.Z)
		if flatGoal.Magnitude>82 then goal=flatGoal.Unit*82+Vector3.new(0,3.6,0) end
		local delta=goal-old
		if s.petAttack then speed=0 end
		local pos=delta.Magnitude>.08 and old+delta.Unit*math.min(delta.Magnitude,speed*dt) or old
		local facing=Vector3.new(look.X,pos.Y,look.Z)-pos
		local rotation=s.pet:GetPivot().Rotation
		if facing.Magnitude>.1 then rotation=rotation:Lerp(CFrame.lookAt(Vector3.zero,facing.Unit).Rotation,math.min(1,dt*10)) end
		s.pet:PivotTo(CFrame.new(pos)*rotation)
		s.pet:SetAttribute("Behavior",s.petAttack and (s.petAttack.heavy and "EarthSlam" or "GroundPunch") or (petTarget and "Attack" or (s.petReturning and "Return" or "Patrol")))
		s.cooldown=math.max(0,s.cooldown-dt)
		if not s.offers then
			activeSpells.Step(s,dt)
			missiles.StepPlayer(s,r,dt)
			crystals.StepPlayer(s,r,dt)
			skyLances.Step(s,r,dt)
			areaSpells.Step(s,r,dt)
			s.fireClock-=dt; s.lightningClock-=dt; s.iceClock-=dt; s.golemClock-=dt
			local target=nearest(r.Position,46)
			if target and s.fire>0 and s.fireClock<=0 then
				s.fireClock=math.max(.4,1.05-s.fire*.09)
				effect:FireAllClients("fire",r.Position,target.pos,2.5+s.fire*.6)
				blast(target.pos,2.5+s.fire*.6,15+s.fire*8,s)
			end
			if target and s.lightning>0 and s.lightningClock<=0 then
				s.lightningClock=2; local last=r.Position; local struck={}
				for hop=1,1+s.lightning do
					local hit,range=nil,35
					for _,e in ipairs(enemies) do local d=(e.pos-last).Magnitude; if e.hp>0 and not struck[e] and d<range then hit,range=e,d end end
					if not hit then break end
					struck[hit]=true; effect:FireAllClients("lightning",last,hit.pos,hop); damage(hit,12+s.lightning*7,s); last=hit.pos
				end
			end
			local iceTarget=s.ice>0 and nearest(r.Position,46)
			if iceTarget and s.iceClock<=0 then
				s.iceClock=1.6
				castIceSpear(s,r,iceTarget)
			end
			local slamReady=s.petSlamPoint and (pos-s.petSlamPoint).Magnitude<3 and (s.petHeavyCooldown or 0)<=0
			if slamReady and not s.petAttack then
				beginGolemAttack(s,true)
			elseif petTarget and petTarget.hp>0 and not s.petAttack and not s.petSlamPoint and s.golemClock<=0 and (pos-petTarget.pos).Magnitude<7 then
				beginGolemAttack(s,false)
			end
			advanceGolemAttack(s,dt)
		end
		poseGolem(s)
	end

	return {
		StepPlayer = stepPlayer,
		StepProjectiles = function(dt)advanceIceSpears(dt);missiles.Step(dt);crystals.Step(dt)end,
		ClearProjectiles = clearIceShots,
		RequestWave = requestWave,
	}
end
]====])
-- Source: src/server/combat/HomingMissiles.luau
addModule(modules,{"combat","HomingMissiles"},[====[
-- Single-target pressure. Each projectile hits one enemy; no explosion damage.
return function(deps)
 local shots={};local nextShot=0
 local function target(origin)
  local best,score=nil,-math.huge
  for _,e in ipairs(deps.enemies)do
   local distance=(e.pos-origin).Magnitude
   if e.hp>0 and distance<=58 then
    local value=(e.isBoss and 1000000 or 0)+math.min(e.hp,100000)*4-distance
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
]====])
-- Source: src/server/combat/Movement.luau
addModule(modules,{"combat","Movement"},[====[
-- Server-authoritative dash and movement recovery.
return function(deps)
	local world, rootOf, paused, effect = deps.world, deps.rootOf, deps.paused, deps.effect
	local function finishDash(s)
		if not s.dash then return end
		s.dash=nil
		local char=s.player.Character
		local r=char and char:FindFirstChild("HumanoidRootPart")
		local h=char and char:FindFirstChildOfClass("Humanoid")
		if r then pcall(function() r:SetNetworkOwnershipAuto() end) end
		if h then h.AutoRotate=true;h.WalkSpeed=(s.over or s.offers) and 0 or 22+s.agility*2 end
	end
	local function advanceDash(s,dt)
		s.dashCooldown=math.max(0,(s.dashCooldown or 0)-dt)
		s.invulnerable=math.max(0,(s.invulnerable or 0)-dt)
		local dash=s.dash;if not dash then return end
		local r=rootOf(s)
		if not r or s.offers then finishDash(s);return end
		local step=64*math.min(dt,dash.remaining)
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.player.Character,world};params.RespectCanCollide=true
		local hit=workspace:Blockcast(r.CFrame,Vector3.new(2.8,4,2.8),dash.direction*step,params)
		if hit then step=math.max(0,hit.Distance-.15) end
		local dest=r.Position+dash.direction*step
		local flat=Vector3.new(dest.X,0,dest.Z)
		local boundary=flat.Magnitude>81
		if boundary then dest=flat.Unit*81+Vector3.new(0,dest.Y,0) end
		r.CFrame=CFrame.lookAt(dest,dest+dash.direction)
		r.AssemblyLinearVelocity=Vector3.new(0,r.AssemblyLinearVelocity.Y,0)
		dash.remaining-=dt
		if dash.remaining<=0 or hit or boundary then finishDash(s) end
	end
	local function requestDash(s,id)
		if s.over or (s.dashCooldown or 0)>0 or s.offers or paused() then return end
		local root,h=rootOf(s);if not root then return end
		local facing=root.CFrame.LookVector
		if typeof(id)=="Vector3" and id.X==id.X and id.Z==id.Z and math.abs(id.X)<10000 and math.abs(id.Z)<10000 then facing=id end
		local direction=Vector3.new(facing.X,0,facing.Z)
		if direction.Magnitude<.01 then direction=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
		if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
		s.dashCooldown=3;s.invulnerable=.28;s.dash={direction=direction,remaining=.23}
		h.WalkSpeed=0;h.AutoRotate=false
		pcall(function()root:SetNetworkOwner(nil)end)
		effect:FireAllClients("dash",s.player.Character,.23,direction)
		return true
	end

	return {
		FinishDash = finishDash,
		Step = advanceDash,
		RequestDash = requestDash,
	}
end
]====])
-- Source: src/server/combat/SkyLances.luau
addModule(modules,{"combat","SkyLances"},[====[
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
]====])
-- Source: src/server/flow/Loadout.luau
addModule(modules,{"flow","Loadout"},[====[
-- Public spell descriptions and strict server-side loadout validation.
local options={
 {id='fire',name='화염탄',role='빠른 자동 공격',desc='가까운 적에게 불꽃을 쏘고 작은 폭발을 일으킵니다.',color={255,155,82}},
 {id='ice',name='빙결 얼음창',role='빙결 · 밀치기',desc='마법진에서 얼음창을 쏘아 적을 밀치고 얼립니다.',color={132,218,255}},
 {id='lightning',name='연쇄 번개',role='여러 적 연속 타격',desc='하늘에서 내려꽂힌 번개가 주변 적에게 이어집니다.',color={208,191,255}},
 {id='meteor',name='메테오',role='강력한 광역 폭발',desc='거대한 운석이 하늘에서 낙하해 밀집한 적을 강타합니다.',color={255,188,91}},
 {id='blades',name='비전 결정',role='다섯 결정 · 순차 추적 발사',desc='등 뒤의 결정 5개가 한 발씩 적을 추적한 뒤 다시 충전됩니다.',color={128,255,220}},
 {id='skyLances',name='천공의 창',role='상공 마법진 · 다섯 창 순차 낙하',desc='적 머리 위 마법진에서 긴 마법 창들이 차례로 내려꽂힙니다.',color={172,205,255}},
 {id='frost',name='서리 폭발',role='포위 탈출 · 빙결',desc='몸에서 냉기 파동이 퍼져 가까운 적을 한꺼번에 얼립니다.',color={157,234,255}},
 {id='missile',name='추적 마탄',role='강한 적 하나를 집중 공격',desc='보스와 체력이 높은 적을 우선 추적하는 마탄입니다. 범위 피해는 없습니다.',color={216,159,255}},
 {id='ward',name='수호 결계',role='피해 흡수 · 생존',desc='주기적으로 보호막을 펼칩니다. 흡수량을 다 쓰면 깨집니다.',color={255,223,146}},
}
local allowed={};for _,v in ipairs(options)do allowed[v.id]=true end
local function validate(ids)
 if type(ids)~='table' then return nil end
 local result,seen,count={},{},0
 for key,id in pairs(ids)do
  if type(key)~='number' or key%1~=0 or key<1 or key>3 or type(id)~='string' or not allowed[id] or seen[id] then return nil end
  seen[id]=true;result[key]=id;count+=1
 end
 if count~=3 or not result[1] or not result[2] or not result[3] then return nil end
 return result
end
local activeOptions={
 {id='fireWave',name='화염 파동',desc='정면 부채꼴 · 밀치기 · 7초'},
 {id='thunder',name='뇌창',desc='정면으로 날아가는 번개 창 · 관통 · 7초'},
 {id='aetherLance',name='성운창',desc='아지랑이 빛의 창 · 관통 · 7초'},
 {id='iceRush',name='빙하 쇄도',desc='정면 얼음 기둥 · 빙결 · 7초'},
}
local activeNames={};for _,v in ipairs(activeOptions)do activeNames[v.id]=v.name end
local function validateActive(id)return type(id)=='string' and activeNames[id]~=nil end
return {Options=options,Validate=validate,Defaults={'fire','meteor','blades'},ActiveOptions=activeOptions,ActiveNames=activeNames,ValidateActive=validateActive}
]====])
-- Source: src/server/flow/Progression.luau
addModule(modules,{"flow","Progression"},[====[
-- XP, offers, upgrades and the HUD state packet.
return function(deps)
	local world, states, gems, rng = deps.world, deps.states, deps.gems, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local finishDash, update, clock = deps.finishDash, deps.update, deps.clock
	local spellOptions=deps.spellOptions
	local function need(s) return 5+(s.level-1)*3 end
	local labels={fire="화염탄",lightning="연쇄 번개",ice="빙결 얼음창",golem="골렘",meteor="메테오",blades="비전 결정",frost="서리 폭발",ward="수호 결계",missile="추적 마탄",skyLances="천공의 창"}
	local function choices(s)
		local pool={}
		for _,id in ipairs({"fire","lightning","ice","golem","meteor","blades","frost","ward","missile","skyLances"}) do
			local lv=s[id] or 0
			if lv<5 and (not s.loadout or id=="golem" or table.find(s.loadout,id)) then
				local description
				if id=="fire" then description="피해량 +8 · 폭발 범위 증가"
				elseif id=="lightning" then description=lv==0 and "주변 적을 연결하는 번개를 자동 발사" or "피해량과 연쇄 타격 수 증가"
				elseif id=="meteor" then description=lv==0 and "밀집한 적을 향해 운석 낙하 · 넓은 폭발" or "운석 피해 +18 · 범위 증가 · 대기시간 감소"
				elseif id=="blades" then description="다섯 결정 피해 증가 · 재충전 시간 감소"
				elseif id=="skyLances" then description="낙하 창 피해 증가 · 재사용 대기시간 감소"
				elseif id=="frost" then description="냉기 피해·범위·빙결 시간 증가"
				elseif id=="missile" then description="단일 대상 마탄 피해 증가 · 강화 시 발사 수 증가"
				elseif id=="ward" then description="보호막 흡수량 증가 · 재사용 시간 감소"
				elseif id=="ice" then description=lv==0 and "얼음창 자동 발사 · 적을 밀쳐내고 빙결" or "피해량과 빙결·둔화 지속시간 증가"
				else
					description=lv==2 and "대지 강타에 바위 파편 추가 · 피해와 범위 증가" or (lv==4 and "대지 강타를 두 번 연속 사용 · 피해와 범위 증가" or "내려찍기와 대지 강타의 피해·범위 증가")
				end
				table.insert(pool,{id=id,title=labels[id]..(lv==0 and " 배우기" or " 강화"),desc=description,tag=lv==0 and "새로운 마법" or (id=="golem" and "소환수 강화" or "마법 강화"),level=lv+1})
			end
		end
		local fallback={
			{id="vitality",title="생명의 축복",desc="최대 체력 +15 · 체력 30 회복",tag="생존 강화",level=s.vitality+1},
			{id="agility",title="바람의 발걸음",desc="이동 속도 +2",tag="생존 강화",level=s.agility+1},
			{id="magnet",title="경험치 자석",desc="경험치를 끌어오는 범위 +3",tag="수집 강화",level=s.magnet+1},
		}
		for _,v in ipairs(fallback) do if #pool>=3 then break end; table.insert(pool,v) end
		for i=#pool,2,-1 do local j=rng:NextInteger(1,i); pool[i],pool[j]=pool[j],pool[i] end
		local result={}; for i=1,math.min(3,#pool) do result[i]=pool[i] end
		return result
	end
	local function sync(s)
		local _,h=rootOf(s)
        local remaining=clock.phase=="boss" and math.floor(clock.bossElapsed) or clock.roundLength-math.floor(clock.elapsed)
        local b=clock.boss
		update:FireClient(s.player,{time=math.max(0,remaining),phase=clock.phase,lobby=s.lobby==true,queued=s.queued==true,loadout=s.loadout,spellOptions=s.lobby and spellOptions or nil,activeOptions=s.lobby and deps.activeOptions or nil,activeSkill=s.activeSkill or "fireWave",activeName=s.activeName or "화염 파동",lobbyMessage=s.lobbyMessage,shield=s.shield or 0,boss=b and {name=b.name,hp=math.max(0,b.hp),maxHp=b.maxHp,stage=b.phase,airborne=b.airborne} or nil,level=s.level,xp=s.xp,need=need(s),hp=h and math.ceil(h.Health) or 0,maxHp=h and h.MaxHealth or 100,
			kills=s.kills,fire=s.fire,lightning=s.lightning,ice=s.ice,meteor=s.meteor or 0,blades=s.blades or 0,frost=s.frost or 0,ward=s.ward or 0,missile=s.missile or 0,skyLances=s.skyLances or 0,golem=s.golem,offers=s.offers,over=s.over,result=s.result,cooldown=math.max(0,math.ceil(s.cooldown)),dashCooldown=math.ceil((s.dashCooldown or 0)*10)/10,golemCooldown=math.max(0,math.ceil(s.petHeavyCooldown or 0)),paused=paused()})
	end
	local function levelCheck(s)
		if s.over or s.offers or s.lobby then return end
		if s.xp>=need(s) then
			s.xp-=need(s); s.level+=1; s.offers=choices(s)
			if finishDash then finishDash(s) end
			local _,h=rootOf(s); if h then h.WalkSpeed=0 end
			sync(s)
		end
	end
	local function drop(pos)
		if #gems>=180 then return end
		local p=block(world,"Experience",Vector3.new(.8,.8,.8),Vector3.new(pos.X,1.1,pos.Z),Color3.fromRGB(72,250,212),Enum.Material.Neon)
		p.CFrame*=CFrame.Angles(0,math.pi/4,math.pi/4)
		table.insert(gems,{part=p,pos=p.Position})
	end
	local function choose(s,id)
		if s.over or s.lobby then return end
		if not s.offers or type(id)~="string" then return end
		local valid=false; for _,v in ipairs(s.offers) do if v.id==id then valid=true; break end end
		if not valid then return end
		if id=="vitality" then
			s.vitality+=1; local _,h=rootOf(s); if h then h.MaxHealth+=15; h.Health=math.min(h.MaxHealth,h.Health+30) end
		else s[id]=(s[id] or 0)+1 end
		s.offers=nil
		local _,h=rootOf(s); if h then h.WalkSpeed=22+s.agility*2 end
		levelCheck(s); sync(s)
	end
	local function collect(dt)
        for i=#gems,1,-1 do
            local gem=gems[i]
            local collector=gem.collector
            local r,h
            if collector and states[collector.player]==collector and not collector.offers then r,h=rootOf(collector) end
            if not r then
                collector=nil
                local best=math.huge
                for _,s in pairs(states) do
                    local candidate,humanoid=rootOf(s)
                    if candidate and not s.offers then
                        local delta=candidate.Position-gem.pos
                        local distance=Vector3.new(delta.X,0,delta.Z).Magnitude
                        if distance<18+s.magnet*3 and distance<best then
                            collector,r,h,best=s,candidate,humanoid,distance
                        end
                    end
                end
            end
            gem.collector=collector
            if collector then
                local delta=r.Position-gem.pos
                local distance=delta.Magnitude
                -- Stay attached once attracted; run speed and dashes cannot strand it.
                local travel=(math.max(36,h.WalkSpeed+12)+distance*2)*dt
                if distance<=3.5+travel then
                    gem.part:Destroy();table.remove(gems,i)
                    for _,s in pairs(states) do if rootOf(s) then s.xp+=1;levelCheck(s) end end
                else
                    gem.pos+=delta.Unit*travel
                    gem.part.Position=gem.pos
                end
            end
        end
    end

	return {
		Sync = sync,
		Drop = drop,
		Choose = choose,
		Collect = collect,
		Need = need,
		LevelCheck = levelCheck,
	}
end
]====])
-- Source: src/server/flow/Session.luau
addModule(modules,{"flow","Session"},[====[
-- Join, death, victory and full-round restart.
return function(deps)
	local Players = deps.players or game:GetService("Players")
	local world, states, enemies, gems, rng = deps.world, deps.states, deps.enemies, deps.gems, deps.rng
	local creature, finishDash, clearIceShots, sync = deps.creature, deps.finishDash, deps.clearIceShots, deps.sync
	local clock, resetSpawn = deps.clock, deps.resetSpawn
	local loadouts=require(script.Parent.Loadout)
	local saved={}
	local savedActive={}
	local starting = false
	local STARTING_HEALTH = 150 -- Pattern-review tuning; applies on join and restart.
	local function endPlayer(s,result)
		if s.over then return end
		s.over=true; s.result=result; s.offers=nil
		finishDash(s)
		clearIceShots(s)
		local c=s.player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
		if h then h.WalkSpeed=0 end
		sync(s)
	end
	local function addPlayer(player)
		local s={player=player,level=1,xp=0,kills=0,fire=0,lightning=0,ice=0,meteor=0,blades=0,frost=0,ward=0,missile=0,skyLances=0,golem=1,vitality=0,agility=0,magnet=0,cooldown=0,fireClock=0,lightningClock=0,iceClock=0,golemClock=0,over=false}
		s.activeSkill=savedActive[player] or 'fireWave';s.activeName=loadouts.ActiveNames[s.activeSkill]
		s.lobby=true;s.loadout=table.clone(saved[player] or loadouts.Defaults)
		states[player]=s
		s.pet=creature(player.Name.."_Golem",Color3.fromRGB(95,112,120),true)
		s.petRig={}
		for _,part in ipairs(s.pet:GetChildren()) do if part:IsA("BasePart") then s.petRig[part]=s.pet:GetPivot():ToObjectSpace(part.CFrame) end end
		player:LoadCharacterAsync()
		local character=player.Character
		if states[player]~=s or not character then return end
		local root=character:WaitForChild("HumanoidRootPart")
		root.CFrame=(deps.lobbySpawn or CFrame.new(0,4,150))*CFrame.new(rng:NextNumber(-4,4),0,rng:NextNumber(-4,4))
		s.pet:PivotTo(CFrame.new(root.Position.X+5,3.6,root.Position.Z+4))
		local humanoid=character:WaitForChild("Humanoid")
		humanoid.WalkSpeed=0; humanoid.MaxHealth=STARTING_HEALTH; humanoid.Health=STARTING_HEALTH
		humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
		s.loaded=true
		humanoid.Died:Connect(function() if states[player]==s then
			if s.lobby then saved[player]=table.clone(s.loadout);s.pet:Destroy();task.spawn(addPlayer,player) else endPlayer(s,"defeat")end
		end end)
		sync(s)
	end
	local function restart()
		if starting then return end
		starting=true
		for _,s in pairs(states) do if not s.over and not s.lobby then starting=false; return end end
		for p,s in pairs(states)do saved[p]=table.clone(s.loadout);savedActive[p]=s.activeSkill end
		world:ClearAllChildren(); table.clear(enemies); table.clear(gems); table.clear(states)
		clearIceShots()
		clock.elapsed=0; resetSpawn(); if deps.resetBoss then deps.resetBoss() end
		for _,p in ipairs(Players:GetPlayers()) do task.spawn(addPlayer,p) end
		starting=false
	end
	local function tryStart()
  local count=0
  for _,state in pairs(states)do
   if not state.lobby or not state.queued or not state.loaded then return end
   local c=state.player.Character;local h=c and c:FindFirstChildOfClass('Humanoid')
   if not h or h.Health<=0 then return end
   count+=1
  end
  if count==0 then return end
  for p,state in pairs(states)do
   state.lobby=false;state.queued=false;state.lobbyMessage=nil
   for _,id in ipairs(state.loadout)do state[id]=1 end
   saved[p]=table.clone(state.loadout);savedActive[p]=state.activeSkill
   local c=p.Character;local r=c.HumanoidRootPart;local h=c:FindFirstChildOfClass('Humanoid')
   r.CFrame=CFrame.new(rng:NextNumber(-4,4),4,rng:NextNumber(-4,4));r.AssemblyLinearVelocity=Vector3.zero
   h.WalkSpeed=22;state.pet:PivotTo(CFrame.new(r.Position+Vector3.new(5,0,4)))
   sync(state)
  end
 end
 local function startRound(s,ids,activeId)
  if not s.lobby or not s.loaded or starting then return end
  local now=os.clock();if now-(s.lastLobbyRequest or -10)<.5 then return end;s.lastLobbyRequest=now
  activeId=activeId or s.activeSkill or 'fireWave'
  if not loadouts.ValidateActive(activeId) then s.lobbyMessage='사용할 Q 스킬을 선택해 주세요.';sync(s);return end
  local valid=loadouts.Validate(ids)
  if not valid then s.lobbyMessage='서로 다른 마법을 정확히 3개 골라 주세요.';sync(s);return end
  for _,other in pairs(states)do
   if not other.lobby then s.lobbyMessage='진행 중인 전투가 끝난 뒤 함께 출발할 수 있어요.';sync(s);return end
  end
  s.activeSkill=activeId;s.activeName=loadouts.ActiveNames[activeId];s.loadout=valid;s.queued=true;s.lobbyMessage=nil;sync(s);tryStart()
 end
 local function cancelReady(s)
  if s.lobby and s.queued then s.queued=false;sync(s)end
 end
 local function removePlayer(p)
		saved[p]=nil;savedActive[p]=nil
		local s=states[p]; if s and s.pet then s.pet:Destroy() end; states[p]=nil
		if s then clearIceShots(s) end
		tryStart()
		if next(states)==nil then world:ClearAllChildren(); table.clear(enemies); table.clear(gems); clock.elapsed=0; resetSpawn(); if deps.resetBoss then deps.resetBoss() end end
	end

	return {
		AddPlayer = addPlayer,
		RemovePlayer = removePlayer,
		EndPlayer = endPlayer,
		Restart = restart,
		StartRound = startRound,
		CancelReady = cancelReady,
	}
end
]====])
-- Source: src/server/shared/Actors.luau
addModule(modules,{"shared","Actors"},[====[
-- Procedural actor geometry; shared by enemies and summons.
return function(deps)
	local world = deps.world
	local function block(parent, name, size, pos, color, material)
		local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=CFrame.new(pos)
		p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
		p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent
		return p
	end
	local createEnemy=require(script.Parent.EnemyModels)({block=block})
	local function creature(name, color, golem, kind)
        if not golem then return createEnemy(name,kind or "stalker",world) end
		local m=Instance.new("Model"); m.Name=name
		local size=golem and 1.2 or 0.85
		local root=block(m,"Core",Vector3.new(2.6,2.5,1.8)*size,Vector3.new(0,3,0),color,Enum.Material.Slate)
		m.PrimaryPart=root
		block(m,"Head",Vector3.new(1.9,1.5,1.6)*size,Vector3.new(0,5.1*size,0),color,Enum.Material.Slate)
		for _,side in ipairs({-1,1}) do
			block(m,golem and (side==-1 and "LeftArm" or "RightArm") or "Arm",Vector3.new(1,2.5,1.2)*size,Vector3.new(side*1.9*size,2.8*size,0),color,Enum.Material.Slate)
			block(m,"Leg",Vector3.new(1,1.8,1.3)*size,Vector3.new(side*.72*size,.9*size,0),color,Enum.Material.Slate)
			block(m,"Eye",Vector3.new(.3,.25,.12),Vector3.new(side*.45*size,5.25*size,-.85*size),golem and Color3.fromRGB(96,255,222) or Color3.fromRGB(255,112,115),Enum.Material.Neon)
		end
		block(m,"Rune",Vector3.new(.65,.8,.12),Vector3.new(0,3*size,-.96*size),golem and Color3.fromRGB(96,255,222) or Color3.fromRGB(215,70,104),Enum.Material.Neon)
		m.Parent=world
		return m
	end

	return {
		Block = block,
		Create = creature,
	}
end
]====])
-- Source: src/server/shared/EnemyModels.luau
addModule(modules,{"shared","EnemyModels"},[====[
-- Distinct silhouettes share only their invisible hit anchor.
return function(deps)
 local block=deps.block
 local function make(name,kind,world)
  local m=Instance.new('Model');m.Name=name
  local root=block(m,'Core',Vector3.one,CFrame.identity.Position,Color3.new());root.Transparency=1;root.Position=Vector3.new(0,3,0);m.PrimaryPart=root
  local function p(label,size,position,color,shape,rotation)
   local cf=CFrame.new(position)*(rotation or CFrame.identity)
   local v
   if shape=='wedge'then v=Instance.new('WedgePart');v.Name=label;v.Size=size;v.CFrame=cf;v.Color=color;v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false;v.Material=Enum.Material.Slate;v.Parent=m
   else v=block(m,label,size,position,color,Enum.Material.Slate);v.CFrame=cf;if shape=='ball'then local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=v end end
   return v
  end
  local function neon(label,size,position,color,shape)local v=p(label,size,position,color,shape);v.Material=Enum.Material.Neon;return v end
  local function limb(a,b,width,color)
   local v=p('Limb',Vector3.new(width,width,(b-a).Magnitude), (a+b)/2,color,'ball');v.CFrame=CFrame.lookAt((a+b)/2,b)
  end
  if kind=='skitter'then
   local green=Color3.fromRGB(91,167,126)
   p('Abdomen',Vector3.new(3,1.8,3.5),Vector3.new(0,2.2,.5),green,'ball')
   p('Head',Vector3.new(2.2,1.3,1.8),Vector3.new(0,2,-1.7),Color3.fromRGB(30,64,57),'ball')
   for _,side in ipairs({-1,1})do
    for j=1,3 do local a=Vector3.new(side*1.1,2.1,j-1.5);local b=Vector3.new(side*(2.1+j*.25),1.6,j*1.15-2.5);limb(a,b,.28,green);limb(b,Vector3.new(b.X+side*.5,.4,b.Z-.3),.18,green)end
    neon('Eye',Vector3.new(.3,.28,.3),Vector3.new(side*.6,2.2,-2.5),Color3.fromRGB(182,255,163),'ball')
    p('Fang',Vector3.new(.3,.6,.8),Vector3.new(side*.4,1.6,-2.6),Color3.fromRGB(214,239,203),'wedge')
   end
  elseif kind=='brute'or kind=='charger'then
   local armor=kind=='charger'and Color3.fromRGB(145,56,65)or Color3.fromRGB(73,101,126)
   p('ArmoredShell',Vector3.new(kind=='charger'and 3.2 or 4.6,kind=='charger'and 2.4 or 3,kind=='charger'and 5.8 or 4.8),Vector3.new(0,3,.4),armor,'ball')
   p('Head',Vector3.new(2.1,1.7,2.2),Vector3.new(0,2.3,-2),Color3.fromRGB(36,49,69),'ball')
   for i=-1,1 do p('ShellPlate',Vector3.new(1.5,1,4),Vector3.new(i*1.35,3.9,.3),armor,'wedge',CFrame.Angles(0,0,i*-.25))end
   for _,side in ipairs({-1,1})do
    for _,z in ipairs({-1.2,1.7})do limb(Vector3.new(side*1.4,2.5,z),Vector3.new(side*2.7,.5,z),.6,armor)end
    p('Tusk',Vector3.new(.7,1.6,1.6),Vector3.new(side*1.1,2.7,-2.7),Color3.fromRGB(226,218,184),'wedge',CFrame.Angles(-.5,0,side*.3))
    neon('Eye',Vector3.new(.3,.22,.2),Vector3.new(side*.52,2.6,-3.04),Color3.fromRGB(112,222,255),'ball')
   end
  elseif kind=='caster'then
   local purple=Color3.fromRGB(104,60,141)
   p('Robe',Vector3.new(2.6,3.6,2),Vector3.new(0,3,0),purple,'wedge')
   p('Hood',Vector3.new(2.1,2,1.9),Vector3.new(0,5.25,0),Color3.fromRGB(66,37,96),'ball')
   p('Face',Vector3.new(1.3,1.1,.18),Vector3.new(0,5.2,-.9),Color3.fromRGB(13,15,31),'ball')
   for _,side in ipairs({-1,1})do neon('Eye',Vector3.new(.2,.17,.15),Vector3.new(side*.35,5.35,-1.02),Color3.fromRGB(247,151,255),'ball');p('Sleeve',Vector3.new(.9,1.8,1),Vector3.new(side*1.5,3.6,-.2),purple,'wedge')end
   limb(Vector3.new(1.9,1.1,-.4),Vector3.new(1.9,6,-.4),.2,Color3.fromRGB(155,119,181))
   neon('StaffOrb',Vector3.new(.9,.9,.9),Vector3.new(1.9,6.2,-.4),Color3.fromRGB(214,127,255),'ball')
   for i=1,4 do local a=i*math.pi/2;neon('OrbitShard',Vector3.new(.25,.6,.25),Vector3.new(math.cos(a)*1.8,1.4,math.sin(a)*1.8),Color3.fromRGB(169,112,232),'wedge')end
  elseif kind=='ember'then
   local coal=Color3.fromRGB(79,37,44)
   p('ObsidianShell',Vector3.new(2.8,2.7,2.8),Vector3.new(0,2.5,0),coal,'ball')
   neon('FurnaceCore',Vector3.new(1.7,1.5,.3),Vector3.new(0,2.5,-1.35),Color3.fromRGB(255,106,36),'ball')
   for i=1,6 do local a=i*math.pi/3;p('Spine',Vector3.new(.35,1.2,.6),Vector3.new(math.sin(a)*1.2,3.5,math.cos(a)*1.2),coal,'wedge',CFrame.Angles(math.cos(a)*.5,0,-math.sin(a)*.5))end
   for _,side in ipairs({-1,1})do limb(Vector3.new(side*.8,1.7,.2),Vector3.new(side*1.1,.4,-.2),.5,coal);neon('Eye',Vector3.new(.22,.22,.22),Vector3.new(side*.45,3.1,-1.3),Color3.fromRGB(255,221,135),'ball')end
  else
   local dark=Color3.fromRGB(56,61,80)
   p('Body',Vector3.new(2.3,2.5,1.5),Vector3.new(0,3,0),dark,'wedge')
   p('Mask',Vector3.new(1.7,1.7,1.3),Vector3.new(0,4.8,-.2),Color3.fromRGB(130,135,148),'wedge')
   for _,side in ipairs({-1,1})do
    limb(Vector3.new(side*.55,2.1,0),Vector3.new(side*.8,.5,-.1),.55,dark)
    limb(Vector3.new(side*1.1,3.6,0),Vector3.new(side*1.7,1.8,-.6),.45,dark)
    p('Claw',Vector3.new(.3,.75,.45),Vector3.new(side*1.7,1.45,-.6),Color3.fromRGB(183,187,195),'wedge')
    neon('Eye',Vector3.new(.24,.25,.2),Vector3.new(side*.42,4.9,-.9),Color3.fromRGB(255,118,151),'ball')
   end
  end
  if kind=='charger'then
   for _,side in ipairs({-1,1})do
    p('ChargeHorn',Vector3.new(.45,.7,3.4),Vector3.new(side*.85,3.3,-3),Color3.fromRGB(255,204,151),'wedge',CFrame.Angles(.25,0,side*.1))
   end
   neon('ChargeCrest',Vector3.new(.22,.8,2.8),Vector3.new(0,4.6,-.6),Color3.fromRGB(255,118,83),'wedge')
  end
  m:SetAttribute('EnemyKind',kind);m.Parent=world;return m
 end
 return make
end
]====])
-- Source: src/server/shared/PlayerDamage.luau
addModule(modules,{"shared","PlayerDamage"},[====[
-- Call after existing dodge/offer/attack-once checks. Shields absorb before health.
return function(s,humanoid,amount,effect)
 local absorbed=math.min(s.shield or 0,amount)
 s.shield=math.max(0,(s.shield or 0)-absorbed)
 if absorbed>0 and effect then
  local character=s.player.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
  if root then effect:FireAllClients('wardHit',root.Position,s.shield<=0)end
 end
 if amount>absorbed then humanoid:TakeDamage(amount-absorbed)end
 return amount-absorbed
end
]====])
-- Source: src/server/shared/PlayerState.luau
addModule(modules,{"shared","PlayerState"},[====[
-- Read-only queries over the session state table.
return function(deps)
	local states = deps.states
	local function rootOf(s)
		local c=s.player.Character
		local h=c and c:FindFirstChildOfClass("Humanoid")
		local r=c and c:FindFirstChild("HumanoidRootPart")
		if h and r and h.Health>0 and not s.over and not s.lobby then return r,h end
	end
	local function liveCount()
		local n=0; for _,s in pairs(states) do if rootOf(s) then n+=1 end end; return n
	end
	local function paused()
		-- Developer model inspection freezes the Studio simulation for every tester.
		for _,s in pairs(states) do if s.previewDragon or s.previewSkills then return true end end
		if liveCount()~=1 then return false end
		for _,s in pairs(states) do if rootOf(s) and s.offers then return true end end
		return false
	end

	return {
		RootOf = rootOf,
		LiveCount = liveCount,
		Paused = paused,
	}
end
]====])
-- Source: src/server/world/Boss.luau
addModule(modules,{"world","Boss"},[====[
-- Server-owned dragon choreography. Every large hit has a locked ground warning.
return function(deps)
 local applyDamage=require(script.Parent.Parent.shared.PlayerDamage)
 local world,enemies,states,clock=deps.world,deps.enemies,deps.states,deps.clock
 local rootOf,effect,factory=deps.rootOf,deps.effect,deps.modelFactory
 local boss,rig,action=nil,nil,nil
 local t,cooldown,pattern=0,1,0
 local order={'breath','airBreath','dive','eruption','tail','flameCross','airCross','airRing'}
 local markers=Instance.new('Folder');markers.Name='BossTelegraphs';markers.Parent=world
 local red=Color3.fromRGB(255,91,61)
 local function flat(v)return Vector3.new(v.X,0,v.Z)end
 local function directionTo(a,b)local d=flat(b-a);return d.Magnitude>.01 and d.Unit or Vector3.new(0,0,1)end
 local function bounded(p)local f=flat(p);if f.Magnitude>68 then f=f.Unit*68 end;return Vector3.new(f.X,3,f.Z)end
 local function clear()markers:ClearAllChildren()end
 local function part(name,size,cf,alpha,class,parent)
  local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=red;p.Transparency=alpha or .4;p.CastShadow=false;p.Parent=parent or markers;return p
 end
 local function disc(pos,radius,name)
  name=name or 'EruptionWarning'
  local p=part(name,Vector3.new(.07,radius*2,radius*2),CFrame.new(pos.X,.14,pos.Z)*CFrame.Angles(0,0,math.pi/2),.85);p.Shape=Enum.PartType.Cylinder
  if name=='LandingWarning'then p.Color=Color3.fromRGB(255,191,72)end
  for i=1,32 do local a=i*math.pi/16;local edge=part(name..'Edge',Vector3.new(radius*.18,.07,.16),CFrame.new(pos.X,.2,pos.Z)*CFrame.Angles(0,a,0)*CFrame.new(0,0,-radius),.12);edge.Color=p.Color end
 end
 local function line(center,direction,length,halfWidth,delay)
  local folder=Instance.new('Folder');folder.Name='FireLineWarning';folder.Parent=markers
  local from=center-direction*length/2;local finish=center+direction*length/2
  local cf=CFrame.lookAt(Vector3.new(center.X,.16,center.Z),Vector3.new(center.X,.16,center.Z)+direction)
  part('FireLane',Vector3.new(halfWidth*2,.06,length),cf,.85,nil,folder)
  for _,side in ipairs({-1,1})do part('LaneEdge',Vector3.new(.15,.08,length),cf*CFrame.new(side*halfWidth,.06,0),.1,nil,folder)end
  return {from=from,finish=finish,direction=direction,length=length,halfWidth=halfWidth,at=delay,warning=folder}
 end
 local function insideLine(p,l)
  local d=flat(p-(l.from+l.finish)/2)
  return math.abs(d:Dot(l.direction))<=l.length/2 and math.abs(d:Dot(l.direction:Cross(Vector3.yAxis)))<=l.halfWidth
 end
 local function segmentDistance(p,a,b)
  local ab=flat(b-a);local ap=flat(p-a);local alpha=ab:Dot(ab)>.001 and math.clamp(ap:Dot(ab)/ab:Dot(ab),0,1) or 0;return (ap-ab*alpha).Magnitude
 end
 local function hit(predicate,amount,record)
  for _,s in pairs(states)do local r,h=rootOf(s);if r and not s.offers and(s.invulnerable or 0)<=0 and not record[s]and predicate(r.Position)then record[s]=true;applyDamage(s,h,amount,deps.effect)end end
 end
 local function fireLines(a)
  for _,l in ipairs(a.lines)do
   if a.time>=l.at and not l.fired then
    l.fired=true;if l.warning.Parent then l.warning:Destroy()end
    effect:FireAllClients('dragonFireLine',l.from,l.finish,{halfWidth=l.halfWidth,model=boss.model,duration=.5})
    hit(function(p)return insideLine(p,l)end,22,a.hit)
   end
  end
 end
 local function frame()return CFrame.lookAt(flat(boss.pos),flat(boss.pos)+boss.heading)end
 local function spawn()
  if boss then return end
  for _,e in ipairs(enemies)do if e.hp>0 and not e.isBoss then deps.drop(e.pos);e.hp=0;e.model:Destroy()end end
  if deps.clearEnemyShots then deps.clearEnemyShots()end
  local count=0;for _,s in pairs(states)do if rootOf(s)then count+=1 end end
  rig=factory.create(world,CFrame.new(0,0,-34));rig.model.Name='EmberDragon'
  local hp=2880*(1+.7*math.max(0,count-1))
  boss={name='흑염룡 · 아그니스',model=rig.model,pos=Vector3.new(0,3,-34),hp=hp,maxHp=hp,isBoss=true,slow=0,frozen=0,speed=16,heading=Vector3.new(0,0,1),phase=1,altitude=0}
  boss.model:SetAttribute('HP',hp);boss.model:SetAttribute('MaxHP',hp)
  table.insert(enemies,boss);clock.boss=boss;clock.phase='boss';clock.bossElapsed=0;t,cooldown,pattern=0,1,0
  effect:FireAllClients('dragonArrival',boss.pos,16)
 end
 local function fanWarning(a)
  local function triangle(x,y,z)
   local ab,ac,bc=y-x,z-x,z-y
   if ab.Magnitude>ac.Magnitude and ab.Magnitude>bc.Magnitude then z,x=x,z elseif ac.Magnitude>bc.Magnitude then x,y=y,x end
   ab,ac,bc=y-x,z-x,z-y
   local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit;local height=math.abs(ab:Dot(up))
   part('BreathWarning',Vector3.new(.045,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((x+y)/2,right,up,back),.86,'WedgePart')
   part('BreathWarning',Vector3.new(.045,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((x+z)/2,-right,up,-back),.86,'WedgePart')
  end
  local center=Vector3.new(a.mouth.X,.15,a.mouth.Z)
  for i=0,11 do
   local x=math.rad(-a.angle+i*a.angle*2/12);local y=math.rad(-a.angle+(i+1)*a.angle*2/12)
   triangle(center,center+CFrame.Angles(0,x,0):VectorToWorldSpace(a.direction)*a.range,center+CFrame.Angles(0,y,0):VectorToWorldSpace(a.direction)*a.range)
  end
  for _,angle in ipairs({-a.angle,a.angle})do local d=CFrame.Angles(0,math.rad(angle),0):VectorToWorldSpace(a.direction);part('BreathEdge',Vector3.new(.16,.08,a.range),CFrame.lookAt(center+d*a.range/2,center+d*(a.range/2+1)),.1)end
 end
 local function begin(target)
  clear();pattern=pattern%#order+1
  local kind=order[pattern];boss.heading=directionTo(boss.pos,target)
  action={kind=kind,time=0,hit={},origin=flat(boss.pos),direction=boss.heading,phase=boss.phase}
  local a=action;local right=a.direction:Cross(Vector3.yAxis)
  if kind=='eruption'then
   a.windup=1.05;a.total=1.6;a.radius=boss.phase==2 and 14 or 12;a.points={}
   for _,offset in ipairs(boss.phase==2 and {-36,-18,0,18,36}or{-18,0,18})do local p=bounded(target+right*offset);table.insert(a.points,p);disc(p,a.radius)end
  elseif kind=='breath'then
   a.windup=.95;a.total=2.05;a.range=55;a.angle=boss.phase==2 and 50 or 45;a.mouth=frame():PointToWorldSpace(Vector3.new(0,19.2,-10.2));fanWarning(a)
  elseif kind=='flameCross'then
   a.windup=1;a.total=2.05
   a.lines={line(target,a.direction,72,9,a.windup),line(target,right,72,9,a.windup+.5)}
  elseif kind=='airBreath'or kind=='airCross'or kind=='airRing'then
   a.air=true;a.windup=1;a.sweepDuration=1.4;a.landStart=a.windup+a.sweepDuration;a.landAt=a.landStart+.7;a.total=a.landAt+.3
   a.finish=bounded(target-a.direction*8);a.slamRadius=boss.phase==2 and 22 or 18;a.slamHit={};a.points={}
   if kind=='airCross'then
    a.lines={line(target,a.direction,76,10,a.windup),line(target,right,76,10,a.windup+.6)}
   elseif kind=='airRing'then
    a.radius=boss.phase==2 and 11 or 10
    for i=0,7 do local angle=i*math.pi/4;local p=bounded(target+Vector3.new(math.cos(angle)*25,0,math.sin(angle)*25));table.insert(a.points,p);disc(p,a.radius)end
    table.insert(a.points,a.points[1]) -- Close the visible breath loop; damage each patch once.
   else
    a.radius=boss.phase==2 and 11 or 10
    for i=1,7 do local p=bounded(target+right*(i-4)*9);table.insert(a.points,p);disc(p,a.radius)end
   end
  elseif kind=='tail'then
   a.windup=1;a.spinDuration=1.35;a.total=2.55;a.radius=boss.phase==2 and 24 or 22
   local desired=flat(bounded(target-a.direction*6));local delta=desired-a.origin
   a.finish=a.origin+(delta.Magnitude>30 and delta.Unit*30 or delta);disc(a.finish,a.radius,'TailWarning')
  else
   a.windup=.9;a.travelDuration=.55;a.total=1.8;a.halfWidth=11;a.radius=16;a.finish=flat(bounded(boss.pos+a.direction*46))
   local length=flat(a.finish-a.origin).Magnitude
   part('DiveWarning',Vector3.new(a.halfWidth*2,.06,math.max(1,length)),CFrame.lookAt(a.origin+a.direction*length*.5+Vector3.new(0,.15,0),a.origin+a.direction*(length*.5+1)+Vector3.new(0,.15,0)),.8)
   disc(a.finish,a.radius,'LandingWarning')
  end
  if kind=='breath'or kind=='flameCross'or a.air then effect:FireAllClients('dragonCharge',boss.model,a.windup)end
  boss.model:SetAttribute('Attack',kind)
 end
 local function stepAir(a)
  local travel=math.clamp(a.time/a.landStart,0,1);travel=travel*travel*(3-2*travel)
  boss.pos=a.origin:Lerp(flat(a.finish),travel)
  local pose='fly'
  if a.time<a.windup then boss.altitude=24*math.sin(a.time/a.windup*math.pi/2)
  elseif a.time<a.landStart then
   boss.altitude=24;pose='airBreath'
   if a.lines then fireLines(a)
   else
    if not a.started then a.started=true;clear();effect:FireAllClients('dragonAirBreath',boss.model,a.points,a.sweepDuration)end
    local count=a.kind=='airRing'and #a.points-1 or #a.points
    local index=math.clamp(math.floor((a.time-a.windup)/a.sweepDuration*count)+1,1,count)
    for i=1,index do if not a['patch'..i]then
     a['patch'..i]=true;local p=a.points[i];effect:FireAllClients('dragonEruption',p,a.radius)
     hit(function(pos)return flat(pos-p).Magnitude<=a.radius end,20,a.hit)
    end end
   end
  else
   local fall=math.clamp((a.time-a.landStart)/(a.landAt-a.landStart),0,1)
   boss.altitude=24*(1-fall*fall)
  end
  if a.time>=a.landStart-.25 and not a.warned then a.warned=true;disc(a.finish,a.slamRadius,'LandingWarning')end
  if a.time>=a.landAt then
   boss.altitude=0;pose='land'
   if not a.landed then
    a.landed=true;clear();effect:FireAllClients('dragonSlam',a.finish,a.slamRadius)
    hit(function(p)return flat(p-a.finish).Magnitude<=a.slamRadius end,26,a.slamHit)
   end
  end
  return pose
 end
 local function step(dt)
  if clock.phase=='survival'then if clock.elapsed>=clock.roundLength then spawn()end;return end
  if clock.phase~='boss'or not boss or boss.hp<=0 then return end
  clock.bossElapsed+=dt;t+=dt;boss.phase=boss.hp<=boss.maxHp*.5 and 2 or 1
  boss.slow=math.max(0,boss.slow-dt);boss.frozen=0;boss.knockTime=0;boss.model:SetAttribute('Frozen',false)
  local target,best=nil,math.huge
  for _,s in pairs(states)do local r=rootOf(s);if r then local d=flat(r.Position-boss.pos).Magnitude;if d<best then best=d;target=r.Position end end end
  if not target then return end
  local pose,progress=nil,0;boss.altitude=0
  if action then
   local a=action;a.time+=dt;pose=a.kind;progress=a.time/a.total
   if a.air then
    pose=stepAir(a)
    if pose=='land'then progress=math.clamp((a.time-a.landAt)/(a.total-a.landAt),0,1)end
   elseif a.kind=='flameCross'then pose='breath';fireLines(a)
   elseif a.kind=='eruption'then
    if a.time>=a.windup and not a.impacted then
     a.impacted=true;clear();for _,p in ipairs(a.points)do effect:FireAllClients('dragonEruption',p,a.radius)end
     hit(function(pos)for _,p in ipairs(a.points)do if flat(pos-p).Magnitude<=a.radius then return true end end;return false end,22,a.hit)
    end
   elseif a.kind=='breath'then
    if a.time>=a.windup and not a.impacted then
     a.impacted=true;clear();effect:FireAllClients('dragonBreath',a.mouth,a.direction,{range=a.range,angle=a.angle,model=boss.model})
     hit(function(p)local d=flat(p-a.mouth);return d.Magnitude<=a.range and(d.Magnitude<.1 or d.Unit:Dot(a.direction)>=math.cos(math.rad(a.angle)))end,17,a.hit)
    end
   elseif a.kind=='tail'then
    local move=math.clamp(a.time/a.windup,0,1);boss.pos=a.origin:Lerp(a.finish,move*move*(3-2*move))
    local coil=math.clamp((a.time-.5)/(a.windup-.5),0,1)
    if a.time<a.windup then
     pose=a.time<.5 and 'walk'or'tailWindup';progress=coil
     boss.heading=CFrame.Angles(0,math.rad(18)*coil*coil*(3-2*coil),0):VectorToWorldSpace(a.direction)
    end
    if a.time>=a.windup then
     local spin=math.clamp((a.time-a.windup)/a.spinDuration,0,1)
     local eased=spin*spin*spin*(spin*(spin*6-15)+10)
     progress=spin
     boss.heading=CFrame.Angles(0,math.rad(18)-(math.pi*2+math.rad(18))*eased,0):VectorToWorldSpace(a.direction)
     if not a.started then a.started=true;clear();effect:FireAllClients('dragonTailSpin',boss.model,a.radius,a.spinDuration)end
     if eased>=.28 and not a.impacted then a.impacted=true;hit(function(p)return flat(p-a.finish).Magnitude<=a.radius end,20,a.hit)end
    end
   else
    if a.time<a.windup then boss.altitude=12*math.sin(a.time/a.windup*math.pi/2);pose='fly'
    elseif not a.done then
     if not a.started then a.started=true;clear();effect:FireAllClients('dragonDive',boss.model,a.travelDuration)end
     local previous=boss.pos;local alpha=math.clamp((a.time-a.windup)/a.travelDuration,0,1);boss.pos=a.origin:Lerp(a.finish,alpha);boss.altitude=12*(1-alpha)+math.sin(alpha*math.pi)*12
     if boss.altitude<10 then hit(function(p)return segmentDistance(p,previous,boss.pos)<=a.halfWidth end,20,a.hit)end
     if alpha>=1 then a.done=true;effect:FireAllClients('dragonSlam',a.finish,a.radius);hit(function(p)return flat(p-a.finish).Magnitude<=a.radius end,20,a.hit)end
    else pose='land'end
    if pose=='land'then progress=math.clamp((a.time-a.windup-a.travelDuration)/(a.total-a.windup-a.travelDuration),0,1)end
   end
   if a.time>=a.total then action=nil;cooldown=boss.phase==2 and .5 or .7;clear();boss.model:SetAttribute('Attack','Recover')end
  else
   cooldown-=dt
   -- Long-range attacks engage immediately; no chase-until-38-studs gate.
   if cooldown<=0 then begin(target)
   elseif best>15 and t>1 then
    pose='walk';local desired=directionTo(boss.pos,target);local alpha=1-math.exp(-dt*8)
    boss.heading=CFrame.lookAt(Vector3.zero,boss.heading):Lerp(CFrame.lookAt(Vector3.zero,desired),alpha).LookVector
    boss.pos=bounded(boss.pos+boss.heading*math.min(best-15,boss.speed*(boss.slow>0 and .8 or 1)*dt))
   end
  end
  boss.airborne=boss.altitude>8;boss.pos=Vector3.new(boss.pos.X,3+boss.altitude,boss.pos.Z)
  if t<1 and not action then pose='roar';progress=t end
  rig.origin=frame()*CFrame.new(0,boss.altitude,0);factory.pose(rig,t,pose,math.clamp(progress,0,1),boss.phase)
 end
 local function resolve()
  if clock.phase~='boss'or not boss then return end
  if boss.hp<=0 then
   clock.phase='victory';clear();effect:FireAllClients('dragonArrival',boss.pos,18)
   if boss.model.Parent then boss.model:Destroy()end
   for _,s in pairs(states)do if not s.over then deps.endPlayer(s,'victory')end end
  end
 end
 local function reset()
  if boss and boss.model.Parent then boss.model:Destroy()end
  boss,rig,action=nil,nil,nil;clock.boss=nil;clock.bossElapsed=0;clock.phase='survival';t,cooldown,pattern=0,1,0
  if not markers.Parent then markers=Instance.new('Folder');markers.Name='BossTelegraphs';markers.Parent=world else clear()end
 end
 return {Step=step,Resolve=resolve,Reset=reset}
end
]====])
-- Source: src/server/world/LobbyWorld.luau
addModule(modules,{"world","LobbyWorld"},[====[
-- Reproducible waiting sanctuary, separate from the combat runtime.
return function()
 local old=workspace:FindFirstChild('SummonerLobby');if old then old:Destroy()end
 local folder=Instance.new('Folder');folder.Name='SummonerLobby';folder.Parent=workspace
 local function part(name,size,cf,color,material,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Slate;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.Parent=folder;return p
 end
 local stone=Color3.fromRGB(39,49,72);local mint=Color3.fromRGB(91,244,216)
 part('Sanctuary',Vector3.new(3,68,68),CFrame.new(0,-1.5,150)*CFrame.Angles(0,0,math.pi/2),stone,nil,Enum.PartType.Cylinder)
 part('Dais',Vector3.new(.4,22,22),CFrame.new(0,.2,150)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(57,64,90),nil,Enum.PartType.Cylinder)
 for i=1,40 do
  local a=i*math.pi/20
  local p=part('RunicInlay',Vector3.new(2,.08,.17),CFrame.new(math.cos(a)*10,.44,150+math.sin(a)*10)*CFrame.Angles(0,-a-math.pi/2,0),mint,Enum.Material.Neon);p.CanCollide=false
 end
 for i=1,8 do
  local a=i*math.pi/4;local pos=Vector3.new(math.cos(a)*27,0,150+math.sin(a)*27)
  part('Obelisk',Vector3.new(3,9,3),CFrame.new(pos+Vector3.new(0,4.5,0)),stone)
  local p=part('SpellCrystal',Vector3.new(2,3.5,2),CFrame.new(pos+Vector3.new(0,11,0))*CFrame.Angles(0,math.pi/4,.3),i%2==0 and mint or Color3.fromRGB(188,151,255),Enum.Material.Neon);p.CanCollide=false
  local light=Instance.new('PointLight');light.Color=p.Color;light.Range=18;light.Brightness=1.5;light.Parent=p
 end
 for i=1,24 do
  local a=i*math.pi/12
  local p=part('PortalArc',Vector3.new(1.7,1.7,1.1),CFrame.new(math.cos(a)*8,9+math.sin(a)*8,127)*CFrame.Angles(0,0,a),i%3==0 and mint or stone, i%3==0 and Enum.Material.Neon or Enum.Material.Slate);p.CanCollide=false
 end
 return CFrame.new(0,4,150)*CFrame.Angles(0,math.pi,0)
end
]====])
-- Source: src/server/world/Waves.luau
addModule(modules,{"world","Waves"},[====[
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
  spawnClock=math.max(.28,.8-elapsed*.0035)/math.max(1,alive*.65)
  local pool={'stalker','stalker','stalker','stalker','stalker','stalker'}
  if elapsed>=12 then table.insert(pool,'skitter');table.insert(pool,'skitter');table.insert(pool,'skitter')end
  if elapsed>=28 then table.insert(pool,'brute');table.insert(pool,'brute')end
  if elapsed>=42 then table.insert(pool,'caster');table.insert(pool,'caster')end
  if elapsed>=60 then table.insert(pool,'ember')end
  if elapsed>=32 then table.insert(pool,'charger');table.insert(pool,'charger')end
  local a=rng:NextNumber(0,math.pi*2)
  create(pool[rng:NextInteger(1,#pool)],Vector3.new(math.cos(a)*77,3,math.sin(a)*77),elapsed)
  if elapsed>=nextPack then
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
   if e.isBoss then continue end
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
   if e.model.Parent and diff.Magnitude>.01 then
    local bob=e.kind=='caster'and math.sin(time*2+e.seed)*.25 or math.sin(time*(e.kind=='skitter'and 9 or 4)+e.seed)*.08
    e.model:PivotTo(CFrame.lookAt(e.pos+Vector3.new(0,bob,0),e.pos+Vector3.new(0,bob,0)+move))
   end
   if e.kind~='caster'and e.kind~='ember'and dist<4 and e.hitClock<=0 and e.frozen<=0 then
    if harm(target,e.kind=='brute'and 11 or(e.kind=='charger'and 12 or(e.kind=='skitter'and 6 or 8)))then e.hitClock=.95 end
   end
  end
 end
 local function resetSpawn()
  spawnClock=0;time=0;nextPack=18
  for _,s in ipairs(shots)do s.part:Destroy()end;table.clear(shots)
 end
 return {Spawn=spawn,Step=step,ResetSpawn=resetSpawn}
end
]====])
entry.Parent=game.ServerScriptService
end

do
local entry=Instance.new("LocalScript")
entry.Name="SummonerClient"
entry.Source=[====[
-- Composition root. Install the Modules children together with this script.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local net = RS:WaitForChild("SummonerNet")
local modules = script:WaitForChild("Modules")
local combat = modules:WaitForChild("combat")
local flow = modules:WaitForChild("flow")
local world = modules:WaitForChild("world")
local input = require(combat:WaitForChild("Input"))({player=player,net=net})
local hud = require(flow:WaitForChild("HUD"))({player=player,net=net,input=input})
require(combat:WaitForChild("Effects"))({player=player,net=net,gui=hud.Gui})
local cameraController=require(world:WaitForChild("Camera"))({player=player})
require(world:WaitForChild("CharacterMotion"))()
require(world:WaitForChild("DragonPresentation"))()
local skillPreview
local dragonPreview=require(world:WaitForChild("DragonPreview"))({player=player,net=net,input=input,hud=hud.Gui,beforeOpen=function()if skillPreview then skillPreview.Close()end end})
require(flow:WaitForChild("Lobby"))({player=player,net=net,input=input,hud=hud.Gui,camera=cameraController})
skillPreview=require(flow:WaitForChild("SkillPreview"))({player=player,net=net,input=input,hud=hud.Gui,dragon=dragonPreview,camera=cameraController})
net.Action:FireServer("ready")
print("[Summoner] HUD ready")
]====]
local modules=Instance.new("Folder");modules.Name="Modules";modules.Parent=entry
-- Source: src/client/Theme.luau
addModule(modules,{"Theme"},[====[
local palette={bg=Color3.fromRGB(15,25,34),card=Color3.fromRGB(25,40,50),text=Color3.fromRGB(234,244,244),muted=Color3.fromRGB(155,182,188),mint=Color3.fromRGB(93,242,207),gold=Color3.fromRGB(255,196,103)}
local function make(class,parent,props)
	local obj=Instance.new(class); for k,v in pairs(props) do obj[k]=v end; obj.Parent=parent; return obj
end
local function round(obj,radius) make("UICorner",obj,{CornerRadius=UDim.new(0,radius or 12)}) end
local function stroke(obj,color) make("UIStroke",obj,{Color=color or Color3.fromRGB(57,82,91),Thickness=1}) end
local function label(parent,text,size,pos,font,color)
	return make("TextLabel",parent,{BackgroundTransparency=1,Text=text,Size=size,Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextColor3=color or palette.text,TextSize=16,TextWrapped=true})
end
return {Palette=palette, Make=make, Round=round, Stroke=stroke, Label=label}
]====])
-- Source: src/client/combat/ActiveArt.luau
addModule(modules,{"combat","ActiveArt"},[====[
-- Procedural Q charge portals, jagged lightning and a rising glacial lane.
return function(deps)
 local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris');local Run=game:GetService('RunService')
 local fx=deps.folder;local cyan=Color3.fromRGB(142,225,255);local white=Color3.fromRGB(232,251,255)
 local function part(parent,name,size,cf,color,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Color=color;p.Material=Enum.Material.Neon;p.Parent=parent;return p
 end
 local function line(parent,a,b,width,color,lifetime,alpha)
  local p=part(parent,'ArcaneBolt',Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color);p.Transparency=alpha or 0
  if lifetime then Debris:AddItem(p,lifetime);Tween:Create(p,TweenInfo.new(lifetime),{Transparency=1}):Play()end
  return p
 end
 local function charge(name,kind)
  if kind=='aetherLance' then return end -- Lance ribbons provide the charge; avoid a solid portal obscuring the shimmer.
  local anchor=name
  if type(name)=='string' then local runtime=workspace:WaitForChild('SummonerRuntime',3);anchor=runtime and runtime:WaitForChild(name,1)end
  if typeof(anchor)~='Instance' then return end
  if not anchor or not anchor.Parent then return end
  local model=Instance.new('Model');model.Name=kind..'Charge';model.Parent=fx
  local parts={};for i=1,24 do parts[i]=part(model,'PortalRune',Vector3.one*.1,CFrame.new(),cyan)end
  local orb=part(model,'GatheringCore',Vector3.one*.6,anchor.CFrame,white,Enum.PartType.Ball)
  local length=anchor:GetAttribute('Range')or 34;local width=kind=='thunder' and 2.4 or 6
  for _,side in ipairs({-1,1})do
   local a=anchor.CFrame:PointToWorldSpace(Vector3.new(side*width,-2,0));local b=a+anchor.CFrame.LookVector*length
   local p=line(model,a,b,.1,cyan);p.Transparency=.55
  end
  local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;model:Destroy()end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent or anchor:GetAttribute('Launched') then clear();return end
   local u=math.clamp((anchor:GetAttribute('Elapsed')or 0)/.4,0,1)
   local frame=anchor.CFrame*CFrame.new(0,1.3,-3)
   orb.CFrame=frame;orb.Size=Vector3.one*(.6+u*.9)
   for i,p in ipairs(parts)do
    local a=i*math.pi/12+u*1.5;local b=(i+1)*math.pi/12+u*1.5
    local from=frame:PointToWorldSpace(Vector3.new(math.cos(a)*1.8,math.sin(a)*1.8,0));local to=frame:PointToWorldSpace(Vector3.new(math.cos(b)*1.8,math.sin(b)*1.8,0))
    p.Size=Vector3.new(.09,.09,(to-from).Magnitude);p.CFrame=CFrame.lookAt((from+to)/2,to)
   end
  end)
 end
 local function strike(origin,direction,settings)
  local side=direction:Cross(Vector3.yAxis)
  if settings.kind=='iceRush' then
   for step=1,8 do
    for _,sign in ipairs({-1,1})do
     local point=origin+direction*(step*settings.range/8)+side*sign*(1.2+step%3)
     local height=4+step%3
     local p=Instance.new('WedgePart');p.Name='GlacialRushSpire';p.Size=Vector3.new(.6,.1,2);p.CFrame=CFrame.lookAt(Vector3.new(point.X,-1,point.Z),Vector3.new(point.X,-1,point.Z)+direction)*CFrame.Angles(0,sign*.3,0);p.Color=step%2==0 and white or cyan;p.Material=Enum.Material.Glass;p.Transparency=.12;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,1.8)
     Tween:Create(p,TweenInfo.new(.2),{Size=Vector3.new(1.4,height,2.7),Position=Vector3.new(point.X,height*.35,point.Z)}):Play()
     task.delay(.7,function()if p.Parent then Tween:Create(p,TweenInfo.new(.9),{Transparency=1,Position=p.Position-Vector3.new(0,2,0)}):Play()end end)
    end
   end
   local from=Vector3.new(origin.X,.45,origin.Z);local to=from+direction*settings.range
   local wave=line(fx,from,to,1.1,cyan,.45,.4);wave.Name='GlacialRushLane'
  end
 end
 return {Charge=charge,Strike=strike}
end
]====])
-- Source: src/client/combat/AetherLanceArt.luau
addModule(modules,{"combat","AetherLanceArt"},[====[
-- Original soft blue/violet ribbon lance, inspired by the user-provided reference.
return function(deps)
 local Run=game:GetService('RunService');local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris')
 local fx=deps.folder;local cyan=Color3.fromRGB(113,207,255);local white=Color3.fromRGB(231,252,255);local violet=Color3.fromRGB(206,140,255)
 local function part(parent,name,size,cf,color,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Shape=shape or Enum.PartType.Block;p.Material=Enum.Material.Neon;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function resolve(name)
  if typeof(name)=='Instance'then return name end
  if type(name)~='string'then return nil end
  local runtime=workspace:WaitForChild('SummonerRuntime',3);return runtime and runtime:WaitForChild(name,2)
 end
 local function cast(name,kind)
  local anchor=resolve(name);if not anchor or not anchor.Parent then return end
  local spear=kind=='aetherLance';local crystal=false
  local model=Instance.new('Model');model.Name=spear and 'AetherLance' or(crystal and 'CrystalBolt' or 'HomingMissile');model.Parent=fx
  local pivot=part(model,'Pivot',Vector3.one*.1,CFrame.identity,white);pivot.Transparency=1;model.PrimaryPart=pivot
  local color=(spear or crystal)and cyan or violet
  local currents={};local tipSparks;local age=0
  if spear then
   -- Thin luminous lance, formed inside soft blue/violet ribbons.
   local shaft=part(model,'SpearShaft',Vector3.new(17,.085,.085),CFrame.new(0,0,2)*CFrame.Angles(0,math.pi/2,0),cyan,Enum.PartType.Cylinder);shaft.Transparency=.2
   part(model,'SpearSpine',Vector3.new(20,.035,.035),CFrame.new(0,0,.7)*CFrame.Angles(0,math.pi/2,0),white,Enum.PartType.Cylinder)
   local aura=part(model,'SpearAura',Vector3.new(19,.2,.2),CFrame.new(0,0,1)*CFrame.Angles(0,math.pi/2,0),cyan,Enum.PartType.Cylinder);aura.Transparency=.78
   local function face(a,b,c,color)
    local ab,ac,bc=b-a,c-a,c-b
    local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
    if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
    ab,ac,bc=b-a,c-a,c-b
    local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
    local function half(v,axis,depth)
     if depth<.005 then return end
     local p=Instance.new('WedgePart');p.Name='LightningSpearFacet';p.Size=Vector3.new(.015,math.abs(ab:Dot(up)),depth);p.CFrame=CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back);p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.2;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=model
    end
    half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
   end
   local tip=Vector3.new(0,0,-13);local tail=Vector3.new(0,0,-6.8)
   local ring={Vector3.new(.17,0,-8.5),Vector3.new(0,.17,-8.5),Vector3.new(-.17,0,-8.5),Vector3.new(0,-.17,-8.5)}
   for i=1,4 do local a,b=ring[i],ring[i%4+1];face(tip,a,b,i%2==0 and white or cyan);face(tail,b,a,cyan)end
   for strand=1,3 do
    for i=1,8 do
     local a=Instance.new('Attachment');a.Parent=pivot;local b=Instance.new('Attachment');b.Parent=pivot
     local beam=Instance.new('Beam');beam.Name='WaveringLanceRibbon';beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=8;beam.LightEmission=1;beam.LightInfluence=0
     beam.Color=ColorSequence.new(strand==3 and Color3.fromRGB(128,116,255)or cyan,white)
     if strand>1 then beam.Texture='rbxasset://textures/particles/smoke_main.dds';beam.TextureMode=Enum.TextureMode.Stretch;beam.TextureSpeed=.35 end
     beam.Transparency=NumberSequence.new(strand==1 and .28 or .72);beam.Width0=strand==1 and .055 or 1.1;beam.Width1=beam.Width0;beam.Parent=pivot
     table.insert(currents,{a=a,b=b,beam=beam,index=i,strand=strand})
    end
   end
   local tipHost=Instance.new('Attachment');tipHost.Position=Vector3.new(0,0,-7.5);tipHost.Parent=pivot
   tipSparks=Instance.new('ParticleEmitter');tipSparks.Name='LanceStardust';tipSparks.Texture='rbxasset://textures/particles/sparkles_main.dds';tipSparks.Rate=35;tipSparks.Lifetime=NumberRange.new(.18,.4);tipSparks.Speed=NumberRange.new(.5,2);tipSparks.SpreadAngle=Vector2.new(180,180);tipSparks.Size=NumberSequence.new(.14,0);tipSparks.Color=ColorSequence.new(white,cyan);tipSparks.LightEmission=1;tipSparks.Transparency=NumberSequence.new(.2,1);tipSparks.Parent=tipHost
   local host=Instance.new('Attachment');host.Position=Vector3.new(0,0,5);host.Parent=pivot
   local mist=Instance.new('ParticleEmitter');mist.Name='LanceHaze';mist.Texture='rbxasset://textures/particles/smoke_main.dds';mist.Rate=22;mist.Lifetime=NumberRange.new(.25,.55);mist.Speed=NumberRange.new(.5,2);mist.SpreadAngle=Vector2.new(25,25);mist.Size=NumberSequence.new(1.8,0);mist.Color=ColorSequence.new(cyan,Color3.fromRGB(118,99,255));mist.Transparency=NumberSequence.new(.9,1);mist.LightEmission=.65;mist.Parent=host

  end
  local a=Instance.new('Attachment');a.Position=Vector3.new(-.3,0,spear and 9.5 or .3);a.Parent=pivot
  local b=Instance.new('Attachment');b.Position=Vector3.new(.3,0,spear and 9.5 or .3);b.Parent=pivot
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=spear and .3 or .2;trail.Color=ColorSequence.new(white,color);trail.Transparency=NumberSequence.new(.2,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=1;trail.Parent=pivot
  local light=Instance.new('PointLight');light.Color=color;light.Range=spear and 12 or 6;light.Brightness=1.5;light.Parent=pivot
  local current=anchor.CFrame;local bodyParts={};if spear then for _,p in ipairs(model:GetChildren())do if p:IsA('BasePart')and p~=pivot then table.insert(bodyParts,{part=p,alpha=p.Transparency})end end end;local hasLaunched=false;local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;model:Destroy()end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function(dt)
   if not anchor.Parent then clear();return end
   age+=dt
   local launched=not spear or anchor:GetAttribute('Launched')
   local target=anchor.CFrame
   local charge=math.clamp((anchor:GetAttribute('Elapsed')or 0)/.4,0,1)
   if spear then
    if not launched then target=target*CFrame.new(0,1.2,-3)end
    local formed=launched and 1 or math.clamp((charge-.4)/.6,0,1)
    for _,v in ipairs(bodyParts)do v.part.Transparency=1-(1-v.alpha)*formed end
   end
   current=current:Lerp(target,1-math.exp(-dt*35));model:PivotTo(current);trail.Enabled=launched
   if spear then
    for _,v in ipairs(currents)do
     local function point(index)
      local z=-8+index*2.5;local phase=age*5+index*.9+v.strand*2.1
      local width=(launched and 1.25 or 1.7)*(v.strand==1 and .75 or 1)
      return Vector3.new(math.sin(phase)*width,math.cos(phase*.85)*width*.7,z)
     end
     v.a.Position=point(v.index-1);v.b.Position=point(v.index)
     v.beam.CurveSize0=math.sin(age*3+v.index)*.22;v.beam.CurveSize1=-v.beam.CurveSize0
    end
    if launched and not hasLaunched then hasLaunched=true;tipSparks:Emit(28)end
   end
  end)
 end
 return {Cast=cast}
end
]====])
-- Source: src/client/combat/AreaArt.luau
addModule(modules,{"combat","AreaArt"},[====[
-- Original procedural art. Active casts follow server time, so menu pauses freeze them.
return function(deps)
 local Run=game:GetService('RunService');local Debris=game:GetService('Debris');local Tween=game:GetService('TweenService')
 local fx=deps.folder
 local skyLances=require(script.Parent.SkyLanceArt)({folder=fx})
 local gold=Color3.fromRGB(255,171,62);local ice=Color3.fromRGB(158,235,255);local mint=Color3.fromRGB(132,255,220)
 local function part(parent,name,color,size,shape)
  local p=Instance.new('Part');p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Color=color;p.Size=size;p.Shape=shape or Enum.PartType.Ball;p.Parent=parent;return p
 end
 local function line(p,a,b,width)
  p.Size=Vector3.new((b-a).Magnitude,width,width);p.CFrame=CFrame.lookAt((a+b)*.5,b)*CFrame.Angles(0,math.pi/2,0)
 end
 local function edge(parent,color,width)return part(parent,'RuneArc',color,Vector3.new(width,width,1),Enum.PartType.Cylinder)end
 local function ring(parent,pos,radius,color,duration)
  for i=1,40 do
   local a=(i-1)*math.pi/20;local b=i*math.pi/20
   local p=edge(parent,color,.16);local dir=Vector3.new(math.cos((a+b)/2),0,math.sin((a+b)/2))
   line(p,pos+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius),pos+Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius),.16)
   Debris:AddItem(p,duration);Tween:Create(p,TweenInfo.new(duration),{Position=p.Position+dir*radius*.25,Transparency=1}):Play()
  end
 end
 local function burst(pos,radius,color)
  local p=part(fx,'ArcaneImpact',color,Vector3.one);p.Position=pos+Vector3.new(0,1,0);p.Transparency=.45;Debris:AddItem(p,.65)
  Tween:Create(p,TweenInfo.new(.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(radius*1.8,2,radius*1.8),Transparency=1}):Play()
  ring(fx,Vector3.new(pos.X,.5,pos.Z),radius,color,.65)
  for i=1,20 do
   local a=i*math.pi/10;local dir=Vector3.new(math.cos(a),0,math.sin(a))
   local shard=part(fx,'ImpactSpark',color,Vector3.new(.25,2,.25));shard.Position=pos+dir*2;Debris:AddItem(shard,.8)
   Tween:Create(shard,TweenInfo.new(.7),{Position=pos+dir*radius+Vector3.new(0,(i%4)*1.5,0),Transparency=1,Size=Vector3.new(.05,.1,.05)}):Play()
  end
 end
 local function meteorImpact(pos,radius)
  burst(pos,radius,gold);ring(fx,Vector3.new(pos.X,.7,pos.Z),radius*.65,Color3.fromRGB(255,239,179),.45)
  local crater=part(fx,'MeteorScorch',Color3.fromRGB(33,24,28),Vector3.new(.09,radius*1.5,radius*1.5),Enum.PartType.Cylinder)
  crater.CFrame=CFrame.new(pos.X,.12,pos.Z)*CFrame.Angles(0,0,math.pi/2);crater.Material=Enum.Material.Slate;crater.Transparency=.25;Debris:AddItem(crater,5);Tween:Create(crater,TweenInfo.new(5),{Transparency=1}):Play()
  for i=1,18 do
   local a=i*math.pi/9;local dir=Vector3.new(math.cos(a),0,math.sin(a))
   local rock=part(fx,'MeteorDebris',Color3.fromRGB(63,42,39),Vector3.new(1.6+(i%3),1.4,2.2));rock.Material=Enum.Material.Slate;rock.CFrame=CFrame.new(pos+dir*3)*CFrame.Angles(i,i*.7,0);Debris:AddItem(rock,2.6)
   local peak=pos+dir*radius*.75+Vector3.new(0,5+i%5,0)
   Tween:Create(rock,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=peak,Orientation=Vector3.new(i*31,i*17,80)}):Play()
   task.delay(.35,function()if rock.Parent then Tween:Create(rock,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=pos+dir*radius,Transparency=1}):Play()end end)
  end
 end
 local function frostImpact(pos,radius)
  burst(pos,radius,ice)
  local flash=part(fx,'FrostWhiteFlash',Color3.fromRGB(232,255,255),Vector3.one*3);flash.Position=pos+Vector3.new(0,1.5,0);flash.Transparency=.3;Debris:AddItem(flash,.3)
  Tween:Create(flash,TweenInfo.new(.25),{Size=Vector3.one*radius*.9,Transparency=1}):Play()
  local light=Instance.new('PointLight');light.Color=ice;light.Range=radius*3;light.Brightness=5;light.Parent=flash;Tween:Create(light,TweenInfo.new(.25),{Brightness=0}):Play()
  for layer=1,3 do
   task.delay((layer-1)*.08,function()
    for i=1,36 do
     local a=i*math.pi/18;local dir=Vector3.new(math.cos(a),0,math.sin(a))
     local start=Vector3.new(pos.X,.4+layer*.12,pos.Z)+dir*2
     local p=edge(fx,layer==2 and Color3.fromRGB(233,255,255)or ice,.3);p.CFrame=CFrame.lookAt(start,start+dir)*CFrame.Angles(0,math.pi/2,0);p.Size=Vector3.new(.7,.18,.18);Debris:AddItem(p,.65)
     Tween:Create(p,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=start+dir*(radius-2),Size=Vector3.new(radius*.19,.06,.2),Transparency=1}):Play()
    end
   end)
  end
  local mist=part(fx,'FrostMist',ice,Vector3.one*.1);mist.Position=pos+Vector3.new(0,.7,0);mist.Transparency=1;Debris:AddItem(mist,1.8)
  local fog=Instance.new('ParticleEmitter');fog.Texture='rbxasset://textures/particles/smoke_main.dds';fog.Rate=0;fog.Lifetime=NumberRange.new(.55,1.2);fog.Speed=NumberRange.new(14,28);fog.SpreadAngle=Vector2.new(85,85);fog.EmissionDirection=Enum.NormalId.Top;fog.Drag=5;fog.Size=NumberSequence.new(4,10);fog.Color=ColorSequence.new(ice);fog.Transparency=NumberSequence.new(.72,1);fog.LightEmission=.4;fog.Parent=mist;fog:Emit(32)
  for i=1,24 do
   local a=i*math.pi/12;local distance=radius*(i%3==0 and .4 or .8);local height=5+i%4
   local p=Instance.new('WedgePart');p.Name='FrostCrown';p.Size=Vector3.new(.7,.1,1.8);p.CFrame=CFrame.new(pos+Vector3.new(math.cos(a)*distance,-1,math.sin(a)*distance))*CFrame.Angles(0,-a,.3);p.Color=i%3==0 and Color3.fromRGB(219,254,255)or ice;p.Material=Enum.Material.Glass;p.Transparency=.15;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,1.8)
   Tween:Create(p,TweenInfo.new(.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=Vector3.new(1.2,height,2.6),Position=p.Position+Vector3.new(0,height*.35,0)}):Play()
   task.delay(.65,function()if p.Parent then Tween:Create(p,TweenInfo.new(.8),{Transparency=1,Position=p.Position-Vector3.new(0,2,0)}):Play()end end)
  end
 end
 local function cast(anchor,kind)
  if kind=='skyLances' then skyLances.Cast(anchor);return end
  -- Instances created this frame can arrive after the remote; resolve a stable name.
  if type(anchor)=='string' then
   local runtime=workspace:WaitForChild('SummonerRuntime',3)
   anchor=runtime and runtime:WaitForChild(anchor,2)
  end
  if not anchor or not anchor.Parent then return end
  local model=Instance.new('Model');model.Name=kind..'Magic';model.Parent=fx
  local deadline=os.clock()+1
  while anchor.Parent and not anchor:GetAttribute('Duration') and os.clock()<deadline do task.wait()end
  local radius=anchor:GetAttribute('Radius');local duration=anchor:GetAttribute('Duration');local level=anchor:GetAttribute('Level')or 1
  if not anchor.Parent or not radius or not duration then model:Destroy();return end
  local color=kind=='meteor' and gold or(kind=='frost' and ice or(kind=='blades' and mint or Color3.fromRGB(255,222,152)))
  local arcs={};if kind~='blades' then for i=1,48 do arcs[i]=edge(model,color,.12)end end
  local pieces={};local cracks={};local shell,core,emitter
  local meteorSize=10+level*.6
  if kind=='meteor' then
   core=part(model,'MeteorBody',Color3.fromRGB(63,43,39),Vector3.one*meteorSize);core.Material=Enum.Material.Slate
   shell=part(model,'FlameAura',gold,Vector3.one*(meteorSize+1.2));shell.Transparency=.95
   local light=Instance.new('PointLight');light.Color=gold;light.Range=45;light.Brightness=4;light.Parent=core
   emitter=Instance.new('ParticleEmitter');emitter.Texture='rbxasset://textures/particles/fire_main.dds';emitter.Rate=120;emitter.Lifetime=NumberRange.new(.35,.65);emitter.Speed=NumberRange.new(7,13);emitter.EmissionDirection=Enum.NormalId.Top;emitter.SpreadAngle=Vector2.new(20,20);emitter.Size=NumberSequence.new(12,0);emitter.Color=ColorSequence.new(Color3.fromRGB(255,241,169),Color3.fromRGB(255,95,32));emitter.Transparency=NumberSequence.new(.15,1);emitter.LightEmission=.9;emitter.Parent=core
   for i=1,12 do
    local rock=part(model,'MeteorCrust',Color3.fromRGB(58+i*2,34+i,31),Vector3.new(4.4,3.2,5.1));rock.Material=Enum.Material.Slate;pieces[i]=rock
   end
   for i=1,18 do cracks[i]=edge(model,Color3.fromRGB(255,157,58),.18)end
   for i=1,3 do
    local a=Instance.new('Attachment');a.Position=Vector3.new(-meteorSize*.36,0,(i-2)*2);a.Parent=core
    local b=Instance.new('Attachment');b.Position=Vector3.new(meteorSize*.36,0,(i-2)*2);b.Parent=core
    local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.7;trail.Color=ColorSequence.new(Color3.fromRGB(255,241,180),Color3.fromRGB(255,92,33));trail.Transparency=NumberSequence.new(.25,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=1;trail.Parent=core
   end
  elseif kind=='blades' then
   for i=1,5 do
    local crystal=Instance.new('Model');crystal.Name='OrbitLight';crystal.Parent=model
    local pivot=part(crystal,'Pivot',mint,Vector3.one*.1);pivot.Transparency=1;crystal.PrimaryPart=pivot
    part(crystal,'LightCore',Color3.fromRGB(222,253,255),Vector3.one*.55)
    local glow=part(crystal,'LightHalo',Color3.fromRGB(112,202,255),Vector3.one*1.15);glow.Transparency=.8
    local outer=part(crystal,'SoftAura',Color3.fromRGB(108,135,255),Vector3.one*1.65);outer.Transparency=.93
    local light=Instance.new('PointLight');light.Color=Color3.fromRGB(129,209,255);light.Range=4;light.Brightness=.65;light.Parent=pivot
    local sparks=Instance.new('ParticleEmitter');sparks.Name='OrbStardust';sparks.Texture='rbxasset://textures/particles/sparkles_main.dds';sparks.Rate=8;sparks.Lifetime=NumberRange.new(.2,.45);sparks.Speed=NumberRange.new(.2,.8);sparks.SpreadAngle=Vector2.new(180,180);sparks.Size=NumberSequence.new(.12,0);sparks.Transparency=NumberSequence.new(.3,1);sparks.Color=ColorSequence.new(Color3.fromRGB(192,242,255));sparks.LightEmission=1;sparks.Parent=pivot
    pieces[i]=crystal
   end
  elseif kind=='ward' then
   shell=part(model,'GuardianDome',color,Vector3.new(9,10,9));shell.Material=Enum.Material.ForceField;shell.Transparency=.45
   for i=1,6 do pieces[i]=part(model,'GuardianRune',color,Vector3.new(.12,.8,.65),Enum.PartType.Block)end
  else
   shell=part(model,'FrostGathering',Color3.fromRGB(222,255,255),Vector3.one*4);shell.Transparency=.3
   local light=Instance.new('PointLight');light.Color=ice;light.Range=16;light.Brightness=2;light.Parent=shell
   for i=1,8 do pieces[i]=part(model,'GatheringShard',ice,Vector3.new(.3,1.1,.3),Enum.PartType.Block)end
  end
  local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;if model.Parent then model:Destroy()end end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent then clear();return end
   local center=anchor.Position;local t=anchor:GetAttribute('Elapsed')or 0;local u=math.clamp(t/duration,0,1)
   for i,p in ipairs(arcs)do
    local a=(i-1)*math.pi/24;local b=i*math.pi/24
    local r=radius*(kind=='meteor' and (.85+u*.15) or(kind=='frost' and .3+u*.7 or 1))
    local function point(angle)return center+Vector3.new(math.cos(angle)*r,.12,math.sin(angle)*r)end
    line(p,point(a),point(b),i%4==0 and .21 or .09);p.Transparency=kind=='blades' and .75 or .25
   end
   if kind=='meteor' then
    local fall=math.clamp((t-.35)/(duration-.35),0,1);local height=76*(1-fall)^1.3+meteorSize*.3
    local origin=center+Vector3.new(20*(1-fall),height,0)
    core.CFrame=CFrame.new(origin)*CFrame.Angles(t*.7,t*.8,t*.4);shell.CFrame=core.CFrame
    for i,p in ipairs(pieces)do
     local a=i*math.pi/6;local y=(i%3-1)*meteorSize*.24
     p.CFrame=core.CFrame*CFrame.new(math.cos(a)*meteorSize*.37,y,math.sin(a)*meteorSize*.37)*CFrame.Angles(i*.7,i*.4,i*.9)
    end
   for i,p in ipairs(cracks)do
     local a=i*math.pi/6;local y=math.sin(i*2.3)*.48
     local p1=Vector3.new(math.cos(a),y,math.sin(a)).Unit*meteorSize*.51
     local p2=Vector3.new(math.cos(a+.24),y+.12,math.sin(a+.24)).Unit*meteorSize*.51
     line(p,core.CFrame:PointToWorldSpace(p1),core.CFrame:PointToWorldSpace(p2),.18)
    end
   elseif kind=='blades' then
    local count=5;local fired=anchor:GetAttribute('Fired')or 0
    for i,crystal in ipairs(pieces)do
     local a=i/(count+1)*math.pi-math.pi/2
     crystal:PivotTo(anchor.CFrame*CFrame.new(math.sin(a)*4.2,3.2+math.cos(a)*1.7+math.sin(t*2+i)*.08,1.8)*CFrame.Angles(0,t*.5+i,0))
     for _,p in ipairs(crystal:GetDescendants())do
      if p:IsA('BasePart')and p.Name~='Pivot' then p.LocalTransparencyModifier=i<=fired and 1 or 0
      elseif p:IsA('ParticleEmitter')or p:IsA('PointLight')then p.Enabled=i>fired end
     end
    end
   elseif kind=='ward' then
    shell.Position=center+Vector3.new(0,2.6,0);shell.Transparency=.4+math.sin(t*4)*.06
    for i,p in ipairs(pieces)do local a=t*.7+i*math.pi/3;p.CFrame=CFrame.new(center+Vector3.new(math.cos(a)*4.3,3+math.sin(a*2)*.5,math.sin(a)*4.3))*CFrame.Angles(0,-a,math.pi/4)end
   else
    shell.Position=center+Vector3.new(0,1.7,0);shell.Size=Vector3.one*(4*(1-u)+.6)
    for i,p in ipairs(pieces)do local a=i*math.pi/4+t*5;local r=(1-u)*5+1;p.CFrame=CFrame.new(center+Vector3.new(math.cos(a)*r,1.5,math.sin(a)*r))*CFrame.Angles(t*3,a,math.pi/4)end
   end
  end)
 end
 return {Cast=cast,Burst=burst,MeteorImpact=meteorImpact,FrostImpact=frostImpact}
end
]====])
-- Source: src/client/combat/Effects.luau
addModule(modules,{"combat","Effects"},[====[
-- Client-only spell and summon presentation; never awards damage or XP.
return function(deps)
	local Players = game:GetService("Players")
	local RS = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local ContentProvider = game:GetService("ContentProvider")
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local player, net, gui = deps.player, deps.net, deps.gui
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, label = theme.Palette, theme.Make, theme.Label
	local fx=deps.folder
	if not fx then fx=Instance.new("Folder");fx.Name="SummonerLocalEffects";fx.Parent=workspace end
	local art=require(script.Parent.SpellArt)({folder=fx})
	local areaArt=require(script.Parent.AreaArt)({folder=fx})
	local activeArt=require(script.Parent.ActiveArt)({folder=fx})
	local projectileArt=require(script.Parent.ProjectileArt)({folder=fx})
 local fireArt=require(script.Parent.FireArt)({folder=fx})
	local bloom=Lighting:FindFirstChild("SummonerSpellBloom")
	if not bloom then
		bloom=Instance.new("BloomEffect");bloom.Name="SummonerSpellBloom";bloom.Intensity=.22;bloom.Size=22;bloom.Threshold=1.35;bloom.Parent=Lighting
	end
	-- Bundled Roblox textures loaded successfully in this project; see ASSET_CREDITS.md.
	local smokeTexture="rbxasset://textures/particles/smoke_main.dds"
	task.spawn(function()
		local ok=pcall(function()
			ContentProvider:PreloadAsync({smokeTexture},function(_,status)
				gui:SetAttribute("SmokeTextureStatus",status.Name)
				if status~=Enum.AssetFetchStatus.Success then smokeTexture="rbxasset://textures/particles/smoke_main.dds" end
			end)
		end)
		if not ok then smokeTexture="rbxasset://textures/particles/smoke_main.dds" end
	end)
	local function visual(size,cf,color,shape,lifetime)
		local p=Instance.new("Part"); p.Size=size; p.CFrame=cf; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Material=Enum.Material.Neon; p.Color=color
		p.Shape=shape or Enum.PartType.Ball; p.Parent=fx; Debris:AddItem(p,lifetime or 1); return p
	end
	local function ring(pos,radius,color)
		local p=visual(Vector3.new(.12,1,1),CFrame.new(pos.X,.2,pos.Z)*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder)
		p.Transparency=.25
		TweenService:Create(p,TweenInfo.new(.4),{Size=Vector3.new(.12,radius*2,radius*2),Transparency=1}):Play()
	end
	local function dustBurst(point,direction,heavy)
		local host=visual(Vector3.new(.1,.1,.1),CFrame.lookAt(point,point+direction),palette.gold,nil,2)
		host.Name="SlamDust"; host.Transparency=1
		local emitter=Instance.new("ParticleEmitter")
		emitter.Name="ImpactDust"; emitter.Texture=smokeTexture; emitter.Rate=0
		emitter.Lifetime=NumberRange.new(.45,heavy and 1.1 or .7)
		emitter.Speed=NumberRange.new(heavy and 8 or 3,heavy and 15 or 7)
		emitter.EmissionDirection=Enum.NormalId.Front; emitter.SpreadAngle=Vector2.new(25,18)
		emitter.Acceleration=Vector3.new(0,3,0); emitter.Drag=3
		emitter.Rotation=NumberRange.new(0,360); emitter.RotSpeed=NumberRange.new(-70,70)
		emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,heavy and 2.8 or 1.3),NumberSequenceKeypoint.new(.45,heavy and 5 or 2.5),NumberSequenceKeypoint.new(1,heavy and 6.5 or 3)})
		emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.45),NumberSequenceKeypoint.new(.4,.65),NumberSequenceKeypoint.new(1,1)})
		emitter.Color=ColorSequence.new(Color3.fromRGB(181,164,132),Color3.fromRGB(110,122,124))
		emitter.LightEmission=.08; emitter.LightInfluence=.8; emitter.Parent=host
		emitter:Emit(heavy and 5 or 3)
	end
	local function shockwave(pos,radius,color,heavy)
		local count=heavy and 24 or 12
		local center=Vector3.new(pos.X,.19,pos.Z)
		for i=1,count do
			local a=i*math.pi*2/count
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			local start=center+dir*1.7
			local finish=center+dir*radius
			local p=visual(Vector3.new(.8,.1,.18),CFrame.lookAt(start,start+dir),color,Enum.PartType.Block)
			p.Name="SlamShockwave";p.Transparency=.12
			TweenService:Create(p,TweenInfo.new(heavy and .5 or .32,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.lookAt(finish,finish+dir),Size=Vector3.new(math.pi*2*radius/count*.91,.06,.12),Transparency=1}):Play()
		end
	end
	local function chargeGolem(pet,duration)
		if typeof(pet)~="Instance" or not pet.Parent then return end
		for _,name in ipairs({"LeftArm","RightArm"}) do
			local arm=pet:FindFirstChild(name)
			if arm then
				local attachment=Instance.new("Attachment"); attachment.Name="SlamCharge";attachment.Position=Vector3.new(0,-arm.Size.Y*.4,0);attachment.Parent=arm;Debris:AddItem(attachment,duration+1)
				local light=Instance.new("PointLight");light.Color=palette.gold;light.Range=9;light.Brightness=1.5;light.Parent=attachment
				local sparks=Instance.new("ParticleEmitter");sparks.Texture="rbxasset://textures/particles/sparkles_main.dds";sparks.Rate=25;sparks.Lifetime=NumberRange.new(.15,.35);sparks.Speed=NumberRange.new(1,4);sparks.SpreadAngle=Vector2.new(180,180);sparks.Size=NumberSequence.new(.45,0);sparks.Transparency=NumberSequence.new(0,1);sparks.Color=ColorSequence.new(palette.gold,palette.mint);sparks.LightEmission=1;sparks.Parent=attachment
				task.delay(duration,function()if attachment.Parent then sparks.Enabled=false;TweenService:Create(light,TweenInfo.new(.2),{Brightness=0}):Play() end end)
			end
		end
	end
	local function groundImpact(pos,radius,heavy,level)
		local color=heavy and palette.gold or palette.mint
		shockwave(pos,radius,color,heavy)
		if heavy then task.delay(.07,function()shockwave(pos,radius*.72,palette.mint,true)end) end
		local flash=visual(Vector3.new(1,.5,1),CFrame.new(pos.X,.4,pos.Z),color)
		flash.Name="SlamFlash"
		TweenService:Create(flash,TweenInfo.new(.18),{Size=Vector3.new(heavy and 7 or 3,.2,heavy and 7 or 3),Transparency=1}):Play()
		if heavy then
			local light=Instance.new("PointLight");light.Color=color;light.Range=20;light.Brightness=3;light.Parent=flash;TweenService:Create(light,TweenInfo.new(.2),{Brightness=0}):Play()
		end
		for i=1,(heavy and 10 or 4) do
			local a=i*math.pi*2/(heavy and 10 or 4)
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			dustBurst(Vector3.new(pos.X,.7,pos.Z)+dir*1.5,dir,heavy)
		end
		local count=heavy and 10 or 4
		for i=1,count do
			local a=i*math.pi*2/count
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			local point=Vector3.new(pos.X,.35,pos.Z)+dir*(heavy and 2.5 or 1.3)
			local size=heavy and 1.25 or .6
			local rock=visual(Vector3.new(size*1.3,size*.7,size),CFrame.new(point)*CFrame.Angles(a,a*.7,a*.3),Color3.fromRGB(105,121,123),Enum.PartType.Block)
			rock.Material=Enum.Material.Slate
			local land=point+dir*radius*.55
			TweenService:Create(rock,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=land+Vector3.new(0,heavy and 3 or 1.4,0)}):Play()
			task.delay(.22,function()
				if rock.Parent then TweenService:Create(rock,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=land,Transparency=1}):Play() end
			end)
			local midpoint=Vector3.new(pos.X,.12,pos.Z)+dir*radius*.38
			local crack=visual(Vector3.new(heavy and .22 or .12,.05,radius*.55),CFrame.lookAt(midpoint,midpoint+dir),Color3.fromRGB(16,23,25),Enum.PartType.Block)
			crack.Material=Enum.Material.Slate
			TweenService:Create(crack,TweenInfo.new(.8),{Transparency=1}):Play()
		end
		local templates=RS:FindFirstChild("SummonerVFXAssets")
		local spikes=templates and templates:FindFirstChild("GroundSpikes")
		if heavy and spikes and spikes:IsA("MeshPart") then
			local mound=spikes:Clone();mound.Name="SlamGroundSpikes";mound.Size=Vector3.new(radius*.75,3.6,radius*.75);mound.CFrame=CFrame.new(pos.X,-1.8,pos.Z)*CFrame.Angles(0,math.random()*math.pi,0);mound.Color=Color3.fromRGB(74,92,91);mound.Material=Enum.Material.Slate;mound.Transparency=0;mound.Parent=fx;Debris:AddItem(mound,1.8)
			TweenService:Create(mound,TweenInfo.new(.12,Enum.EasingStyle.Back),{Position=Vector3.new(pos.X,.7,pos.Z)}):Play()
			task.delay(.8,function()if mound.Parent then TweenService:Create(mound,TweenInfo.new(.7),{Position=Vector3.new(pos.X,-2.5,pos.Z),Transparency=1}):Play() end end)
		end
		if heavy and level>=3 then
			for i=1,6 do
				local a=i*math.pi/3
				local point=Vector3.new(pos.X,-1,pos.Z)+Vector3.new(math.cos(a),0,math.sin(a))*radius*.75
				local shard=visual(Vector3.new(1.7,3.3,1.7),CFrame.new(point)*CFrame.Angles(.2,a,.2),Color3.fromRGB(100,137,128),Enum.PartType.Block)
				shard.Material=Enum.Material.Slate
				TweenService:Create(shard,TweenInfo.new(.15,Enum.EasingStyle.Back),{Position=point+Vector3.new(0,2.1,0)}):Play()
				task.delay(.4,function() if shard.Parent then TweenService:Create(shard,TweenInfo.new(.4),{Position=point,Transparency=1}):Play() end end)
			end
		end
	end
	local function spellBurst(pos,texture,color,count,size,speed)
		local host=visual(Vector3.new(.1,.1,.1),CFrame.new(pos),color,nil,1.5)
		host.Name="SpellParticles";host.Transparency=1
		local p=Instance.new("ParticleEmitter");p.Texture=texture;p.Rate=0
		p.Color=ColorSequence.new(color,Color3.fromRGB(242,248,255))
		p.Lifetime=NumberRange.new(.2,.6);p.Speed=NumberRange.new(speed*.4,speed)
		p.SpreadAngle=Vector2.new(180,180);p.Drag=3
		p.Size=NumberSequence.new(size,0);p.Transparency=NumberSequence.new(.1,1)
		p.Rotation=NumberRange.new(0,360);p.RotSpeed=NumberRange.new(-90,90)
		p.LightEmission=.8;p.Parent=host;p:Emit(count)
		return host
	end
	local function spellGlow(pos,color,size)
		local host=spellBurst(pos,"rbxasset://textures/particles/forcefield_glow_main.dds",color,1,size,0)
		host.Name="SpellGlow"
		local p=host:FindFirstChildOfClass("ParticleEmitter")
		p.Lifetime=NumberRange.new(.22,.35);p.Size=NumberSequence.new(size,size*1.7);p.Transparency=NumberSequence.new(.35,1);p.LightEmission=1;p:Clear();p:Emit(1)
	end
	local function runeCircle(pos,radius,color,lifetime)
		local center=Vector3.new(pos.X,.16,pos.Z)
		for i=1,16 do
			local a=i*math.pi*2/16
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			local point=center+dir*radius
			local p=visual(Vector3.new(radius*.32,.055,.07),CFrame.lookAt(point,point+dir),color,Enum.PartType.Block,lifetime+.1)
			p.Name="SpellRune";p.Transparency=.25
			TweenService:Create(p,TweenInfo.new(lifetime),{Transparency=1}):Play()
			if i%4==0 then
				local glyph=visual(Vector3.new(.35,.055,.35),CFrame.new(center+dir*(radius+.6))*CFrame.Angles(0,math.pi/4,0),color,Enum.PartType.Block,lifetime+.1)
				glyph.Name="SpellRune";TweenService:Create(glyph,TweenInfo.new(lifetime),{Transparency=1,Size=Vector3.new(.07,.055,.07)}):Play()
			end
		end
	end
	local fireTexture="rbxasset://textures/particles/fire_main.dds"
	local emberTexture="rbxasset://textures/particles/fire_sparks_main.dds"
	task.spawn(function()
		ContentProvider:PreloadAsync({fireTexture,emberTexture},function(asset,status)
			gui:SetAttribute(asset==fireTexture and "FireTextureStatus" or "EmberTextureStatus",status.Name)
		end)
	end)
	local function flameEmitter(host,core)
		local p=Instance.new("ParticleEmitter");p.Name=core and "FlameHeart" or "FlameTongues";p.Texture=fireTexture
		p.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp
		p.EmissionDirection=Enum.NormalId.Top;p.SpreadAngle=Vector2.new(28,28)
		p.Lifetime=core and NumberRange.new(.18,.32) or NumberRange.new(.32,.55)
		p.Speed=core and NumberRange.new(2,4) or NumberRange.new(4,8)
		p.Acceleration=Vector3.new(0,6,0);p.Drag=1;p.VelocityInheritance=0
		p.Rotation=NumberRange.new(-12,12);p.RotSpeed=NumberRange.new(-25,25)
		p.Color=core and ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,243,170)),ColorSequenceKeypoint.new(.45,Color3.fromRGB(255,193,57)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,93,25))}) or ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,194,49)),ColorSequenceKeypoint.new(.35,Color3.fromRGB(255,104,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(204,37,25))})
		p.Size=core and NumberSequence.new({NumberSequenceKeypoint.new(0,.6),NumberSequenceKeypoint.new(.25,1.5,.3),NumberSequenceKeypoint.new(1,0)}) or NumberSequence.new({NumberSequenceKeypoint.new(0,1.2,.2),NumberSequenceKeypoint.new(.3,2.7,.5),NumberSequenceKeypoint.new(.65,2.1,.4),NumberSequenceKeypoint.new(1,0)})
		p.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(.12,.05),NumberSequenceKeypoint.new(.55,.2),NumberSequenceKeypoint.new(1,1)})
		p.LightEmission=.8;p.LightInfluence=0;p.Rate=core and 24 or 42;p.Parent=host
		return p
	end
	local function fireWave(origin,direction,range)
        fireArt.Wave(origin,direction,range)
    end

	local function magicBolt(a,b,radius)
        fireArt.Bolt(a,b,radius)
    end

	local function dashEffect(character,duration,direction)
		if typeof(character)~="Instance" or not character.Parent then return end
		local root=character:FindFirstChild("HumanoidRootPart");if not root then return end
		local a=Instance.new("Attachment");a.Position=Vector3.new(-.8,0,0);a.Parent=root;Debris:AddItem(a,duration+.4)
		local b=Instance.new("Attachment");b.Position=Vector3.new(.8,0,0);b.Parent=root;Debris:AddItem(b,duration+.4)
		local trail=Instance.new("Trail");trail.Name="DashRibbon";trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.18;trail.MinLength=.05;trail.Color=ColorSequence.new(Color3.fromRGB(216,251,255),Color3.fromRGB(116,176,255));trail.Transparency=NumberSequence.new(.45,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=.8;trail.Parent=a
		spellBurst(root.Position,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(159,223,255),8,.25,5)
		task.spawn(function()
			for frame=1,3 do
				if not character.Parent then break end
				local count=0
				for _,part in ipairs(character:GetDescendants())do
					if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and count<16 then
						local ghost=part:Clone()
						if ghost then
							for _,child in ipairs(ghost:GetChildren())do if not child:IsA("SpecialMesh") then child:Destroy() elseif child:IsA("SpecialMesh") then child.TextureId="" end end
							ghost.Name="ArcaneDashGhost";ghost.Anchored=true;ghost.CanCollide=false;ghost.CanTouch=false;ghost.CanQuery=false;ghost.CastShadow=false;ghost.Color=Color3.fromRGB(139,206,255);ghost.Material=Enum.Material.Neon;ghost.Transparency=.72
							if ghost:IsA("MeshPart") then ghost.TextureID="" end
							ghost.Parent=fx;Debris:AddItem(ghost,.32);TweenService:Create(ghost,TweenInfo.new(.3),{Transparency=1}):Play();count+=1
						end
					end
				end
				task.wait(.065)
			end
		end)
		task.delay(duration,function()if trail.Parent then trail.Enabled=false end end)
	end
	local function lightningBolt(a,b,hop)
		local blue=Color3.fromRGB(65,164,255);local white=Color3.fromRGB(230,251,255)
		local function ground(pos)
			local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
			local excluded={fx};local runtime=workspace:FindFirstChild("SummonerRuntime");if runtime then table.insert(excluded,runtime)end
			for _,plr in ipairs(Players:GetPlayers())do if plr.Character then table.insert(excluded,plr.Character)end end
			params.FilterDescendantsInstances=excluded;params.RespectCanCollide=true
			local hit=workspace:Raycast(pos+Vector3.new(0,8,0),Vector3.new(0,-50,0),params)
			return hit and hit.Position+Vector3.new(0,.12,0) or Vector3.new(pos.X,.15,pos.Z)
		end
		local function segment(start,finish,width,color,alpha,delay)
			local length=(finish-start).Magnitude;if length<.01 then return end
			task.delay(delay,function()
				local p=visual(Vector3.new(width,width,length),CFrame.lookAt((start+finish)/2,finish),color,Enum.PartType.Block,.48)
				p.Name="ChainLightning";p.Transparency=alpha
				task.delay(.09,function()if p.Parent then TweenService:Create(p,TweenInfo.new(.28),{Transparency=1}):Play()end end)
			end)
		end
		local function line(start,finish,width,delay)
			segment(start,finish,width,blue,.5,delay);segment(start,finish,width*.32,white,.02,delay)
		end
		local landing=ground(b)
		if (hop or 1)==1 then
			-- The upper leader arrives first, then the flash and floor discharge.
			local top=landing+Vector3.new(0,22,0);local points={top}
			for i=1,7 do table.insert(points,top:Lerp(landing,i/8)+Vector3.new((i%2==0 and 1 or -1)*(1.1+math.random()),0,(math.random()-.5)*1.6))end
			table.insert(points,landing)
			for i=1,#points-1 do
				line(points[i],points[i+1],.85,(i-1)*.008)
				if i==3 or i==5 then
					local branch=points[i]+Vector3.new(i==3 and 3 or -3,-3,1)
					line(points[i],branch,.25,(i-1)*.008)
				end
			end
			task.delay(.11,function()for i=1,#points-1 do line(points[i],points[i+1],.4,0)end end)
		else
			local start=ground(a);local delta=landing-start;local side=Vector3.new(-delta.Z,0,delta.X)
			if side.Magnitude>.01 then side=side.Unit else side=Vector3.xAxis end
			local last=start
			for i=1,6 do
				local point=i==6 and landing or start+delta*(i/6)+side*(i%2==0 and 1 or -1)*.75
				line(last,point,.45,.055+i*.012);last=point
			end
		end
		-- Radial arcs crawl out from the impact over the floor.
		for ray=1,6 do
			local angle=ray*math.pi/3+math.random()*.35
			local dir=Vector3.new(math.cos(angle),0,math.sin(angle));local side=Vector3.new(-dir.Z,0,dir.X)
			local last=landing
			for step=1,4 do
				local point=ground(landing+dir*(step*1.55)+side*((step%2==0 and 1 or -1)*.55))
				line(last,point,.32*(1-step*.12),.065+step*.025);last=point
			end
		end
		task.delay(.065,function()
			spellGlow(landing,blue,5)
			local host=spellBurst(landing+Vector3.new(0,.3,0),"rbxasset://textures/particles/sparkles_main.dds",blue,18,.5,10)
			local light=Instance.new("PointLight");light.Color=blue;light.Range=15;light.Brightness=3;light.Parent=host;TweenService:Create(light,TweenInfo.new(.35),{Brightness=0}):Play()
			spellGlow(b,white,2.5)
		end)
	end
	local function iceShard(size,cf,color,lifetime)
		local p=Instance.new("WedgePart");p.Name="IceCrystal";p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=.15
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,lifetime or .7)
		return p
	end
	local function icePortal(cf,charge)
		local portal=Instance.new("Folder");portal.Name="IceCastingCircle";portal.Parent=fx
		local function glyph(size,localCF,color,delay)
			local p=Instance.new("Part");p.Name="FrostSigil";p.Size=size;p.CFrame=cf*localCF;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=portal
			task.delay(delay,function()if p.Parent then TweenService:Create(p,TweenInfo.new(.08),{Transparency=.18}):Play()end end)
		end
		for ring=1,2 do
			local count=ring==1 and 32 or 24
			local radius=ring==1 and 2.45 or 1.85
			for i=1,count do
				local a=(i-1)*math.pi*2/count
				local localCF=CFrame.new(math.cos(a)*radius,math.sin(a)*radius,0)*CFrame.Angles(0,0,a+math.pi/2)
				glyph(Vector3.new(math.pi*2*radius/count*.92,.055,.055),localCF,ring==1 and Color3.fromRGB(117,215,255)or Color3.fromRGB(213,251,255),(i-1)/count*charge*.7+(ring-1)*.05)
			end
		end
		for i=1,6 do
			local a=i*math.pi/3
			glyph(Vector3.new(.27,.27,.055),CFrame.new(math.cos(a)*2.95,math.sin(a)*2.95,0)*CFrame.Angles(0,0,a+math.pi/4),Color3.fromRGB(190,237,255),charge*.55)
		end
		for i=0,2 do glyph(Vector3.new(.055,2.6,.055),CFrame.Angles(0,0,i*math.pi/3),Color3.fromRGB(162,231,255),charge*.3)end
		spellGlow(cf.Position,Color3.fromRGB(134,218,255),2.4)
		return portal
	end
	local function iceProjectile(anchorName,portalCF,charge)
		if typeof(portalCF)~="CFrame" then return end
		local anchor=anchorName
		if type(anchorName)=="string" then
			local runtime=workspace:FindFirstChild("SummonerRuntime")
			anchor=runtime and (runtime:FindFirstChild(anchorName) or runtime:WaitForChild(anchorName,2))
		end
		if typeof(anchor)~="Instance" then return end
		if not anchor or not anchor.Parent then return end
		local portal=icePortal(portalCF,charge)
		local spear=Instance.new("Model");spear.Name="GlacialSpear";spear.Parent=fx
		local initial=anchor.CFrame
		local function piece(class,name,size,offset,color,material,transparency)
			local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=initial*offset;p.Color=color;p.Material=material;p.Transparency=transparency;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=spear
			return p
		end
		local pivot=piece("Part","SpearPivot",Vector3.new(.05,.05,.05),CFrame.new(),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1);spear.PrimaryPart=pivot
		-- Each triangular face is split at its altitude into two thin wedges.
		-- A closed diamond cross-section tapers to a real point at both ends.
		local function face(a,b,c,color)
			local ab,ac,bc=b-a,c-a,c-b
			local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
			if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
			ab,ac,bc=b-a,c-a,c-b
			local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
			local height=math.abs(ab:Dot(up))
			local function half(v,axis,depth)
				if depth<.005 then return end
				piece("WedgePart","IceSpearFacet",Vector3.new(.025,height,depth),CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back),color,Enum.Material.Glass,.16).Reflectance=.08
			end
			half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
		end
		local tip=Vector3.new(0,0,-6.5);local tail=Vector3.new(0,0,1.4)
		local ring={Vector3.new(.9,0,-2.2),Vector3.new(0,.9,-2.2),Vector3.new(-.9,0,-2.2),Vector3.new(0,-.9,-2.2)}
		local function edge(a,b)
			piece("Part","IceSpearRidge",Vector3.new(.045,.045,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(184,241,255),Enum.Material.Neon,.18)
		end
		for i=1,4 do
			local a,b=ring[i],ring[i%4+1]
			local color=i%2==0 and Color3.fromRGB(173,230,255) or Color3.fromRGB(75,162,230)
			face(tip,a,b,color);face(tail,b,a,color)
			edge(tip,a);edge(tail,a);edge(a,b)
		end
		local left=Instance.new("Attachment");left.Position=Vector3.new(-.6,0,0);left.Parent=pivot
		local right=Instance.new("Attachment");right.Position=Vector3.new(.6,0,0);right.Parent=pivot
		local trail=Instance.new("Trail");trail.Name="GlacialSpearTrail";trail.Attachment0=left;trail.Attachment1=right;trail.Enabled=false;trail.Lifetime=.25;trail.MinLength=.1;trail.Color=ColorSequence.new(Color3.fromRGB(220,252,255),Color3.fromRGB(109,177,255));trail.Transparency=NumberSequence.new(.25,1);trail.WidthScale=NumberSequence.new(.7,0);trail.LightEmission=.8;trail.Parent=pivot
		spear:ScaleTo(.12)
		local scale=Instance.new("NumberValue");scale.Value=.12;scale.Parent=spear
		local scaleConn=scale.Changed:Connect(function(value)if spear.Parent then spear:ScaleTo(value)end end)
		TweenService:Create(scale,TweenInfo.new(charge*.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=1}):Play()
		local launched=false
		local renderConn,destroyConn
		local function clear()
			if renderConn then renderConn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;scaleConn:Disconnect()
			if portal.Parent then portal:Destroy()end;if spear.Parent then spear:Destroy()end
		end
		destroyConn=anchor.Destroying:Connect(clear)
		renderConn=RunService.RenderStepped:Connect(function(dt)
			if not anchor.Parent then clear();return end
			spear:PivotTo(spear:GetPivot():Lerp(anchor.CFrame,1-math.exp(-dt*35)))
			if not launched and anchor:GetAttribute("Launched") then
				launched=true;trail.Enabled=true
				spellBurst(portalCF.Position,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(191,242,255),14,.3,4)
				for _,p in ipairs(portal:GetChildren())do if p:IsA("BasePart")then TweenService:Create(p,TweenInfo.new(.25),{Transparency=1}):Play()end end
				Debris:AddItem(portal,.3)
			end
		end)
	end
	local function iceImpact(model,pos,duration)
		spellGlow(pos,Color3.fromRGB(145,223,255),4)
		runeCircle(pos,2.8,Color3.fromRGB(133,235,255),.7)
		local mist=spellBurst(pos,smokeTexture,Color3.fromRGB(149,211,240),7,1.5,3)
		local fog=mist:FindFirstChildOfClass("ParticleEmitter");fog.LightEmission=.25;fog.Size=NumberSequence.new(1.2,3.8);fog.Transparency=NumberSequence.new(.7,1)
		spellBurst(pos,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(200,246,255),22,.4,8)
		shockwave(pos,3.8,Color3.fromRGB(166,238,255),false)
		for i=1,10 do
			local angle=i*math.pi*2/10
			local dir=Vector3.new(math.cos(angle),0,math.sin(angle))
			local p=iceShard(Vector3.new(.35,1.1+(i%3)*.25,.5),CFrame.new(pos+dir*.6)*CFrame.Angles(.2,angle,.3),i%2==0 and Color3.fromRGB(190,251,255) or Color3.fromRGB(109,181,255),.7)
			TweenService:Create(p,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=pos+dir*3.5+Vector3.new(0,.4,0),Transparency=1}):Play()
		end
		if typeof(model)=="Instance" and model.Parent then
			local old=model:FindFirstChild("SpellFreezeHighlight");if old then old:Destroy() end
			local h=Instance.new("Highlight");h.Name="SpellFreezeHighlight";h.Adornee=model;h.FillColor=Color3.fromRGB(109,207,255);h.OutlineColor=Color3.fromRGB(223,251,255);h.FillTransparency=.42;h.OutlineTransparency=.12;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model
			local conn,destroyConn
			local function clear()
				if conn then conn:Disconnect() end;if destroyConn then destroyConn:Disconnect() end
				if h.Parent then h:Destroy() end
			end
			conn=model:GetAttributeChangedSignal("Frozen"):Connect(function()if not model:GetAttribute("Frozen") then clear() end end)
			destroyConn=model.Destroying:Connect(clear)
			-- Handles a late event arriving after the replicated frozen state has cleared.
			task.delay(duration+.2,function()if model.Parent and not model:GetAttribute("Frozen") then clear() end end)
		end
	end
	local function play(kind,a,b,c)
		if not fx.Parent then return end
		if kind=="hit" then
			local p=visual(Vector3.new(.05,.05,.05),CFrame.new(a+Vector3.new(0,3,0)),palette.text); p.Transparency=1
			local billboard=make("BillboardGui",p,{Size=UDim2.fromOffset(70,32),AlwaysOnTop=true,Adornee=p})
			local number=label(billboard,tostring(b),UDim2.fromScale(1,1),nil,Enum.Font.GothamBold,palette.gold); number.TextSize=18
			TweenService:Create(p,TweenInfo.new(.55),{Position=p.Position+Vector3.new(0,2,0)}):Play(); TweenService:Create(number,TweenInfo.new(.55),{TextTransparency=1}):Play()
		elseif kind=="dragonSlam" then art.Slam(a,b)
        elseif kind=="dragonTailSpin" then art.TailSpin(a,b,c)
        elseif kind=="dragonFireLine" then fireArt.FireLine(a,b,c)
        elseif kind=="dragonCharge" then fireArt.Charge(a,b)
        elseif kind=="dragonBreath" then fireArt.Breath(a,b,c)
        elseif kind=="dragonAirBreath" then fireArt.AirBreath(a,b,c)
        elseif kind=="dragonEruption" then art.Rupture(a,b,false)
        elseif kind=="enemyExplosion" then art.Rupture(a,b,true)
        elseif kind=="dragonDive" then art.Dive(a,b)
        elseif kind=="dragonArrival" then art.Rupture(a,b,false)
        elseif kind=="golemCharge" then chargeGolem(a,b)
		elseif kind=="golemHeavy" or kind=="golemLight" then groundImpact(a,b,kind=="golemHeavy",c)
		elseif kind=="dash" then dashEffect(a,b,c)
		elseif kind=="fire" then magicBolt(a,b,c)
		elseif kind=="fireWave" then
			fireWave(a,b,c)
		elseif kind=="lightning" then
			task.delay(math.min(.3,math.max(0,(c or 1)-1)*.045),function()lightningBolt(a,b,c)end)
		elseif kind=="thunderSpear" then projectileArt.Cast(a,"thunder")
		elseif kind=="aetherSpear" then projectileArt.Cast(a,"aetherLance")
		elseif kind=="aetherHit" then projectileArt.Impact(a,"aetherLance")
		elseif kind=="crystalBolt" then projectileArt.Cast(a,"crystal")
		elseif kind=="skyLanceHit" then areaArt.Burst(a,b,Color3.fromRGB(157,204,255))
		elseif kind=="crystalHit" then projectileArt.Impact(a,"crystal")
		elseif kind=="homingMissile" then projectileArt.Cast(a,"missile")
		elseif kind=="thunderHit" then projectileArt.Impact(a,"thunder")
		elseif kind=="missileHit" then projectileArt.Impact(a,"missile")
		elseif kind=="activeCast" then activeArt.Charge(a,b)
		elseif kind=="activeStrike" then activeArt.Strike(a,b,c)
		elseif kind=="areaCast" then areaArt.Cast(a,b)
		elseif kind=="meteorHit" then art.Rupture(a,b,false);areaArt.MeteorImpact(a,b)
		elseif kind=="frostHit" then areaArt.FrostImpact(a,b)
		elseif kind=="wardHit" then areaArt.Burst(a,b and 5 or 2.5,Color3.fromRGB(255,222,152))
		elseif kind=="iceCast" then iceProjectile(a,b,c)
		elseif kind=="iceHit" then iceImpact(a,b,c)
		end
	end
	local connection
	if deps.listen~=false then connection=net.Effect.OnClientEvent:Connect(play) end

	return {
		Folder = fx,
		Play = play,
		Disconnect = function()if connection then connection:Disconnect();connection=nil end end,
	}
end
]====])
-- Source: src/client/combat/FireArt.luau
addModule(modules,{"combat","FireArt"},[====[
-- Adapted layering from AetherFX Fire Bolt / Lesser Fireball (MIT).
-- See assets/vfx/aetherfx/LICENSE and the pinned reference recipes.
return function(deps)
 local Tween=game:GetService('TweenService');local Run=game:GetService('RunService');local Debris=game:GetService('Debris')
 local fx=deps.folder
 local flame='rbxasset://textures/particles/fire_main.dds';local smoke='rbxasset://textures/particles/smoke_main.dds';local ember='rbxasset://textures/particles/fire_sparks_main.dds'
 local orange=Color3.fromRGB(255,124,32);local red=Color3.fromRGB(195,43,18)
 local function host(name,cf,life)
  local p=Instance.new('Part');p.Name=name;p.Size=Vector3.one*.15;p.CFrame=cf;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,life);return p
 end
 local function emitter(p,texture,rate,lifetime,size,color)
  local e=Instance.new('ParticleEmitter');e.Texture=texture;e.Rate=rate;e.Lifetime=lifetime;e.Size=size;e.Color=color;e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.65,.35),NumberSequenceKeypoint.new(1,1)});e.LightEmission=.7;e.LightInfluence=0;e.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;e.Rotation=NumberRange.new(-35,35);e.RotSpeed=NumberRange.new(-90,90);e.SpreadAngle=Vector2.new(20,20);e.EmissionDirection=Enum.NormalId.Back;e.Speed=NumberRange.new(3,7);e.Drag=1;e.Parent=p;return e
 end
 local colors=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,224,140)),ColorSequenceKeypoint.new(.35,orange),ColorSequenceKeypoint.new(1,red)})
 local function impact(point,radius)
  local p=host('FireballImpact',CFrame.new(point),1.4)
  local fire=emitter(p,flame,0,NumberRange.new(.22,.55),NumberSequence.new({NumberSequenceKeypoint.new(0,1.2),NumberSequenceKeypoint.new(.25,radius),NumberSequenceKeypoint.new(1,0)}),colors);fire.Speed=NumberRange.new(5,13);fire.SpreadAngle=Vector2.new(180,180);fire.Acceleration=Vector3.new(0,5,0);fire:Emit(18)
  local sparks=emitter(p,ember,0,NumberRange.new(.3,.7),NumberSequence.new(.5,0),ColorSequence.new(orange));sparks.Speed=NumberRange.new(9,18);sparks.SpreadAngle=Vector2.new(180,180);sparks.Acceleration=Vector3.new(0,-14,0);sparks:Emit(18)
  local soot=emitter(p,smoke,0,NumberRange.new(.45,1),NumberSequence.new(1,radius*1.5),ColorSequence.new(Color3.fromRGB(66,53,48)));soot.LightEmission=0;soot.Transparency=NumberSequence.new(.6,1);soot.Speed=NumberRange.new(2,5);soot.Acceleration=Vector3.new(0,4,0);soot:Emit(6)
  local light=Instance.new('PointLight');light.Color=orange;light.Range=radius*4;light.Brightness=2;light.Parent=p;Tween:Create(light,TweenInfo.new(.25),{Brightness=0}):Play()
 end
 local function bolt(a,b,radius)
  local distance=(b-a).Magnitude;if distance<.1 then return end
  local p=host('MoltenFireball',CFrame.lookAt(a,b),1.6);p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*.55;p.Color=Color3.fromRGB(255,143,35);p.Material=Enum.Material.Neon;p.Transparency=0
  local sheath=emitter(p,flame,160,NumberRange.new(.2,.38),NumberSequence.new({NumberSequenceKeypoint.new(0,1.4),NumberSequenceKeypoint.new(.25,3),NumberSequenceKeypoint.new(1,0)}),colors);sheath.Speed=NumberRange.new(1,4);sheath:Emit(12)
  local core=emitter(p,flame,70,NumberRange.new(.1,.18),NumberSequence.new(1.1,0),ColorSequence.new(Color3.fromRGB(255,225,153),orange));core.Speed=NumberRange.new(0,2)
  local tail=emitter(p,ember,35,NumberRange.new(.2,.45),NumberSequence.new(.5,0),ColorSequence.new(orange));tail.Speed=NumberRange.new(6,12)
  local soot=emitter(p,smoke,18,NumberRange.new(.25,.55),NumberSequence.new(1.1,2.8),ColorSequence.new(Color3.fromRGB(65,49,42)));soot.LightEmission=0;soot.Transparency=NumberSequence.new(.7,1)
  local light=Instance.new('PointLight');light.Color=orange;light.Range=9;light.Brightness=.9;light.Parent=p
  local duration=math.clamp(distance/85,.18,.42)
  Tween:Create(p,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Position=b}):Play()
  task.delay(duration,function()
   if not p.Parent then return end
   p.Transparency=1;sheath.Enabled=false;core.Enabled=false;tail.Enabled=false;soot.Enabled=false;light.Enabled=false;impact(b,math.clamp(radius,2,5))
  end)
 end
 local function jet(origin,target,duration,follow,density)
  density=density or 1
  local p=host('DragonVolumetricBreath',CFrame.lookAt(origin,target),duration+1.5)
  local body=emitter(p,flame,300*density,NumberRange.new(.35,.7),NumberSequence.new({NumberSequenceKeypoint.new(0,1.2),NumberSequenceKeypoint.new(.3,5.2),NumberSequenceKeypoint.new(.7,8),NumberSequenceKeypoint.new(1,0)}),colors)
  body.EmissionDirection=Enum.NormalId.Front;body.SpreadAngle=Vector2.new(12,10);body.Orientation=Enum.ParticleOrientation.FacingCamera
  local core=emitter(p,flame,100*density,NumberRange.new(.25,.5),NumberSequence.new(1.6,4.5),ColorSequence.new(Color3.fromRGB(255,221,137),orange));core.EmissionDirection=Enum.NormalId.Front;core.SpreadAngle=Vector2.new(5,5)
  local soot=emitter(p,smoke,25*density,NumberRange.new(.55,1),NumberSequence.new(2,8),ColorSequence.new(Color3.fromRGB(52,44,39)));soot.EmissionDirection=Enum.NormalId.Front;soot.LightEmission=0;soot.Transparency=NumberSequence.new(.75,1)
  local sparks=emitter(p,ember,55*density,NumberRange.new(.35,.7),NumberSequence.new(.7,0),ColorSequence.new(orange));sparks.EmissionDirection=Enum.NormalId.Front;sparks.SpreadAngle=Vector2.new(16,14)
  local t=0;local conn
  conn=Run.RenderStepped:Connect(function(dt)
   t+=dt
   if not p.Parent or t>=duration then conn:Disconnect();for _,e in ipairs({body,core,soot,sparks})do e.Enabled=false end;return end
   local start,finish=origin,target
   if follow then start,finish=follow(t/duration)end
   local speed=math.clamp((finish-start).Magnitude/.55,30,95)
   p.CFrame=CFrame.lookAt(start,finish)
   body.Speed=NumberRange.new(speed*.85,speed*1.1);core.Speed=NumberRange.new(speed,speed*1.1);soot.Speed=NumberRange.new(speed*.5,speed*.75);sparks.Speed=NumberRange.new(speed*.8,speed*1.1)
  end)
 end
 local function charge(model,duration)
  if not model or not model.Parent then return end
  local p=host('DragonThroatCharge',model:GetPivot(),duration+.8)
  local e=emitter(p,ember,70,NumberRange.new(.15,.4),NumberSequence.new(.65,0),colors);e.Speed=NumberRange.new(2,5);e.SpreadAngle=Vector2.new(180,180)
  local glow=Instance.new('PointLight');glow.Color=orange;glow.Range=13;glow.Brightness=0;glow.Parent=p;Tween:Create(glow,TweenInfo.new(duration),{Brightness=3}):Play()
  local t=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   t+=dt
   if not p.Parent or not model.Parent or t>=duration then connection:Disconnect();if p.Parent then e.Enabled=false;glow.Enabled=false end;return end
   p.Position=model:GetAttribute('DragonMouth')or model:GetPivot():PointToWorldSpace(Vector3.new(0,19.2,-10.2))
  end)
 end
 local function mouth(model,fallback)
  return model and model.Parent and model:GetAttribute('DragonMouth')or fallback
 end
 local function breath(origin,direction,settings)
  -- Five volumetric jets show the complete wide fan instead of a narrow centre ray.
  for i=-2,2 do
   local d=CFrame.Angles(0,math.rad(i*(settings.angle or 45)*.4),0):VectorToWorldSpace(direction)
   local target=Vector3.new(origin.X,.7,origin.Z)+d*(settings.range*.92)
   jet(origin,target,1.05,function()return mouth(settings.model,origin),target end,.38)
  end
 end
 local function fireLine(from,finish,settings)
  local span=finish-from;local length=span.Magnitude;if length<.1 then return end
  local count=math.clamp(math.ceil(length/6),1,16)
  for i=0,count-1 do
   local pos=from:Lerp(finish,(i+.5)/count);pos=Vector3.new(pos.X,.35,pos.Z)
   local p=host('DragonFireLane',CFrame.lookAt(pos,pos+span),1.4)
   p.Size=Vector3.new(settings.halfWidth*2,.15,length/count)
   local e=emitter(p,flame,0,NumberRange.new(.35,.8),NumberSequence.new({NumberSequenceKeypoint.new(0,2),NumberSequenceKeypoint.new(.25,6),NumberSequenceKeypoint.new(1,0)}),colors)
   e.EmissionDirection=Enum.NormalId.Top;e.Speed=NumberRange.new(10,19);e.SpreadAngle=Vector2.new(25,25);e:Emit(20)
   local sparks=emitter(p,ember,0,NumberRange.new(.35,.7),NumberSequence.new(.55,0),ColorSequence.new(orange));sparks.EmissionDirection=Enum.NormalId.Top;sparks.Speed=NumberRange.new(12,20);sparks:Emit(5)
  end
  local origin=mouth(settings.model,from+Vector3.new(0,18,0))
  jet(origin,from,settings.duration,function(alpha)return mouth(settings.model,origin),from:Lerp(finish,alpha)end,.6)
 end
 local function airBreath(model,points,duration)
  if not model or not model.Parent then return end
  local root=model.PrimaryPart;if not root then return end
  jet(root.Position,points[1],duration,function(alpha)
   local index=math.clamp(alpha*(#points-1)+1,1,#points);local lo=math.floor(index);local hi=math.min(#points,lo+1)
   local target=points[lo]:Lerp(points[hi],index-lo)
   return model:GetAttribute('DragonMouth')or root.CFrame:PointToWorldSpace(Vector3.new(0,19.2,-10.2)),Vector3.new(target.X,.5,target.Z)
  end)
 end
 local function wave(origin,direction,range)
  for i=-2,2 do
   local dir=CFrame.Angles(0,math.rad(i*14),0):VectorToWorldSpace(direction)
   local p=host('SpellFlameFront',CFrame.lookAt(origin+dir*2,origin+dir*3),1.6)
   local e=emitter(p,flame,180,NumberRange.new(.16,.35),NumberSequence.new({NumberSequenceKeypoint.new(0,1.8),NumberSequenceKeypoint.new(.3,3.6),NumberSequenceKeypoint.new(1,0)}),colors);e.EmissionDirection=Enum.NormalId.Top;e.Speed=NumberRange.new(2,8);e.Acceleration=Vector3.new(0,6,0);e:Emit(10)
   local emb=emitter(p,ember,25,NumberRange.new(.2,.55),NumberSequence.new(.45,0),ColorSequence.new(orange));emb.Speed=NumberRange.new(5,10)
   Tween:Create(p,TweenInfo.new(.42,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=origin+dir*range}):Play()
   task.delay(.42,function()if p.Parent then e.Enabled=false;emb.Enabled=false end end)
  end
 end
 return {FireLine=fireLine,Charge=charge,Bolt=bolt,Breath=breath,AirBreath=airBreath,Wave=wave,Impact=impact}
end
]====])
-- Source: src/client/combat/Input.luau
addModule(modules,{"combat","Input"},[====[
-- Fire along the character's facing, independent of pointer and camera position.
return function(deps)
 local UIS=game:GetService('UserInputService')
 local player,net=deps.player,deps.net
 local suspended=false
 local function requestDash()
  if suspended then return end
  local char=player.Character;local h=char and char:FindFirstChildOfClass('Humanoid');local root=char and char:FindFirstChild('HumanoidRootPart')
  if not h or not root then return end
  net.Action:FireServer('dash',h.MoveDirection.Magnitude>.1 and h.MoveDirection or root.CFrame.LookVector)
 end
 local function fireWave()
  if suspended then return end
  local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
  if root then net.Action:FireServer('fireWave',root.CFrame.LookVector) end
 end
 UIS.InputBegan:Connect(function(input,processed)
  if processed then return end
  if input.KeyCode==Enum.KeyCode.Q or input.KeyCode==Enum.KeyCode.ButtonR2 then fireWave()
  elseif input.KeyCode==Enum.KeyCode.E or input.KeyCode==Enum.KeyCode.ButtonB then requestDash() end
 end)
 return {Dash=requestDash,FireWave=fireWave,SetSuspended=function(value)suspended=value end}
end
]====])
-- Source: src/client/combat/PreviewScene.luau
addModule(modules,{"combat","PreviewScene"},[====[
-- Local effect gallery. No damage, remotes, live actor movement, or XP changes.
return function(deps)
 local root=Instance.new('Folder');root.Name='SkillPreviewStage';root.Parent=workspace
 local stage=Instance.new('Folder');stage.Name='Stage';stage.Parent=root
 local actors=Instance.new('Folder');actors.Name='Actors';actors.Parent=root
 local fx=Instance.new('Folder');fx.Name='Effects';fx.Parent=root
 local origin=Vector3.new(6000,0,6000)
 local forward=Vector3.new(0,0,-1)
 local casterPoint=origin+Vector3.new(0,3,18)
 local targetPoint=origin+Vector3.new(0,3,-12)
 local function block(parent,name,size,cf,color,material,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
 end
 local floor=block(stage,'PreviewFloor',Vector3.new(112,1,124),CFrame.new(origin-Vector3.new(0,.5,0)),Color3.fromRGB(36,45,60));floor.CanQuery=true
 for i=-5,5 do
  local color=Color3.fromRGB(49,66,82)
  block(stage,'Grid',Vector3.new(.06,.03,120),CFrame.new(origin+Vector3.new(i*10,.025,0)),color)
  block(stage,'Grid',Vector3.new(110,.03,.06),CFrame.new(origin+Vector3.new(0,.025,i*10)),color)
 end
 local function mannequin(name,point,color)
  local m=Instance.new('Model');m.Name=name;m.Parent=actors
  local pivot=block(m,'HumanoidRootPart',Vector3.one*.1,CFrame.new(point),color);pivot.Transparency=1;m.PrimaryPart=pivot
  block(m,'Body',Vector3.new(2,2.6,1.2),CFrame.new(point),color)
  block(m,'Head',Vector3.one*1.35,CFrame.new(point+Vector3.new(0,2,0)),color,nil,Enum.PartType.Ball)
  for _,side in ipairs({-1,1})do
   block(m,'Arm',Vector3.new(.7,2,.7),CFrame.new(point+Vector3.new(side*1.4,.1,0)),color)
   block(m,'Leg',Vector3.new(.75,2,.8),CFrame.new(point+Vector3.new(side*.55,-2,0)),color)
  end
  return m
 end
 local caster=mannequin('Caster',casterPoint,Color3.fromRGB(107,181,203))
 local targets={};for i=1,3 do targets[i]=mannequin('Target'..i,targetPoint+Vector3.new((i-2)*9,0,0),Color3.fromRGB(133,108,155))end
 local renderer=require(script.Parent.Effects)({player=deps.player,net=deps.net,gui=deps.gui,folder=fx,listen=false})
 local time,duration,id,rank=0,3,'meteor',1
 local events,anchors={},{}
 local pet
 local function at(t,fn)table.insert(events,{time=t,run=fn,done=false})end
 local function play(kind,a,b,c)renderer.Play(kind,a,b,c)end
 local function anchor(kind,point,radius,seconds)
  local p=block(fx,'PreviewAnchor',Vector3.one*.1,CFrame.new(point),Color3.new());p.Transparency=1
  p:SetAttribute('Elapsed',0);p:SetAttribute('Duration',seconds);p:SetAttribute('Radius',radius);p:SetAttribute('Level',rank);p:SetAttribute('Launched',false)
  table.insert(anchors,p);return p
 end
 local function clear()
  table.clear(events);table.clear(anchors);fx:ClearAllChildren()
  if pet then pet:Destroy();pet=nil end
  caster:PivotTo(CFrame.lookAt(casterPoint,casterPoint+forward))
  for _,m in ipairs(targets)do m:SetAttribute('Frozen',false)end
 end
 local function begin(spell,level)
  clear();time=0;id=spell;rank=level
  if id=='meteor' or id=='frost' or id=='ward' then
   local seconds=id=='meteor' and 3.2 or(id=='blades' and 6 or(id=='frost' and .75 or 5))
   local point=id=='meteor' and targetPoint or casterPoint
   point=Vector3.new(point.X,.35,point.Z)
   local radius=id=='meteor' and 14+rank or(id=='blades' and 11+rank*.7 or(id=='frost' and 12+rank or 4))
   local a=anchor(id,point,radius,seconds);play('areaCast',a,id)
   at(seconds,function()
    a:Destroy()
    if id=='meteor' then play('meteorHit',point,radius)
    elseif id=='frost' then play('frostHit',point,radius)
    elseif id=='ward' then play('wardHit',casterPoint,true)end
   end)
   if id=='ward' then at(2,function()play('wardHit',casterPoint,false)end)end
   duration=seconds+(id=='meteor' and 2.5 or 1.6)
  elseif id=='blades' then
   local a=anchor(id,casterPoint,2,5);a.CFrame=CFrame.lookAt(casterPoint,casterPoint+forward);a:SetAttribute('Fired',0);play('areaCast',a,id)
   for shot=1,5 do
    local born=.8+(shot-1)*.18
    at(born,function()
     a:SetAttribute('Fired',shot)
     local angle=shot/6*math.pi-math.pi/2
     local point=casterPoint+Vector3.new(math.sin(angle)*4.2,3.2+math.cos(angle)*1.7,1.8)
     local target=targets[(shot-1)%3+1]:GetPivot().Position
     local delta=target-point;local bolt=anchor(id,point,0,2);bolt:SetAttribute('Role','bolt');bolt:SetAttribute('Born',born);bolt:SetAttribute('Origin',point);bolt:SetAttribute('Direction',delta.Unit);bolt.CFrame=CFrame.lookAt(point,target);play('crystalBolt',bolt)
     at(born+delta.Magnitude/48,function()bolt:Destroy();play('crystalHit',target)end)
    end)
   end
   at(4.3,function()a:SetAttribute('Fired',0)end)
   at(5,function()a:Destroy()end);duration=5.5
  elseif id=='skyLances' then
   local point=Vector3.new(targetPoint.X,.35,targetPoint.Z);local a=anchor(id,point,8.3,2.65);play('areaCast',a,id)
   for i,offset in ipairs({Vector3.zero,Vector3.new(5,0,0),Vector3.new(0,0,5),Vector3.new(-5,0,0),Vector3.new(0,0,-5)})do at(1.75+(i-1)*.16,function()play('skyLanceHit',point+offset,3.3)end)end
   at(2.65,function()a:Destroy()end);duration=4.1
  elseif id=='fire' then
   at(.2,function()play('fire',casterPoint,targetPoint,2.5+rank*.6)end);duration=2.4
  elseif id=='lightning' then
   for hop=1,1+rank do
    at(.2+(hop-1)*.14,function()
     local target=targets[(hop-1)%3+1]:GetPivot().Position
     play('lightning',casterPoint,target,hop)
    end)
   end;duration=3
  elseif id=='ice' then
   local point=casterPoint+forward*3.5+Vector3.new(0,1.2,0)
   local frame=CFrame.lookAt(point,point+forward)
   local seconds=.42+(targetPoint-point).Magnitude/36
   local a=anchor('ice',point,0,seconds);a.CFrame=frame
   play('iceCast',a,frame,.42)
   at(seconds,function()a:Destroy();targets[2]:SetAttribute('Frozen',true);play('iceHit',targets[2],targetPoint,1.2)end)
   at(seconds+1.2,function()targets[2]:SetAttribute('Frozen',false)end);duration=seconds+2
  elseif id=='fireWave' then
   at(.25,function()play('fireWave',casterPoint,forward,30)end);duration=2.4
  elseif id=='thunder'or id=='aetherLance' then
   local a=anchor(id,casterPoint,0,.4);a.CFrame=CFrame.lookAt(casterPoint,casterPoint+forward);a:SetAttribute('Range',52)
   play('activeCast',a,id);play(id=='thunder'and'thunderSpear'or'aetherSpear',a)
   at(.4+27/48,function()play(id=='thunder'and'thunderHit'or'aetherHit',targetPoint)end)
   at(.4+52/48,function()a:Destroy()end);duration=3.2
  elseif id=='iceRush' then
   local a=anchor(id,casterPoint,0,.4);a.CFrame=CFrame.lookAt(casterPoint,casterPoint+forward);a:SetAttribute('Range',34)
   play('activeCast',a,id)
   at(.4,function()a:Destroy();play('activeStrike',casterPoint,forward,{kind=id,range=34,width=6})end);duration=3
  elseif id=='missile' then
   local count=2+math.floor(rank/2)
   for index=1,count do
    local point=casterPoint+Vector3.new((index-(count+1)/2)*1.6,1.2,0)
    local seconds=(targetPoint-point).Magnitude/44
    local a=anchor(id,point,0,seconds);a.CFrame=CFrame.lookAt(point,targetPoint);a:SetAttribute('Index',index);a:SetAttribute('Count',count)
    play('homingMissile',a)
    at(seconds,function()a:Destroy();play('missileHit',targetPoint)end)
   end;duration=2.8
  elseif id=='golem' then
   local runtime=workspace:FindFirstChild('SummonerRuntime');local live=runtime and runtime:FindFirstChild(deps.player.Name..'_Golem')
   if live and live.Archivable then
    pet=live:Clone()
    for _,v in ipairs(pet:GetDescendants())do
     if v:IsA('LuaSourceContainer')then v:Destroy()elseif v:IsA('BasePart')then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
    end
    pet.Name='PreviewGolem';pet.Parent=actors;pet:PivotTo(CFrame.new(origin+Vector3.new(0,3.6,-1)))
    play('golemCharge',pet,.65)
   end
   at(.77,function()play('golemHeavy',origin+Vector3.new(0,.35,-4),11+rank,rank)end);duration=3.5
  elseif id=='dash' then
   at(.3,function()play('dash',caster,.23,forward)end);duration=2.2
  end
  return duration
 end
 local function step(dt)
  time+=dt
  for _,a in ipairs(anchors)do
   if a.Parent then
    a:SetAttribute('Elapsed',time)
    if id=='blades' and a:GetAttribute('Role')=='bolt' then
     local point=a:GetAttribute('Origin')+a:GetAttribute('Direction')*math.max(0,time-a:GetAttribute('Born'))*48;a.CFrame=CFrame.lookAt(point,point+a:GetAttribute('Direction'))
    elseif (id=='thunder'or id=='aetherLance')and time>=.4 then
     a:SetAttribute('Launched',true);local p=casterPoint+forward*(3+math.min(52,(time-.4)*48))+Vector3.new(0,1.2,0);a.CFrame=CFrame.lookAt(p,p+forward)
    elseif id=='missile' then
     local index=a:GetAttribute('Index');local count=a:GetAttribute('Count')
     local start=casterPoint+Vector3.new((index-(count+1)/2)*1.6,1.2,0);local delta=targetPoint-start
     local p=start+delta.Unit*math.min(delta.Magnitude,time*44);a.CFrame=CFrame.lookAt(p,p+delta.Unit)
    elseif id=='ice' and time>=.42 then
     a:SetAttribute('Launched',true)
     local start=casterPoint+forward*3.5+Vector3.new(0,1.2,0)
     local delta=targetPoint-start;local p=start+delta.Unit*math.min(delta.Magnitude,(time-.42)*36)
     a.CFrame=CFrame.lookAt(p,p+delta.Unit)
    end
   end
  end
  if id=='dash' then local p=casterPoint+forward*64*math.clamp(time-.3,0,.23);caster:PivotTo(CFrame.lookAt(p,p+forward))end
  for _,event in ipairs(events)do if not event.done and time>=event.time then event.done=true;event.run()end end
  return time>=duration,time,duration
 end
 return {Root=root,Origin=origin,Effects=fx,Play=begin,Step=step,Clear=clear,Destroy=function()clear();renderer.Disconnect();game:GetService('Debris'):AddItem(root,3)end}
end
]====])
-- Source: src/client/combat/ProjectileArt.luau
addModule(modules,{"combat","ProjectileArt"},[====[
-- Reusable moving lightning lance and compact homing missiles; presentation only.
return function(deps)
 local Run=game:GetService('RunService');local Tween=game:GetService('TweenService');local Debris=game:GetService('Debris')
 local aether=require(script.Parent.AetherLanceArt)(deps)
 local fx=deps.folder;local cyan=Color3.fromRGB(113,207,255);local white=Color3.fromRGB(231,252,255);local violet=Color3.fromRGB(206,140,255)
 local function part(parent,name,size,cf,color,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Shape=shape or Enum.PartType.Block;p.Material=Enum.Material.Neon;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function resolve(name)
  if typeof(name)=='Instance'then return name end
  if type(name)~='string'then return nil end
  local runtime=workspace:WaitForChild('SummonerRuntime',3);return runtime and runtime:WaitForChild(name,2)
 end
 local function cast(name,kind)
  if kind=='aetherLance'then aether.Cast(name,kind);return end
  local anchor=resolve(name);if not anchor or not anchor.Parent then return end
  local spear=kind=='thunder';local crystal=kind=='crystal'
  local model=Instance.new('Model');model.Name=spear and 'LightningSpear' or(crystal and 'CrystalBolt' or 'HomingMissile');model.Parent=fx
  local pivot=part(model,'Pivot',Vector3.one*.1,CFrame.identity,white);pivot.Transparency=1;model.PrimaryPart=pivot
  local color=(spear or crystal)and cyan or violet
  local currents={};local tipSparks;local age=0
  if spear then
   local shaft=part(model,'SpearShaft',Vector3.new(17,.24,.24),CFrame.new(0,0,2)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(42,78,121),Enum.PartType.Cylinder);shaft.Material=Enum.Material.Metal
   part(model,'SpearSpine',Vector3.new(17,.07,.07),CFrame.new(0,.14,2)*CFrame.Angles(0,math.pi/2,0),white,Enum.PartType.Cylinder)
   local aura=part(model,'SpearAura',Vector3.new(16,.36,.36),CFrame.new(0,0,2)*CFrame.Angles(0,math.pi/2,0),cyan,Enum.PartType.Cylinder);aura.Transparency=.65
   local function face(a,b,c,color)
    local ab,ac,bc=b-a,c-a,c-b
    local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
    if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
    ab,ac,bc=b-a,c-a,c-b
    local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
    local function half(v,axis,depth)
     if depth<.005 then return end
     local p=Instance.new('WedgePart');p.Name='LightningSpearFacet';p.Size=Vector3.new(.03,math.abs(ab:Dot(up)),depth);p.CFrame=CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back);p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.12;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=model
    end
    half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
   end
   local tip=Vector3.new(0,0,-13);local tail=Vector3.new(0,0,-4.5)
   local ring={Vector3.new(.72,0,-7),Vector3.new(0,.72,-7),Vector3.new(-.72,0,-7),Vector3.new(0,-.72,-7)}
   for i=1,4 do
    local a,b=ring[i],ring[i%4+1];face(tip,a,b,i%2==0 and white or cyan);face(tail,b,a,cyan)
    part(model,'SpearRidge',Vector3.new(.045,.045,(tip-a).Magnitude),CFrame.lookAt((tip+a)/2,a),white)
   end
   local gold=Color3.fromRGB(255,222,146)
   for i=1,6 do
    local cuff=part(model,'GildedShaftBand',Vector3.new(.12,.36,.36),CFrame.new(0,0,-2+i*2)*CFrame.Angles(0,math.pi/2,0),gold,Enum.PartType.Cylinder);cuff.Material=Enum.Material.Metal
    for _,side in ipairs({-1,1})do part(model,'ShaftEngraving',Vector3.new(.035,.055,.55),CFrame.new(side*.125,.02,-2+i*2.1)*CFrame.Angles(0,0,side*.3),cyan)end
   end
   for _,side in ipairs({-1,1})do face(Vector3.new(side*.18,0,-3.8),Vector3.new(side*1.65,0,-5.5),Vector3.new(side*.65,0,-7.5),gold)end
   part(model,'SpearPommel',Vector3.new(.4,.4,.7),CFrame.new(0,0,10.8),cyan,Enum.PartType.Ball)
   local function beam(a,b,width,c)
    local aa=Instance.new('Attachment');aa.Position=a;aa.Parent=pivot
    local bb=Instance.new('Attachment');bb.Position=b;bb.Parent=pivot
    local e=Instance.new('Beam');e.Attachment0=aa;e.Attachment1=bb;e.FaceCamera=true;e.Width0=width;e.Width1=width;e.Color=ColorSequence.new(c);e.LightEmission=1;e.LightInfluence=0;e.Transparency=NumberSequence.new(.25);e.Parent=pivot
    return aa,bb
   end
   for ringIndex=1,2 do for i=1,12 do
    local a=i*math.pi/6;local b=(i+1)*math.pi/6;local r=ringIndex==1 and 1 or 1.35;local z=ringIndex==1 and 7.5 or -3.5
    beam(Vector3.new(math.cos(a)*r,math.sin(a)*r,z),Vector3.new(math.cos(b)*r,math.sin(b)*r,z),.065,i%3==0 and gold or cyan)
   end end
   for i=1,12 do local a,b=beam(Vector3.zero,Vector3.new(0,0,1),.09,i%3==0 and white or cyan);currents[i]={a=a,b=b}end
   local tipHost=Instance.new('Attachment');tipHost.Position=tip;tipHost.Parent=pivot
   tipSparks=Instance.new('ParticleEmitter');tipSparks.Texture='rbxasset://textures/particles/sparkles_main.dds';tipSparks.Rate=38;tipSparks.Lifetime=NumberRange.new(.12,.28);tipSparks.Speed=NumberRange.new(1,4);tipSparks.SpreadAngle=Vector2.new(180,180);tipSparks.Size=NumberSequence.new(.25,0);tipSparks.Color=ColorSequence.new(white,gold);tipSparks.LightEmission=1;tipSparks.Transparency=NumberSequence.new(.15,1);tipSparks.Parent=tipHost
   for i=1,10 do
    local a=Vector3.new(math.sin(i*4)*.25,math.cos(i*3)*.23,-2.7+i*.55);local b=Vector3.new(math.sin((i+1)*4)*.25,math.cos((i+1)*3)*.23,-2.7+(i+1)*.55)
    part(model,'SpearCurrent',Vector3.new(.08,.08,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),cyan)
   end
  else
   part(model,'MissileCore',Vector3.one*(crystal and .5 or .45),CFrame.identity,white,Enum.PartType.Ball)
   local aura=part(model,'MissileAura',Vector3.one*(crystal and .95 or .9),CFrame.identity,color,Enum.PartType.Ball);aura.Transparency=.55
   if not crystal then for i=1,4 do local a=i*math.pi/2;part(model,'MissileFin',Vector3.new(.12,.12,1.2),CFrame.new(math.cos(a)*.3,math.sin(a)*.3,.35),color)end end
  end
  local a=Instance.new('Attachment');a.Position=Vector3.new(-.3,0,spear and 9.5 or .3);a.Parent=pivot
  local b=Instance.new('Attachment');b.Position=Vector3.new(.3,0,spear and 9.5 or .3);b.Parent=pivot
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=spear and .3 or .2;trail.Color=ColorSequence.new(white,color);trail.Transparency=NumberSequence.new(.2,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=1;trail.Parent=pivot
  local light=Instance.new('PointLight');light.Color=color;light.Range=spear and 12 or 6;light.Brightness=1.5;light.Parent=pivot
  local current=anchor.CFrame;local scale=1;local hasLaunched=false;local conn,destroyConn
  local function clear()if conn then conn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;model:Destroy()end
  destroyConn=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function(dt)
   if not anchor.Parent then clear();return end
   age+=dt
   local launched=not spear or anchor:GetAttribute('Launched')
   local target=anchor.CFrame
   if spear then
    local wanted=1
    if not launched then target=target*CFrame.new(0,1.2,-3);wanted=.35+.4*math.clamp((anchor:GetAttribute('Elapsed')or 0)/.4,0,1)end
    if math.abs(wanted-scale)>.005 then model:ScaleTo(wanted);scale=wanted end
   end
   current=current:Lerp(target,1-math.exp(-dt*35));model:PivotTo(current);trail.Enabled=launched
   if spear then
    for i,v in ipairs(currents)do
     local z=-11+i*1.65;local phase=age*24+i*2.1
     v.a.Position=Vector3.new(math.sin(phase)*.55,math.cos(phase*1.3)*.5,z)
     v.b.Position=Vector3.new(math.sin(phase+1.9)*.55,math.cos((phase+1.9)*1.3)*.5,z+1.65)
    end
    if launched and not hasLaunched then hasLaunched=true;tipSparks:Emit(28)end
   end
  end)
 end
 local function impact(pos,kind)
  local color=(kind=='thunder' or kind=='aetherLance' or kind=='crystal')and cyan or violet
  local flash=part(fx,'ProjectileImpact',Vector3.one*.6,CFrame.new(pos),white,Enum.PartType.Ball);Debris:AddItem(flash,.3)
  Tween:Create(flash,TweenInfo.new(.25),{Size=Vector3.one*(kind=='crystal' and 1.1 or 2.5),Transparency=1}):Play()
  for i=1,10 do
   local direction=Vector3.new(math.sin(i*7),math.cos(i*5),math.cos(i*3)).Unit
   local p=part(fx,'ProjectileSpark',Vector3.new(.1,.1,.9),CFrame.lookAt(pos,pos+direction),color);Debris:AddItem(p,.5)
   Tween:Create(p,TweenInfo.new(.4),{Position=pos+direction*3,Transparency=1}):Play()
  end
 end
 return {Cast=cast,Impact=impact}
end
]====])
-- Source: src/client/combat/SkyLanceArt.luau
addModule(modules,{"combat","SkyLanceArt"},[====[
-- Original gold/blue ceremonial lances descend from a suspended arcane seal.
return function(deps)
 local Run=game:GetService('RunService');local fx=deps.folder
 local gold=Color3.fromRGB(255,218,143);local white=Color3.fromRGB(230,250,255);local blue=Color3.fromRGB(105,178,255)
 local function part(parent,name,size,cf,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function line(parent,a,b,width,color)
  return part(parent,'SealLine',Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
 end
 local function triangle(parent,a,b,c,color)
  local ab,ac,bc=b-a,c-a,c-b
  if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b
  local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
  for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do
   if v[4]>.005 then
    local p=Instance.new('WedgePart');p.Name='LanceBlade';p.Size=Vector3.new(.025,math.abs(ab:Dot(up)),v[4]);p.CFrame=CFrame.fromMatrix((a+v[1])/2,v[2],up,v[3]);p.Material=Enum.Material.Neon;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
   end
  end
 end
 local function cast(anchor)
  if type(anchor)=='string'then local world=workspace:WaitForChild('SummonerRuntime',3);anchor=world and world:WaitForChild(anchor,2)end
  if not anchor or not anchor.Parent then return end
  local model=Instance.new('Model');model.Name='CelestialLanceRain';model.Parent=fx
  local seal=Instance.new('Model');seal.Name='SkyMagicCircle';seal.Parent=model
  local pivot=part(seal,'Pivot',Vector3.one*.1,CFrame.identity,gold);pivot.Transparency=1;seal.PrimaryPart=pivot
  for layer=1,2 do for i=1,48 do local a=i*math.pi/24;local b=(i+1)*math.pi/24;local r=layer==1 and 8.5 or 6.9;line(seal,Vector3.new(math.cos(a)*r,0,math.sin(a)*r),Vector3.new(math.cos(b)*r,0,math.sin(b)*r),layer==1 and .1 or .06,layer==1 and gold or blue)end end
  for i=1,8 do
   local a=i*math.pi/4;local b=a+math.pi*.75
   line(seal,Vector3.new(math.cos(a)*6.4,0,math.sin(a)*6.4),Vector3.new(math.cos(b)*6.4,0,math.sin(b)*6.4),.055,blue)
   local frame=CFrame.Angles(0,-a,0)*CFrame.new(7.6,0,0)
   for j=-1,1 do part(seal,'SealRune',Vector3.new(.12,.08,.35),frame*CFrame.new(0,0,j*.25)*CFrame.Angles(0,j*.6,0),gold)end
  end
  local lances={};local offsets={Vector3.zero,Vector3.new(5,0,0),Vector3.new(0,0,5),Vector3.new(-5,0,0),Vector3.new(0,0,-5)}
  for i,offset in ipairs(offsets)do
   local m=Instance.new('Model');m.Name='FallingMagicLance';m.Parent=model
   local p=part(m,'Pivot',Vector3.one*.1,CFrame.identity,white);p.Transparency=1;m.PrimaryPart=p
   part(m,'LanceShaft',Vector3.new(.16,13,.16),CFrame.new(0,12,0),Color3.fromRGB(62,104,156),Enum.Material.Metal)
   part(m,'LanceSpine',Vector3.new(.055,13,.055),CFrame.new(0,12,-.12),white)
   local ring={Vector3.new(.6,5,0),Vector3.new(0,5,.6),Vector3.new(-.6,5,0),Vector3.new(0,5,-.6)}
   for j=1,4 do triangle(m,Vector3.zero,ring[j],ring[j%4+1],j%2==0 and white or blue);triangle(m,Vector3.new(0,7,0),ring[j%4+1],ring[j],blue)end
   for _,side in ipairs({-1,1})do triangle(m,Vector3.new(0,7,0),Vector3.new(side*1.15,5.8,0),Vector3.new(side*.4,8.5,0),gold)end
   local a=Instance.new('Attachment');a.Position=Vector3.new(-.3,17,0);a.Parent=p;local b=Instance.new('Attachment');b.Position=Vector3.new(.3,17,0);b.Parent=p
   local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Color=ColorSequence.new(white,blue);trail.Lifetime=.3;trail.Transparency=NumberSequence.new(.15,1);trail.LightEmission=1;trail.Parent=p
   local light=Instance.new('PointLight');light.Color=blue;light.Range=8;light.Brightness=1;light.Parent=p
   lances[i]={model=m,offset=offset,trail=trail}
  end
  local conn,dc
  local function clear()if conn then conn:Disconnect()end;if dc then dc:Disconnect()end;model:Destroy()end
  dc=anchor.Destroying:Connect(clear)
  conn=Run.RenderStepped:Connect(function()
   if not anchor.Parent then clear();return end
   local t=anchor:GetAttribute('Elapsed')or 0
   seal:PivotTo(CFrame.new(anchor.Position+Vector3.new(0,44,0))*CFrame.Angles(0,t*.3,0))
   for i,lance in ipairs(lances)do
    local u=math.clamp((t-.9-(i-1)*.16)/.85,0,1)
    local h=44*(1-u*u);lance.model:PivotTo(CFrame.new(anchor.Position+lance.offset+Vector3.new(0,h,0)));lance.trail.Enabled=u>0 and u<1
    for _,p in ipairs(lance.model:GetDescendants())do if p:IsA('BasePart')and p.Name~='Pivot'then p.LocalTransparencyModifier=u>=1 and math.clamp((t-(1.75+(i-1)*.16))/.25,0,1)or 0 end end
   end
  end)
 end
 return {Cast=cast}
end
]====])
-- Source: src/client/combat/SpellArt.luau
addModule(modules,{"combat","SpellArt"},[====[
-- Original magic artwork. Local geometry and beams never apply damage.
return function(deps)
 local Tween=game:GetService('TweenService')
 local Debris=game:GetService('Debris')
 local Run=game:GetService('RunService')
 local fx=deps.folder
 local gold=Color3.fromRGB(255,184,66)
 local white=Color3.fromRGB(255,248,206)
 local cyan=Color3.fromRGB(106,236,255)
 local red=Color3.fromRGB(255,70,37)
 local fire='rbxasset://textures/particles/fire_main.dds'
 local spark='rbxasset://textures/particles/sparkles_main.dds'
 local function host(name,cf,life)
  local p=Instance.new('Part');p.Name=name;p.Size=Vector3.one*.1;p.CFrame=cf;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,life);return p
 end
 local function attachment(p,position,tangent)
  local a=Instance.new('Attachment');a.CFrame=CFrame.fromMatrix(position,tangent,Vector3.yAxis,tangent:Cross(Vector3.yAxis));a.Parent=p;return a
 end
 local function ribbon(p,a,b,width,color,texture)
  local beam=Instance.new('Beam');beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=8;beam.Width0=width;beam.Width1=width;beam.Color=ColorSequence.new(color);beam.Transparency=NumberSequence.new(.1);beam.LightEmission=1;beam.LightInfluence=0
  if texture then beam.Texture=texture;beam.TextureLength=3;beam.TextureSpeed=1.5 end
  beam.Parent=p;return beam
 end
 local function particles(parent,color,count,size)
  local e=Instance.new('ParticleEmitter');e.Texture=spark;e.Rate=0;e.Lifetime=NumberRange.new(.25,.6);e.Speed=NumberRange.new(3,9);e.SpreadAngle=Vector2.new(180,180);e.Size=NumberSequence.new(size,0);e.Transparency=NumberSequence.new(.15,1);e.Color=ColorSequence.new(white,color);e.LightEmission=1;e.Drag=2;e.Parent=parent;e:Emit(count);return e
 end
 local function circle(p,radius,color,width,vertical)
  local beams={}
  for i=0,15 do
   local a=i*math.pi/8;local b=(i+1)*math.pi/8
   local pa=vertical and Vector3.new(math.cos(a)*radius,math.sin(a)*radius,0) or Vector3.new(math.sin(a)*radius,0,-math.cos(a)*radius)
   local pb=vertical and Vector3.new(math.cos(b)*radius,math.sin(b)*radius,0) or Vector3.new(math.sin(b)*radius,0,-math.cos(b)*radius)
   -- Use straight short segments for vertical sigils; no degenerate tangent frame.
   local aa=Instance.new('Attachment');aa.Position=pa;aa.Parent=p
   local bb=Instance.new('Attachment');bb.Position=pb;bb.Parent=p
   table.insert(beams,ribbon(p,aa,bb,width,color))
  end
  return beams
 end
 local function fade(p,duration)
  for _,b in ipairs(p:GetDescendants())do if b:IsA('Beam')then b.Transparency=NumberSequence.new(.25)end end
  local elapsed=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   elapsed+=dt
   if not p.Parent or elapsed>=duration then connection:Disconnect();if p.Parent then p:Destroy()end;return end
   for _,b in ipairs(p:GetDescendants())do if b:IsA('Beam')then b.Transparency=NumberSequence.new(math.clamp(elapsed/duration,.1,1))end end
  end)
 end
 local function sigil(origin,direction)
  local p=host('SolarCastSigil',CFrame.lookAt(origin+direction*2.5+Vector3.new(0,.5,0),origin+direction*3.5+Vector3.new(0,.5,0)),.65)
  circle(p,2.4,gold,.13,true);circle(p,1.95,cyan,.07,true)
  for i=1,6 do
   local angle=i*math.pi/3
   local a=Instance.new('Attachment');a.Position=Vector3.new(math.cos(angle)*1.5,math.sin(angle)*1.5,0);a.Parent=p
   local b=Instance.new('Attachment');b.Position=Vector3.new(math.cos(angle+math.pi*2/3)*1.5,math.sin(angle+math.pi*2/3)*1.5,0);b.Parent=p
   ribbon(p,a,b,.07,gold)
   particles(a,gold,2,.22)
  end
  Tween:Create(p,TweenInfo.new(.5),{CFrame=p.CFrame*CFrame.Angles(0,0,.7)}):Play();fade(p,.55)
 end
 local function wave(origin,direction,range,enemy,spread,duration)
  direction=Vector3.new(direction.X,0,direction.Z).Unit
  local p=host(enemy and 'DragonBreathWave' or 'SolarCrescent',CFrame.new(),duration+.2)
  local right=direction:Cross(Vector3.yAxis)
  local center=enemy and red or gold
  local strips={}
  for i=0,11 do
   local a=math.rad(-spread+i*spread*2/12);local b=math.rad(-spread+(i+1)*spread*2/12)
   local aa=attachment(p,Vector3.zero,right);local bb=attachment(p,Vector3.zero,right)
   local halo=ribbon(p,aa,bb,enemy and 4.2 or 4.4,center,fire)
   local under=ribbon(p,aa,bb,enemy and 2 or 1.25,center)
   local core=ribbon(p,aa,bb,enemy and .5 or .2,enemy and gold or white)
   local start=math.sin(i/12*math.pi)^.65;local finish=math.sin((i+1)/12*math.pi)^.65
   halo.Width0*=start;halo.Width1*=finish;under.Width0*=start;under.Width1*=finish;core.Width0*=start;core.Width1*=finish
   local e=particles(aa,center,2,enemy and .7 or .35);e.Rate=9;e.Lifetime=NumberRange.new(.12,.3);e.Speed=NumberRange.new(1,4);e.Texture=fire;e.Rate=18;e.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.3),NumberSequenceKeypoint.new(.4,2.5),NumberSequenceKeypoint.new(1,0)});e.Color=ColorSequence.new(white,center)
   table.insert(strips,{a=a,b=b,aa=aa,bb=bb,halo=halo,core=core,under=under})
  end
  local elapsed=0;local connection
  connection=Run.RenderStepped:Connect(function(dt)
   elapsed+=dt
   if not p.Parent or elapsed>=duration then connection:Disconnect();if p.Parent then p:Destroy()end;return end
   local alpha=elapsed/duration;local radius=3+(range-3)*alpha
   local height=enemy and math.max(.9,origin.Y*(1-alpha)) or 2.3+math.sin(alpha*math.pi)*.8
   local opacity=math.clamp((alpha-.65)/.35,0,.95)
   for _,v in ipairs(strips)do
    for _,pair in ipairs({{v.aa,v.a},{v.bb,v.b}})do
     local a=pair[2];local tangent=right*math.cos(a)-direction*math.sin(a)
     local position=Vector3.new(origin.X,height,origin.Z)+(direction*math.cos(a)+right*math.sin(a))*radius
     pair[1].CFrame=CFrame.fromMatrix(position,tangent,Vector3.yAxis,tangent:Cross(Vector3.yAxis))
    end
    local curvature=radius*(v.b-v.a)/3
    v.halo.CurveSize0=curvature;v.halo.CurveSize1=curvature;v.core.CurveSize0=curvature;v.core.CurveSize1=curvature
    v.under.CurveSize0=curvature;v.under.CurveSize1=curvature;v.under.Transparency=NumberSequence.new(.45+opacity*.55);v.halo.Transparency=NumberSequence.new(.05+opacity*.95);v.core.Transparency=NumberSequence.new(opacity)
   end
  end)
 end
 local function fireWave(origin,direction,range)
  sigil(origin,direction);wave(origin,direction,range,false,35,.65)
  task.delay(.13,function()if fx.Parent then wave(origin,direction,range*.93,false,32,.6)end end)
 end
 local function rupture(point,radius,small)
  local life=small and 1.1 or 1.8
  local p=host('EmberEruption',CFrame.new(point.X,.24,point.Z),life)
  circle(p,radius,red,small and .22 or .45,false);circle(p,radius*.72,gold,.18,false)
  -- A fast expanding halo stays inside the authoritative damage boundary.
  local halo=host('EruptionShockwave',p.CFrame,.65)
  circle(halo,radius*.18,white,.28,false)
  for _,a in ipairs(halo:GetChildren())do if a:IsA('Attachment')then Tween:Create(a,TweenInfo.new(.38,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=a.Position/.18}):Play()end end
  fade(halo,.55)
  local scorch=host('EruptionScorch',CFrame.new(point.X,.09,point.Z)*CFrame.Angles(0,0,math.pi/2),2.3)
  scorch.Shape=Enum.PartType.Cylinder;scorch.Size=Vector3.new(.035,radius*1.85,radius*1.85);scorch.Material=Enum.Material.SmoothPlastic;scorch.Color=Color3.fromRGB(49,26,29);scorch.Transparency=.42
  Tween:Create(scorch,TweenInfo.new(2.1),{Transparency=1}):Play()
  local function plume(parent,scale,count)
   local e=Instance.new('ParticleEmitter');e.Texture=fire;e.Rate=0;e.EmissionDirection=Enum.NormalId.Top;e.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;e.Lifetime=NumberRange.new(.35,.8);e.Speed=NumberRange.new(13*scale,26*scale);e.Acceleration=Vector3.new(0,-12,0);e.SpreadAngle=Vector2.new(25,25)
   e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.4*scale),NumberSequenceKeypoint.new(.22,4.6*scale),NumberSequenceKeypoint.new(1,0)});e.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,white),ColorSequenceKeypoint.new(.25,gold),ColorSequenceKeypoint.new(1,red)});e.Transparency=NumberSequence.new(.12,1);e.LightEmission=.85;e.LightInfluence=0;e.Parent=parent;e:Emit(count)
  end
  plume(p,small and .65 or 1.15,small and 18 or 26)
  if not small then
   for i=1,5 do local a=Instance.new('Attachment');local angle=i*math.pi*2/5;a.Position=Vector3.new(math.cos(angle)*radius*.52,0,math.sin(angle)*radius*.52);a.Parent=p;plume(a,.85,12)end
   local smoke=Instance.new('ParticleEmitter');smoke.Texture='rbxasset://textures/particles/smoke_main.dds';smoke.Rate=0;smoke.Lifetime=NumberRange.new(.7,1.3);smoke.Speed=NumberRange.new(4,8);smoke.EmissionDirection=Enum.NormalId.Top;smoke.SpreadAngle=Vector2.new(70,70);smoke.Size=NumberSequence.new(radius*.4,radius);smoke.Color=ColorSequence.new(Color3.fromRGB(72,52,54));smoke.Transparency=NumberSequence.new(.7,1);smoke.Rotation=NumberRange.new(0,360);smoke.Parent=p;smoke:Emit(9)
  end
  local embers=particles(p,gold,small and 12 or 30,.55);embers.Texture='rbxasset://textures/particles/fire_sparks_main.dds';embers.EmissionDirection=Enum.NormalId.Top;embers.Speed=NumberRange.new(12,26);embers.Acceleration=Vector3.new(0,-17,0)
  local light=Instance.new('PointLight');light.Color=gold;light.Range=radius*3;light.Brightness=2.5;light.Parent=p;Tween:Create(light,TweenInfo.new(.6),{Brightness=0}):Play();fade(p,life)
 end
 local function slam(point,radius)
  rupture(point,radius,false)
  local p=host('DragonLandingShock',CFrame.new(point.X,.4,point.Z),1.25)
  circle(p,radius*.4,white,.5,false)
  for _,a in ipairs(p:GetChildren())do if a:IsA('Attachment')then Tween:Create(a,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=a.Position/.4}):Play()end end
  local dust=Instance.new('ParticleEmitter');dust.Texture='rbxasset://textures/particles/smoke_main.dds';dust.Rate=0;dust.Lifetime=NumberRange.new(.4,.9);dust.Size=NumberSequence.new(3,9);dust.Speed=NumberRange.new(15,24);dust.SpreadAngle=Vector2.new(85,85);dust.Color=ColorSequence.new(Color3.fromRGB(124,103,90));dust.Transparency=NumberSequence.new(.5,1);dust.Drag=5;dust.Parent=p;dust:Emit(22)
  for i=1,12 do
   local angle=i*math.pi/6;local dir=Vector3.new(math.cos(angle),0,math.sin(angle))
   local rock=host('LandingDebris',CFrame.new(point+dir*radius*.35+Vector3.new(0,.4,0)),1.1)
   rock.Transparency=0;rock.Size=Vector3.new(1.4+(i%3)*.5,1.2,2);rock.Material=Enum.Material.Slate;rock.Color=Color3.fromRGB(66,53,54)
   local peak=point+dir*radius*.7+Vector3.new(0,3+i%3,0)
   Tween:Create(rock,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=peak,Orientation=Vector3.new(i*23,i*41,38)}):Play()
   task.delay(.22,function()if rock.Parent then Tween:Create(rock,TweenInfo.new(.55,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=Vector3.new(peak.X,.2,peak.Z),Transparency=1}):Play()end end)
  end
  fade(p,1.1)
 end
 local function tailSpin(model,radius,duration)
  if not model or not model.Parent then return end
  local root=model.PrimaryPart;if not root then return end
  local p=host('DragonTailArc',CFrame.new(root.Position.X,1.8,root.Position.Z),duration+.4)
  local arcs={}
  for i=1,5 do
   local a=Instance.new('Attachment');a.Parent=p;local b=Instance.new('Attachment');b.Parent=p
   table.insert(arcs,{a=a,b=b,beam=ribbon(p,a,b,2.5,red,fire)})
  end
  local e=particles(p,gold,18,.6);e.Texture='rbxasset://textures/particles/smoke_main.dds';e.Rate=45;e.Lifetime=NumberRange.new(.15,.35);e.Size=NumberSequence.new(2,5);e.Transparency=NumberSequence.new(.6,1)
  local time=0;local conn
  conn=Run.RenderStepped:Connect(function(dt)
   time+=dt
   if not p.Parent or not root.Parent or time>=duration then conn:Disconnect();if p.Parent then e.Enabled=false;fade(p,.2)end;return end
   p.Position=Vector3.new(root.Position.X,1.8,root.Position.Z)
   local heading=root.CFrame.LookVector
   local sweep=math.atan2(-heading.Z,-heading.X)
   local strength=math.sin(math.clamp(time/duration,0,1)*math.pi)
   e.Rate=20+45*strength
   for i,v in ipairs(arcs)do
    local a=sweep-(i-1)*.2;local b=sweep-i*.2
    v.beam.Transparency=NumberSequence.new(.8-strength*.65);v.beam.Width0=1+strength*1.5;v.beam.Width1=v.beam.Width0
    v.a.Position=Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
    v.b.Position=Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius)
   end
  end)
 end
 local function breath(origin,direction,settings)
  for i=0,3 do task.delay(i*.14,function()if fx.Parent then wave(origin,direction,settings.range,true,settings.angle,.55)end end)end
 end
 local function dive(model,duration)
  if not model or not model.Parent then return end
  local root=model.PrimaryPart;if not root then return end
  local a=Instance.new('Attachment');a.Position=Vector3.new(-6,8,3);a.Parent=root
  local b=Instance.new('Attachment');b.Position=Vector3.new(6,8,3);b.Parent=root
  local trail=Instance.new('Trail');trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.45;trail.Color=ColorSequence.new(gold,red);trail.Transparency=NumberSequence.new(.3,1);trail.LightEmission=1;trail.Parent=a
  local rush=Instance.new('ParticleEmitter');rush.Texture=fire;rush.Rate=70;rush.Lifetime=NumberRange.new(.18,.4);rush.Speed=NumberRange.new(4,9);rush.EmissionDirection=Enum.NormalId.Back;rush.SpreadAngle=Vector2.new(20,20);rush.Size=NumberSequence.new(3,0);rush.Color=ColorSequence.new(gold,red);rush.Transparency=NumberSequence.new(.4,1);rush.LightEmission=1;rush.Parent=a
  task.delay(duration,function()if rush.Parent then rush.Enabled=false end end)
  Debris:AddItem(a,duration+.5);Debris:AddItem(b,duration+.5)
 end
 return {Slam=slam,TailSpin=tailSpin,FireWave=fireWave,Rupture=rupture,Breath=breath,Dive=dive}
end
]====])
-- Source: src/client/flow/HUD.luau
addModule(modules,{"flow","HUD"},[====[
-- Native editable GUI, offers and state rendering.
return function(deps)
	local player, net = deps.player, deps.net
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, round, stroke, label = theme.Palette, theme.Make, theme.Round, theme.Stroke, theme.Label
	local gui=Instance.new("ScreenGui"); gui.Name="SummonerHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
	local encounter=make("Frame",gui,{Name="EncounterPanel",Size=UDim2.new(.8,0,0,26),Position=UDim2.new(1,-12,0,6),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.bg,BackgroundTransparency=.15})
	make("UISizeConstraint",encounter,{MaxSize=Vector2.new(320,26)});round(encounter,8)
	local title=label(encounter,"SURVIVAL / 드래곤 등장까지",UDim2.new(1,-76,1,0),UDim2.fromOffset(10,0),Enum.Font.GothamBold,palette.mint);title.TextSize=11;title.TextXAlignment=Enum.TextXAlignment.Left
	local timer=label(encounter,"02:00",UDim2.fromOffset(60,26),UDim2.new(1,-70,0,0),Enum.Font.GothamBold);timer.TextSize=16;timer.TextXAlignment=Enum.TextXAlignment.Right
	local top=make("Frame",gui,{Name="PlayerPanel",Size=UDim2.fromOffset(340,116),Position=UDim2.new(0,12,1,-12),AnchorPoint=Vector2.new(0,1),BackgroundColor3=palette.bg,BackgroundTransparency=.12})
	round(top,10);stroke(top)
	local info=label(top,"Lv.1  체력 150/150  처치 0",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,6),Enum.Font.GothamBold,palette.text);info.TextSize=12;info.TextXAlignment=Enum.TextXAlignment.Left
	local healthBack=make("Frame",top,{Size=UDim2.new(1,-24,0,6),Position=UDim2.fromOffset(12,30),BackgroundColor3=Color3.fromRGB(49,48,59),BorderSizePixel=0});round(healthBack,3)
	local health=make("Frame",healthBack,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(249,117,133),BorderSizePixel=0});round(health,3)
	local xpInfo=label(top,"경험치 0/5",UDim2.new(1,-24,0,16),UDim2.fromOffset(12,42),nil,palette.muted);xpInfo.TextSize=11;xpInfo.TextXAlignment=Enum.TextXAlignment.Left
	local xpBack=make("Frame",top,{Size=UDim2.new(1,-24,0,3),Position=UDim2.fromOffset(12,62),BackgroundColor3=Color3.fromRGB(38,63,67),BorderSizePixel=0});round(xpBack,2)
	local xp=make("Frame",xpBack,{Size=UDim2.fromScale(0,1),BackgroundColor3=palette.mint,BorderSizePixel=0});round(xp,2)
	local bossPanel=make("Frame",gui,{Name="BossPanel",Size=UDim2.new(.8,0,0,36),Position=UDim2.new(1,-12,0,38),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.bg,BackgroundTransparency=.12,Visible=false})
	make("UISizeConstraint",bossPanel,{MaxSize=Vector2.new(320,36)});round(bossPanel,8);stroke(bossPanel,palette.gold)
	local bossTitle=label(bossPanel,"흑염룡 · 아그니스",UDim2.new(1,-20,0,18),UDim2.fromOffset(10,3),Enum.Font.GothamBold,palette.gold);bossTitle.TextSize=11
	local bossBack=make("Frame",bossPanel,{Size=UDim2.new(1,-20,0,5),Position=UDim2.fromOffset(10,25),BackgroundColor3=palette.card});round(bossBack,3)
	local bossHealth=make("Frame",bossBack,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(187,110,255),BorderSizePixel=0});round(bossHealth,3)
	local skills=label(top,"화염탄 1 · 골렘 1",UDim2.new(1,-24,0,16),UDim2.fromOffset(12,72),nil,palette.text);skills.TextSize=11;skills.TextXAlignment=Enum.TextXAlignment.Left
	skills.Size=UDim2.new(1,-24,0,26);skills.Position=UDim2.fromOffset(12,68)
	local golemStatus=label(top,"대지 강타 · 자동",UDim2.new(1,-24,0,16),UDim2.fromOffset(12,96),nil,palette.gold);golemStatus.TextSize=11;golemStatus.TextXAlignment=Enum.TextXAlignment.Left
	local pulse=make("TextButton",gui,{Name="Pulse",Size=UDim2.fromOffset(108,72),Position=UDim2.new(1,-20,1,-88),AnchorPoint=Vector2.new(1,1),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="화염 파동\n[Q] 준비",Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=true}); round(pulse,16)
	local dashButton=make("TextButton",gui,{Name="Dash",Size=UDim2.fromOffset(108,58),Position=UDim2.new(1,-20,1,-18),AnchorPoint=Vector2.new(1,1),BackgroundColor3=Color3.fromRGB(135,203,255),TextColor3=palette.bg,Text="대시 [E]\n준비",Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=true});round(dashButton,14)
	local function layoutActions()
		local width=workspace.CurrentCamera.ViewportSize.X
		top.Size=UDim2.fromOffset(math.clamp(width-152,180,340),116)
		info.TextSize=width<500 and 10 or 12
		skills.TextSize=width<500 and 10 or 11
	end
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutActions);layoutActions()
	local overlay=make("Frame",gui,{Name="ChoiceOverlay",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(6,12,19),BackgroundTransparency=.18,Visible=false,ZIndex=10})
	local modal=make("Frame",overlay,{Size=UDim2.new(.88,0,.82,0),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg,ZIndex=11}); round(modal,18); stroke(modal,palette.mint); make("UISizeConstraint",modal,{MaxSize=Vector2.new(570,480)})
	local modalTitle=label(modal,"LEVEL UP",UDim2.new(1,-32,0,32),UDim2.new(0,16,0,14),Enum.Font.GothamBold,palette.mint); modalTitle.TextSize=25; modalTitle.ZIndex=12
	local modalHint=label(modal,"이번 성장을 선택하세요",UDim2.new(1,-32,0,24),UDim2.new(0,16,0,48),nil,palette.muted); modalHint.TextSize=14; modalHint.ZIndex=12
	local cards=make("Frame",modal,{Size=UDim2.new(1,-32,1,-94),Position=UDim2.new(0,16,0,80),BackgroundTransparency=1,ZIndex=12})
	make("UIListLayout",cards,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
	local buttons={}
	local waiting=false
	for i=1,3 do
		local b=make("TextButton",cards,{Name="Choice"..i,Size=UDim2.new(1,0,1/3,-7),BackgroundColor3=palette.card,Text="",LayoutOrder=i,ZIndex=13,AutoButtonColor=true}); round(b,12); stroke(b)
		local tag=label(b,"마법 강화",UDim2.new(1,-28,.25,0),UDim2.new(0,14,0,4),Enum.Font.GothamBold,palette.mint); tag.TextSize=11; tag.TextXAlignment=Enum.TextXAlignment.Left; tag.ZIndex=14
		local name=label(b,"화염탄 강화",UDim2.new(1,-28,.3,0),UDim2.new(0,14,.27,0),Enum.Font.GothamBold); name.TextSize=20; name.TextXAlignment=Enum.TextXAlignment.Left; name.ZIndex=14
		local desc=label(b,"피해량 증가",UDim2.new(1,-28,.29,0),UDim2.new(0,14,.63,0),nil,palette.muted); desc.TextSize=13; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.ZIndex=14
		buttons[i]={button=b,tag=tag,name=name,desc=desc}
		b.Activated:Connect(function() if b:GetAttribute("ChoiceId") and not waiting then waiting=true; net.Action:FireServer("choose",b:GetAttribute("ChoiceId")) end end)
	end
	local ending=make("Frame",gui,{Name="Ending",Size=UDim2.fromScale(1,1),BackgroundColor3=palette.bg,BackgroundTransparency=.08,Visible=false,ZIndex=20})
	local resultTitle=label(ending,"생존 성공!",UDim2.new(.9,0,0,70),UDim2.fromScale(.5,.32),Enum.Font.GothamBold,palette.mint); resultTitle.AnchorPoint=Vector2.new(.5,.5); resultTitle.TextSize=38; resultTitle.ZIndex=21
	local resultInfo=label(ending,"",UDim2.new(.9,0,0,60),UDim2.fromScale(.5,.48),nil,palette.text); resultInfo.AnchorPoint=Vector2.new(.5,.5); resultInfo.TextSize=19; resultInfo.ZIndex=21
	local again=make("TextButton",ending,{Name="Restart",Size=UDim2.fromOffset(220,58),Position=UDim2.fromScale(.5,.65),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="로비로 돌아가기",Font=Enum.Font.GothamBold,TextSize=20,ZIndex=21}); round(again)
	again.Activated:Connect(function() net.Action:FireServer("restart") end)
	pulse.Activated:Connect(deps.input.FireWave)
	dashButton.Activated:Connect(deps.input.Dash)
	local lastChoice=""
	net.State.OnClientEvent:Connect(function(s)
        title.Text=s.phase=="boss" and "DRAGON / 시간 제한 없음" or "SURVIVAL / 드래곤 등장까지"
        bossPanel.Visible=s.phase=="boss" and s.boss~=nil and not s.over
        if s.boss then
            bossHealth.Size=UDim2.fromScale(math.clamp(s.boss.hp/s.boss.maxHp,0,1),1)
            bossTitle.Text=string.format("흑염룡 · 아그니스 · %d단계 · %d / %d",s.boss.stage or 1,math.ceil(s.boss.hp),s.boss.maxHp)..(s.boss.airborne and " · 비행 중" or "")
        end
		timer.Text=s.phase=="boss" and "∞" or string.format("%02d:%02d",math.floor(s.time/60),s.time%60)
		health.Size=UDim2.fromScale(math.clamp(s.hp/s.maxHp,0,1),1)
		xp.Size=UDim2.fromScale(math.clamp(s.xp/s.need,0,1),1)
		info.Text=string.format("Lv.%d  체력 %d/%d  처치 %d",s.level,s.hp,s.maxHp,s.kills)
        xpInfo.Text=string.format("경험치 %d/%d",s.xp,s.need)
		local text={"골렘 "..s.golem}; if s.fire>0 then table.insert(text,"화염탄 "..s.fire)end; if s.lightning>0 then table.insert(text,"번개 "..s.lightning) end; if s.ice>0 then table.insert(text,"얼음 "..s.ice) end
		if (s.meteor or 0)>0 then table.insert(text,"메테오 "..s.meteor)end
		for _,v in ipairs({{"blades","결정"},{"frost","서리"},{"ward","결계"},{"missile","마탄"},{"skyLances","천공"}})do if (s[v[1]] or 0)>0 then table.insert(text,v[2].." "..s[v[1]])end end
		local lines={}
		for i=1,#text,3 do table.insert(lines,table.concat(text," · ",i,math.min(i+2,#text)))end
		skills.Text=table.concat(lines,"\n")
		local activeName=s.activeName or "화염 파동"
		pulse.Text=activeName.."\n"..(s.cooldown>0 and s.cooldown.."초" or "[Q] 준비")
		local dashCd=s.dashCooldown or 0
		dashButton.Text=dashCd>0 and "대시 [E]\n"..string.format("%.1f초",dashCd) or "대시 [E]\n준비"
		dashButton.BackgroundColor3=dashCd>0 and Color3.fromRGB(87,119,143) or Color3.fromRGB(135,203,255)
		golemStatus.Text=(s.golemCooldown or 0)>0 and "대지 강타 · 자동 · "..s.golemCooldown.."초" or "대지 강타 · 자동 · 적 탐색 중"
		if (s.shield or 0)>0 then golemStatus.Text="수호 결계 "..math.ceil(s.shield).." · "..golemStatus.Text end
		pulse.BackgroundColor3=s.cooldown>0 and Color3.fromRGB(101,131,139) or palette.mint
		ending.Visible=s.over==true; overlay.Visible=s.offers~=nil and not s.over
		if s.offers then
			local ids={}; for _,v in ipairs(s.offers) do table.insert(ids,v.id..v.level) end
			local key=s.level..table.concat(ids)
			if key~=lastChoice then waiting=false; lastChoice=key end
			modalHint.Text=s.paused and "전투 일시 정지 · 하나를 선택하세요" or "선택하는 동안 보호됩니다 · 하나를 선택하세요"
			for i,v in ipairs(buttons) do
				local offer=s.offers[i]; v.button.Visible=offer~=nil
				if offer then v.button:SetAttribute("ChoiceId",offer.id); v.tag.Text=offer.tag.."  /  Lv."..offer.level; v.name.Text=offer.title; v.desc.Text=offer.desc end
			end
		else waiting=false; lastChoice="" end
		if s.over then resultTitle.Text=s.result=="victory" and "드래곤 격파!" or "다시 도전!"; resultInfo.Text=string.format("레벨 %d  ·  처치 %d\n이번에 완성한 조합으로 다시 도전해 보세요",s.level,s.kills) end
	end)

	return {
		Gui = gui,
	}
end
]====])
-- Source: src/client/flow/Lobby.luau
addModule(modules,{"flow","Lobby"},[====[
-- Before a run: choose three spells, ready up, then enter the arena together.
return function(deps)
 local player,net,hud,input=deps.player,deps.net,deps.hud,deps.input
 local theme=require(script.Parent.Parent.Theme)
 local make,label,round,stroke=theme.Make,theme.Label,theme.Round,theme.Stroke
 local palette=theme.Palette
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='SummonerLobbyUI',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=30,Enabled=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local veil=make('Frame',gui,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(8,14,27),BackgroundTransparency=.2})
 local panel=make('Frame',veil,{Name='Panel',Size=UDim2.fromOffset(960,744),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg,BackgroundTransparency=.04});round(panel,20);stroke(panel)
 local scale=make('UIScale',panel,{Scale=1})
 local function resize()local v=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(1,(v.X-24)/960,(v.Y-24)/744)end
 workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize);resize()
 local heading=label(panel,'ARCANE HAVEN  /  마법사의 안식처',UDim2.fromOffset(900,38),UDim2.fromOffset(28,18),Enum.Font.GothamBold,palette.mint);heading.TextSize=25;heading.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(panel,'Q 사용 스킬 1개와 자동 마법 3개를 골라 출발하세요.',UDim2.fromOffset(900,24),UDim2.fromOffset(28,62),nil,palette.muted);hint.TextXAlignment=Enum.TextXAlignment.Left;hint.TextSize=15
 local slots=label(panel,'마법 목록을 불러오는 중…',UDim2.fromOffset(900,24),UDim2.fromOffset(28,196),Enum.Font.GothamBold,palette.gold);slots.Name='SelectedSpells';slots.TextXAlignment=Enum.TextXAlignment.Left;slots.TextSize=15
 local grid=make('ScrollingFrame',panel,{Name='Spells',Size=UDim2.fromOffset(904,390),Position=UDim2.fromOffset(28,232),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,BackgroundTransparency=1,BorderSizePixel=0})
 make('UIGridLayout',grid,{CellSize=UDim2.new(.5,-8,0,88),CellPadding=UDim2.fromOffset(12,10),SortOrder=Enum.SortOrder.LayoutOrder})
 local start=make('TextButton',panel,{Name='Start',Size=UDim2.fromOffset(270,48),Position=UDim2.fromOffset(662,642),BackgroundColor3=palette.mint,TextColor3=palette.bg,Font=Enum.Font.GothamBold,TextSize=19,Text='전투 시작',AutoButtonColor=true});round(start,12)
 local status=label(panel,'',UDim2.fromOffset(430,50),UDim2.fromOffset(28,638),nil,palette.muted);status.TextSize=14;status.TextXAlignment=Enum.TextXAlignment.Left
 local footer=label(panel,'Q / 패드 R2 선택한 스킬 · E / 패드 B 대시 · 골렘은 기본 동행  |  선택한 마법은 1단계로 시작하고 레벨업으로 강화됩니다.',UDim2.fromOffset(904,26),UDim2.fromOffset(28,704),nil,palette.muted);footer.TextSize=12
 local activeLabel=label(panel,'Q 사용 스킬',UDim2.fromOffset(900,20),UDim2.fromOffset(28,90),Enum.Font.GothamBold,palette.gold);activeLabel.TextSize=13;activeLabel.TextXAlignment=Enum.TextXAlignment.Left
 local selected,options,buttons={},{},{}
 local activeSkill='fireWave';local activeButtons={}
 local queued=false;local inLobby=nil;local pending=false
 local function refresh()
  local names={};for _,id in ipairs(selected)do for _,v in ipairs(options)do if v.id==id then table.insert(names,v.name)end end end
  slots.Text=string.format('선택 %d / 3   ·   ',#selected)..table.concat(names,'  +  ')
  for id,item in pairs(buttons)do
   local active=table.find(selected,id)~=nil
   item.button.BackgroundColor3=active and Color3.fromRGB(40,65,73) or palette.card
   item.mark.Text=active and '선택됨 ✓' or '선택';item.mark.TextColor3=active and palette.mint or palette.muted
  end
  for id,b in pairs(activeButtons)do b.BackgroundColor3=id==activeSkill and Color3.fromRGB(53,89,99) or palette.card end
  start.Text=queued and '준비 취소' or '전투 시작'
  start.BackgroundColor3=#selected==3 and palette.mint or Color3.fromRGB(92,119,127)
 end
 local function buildActive(items)
  local width=(904-(#items-1)*10)/#items
  for index,v in ipairs(items)do
   local b=make('TextButton',panel,{Name='Active_'..v.id,Size=UDim2.fromOffset(width,58),Position=UDim2.fromOffset(28+(index-1)*(width+10),116),BackgroundColor3=palette.card,Text=v.name..'\n'..v.desc,TextColor3=palette.text,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=true});round(b,10);stroke(b)
   activeButtons[v.id]=b
   b.Activated:Connect(function()if queued or pending then return end;activeSkill=v.id;refresh()end)
  end
 end
 local function build()
  for index,v in ipairs(options)do
   local b=make('TextButton',grid,{Name=v.id,Text='',BackgroundColor3=palette.card,LayoutOrder=index,AutoButtonColor=true});round(b,12);stroke(b,Color3.fromRGB(v.color[1],v.color[2],v.color[3]))
   local name=label(b,v.name,UDim2.new(1,-110,0,23),UDim2.fromOffset(14,8),Enum.Font.GothamBold,Color3.fromRGB(v.color[1],v.color[2],v.color[3]));name.TextSize=18;name.TextXAlignment=Enum.TextXAlignment.Left
   local mark=label(b,'',UDim2.fromOffset(80,23),UDim2.new(1,-90,0,8),nil,palette.mint);mark.TextSize=12
   local role=label(b,v.role,UDim2.new(1,-28,0,18),UDim2.fromOffset(14,33),nil,palette.gold);role.TextSize=11;role.TextXAlignment=Enum.TextXAlignment.Left
   local desc=label(b,v.desc,UDim2.new(1,-28,0,26),UDim2.fromOffset(14,53),nil,palette.muted);desc.TextSize=12;desc.TextXAlignment=Enum.TextXAlignment.Left
   buttons[v.id]={button=b,mark=mark}
   b.Activated:Connect(function()
    if queued or pending then return end
    local i=table.find(selected,v.id)
    if i then table.remove(selected,i)elseif #selected<3 then table.insert(selected,v.id)else status.Text='선택한 마법 하나를 해제한 뒤 다른 마법을 골라 주세요.'end
    refresh()
   end)
  end
 end
 start.Activated:Connect(function()
  if pending then return end
  if queued then net.Action:FireServer('cancelReady');return end
  if #selected~=3 then status.Text='서로 다른 마법을 3개 골라 주세요.';return end
  pending=true;start.Text='출발 준비 중…';net.Action:FireServer('startRound',table.clone(selected),activeSkill)
  task.delay(2,function()pending=false;refresh()end)
 end)
 net.State.OnClientEvent:Connect(function(s)
  local visible=s.lobby==true
  if visible and inLobby~=true then selected=table.clone(s.loadout or {});activeSkill=s.activeSkill or 'fireWave';input.SetSuspended(true);hud.Enabled=false end
  if not visible and inLobby~=false then
   input.SetSuspended(false);hud.Enabled=true
   local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart')
   if root and deps.camera then deps.camera.Reset()end
  end
  local preview=player.PlayerGui:FindFirstChild('DragonPreview');local open=preview and preview:FindFirstChild('OpenButton')
  if open then open.Visible=not visible end
  local skillView=player.PlayerGui:FindFirstChild("SkillPreview")
  inLobby=visible;gui.Enabled=visible and not(skillView and skillView:GetAttribute("Open"));gui:SetAttribute('InLobby',visible)
  if not visible then return end
  if #options==0 and s.spellOptions then options=s.spellOptions;build()end
  if not next(activeButtons) and s.activeOptions then buildActive(s.activeOptions)end
  queued=s.queued==true;pending=false
  status.Text=s.lobbyMessage or(queued and '준비 완료 · 다른 플레이어가 준비하면 함께 출발합니다.' or '혼자라면 바로 출발 · 친구와 함께라면 전원 준비 후 출발')
  refresh()
 end)
 return {Gui=gui}
end
]====])
-- Source: src/client/flow/SkillPreview.luau
addModule(modules,{"flow","SkillPreview"},[====[
-- Studio effect gallery. Uses a local world stage so particles, trails and lights render.
return function(deps)
 local Run=game:GetService('RunService');if not Run:IsStudio()then return end
 local UIS=game:GetService('UserInputService');local GuiService=game:GetService('GuiService')
 local player,net,input,hud=deps.player,deps.net,deps.input,deps.hud
 local theme=require(script.Parent.Parent.Theme);local make,label,round=theme.Make,theme.Label,theme.Round;local palette=theme.Palette
 local spells={
  {id='meteor',name='메테오',note='천천히 낙하하는 대형 운석과 충돌 폭발'},
  {id='skyLances',name='천공의 창',note='상공의 마법진에서 차례로 내려오는 다섯 마법 창'},
  {id='blades',name='비전 결정',note='등 뒤의 다섯 결정 · 개별 발사 · 재충전'},
  {id='frost',name='서리 폭발',note='냉기 응축 · 충격파 · 얼음 결정'},
  {id='missile',name='추적 마탄',note='강한 적 하나를 노리는 단일 대상 추적탄'},
  {id='ward',name='수호 결계',note='결계 생성 · 타격 · 보호막 파괴'},
  {id='fire',name='화염탄',note='불꽃 탄환과 적중 폭발'},
  {id='ice',name='빙결 얼음창',note='정면 마법진 · 얼음창 · 빙결'},
  {id='lightning',name='연쇄 번개',note='하늘에서 내려꽂히는 연쇄 번개'},
  {id='fireWave',name='화염 파동 [Q]',note='정면으로 퍼지는 부채꼴 화염',common=true},
  {id='thunder',name='뇌창 [Q]',note='정면으로 쏘아 보내는 관통 번개 창',common=true},
  {id='aetherLance',name='성운창 [Q]',note='푸른 아지랑이가 모여 가느다란 창으로 발사',common=true},
  {id='iceRush',name='빙하 쇄도 [Q]',note='정면에 솟아오르는 얼음 기둥',common=true},
  {id='golem',name='골렘 대지 강타',note='현재 게임과 같은 5단계 최대 연출',common=true},
  {id='dash',name='대시',note='이동 궤적과 잔상',common=true},
 }
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='SkillPreview',ResetOnSpawn=false,DisplayOrder=90,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local launcher=make('Frame',gui,{Name='Launcher',Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
 local button=make('TextButton',launcher,{Name='SkillPreviewButton',Size=UDim2.fromOffset(166,32),Position=UDim2.fromOffset(174,8),Text='스킬 미리보기 [P]',Font=Enum.Font.GothamBold,TextSize=13,BackgroundColor3=palette.card,TextColor3=palette.gold});round(button,8)
 local overlay=make('Frame',gui,{Name='Overlay',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
 local header=make('Frame',overlay,{Name='Header',Size=UDim2.new(1,-24,0,60),Position=UDim2.fromOffset(12,8),BackgroundColor3=palette.bg,BackgroundTransparency=.04});round(header,10)
 local title=label(header,'스킬 미리보기',UDim2.new(1,-120,0,26),UDim2.fromOffset(14,5),Enum.Font.GothamBold,palette.gold);title.TextSize=18;title.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(header,'연출만 재생 · 전투 일시 정지 · 드래그 회전 / 휠 확대 · 패드 오른쪽 스틱 회전',UDim2.new(1,-120,0,19),UDim2.fromOffset(14,34),nil,palette.muted);hint.TextSize=11;hint.TextXAlignment=Enum.TextXAlignment.Left
 local close=make('TextButton',header,{Name='Close',Size=UDim2.fromOffset(78,34),Position=UDim2.new(1,-90,0,12),BackgroundColor3=palette.card,TextColor3=palette.text,Text='닫기',Font=Enum.Font.GothamBold,TextSize=13});round(close,8)
 local list=make('ScrollingFrame',overlay,{Name='Spells',Size=UDim2.new(0,200,1,-158),Position=UDim2.fromOffset(12,78),BackgroundColor3=palette.bg,BackgroundTransparency=.06,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,BorderSizePixel=0});round(list,8)
 make('UIListLayout',list,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
 make('UIPadding',list,{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
 local surface=make('Frame',overlay,{Name='StageInput',Size=UDim2.new(1,-236,1,-160),Position=UDim2.fromOffset(224,78),BackgroundTransparency=1,Active=true})
 local controlsBar=make('Frame',overlay,{Name='Controls',Size=UDim2.new(1,-236,0,42),Position=UDim2.new(0,224,1,-54),BackgroundColor3=palette.bg,BackgroundTransparency=.04});round(controlsBar,10)
 local clockLabel=label(overlay,'',UDim2.new(1,-236,0,20),UDim2.new(0,224,1,-79),nil,palette.text);clockLabel.TextSize=12
 local controls={}
 for i,item in ipairs({{'Replay','다시 재생'},{'Loop','반복 켬'},{'Level','단계 1'},{'ResetView','시점 초기화'},{'Close','닫기'}})do
  local b=make('TextButton',controlsBar,{Name=item[1],Text=item[2],Size=UDim2.new(.2,-10,1,-12),Position=UDim2.new((i-1)*.2,5,0,6),BackgroundColor3=palette.card,TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=12});round(b,7);controls[item[1]]=b
 end
 local opened,lastLobby,loop,playing=false,false,true,true
 local selected,levelIndex=spells[1],1;local levels={1,3,5}
 local yaw,pitch,distance=0,.65,82
 local scene,oldCamera,oldSelection,playerControls
 local dragging,touch,lastPosition=false,nil,nil;local stick=Vector2.zero
 local spellButtons={};local setOpen
 local function fit()
  yaw=0;pitch=(selected.id=='meteor' or selected.id=='skyLances') and .48 or .65;distance=(selected.id=='meteor' or selected.id=='skyLances') and 140 or 84
 end
 local function refresh()
  title.Text='스킬 미리보기 · '..selected.name..' · '..selected.note
  controls.Loop.Text=loop and '반복 켬'or'반복 끔'
  controls.Level.Text=selected.common and(selected.id=='golem' and '단계 5 · 최대 연출'or'단계 공통')or('단계 '..levels[levelIndex])
  for id,b in pairs(spellButtons)do b.BackgroundColor3=id==selected.id and palette.mint or palette.card;b.TextColor3=id==selected.id and palette.bg or palette.text end
  gui:SetAttribute('SelectedSpell',selected.id);gui:SetAttribute('Level',selected.id=='golem' and 5 or levels[levelIndex]);gui:SetAttribute('Loop',loop)
 end
 local function replay()
  if not scene then return end
  scene.Play(selected.id,selected.id=='golem' and 5 or levels[levelIndex]);playing=true;clockLabel.Text='재생 중…';gui:SetAttribute('PlaybackTime',0);refresh()
 end
 local function selectSpell(item)
  selected=item;fit();replay()
 end
 for i,item in ipairs(spells)do
  local b=make('TextButton',list,{Name='Spell_'..item.id,Size=UDim2.new(1,-2,0,34),LayoutOrder=i,Text=item.name,BackgroundColor3=palette.card,TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=true});round(b,7);spellButtons[item.id]=b
  b.Activated:Connect(function()selectSpell(item)end)
 end
 setOpen=function(value)
  if opened==value then return end
  if value and deps.dragon then deps.dragon.Close()end
  opened=value;overlay.Visible=value;button.Visible=not value;gui:SetAttribute('Open',value)
  input.SetSuspended(value or lastLobby);net.Action:FireServer('previewSkills',value)
  local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI')
  if value then
   oldSelection=GuiService.SelectedObject
   if deps.camera then deps.camera.Suspend(true)end
   local camera=workspace.CurrentCamera;oldCamera={type=camera.CameraType,subject=camera.CameraSubject,frame=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView}
   hud.Enabled=false;if lobby then lobby.Enabled=false end
   if deps.dragon then deps.dragon.Gui.Enabled=false end
   local module=player.PlayerScripts:FindFirstChild('PlayerModule')
   if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then playerControls=result;playerControls:Disable()end end
   if not scene then scene=require(script.Parent.Parent.combat.PreviewScene)({player=player,net=net,gui=gui})end
   fit();replay()
   if UIS.GamepadEnabled then GuiService.SelectedObject=spellButtons[selected.id]end
  else
   dragging=false;touch=nil;stick=Vector2.zero;if scene then scene.Clear()end
   hud.Enabled=not lastLobby;if lobby then lobby.Enabled=lastLobby end
   if deps.dragon then deps.dragon.Gui.Enabled=true end
   if playerControls then playerControls:Enable()end
   local camera=workspace.CurrentCamera
   if deps.camera then deps.camera.Restore(oldCamera)
   elseif oldCamera then
    camera.FieldOfView=oldCamera.fov;camera.CameraSubject=oldCamera.subject and oldCamera.subject.Parent and oldCamera.subject or(player.Character and player.Character:FindFirstChildOfClass('Humanoid'));camera.CameraType=oldCamera.type;camera.CFrame=oldCamera.frame
   end
   GuiService.SelectedObject=oldSelection and oldSelection.Parent and oldSelection or nil
  end
 end
 button.Activated:Connect(function()setOpen(true)end);close.Activated:Connect(function()setOpen(false)end)
 controls.Close.Activated:Connect(function()setOpen(false)end)
 controls.Replay.Activated:Connect(replay)
 controls.Loop.Activated:Connect(function()loop=not loop;if loop and not playing then replay()end;refresh()end)
 controls.Level.Activated:Connect(function()if selected.common then return end;levelIndex=levelIndex%#levels+1;replay()end)
 controls.ResetView.Activated:Connect(fit)
 surface.InputBegan:Connect(function(key)
  if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 or key.UserInputType==Enum.UserInputType.Touch then dragging=true;lastPosition=key.Position;if key.UserInputType==Enum.UserInputType.Touch then touch=key end end
 end)
 surface.InputChanged:Connect(function(key)if opened and key.UserInputType==Enum.UserInputType.MouseWheel then distance=math.clamp(distance*math.exp(-key.Position.Z*.13),24,220)end end)
 local keyConnection=UIS.InputBegan:Connect(function(key,processed)
  if key.KeyCode==Enum.KeyCode.P and(opened or not processed)and not UIS:GetFocusedTextBox()then setOpen(not opened)
  elseif opened then
   if key.KeyCode==Enum.KeyCode.ButtonB then setOpen(false)
   elseif key.KeyCode==Enum.KeyCode.ButtonL1 then distance=math.min(220,distance*1.15)
   elseif key.KeyCode==Enum.KeyCode.ButtonR1 then distance=math.max(24,distance/1.15)end
  end
 end)
 local changedConnection=UIS.InputChanged:Connect(function(key)
  if not opened then return end
  if key.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(key.Position.X,key.Position.Y)end
  if dragging and(key.UserInputType==Enum.UserInputType.MouseMovement or key==touch)then local delta=key.Position-lastPosition;lastPosition=key.Position;yaw-=delta.X*.008;pitch=math.clamp(pitch+delta.Y*.006,.12,1.35)end
 end)
 local endedConnection=UIS.InputEnded:Connect(function(key)if key==touch or key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false;touch=nil end end)
 local stateConnection=net.State.OnClientEvent:Connect(function(s)
  lastLobby=s.lobby==true
  if not opened then
   local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI')
   local panel=lobby and lobby:FindFirstChild('Frame') and lobby.Frame:FindFirstChild('Panel')
   if lastLobby and panel then button.Parent=panel;button.Position=UDim2.fromOffset(480,642);button.Size=UDim2.fromOffset(166,48)
   else button.Parent=launcher;button.Position=UDim2.fromOffset(12,64);button.Size=UDim2.fromOffset(166,32)end
  end
 end)
 local infoClock=0
 local renderConnection=Run.RenderStepped:Connect(function(dt)
  local dragonOpen=deps.dragon and deps.dragon.Gui:GetAttribute('Open')
  button.Visible=not opened and not dragonOpen
  if not opened or not scene then return end
  yaw-=stick.X*dt*2;pitch=math.clamp(pitch-stick.Y*dt*1.2,.12,1.35)
  local focus=scene.Origin+Vector3.new(0,(selected.id=='meteor' or selected.id=='skyLances') and 25 or 5,-5)
  local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=55
  local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),math.cos(yaw)*math.cos(pitch))*distance
  camera.CFrame=CFrame.lookAt(focus+offset,focus)
  if playing then
   local done,time,duration=scene.Step(math.min(dt,.1));infoClock+=dt
   if infoClock>.15 then infoClock=0;clockLabel.Text=string.format('%.1f / %.1f초  ·  피해 없이 연출만 확인',time,duration);gui:SetAttribute('PlaybackTime',time)end
   if done then if loop then replay()else playing=false;clockLabel.Text='재생 완료 · 다시 재생을 누르세요'end end
  end
 end)
 gui:SetAttribute('Open',false);refresh()
 gui.Destroying:Connect(function()
  if opened then setOpen(false)end
  keyConnection:Disconnect();changedConnection:Disconnect();endedConnection:Disconnect();stateConnection:Disconnect();renderConnection:Disconnect()
  if scene then scene.Destroy();scene=nil end
  button:Destroy()
 end)
 return {Gui=gui,Open=function()setOpen(true)end,Close=function()setOpen(false)end}
end
]====])
-- Source: src/client/world/Camera.luau
addModule(modules,{"world","Camera"},[====[
-- A short camera reset at spawn/entry, then Roblox's standard free orbit takes over.
return function(deps)
 local Run=game:GetService('RunService')
 local player=deps.player
 local binding='SummonerCameraReset_'..player.UserId
 local suspended=false;local seeding=false
 local function cancel()
  Run:UnbindFromRenderStep(binding)
  if seeding then
   seeding=false;player.CameraMinZoomDistance=8;player.CameraMaxZoomDistance=85
   if workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end
  end
 end
 local function seed(offset,fov)
  cancel();if suspended then return end
  local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
  if not h or not root then return end
  if not offset then
   local back=Vector3.new(-root.CFrame.LookVector.X,0,-root.CFrame.LookVector.Z)
   if back.Magnitude<.1 then back=Vector3.zAxis else back=back.Unit end
   offset=back*24+Vector3.new(0,14,0)
  end
  local distance=math.clamp(offset.Magnitude,8,85);offset=offset.Unit*distance
  player.CameraMode=Enum.CameraMode.Classic;player.CameraMaxZoomDistance=distance;player.CameraMinZoomDistance=distance
  local camera=workspace.CurrentCamera;camera.CameraSubject=h;camera.FieldOfView=fov or 70;camera.CameraType=Enum.CameraType.Scriptable
  seeding=true;local elapsed,frames,released=0,0,0
  Run:BindToRenderStep(binding,Enum.RenderPriority.Camera.Value+1,function(dt)
   if suspended or player.Character~=c or not root.Parent then cancel();return end
   elapsed+=dt;frames+=1
   local focus=root.Position+Vector3.new(0,1.5,0)
   camera.Focus=CFrame.new(focus);camera.CFrame=CFrame.lookAt(focus+offset,focus)
   if elapsed>=.18 and frames>=4 then
    camera.CameraType=Enum.CameraType.Custom;released+=1
    if released>=3 then cancel()end
   else camera.CameraType=Enum.CameraType.Scriptable end
  end)
 end
 local function bind(character)
  character:WaitForChild('Humanoid');character:WaitForChild('HumanoidRootPart')
  if player.Character==character and not suspended then seed()end
 end
 player.CharacterAdded:Connect(function(c)task.spawn(bind,c)end)
 if player.Character then task.spawn(bind,player.Character)end
 return {
  Reset=function()seed()end,
  Suspend=function(value)suspended=value;if value then cancel()end end,
  Restore=function(snapshot)
   suspended=false
   local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart')
   if snapshot and snapshot.type==Enum.CameraType.Custom and snapshot.focus and root and (snapshot.focus.Position-root.Position).Magnitude<12 then
    local offset=snapshot.frame.Position-snapshot.focus.Position
    if offset.Magnitude>=8 and offset.Magnitude<=85 then seed(offset,snapshot.fov);return end
   end
   seed()
  end,
 }
end
]====])
-- Source: src/client/world/CharacterMotion.luau
addModule(modules,{"world","CharacterMotion"},[====[
-- Reused CC0 R15 leg clips. Roblox Animate keeps ownership of the upper body.
-- Presentation only: no root displacement, jump physics or server state changes.
return function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local folder = script.Parent:WaitForChild("clips")
	local clips = {
		walk = require(folder:WaitForChild("Walk_Carry_Loop")),
		jump = require(folder:WaitForChild("NinjaJump_Start")),
		air = require(folder:WaitForChild("NinjaJump_Idle_Loop")),
		land = require(folder:WaitForChild("NinjaJump_Land")),
	}
	local legs = {LeftHip=true,RightHip=true,LeftKnee=true,RightKnee=true,LeftAnkle=true,RightAnkle=true}
	local records = {}
	local function sample(clip, time)
		local t = clip.Loop and time % clip.Duration or math.clamp(time,0,clip.Duration)
		local frames = clip.Frames
		local index = math.clamp(math.floor(t*60)+1,1,#frames)
		local a, b = frames[index], frames[math.min(index+1,#frames)]
		local alpha = math.clamp((t-a.Time)/math.max(b.Time-a.Time,.00001),0,1)
		local pose = {}
		for name in pairs(legs) do pose[name] = a.Pose[name]:Lerp(b.Pose[name],alpha) end
		return pose
	end
	local function restore(record)
		for motor, transform in pairs(record.restore) do
			if motor.Parent then motor.Transform = transform end
		end
		table.clear(record.restore)
	end
	-- Restore the previous frame before Animator writes; prevents additive drift.
	local before = RunService.PreAnimation:Connect(function()
		for _, record in pairs(records) do restore(record) end
	end)
	local step = RunService.PreSimulation:Connect(function(dt)
		dt = math.min(dt,.1)
		local live = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root or humanoid.RigType ~= Enum.HumanoidRigType.R15 then continue end
			live[character] = true
			local record = records[character]
			if not record then
				record = {motors={},restore={},phase=0,time=0,weight=0,mode="idle",wasAir=false,pose=nil}
				for _, child in ipairs(character:GetDescendants()) do
					if child:IsA("Motor6D") and legs[child.Name] then record.motors[child.Name] = child end
				end
				records[character] = record
			end
			local state = humanoid:GetState()
			local velocity = root.AssemblyLinearVelocity
			local speed = Vector3.new(velocity.X,0,velocity.Z).Magnitude
			local airborne = state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
			local blocked = humanoid.Health<=0 or humanoid.WalkSpeed<=0 or humanoid.Sit or humanoid.PlatformStand
				or state==Enum.HumanoidStateType.Swimming or state==Enum.HumanoidStateType.Climbing
			local mode = "idle"
			if not blocked then
				if airborne then
					mode = (not record.wasAir or (record.mode=="jump" and record.time<.18)) and "jump" or "air"
				elseif record.wasAir or (record.mode=="land" and record.time<.2) then mode="land"
				elseif speed>1 and humanoid.AutoRotate then mode="walk" end
			end
			if mode~=record.mode then record.time=0;record.mode=mode end
			record.time+=dt;record.wasAir=airborne
			local target = clips[mode]
			if target then
				local time = record.time
				if mode=="walk" then
					record.phase+=dt*math.clamp(speed/7,.5,3.5);time=record.phase
				elseif mode=="jump" then time=math.min(time/.18,1)*target.Duration
				elseif mode=="land" then time=math.min(time/.2,1)*target.Duration end
				local pose=sample(target,time)
				if record.pose then for name,value in pairs(pose) do pose[name]=record.pose[name]:Lerp(value,1-math.exp(-dt*22)) end end
				record.pose=pose
			end
			record.weight+=( (target and 1 or 0)-record.weight)*(1-math.exp(-dt*18))
			if humanoid.Health<=0 then record.weight=0 end
			if record.pose and record.weight>.001 then
				for name,motor in pairs(record.motors) do
					if motor.Parent then record.restore[motor]=motor.Transform;motor.Transform=motor.Transform:Lerp(record.pose[name],record.weight) end
				end
			end
			character:SetAttribute("SummonerMotion",mode)
		end
		for character,record in pairs(records) do
			if not live[character] then restore(record);records[character]=nil end
		end
	end)
	return {Destroy=function()
		before:Disconnect();step:Disconnect()
		for character,record in pairs(records) do restore(record);character:SetAttribute("SummonerMotion",nil) end
		table.clear(records)
	end}
end
]====])
-- Source: src/client/world/DragonMesh.luau
addModule(modules,{"world","DragonMesh"},[====[
-- Cethiel/Drummyfish CC0 geometry + original Collada animation tracks.
-- CPU skinning of 633 vertices keeps the complete original welded silhouette.
local folder=script.Parent.dragon
local geometry=require(folder.Geometry)
local skeleton=require(folder.Rig)
local Mesh={}
local function cf(v)return CFrame.new(table.unpack(v))end
local armature=cf(skeleton.armature)
local bones={};local boneNames={}
for _,b in ipairs(skeleton.bones)do bones[#bones+1]={index=b.index,name=b.name,parent=b.parent,rest=cf(b.rest),inverse=cf(b.inverse)};boneNames[b.index]=b.name end
local clips={}
for name,module in pairs({idle=folder.Idle,walk=folder.Walk,attack=folder.Attack,die=folder.Die})do
 local source=require(module);local tracks={}
 for index,v in pairs(source.tracks)do
  local poses={};for _,p in ipairs(v.poses)do table.insert(poses,cf(p))end
  tracks[tonumber(index)]={times=v.times,poses=poses}
 end
 clips[name]={duration=source.duration,tracks=tracks}
end
local positions={};for _,v in ipairs(geometry.positions)do table.insert(positions,Vector3.new(table.unpack(v)))end
local function sample(track,time)
 local times=track.times
 for i=1,#times-1 do if time<=times[i+1]then return track.poses[i]:Lerp(track.poses[i+1],math.clamp((time-times[i])/math.max(.0001,times[i+1]-times[i]),0,1))end end
 return track.poses[#times]
end
function Mesh.create(parent)
 local asset=game:GetService('AssetService')
 local editable=asset:CreateEditableMesh();assert(editable,'Editable mesh memory budget exhausted')
 local ids={}
 for _,p in ipairs(positions)do table.insert(ids,editable:AddVertex(p))end
 for i,tri in ipairs(geometry.triangles)do
  local face=editable:AddTriangle(ids[tri[1]],ids[tri[2]],ids[tri[3]])
  local colors={}
  for j=1,3 do local rgb=geometry.colors[(i-1)*3+j];colors[j]=editable:AddColor(Color3.fromRGB(rgb[1],rgb[2],rgb[3]),1)end
  editable:SetFaceColors(face,colors)
  if i%250==0 then task.wait()end
 end
 local part=asset:CreateMeshPartAsync(Content.fromObject(editable))
 part.Name='CethielDragonMesh';part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.DoubleSided=true;part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic;part.Parent=parent
 local rig={mesh=editable,part=part,ids=ids,previous={},center=editable:GetCenter()}
 Mesh.pose(rig,CFrame.identity,0,'idle',0)
 return rig
end
function Mesh.pose(rig,origin,time,mode,progress,gaitTime)
 local clip=clips[(mode=='walk'and'walk')or(mode=='breath'or mode=='eruption'or mode=='roar'or mode=='airBreath')and'attack'or'idle']
 local playTime=(mode=='breath'or mode=='eruption'or mode=='roar'or mode=='airBreath')and math.clamp(progress or 0,0,1)*clip.duration or (mode=='walk'and(gaitTime or time)or time)%clip.duration
 local targetFlight=(mode=='fly'or mode=='airBreath')and 1 or(mode=='dive'and .8 or 0)
 rig.flight=(rig.flight or 0)+(targetFlight-(rig.flight or 0))*.18
 local tailTarget=0
 if mode=='tailWindup'then tailTarget=.35*(progress or 0)
 elseif mode=='tail'then local p=progress or 0;tailTarget=.35*(1-p)-.45*math.sin(p*math.pi)end
 rig.tailAngle=(rig.tailAngle or 0)+(tailTarget-(rig.tailAngle or 0))*.3
 local global,skin,wingPivot={},{},{}
 local tailBase,tailAxis
 for _,b in ipairs(bones)do
  local track=clip.tracks[b.index]
  local pose=track and sample(track,playTime)or b.rest
  if rig.previous[b.index]then pose=rig.previous[b.index]:Lerp(pose,.45)end
  rig.previous[b.index]=pose
  local parent=b.parent==0 and armature or global[b.parent]
  local g=parent*pose
  if rig.flight>.001 and string.find(b.name,'wing_')then
   local side=string.find(b.name,'_L$')and 1 or -1
   local beat=math.sin(time*5.5)
   local angle=(string.find(b.name,'upper')and(-1.85+beat*.25)or(beat*.45))*side*rig.flight
   if mode=='dive'then angle*=.8 end
   local pivot=g.Position;g=CFrame.new(pivot)*CFrame.Angles(0,0,angle)*CFrame.new(-pivot)*g
  end
  if rig.flight>.001 and string.find(b.name,'leg_')and string.find(b.name,'upper')then
   local pivot=g.Position;g=CFrame.new(pivot)*CFrame.Angles(-.55*rig.flight,0,0)*CFrame.new(-pivot)*g
  elseif math.abs(rig.tailAngle)>.001 and(string.find(b.name,'^tail')or b.name=='back2')then
   local weight=b.name=='back2'and .25 or(b.name=='tail1'and .8 or(b.name=='tail2'and .45 or .25))
   local angle=rig.tailAngle*weight
   local pivot=g.Position;g=CFrame.new(pivot)*CFrame.Angles(0,angle,0)*CFrame.new(-pivot)*g
  end
  if string.find(b.name,'wing_lower')then wingPivot[b.index]=g.Position
  elseif string.find(b.name,'wing_upper')then wingPivot[b.index]=wingPivot[b.parent]end
  if b.name=='tail1'then tailBase=g.Position elseif b.name=='tail2'and tailBase then tailAxis=(g.Position-tailBase).Unit end
  global[b.index]=g;skin[b.index]=g*b.inverse
 end
 for i,p in ipairs(positions)do
  local result=Vector3.zero
  for _,w in ipairs(geometry.weights[i])do
   local point=skin[w[1]]*p;local pivot=wingPivot[w[1]]
   if pivot then
    local offset=point-pivot
    -- Extend span more than chord, retaining the thin membrane and body proportions.
    offset=Vector3.new(offset.X*1.9,offset.Y*1.5,offset.Z*1.8)
    point=pivot+offset*(1+rig.flight*.7)
   end
   if tailBase and tailAxis and string.find(boneNames[w[1]],'^tail')then point+=tailAxis*(point-tailBase):Dot(tailAxis)*1.0 end
   result+=point*w[2]
  end
  rig.mesh:SetPosition(rig.ids[i],result)
 end
 local lean=mode=='dive'and -math.sin((progress or 0)*math.pi)*math.rad(23)or((mode=='fly'or mode=='airBreath')and -math.rad(7)or 0)
 local landing=mode=='land'and -.9*math.sin((progress or 0)*math.pi)or 0
 local visualOrigin=origin*CFrame.Angles(lean,0,(rig.bank or 0)*rig.flight)*CFrame.new(0,landing,0)
 rig.part.CFrame=visualOrigin*CFrame.new(0,skeleton.groundOffset,0)
 rig.jaw=visualOrigin*CFrame.new(0,skeleton.groundOffset,0)*global[7]
 if rig.part.Parent then rig.part.Parent:SetAttribute('DragonMouth',rig.jaw.Position)end
end
function Mesh.destroy(rig)
 rig.part:Destroy();rig.mesh:Destroy()
end
return Mesh
]====])
-- Source: src/client/world/DragonPresentation.luau
addModule(modules,{"world","DragonPresentation"},[====[
-- A single local mesh per boss; server only replicates root and animation state.
return function()
 local Run=game:GetService('RunService')
 local mesh=require(script.Parent.DragonMesh)
 local rigs={};local creating={};local elapsed=0
 local function attach(model)
  if rigs[model]or creating[model]then return end
  creating[model]=true
  task.spawn(function()
   local root=model:WaitForChild('Root',5)
   if not root or not model.Parent then creating[model]=nil;return end
   local ok,rig=pcall(mesh.create,model)
   creating[model]=nil
   if not ok then model:SetAttribute('DragonMeshStatus','Failed');warn('[DragonMesh] '..tostring(rig));return end
   if not model.Parent then mesh.destroy(rig);return end
   model:SetAttribute('DragonMeshStatus','Ready');rig.root=root;rig.time=0;rig.gaitTime=0;rig.previousPosition=root.Position;rig.visualFrame=root.CFrame;rigs[model]=rig
  end)
 end
 local world=workspace:WaitForChild('SummonerRuntime')
 for _,v in ipairs(world:GetChildren())do if v.Name=='EmberDragon'then attach(v)end end
 world.ChildAdded:Connect(function(v)if v.Name=='EmberDragon'then attach(v)end end)
 Run.RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<1/24 then return end
  local delta=elapsed;elapsed=0
  for model,rig in pairs(rigs)do
   if not model.Parent or not rig.root.Parent then mesh.destroy(rig);rigs[model]=nil
   else
    rig.time+=delta
    local mode=model:GetAttribute('Animation')or'idle'
    local movement=rig.root.Position-rig.previousPosition;rig.previousPosition=rig.root.Position
    local distance=Vector3.new(movement.X,0,movement.Z).Magnitude
    if mode=='walk'then rig.gaitTime+=math.min(distance,3)/12*1.66667 end
    local target=rig.root.CFrame
    local relative=rig.visualFrame:ToObjectSpace(target);local _,turn=relative:ToOrientation()
    rig.bank=(rig.bank or 0)+(math.clamp(-turn*.4,-.18,.18)-(rig.bank or 0))*.25
    rig.visualFrame=rig.visualFrame:Lerp(target,1-math.exp(-delta*24))
    mesh.pose(rig,rig.visualFrame,rig.time,mode,model:GetAttribute('PoseProgress')or 0,rig.gaitTime)
   end
  end
 end)
end
]====])
-- Source: src/client/world/DragonPreview.luau
addModule(modules,{"world","DragonPreview"},[====[
-- Studio-only model viewer. Own WorldModel/camera; it never moves the live dragon.
return function(deps)
 local Run=game:GetService('RunService')
 if not Run:IsStudio()then return end
 local UIS=game:GetService('UserInputService')
 local player,net,input,hud=deps.player,deps.net,deps.input,deps.hud
 local theme=require(script.Parent.Parent.Theme)
 local make,label,round=theme.Make,theme.Label,theme.Round
 local colors=theme.Palette
 local renderer=require(script.Parent.DragonMesh)
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='DragonPreview',ResetOnSpawn=false,DisplayOrder=80,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local button=make('TextButton',gui,{Name='OpenButton',Text='드래곤 보기 [V]',Size=UDim2.fromOffset(150,32),Position=UDim2.fromOffset(12,8),BackgroundColor3=colors.card,TextColor3=colors.mint,Font=Enum.Font.GothamBold,TextSize=13});round(button,8)
 local overlay=make('Frame',gui,{Name='Overlay',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,10,16),BackgroundTransparency=.05,Visible=false,Active=true})
 local panel=make('Frame',overlay,{Size=UDim2.fromScale(.96,.94),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=colors.bg});round(panel,14)
 make('UISizeConstraint',panel,{MaxSize=Vector2.new(1100,820)})
 local title=label(panel,'흑염룡 · 아그니스',UDim2.new(1,-32,0,28),UDim2.fromOffset(16,10),Enum.Font.GothamBold,colors.gold);title.TextSize=19;title.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(panel,'드래그 회전 · 휠 확대/축소 · 전투 일시 정지',UDim2.new(1,-32,0,20),UDim2.fromOffset(16,41),nil,colors.muted);hint.TextSize=11;hint.TextXAlignment=Enum.TextXAlignment.Left

 local view=make('ViewportFrame',panel,{Name='Viewport',Size=UDim2.new(1,-24,1,-150),Position=UDim2.fromOffset(12,68),BackgroundColor3=Color3.fromRGB(23,33,49),Ambient=Color3.fromRGB(205,215,235),LightColor=Color3.fromRGB(255,242,226),LightDirection=Vector3.new(.6,-.7,1),Active=true});round(view,10)
 local camera=make('Camera',view,{Name='PreviewCamera',FieldOfView=40});view.CurrentCamera=camera
 local world=make('WorldModel',view,{Name='PreviewWorld'})
 local loading=label(view,'드래곤을 불러오는 중…',UDim2.fromScale(1,1),UDim2.new(),nil,colors.muted);loading.TextSize=14
 local rig,creating,opened=nil,false,false
 local yaw,pitch,distance=-.35,.22,80
 local mode,elapsed,autoRotate,playing='fly',0,false,true
 local dragging,touch,lastPosition=false,nil,nil
 local controls,oldHudEnabled,oldSelection
 local poseButtons={};local utility={}
 local function cameraStep()
  local aspect=view.AbsoluteSize.X/math.max(1,view.AbsoluteSize.Y)
  local radius=distance*math.max(1,1.6/aspect)
  local focus=Vector3.new(0,12,7)
  local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),-math.cos(yaw)*math.cos(pitch))*radius
  camera.CFrame=CFrame.lookAt(focus+offset,focus)
 end
 local function refresh()
  for name,b in pairs(poseButtons)do b.BackgroundColor3=name==mode and colors.mint or colors.card;b.TextColor3=name==mode and colors.bg or colors.text end
  utility.Auto.Text=autoRotate and '자동회전 켬'or'자동회전 끔'
  utility.Pause.Text=playing and '일시정지'or'재생'
  gui:SetAttribute('ViewingMode',mode)
 end
 local function buildRig()
  if rig or creating then return end
  creating=true;loading.Visible=true;loading.Text='드래곤을 불러오는 중…'
  task.spawn(function()
   local model=Instance.new('Model');model.Name='PreviewDragon';model.Parent=world
   local ok,result=pcall(renderer.create,model);creating=false
   if not gui.Parent then if ok then renderer.destroy(result)end;model:Destroy();return end
   if not ok then model:Destroy();loading.Text='드래곤을 표시하지 못했어요. Mesh / Image APIs 설정을 확인해 주세요.';gui:SetAttribute('MeshStatus','Failed');warn('[DragonPreview] '..tostring(result));return end
   rig=result;loading.Visible=false;gui:SetAttribute('MeshStatus','Ready')
  end)
 end
 local function setOpen(value)
  if opened==value then return end
  if value and deps.beforeOpen then deps.beforeOpen()end
  opened=value;overlay.Visible=value;button.Visible=not value;gui:SetAttribute('Open',value)
  input.SetSuspended(value)
  net.Action:FireServer('previewDragon',value)
  if value then
   oldHudEnabled=hud.Enabled;hud.Enabled=false
   oldSelection=game:GetService('GuiService').SelectedObject
   local module=player.PlayerScripts:FindFirstChild('PlayerModule')
   if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then controls=result;controls:Disable()end end
   if UIS.GamepadEnabled then game:GetService('GuiService').SelectedObject=poseButtons.fly end
   cameraStep();buildRig()
  else
   dragging=false;touch=nil;hud.Enabled=oldHudEnabled~=false
   if controls then controls:Enable()end
   game:GetService('GuiService').SelectedObject=oldSelection
  end
 end
 for i,item in ipairs({{'idle','기본 모습'},{'walk','걷기'},{'fly','비행'},{'tail','꼬리 공격'}})do
  local b=make('TextButton',panel,{Name='Pose_'..item[1],Text=item[2],Size=UDim2.new(.25,-12,0,28),Position=UDim2.new((i-1)*.25,12-(i-1)*6,1,-72),BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamBold,TextSize=12});round(b,7);poseButtons[item[1]]=b
  b.Activated:Connect(function()mode=item[1];elapsed=0;refresh()end)
 end
 for i,item in ipairs({{'Auto','자동회전 끔'},{'Front','정면'},{'Side','측면'},{'Pause','일시정지'},{'Close','닫기'}})do
  local b=make('TextButton',panel,{Name=item[1],Text=item[2],Size=UDim2.new(.2,-11,0,28),Position=UDim2.new((i-1)*.2,12-(i-1)*4.8,1,-38),BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamMedium,TextSize=11});round(b,7);utility[item[1]]=b
 end
 utility.Auto.Activated:Connect(function()autoRotate=not autoRotate;refresh()end)
 utility.Front.Activated:Connect(function()yaw=0;pitch=.18;distance=80;cameraStep()end)
 utility.Side.Activated:Connect(function()yaw=math.pi/2;pitch=.22;distance=80;cameraStep()end)
 utility.Pause.Activated:Connect(function()playing=not playing;refresh()end)
 button.Activated:Connect(function()setOpen(true)end)
 utility.Close.Activated:Connect(function()setOpen(false)end)
 local keyConnection=UIS.InputBegan:Connect(function(key,processed)
  if key.KeyCode==Enum.KeyCode.V and(opened or not processed)and not UIS:GetFocusedTextBox()then setOpen(not opened)
  elseif opened and key.KeyCode==Enum.KeyCode.ButtonB then setOpen(false)end
 end)
 view.InputBegan:Connect(function(key)
  if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 or key.UserInputType==Enum.UserInputType.Touch then
   dragging=true;lastPosition=key.Position;if key.UserInputType==Enum.UserInputType.Touch then touch=key end
  end
 end)
 local changedConnection=UIS.InputChanged:Connect(function(key)
  if opened and dragging and(key.UserInputType==Enum.UserInputType.MouseMovement or key==touch)then
   local delta=key.Position-lastPosition;lastPosition=key.Position;yaw-=delta.X*.008;pitch=math.clamp(pitch+delta.Y*.006,-.15,1.15)
  end
 end)
 local endedConnection=UIS.InputEnded:Connect(function(key)
  if key==touch or key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false;touch=nil end
 end)
 view.InputChanged:Connect(function(key)if opened and key.UserInputType==Enum.UserInputType.MouseWheel then distance=math.clamp(distance*math.exp(-key.Position.Z*.12),55,190)end end)
 gui:SetAttribute('Open',false)
 refresh();cameraStep()
 local renderClock=0
 local renderConnection=Run.RenderStepped:Connect(function(dt)
  if not opened then return end
  if autoRotate then yaw+=dt*.22 end
  cameraStep();renderClock+=dt;if renderClock<1/24 then return end
  local delta=renderClock;renderClock=0;if playing then elapsed+=math.min(delta,.1)end
  if not rig then return end
  local pose,progress,origin=mode,0,CFrame.identity
  if mode=='tail'then
   local cycle=elapsed%3.2
   if cycle<1 then pose='tailWindup';progress=math.clamp((cycle-.5)/.5,0,1);origin=CFrame.Angles(0,math.rad(18)*progress*progress*(3-2*progress),0)
   elseif cycle<2.35 then
    progress=(cycle-1)/1.35;local eased=progress^3*(progress*(progress*6-15)+10);origin=CFrame.Angles(0,math.rad(18)-(math.pi*2+math.rad(18))*eased,0)
   else pose='idle'end
  end
  renderer.pose(rig,origin,elapsed,pose,progress,elapsed)
 end)
 gui.Destroying:Connect(function()
  if opened then setOpen(false)end
  keyConnection:Disconnect();changedConnection:Disconnect();endedConnection:Disconnect();renderConnection:Disconnect()
  if rig then renderer.destroy(rig);rig=nil end
 end)
 return {Gui=gui,Open=function()setOpen(true)end,Close=function()setOpen(false)end}
end
]====])
-- Source: src/client/world/clips/NinjaJump_Idle_Loop.luau
addModule(modules,{"world","clips","NinjaJump_Idle_Loop"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
{0,-13117,0,57789,-30744,20704,113003,22957,39182,-270344,23601,-10922,-58819,38767,22167,79557,-43384,-106191,-276639,14881,-5841,-38690,-82963,-8343,-161894,-11411,11889,-17993,40315,-4423,114857,64141,-86499,44040,20941,-14449,6347,25612,52095,-18776,-12413,23952,23019,23714,26849,56871,26115,1070},
{0,-13119,0,57778,-30747,20684,112581,22836,39165,-269978,23568,-11010,-58719,38794,22167,79311,-43262,-106263,-276533,14495,-5709,-38543,-82711,-8250,-161674,-11625,11966,-18125,40570,-4460,114803,64108,-86447,44040,20941,-14449,6396,25726,51969,-18852,-12196,23989,23019,23714,26849,56716,26281,903},
{0,-13127,0,57746,-30755,20626,112197,22734,39162,-269613,23502,-11083,-58639,38841,22172,79042,-43121,-106328,-276428,14032,-5545,-38374,-82421,-8148,-161438,-11864,12056,-18229,40781,-4527,114767,64054,-86404,44040,20941,-14449,6454,25861,51827,-18857,-11950,24023,23019,23714,26849,56535,26454,734},
{0,-13134,0,57714,-30763,20568,111813,22632,39159,-269249,23435,-11155,-58559,38888,22177,78773,-42979,-106392,-276322,13569,-5381,-38206,-82131,-8048,-161201,-12104,12147,-18332,40992,-4595,114731,63999,-86361,44040,20941,-14449,6512,25996,51684,-18861,-11704,24056,23019,23714,26849,56354,26628,566},
{0,-13146,0,57663,-30776,20474,111470,22550,39170,-268892,23339,-11211,-58499,38952,22186,78485,-42822,-106447,-276216,13040,-5188,-38021,-81808,-7941,-160949,-12365,12249,-18409,41163,-4692,114712,63924,-86327,44040,20941,-14449,6578,26149,51526,-18801,-11433,24085,23019,23714,26849,56149,26806,397},
{0,-13157,0,57612,-30789,20380,111127,22467,39181,-268534,23242,-11267,-58438,39016,22196,78198,-42664,-106502,-276109,12511,-4995,-37837,-81485,-7836,-160696,-12627,12351,-18486,41333,-4788,114693,63849,-86292,44040,20941,-14449,6643,26302,51368,-18741,-11162,24114,23019,23714,26849,55944,26985,228},
{0,-13173,0,57543,-30806,20254,110828,22404,39206,-268190,23119,-11306,-58395,39094,22208,77896,-42492,-106546,-276003,11924,-4777,-37639,-81135,-7728,-160431,-12908,12464,-18538,41464,-4912,114690,63754,-86266,44040,20941,-14449,6716,26470,51195,-18623,-10870,24138,23019,23714,26849,55718,27167,61},
{0,-13188,0,57474,-30822,20127,110530,22341,39231,-267845,22996,-11344,-58353,39173,22221,77595,-42320,-106590,-275895,11338,-4559,-37443,-80784,-7621,-160165,-13188,12578,-18589,41596,-5036,114686,63659,-86239,44040,20941,-14449,6789,26639,51021,-18506,-10578,24162,23018,23714,26849,55491,27351,-107},
{0,-13207,0,57388,-30842,19971,110278,22299,39269,-267518,22850,-11366,-58328,39265,22235,77284,-42137,-106622,-275786,10703,-4319,-37237,-80410,-7514,-159889,-13485,12702,-18617,41690,-5184,114697,63547,-86220,44040,20941,-14449,6868,26820,50835,-18337,-10269,24181,23019,23714,26849,55245,27537,-272},
{0,-13226,0,57303,-30862,19814,110027,22256,39308,-267191,22704,-11387,-58303,39357,22250,76973,-41953,-106653,-275676,10069,-4078,-37032,-80036,-7407,-159612,-13781,12826,-18644,41785,-5333,114708,63435,-86200,44040,20941,-14449,6947,27001,50648,-18168,-9961,24199,23019,23714,26849,55000,27723,-438},
{0,-13248,0,57202,-30884,19630,109824,22233,39360,-266887,22539,-11390,-58293,39460,22266,76656,-41759,-106671,-275566,9395,-3818,-36821,-79642,-7302,-159326,-14091,12959,-18649,41845,-5504,114732,63306,-86187,44040,20941,-14449,7031,27192,50450,-17956,-9640,24212,23019,23714,26849,54737,27911,-600},
{0,-13270,0,57102,-30906,19446,109622,22210,39411,-266583,22374,-11393,-58284,39563,22282,76340,-41566,-106689,-275454,8722,-3558,-36612,-79249,-7199,-159040,-14401,13094,-18654,41905,-5676,114755,63178,-86174,44040,20941,-14449,7116,27383,50251,-17743,-9319,24224,23019,23714,26849,54474,28100,-762},
{0,-13295,0,56988,-30929,19238,109471,22208,39475,-266308,22192,-11379,-58290,39676,22298,76022,-41365,-106693,-275341,8017,-3282,-36399,-78840,-7099,-158748,-14721,13235,-18639,41933,-5867,114791,63035,-86167,44040,20941,-14449,7205,27582,50042,-17493,-8990,24231,23019,23714,26849,54197,28289,-919},
{0,-13319,0,56874,-30952,19029,109321,22206,39540,-266032,22010,-11364,-58296,39789,22315,75705,-41164,-106696,-275227,7313,-3005,-36189,-78431,-7001,-158455,-15040,13378,-18623,41961,-6059,114827,62892,-86160,44040,20941,-14449,7295,27781,49832,-17244,-8661,24237,23018,23714,26849,53920,28478,-1077},
{0,-13346,0,56748,-30977,18799,109225,22224,39615,-265790,21813,-11331,-58315,39911,22332,75389,-40958,-106685,-275112,6586,-2716,-35978,-78012,-6908,-158158,-15367,13527,-18589,41958,-6269,114873,62736,-86158,44040,20941,-14449,7388,27985,49614,-16964,-8329,24237,23018,23714,26849,53630,28667,-1229},
{0,-13372,0,56622,-31001,18569,109129,22243,39691,-265548,21617,-11297,-58334,40033,22349,75074,-40753,-106673,-274995,5859,-2426,-35768,-77592,-6816,-157861,-15694,13677,-18554,41955,-6478,114920,62580,-86156,44040,20941,-14449,7481,28189,49395,-16683,-7997,24237,23019,23714,26849,53340,28856,-1380},
{0,-13400,0,56486,-31025,18320,109090,22281,39776,-265345,21408,-11245,-58365,40163,22365,74763,-40544,-106648,-274879,5116,-2127,-35561,-77165,-6730,-157561,-16025,13832,-18502,41924,-6704,114976,62413,-86159,44040,20941,-14449,7577,28396,49170,-16380,-7666,24231,23018,23714,26849,53040,29043,-1525},
{0,-13428,0,56349,-31049,18071,109052,22320,39862,-265142,21200,-11193,-58396,40293,22382,74453,-40335,-106621,-274760,4374,-1827,-35355,-76738,-6646,-157262,-16356,13988,-18451,41893,-6929,115032,62245,-86162,44040,20941,-14449,7674,28602,48944,-16076,-7335,24225,23019,23714,26849,52741,29231,-1670},
{0,-13458,0,56203,-31072,17805,109073,22380,39957,-264983,20981,-11122,-58438,40429,22398,74152,-40126,-106581,-274641,3624,-1520,-35154,-76307,-6570,-156962,-16688,14147,-18383,41836,-7167,115097,62068,-86169,44040,20941,-14449,7772,28810,48712,-15755,-7009,24213,23018,23714,26849,52433,29416,-1807},
{0,-13487,0,56057,-31095,17539,109093,22439,40051,-264824,20762,-11050,-58481,40566,22415,73850,-39917,-106540,-274520,2874,-1212,-34954,-75877,-6495,-156663,-17020,14308,-18316,41778,-7405,115161,61891,-86177,44040,20941,-14449,7870,29017,48481,-15435,-6683,24201,23019,23714,26849,52126,29601,-1944},
{0,-13517,0,55904,-31117,17260,109177,22519,40153,-264714,20533,-10960,-58533,40709,22430,73559,-39709,-106486,-274401,2123,-900,-34761,-75446,-6428,-156366,-17351,14471,-18235,41697,-7654,115234,61706,-86188,44040,20941,-14449,7970,29222,48246,-15104,-6367,24185,23019,23714,26849,51812,29781,-2072},
{0,-13546,0,55751,-31138,16981,109261,22600,40255,-264604,20305,-10869,-58586,40851,22446,73269,-39501,-106431,-274279,1372,-587,-34569,-75016,-6363,-156068,-17681,14636,-18154,41615,-7902,115306,61521,-86199,44040,20941,-14449,8070,29427,48011,-14773,-6051,24167,23019,23714,26849,51499,29962,-2200},
{0,-13577,0,55592,-31158,16691,109411,22701,40363,-264550,20069,-10759,-58648,41000,22461,72993,-39297,-106363,-274160,627,-274,-34385,-74589,-6308,-155776,-18008,14800,-18061,41512,-8159,115384,61329,-86213,44040,20941,-14449,8169,29628,47774,-14439,-5750,24146,23019,23714,26849,51183,30137,-2318},
{0,-13607,0,55432,-31177,16401,109561,22802,40470,-264495,19832,-10649,-58710,41148,22477,72716,-39093,-106295,-274039,-118,41,-34203,-74162,-6254,-155484,-18334,14966,-17969,41408,-8415,115463,61137,-86227,44040,20941,-14449,8269,29829,47537,-14104,-5449,24124,23019,23714,26849,50867,30313,-2436},
{0,-13637,0,55268,-31194,16104,109781,22925,40582,-264501,19587,-10519,-58782,41302,22492,72456,-38894,-106216,-273920,-852,354,-34030,-73742,-6209,-155199,-18654,15131,-17866,41285,-8677,115547,60941,-86245,44040,20941,-14449,8368,30024,47300,-13773,-5166,24100,23019,23714,26849,50549,30481,-2543},
{0,-13667,0,55104,-31210,15806,110001,23048,40693,-264506,19342,-10389,-58854,41456,22506,72195,-38696,-106136,-273800,-1585,668,-33858,-73322,-6166,-154913,-18973,15298,-17763,41161,-8939,115631,60744,-86262,44040,20941,-14449,8467,30218,47063,-13442,-4883,24075,23019,23714,26849,50232,30650,-2650},
{0,-13697,0,54938,-31223,15503,110296,23192,40805,-264578,19090,-10239,-58936,41616,22521,71953,-38505,-106047,-273684,-2301,977,-33697,-72913,-6133,-154638,-19282,15461,-17651,41020,-9203,115720,60544,-86283,44040,20941,-14449,8564,30404,46829,-13121,-4624,24048,23018,23714,26849,49916,30811,-2745},
{0,-13726,0,54771,-31235,15200,110590,23336,40918,-264648,18837,-10089,-59018,41775,22536,71710,-38315,-105957,-273566,-3017,1287,-33537,-72503,-6101,-154363,-19592,15625,-17540,40878,-9468,115809,60344,-86303,44040,20941,-14449,8661,30590,46595,-12800,-4365,24020,23019,23714,26849,49600,30972,-2840},
{0,-13755,0,54603,-31244,14894,110936,23495,41029,-264765,18577,-9925,-59107,41939,22550,71488,-38133,-105858,-273455,-3709,1590,-33389,-72106,-6081,-154100,-19889,15785,-17422,40721,-9732,115901,60143,-86325,44040,20941,-14449,8755,30766,46365,-12495,-4133,23992,23019,23714,26849,49288,31122,-2922},
{0,-13784,0,54434,-31252,14589,111282,23654,41140,-264882,18317,-9761,-59197,42104,22565,71265,-37952,-105760,-273341,-4402,1893,-33241,-71710,-6061,-153837,-20186,15946,-17304,40564,-9997,115994,59941,-86348,44040,20941,-14449,8850,30941,46136,-12191,-3901,23963,23019,23714,26849,48975,31274,-3004},
{0,-13812,0,54267,-31256,14284,111653,23818,41248,-265020,18051,-9591,-59289,42272,22577,71064,-37782,-105654,-273235,-5066,2187,-33107,-71330,-6052,-153589,-20468,16101,-17180,40394,-10259,116089,59740,-86372,44040,20941,-14449,8939,31104,45913,-11910,-3701,23935,23019,23714,26849,48668,31414,-3072},
{0,-13840,0,54099,-31260,13979,112023,23983,41355,-265157,17786,-9421,-59382,42440,22589,70863,-37612,-105549,-273128,-5730,2481,-32973,-70949,-6044,-153341,-20750,16256,-17057,40223,-10521,116184,59538,-86397,44040,20941,-14449,9029,31267,45690,-11628,-3501,23907,23018,23714,26849,48362,31554,-3140},
{0,-13866,0,53933,-31259,13677,112413,24152,41458,-265313,17516,-9246,-59477,42611,22600,70685,-37455,-105439,-273030,-6360,2763,-32854,-70588,-6047,-153111,-21014,16403,-16930,40042,-10779,116282,59339,-86424,44040,20941,-14449,9114,31415,45476,-11378,-3337,23880,23019,23714,26849,48063,31681,-3194},
{0,-13893,0,53767,-31257,13375,112803,24320,41560,-265469,17246,-9072,-59573,42782,22610,70506,-37298,-105329,-272930,-6991,3045,-32734,-70227,-6051,-152880,-21278,16551,-16803,39860,-11036,116379,59139,-86450,44040,20941,-14449,9199,31564,45262,-11127,-3174,23853,23019,23714,26849,47764,31809,-3248},
{0,-13918,0,53605,-31250,13079,113209,24491,41656,-265641,16974,-8895,-59670,42955,22617,70353,-37156,-105217,-272842,-7583,3311,-32629,-69888,-6067,-152671,-21523,16689,-16674,39669,-11286,116478,58943,-86479,44040,20941,-14449,9277,31695,45060,-10913,-3050,23829,23019,23714,26849,47476,31923,-3286},
{0,-13943,0,53442,-31243,12783,113614,24661,41752,-265813,16702,-8718,-59767,43129,22625,70199,-37014,-105105,-272753,-8175,3578,-32524,-69550,-6083,-152461,-21767,16828,-16545,39478,-11536,116577,58747,-86507,44040,20941,-14449,9355,31827,44857,-10699,-2927,23805,23019,23714,26849,47188,32036,-3324},
{0,-13967,0,53285,-31230,12496,114031,24832,41841,-265999,16430,-8539,-59865,43303,22630,70071,-36888,-104993,-272677,-8724,3826,-32435,-69236,-6110,-152274,-21988,16954,-16415,39280,-11777,116676,58555,-86537,44040,20941,-14449,9425,31940,44669,-10530,-2849,23785,23018,23714,26849,46912,32134,-3346},
{0,-13990,0,53128,-31216,12209,114447,25003,41929,-266185,16157,-8361,-59963,43478,22635,69942,-36762,-104880,-272600,-9274,4075,-32345,-68922,-6138,-152087,-22210,17081,-16286,39082,-12017,116775,58364,-86567,44040,20941,-14449,9495,32053,44480,-10360,-2770,23765,23019,23714,26849,46637,32232,-3368},
{0,-14011,0,52978,-31197,11934,114870,25171,42009,-266383,15885,-8184,-60061,43652,22636,69841,-36654,-104771,-272540,-9775,4302,-32272,-68635,-6178,-151926,-22406,17194,-16156,38880,-12245,116875,58180,-86599,44040,20941,-14449,9557,32145,44307,-10241,-2741,23750,23019,23714,26849,46376,32313,-3373},
{0,-14033,0,52828,-31177,11658,115293,25340,42088,-266581,15614,-8007,-60159,43827,22638,69740,-36546,-104661,-272478,-10276,4529,-32199,-68349,-6218,-151765,-22602,17308,-16028,38678,-12473,116974,57996,-86631,44040,20941,-14449,9618,32237,44134,-10122,-2711,23736,23019,23714,26849,46115,32394,-3378},
{0,-14052,0,52687,-31150,11397,115718,25505,42159,-266789,15346,-7832,-60255,44000,22635,69667,-36458,-104555,-272434,-10726,4732,-32142,-68094,-6270,-151632,-22770,17405,-15901,38473,-12687,117072,57820,-86664,44040,20941,-14449,9669,32307,43979,-10060,-2735,23727,23019,23714,26849,45872,32457,-3365},
{0,-14072,0,52546,-31123,11136,116142,25670,42229,-266996,15078,-7657,-60351,44173,22633,69594,-36370,-104450,-272389,-11175,4936,-32085,-67838,-6322,-151500,-22939,17503,-15774,38268,-12900,117171,57644,-86698,44040,20941,-14449,9721,32377,43824,-9999,-2759,23718,23019,23714,26849,45628,32519,-3353},
{0,-14089,0,52415,-31090,10892,116564,25829,42291,-267212,14816,-7486,-60445,44345,22626,69550,-36302,-104351,-272365,-11567,5112,-32046,-67616,-6386,-151398,-23077,17582,-15650,38063,-13097,117268,57479,-86733,44040,20941,-14449,9760,32422,43690,-9975,-2823,23714,23018,23714,26849,45404,32561,-3322},
{0,-14107,0,52284,-31056,10647,116985,25989,42351,-267427,14554,-7316,-60538,44516,22619,69506,-36235,-104253,-272340,-11959,5288,-32007,-67394,-6450,-151297,-23215,17662,-15527,37858,-13294,117365,57313,-86767,44040,20941,-14449,9800,32467,43555,-9951,-2888,23709,23019,23714,26849,45181,32603,-3291},
{0,-14122,0,52165,-31014,10423,117398,26141,42402,-267649,14301,-7151,-60628,44683,22607,69494,-36191,-104163,-272338,-12289,5433,-31986,-67208,-6526,-151230,-23320,17723,-15408,37656,-13473,117460,57160,-86804,44040,20941,-14449,9827,32486,43443,-9939,-2979,23705,23019,23714,26849,44979,32623,-3241},
{0,-14137,0,52047,-30973,10199,117811,26293,42452,-267870,14048,-6987,-60717,44851,22595,69481,-36146,-104074,-272335,-12619,5579,-31964,-67023,-6603,-151162,-23425,17783,-15289,37453,-13650,117556,57006,-86841,44040,20941,-14449,9854,32505,43330,-9927,-3070,23701,23019,23714,26849,44777,32643,-3191},
{0,-14149,0,51942,-30924,9997,118211,26435,42493,-268095,13806,-6830,-60800,45013,22577,69502,-36127,-103995,-272359,-12880,5690,-31963,-66878,-6692,-151142,-23486,17817,-15170,37243,-13806,117651,56867,-86882,44040,20941,-14449,9866,32492,43249,-9921,-3195,23697,23019,23714,26849,44606,32632,-3115},
{0,-14162,0,51837,-30875,9795,118610,26578,42534,-268320,13564,-6674,-60883,45176,22559,69524,-36108,-103917,-272383,-13141,5801,-31961,-66734,-6782,-151121,-23548,17850,-15052,37032,-13961,117747,56728,-86923,44040,20941,-14449,9877,32478,43167,-9914,-3320,23693,23019,23714,26849,44434,32621,-3039},
{0,-14172,0,51748,-30818,9619,118990,26709,42564,-268548,13338,-6526,-60958,45332,22535,69580,-36115,-103852,-272433,-13330,5875,-31981,-66632,-6885,-151156,-23559,17853,-14931,36809,-14090,117845,56606,-86970,44040,20941,-14449,9869,32429,43122,-9909,-3484,23688,23019,23714,26849,44299,32573,-2932},
{0,-14182,0,51659,-30761,9443,119371,26840,42594,-268775,13111,-6379,-61034,45488,22511,69635,-36123,-103786,-272484,-13518,5949,-32000,-66530,-6987,-151190,-23569,17855,-14810,36586,-14218,117942,56485,-87018,44040,20941,-14449,9862,32380,43078,-9903,-3648,23683,23019,23714,26849,44164,32525,-2824},
{0,-14190,0,51587,-30696,9294,119726,26959,42615,-269003,12903,-6243,-61099,45636,22479,69724,-36156,-103735,-272561,-13632,5987,-32040,-66471,-7103,-151276,-23531,17828,-14692,36359,-14320,118039,56381,-87070,44040,20941,-14449,9836,32294,43067,-9901,-3846,23677,23019,23714,26849,44064,32442,-2690},
{0,-14198,0,51515,-30630,9146,120082,27077,42636,-269230,12694,-6107,-61164,45784,22447,69813,-36188,-103684,-272637,-13747,6025,-32081,-66412,-7218,-151363,-23492,17800,-14573,36132,-14422,118136,56277,-87122,44040,20941,-14449,9811,32209,43056,-9899,-4044,23671,23019,23714,26849,43964,32359,-2555},
{0,-14202,0,51463,-30556,9028,120406,27181,42647,-269456,12508,-5984,-61217,45922,22408,69933,-36247,-103647,-272738,-13785,6025,-32143,-66395,-7347,-151497,-23406,17745,-14457,35902,-14499,118230,56193,-87178,44040,20941,-14449,9770,32093,43075,-9901,-4270,23664,23019,23714,26849,43898,32245,-2396},
{0,-14207,0,51410,-30482,8910,120731,27285,42658,-269682,12321,-5861,-61270,46060,22368,70054,-36305,-103611,-272838,-13824,6025,-32205,-66378,-7476,-151632,-23321,17689,-14340,35672,-14577,118324,56108,-87233,44040,20941,-14449,9729,31977,43094,-9903,-4497,23658,23019,23714,26849,43833,32130,-2238},
{0,-14209,0,51378,-30400,8826,121019,27373,42661,-269905,12161,-5753,-61308,46186,22319,70206,-36389,-103590,-272961,-13784,5988,-32291,-66404,-7617,-151812,-23189,17607,-14224,35436,-14634,118414,56045,-87290,44040,20941,-14449,9676,31838,43138,-9910,-4748,23650,23019,23714,26849,43801,31987,-2059},
{0,-14211,0,51346,-30317,8742,121307,27460,42663,-270127,12000,-5645,-61347,46313,22270,70357,-36473,-103569,-273084,-13744,5951,-32376,-66430,-7759,-151991,-23058,17526,-14107,35200,-14691,118503,55981,-87348,44040,20941,-14449,9623,31699,43182,-9917,-5000,23643,23018,23714,26849,43769,31843,-1880},
{0,-14210,0,51335,-30226,8691,121555,27531,42658,-270346,11869,-5552,-61369,46426,22211,70539,-36581,-103564,-273226,-13625,5877,-32485,-66499,-7914,-152212,-22883,17420,-13992,34961,-14730,118586,55939,-87406,44040,20941,-14449,9560,31539,43248,-9930,-5274,23634,23019,23714,26849,43770,31673,-1684},
{0,-14209,0,51323,-30135,8641,121803,27601,42652,-270564,11738,-5460,-61390,46539,22152,70722,-36690,-103559,-273369,-13506,5803,-32595,-66568,-8069,-152432,-22707,17314,-13877,34722,-14768,118669,55897,-87464,44040,20941,-14449,9496,31380,43313,-9943,-5547,23626,23019,23714,26849,43771,31504,-1488},
{0,-14206,0,51330,-30037,8623,122014,27656,42639,-270778,11637,-5383,-61396,46637,22085,70933,-36823,-103567,-273529,-13312,5695,-32728,-66678,-8236,-152690,-22491,17187,-13762,34481,-14788,118746,55879,-87524,44040,20941,-14449,9423,31201,43399,-9961,-5840,23617,23019,23714,26849,43803,31311,-1279},
{0,-14203,0,51337,-29939,8605,122225,27711,42626,-270991,11535,-5307,-61402,46736,22017,71145,-36955,-103575,-273689,-13117,5588,-32861,-66788,-8403,-152947,-22275,17061,-13648,34240,-14808,118822,55861,-87583,44040,20941,-14449,9351,31023,43485,-9980,-6134,23608,23019,23714,26849,43836,31119,-1069},
{0,-14198,0,51360,-29836,8616,122400,27751,42607,-271200,11462,-5245,-61394,46821,21943,71385,-37109,-103593,-273865,-12851,5449,-33015,-66937,-8579,-153235,-22023,16916,-13536,34000,-14810,118890,55868,-87643,44040,20941,-14449,9270,30828,43588,-10004,-6443,23597,23019,23714,26849,43899,30906,-849},
{0,-14192,0,51384,-29733,8627,122576,27791,42588,-271408,11389,-5183,-61385,46905,21868,71624,-37263,-103612,-274040,-12586,5311,-33170,-67086,-8756,-153523,-21771,16773,-13425,33759,-14813,118958,55876,-87703,44040,20941,-14449,9190,30633,43691,-10029,-6753,23587,23019,23714,26849,43963,30694,-629},
{0,-14185,0,51423,-29626,8666,122718,27818,42564,-271611,11344,-5135,-61364,46975,21788,71889,-37436,-103639,-274227,-12253,5144,-33345,-67271,-8940,-153838,-21487,16615,-13316,33523,-14799,119015,55911,-87761,44040,20941,-14449,9102,30424,43808,-10060,-7075,23576,23019,23714,26849,44056,30464,-402},
{0,-14177,0,51463,-29520,8706,122859,27845,42540,-271815,11300,-5087,-61343,47045,21707,72154,-37610,-103666,-274414,-11919,4979,-33521,-67457,-9125,-154153,-21202,16457,-13208,33286,-14785,119073,55945,-87820,44040,20941,-14449,9015,30215,43926,-10091,-7397,23564,23018,23714,26849,44149,30235,-174},
{0,-14167,0,51517,-29411,8771,122968,27859,42512,-272011,11283,-5053,-61310,47100,21622,72442,-37800,-103700,-274610,-11522,4787,-33715,-67677,-9317,-154489,-20890,16289,-13104,33056,-14756,119119,56008,-87877,44040,20941,-14449,8922,29993,44056,-10129,-7729,23552,23018,23714,26849,44270,29992,57},
{0,-14158,0,51571,-29302,8836,123077,27872,42483,-272208,11266,-5019,-61276,47155,21537,72731,-37991,-103732,-274806,-11124,4597,-33911,-67896,-9509,-154824,-20577,16121,-13000,32826,-14726,119165,56071,-87934,44040,20941,-14449,8830,29772,44185,-10167,-8060,23540,23019,23714,26849,44392,29749,289},
{0,-14146,0,51639,-29193,8926,123155,27874,42451,-272398,11277,-4999,-61232,47195,21448,73041,-38198,-103770,-275009,-10665,4383,-34124,-68149,-9706,-155177,-20241,15945,-12902,32605,-14682,119199,56160,-87988,44040,20941,-14449,8733,29541,44325,-10213,-8397,23527,23019,23714,26849,44541,29496,522},
{0,-14134,0,51706,-29083,9016,123233,27876,42419,-272588,11288,-4978,-61188,47234,21360,73352,-38404,-103806,-275211,-10206,4170,-34338,-68401,-9905,-155529,-19905,15770,-12804,32385,-14638,119234,56248,-88042,44040,20941,-14449,8636,29310,44465,-10260,-8735,23513,23019,23714,26849,44691,29243,756},
{0,-14121,0,51787,-28974,9130,123281,27867,42383,-272770,11327,-4970,-61134,47258,21269,73682,-38624,-103844,-275417,-9689,3937,-34569,-68684,-10106,-155893,-19549,15589,-12713,32176,-14580,119257,56360,-88094,44040,20941,-14449,8536,29071,44613,-10314,-9074,23499,23019,23714,26849,44866,28982,987},
{0,-14108,0,51867,-28865,9243,123328,27857,42347,-272952,11365,-4962,-61080,47282,21179,74012,-38844,-103882,-275622,-9172,3705,-34801,-68967,-10309,-156257,-19193,15410,-12621,31968,-14522,119280,56472,-88145,44040,20941,-14449,8437,28832,44760,-10369,-9414,23485,23019,23714,26849,45042,28722,1219},
{0,-14092,0,51959,-28758,9377,123348,27837,42309,-273126,11430,-4967,-61018,47289,21087,74360,-39075,-103920,-275828,-8602,3455,-35048,-69278,-10513,-156628,-18822,15227,-12538,31775,-14450,119292,56605,-88193,44040,20941,-14449,8335,28588,44913,-10433,-9752,23470,23019,23714,26849,45242,28458,1447},
{0,-14077,0,52050,-28651,9512,123367,27817,42270,-273300,11495,-4971,-60956,47296,20996,74708,-39306,-103956,-276033,-8031,3206,-35296,-69588,-10719,-156999,-18450,15046,-12455,31582,-14379,119304,56738,-88240,44040,20941,-14449,8234,28344,45066,-10497,-10090,23455,23019,23714,26849,45442,28195,1675},
{0,-14060,0,52152,-28547,9666,123360,27787,42229,-273464,11586,-4987,-60886,47287,20905,75072,-39545,-103991,-276237,-7411,2942,-35557,-69925,-10925,-157373,-18068,14864,-12381,31408,-14295,119305,56890,-88283,44040,20941,-14449,8132,28097,45224,-10570,-10423,23439,23019,23714,26849,45679,27930,1892},
{0,-14043,0,52254,-28443,9820,123352,27757,42187,-273629,11677,-5004,-60817,47278,20813,75435,-39785,-104025,-276439,-6791,2679,-35820,-70261,-11132,-157746,-17686,14683,-12307,31233,-14211,119306,57042,-88326,44040,20941,-14449,8030,27850,45381,-10643,-10756,23423,23019,23714,26849,45917,27667,2110},
{0,-14024,0,52366,-28343,9993,123319,27718,42144,-273783,11794,-5032,-60742,47252,20724,75810,-40031,-104055,-276637,-6126,2403,-36094,-70620,-11338,-158118,-17297,14504,-12244,31080,-14114,119295,57210,-88364,44040,20941,-14449,7928,27603,45542,-10727,-11081,23407,23019,23714,26849,46199,27406,2313},
{0,-14005,0,52477,-28244,10166,123285,27679,42100,-273937,11911,-5060,-60666,47225,20634,76186,-40277,-104085,-276833,-5461,2129,-36369,-70979,-11545,-158490,-16908,14327,-12181,30927,-14018,119285,57378,-88402,44040,20941,-14449,7827,27356,45702,-10811,-11406,23391,23019,23714,26849,46481,27146,2515},
{0,-13985,0,52596,-28150,10355,123229,27631,42054,-274081,12052,-5099,-60586,47182,20548,76570,-40527,-104109,-277024,-4758,1844,-36653,-71359,-11748,-158855,-16517,14153,-12129,30798,-13909,119263,57560,-88434,44040,20941,-14449,7726,27111,45863,-10905,-11720,23375,23019,23714,26849,46801,26892,2702},
{0,-13965,0,52715,-28057,10545,123172,27583,42008,-274224,12194,-5138,-60506,47138,20461,76955,-40776,-104133,-277211,-4053,1561,-36939,-71738,-11953,-159221,-16126,13980,-12078,30669,-13801,119241,57743,-88466,44040,20941,-14449,7627,26866,46025,-10999,-12033,23359,23019,23714,26849,47121,26640,2889},
{0,-13943,0,52843,-27985,10757,123109,27530,41956,-274356,12368,-5191,-60442,47063,20392,77336,-41022,-104152,-277388,-3308,1267,-37219,-72145,-12132,-159576,-15738,13812,-12043,30571,-13665,119209,57937,-88492,44040,20941,-14449,7528,26633,46201,-11105,-12330,23343,23018,23714,26849,47471,26397,3058},
{0,-13921,0,52972,-27912,10969,123046,27477,41904,-274488,12543,-5245,-60379,46987,20322,77717,-41268,-104170,-277563,-2562,974,-37500,-72552,-12313,-159931,-15350,13646,-12008,30472,-13529,119177,58131,-88518,44040,20941,-14449,7431,26399,46376,-11211,-12627,23327,23018,23714,26849,47822,26155,3229},
{0,-13898,0,53109,-27874,11207,122964,27415,41848,-274605,12762,-5318,-60322,46869,20281,78082,-41502,-104186,-277723,-1777,670,-37763,-72992,-12448,-160271,-14969,13487,-11992,30409,-13353,119135,58336,-88538,44040,20941,-14449,7335,26185,46577,-11330,-12904,23312,23019,23714,26849,48197,25926,3380},
{0,-13875,0,53247,-27835,11445,122881,27353,41792,-274722,12982,-5391,-60266,46751,20240,78447,-41737,-104201,-277879,-991,368,-38027,-73432,-12586,-160611,-14588,13329,-11977,30347,-13178,119093,58540,-88559,44040,20941,-14449,7240,25970,46778,-11448,-13182,23296,23019,23714,26849,48572,25698,3533},
{0,-13851,0,53392,-27827,11707,122789,27285,41731,-274824,13241,-5482,-60225,46594,20224,78793,-41959,-104213,-278019,-175,59,-38271,-73899,-12681,-160933,-14220,13179,-11982,30322,-12968,119041,58751,-88572,44040,20941,-14449,7149,25774,46998,-11580,-13435,23282,23019,23714,26849,48963,25486,3665},
{0,-13827,0,53538,-27818,11968,122697,27217,41670,-274926,13499,-5572,-60184,46437,20208,79140,-42181,-104224,-278157,642,-249,-38517,-74365,-12779,-161254,-13851,13030,-11987,30297,-12758,118988,58963,-88585,44040,20941,-14449,7057,25579,47218,-11711,-13689,23268,23019,23714,26849,49355,25276,3799},
{0,-13803,0,53689,-27837,12249,122594,27143,41604,-275013,13792,-5677,-60155,46245,20214,79464,-42388,-104233,-278275,1477,-561,-38743,-74850,-12837,-161554,-13500,12891,-12013,30312,-12519,118925,59179,-88589,44040,20941,-14449,6971,25403,47453,-11856,-13917,23256,23019,23714,26849,49756,25084,3911},
{0,-13778,0,53841,-27855,12530,122492,27070,41538,-275099,14085,-5783,-60127,46054,20220,79789,-42596,-104242,-278392,2312,-872,-38970,-75336,-12898,-161852,-13148,12752,-12039,30327,-12279,118861,59396,-88594,44040,20941,-14449,6884,25227,47687,-12001,-14144,23243,23019,23714,26849,50158,24894,4023},
{0,-13752,0,53997,-27897,12826,122379,26991,41469,-275170,14407,-5901,-60109,45832,20244,80089,-42787,-104249,-278488,3155,-1183,-39175,-75832,-12922,-162125,-12819,12625,-12087,30384,-12016,118786,59615,-88589,44040,20941,-14449,6803,25073,47931,-12159,-14342,23233,23019,23714,26849,50562,24726,4113},
{0,-13726,0,54153,-27939,13123,122266,26912,41400,-275240,14729,-6020,-60091,45611,20269,80388,-42978,-104256,-278582,3998,-1493,-39381,-76329,-12947,-162397,-12489,12498,-12135,30440,-11752,118711,59833,-88584,44040,20941,-14449,6723,24918,48175,-12317,-14540,23223,23019,23714,26849,50966,24559,4204},
{0,-13700,0,54312,-28002,13432,122143,26829,41328,-275293,15075,-6150,-60082,45364,20309,80659,-43151,-104263,-278656,4835,-1799,-39564,-76828,-12939,-162639,-12187,12382,-12206,30541,-11470,118623,60052,-88568,44040,20941,-14449,6648,24785,48424,-12488,-14705,23215,23019,23714,26849,51367,24417,4270},
{0,-13674,0,54471,-28064,13741,122020,26745,41255,-275345,15421,-6281,-60073,45117,20350,80930,-43325,-104270,-278727,5673,-2105,-39748,-77328,-12931,-162880,-11884,12268,-12277,30641,-11187,118536,60271,-88553,44040,20941,-14449,6574,24652,48672,-12660,-14871,23208,23018,23714,26849,51767,24276,4336},
{0,-13648,0,54631,-28144,14058,121885,26656,41180,-275380,15785,-6421,-60070,44850,20403,81168,-43479,-104279,-278778,6492,-2403,-39906,-77822,-12892,-163088,-11613,12165,-12372,30787,-10889,118436,60487,-88526,44040,20941,-14449,6507,24543,48919,-12846,-15000,23204,23018,23714,26849,52157,24164,4376},
{0,-13621,0,54792,-28224,14376,121751,26568,41105,-275415,16150,-6561,-60068,44583,20456,81407,-43633,-104288,-278826,7312,-2701,-40066,-78316,-12854,-163295,-11342,12064,-12468,30932,-10592,118337,60703,-88500,44040,20941,-14449,6441,24434,49167,-13031,-15130,23200,23018,23714,26849,52547,24051,4417},
{0,-13595,0,54952,-28318,14698,121605,26476,41028,-275432,16527,-6709,-60070,44300,20520,81609,-43767,-104300,-278853,8101,-2988,-40198,-78797,-12786,-163463,-11108,11975,-12588,31125,-10285,118225,60915,-88461,44040,20941,-14449,6383,24349,49408,-13230,-15222,23201,23019,23714,26849,52919,23970,4429},
{0,-13568,0,55112,-28411,15021,121460,26383,40951,-275448,16904,-6857,-60073,44018,20584,81811,-43900,-104313,-278878,8890,-3276,-40331,-79277,-12719,-163632,-10874,11887,-12709,31318,-9978,118113,61126,-88423,44040,20941,-14449,6325,24265,49650,-13430,-15313,23201,23019,23714,26849,53291,23889,4441},
{0,-13542,0,55271,-28516,15344,121302,26287,40873,-275446,17289,-7011,-60078,43725,20655,81974,-44012,-104332,-278882,9635,-3548,-40435,-79734,-12624,-163759,-10682,11814,-12855,31560,-9667,117989,61330,-88373,44040,20941,-14449,6276,24207,49881,-13643,-15364,23207,23019,23714,26849,53639,23842,4423},
{0,-13515,0,55430,-28621,15668,121145,26191,40794,-275444,17673,-7165,-60083,43432,20727,82136,-44124,-104351,-278885,10379,-3820,-40539,-80192,-12529,-163885,-10489,11740,-13002,31801,-9355,117866,61534,-88322,44040,20941,-14449,6227,24148,50111,-13856,-15414,23212,23019,23714,26849,53987,23795,4405},
{0,-13489,0,55585,-28734,15988,120976,26091,40715,-275422,18058,-7323,-60089,43135,20804,82256,-44213,-104378,-278867,11067,-4074,-40612,-80618,-12409,-163965,-10343,11683,-13176,32093,-9044,117730,61729,-88260,44040,20941,-14449,6189,24119,50326,-14084,-15420,23223,23018,23714,26849,54304,23784,4354},
{0,-13463,0,55741,-28847,16309,120807,25991,40636,-275401,18443,-7481,-60096,42838,20881,82376,-44302,-104405,-278848,11755,-4327,-40685,-81044,-12289,-164045,-10197,11625,-13351,32385,-8732,117595,61924,-88197,44040,20941,-14449,6151,24089,50540,-14311,-15426,23235,23019,23714,26849,54620,23773,4304},
{0,-13438,0,55891,-28965,16624,120626,25888,40556,-275360,18823,-7641,-60101,42541,20961,82450,-44367,-104442,-278809,12373,-4559,-40726,-81430,-12145,-164086,-10092,11580,-13545,32714,-8424,117452,62108,-88126,44040,20941,-14449,6122,24084,50738,-14547,-15396,23251,23019,23714,26849,54907,23792,4226},
{0,-13412,0,56042,-29082,16938,120446,25786,40477,-275319,19203,-7802,-60107,42244,21042,82524,-44433,-104480,-278769,12992,-4790,-40767,-81816,-12000,-164127,-9987,11536,-13741,33043,-8116,117309,62293,-88054,44040,20941,-14449,6093,24078,50936,-14783,-15366,23268,23019,23714,26849,55194,23811,4148},
{0,-13388,0,56186,-29202,17242,120253,25680,40398,-275259,19571,-7963,-60111,41953,21124,82550,-44474,-104529,-278711,13529,-4996,-40774,-82154,-11835,-164138,-9913,11502,-13948,33393,-7816,117164,62466,-87978,44040,20941,-14449,6071,24092,51119,-15019,-15310,23288,23018,23714,26849,55454,23851,4052},
{0,-13364,0,56330,-29322,17546,120060,25575,40319,-275198,19940,-8124,-60114,41663,21205,82577,-44515,-104579,-278651,14066,-5201,-40781,-82492,-11669,-164150,-9840,11468,-14156,33741,-7514,117019,62639,-87901,44040,20941,-14449,6050,24106,51302,-15255,-15255,23309,23019,23714,26849,55714,23890,3956},
{0,-13341,0,56466,-29442,17835,119856,25468,40242,-275119,20291,-8283,-60113,41383,21287,82553,-44531,-104641,-278575,14510,-5377,-40754,-82773,-11484,-164134,-9798,11444,-14372,34105,-7226,116874,62799,-87822,44040,20941,-14449,6035,24137,51467,-15489,-15176,23333,23019,23714,26849,55945,23949,3843},
{0,-13318,0,56602,-29561,18124,119651,25361,40164,-275039,20642,-8442,-60113,41104,21368,82529,-44547,-104704,-278497,14954,-5552,-40726,-83054,-11299,-164118,-9755,11420,-14590,34468,-6937,116729,62959,-87743,44040,20941,-14449,6021,24168,51633,-15723,-15098,23357,23018,23714,26849,56175,24007,3731},
{0,-13296,0,56728,-29676,18395,119404,25244,40089,-274918,20971,-8603,-60096,40842,21447,82459,-44540,-104778,-278405,15301,-5696,-40666,-83276,-11099,-164075,-9744,11407,-14812,34840,-6665,116586,63104,-87661,44040,20941,-14449,6014,24216,51777,-15952,-14998,23384,23019,23714,26849,56373,24083,3603},
{0,-13275,0,56855,-29792,18666,119156,25127,40013,-274796,21299,-8765,-60080,40579,21525,82388,-44532,-104853,-278312,15648,-5840,-40606,-83497,-10899,-164032,-9732,11393,-15035,35212,-6392,116443,63250,-87580,44040,20941,-14449,6006,24263,51922,-16181,-14898,23412,23019,23714,26849,56571,24158,3476},
{0,-13255,0,56970,-29901,18914,118844,24994,39939,-274616,21600,-8931,-60039,40340,21598,82278,-44504,-104938,-278209,15900,-5952,-40519,-83659,-10692,-163963,-9751,11390,-15259,35588,-6142,116305,63379,-87498,44040,20941,-14449,6006,24325,52042,-16402,-14779,23442,23019,23714,26849,56734,24250,3336},
{0,-13236,0,57085,-30010,19162,118532,24861,39866,-274435,21900,-9098,-59999,40101,21671,82167,-44476,-105022,-278106,16152,-6063,-40432,-83820,-10484,-163894,-9770,11387,-15485,35964,-5891,116166,63508,-87416,44040,20941,-14449,6006,24386,52162,-16624,-14660,23473,23019,23714,26849,56897,24341,3196},
{0,-13218,0,57187,-30110,19384,118168,24716,39794,-274205,22164,-9265,-59939,39891,21738,82023,-44430,-105114,-277995,16310,-6142,-40323,-83922,-10276,-163801,-9818,11394,-15708,36339,-5668,116035,63619,-87336,44040,20941,-14449,6013,24460,52255,-16836,-14524,23506,23019,23714,26849,57021,24446,3046},
{0,-13201,0,57289,-30210,19605,117803,24571,39723,-273974,22427,-9432,-59878,39681,21806,81879,-44383,-105205,-277885,16468,-6222,-40215,-84023,-10067,-163708,-9866,11402,-15933,36713,-5443,115903,63730,-87255,44040,20941,-14449,6020,24535,52347,-17047,-14388,23539,23018,23714,26849,57145,24552,2895},
{0,-13186,0,57376,-30298,19795,117390,24416,39655,-273699,22650,-9596,-59793,39505,21866,81706,-44320,-105301,-277770,16531,-6267,-40089,-84064,-9864,-163591,-9943,11420,-16151,37081,-5252,115779,63821,-87176,44040,20941,-14449,6034,24619,52409,-17247,-14236,23575,23019,23714,26849,57228,24670,2736},
{0,-13171,0,57464,-30386,19986,116976,24261,39587,-273424,22872,-9761,-59708,39329,21926,81533,-44257,-105397,-277655,16594,-6312,-39963,-84105,-9661,-163475,-10021,11438,-16371,37448,-5060,115656,63912,-87097,44040,20941,-14449,6048,24704,52471,-17446,-14085,23610,23019,23714,26849,57311,24789,2577},
{0,-13159,0,57535,-30460,20141,116545,24106,39525,-273117,23046,-9916,-59620,39190,21976,81337,-44180,-105494,-277538,16565,-6323,-39826,-84085,-9470,-163336,-10127,11468,-16580,37805,-4906,115543,63982,-87022,44040,20941,-14449,6069,24796,52499,-17631,-13919,23647,23019,23714,26849,57349,24919,2413},
{0,-13147,0,57605,-30533,20297,116114,23951,39462,-272809,23219,-10072,-59532,39052,22027,81141,-44103,-105590,-277421,16535,-6334,-39689,-84065,-9280,-163196,-10232,11497,-16791,38161,-4751,115429,64051,-86946,44040,20941,-14449,6090,24889,52527,-17816,-13754,23684,23019,23714,26849,57388,25049,2248},
{0,-13138,0,57658,-30589,20413,115668,23798,39407,-272475,23343,-10216,-59436,38955,22066,80928,-44014,-105685,-277305,16414,-6310,-39546,-83984,-9110,-163036,-10366,11538,-16987,38500,-4640,115329,64097,-86875,44040,20941,-14449,6118,24988,52518,-17983,-13576,23722,23019,23714,26849,57379,25190,2080},
{0,-13129,0,57711,-30645,20529,115221,23645,39351,-272141,23465,-10360,-59339,38858,22105,80716,-43924,-105779,-277189,16293,-6286,-39403,-83903,-8940,-162875,-10500,11578,-17184,38840,-4529,115228,64143,-86804,44040,20941,-14449,6145,25086,52508,-18151,-13399,23761,23018,23714,26849,57370,25330,1911},
{0,-13124,0,57744,-30681,20601,114770,23498,39307,-271788,23535,-10488,-59236,38805,22129,80491,-43824,-105869,-277075,16082,-6226,-39259,-83761,-8797,-162695,-10661,11630,-17364,39158,-4466,115141,64164,-86738,44040,20941,-14449,6180,25189,52458,-18299,-13211,23800,23019,23714,26849,57311,25481,1742},
{0,-13118,0,57777,-30716,20674,114318,23351,39262,-271436,23604,-10616,-59133,38752,22153,80266,-43724,-105958,-276962,15870,-6166,-39116,-83620,-8654,-162514,-10821,11683,-17544,39476,-4403,115054,64185,-86671,44040,20941,-14449,6215,25291,52408,-18447,-13023,23838,23018,23714,26849,57251,25631,1572},
{0,-13116,0,57788,-30729,20699,113872,23214,39231,-271073,23619,-10725,-59026,38746,22160,80035,-43616,-106038,-276853,15569,-6069,-38976,-83418,-8545,-162313,-11009,11747,-17702,39768,-4395,114982,64179,-86611,44040,20941,-14449,6256,25394,52314,-18573,-12826,23877,23019,23714,26849,57138,25790,1405},
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
}
local clip={Duration=2.0,Loop=true,Source="Quaternius original GLB",Role="NinjaJump_Idle_Loop",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/clips/NinjaJump_Land.luau
addModule(modules,{"world","clips","NinjaJump_Land"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
{0,-26527,0,49904,-30477,17506,101604,23417,45588,-259651,23011,-13807,-32332,44997,14425,87938,-44555,-98155,-266116,-91,1101,-25107,-65758,1628,-157202,-9542,10447,-13070,27313,-14675,116164,66516,-88731,44049,20869,-14455,8565,23122,51413,-16242,-11500,23826,23019,23714,26849,55773,23858,2569},
{0,-39939,0,42030,-29973,14324,89784,23021,51973,-248635,22074,-16687,-4571,49127,4896,96168,-45011,-90094,-254306,-14565,9851,-14866,-47551,7864,-152253,-7921,9097,-9422,14132,-23921,117506,68836,-90989,44057,20798,-14460,10812,20749,50583,-13786,-10374,23709,23019,23714,26849,54574,21719,3815},
{0,-65704,0,26755,-28555,8366,78869,23191,60782,-225530,23749,-29785,32972,44325,-11827,111303,-41192,-70308,-227949,-12809,15224,4369,-35675,14499,-141408,-5054,6268,-5399,-9676,-41075,117714,73313,-93389,44087,20540,-14480,14829,16499,49858,-7863,-7194,23380,23019,23714,26849,51809,18124,6442},
{0,-91469,0,11672,-26291,2731,67988,22427,69551,-202389,22452,-42934,68075,34530,-25095,125054,-34820,-51745,-201795,-9730,19939,22061,-22889,18454,-130433,-2349,3481,-3946,-34067,-57406,118081,77785,-95906,44117,20283,-14500,18808,12247,49035,-1940,-4040,22864,23019,23714,26849,49213,14346,8800},
{0,-115198,0,506,-24762,-917,68852,24643,74832,-197221,23233,-50061,86906,27677,-29532,139521,-32598,-41855,-193508,-5870,14391,32809,-18913,22202,-120316,-1049,1747,-4032,-49408,-66377,113723,81267,-94307,44175,19776,-14539,21138,10732,48139,5754,60,21972,23018,23714,26849,46180,12809,10081},
{0,-138927,0,-10550,-22851,-4353,69598,26900,80124,-192002,23652,-57231,105083,20165,-32508,153560,-29073,-32490,-185032,-2485,8552,43324,-14569,25473,-110162,134,17,-5281,-64745,-75935,109114,84695,-92419,44233,19270,-14577,23447,9217,47221,13491,4080,20767,23019,23714,26849,43183,11207,11295},
{0,-149532,0,-13565,-22714,-5034,79332,29793,76314,-201652,24665,-47991,109254,13116,-34309,164531,-30805,-30894,-192896,-2095,5829,43564,-14690,27900,-103246,135,8,-4267,-69405,-72349,100540,84199,-86236,44323,18450,-14637,23499,9163,44700,20415,9509,18908,23018,23714,26849,40387,11660,10812},
{0,-160136,0,-16578,-22556,-5710,89259,32312,72193,-211370,24806,-38680,113268,6002,-35801,175589,-32358,-29100,-200745,-1492,3145,43807,-14805,30329,-96329,135,-2,-3021,-74032,-68565,92092,83355,-80185,44413,17631,-14697,23550,9106,42180,27484,14796,16663,23019,23714,26849,37592,12111,10326},
{0,-164710,0,-18954,-22417,-6240,97064,32445,65867,-216463,22101,-31658,114911,-800,-36479,181873,-32883,-27778,-203935,-703,1407,43433,-14738,32777,-91008,135,-9,-1635,-77919,-64803,89466,81505,-77784,44538,16434,-14780,23829,9794,39495,33625,17669,14905,23019,23714,26849,35449,12447,9917},
{0,-169283,0,-21328,-22266,-6766,104858,32110,59552,-221320,19061,-24828,116511,-7612,-37047,188175,-33327,-26422,-207111,142,-304,43058,-14681,35226,-85688,134,-16,-9,-81764,-60824,86954,79614,-75500,44661,15238,-14861,24128,10472,36806,39850,20429,12961,23019,23714,26849,33307,12780,9506},
{0,-170033,0,-23153,-22142,-7168,106805,32919,59659,-222114,19335,-24769,116634,-7677,-37522,190902,-33462,-25803,-207701,515,-967,42856,-14437,37211,-83559,134,-19,1282,-85704,-58811,87968,78057,-75536,44817,13602,-14966,25114,13041,34374,43766,18963,13376,23019,23714,26849,32454,12931,9315},
{0,-170783,0,-24977,-22011,-7567,108756,33730,59749,-222908,19608,-24708,116756,-7742,-37998,193632,-33582,-25179,-208288,891,-1629,42650,-14198,39195,-81431,133,-22,2756,-89625,-56621,88965,76498,-75550,44970,11965,-15069,26168,15582,31906,47678,17514,13848,23018,23714,26849,31601,13082,9124},
{0,-168996,0,-26327,-21909,-7861,109533,34008,59707,-221702,19821,-25574,115955,-7565,-37754,193759,-33678,-25219,-207261,697,-1309,42691,-13836,40313,-82041,133,-21,3611,-93704,-56762,92610,75170,-77327,45147,9859,-15190,27933,19928,30136,50320,12966,16302,23019,23714,26849,32057,13112,9108},
{0,-167208,0,-27676,-21803,-8154,110310,34287,59662,-220493,20023,-26442,115153,-7391,-37509,193887,-33775,-25259,-206235,505,-988,42728,-13473,41430,-82652,133,-20,4519,-97783,-56841,96177,73797,-79015,45321,7753,-15307,29796,24239,28265,53060,8485,18864,23019,23714,26849,32513,13142,9092},
{0,-163703,0,-28614,-21727,-8356,110156,34139,59516,-217886,20066,-27947,113770,-7092,-36774,192208,-33818,-25732,-204085,-62,103,42865,-13067,41330,-84261,134,-18,4956,-101395,-57969,100421,71962,-81037,45495,5282,-15431,31863,29157,27260,56294,3497,21905,23019,23714,26849,33678,13157,9105},
{0,-160199,0,-29551,-21650,-8558,110002,33992,59371,-215279,20070,-29452,112385,-6803,-36034,190529,-33853,-26206,-201929,-605,1207,43003,-12661,41229,-85870,134,-16,5356,-105008,-59126,104548,70066,-82922,45666,2811,-15550,34019,34051,26123,59676,-1389,25104,23018,23714,26849,34843,13172,9118},
{0,-155537,0,-30134,-21601,-8683,109096,33490,59117,-211681,19764,-31337,110616,-6454,-35037,187647,-33711,-26873,-198906,-1203,2710,43073,-12288,40307,-88144,134,-13,5248,-108073,-61131,108884,67776,-84883,45816,115,-15664,36097,39123,25970,63370,-6356,28617,23019,23714,26849,36427,13174,9156},
{0,-150875,0,-30716,-21551,-8808,108191,32989,58860,-208093,19392,-33208,108843,-6123,-34035,184767,-33551,-27534,-195875,-1755,4231,43148,-11916,39386,-90419,135,-10,5013,-111133,-63256,113083,65424,-86681,45963,-2581,-15774,38233,44191,25688,67253,-11188,32327,23018,23714,26849,38010,13177,9195},
{0,-145456,0,-30991,-21527,-8867,106698,32208,58493,-203838,18610,-35229,106783,-5731,-32977,181103,-33153,-28225,-192138,-2119,5808,43029,-11625,38351,-93027,135,-6,4380,-113592,-65852,117100,62811,-88336,46076,-5364,-15872,39994,48965,26326,71180,-15692,36094,23019,23714,26849,39719,13170,9254},
{0,-140036,0,-31266,-21503,-8925,105206,31432,58115,-199607,17745,-37212,104720,-5361,-31911,177448,-32732,-28898,-188395,-2424,7396,42914,-11333,37317,-95634,135,-3,3568,-116039,-68623,120989,60147,-89833,46186,-8146,-15966,41771,53751,26874,75309,-20042,40069,23018,23714,26849,41429,13164,9313},
{0,-134155,0,-31276,-21502,-8927,103230,30428,57626,-194918,16442,-39191,102443,-4938,-30899,173322,-32071,-29495,-184113,-2461,8883,42534,-11128,36262,-98242,135,1,2665,-117877,-71280,124381,57411,-91011,46256,-10876,-16044,42970,57793,28064,79099,-23712,43728,23018,23714,26849,42971,13150,9389},
{0,-128274,0,-31286,-21501,-8930,101255,29434,57118,-190266,15050,-41102,100162,-4538,-29878,169209,-31387,-30061,-179831,-2434,10369,42157,-10920,35209,-100850,135,4,1599,-119701,-74100,127678,54643,-92060,46323,-13605,-16120,44145,61850,29217,83061,-27240,47563,23018,23714,26849,44513,13136,9465},
{0,-122157,0,-31069,-21520,-8883,98885,28265,56506,-185311,13246,-42901,97712,-4083,-28969,164798,-30504,-30512,-175114,-2134,11675,41484,-10793,34189,-103125,135,7,929,-120954,-76040,130224,52025,-92649,46352,-16144,-16179,44716,64780,30519,86187,-29816,50596,23019,23714,26849,45594,13118,9554},
{0,-116041,0,-30851,-21539,-8837,96516,27110,55867,-180400,11356,-44604,95259,-3651,-28049,160404,-29603,-30921,-170403,-1772,12965,40813,-10659,33171,-105399,135,10,172,-122200,-78068,132715,49395,-93154,46379,-18683,-16238,45252,67720,31822,89420,-32298,53736,23019,23714,26849,46676,13100,9643},
{0,-109866,0,-30439,-21575,-8749,93835,25834,55139,-175310,9116,-46125,92671,-3157,-27271,155824,-28556,-31208,-165340,-1169,14038,39843,-10595,32215,-107008,134,13,378,-122932,-78379,134231,47150,-93072,46375,-20894,-16280,45315,69215,32652,91253,-33627,55519,23019,23714,26849,47003,13080,9740},
{0,-103691,0,-30027,-21610,-8660,91154,24578,54379,-170264,6803,-47528,90081,-2684,-26481,151260,-27497,-31443,-160285,-512,15080,38874,-10523,31260,-108617,134,15,585,-123662,-78691,135732,44907,-92952,46371,-23105,-16323,45363,70714,33486,93120,-34926,57337,23019,23714,26849,47331,13060,9837},
{0,-97600,0,-29450,-21658,-8536,88201,23235,53541,-165086,4194,-48717,87372,-2139,-25847,146596,-26346,-31566,-154973,335,15895,37631,-10508,30378,-109228,134,16,2260,-123896,-76521,136021,43268,-92116,46349,-24852,-16352,45240,71000,33450,93605,-35254,57809,23018,23714,26849,46611,13042,9939},
{0,-91508,0,-28873,-21706,-8412,85247,21917,52664,-159943,1528,-49768,84661,-1611,-25199,141947,-25191,-31633,-149668,1224,16663,36387,-10482,29496,-109838,134,16,3961,-124119,-74326,136323,41631,-91280,46327,-26599,-16381,45118,71287,33413,94092,-35580,58283,23018,23714,26849,45891,13023,10040},
{0,-85615,0,-28157,-21764,-8258,82085,20554,51729,-154736,-1354,-50588,81856,-1002,-24714,137226,-23984,-31607,-144140,2257,17213,34889,-10502,28691,-109645,134,16,6754,-123884,-70243,135481,40842,-89957,46303,-27747,-16398,45015,70992,32718,93826,-35403,58024,23019,23714,26849,44357,13008,10143},
{0,-79722,0,-27442,-21822,-8103,78918,19220,50753,-149549,-4275,-51256,79048,-406,-24212,132518,-22779,-31523,-138616,3318,17706,33390,-10510,27884,-109452,134,16,9495,-123617,-66210,134653,40042,-88645,46279,-28894,-16415,44912,70695,32023,93561,-35225,57766,23018,23714,26849,42823,12993,10245},
{0,-74123,0,-26611,-21887,-7923,75573,17860,49715,-144297,-7368,-51695,76172,248,-23847,127778,-21559,-31365,-132930,4473,17993,31673,-10556,27151,-108894,134,15,12566,-122984,-61498,133168,39789,-87121,46269,-29307,-16421,44809,70092,30992,92897,-34774,57119,23019,23714,26849,40955,12986,10343},
{0,-68524,0,-25781,-21951,-7743,72221,16535,48634,-139045,-10480,-51972,73293,890,-23463,123048,-20347,-31148,-127244,5643,18215,29956,-10589,26417,-108337,134,14,15495,-122309,-56924,131689,39515,-85603,46259,-29720,-16427,44700,69487,29966,92237,-34319,56477,23019,23714,26849,39086,12977,10442},
{0,-63300,0,-24857,-22020,-7541,68732,15205,47491,-133747,-13711,-52022,70387,1553,-23182,118312,-19144,-30875,-121440,6865,18250,28055,-10651,25750,-107449,134,13,18522,-121291,-51992,129872,39294,-83831,46259,-29720,-16427,44562,68585,28670,91227,-33609,55494,23018,23714,26849,36954,12981,10532},
{0,-58075,0,-23933,-22087,-7339,65234,13916,46304,-128424,-16940,-51898,67479,2207,-22882,113583,-17955,-30545,-115631,8088,18214,26153,-10701,25082,-106561,134,12,21339,-120229,-47267,128062,39042,-82066,46259,-29720,-16427,44413,67681,27383,90227,-32890,54521,23018,23714,26849,34823,12983,10623},
{0,-53294,0,-22936,-22157,-7120,61639,12644,45064,-123072,-20238,-51549,64566,2876,-22677,108863,-16793,-30176,-109734,9330,18011,24097,-10774,24476,-105374,135,10,24048,-118868,-42473,125952,38815,-80089,46259,-29720,-16427,44200,66486,25899,88928,-31932,53258,23019,23714,26849,32501,13000,10701},
{0,-48512,0,-21938,-22226,-6901,58033,11416,43780,-117669,-23514,-51016,61652,3539,-22453,104148,-15649,-29752,-103827,10558,17735,22041,-10835,23869,-104188,135,9,26521,-117468,-37912,123849,38549,-78120,46259,-29720,-16427,43970,65290,24428,87646,-30958,52013,23019,23714,26849,30179,13017,10780},
{0,-44232,0,-20885,-22295,-6668,54361,10222,42450,-112244,-26815,-50260,58753,4210,-22316,99475,-14548,-29303,-97889,11773,17314,19871,-10915,23319,-102737,135,7,28781,-115835,-33469,121484,38281,-75985,46259,-29720,-16427,43642,63812,22831,86118,-29760,50528,23019,23714,26849,27741,13053,10842},
{0,-39952,0,-19831,-22363,-6435,50678,9078,41078,-106740,-30072,-49310,55852,4878,-22160,94804,-13468,-28804,-91936,12960,16821,17700,-10983,22767,-101286,135,5,30814,-114170,-29248,119130,37967,-73860,46259,-29720,-16427,43291,62333,21249,84613,-28541,49068,23018,23714,26849,25302,13087,10904},
{0,-36225,0,-18739,-22430,-6192,46977,7985,39678,-101257,-33296,-48151,53003,5549,-22086,90213,-12443,-28294,-86021,14106,16210,15462,-11067,22267,-99603,135,3,32597,-112248,-25154,116504,37606,-71563,46259,-29720,-16427,42814,60587,19610,82912,-27113,47419,23018,23714,26849,22821,13145,10943},
{0,-32499,0,-17646,-22495,-5949,43264,6945,38239,-95670,-36454,-46790,50153,6218,-21993,85622,-11442,-27738,-80089,15214,15531,13223,-11140,21766,-97921,135,0,34175,-110301,-21262,113892,37189,-69280,46259,-29720,-16427,42310,58840,17984,81243,-25658,45802,23018,23714,26849,20340,13202,10983},
{0,-29371,0,-16528,-22558,-5699,39590,5975,36801,-90177,-39512,-45252,47404,6885,-21978,81168,-10510,-27188,-74304,16251,14768,10978,-11226,21314,-96039,135,-2,35422,-108025,-17533,110996,36673,-66816,46259,-29720,-16427,41657,56845,16363,79425,-24014,44043,23018,23714,26849,17890,13286,10995},
{0,-26243,0,-15411,-22619,-5449,35905,5059,35329,-84561,-42487,-43512,44654,7551,-21944,76713,-9603,-26598,-68502,17242,13945,8733,-11302,20861,-94158,135,-5,36488,-105734,-13977,108120,36092,-64373,46259,-29720,-16427,40977,54852,14751,77644,-22339,42322,23018,23714,26849,15441,13370,11008},
{0,-23755,0,-14283,-22678,-5195,32341,4231,33908,-79191,-45276,-41673,42086,8210,-21984,72495,-8781,-26038,-63039,18129,13091,6582,-11389,20454,-92111,135,-7,37167,-103129,-10689,105002,35381,-61796,46259,-29720,-16427,40135,52635,13197,75760,-20495,40504,23018,23714,26849,13099,13483,10985},
{0,-21267,0,-13154,-22733,-4941,28767,3454,32459,-73690,-47970,-39642,39517,8870,-22006,68275,-7984,-25445,-57560,18968,12188,4430,-11466,20045,-90064,135,-10,37704,-100518,-7530,101912,34596,-59251,46259,-29720,-16427,39267,50424,11646,73918,-18619,38728,23018,23714,26849,10757,13597,10964},
{0,-19455,0,-12028,-22786,-4687,25441,2786,31153,-68732,-50363,-37682,37266,9518,-22100,64468,-7299,-24922,-52770,19659,11344,2543,-11552,19682,-87885,134,-13,37842,-97620,-4701,98627,33660,-56622,46259,-29720,-16427,38235,48018,10194,72012,-16599,36894,23019,23714,26849,8600,13743,10900},
{0,-17643,0,-10902,-22836,-4433,22107,2161,29826,-63654,-52666,-35561,35015,10167,-22178,60659,-6634,-24374,-47968,20310,10466,656,-11631,19318,-85706,134,-16,37881,-94724,-1952,95380,32643,-54036,46259,-29720,-16427,37179,45620,8738,70150,-14546,35105,23019,23714,26849,6442,13891,10837},
{0,-16540,0,-9790,-22883,-4181,19239,1669,28811,-59706,-54501,-33859,33326,10799,-22324,57579,-6126,-23968,-44494,20752,9801,-662,-11716,18998,-83427,134,-19,37538,-91578,437,91990,31460,-51422,46259,-29720,-16427,35969,43064,7412,68261,-12379,33292,23018,23714,26849,4548,14073,10722},
{0,-15438,0,-8677,-22927,-3928,16365,1206,27782,-55677,-56276,-32053,31637,11433,-22459,54498,-5631,-23546,-41014,21171,9120,-1980,-11797,18677,-81149,133,-22,37135,-88440,2792,88647,30195,-48860,46259,-29720,-16427,34736,40518,6073,66417,-10179,31526,23019,23714,26849,2655,14256,10609},
{0,-15075,0,-7589,-22967,-3681,14239,892,27306,-53613,-57389,-31188,30843,12046,-22658,52572,-5349,-23362,-39724,21311,8859,-2321,-11881,18401,-78804,133,-25,36391,-85098,4780,85216,28763,-46325,46259,-29720,-16427,33367,37854,4886,64575,-7898,29767,23019,23714,26849,1104,14476,10434},
{0,-14712,0,-6501,-23005,-3433,12112,589,26823,-51524,-58486,-30290,30050,12660,-22852,50647,-5070,-23172,-38432,21448,8595,-2662,-11964,18124,-76459,132,-28,35619,-81768,6773,81837,27250,-43852,46259,-29720,-16427,31980,35201,3678,62777,-5585,28052,23019,23714,26849,-445,14697,10259},
{0,-14726,0,-5448,-23039,-3192,10481,367,26697,-50714,-59185,-30046,29816,13252,-23075,49444,-4915,-23131,-38482,21426,8598,-2403,-12046,17874,-74081,131,-32,34558,-78285,8407,78427,25581,-41456,46259,-29720,-16427,30481,32474,2636,61009,-3225,26370,23019,23714,26849,-1569,14954,10012},
{0,-14740,0,-4395,-23071,-2952,8850,147,26568,-49898,-59881,-29794,29583,13845,-23297,48242,-4760,-23089,-38532,21403,8602,-2144,-12128,17624,-71703,130,-35,33492,-74817,10076,75073,23835,-39130,46259,-29720,-16427,28967,29758,1566,59282,-837,24731,23019,23714,26849,-2693,15210,9764},
{0,-14749,0,-3386,-23098,-2721,7269,-63,26420,-49052,-60576,-29509,29334,14417,-23514,47076,-4611,-23047,-38553,21385,8600,-1908,-12204,17382,-69325,130,-38,32199,-71255,11403,71741,21959,-36926,46259,-29720,-16427,27373,27012,666,57606,1562,23144,23019,23714,26849,-3275,15504,9425},
{0,-14758,0,-2377,-23124,-2490,5689,-272,26269,-48201,-61269,-29216,29085,14989,-23730,45910,-4462,-23003,-38573,21366,8597,-1673,-12281,17141,-66947,129,-41,30915,-67708,12785,68465,20013,-34795,46259,-29720,-16427,25766,24278,-268,55967,3986,21597,23019,23714,26849,-3855,15796,9084},
{0,-14762,0,-1421,-23146,-2270,4166,-470,26096,-47309,-61959,-28881,28815,15534,-23939,44792,-4321,-22961,-38567,21352,8590,-1462,-12352,16909,-64602,128,-44,29467,-64131,13850,65260,17974,-32822,46259,-29720,-16427,24115,21560,-1031,54398,6382,20120,23018,23714,26849,-4018,16102,8672},
{0,-14765,0,-465,-23166,-2051,2643,-665,25920,-46410,-62646,-28538,28546,16081,-24147,43674,-4179,-22916,-38562,21337,8583,-1250,-12423,16678,-62258,127,-47,28036,-60568,14982,62108,15874,-30922,46259,-29720,-16427,22452,18853,-1831,52862,8800,18678,23018,23714,26849,-4179,16404,8256},
{0,-14765,0,430,-23183,-1845,1203,-847,25734,-45512,-63314,-28175,28272,16596,-24346,42617,-4046,-22873,-38535,21325,8572,-1061,-12489,16459,-59979,125,-50,26504,-57041,15825,59073,13727,-29205,46259,-29720,-16427,20784,16209,-2468,51412,11152,17321,23019,23714,26849,-4083,16697,7798},
{0,-14765,0,1326,-23198,-1640,-238,-1026,25545,-44607,-63979,-27803,27999,17111,-24543,41560,-3913,-22829,-38509,21314,8561,-873,-12554,16240,-57701,124,-53,24992,-53527,16740,56083,11530,-27558,46259,-29720,-16427,19105,13574,-3143,49989,13522,15994,23019,23714,26849,-3986,16984,7337},
{0,-14761,0,2152,-23211,-1450,-1592,-1191,25343,-43688,-64624,-27404,27715,17591,-24730,40574,-3790,-22787,-38467,21305,8548,-706,-12614,16035,-55521,123,-55,23440,-50117,17396,53250,9342,-26108,46259,-29720,-16427,17459,11047,-3664,48665,15788,14763,23019,23714,26849,-3719,17249,6854},
{0,-14758,0,2979,-23222,-1259,-2947,-1352,25138,-42762,-65267,-26995,27431,18072,-24915,39588,-3667,-22744,-38425,21297,8534,-540,-12673,15830,-53342,122,-58,21907,-46718,18124,50455,7113,-24722,46259,-29720,-16427,15805,8527,-4222,47363,18070,13558,23018,23714,26849,-3451,17508,6367},
{0,-14752,0,3730,-23230,-1086,-4195,-1498,24930,-41858,-65874,-26578,27150,18512,-25088,38684,-3555,-22703,-38372,21291,8519,-395,-12726,15642,-51295,121,-60,20392,-43490,18626,47853,4951,-23536,46259,-29720,-16427,14223,6159,-4641,46171,20208,12458,23019,23714,26849,-3066,17737,5875},
{0,-14745,0,4481,-23238,-914,-5443,-1641,24720,-40946,-66479,-26152,26869,18953,-25259,37780,-3443,-22662,-38319,21285,8503,-250,-12779,15454,-49248,119,-63,18891,-40272,19194,45280,2760,-22407,46259,-29720,-16427,12632,3797,-5093,44998,22359,11379,23019,23714,26849,-2679,17960,5381},
{0,-14738,0,5150,-23243,-759,-6573,-1767,24511,-40067,-67041,-25726,26594,19350,-25415,36969,-3343,-22624,-38260,21281,8487,-126,-12826,15284,-47367,118,-65,17462,-37291,19568,42934,695,-21470,46259,-29720,-16427,11152,1629,-5422,43945,24331,10413,23019,23714,26849,-2212,18150,4897},
{0,-14730,0,5819,-23248,-605,-7703,-1890,24300,-39180,-67600,-25291,26320,19746,-25569,36158,-3244,-22586,-38201,21277,8472,-2,-12872,15114,-45485,117,-67,16044,-34318,20001,40608,-1391,-20582,46259,-29720,-16427,9665,-535,-5780,42905,26312,9464,23019,23714,26849,-1744,18334,4411},
{0,-14721,0,6400,-23251,-472,-8705,-1996,24093,-38339,-68109,-24864,26055,20094,-25707,35448,-3157,-22551,-38141,21275,8456,102,-12912,14965,-43803,116,-69,14745,-31647,20273,38543,-3291,-19871,46259,-29720,-16427,8325,-2466,-6031,41995,28078,8635,23019,23714,26849,-1225,18484,3952},
{0,-14713,0,6980,-23253,-338,-9706,-2100,23886,-37492,-68615,-24429,25790,20442,-25843,34739,-3070,-22517,-38081,21272,8440,206,-12952,14816,-42120,115,-71,13453,-28980,20593,36489,-5205,-19199,46259,-29720,-16427,6978,-4393,-6307,41095,29850,7819,23019,23714,26849,-706,18629,3490},
{0,-14704,0,7467,-23254,-226,-10558,-2185,23697,-36736,-69054,-24032,25552,20736,-25960,34141,-2997,-22487,-38025,21271,8426,291,-12985,14689,-40669,114,-73,12323,-26677,20785,34730,-6875,-18685,46259,-29720,-16427,5813,-6049,-6494,40333,31373,7131,23018,23714,26849,-166,18742,3070},
{0,-14695,0,7953,-23255,-114,-11410,-2269,23507,-35976,-69491,-23629,25315,21031,-26076,33543,-2925,-22457,-37969,21270,8412,376,-13018,14562,-39218,113,-74,11196,-24377,21012,32976,-8555,-18199,46259,-29720,-16427,4642,-7702,-6699,39578,32900,6451,23018,23714,26849,375,18850,2649},
{0,-14688,0,8340,-23255,-25,-12098,-2334,23344,-35331,-69851,-23280,25111,21267,-26170,33065,-2867,-22432,-37920,21269,8400,443,-13044,14460,-38032,112,-76,10268,-22496,21141,31550,-9938,-17848,46259,-29720,-16427,3685,-9049,-6832,38970,34144,5906,23018,23714,26849,902,18930,2286},
{0,-14680,0,8726,-23255,65,-12787,-2399,23180,-34682,-70210,-22926,24908,21504,-26264,32587,-2809,-22407,-37871,21269,8388,509,-13070,14358,-36846,111,-77,9342,-20618,21294,30127,-11326,-17515,46259,-29720,-16427,2724,-10393,-6977,38367,35390,5366,23018,23714,26849,1430,19005,1922},
{0,-14674,0,9009,-23255,130,-13296,-2445,23052,-34184,-70479,-22651,24751,21679,-26333,32236,-2767,-22389,-37833,21268,8379,557,-13088,14283,-35957,110,-78,8646,-19214,21377,29065,-12369,-17294,46259,-29720,-16427,2005,-11396,-7066,37921,36319,4968,23018,23714,26849,1900,19056,1633},
{0,-14668,0,9291,-23254,195,-13806,-2491,22924,-33683,-70748,-22373,24594,21853,-26402,31886,-2724,-22370,-37796,21268,8369,604,-13107,14207,-35069,109,-79,7951,-17811,21472,28005,-13415,-17083,46259,-29720,-16427,1285,-12397,-7162,37478,37250,4573,23019,23714,26849,2370,19105,1345},
{0,-14663,0,9463,-23254,234,-14122,-2518,22841,-33362,-70917,-22193,24493,21961,-26445,31671,-2699,-22359,-37772,21268,8364,633,-13118,14160,-34512,109,-80,7516,-16933,21519,27341,-14071,-16963,46259,-29720,-16427,834,-13022,-7213,37202,37832,4328,23019,23714,26849,2722,19132,1152},
{0,-14659,0,9636,-23254,274,-14437,-2546,22759,-33041,-71085,-22012,24392,22069,-26488,31457,-2673,-22348,-37748,21268,8358,663,-13130,14113,-33955,108,-80,7081,-16055,21570,26678,-14727,-16847,46259,-29720,-16427,383,-13647,-7267,36928,38414,4084,23018,23714,26849,3074,19159,960},
{0,-14658,0,9694,-23254,288,-14545,-2555,22730,-32929,-71143,-21948,24357,22106,-26503,31384,-2664,-22344,-37740,21268,8356,672,-13134,14097,-33761,108,-80,6931,-15752,21585,26449,-14955,-16809,46259,-29720,-16427,227,-13863,-7284,36833,38615,4000,23019,23714,26849,3218,19167,889},
{0,-14657,0,9753,-23253,301,-14653,-2564,22701,-32817,-71201,-21885,24322,22143,-26518,31310,-2655,-22340,-37731,21268,8354,682,-13137,14081,-33568,108,-81,6780,-15449,21601,26219,-15182,-16772,46259,-29720,-16427,71,-14079,-7302,36739,38817,3916,23019,23714,26849,3361,19176,818},
}
local clip={Duration=1.2666666666666666,Loop=false,Source="Quaternius original GLB",Role="NinjaJump_Land",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/clips/NinjaJump_Start.luau
addModule(modules,{"world","clips","NinjaJump_Start"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-138927,0,-10550,-22851,-4353,69598,26900,80124,-192002,23652,-57231,105083,20165,-32508,153560,-29073,-32490,-185032,-2485,8552,43324,-14569,25473,-101214,135,5,24430,-89606,-28418,102918,63249,-74414,46259,-29720,-16427,43903,50312,19132,73445,-18126,38273,49053,27731,12254,76912,14859,5664},
{0,-78579,0,33,-23176,-1937,26454,4924,51340,-117633,-33932,-60471,62626,21845,-29122,88131,-13824,-32292,-105630,10591,12444,19251,-14548,20715,-105198,-3972,3587,33779,-82164,-13945,91142,57487,-64204,46259,-29720,-16427,50527,44994,-1957,54385,-19373,32747,49052,27731,12254,93965,14931,-2494},
{0,-18232,0,10626,-23250,502,-20850,-2337,16198,-17001,-74279,-11557,20047,22009,-25321,23396,-1801,-22876,-24954,22494,5683,-4775,-13405,16104,-109058,-8040,7194,40641,-74317,-1232,80526,50822,-55208,46259,-29720,-16427,55701,39133,-22291,35256,-19566,27073,49052,27731,12254,110958,13185,-10347},
{0,-17536,0,21928,-23545,3654,-18766,-3285,24517,-53413,-62674,-32480,13970,25844,-20570,31199,-3514,-29614,-70562,16384,13164,-8621,-14873,17645,-111083,-7706,7891,29570,-59993,156,76776,43245,-46367,46298,-27855,-16399,44974,28800,-20176,15645,-15549,24625,49241,27108,12252,104532,13684,-10200},
{0,-16840,0,33237,-23492,6821,-16609,-4057,32857,-83569,-46431,-45966,7645,29387,-15535,38876,-5742,-36204,-115201,7686,17135,-12452,-16398,19131,-113108,-7360,8588,19478,-45699,3344,73870,35411,-38112,46337,-25989,-16371,34816,18218,-19075,-3751,-11142,23025,49430,26485,12252,98103,14194,-10032},
{0,-15615,0,41704,-23975,10064,-6012,-2618,37546,-112648,-27785,-49623,-10150,31323,-7217,45286,-8798,-45550,-153841,1326,14334,-21281,-26489,22709,-115156,-6186,9565,8008,-28002,-254,75174,27219,-26966,46353,-21315,-16282,25238,11346,-12055,-15232,-2756,24850,49870,25000,12263,86387,15337,-8768},
{0,-14389,0,50189,-24189,13341,4503,-692,42056,-140038,-8928,-47677,-28122,31815,1363,51403,-12433,-54714,-192661,-3507,9341,-30019,-36848,25442,-117204,-5008,10561,-2007,-9822,-1379,77371,19215,-15925,46365,-16641,-16193,16344,3904,-5514,-26877,5365,27625,50310,23514,12281,74643,16399,-7385},
{0,-13361,0,55590,-24786,16117,16838,1945,42122,-162670,1589,-42001,-34403,32830,4928,55576,-15942,-63319,-212979,-2159,4389,-25972,-44962,25151,-119752,-3694,11600,-9497,7328,-6309,78952,15894,-9667,46211,-10545,-16022,10588,1950,4619,-31840,11173,29814,50818,21741,12325,62208,17419,-5412},
{0,-12333,0,61014,-25236,18926,29183,4570,41864,-185993,10540,-34069,-40738,33629,8565,59454,-19791,-71825,-233203,157,-190,-21773,-53080,25227,-122298,-2391,12687,-16257,24881,-9801,80732,12678,-3386,46048,-4450,-15843,5011,-243,14682,-36972,16863,32310,51325,19967,12378,49739,18270,-3304},
{0,-11736,0,63937,-25804,20880,40900,6762,39895,-203395,14111,-28272,-42574,35403,10647,60581,-22148,-78005,-242060,2037,-1669,-21531,-57400,21575,-124723,-1498,13625,-20441,38479,-14112,80708,12755,-3528,45692,1660,-15586,1441,521,24508,-38079,18448,32944,51738,18481,12440,40135,18765,-1440},
{0,-11139,0,66876,-26316,22853,52677,8708,37679,-221059,16623,-21909,-44462,37141,12777,61563,-24570,-84193,-250893,4041,-2978,-21476,-61725,17827,-127145,-622,14604,-24381,52237,-17899,80685,12831,-3671,45320,7770,-15306,-2297,1247,34302,-39200,20025,33598,52151,16996,12508,30517,19127,492},
{0,-10873,0,68198,-26525,23669,59219,9774,36747,-229479,17182,-19231,-44869,38379,13694,60997,-25749,-88638,-253782,3596,-2506,-22937,-62901,13214,-130293,-810,15088,-26273,60340,-20942,82889,15312,-6505,44899,12474,-15029,-3785,2196,39786,-37739,17964,32748,52321,16373,12541,28816,19362,1207},
{0,-10607,0,69523,-26724,24488,65779,10778,35746,-237918,17516,-16514,-45291,39613,14621,60376,-26902,-93104,-256670,3137,-2047,-24476,-64022,8541,-133439,-1014,15580,-28092,68471,-23903,85172,17729,-9406,44462,17178,-14729,-5352,3143,45265,-36301,15890,31932,52491,15750,12576,27113,19584,1931},
{0,-10563,0,69734,-26701,24519,67737,11258,36042,-240477,17780,-15935,-45233,39819,15002,60463,-27773,-95577,-257822,3016,-1920,-25977,-64947,5528,-136326,-1795,15642,-28588,70614,-24428,87491,20235,-12593,44253,19060,-14591,-5281,3603,46964,-34173,12743,30763,52491,15750,12576,30124,19865,1737},
{0,-10520,0,69944,-26678,24550,69695,11743,36329,-243038,18030,-15349,-45176,40024,15384,60527,-28646,-98055,-258974,2894,-1795,-27523,-65836,2476,-139212,-2579,15685,-29086,72758,-24946,89902,22667,-15855,44040,20941,-14449,-5218,4064,48663,-32089,9571,29665,52491,15750,12576,33137,20139,1533},
{0,-10549,0,69812,-26718,24517,71889,12272,36577,-245364,18310,-14874,-45281,40175,15734,61246,-29320,-98837,-260077,3399,-2051,-27935,-66550,1463,-141507,-3247,15689,-29409,72805,-24069,91714,24670,-18693,44040,20941,-14449,-5126,4472,49915,-30338,6840,28781,52491,15750,12576,35542,20400,1360},
{0,-10579,0,69679,-26758,24483,74083,12807,36814,-247693,18579,-14393,-45387,40326,16083,61961,-29999,-99615,-261179,3907,-2300,-28358,-67260,440,-143802,-3916,15679,-29733,72851,-23191,93592,26622,-21583,44040,20941,-14449,-5039,4880,51168,-28614,4093,27946,52491,15750,12576,37948,20655,1181},
{0,-10631,0,69441,-26825,24426,76282,13344,37030,-249773,18836,-13980,-45655,40429,16414,62731,-30682,-100291,-262196,4430,-2542,-28785,-67969,-451,-145778,-4510,15639,-29839,72267,-22077,95093,28371,-24250,44040,20941,-14449,-4913,5300,52106,-27148,1716,27265,52491,15750,12576,40022,20897,1031},
{0,-10684,0,69202,-26893,24368,78481,13885,37234,-251855,19084,-13562,-45923,40531,16745,63499,-31371,-100963,-263211,4955,-2779,-29223,-68675,-1351,-147754,-5104,15589,-29937,71682,-20969,96650,30081,-26958,44040,20941,-14449,-4790,5720,53045,-25699,-670,26619,52491,15750,12576,42097,21136,875},
{0,-10748,0,68909,-26979,24295,80612,14414,37420,-253693,19318,-13204,-46317,40591,17057,64274,-32037,-101541,-264136,5488,-3006,-29663,-69369,-2134,-149545,-5644,15511,-29860,70724,-19816,97986,31716,-29573,44040,20941,-14449,-4621,6206,53753,-24431,-2786,26078,52389,15790,12615,43974,21362,748},
{0,-10812,0,68617,-27064,24221,82743,14946,37595,-255533,19545,-12842,-46712,40649,17370,65046,-32707,-102115,-265059,6023,-3229,-30112,-70061,-2926,-151337,-6183,15425,-29770,69767,-18671,99374,33316,-32226,44040,20941,-14449,-4454,6692,54461,-23174,-4907,25562,52287,15830,12655,45853,21584,616},
{0,-10884,0,68293,-27164,24136,84786,15462,37756,-257147,19757,-12533,-47212,40669,17665,65805,-33344,-102603,-265892,6558,-3442,-30558,-70735,-3610,-153009,-6678,15313,-29530,68550,-17553,100626,34895,-34840,44040,20941,-14449,-4241,7265,55001,-22054,-6817,25122,51996,15945,12768,47600,21796,512},
{0,-10955,0,67969,-27263,24051,86830,15980,37906,-258763,19964,-12220,-47713,40688,17960,66563,-33985,-103087,-266725,7095,-3650,-31013,-71407,-4302,-154682,-7172,15194,-29275,67334,-16442,101929,36442,-37491,44040,20941,-14449,-4029,7837,55541,-20941,-8731,24703,51704,16059,12882,49348,22004,404},
{0,-11030,0,67626,-27373,23957,88767,16476,38045,-260169,20159,-11955,-48290,40675,18236,67295,-34585,-103493,-267471,7623,-3845,-31459,-72056,-4893,-156271,-7627,15049,-28887,65923,-15390,103151,37992,-40129,44040,20941,-14449,-3774,8502,55959,-19937,-10470,24341,51242,16239,13065,51001,22203,324},
{0,-11106,0,67283,-27482,23863,90704,16975,38173,-261577,20351,-11688,-48868,40660,18512,68027,-35188,-103895,-268217,8152,-4037,-31912,-72704,-5491,-157861,-8081,14899,-28485,64514,-14343,104425,39512,-42804,44040,20941,-14449,-3520,9167,56376,-18937,-12213,23995,50780,16417,13248,52654,22399,239},
{0,-11184,0,66928,-27599,23762,92519,17447,38291,-262791,20531,-11464,-49496,40618,18768,68725,-35747,-104227,-268881,8664,-4216,-32349,-73325,-5995,-159389,-8499,14725,-27968,62952,-13370,105658,41043,-45477,44040,20941,-14449,-3226,9922,56707,-18027,-13809,23695,50168,16649,13495,54235,22586,182},
{0,-11261,0,66572,-27716,23660,94336,17921,38400,-264006,20709,-11238,-50123,40576,19025,69422,-36307,-104555,-269545,9177,-4391,-32792,-73944,-6505,-160919,-8916,14545,-27437,61394,-12398,106943,42544,-48189,44040,20941,-14449,-2933,10677,57037,-17119,-15408,23408,49555,16880,13743,55817,22772,121},
{0,-11341,0,66211,-27839,23553,96017,18364,38499,-265043,20877,-11052,-50773,40512,19262,70080,-36822,-104820,-270132,9663,-4551,-33213,-74533,-6926,-161369,-9151,14439,-27119,60521,-11905,107353,43641,-50064,44040,20941,-14449,-2691,11040,57197,-16796,-15978,23309,48812,17153,14051,56302,22950,87},
{0,-11420,0,65849,-27962,23446,97700,18809,38590,-266081,21043,-10864,-51423,40446,19498,70738,-37338,-105082,-270719,10150,-4708,-33640,-75120,-7352,-161819,-9386,14331,-26798,59650,-11412,107788,44731,-51953,44040,20941,-14449,-2449,11403,57356,-16474,-16549,23212,48068,17425,14360,56788,23127,51},
{0,-11499,0,65485,-28089,23334,99238,19220,38673,-266956,21201,-10712,-52072,40366,19715,71352,-37806,-105290,-271234,10604,-4849,-34039,-75673,-7695,-161838,-9540,14249,-26550,59012,-11091,107868,45671,-53505,44040,20941,-14449,-2206,11670,57406,-16407,-16667,23192,47213,17729,14724,56832,23296,38},
{0,-11578,0,65121,-28215,23222,100777,19631,38749,-267832,21357,-10559,-52721,40284,19931,71966,-38276,-105495,-271750,11058,-4988,-34443,-76224,-8043,-161858,-9694,14167,-26300,58375,-10769,107965,46609,-55066,44040,20941,-14449,-1963,11936,57457,-16340,-16786,23172,46357,18029,15090,56876,23465,25},
{0,-11657,0,64758,-28343,23107,102166,20006,38818,-268562,21504,-10438,-53346,40192,20127,72545,-38703,-105646,-272201,11480,-5114,-34823,-76739,-8313,-161826,-9822,14079,-26026,57704,-10464,108033,47535,-56588,44040,20941,-14449,-1693,12268,57444,-16336,-16793,23171,45411,18351,15505,56861,23625,31},
{0,-11736,0,64394,-28471,22992,103556,20382,38881,-269292,21651,-10315,-53971,40099,20323,73126,-39132,-105795,-272651,11902,-5237,-35207,-77253,-8588,-161795,-9950,13991,-25751,57033,-10159,108118,48460,-58118,44040,20941,-14449,-1421,12599,57431,-16332,-16799,23170,44462,18670,15923,56847,23785,37},
{0,-11814,0,64034,-28600,22875,104792,20719,38937,-269889,21789,-10222,-54557,40001,20500,73645,-39508,-105910,-273041,12272,-5341,-35547,-77727,-8791,-161758,-10061,13895,-25446,56312,-9857,108221,49381,-59636,44040,20941,-14449,-1124,13003,57366,-16365,-16741,23179,43444,18999,16383,56821,23936,60},
{0,-11891,0,63674,-28729,22757,106029,21057,38989,-270487,21926,-10128,-55141,39902,20676,74164,-39885,-106023,-273430,12643,-5444,-35889,-78200,-8996,-161721,-10172,13799,-25139,55591,-9554,108341,50299,-61163,44040,20941,-14449,-825,13406,57301,-16398,-16682,23189,42424,19324,16847,56795,24086,83},
{0,-11967,0,63320,-28856,22640,107114,21356,39035,-270968,22054,-10059,-55672,39803,20834,74634,-40217,-106103,-273765,12966,-5530,-36192,-78631,-9137,-161691,-10269,13697,-24808,54827,-9253,108494,51206,-62674,44040,20941,-14449,-505,13875,57190,-16459,-16575,23207,41355,19651,17345,56769,24227,119},
{0,-12043,0,62965,-28983,22521,108199,21656,39078,-271449,22183,-9989,-56202,39702,20990,75104,-40549,-106182,-274099,13288,-5614,-36497,-79062,-9280,-161662,-10365,13594,-24475,54063,-8951,108663,52111,-64194,44040,20941,-14449,-183,14342,57079,-16519,-16469,23225,40284,19973,17846,56744,24368,156},
{0,-12117,0,62620,-29107,22404,109138,21916,39115,-271827,22301,-9942,-56670,39604,21129,75524,-40839,-106233,-274383,13562,-5683,-36762,-79451,-9365,-161642,-10448,13487,-24122,53268,-8653,108871,52994,-65687,44040,20941,-14449,156,14865,56927,-16601,-16324,23250,39186,20288,18373,56724,24498,204},
{0,-12191,0,62274,-29231,22286,110077,22178,39150,-272206,22420,-9893,-57137,39506,21266,75945,-41129,-106284,-274668,13835,-5751,-37029,-79839,-9451,-161622,-10531,13380,-23768,52474,-8354,109094,53875,-67190,44040,20941,-14449,497,15386,56774,-16683,-16178,23275,38085,20598,18903,56704,24629,252},
{0,-12262,0,61939,-29352,22171,110877,22402,39180,-272495,22529,-9863,-57537,39414,21385,76318,-41378,-106313,-274907,14059,-5803,-37255,-80183,-9486,-161613,-10603,13270,-23401,51662,-8062,109353,54722,-68649,44040,20941,-14449,849,15951,56585,-16783,-16002,23305,36979,20894,19448,56691,24749,308},
{0,-12332,0,61604,-29471,22055,111678,22626,39208,-272785,22639,-9833,-57935,39321,21504,76691,-41628,-106341,-275147,14283,-5855,-37482,-80528,-9523,-161603,-10674,13160,-23032,50850,-7768,109628,55566,-70119,44040,20941,-14449,1205,16515,56396,-16883,-15826,23335,35870,21184,19997,56677,24869,365},
{0,-12400,0,61283,-29585,21943,112352,22816,39232,-273000,22738,-9818,-58265,39236,21605,77017,-41841,-106352,-275345,14459,-5893,-37670,-80829,-9516,-161604,-10734,13051,-22657,50034,-7486,109933,56367,-71529,44040,20941,-14449,1566,17111,56174,-16996,-15625,23370,34779,21455,20548,56671,24978,427},
{0,-12467,0,60962,-29699,21830,113027,23006,39255,-273215,22838,-9803,-58594,39152,21705,77344,-42054,-106362,-275544,14635,-5930,-37859,-81131,-9509,-161605,-10795,12941,-22281,49218,-7201,110253,57163,-72948,44040,20941,-14449,1930,17705,55952,-17110,-15424,23405,33686,21719,21102,56664,25087,489},
{0,-12531,0,60657,-29806,21723,113599,23168,39275,-273370,22927,-9799,-58864,39077,21787,77627,-42233,-106360,-275707,14767,-5955,-38011,-81390,-9468,-161616,-10845,12835,-21904,48412,-6932,110594,57905,-74288,44040,20941,-14449,2294,18320,55703,-17234,-15205,23443,32633,21960,21646,56665,25185,554},
{0,-12595,0,60352,-29913,21615,114171,23331,39293,-273525,23017,-9794,-59133,39002,21869,77910,-42413,-106358,-275870,14899,-5980,-38163,-81649,-9427,-161626,-10895,12728,-21527,47607,-6660,110948,58642,-75637,44040,20941,-14449,2661,18933,55453,-17358,-14987,23482,31579,22195,22193,56665,25282,619},
{0,-12654,0,60068,-30011,21515,114636,23463,39309,-273631,23098,-9799,-59329,38939,21932,78153,-42562,-106346,-276001,14992,-5994,-38280,-81867,-9359,-161645,-10937,12626,-21158,46827,-6408,111310,59315,-76885,44040,20941,-14449,3021,19552,55182,-17488,-14758,23523,30588,22403,22716,56672,25368,684},
{0,-12712,0,59783,-30109,21414,115102,23596,39324,-273738,23179,-9804,-59524,38875,21995,78395,-42711,-106333,-276132,15084,-6008,-38398,-82086,-9291,-161663,-10978,12525,-20788,46048,-6154,111683,59984,-78142,44040,20941,-14449,3384,20171,54910,-17617,-14529,23564,29596,22607,23241,56679,25454,750},
{0,-12766,0,59522,-30197,21322,115487,23706,39336,-273810,23251,-9814,-59660,38824,22040,78600,-42832,-106315,-276235,15143,-6013,-38485,-82265,-9206,-161689,-11011,12431,-20434,45309,-5922,112050,60578,-79276,44040,20941,-14449,3732,20781,54626,-17748,-14299,23605,28692,22781,23727,56693,25528,813},
{0,-12820,0,59261,-30285,21229,115872,23816,39348,-273882,23323,-9825,-59795,38773,22085,78805,-42954,-106296,-276338,15202,-6018,-38572,-82445,-9121,-161715,-11044,12337,-20079,44571,-5689,112427,61169,-80417,44040,20941,-14449,4083,21390,54340,-17879,-14068,23647,27786,22951,24214,56706,25602,876},
{0,-12867,0,59028,-30361,21147,116193,23908,39358,-273933,23387,-9837,-59876,38735,22111,78975,-43052,-106274,-276417,15233,-6017,-38632,-82587,-9028,-161747,-11070,12254,-19750,43894,-5484,112780,61676,-81411,44040,20941,-14449,4410,21973,54052,-18006,-13846,23688,26992,23091,24647,56726,25663,933},
{0,-12914,0,58796,-30437,21066,116515,24000,39367,-273985,23451,-9849,-59957,38697,22136,79144,-43150,-106251,-276495,15265,-6015,-38693,-82730,-8935,-161778,-11095,12170,-19421,43216,-5277,113141,62180,-82412,44040,20941,-14449,4739,22555,53763,-18132,-13624,23729,26197,23228,25081,56746,25725,991},
{0,-12954,0,58598,-30500,20997,116425,23972,39361,-273755,23501,-9932,-59894,38683,22148,79280,-43225,-106228,-276552,15277,-6010,-38732,-82837,-8843,-161815,-11115,12099,-19129,42621,-5103,113461,62592,-83241,44040,20941,-14449,5031,23088,53487,-18248,-13422,23766,25538,23336,25445,56772,25773,1041},
{0,-12994,0,58399,-30563,20927,116336,23944,39354,-273525,23550,-10016,-59831,38670,22159,79416,-43301,-106205,-276609,15288,-6004,-38770,-82945,-8752,-161852,-11134,12029,-18837,42026,-4928,113786,63001,-84075,44040,20941,-14449,5326,23621,53209,-18363,-13220,23804,24878,23441,25810,56798,25821,1090},
{0,-13026,0,58243,-30611,20874,115767,23774,39326,-272958,23580,-10184,-59631,38680,22163,79519,-43356,-106184,-276647,15287,-5997,-38792,-83021,-8673,-161893,-11149,11974,-18597,41539,-4791,114052,63310,-84714,44040,20941,-14449,5569,24077,52965,-18457,-13054,23835,24377,23517,26088,56830,25856,1129},
{0,-13057,0,58087,-30658,20820,115198,23605,39297,-272392,23610,-10353,-59430,38689,22167,79621,-43412,-106163,-276686,15287,-5990,-38814,-83096,-8593,-161934,-11163,11919,-18356,41053,-4653,114321,63618,-85355,44040,20941,-14449,5814,24531,52720,-18552,-12887,23867,23876,23592,26368,56862,25892,1168},
{0,-13078,0,57982,-30689,20785,114592,23424,39264,-271815,23620,-10518,-59251,38706,22168,79688,-43447,-106147,-276708,15281,-5984,-38824,-83141,-8537,-161978,-11173,11882,-18185,40710,-4560,114514,63817,-85776,44040,20941,-14449,5985,24866,52539,-18614,-12778,23887,23559,23638,26546,56900,25913,1193},
{0,-13099,0,57877,-30720,20750,113986,23244,39231,-271239,23630,-10683,-59071,38722,22168,79754,-43482,-106132,-276730,15275,-5978,-38833,-83186,-8480,-162021,-11183,11845,-18015,40367,-4467,114708,64014,-86198,44040,20941,-14449,6158,25201,52358,-18677,-12670,23908,23241,23683,26724,56938,25934,1219},
{0,-13107,0,57838,-30730,20737,113706,23161,39215,-270974,23632,-10758,-58995,38731,22168,79779,-43494,-106125,-276737,15272,-5975,-38835,-83201,-8459,-162067,-11190,11828,-17938,40214,-4427,114809,64094,-86375,44040,20941,-14449,6228,25349,52289,-18688,-12649,23912,23130,23698,26786,56982,25941,1228},
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
}
local clip={Duration=0.9666666666666667,Loop=false,Source="Quaternius original GLB",Role="NinjaJump_Start",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/clips/Walk_Carry_Loop.luau
addModule(modules,{"world","clips","Walk_Carry_Loop"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-41847,0,57025,2731,2574,-65744,2051,-5326,-63617,-860,-618,51093,-809,-4228,25003,-414,-4788,-79188,-794,-781,4976,-3289,989,-59621,5419,6039,39041,-68180,-10987,93303,65954,15596,33756,39611,-7476,39040,68180,11065,98096,-65391,-13198,33764,-39613,7502,61633,-7647,-5967},
{0,-43248,0,57025,2725,2564,-64341,1919,-5089,-66934,-833,-640,52162,-763,-4408,26042,-444,-4842,-83499,-381,-376,8237,-3764,630,-60363,5757,6366,39044,-68193,-10982,93133,66000,15594,33756,39611,-7476,39040,68180,11065,98191,-65414,-13207,33764,-39613,7502,61800,-8093,-5981},
{0,-44648,0,57025,2719,2554,-62939,1790,-4851,-70250,-805,-661,53231,-719,-4589,27082,-475,-4897,-87811,15,46,11496,-4250,286,-61106,6092,6694,39048,-68207,-10976,92962,66045,15591,33756,39611,-7476,39040,68180,11065,98285,-65436,-13217,33764,-39613,7502,61968,-8539,-5995},
{0,-45413,0,57024,2701,2525,-61690,1677,-4635,-73277,-774,-675,52670,-738,-4632,27241,-531,-5428,-90683,897,1210,14164,-5626,-296,-62063,6280,6894,39058,-68246,-10960,92817,66104,15605,33756,39611,-7476,39040,68180,11065,98236,-65469,-13211,33764,-39613,7502,61891,-8768,-5993},
{0,-46177,0,57024,2682,2496,-60440,1568,-4418,-76303,-743,-688,52109,-756,-4675,27399,-588,-5960,-93565,1744,2399,16825,-7017,-841,-63021,6465,7095,39068,-68286,-10944,92672,66162,15619,33756,39611,-7476,39040,68180,11065,98186,-65502,-13205,33764,-39613,7502,61815,-8997,-5992},
{0,-46407,0,57023,2653,2449,-59372,1465,-4201,-79046,-707,-690,50218,-792,-4618,26868,-648,-6751,-95387,2777,3975,19048,-8861,-1456,-64078,6572,7231,39084,-68349,-10918,92535,66223,15637,33756,39611,-7476,39040,68180,11065,98103,-65537,-13195,33764,-39613,7502,61657,-9119,-5969},
{0,-46636,0,57023,2623,2402,-58303,1365,-3982,-81789,-672,-692,48326,-828,-4561,26337,-704,-7544,-97225,3780,5571,21264,-10719,-2032,-65135,6677,7367,39101,-68413,-10893,92398,66284,15655,33756,39611,-7476,39040,68180,11065,98020,-65573,-13185,33764,-39613,7502,61500,-9241,-5947},
{0,-46422,0,57022,2583,2339,-57436,1269,-3754,-84272,-632,-682,45415,-842,-4426,25265,-733,-8338,-98237,4756,7165,23141,-12588,-2531,-66242,6715,7446,39123,-68498,-10858,92266,66346,15674,33756,39611,-7476,39040,68180,11065,97921,-65609,-13173,33764,-39613,7502,61298,-9276,-5900},
{0,-46208,0,57021,2543,2276,-56568,1174,-3524,-86756,-592,-670,42504,-860,-4293,24193,-753,-9133,-99265,5716,8769,25013,-14466,-2996,-67348,6751,7524,39145,-68584,-10823,92135,66407,15694,33756,39611,-7476,39040,68180,11065,97822,-65645,-13162,33764,-39613,7502,61096,-9311,-5853},
{0,-45544,0,57020,2493,2198,-55944,1080,-3277,-88896,-548,-645,38799,-825,-4104,22631,-720,-9653,-99442,6487,9978,26549,-15901,-3277,-68474,6713,7535,39173,-68690,-10779,92007,66469,15715,33756,39611,-7476,39040,68180,11065,97713,-65681,-13149,33764,-39613,7502,60861,-9250,-5777},
{0,-44879,0,57019,2443,2120,-55319,988,-3029,-91036,-505,-620,35094,-796,-3914,21069,-679,-10173,-99627,7256,11188,28085,-17340,-3537,-69600,6674,7545,39200,-68796,-10736,91880,66530,15736,33756,39611,-7476,39040,68180,11065,97605,-65717,-13137,33764,-39613,7502,60627,-9190,-5700},
{0,-43755,0,57018,2384,2029,-54911,894,-2758,-92818,-458,-579,30821,-695,-3692,19090,-577,-10158,-98918,7667,11630,29280,-17870,-3558,-70723,6534,7453,39233,-68920,-10684,91756,66591,15758,33756,39611,-7476,39040,68180,11065,97490,-65754,-13124,33764,-39613,7502,60364,-8996,-5580},
{0,-42632,0,57017,2325,1937,-54504,800,-2487,-94600,-411,-537,26548,-603,-3466,17110,-476,-10141,-98210,8082,12069,30475,-18400,-3572,-71845,6395,7359,39266,-69045,-10633,91632,66652,15779,33756,39611,-7476,39040,68180,11065,97376,-65790,-13111,33764,-39613,7502,60102,-8803,-5459},
{0,-41084,0,57016,2257,1834,-54210,701,-2190,-96087,-361,-482,21933,-431,-3233,14819,-322,-9087,-96535,7581,10950,31328,-16925,-3270,-72943,6154,7150,39303,-69186,-10575,91512,66712,15802,33756,39611,-7476,39040,68180,11065,97258,-65826,-13097,33764,-39613,7502,59810,-8471,-5283},
{0,-39537,0,57014,2189,1731,-53917,603,-1892,-97573,-312,-425,17318,-270,-2991,12525,-192,-8030,-94867,7062,9840,32174,-15449,-2980,-74041,5915,6939,39340,-69327,-10516,91392,66773,15824,33756,39611,-7476,39040,68180,11065,97139,-65863,-13084,33764,-39613,7502,59518,-8140,-5104},
{0,-37657,0,57011,2114,1617,-53525,496,-1567,-98917,-258,-355,12569,-34,-2768,9878,-68,-6332,-92362,5807,7743,32635,-12566,-2626,-75093,5658,6691,39382,-69483,-10452,91275,66832,15846,33756,39611,-7476,39040,68180,11065,97019,-65899,-13070,33764,-39613,7502,59183,-7784,-4891},
{0,-35777,0,57007,2038,1504,-53133,390,-1241,-100260,-206,-284,7820,190,-2533,7229,12,-4632,-89886,4500,5679,33084,-9681,-2287,-76144,5402,6441,39423,-69639,-10387,91157,66892,15869,33756,39611,-7476,39040,68180,11065,96899,-65935,-13056,33764,-39613,7502,58847,-7431,-4673},
{0,-33705,0,57006,1956,1381,-51431,268,-881,-102648,-147,-201,3124,478,-2344,4181,59,-3326,-86780,3494,4190,33150,-7485,-2165,-77128,5147,6172,39469,-69807,-10317,91043,66950,15891,33756,39611,-7476,39040,68180,11065,96778,-65971,-13043,33764,-39613,7502,58456,-7079,-4427},
{0,-31634,0,57006,1873,1258,-49729,153,-519,-105037,-91,-117,-1574,757,-2142,1133,67,-2019,-83690,2442,2733,33214,-5289,-2045,-78111,4894,5900,39514,-69976,-10246,90929,67009,15914,33756,39611,-7476,39040,68180,11065,96657,-66006,-13029,33764,-39613,7502,58063,-6731,-4176},
{0,-29535,0,57005,1784,1128,-46676,34,-123,-108390,-32,-10,-6324,1087,-2004,-2165,64,-1291,-80136,2036,2144,32983,-4306,-2102,-78982,4649,5615,39563,-70156,-10170,90819,67066,15937,33756,39611,-7476,39040,68180,11065,96536,-66041,-13015,33764,-39613,7502,57591,-6393,-3898},
{0,-27436,0,57005,1695,998,-43624,-73,277,-111744,24,98,-11075,1410,-1851,-5464,37,-563,-76584,1609,1570,32753,-3323,-2156,-79853,4405,5327,39612,-70335,-10095,90708,67123,15960,33756,39611,-7476,39040,68180,11065,96414,-66077,-13002,33764,-39613,7502,57119,-6059,-3616},
{0,-25455,0,57004,1601,862,-39827,-171,705,-115307,77,233,-16068,1764,-1772,-8899,-1,17,-72695,1317,1204,32310,-2631,-2267,-80538,4173,5026,39664,-70524,-10015,90600,67180,15982,33756,39611,-7476,39040,68180,11065,96294,-66111,-12988,33764,-39613,7502,56518,-5742,-3302},
{0,-23474,0,57003,1506,725,-36030,-253,1136,-118870,125,371,-21062,2114,-1676,-12334,-60,595,-68808,1011,850,31868,-1940,-2376,-81224,3943,4723,39716,-70713,-9935,90492,67236,16005,33756,39611,-7476,39040,68180,11065,96173,-66146,-12975,33764,-39613,7502,55916,-5429,-2985},
{0,-21714,0,57003,1407,584,-31897,-317,1578,-122167,166,531,-26023,2469,-1602,-15836,-126,1066,-64715,825,648,31282,-1484,-2516,-81546,3731,4403,39770,-70909,-9851,90388,67291,16027,33756,39611,-7476,39040,68180,11065,96054,-66180,-12962,33764,-39613,7502,55051,-5134,-2640},
{0,-19955,0,57002,1307,443,-27763,-363,2022,-125464,202,692,-30984,2821,-1511,-19337,-209,1534,-60623,631,453,30697,-1028,-2654,-81869,3520,4082,39825,-71105,-9767,90284,67345,16050,33756,39611,-7476,39040,68180,11065,95934,-66214,-12949,33764,-39613,7502,54184,-4845,-2290},
{0,-18475,0,57002,1203,299,-23558,-388,2457,-128293,230,867,-35419,3156,-1391,-22707,-296,1930,-56679,537,359,29930,-739,-2783,-81601,3331,3742,39882,-71307,-9681,90183,67399,16072,33756,39611,-7476,39040,68180,11065,95817,-66247,-12936,33764,-39613,7502,52912,-4571,-1924},
{0,-16995,0,57001,1099,155,-19352,-394,2892,-131123,253,1043,-39855,3487,-1256,-26077,-397,2323,-52736,440,269,29164,-450,-2909,-81333,3141,3402,39939,-71509,-9594,90082,67452,16094,33756,39611,-7476,39040,68180,11065,95699,-66281,-12923,33764,-39613,7502,51639,-4303,-1554},
{0,-15813,0,57001,992,9,-15190,-381,3308,-133389,269,1224,-43651,3793,-1112,-29084,-498,2674,-49373,418,237,28255,-258,-2990,-80727,2955,3054,39997,-71714,-9506,89984,67503,16116,33756,39611,-7476,39040,68180,11065,95584,-66313,-12910,33764,-39613,7502,50497,-4048,-1161},
{0,-14632,0,57000,885,-137,-11029,-351,3724,-135656,282,1406,-47448,4093,-956,-32092,-610,3022,-46011,395,206,27345,-65,-3070,-80122,2769,2709,40056,-71919,-9417,89887,67555,16138,33756,39611,-7476,39040,68180,11065,95469,-66345,-12898,33764,-39613,7502,49353,-3799,-763},
{0,-13747,0,57000,774,-283,-7014,-304,4113,-137301,292,1585,-50470,4364,-812,-34650,-721,3350,-43431,412,201,26451,85,-3104,-79332,2579,2363,40115,-72126,-9326,89794,67605,16159,33756,39611,-7476,39040,68180,11065,95357,-66377,-12885,33764,-39613,7502,48760,-3555,-340},
{0,-12861,0,56999,664,-429,-2998,-242,4499,-138946,299,1764,-53493,4629,-661,-37208,-840,3676,-40850,430,195,25556,236,-3136,-78542,2388,2019,40175,-72333,-9236,89700,67655,16181,33756,39611,-7476,39040,68180,11065,95245,-66408,-12873,33764,-39613,7502,48166,-3313,84},
{0,-12256,0,56999,552,-574,819,-168,4853,-140056,307,1935,-54807,4861,-582,-39242,-956,3992,-39218,456,197,24815,388,-3124,-77638,2190,1678,40235,-72540,-9145,89610,67702,16201,33756,39611,-7476,39040,68180,11065,95136,-66439,-12861,33764,-39613,7502,47795,-3064,513},
{0,-11650,0,56999,439,-719,4636,-81,5205,-141167,314,2106,-56122,5092,-500,-41276,-1077,4307,-37586,481,198,24074,540,-3112,-76734,1991,1339,40296,-72747,-9054,89521,67750,16222,33756,39611,-7476,39040,68180,11065,95028,-66469,-12850,33764,-39613,7502,47423,-2815,942},
{0,-11303,0,56998,325,-862,8220,13,5520,-141804,324,2263,-55155,5287,-541,-42750,-1190,4612,-36991,511,206,23583,696,-3056,-75755,1783,1005,40356,-72952,-8964,89436,67796,16242,33756,39611,-7476,39040,68180,11065,94924,-66498,-12838,33764,-39613,7502,47267,-2553,1369},
{0,-10956,0,56998,211,-1005,11804,118,5831,-142440,333,2420,-54188,5482,-584,-44224,-1307,4916,-36396,541,214,23093,852,-2999,-74778,1575,674,40417,-73157,-8873,89351,67841,16262,33756,39611,-7476,39040,68180,11065,94819,-66527,-12827,33764,-39613,7502,47109,-2290,1795},
{0,-10844,0,56998,97,-1143,15053,223,6101,-142509,350,2553,-51318,5629,-752,-45199,-1412,5206,-36738,578,230,22860,1006,-2899,-73752,1358,348,40477,-73359,-8783,89271,67885,16281,33756,39611,-7476,39040,68180,11065,94720,-66555,-12816,33764,-39613,7502,47144,-2011,2214},
{0,-10733,0,56998,-18,-1281,18302,336,6367,-142578,368,2686,-48448,5772,-925,-46173,-1519,5495,-37081,615,247,22626,1159,-2798,-72727,1139,25,40538,-73560,-8693,89190,67928,16301,33756,39611,-7476,39040,68180,11065,94620,-66582,-12806,33764,-39613,7502,47179,-1728,2631},
{0,-10797,0,56998,-133,-1414,21091,440,6584,-141958,400,2782,-44055,5842,-1209,-46828,-1612,5760,-38022,657,271,22535,1300,-2651,-71675,913,-291,40597,-73755,-8605,89116,67968,16319,33756,39611,-7476,39040,68180,11065,94526,-66609,-12796,33764,-39613,7502,47378,-1426,3036},
{0,-10862,0,56997,-247,-1547,23880,550,6798,-141337,433,2878,-39663,5900,-1495,-47482,-1708,6024,-38963,699,296,22444,1442,-2503,-70623,685,-605,40656,-73951,-8517,89041,68009,16337,33756,39611,-7476,39040,68180,11065,94433,-66635,-12786,33764,-39613,7502,47576,-1121,3437},
{0,-11072,0,56997,-361,-1674,26093,640,6950,-139944,482,2922,-34104,5850,-1857,-47968,-1787,6245,-40223,741,325,22411,1559,-2298,-69561,451,-913,40714,-74139,-8432,88971,68046,16354,33756,39611,-7476,39040,68180,11065,94345,-66659,-12776,33764,-39613,7502,47907,-795,3821},
{0,-11283,0,56997,-475,-1800,28307,733,7100,-138552,532,2965,-28545,5781,-2216,-48453,-1867,6465,-41482,783,354,22377,1676,-2094,-68499,215,-1217,40772,-74328,-8347,88902,68083,16371,33756,39611,-7476,39040,68180,11065,94258,-66683,-12767,33764,-39613,7502,48237,-465,4201},
{0,-11663,0,56998,-588,-1917,29865,797,7177,-136363,595,2946,-22151,5583,-2591,-48800,-1924,6622,-43020,822,387,22436,1756,-1822,-67443,-27,-1515,40827,-74507,-8265,88840,68117,16386,33756,39611,-7476,39040,68180,11065,94179,-66705,-12759,33764,-39613,7502,48668,-116,4558},
{0,-12044,0,56998,-701,-2035,31423,863,7253,-134175,658,2926,-15759,5362,-2953,-49148,-1982,6777,-44558,860,421,22494,1836,-1551,-66387,-270,-1810,40882,-74685,-8183,88777,68151,16402,33756,39611,-7476,39040,68180,11065,94099,-66727,-12750,33764,-39613,7502,49098,238,4911},
{0,-12624,0,57001,-811,-2143,32246,897,7282,-131150,731,2851,-8880,5051,-3286,-49404,-2023,6884,-46307,895,458,22668,1878,-1237,-65358,-517,-2098,40935,-74853,-8106,88722,68181,16415,33756,39611,-7476,39040,68180,11065,94029,-66746,-12743,33764,-39613,7502,49598,609,5237},
{0,-13205,0,57004,-922,-2251,33069,931,7310,-128125,802,2774,-2004,4718,-3597,-49661,-2064,6990,-48056,930,496,22841,1920,-924,-64328,-765,-2384,40988,-75021,-8029,88667,68211,16429,33756,39611,-7476,39040,68180,11065,93958,-66766,-12735,33764,-39613,7502,50096,983,5558},
{0,-14023,0,57005,-1030,-2347,33109,932,7309,-124232,878,2651,4996,4339,-3850,-49835,-2090,7056,-50014,961,538,23187,1926,-590,-63340,-1016,-2663,41036,-75176,-7958,88621,68236,16441,33756,39611,-7476,39040,68180,11065,93898,-66782,-12729,33764,-39613,7502,50636,1372,5847},
{0,-14842,0,57006,-1138,-2444,33148,934,7308,-120339,948,2525,11993,3942,-4076,-50008,-2117,7123,-51973,992,580,23533,1933,-255,-62353,-1268,-2939,41086,-75331,-7886,88575,68262,16453,33756,39611,-7476,39040,68180,11065,93838,-66799,-12723,33764,-39613,7502,51176,1765,6130},
{0,-15944,0,57007,-1242,-2528,32383,903,7288,-115578,1014,2363,18601,3549,-4225,-50130,-2131,7156,-54115,1018,626,24100,1906,84,-61435,-1521,-3210,41130,-75471,-7821,88538,68281,16462,33756,39611,-7476,39040,68180,11065,93791,-66812,-12718,33764,-39613,7502,51736,2166,6376},
{0,-17047,0,57008,-1347,-2611,31618,872,7266,-110817,1072,2198,25207,3147,-4347,-50251,-2146,7189,-56257,1044,673,24667,1881,424,-60519,-1774,-3478,41175,-75612,-7755,88502,68301,16471,33756,39611,-7476,39040,68180,11065,93744,-66825,-12713,33764,-39613,7502,52295,2571,6616},
{0,-18484,0,57009,-1447,-2681,30282,818,7227,-105581,1114,2018,30458,2821,-4382,-50322,-2150,7192,-58613,1065,723,25534,1826,755,-59713,-2025,-3741,41215,-75735,-7698,88478,68314,16477,33756,39611,-7476,39040,68180,11065,93713,-66833,-12710,33764,-39613,7502,52867,2976,6825},
{0,-19921,0,57010,-1547,-2751,28947,765,7187,-100346,1147,1837,35708,2493,-4399,-50393,-2154,7195,-60969,1086,774,26400,1774,1086,-58907,-2277,-4002,41255,-75859,-7640,88454,68327,16483,33756,39611,-7476,39040,68180,11065,93681,-66842,-12706,33764,-39613,7502,53438,3384,7028},
{0,-21738,0,57011,-1642,-2805,27391,703,7127,-95214,1159,1667,38557,2306,-4336,-50454,-2149,7171,-63500,1100,828,27612,1699,1397,-58283,-2521,-4259,41289,-75964,-7591,88445,68332,16486,33756,39611,-7476,39040,68180,11065,93670,-66845,-12705,33764,-39613,7502,54046,3786,7202},
{0,-23556,0,57012,-1738,-2859,25834,641,7065,-90082,1162,1497,41406,2120,-4268,-50515,-2144,7147,-66031,1113,882,28824,1627,1709,-57659,-2765,-4514,41323,-76069,-7541,88437,68337,16488,33756,39611,-7476,39040,68180,11065,93658,-66848,-12704,33764,-39613,7502,54653,4191,7370},
{0,-25756,0,57014,-1828,-2896,24501,586,6978,-85811,1149,1360,40893,2117,-4124,-50633,-2133,7097,-68637,1119,936,30395,1539,1991,-57371,-2993,-4770,41351,-76154,-7501,88447,68334,16487,33756,39611,-7476,39040,68180,11065,93658,-66847,-12704,33764,-39613,7502,55402,4581,7511},
{0,-27957,0,57015,-1917,-2932,23168,533,6891,-81541,1129,1224,40379,2113,-3980,-50752,-2123,7046,-71243,1124,991,31967,1456,2273,-57083,-3221,-5025,41378,-76239,-7461,88458,68331,16487,33756,39611,-7476,39040,68180,11065,93658,-66845,-12704,33764,-39613,7502,56151,4973,7646},
{0,-30427,0,57016,-2001,-2951,22510,501,6773,-78938,1104,1138,34394,2352,-3708,-51072,-2111,6968,-73644,1120,1037,33807,1366,2520,-57343,-3418,-5287,41399,-76302,-7431,88487,68322,16485,33756,39611,-7476,39040,68180,11065,93658,-66840,-12703,33764,-39613,7502,57207,5343,7755},
{0,-32897,0,57017,-2084,-2969,21852,470,6654,-76335,1076,1052,28407,2574,-3422,-51391,-2100,6891,-76046,1115,1083,35647,1280,2767,-57604,-3614,-5549,41420,-76365,-7401,88517,68313,16483,33756,39611,-7476,39040,68180,11065,93658,-66836,-12703,33764,-39613,7502,58262,5715,7858},
{0,-35338,0,57018,-2161,-2968,22144,469,6503,-75914,1051,1019,20190,2865,-3039,-52146,-2095,6784,-77718,1102,1107,37511,1198,2974,-58202,-3787,-5807,41432,-76405,-7383,88564,68299,16480,33756,39611,-7476,39040,68180,11065,93658,-66829,-12703,33764,-39613,7502,59366,6056,7932},
{0,-37779,0,57019,-2238,-2966,22435,468,6352,-75493,1026,987,11971,3125,-2633,-52902,-2090,6677,-79390,1088,1131,39375,1120,3183,-58800,-3959,-6066,41445,-76444,-7364,88610,68285,16478,33756,39611,-7476,39040,68180,11065,93658,-66822,-12702,33764,-39613,7502,60471,6399,8002},
{0,-39811,0,57020,-2306,-2943,23719,494,6167,-77356,1003,1002,8505,3240,-2332,-54316,-2097,6538,-79768,1069,1119,40967,1059,3348,-59583,-4123,-6302,41450,-76457,-7358,88672,68266,16474,33756,39611,-7476,39040,68180,11065,93659,-66812,-12702,33764,-39613,7502,61423,6704,8032},
{0,-41844,0,57021,-2375,-2920,25002,517,5981,-79219,979,1017,5039,3346,-2028,-55731,-2103,6400,-80146,1049,1108,42559,1000,3513,-60366,-4286,-6540,41454,-76471,-7351,88733,68247,16470,33756,39611,-7476,39040,68180,11065,93660,-66803,-12701,33764,-39613,7502,62375,7010,8060},
{0,-43245,0,57021,-2436,-2875,26072,558,6073,-83549,573,641,8244,3909,-1722,-54993,-2038,6280,-82266,1028,1133,43711,1081,3534,-61266,-4453,-6738,41450,-76457,-7358,88808,68225,16465,33756,39611,-7476,39040,68180,11065,93662,-66791,-12701,33764,-39613,7502,62758,7247,8059},
{0,-44645,0,57022,-2496,-2829,27143,600,6165,-87881,182,249,11449,4482,-1435,-54255,-1974,6159,-84386,1006,1157,44862,1163,3554,-62166,-4619,-6937,41445,-76444,-7364,88883,68202,16460,33756,39611,-7476,39040,68180,11065,93664,-66780,-12700,33764,-39613,7502,63142,7484,8058},
{0,-45410,0,57023,-2547,-2764,27383,661,6710,-90838,-696,-897,13985,5933,-888,-54106,-1934,6053,-85525,987,1162,45089,1366,3358,-63142,-4777,-7106,41432,-76405,-7383,88969,68176,16455,33756,39611,-7476,39040,68180,11065,93666,-66767,-12700,33764,-39613,7502,63195,7670,8034},
{0,-46174,0,57023,-2598,-2698,27623,724,7255,-93804,-1541,-2068,16515,7397,-377,-53957,-1895,5946,-86663,967,1167,45316,1569,3162,-64118,-4934,-7276,41420,-76365,-7401,89056,68149,16449,33756,39611,-7476,39040,68180,11065,93669,-66754,-12699,33764,-39613,7502,63248,7856,8010},
{0,-46403,0,57024,-2639,-2614,27223,788,8058,-95779,-2563,-3640,18538,9305,223,-54225,-1868,5833,-87200,948,1157,44708,1797,2823,-65143,-5068,-7421,41399,-76302,-7431,89152,68120,16442,33756,39611,-7476,39040,68180,11065,93673,-66739,-12699,33764,-39613,7502,63196,8003,7962},
{0,-46633,0,57024,-2679,-2530,26823,848,8861,-97769,-3554,-5232,20554,11225,785,-54492,-1840,5720,-87738,929,1147,44100,2028,2486,-66168,-5201,-7567,41378,-76239,-7461,89249,68090,16436,33756,39611,-7476,39040,68180,11065,93677,-66724,-12698,33764,-39613,7502,63144,8150,7916},
{0,-46419,0,57024,-2709,-2430,25912,881,9671,-98972,-4507,-6834,22157,13146,1292,-54999,-1811,5581,-88062,907,1127,42749,2198,2090,-67222,-5296,-7681,41351,-76154,-7501,89354,68058,16428,33756,39611,-7476,39040,68180,11065,93682,-66708,-12698,33764,-39613,7502,63039,8247,7848},
{0,-46205,0,57024,-2738,-2331,25000,907,10482,-100191,-5441,-8448,23755,15075,1770,-55507,-1781,5441,-88386,884,1107,41398,2374,1697,-68276,-5389,-7796,41323,-76069,-7541,89460,68025,16421,33756,39611,-7476,39040,68180,11065,93688,-66691,-12698,33764,-39613,7502,62934,8345,7780},
{0,-45540,0,57024,-2754,-2217,23642,879,11027,-100630,-6172,-9678,24969,16552,2081,-56087,-1738,5258,-88764,854,1078,39281,2437,1337,-69341,-5415,-7851,41289,-75964,-7591,89573,67990,16413,33756,39611,-7476,39040,68180,11065,93695,-66674,-12698,33764,-39613,7502,62795,8357,7686},
{0,-44875,0,57024,-2771,-2104,22284,844,11572,-101079,-6898,-10912,26181,18033,2374,-56668,-1694,5076,-89141,824,1050,37164,2509,979,-70406,-5440,-7905,41255,-75859,-7640,89686,67955,16405,33756,39611,-7476,39040,68180,11065,93702,-66656,-12697,33764,-39613,7502,62656,8370,7592},
{0,-43751,0,57024,-2767,-1984,20548,744,11590,-100706,-7260,-11385,27021,18594,2420,-57094,-1626,4838,-89836,784,1014,34196,2451,740,-71465,-5372,-7868,41215,-75735,-7698,89806,67918,16396,33756,39611,-7476,39040,68180,11065,93711,-66637,-12697,33764,-39613,7502,62488,8259,7462},
{0,-42628,0,57023,-2764,-1863,18812,643,11606,-100334,-7624,-11856,27861,19155,2462,-57520,-1557,4600,-90531,744,978,31228,2401,500,-72524,-5304,-7829,41175,-75612,-7755,89925,67880,16387,33756,39611,-7476,39040,68180,11065,93720,-66619,-12697,33764,-39613,7502,62321,8149,7332},
{0,-41080,0,57022,-2735,-1740,16812,480,10572,-99095,-7096,-10760,28361,17707,2100,-57503,-1456,4302,-91783,692,935,27240,2246,443,-73558,-5188,-7737,41130,-75471,-7821,90051,67841,16378,33756,39611,-7476,39040,68180,11065,93730,-66599,-12698,33764,-39613,7502,62117,7978,7172},
{0,-39533,0,57022,-2705,-1616,14810,337,9536,-97862,-6555,-9671,28855,16257,1747,-57485,-1355,4005,-93036,640,891,23252,2093,380,-74593,-5072,-7644,41086,-75331,-7886,90176,67801,16369,33756,39611,-7476,39040,68180,11065,93741,-66579,-12698,33764,-39613,7502,61913,7808,7011},
{0,-37653,0,57020,-2652,-1491,12499,186,7830,-95893,-5323,-7573,28978,13396,1214,-56679,-1218,3650,-95008,576,838,17938,1882,546,-75583,-4932,-7517,41037,-75176,-7958,90306,67760,16359,33756,39611,-7476,39040,68180,11065,93754,-66558,-12698,33764,-39613,7502,61662,7608,6825},
{0,-35773,0,57019,-2599,-1365,10185,75,6121,-93952,-4051,-5501,29085,10535,686,-55872,-1085,3293,-96980,513,783,12625,1663,700,-76572,-4793,-7389,40988,-75021,-8029,90436,67719,16349,33756,39611,-7476,39040,68180,11065,93767,-66537,-12699,33764,-39613,7502,61410,7409,6638},
{0,-33702,0,57016,-2525,-1238,7553,-5,4801,-91527,-3081,-4007,28833,8341,356,-53525,-914,2888,-100094,437,716,6613,1395,958,-77488,-4642,-7236,40935,-74853,-8106,90569,67676,16339,33756,39611,-7476,39040,68180,11065,93783,-66515,-12699,33764,-39613,7502,61093,7194,6429},
{0,-31631,0,57012,-2450,-1111,4920,-49,3480,-89118,-2075,-2538,28574,6149,22,-51178,-752,2479,-103208,363,647,602,1112,1199,-78404,-4491,-7080,40883,-74685,-8183,90703,67633,16329,33756,39611,-7476,39040,68180,11065,93798,-66493,-12700,33764,-39613,7502,60775,6981,6218},
{0,-29532,0,57011,-2357,-984,2109,-78,2752,-86395,-1686,-1961,28057,5144,-92,-47807,-581,2036,-106750,284,555,-5217,776,1380,-79211,-4335,-6902,40827,-74507,-8265,90839,67589,16318,33756,39611,-7476,39040,68180,11065,93816,-66470,-12701,33764,-39613,7502,60363,6759,5987},
{0,-27433,0,57010,-2263,-856,-702,-86,2023,-83675,-1282,-1395,27539,4141,-212,-44435,-424,1588,-110292,209,461,-11035,430,1541,-80018,-4180,-6723,40772,-74328,-8347,90975,67544,16307,33756,39611,-7476,39040,68180,11065,93834,-66447,-12702,33764,-39613,7502,59950,6539,5754},
{0,-25452,0,57009,-2153,-728,-3537,-81,1443,-80842,-1011,-1043,26887,3412,-278,-40614,-276,1119,-113699,136,339,-16553,52,1630,-80642,-4027,-6521,40714,-74139,-8432,91112,67499,16296,33756,39611,-7476,39040,68180,11065,93855,-66423,-12704,33764,-39613,7502,59384,6315,5503},
{0,-23472,0,57008,-2042,-600,-6372,-61,862,-78011,-729,-698,26235,2684,-348,-36793,-146,645,-117105,67,215,-22072,-330,1698,-81265,-3875,-6318,40656,-73951,-8517,91250,67453,16285,33756,39611,-7476,39040,68180,11065,93876,-66400,-12705,33764,-39613,7502,58819,6094,5249},
{0,-21713,0,57007,-1917,-473,-9146,-33,390,-75227,-565,-512,25541,2178,-385,-32754,-34,163,-120192,4,67,-27152,-722,1696,-81553,-3734,-6090,40597,-73755,-8605,91388,67407,16273,33756,39611,-7476,39040,68180,11065,93901,-66375,-12707,33764,-39613,7502,57967,5870,4979},
{0,-19954,0,57006,-1792,-345,-11920,8,-81,-72443,-397,-330,24846,1672,-426,-28714,59,-322,-123278,-53,-83,-32233,-1112,1675,-81840,-3594,-5862,40538,-73560,-8693,91527,67361,16262,33756,39611,-7476,39040,68180,11065,93925,-66351,-12709,33764,-39613,7502,57115,5651,4706},
{0,-18474,0,57005,-1654,-219,-14562,54,-480,-69854,-327,-257,24194,1335,-448,-24573,131,-802,-125981,-102,-251,-36732,-1492,1596,-81598,-3473,-5604,40477,-73359,-8783,91665,67314,16250,33756,39611,-7476,39040,68180,11065,93953,-66326,-12711,33764,-39613,7502,55818,5430,4419},
{0,-16994,0,57004,-1516,-93,-17204,110,-877,-67266,-255,-184,23543,997,-473,-20432,182,-1285,-128684,-147,-419,-41231,-1868,1500,-81357,-3352,-5347,40417,-73157,-8873,91803,67266,16238,33756,39611,-7476,39040,68180,11065,93980,-66301,-12714,33764,-39613,7502,54520,5215,4127},
{0,-15813,0,57003,-1368,31,-19684,170,-1231,-64947,-254,-176,22986,773,-491,-16269,211,-1749,-130969,-182,-599,-45011,-2218,1367,-80802,-3234,-5071,40356,-72952,-8964,91940,67219,16226,33756,39611,-7476,39040,68180,11065,94012,-66275,-12716,33764,-39613,7502,53066,4999,3823},
{0,-14631,0,57002,-1220,156,-22163,239,-1584,-62628,-254,-167,22429,549,-510,-12106,220,-2213,-133254,-213,-778,-48792,-2563,1220,-80248,-3116,-4796,40296,-72747,-9054,92077,67171,16214,33756,39611,-7476,39040,68180,11065,94043,-66249,-12719,33764,-39613,7502,51612,4789,3514},
{0,-13746,0,57001,-1063,278,-24456,311,-1916,-60639,-290,-185,22012,384,-531,-8007,209,-2647,-135076,-237,-961,-51720,-2875,1060,-79523,-2990,-4509,40235,-72540,-9145,92212,67123,16202,33756,39611,-7476,39040,68180,11065,94079,-66223,-12723,33764,-39613,7502,50395,4579,3195},
{0,-12861,0,57000,-907,400,-26749,391,-2246,-58651,-327,-202,21594,219,-553,-3908,180,-3081,-136899,-258,-1143,-54649,-3181,891,-78798,-2864,-4223,40175,-72333,-9236,92346,67075,16189,33756,39611,-7476,39040,68180,11065,94115,-66197,-12726,33764,-39613,7502,49178,4374,2873},
{0,-12256,0,57000,-745,518,-28858,475,-2567,-57001,-368,-221,21333,67,-581,53,134,-3474,-138250,-275,-1319,-55867,-3446,759,-77967,-2726,-3927,40115,-72126,-9326,92478,67026,16177,33756,39611,-7476,39040,68180,11065,94155,-66170,-12730,33764,-39613,7502,48713,4174,2523},
{0,-11650,0,56999,-582,637,-30968,566,-2887,-55350,-409,-239,21071,-85,-610,4015,72,-3865,-139601,-289,-1496,-57086,-3709,625,-77135,-2587,-3634,40056,-71919,-9417,92609,66978,16164,33756,39611,-7476,39040,68180,11065,94196,-66143,-12734,33764,-39613,7502,48247,3974,2173},
{0,-11303,0,56999,-416,752,-32892,659,-3198,-54053,-447,-254,20985,-230,-648,7753,0,-4207,-140443,-302,-1658,-56070,-3931,577,-76235,-2435,-3332,39997,-71714,-9506,92736,66930,16151,33756,39611,-7476,39040,68180,11065,94241,-66115,-12739,33764,-39613,7502,48146,3780,1762},
{0,-10957,0,56998,-250,867,-34816,758,-3506,-52757,-485,-269,20900,-375,-685,11492,-85,-4547,-141285,-314,-1820,-55055,-4153,532,-75335,-2281,-3033,39939,-71509,-9594,92863,66881,16138,33756,39611,-7476,39040,68180,11065,94287,-66088,-12744,33764,-39613,7502,48044,3584,1351},
{0,-10845,0,56998,-83,978,-36579,856,-3799,-51775,-520,-283,20983,-510,-735,14883,-173,-4832,-141515,-331,-1956,-52169,-4330,586,-74390,-2113,-2727,39882,-71307,-9681,92984,66833,16125,33756,39611,-7476,39040,68180,11065,94339,-66060,-12749,33764,-39613,7502,48133,3386,875},
{0,-10734,0,56998,85,1088,-38342,959,-4089,-50794,-556,-297,21066,-645,-784,18275,-269,-5113,-141745,-348,-2092,-49283,-4506,644,-73446,-1943,-2423,39825,-71106,-9767,93105,66785,16111,33756,39611,-7476,39040,68180,11065,94390,-66032,-12755,33764,-39613,7502,48222,3184,401},
{0,-10798,0,56998,252,1194,-40021,1060,-4354,-49984,-587,-308,21256,-765,-851,21175,-359,-5333,-141242,-374,-2190,-44888,-4621,798,-72476,-1757,-2112,39770,-70909,-9851,93218,66737,16098,33756,39611,-7476,39040,68180,11065,94448,-66004,-12761,33764,-39613,7502,48429,2958,-85},
{0,-10863,0,56998,418,1299,-41701,1166,-4617,-49173,-619,-319,21446,-884,-917,24074,-454,-5550,-140739,-402,-2288,-40493,-4730,956,-71505,-1569,-1804,39716,-70713,-9935,93332,66690,16084,33756,39611,-7476,39040,68180,11065,94506,-65976,-12768,33764,-39613,7502,48635,2728,-570},
{0,-11074,0,56998,582,1399,-43330,1264,-4839,-48473,-644,-328,21722,-983,-1011,26354,-532,-5698,-139429,-441,-2336,-34920,-4755,1186,-70525,-1365,-1490,39664,-70524,-10015,93437,66643,16070,33756,39611,-7476,39040,68180,11065,94572,-65948,-12775,33764,-39613,7502,48923,2458,-1018},
{0,-11284,0,56998,746,1499,-44959,1365,-5060,-47773,-670,-335,21997,-1082,-1105,28633,-613,-5845,-138119,-482,-2383,-29347,-4767,1416,-69545,-1160,-1178,39612,-70335,-10095,93541,66596,16056,33756,39611,-7476,39040,68180,11065,94637,-65919,-12783,33764,-39613,7502,49211,2184,-1464},
{0,-11665,0,56999,905,1592,-46514,1455,-5228,-47239,-690,-341,22397,-1154,-1234,30204,-668,-5923,-135995,-533,-2375,-22903,-4685,1678,-68569,-937,-860,39563,-70156,-10170,93636,66550,16041,33756,39611,-7476,39040,68180,11065,94711,-65891,-12792,33764,-39613,7502,49560,1870,-1870},
{0,-12045,0,57000,1064,1686,-48069,1546,-5395,-46706,-709,-346,22797,-1226,-1363,31774,-724,-5999,-133871,-583,-2365,-16459,-4587,1934,-67594,-712,-544,39514,-69976,-10246,93730,66504,16027,33756,39611,-7476,39040,68180,11065,94785,-65862,-12800,33764,-39613,7502,49907,1552,-2273},
{0,-12626,0,57000,1215,1772,-49516,1628,-5528,-46416,-726,-352,23370,-1278,-1507,32560,-753,-6036,-130919,-642,-2310,-9466,-4426,2195,-66639,-469,-222,39469,-69807,-10317,93811,66459,16011,33756,39611,-7476,39040,68180,11065,94869,-65833,-12810,33764,-39613,7502,50307,1196,-2640},
{0,-13207,0,57001,1366,1858,-50964,1711,-5659,-46126,-743,-358,23943,-1330,-1651,33346,-782,-6073,-127966,-699,-2253,-2475,-4248,2443,-65684,-225,98,39423,-69639,-10387,93892,66415,15996,33756,39611,-7476,39040,68180,11065,94953,-65804,-12821,33764,-39613,7502,50704,837,-3002},
{0,-14025,0,57005,1508,1937,-52265,1784,-5764,-46174,-759,-367,24750,-1364,-1800,33295,-782,-6087,-124183,-760,-2159,4727,-4033,2675,-64772,38,425,39382,-69483,-10452,93958,66372,15980,33756,39611,-7476,39040,68180,11065,95048,-65775,-12832,33764,-39613,7502,51150,442,-3331},
{0,-14844,0,57009,1650,2015,-53567,1858,-5868,-46223,-776,-376,25558,-1399,-1949,33244,-782,-6100,-120399,-817,-2063,11927,-3802,2891,-63860,303,749,39340,-69327,-10516,94024,66329,15964,33756,39611,-7476,39040,68180,11065,95144,-65747,-12844,33764,-39613,7502,51594,43,-3655},
{0,-15946,0,57011,1780,2086,-54671,1920,-5948,-46716,-794,-389,26665,-1415,-2097,32367,-755,-6099,-115815,-870,-1937,18829,-3560,3070,-63009,587,1081,39303,-69186,-10575,94072,66288,15947,33756,39611,-7476,39040,68180,11065,95253,-65718,-12858,33764,-39613,7502,52091,-389,-3949},
{0,-17048,0,57012,1911,2156,-55776,1982,-6028,-47210,-812,-403,27773,-1433,-2246,31491,-727,-6096,-111231,-917,-1809,25729,-3308,3232,-62159,874,1412,39266,-69045,-10633,94120,66248,15930,33756,39611,-7476,39040,68180,11065,95363,-65689,-12871,33764,-39613,7502,52586,-824,-4238},
{0,-18485,0,57014,2027,2217,-56659,2030,-6082,-48224,-831,-424,29237,-1432,-2392,30078,-682,-6077,-106229,-952,-1669,31297,-3094,3329,-61411,1181,1751,39233,-68920,-10684,94145,66210,15912,33756,39611,-7476,39040,68180,11065,95489,-65661,-12887,33764,-39613,7502,53148,-1292,-4499},
{0,-19923,0,57015,2143,2278,-57541,2078,-6136,-49238,-851,-445,30701,-1433,-2539,28664,-636,-6057,-101227,-979,-1528,36864,-2876,3414,-60663,1489,2089,39200,-68796,-10736,94171,66172,15893,33756,39611,-7476,39040,68180,11065,95616,-65632,-12903,33764,-39613,7502,53709,-1763,-4755},
{0,-21740,0,57017,2243,2330,-58198,2109,-6161,-50808,-871,-473,32558,-1413,-2683,27093,-584,-6013,-96324,-989,-1393,39958,-2749,3413,-60082,1819,2440,39173,-68690,-10779,94170,66137,15873,33756,39611,-7476,39040,68180,11065,95764,-65604,-12922,33764,-39613,7502,54376,-2268,-4978},
{0,-23557,0,57018,2343,2381,-58855,2140,-6186,-52378,-892,-502,34415,-1395,-2828,25522,-532,-5969,-91420,-993,-1258,43052,-2622,3409,-59501,2151,2789,39145,-68584,-10823,94169,66103,15852,33756,39611,-7476,39040,68180,11065,95913,-65576,-12941,33764,-39613,7502,55043,-2776,-5195},
{0,-25758,0,57020,2425,2423,-59375,2154,-6175,-54350,-909,-536,36607,-1355,-2973,24233,-487,-5894,-87259,-982,-1145,42604,-2627,3298,-59231,2501,3157,39123,-68498,-10858,94135,66073,15829,33756,39611,-7476,39040,68180,11065,96090,-65549,-12963,33764,-39613,7502,55924,-3318,-5375},
{0,-27959,0,57021,2506,2464,-59896,2168,-6164,-56323,-926,-570,38800,-1318,-3119,22944,-443,-5818,-83098,-967,-1033,42156,-2631,3187,-58961,2853,3525,39101,-68413,-10893,94101,66043,15806,33756,39611,-7476,39040,68180,11065,96268,-65522,-12986,33764,-39613,7502,56804,-3863,-5548},
{0,-30429,0,57022,2567,2494,-60446,2166,-6104,-58360,-934,-602,41163,-1256,-3272,22345,-417,-5703,-80371,-943,-955,35983,-2814,2894,-58961,3229,3918,39084,-68349,-10918,94026,66019,15779,33756,39611,-7476,39040,68180,11065,96486,-65497,-13013,33764,-39613,7502,57807,-4445,-5677},
{0,-32899,0,57023,2628,2524,-60997,2164,-6044,-60398,-941,-634,43527,-1198,-3426,21746,-392,-5587,-77643,-917,-877,29809,-2979,2591,-58962,3605,4311,39068,-68286,-10944,93952,65995,15752,33756,39611,-7476,39040,68180,11065,96704,-65471,-13040,33764,-39613,7502,58809,-5029,-5798},
{0,-35340,0,57024,2667,2543,-61882,2147,-5916,-61833,-933,-647,45703,-1113,-3600,22074,-389,-5422,-76865,-889,-837,21194,-3164,2159,-59030,4026,4726,39058,-68246,-10960,93824,65979,15718,33756,39611,-7476,39040,68180,11065,96988,-65449,-13074,33764,-39613,7502,59639,-5657,-5866},
{0,-37781,0,57024,2705,2562,-62766,2130,-5787,-63268,-924,-661,47879,-1031,-3777,22401,-386,-5256,-76087,-860,-796,12577,-3311,1712,-59099,4447,5141,39048,-68207,-10976,93697,65963,15685,33756,39611,-7476,39040,68180,11065,97271,-65426,-13109,33764,-39613,7502,60469,-6284,-5926},
{0,-39814,0,57025,2718,2568,-64255,2092,-5556,-63442,-892,-639,49486,-918,-4001,23702,-402,-5022,-77638,-827,-789,8777,-3307,1350,-59359,4933,5590,39044,-68193,-10982,93500,65959,15641,33756,39611,-7476,39040,68180,11065,97684,-65408,-13153,33764,-39613,7502,61051,-6966,-5949},
{0,-41847,0,57025,2731,2574,-65744,2051,-5326,-63617,-860,-618,51093,-809,-4228,25003,-414,-4788,-79188,-794,-781,4976,-3289,989,-59621,5419,6039,39041,-68180,-10987,93303,65954,15596,33756,39611,-7476,39040,68180,11065,98096,-65391,-13198,33764,-39613,7502,61633,-7647,-5967},
}
local clip={Duration=2.0,Loop=true,Source="Quaternius original GLB",Role="Walk_Carry_Loop",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/dragon/Attack.luau
addModule(modules,{"world","dragon","Attack"},[====[
-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.
return {["duration"]=1.70833,["tracks"]={["5"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,-4.94982,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.29001,-3.31786,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-6.70554e-08,-5.88536,-1.09886,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-6.16163,-0.330842,0.980339,-0.197319,2.03727e-10,0.122752,0.60987,0.782937,-0.154488,-0.767544,0.622101},{6.70554e-08,-7.25869,-2.63102,0.980339,-0.197319,5.58794e-09,0.114596,0.56935,0.814069,-0.160631,-0.798064,0.580768},{-3.35276e-08,-8.35576,-4.93121,0.98034,-0.197319,2.04891e-08,0.106133,0.527304,0.843022,-0.166344,-0.826448,0.537879},{-1.00583e-07,-8.4007,-5.02543,0.980339,-0.197319,1.11759e-08,0.105781,0.525551,0.84416,-0.166569,-0.827564,0.536091},{-6.70554e-08,-6.96165,-4.84213,0.980339,-0.197319,6.51926e-09,0.113155,0.56219,0.819231,-0.16165,-0.803124,0.573464},{0,-4.94982,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759}}},["2"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.969565,-0.157427,0.187514,-0.109396,0.406618,0.907025,-0.219037,-0.899932,0.377021},{1.67638e-08,-6.70554e-08,3.7976,0.968503,-0.156791,0.19344,-0.108933,0.431785,0.895374,-0.223911,-0.888244,0.401105},{-6.70554e-08,2.01166e-07,3.7976,0.964744,-0.154984,0.212719,-0.116013,0.475057,0.872274,-0.236242,-0.866199,0.440328},{-3.35276e-08,0,3.7976,0.956384,-0.154907,0.247659,-0.145733,0.481749,0.864106,-0.253165,-0.862509,0.438162},{-1.67638e-08,2.68221e-07,3.7976,0.930442,-0.23634,0.28004,-0.262846,0.102035,0.959427,-0.255325,-0.966298,0.0328172},{-6.70554e-08,-2.68221e-07,3.7976,0.908752,-0.379614,0.173387,-0.394948,-0.648019,0.65122,-0.134855,-0.660276,-0.738816},{-1.3411e-07,0,3.7976,0.908783,-0.384901,0.161134,-0.39851,-0.686121,0.608628,-0.123704,-0.617325,-0.776922},{-3.35276e-08,-1.3411e-07,3.7976,0.931962,-0.295766,0.209689,-0.295493,-0.284528,0.911991,-0.210073,-0.911902,-0.352566},{-3.35276e-08,-1.3411e-07,3.7976,0.969565,-0.157427,0.187514,-0.109396,0.406618,0.907025,-0.219037,-0.899932,0.377021}}},["6"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{6.70554e-08,2.68221e-07,5.10035,0.220169,-0.957095,-0.188399,0.90994,0.271104,-0.313867,0.351476,-0.102328,0.930588},{6.70554e-08,2.68221e-07,5.10035,0.208275,-0.948382,-0.239151,0.829619,0.300806,-0.470371,0.518029,-0.100438,0.849446},{-3.35276e-08,-6.70554e-08,5.10035,0.162543,-0.93269,-0.321976,0.614991,0.350943,-0.706134,0.771599,-0.083235,0.63064},{-6.70554e-08,-5.86732e-08,5.10035,0.127243,-0.92598,-0.355486,0.480024,0.371121,-0.794887,0.867978,-0.0694981,0.491715},{0,0,5.10035,0.118577,-0.929674,-0.348779,0.450915,0.363366,-0.815255,0.884656,-0.0605993,0.462291},{0,-1.3411e-07,5.10035,0.23028,-0.944384,-0.234755,0.874033,0.306782,-0.376763,0.427828,-0.118423,0.896069},{1.3411e-07,0,5.10035,0.318332,-0.928982,-0.188833,0.918676,0.351453,-0.180319,0.233879,-0.116075,0.965312},{6.70554e-08,2.68221e-07,5.10035,0.279483,-0.940207,-0.194681,0.91179,0.323431,-0.253043,0.300879,-0.106786,0.947665},{6.70554e-08,2.68221e-07,5.10035,0.220169,-0.957095,-0.188399,0.90994,0.271104,-0.313867,0.351476,-0.102328,0.930588}}},["1"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-5.36443e-07,-6.70554e-08,4.80781,0.465714,-0.397752,0.790508,0.65583,0.75488,-0.0065457,-0.594135,0.521487,0.612416},{0,3.35276e-08,4.80781,0.403914,-0.37323,0.835196,0.625649,0.77878,0.0454446,-0.667395,0.504184,0.548071},{3.35276e-07,0,4.80781,0.28441,-0.335053,0.898249,0.559429,0.818886,0.12832,-0.778557,0.46601,0.420337},{-1.3411e-07,3.35276e-08,4.80781,0.234493,-0.322687,0.916998,0.530827,0.832754,0.1573,-0.814393,0.449881,0.366566},{0,3.35276e-08,4.8078,0.261248,-0.353909,0.898052,0.611711,0.780395,0.129591,-0.746699,0.515493,0.420367},{2.68221e-07,-1.3411e-07,4.80781,0.582214,-0.721059,0.375634,0.808847,0.560526,-0.177699,-0.0824209,0.40729,0.909572},{1.3411e-07,-1.3411e-07,4.80781,0.632972,-0.767488,-0.101531,0.741806,0.638794,-0.204124,0.22152,0.0538888,0.973666},{5.36443e-07,-1.67638e-08,4.80781,0.665992,-0.627556,0.403272,0.685168,0.728383,0.00194647,-0.294958,0.275013,0.915078},{-5.36443e-07,-6.70554e-08,4.80781,0.465714,-0.397752,0.790508,0.65583,0.75488,-0.0065457,-0.594135,0.521487,0.612416}}},["7"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-5.36443e-07,5.36443e-07,3.87696,0.220576,-0.810685,0.542343,0.875768,-0.0801763,-0.476029,0.429392,0.579967,0.692286},{8.04661e-07,1.3411e-07,3.87696,0.259211,-0.804493,0.534416,0.878838,-0.0330215,-0.475977,0.400567,0.593044,0.698459},{1.3411e-07,-2.01166e-07,3.87696,0.325361,-0.790046,0.519584,0.879281,0.0506372,-0.473605,0.347859,0.610953,0.711147},{6.70554e-08,6.70554e-08,3.87696,0.343944,-0.788114,0.510469,0.8798,0.0805217,-0.468474,0.328107,0.610239,0.721078},{0,0,3.87696,0.207343,-0.851727,0.481217,0.912046,-0.00960481,-0.409976,0.353809,0.523898,0.774822},{-8.04661e-07,-2.68221e-07,3.87696,0.0922174,-0.978608,0.183908,0.992382,0.0751721,-0.0976075,0.0816948,0.191508,0.978085},{4.02332e-07,4.02332e-07,3.87696,0.148413,-0.988671,-0.0224278,0.988868,0.148612,-0.00745572,0.0107043,-0.0210716,0.999721},{0,0,3.87696,0.164456,-0.961258,0.22122,0.953667,0.0976679,-0.284571,0.25194,0.257769,0.932782},{-5.36443e-07,5.36443e-07,3.87696,0.220576,-0.810685,0.542343,0.875768,-0.0801763,-0.476029,0.429392,0.579967,0.692286}}},["8"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{1.10288,-0.968026,3.25436,0.812169,-0.164631,0.559713,0.485193,0.723352,-0.491274,-0.32399,0.670566,0.667362},{1.04489,-0.969107,3.20405,0.801578,-0.0754916,0.593105,0.479583,0.673558,-0.562422,-0.357033,0.735269,0.576114},{0.943399,-0.970998,3.11602,0.758409,0.10291,0.643603,0.493948,0.5535,-0.670562,-0.425242,0.826466,0.368947},{0.904434,-0.971219,3.08189,0.681966,0.217686,0.698237,0.559361,0.459836,-0.689686,-0.47121,0.860909,0.191827},{0.917922,-0.923111,3.14415,0.601134,0.172878,0.780225,0.698258,0.361228,-0.618021,-0.388682,0.916312,0.0964335},{0.943052,-0.846054,3.62388,0.779609,-0.206801,0.591136,0.549392,0.678944,-0.487036,-0.300629,0.704463,0.642926},{0.897705,-0.897067,3.97595,0.922064,-0.384109,0.0475245,0.387023,0.913985,-0.121838,0.0033622,0.130735,0.991412},{0.98299,-0.926551,3.6756,0.899765,-0.33393,0.280915,0.411976,0.862277,-0.294541,-0.143871,0.380748,0.913418},{1.10288,-0.968026,3.25436,0.812169,-0.164631,0.559713,0.485193,0.723352,-0.491274,-0.32399,0.670566,0.667362}}},["9"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0.177817,-0.156074,2.85685,0.822607,0.0610726,0.565321,0.279987,0.821825,-0.496197,-0.494899,0.566457,0.658939},{0.154734,-0.16296,3.02451,0.796978,0.134355,0.588876,0.274644,0.787721,-0.551423,-0.537956,0.601203,0.590896},{0.142675,-0.199882,3.35094,0.735271,0.264861,0.623879,0.281292,0.718216,-0.636427,-0.616645,0.643439,0.45358},{0.228172,-0.295444,3.56765,0.678728,0.316031,0.662912,0.316688,0.688477,-0.652463,-0.662598,0.652781,0.367205},{0.436084,-0.514081,3.45925,0.670934,0.204118,0.71287,0.442823,0.660822,-0.605988,-0.594773,0.722253,0.35298},{0.453318,-0.511681,3.20661,0.875854,-0.0621671,0.478554,0.27084,0.884083,-0.380845,-0.399406,0.463176,0.791165},{0.411472,-0.43257,3.06486,0.99336,-0.113844,-0.016621,0.112552,0.991535,-0.0647276,0.0238493,0.062427,0.997765},{0.317705,-0.319131,2.97856,0.965125,-0.0842269,0.24787,0.151723,0.951561,-0.267416,-0.21334,0.295697,0.931155},{0.177817,-0.156074,2.85685,0.822607,0.0610726,0.565321,0.279987,0.821825,-0.496197,-0.494899,0.566457,0.658939}}},["23"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,-0.0777039,0.0682742,-0.994636,-0.10221,0.99185,0.0760679,0.991723,0.107573,-0.0700925},{1.67638e-08,-6.70554e-08,3.7976,-0.113752,0.185729,-0.975994,-0.0182212,0.981816,0.18896,0.993342,0.0392784,-0.1083},{-6.70554e-08,2.01166e-07,3.7976,-0.141326,0.398113,-0.906384,0.181711,0.91045,0.371566,0.973143,-0.112188,-0.201012},{-3.35276e-08,0,3.7976,-0.0962412,0.475545,-0.874411,0.37474,0.831162,0.410779,0.922121,-0.288143,-0.258198},{-1.67638e-08,2.68221e-07,3.7976,0.0614766,0.199221,-0.978024,0.480706,0.852837,0.203936,0.874724,-0.48268,-0.0433372},{-6.70554e-08,-2.68221e-07,3.7976,0.175666,-0.103203,-0.979025,0.540921,0.841031,0.00840062,0.822524,-0.531051,0.203565},{-1.3411e-07,0,3.7976,0.179679,-0.115348,-0.976939,0.543189,0.83961,0.000770204,0.820159,-0.530801,0.213516},{-3.35276e-08,-1.3411e-07,3.7976,0.0890709,-0.0180167,-0.995862,0.286226,0.958126,0.0082663,0.954013,-0.285778,0.0904978},{-3.35276e-08,-1.3411e-07,3.7976,-0.0777039,0.0682742,-0.994636,-0.10221,0.99185,0.0760679,0.991723,0.107573,-0.0700925}}},["4"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-2.01166e-07,0,4.8923,0.910719,0.0547092,-0.409387,-0.413005,0.1106,-0.903988,-0.00417811,0.992358,0.123321},{-1.67638e-07,0,4.8923,0.833415,0.116582,-0.540211,-0.549099,0.0640841,-0.833297,-0.0625287,0.991111,0.117424},{2.01166e-07,2.01166e-07,4.8923,0.642799,0.201323,-0.739106,-0.748065,-0.0427863,-0.662245,-0.164949,0.97859,0.1231},{-6.70554e-08,2.68221e-07,4.8923,0.563583,0.208808,-0.799233,-0.801773,-0.0946114,-0.590093,-0.198833,0.973369,0.114095},{1.67638e-07,3.35276e-08,4.8923,0.725497,0.0811237,-0.683427,-0.686217,0.00946688,-0.727335,-0.0525342,0.996659,0.0625367},{3.35276e-08,0,4.8923,0.818902,-0.0166423,-0.573692,-0.569373,0.102197,-0.815702,0.0722047,0.994625,0.0742136},{8.38192e-07,2.68221e-07,4.8923,0.821648,-0.0201932,-0.569637,-0.564813,0.105606,-0.818434,0.0766837,0.994203,0.0753653},{-2.01166e-07,2.68221e-07,4.8923,0.863091,0.01129,-0.504922,-0.503138,0.106104,-0.857668,0.0438912,0.994291,0.0972579},{-2.01166e-07,0,4.8923,0.910719,0.0547092,-0.409387,-0.413005,0.1106,-0.903988,-0.00417811,0.992358,0.123321}}},["3"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-2.34693e-07,5.36443e-07,4.20461,-0.878099,-0.0959764,-0.468755,0.0807577,-0.995349,0.0525152,-0.471616,0.0082579,0.881766},{-1.17347e-07,5.36443e-07,4.20461,-0.872202,-0.0904803,-0.480704,0.0902505,-0.995638,0.0236507,-0.480747,-0.0227556,0.876564},{0,0,4.20461,-0.833131,-0.0777134,-0.547589,0.106847,-0.994043,-0.0214889,-0.542657,-0.0764113,0.836471},{0,0,4.20461,-0.694215,-0.0629759,-0.717008,0.110862,-0.993633,-0.0200659,-0.711179,-0.0934191,0.696777},{0,0,4.20461,-0.171064,-0.0567574,-0.983624,0.07139,-0.996429,0.0450808,-0.98267,-0.0625093,0.174505},{2.68221e-07,2.68221e-07,4.20461,-0.0318928,-0.0651651,-0.997365,0.019423,-0.997724,0.0645675,-0.999303,-0.0173126,0.0330859},{4.69386e-07,0,4.20461,-0.0314427,-0.0652745,-0.997372,0.016785,-0.997759,0.0647707,-0.999365,-0.0147043,0.0324679},{-2.68221e-07,-5.36443e-07,4.20461,-0.448608,-0.0808989,-0.89006,0.0447058,-0.996679,0.0680571,-0.89261,-0.00925976,0.450735},{-2.34693e-07,5.36443e-07,4.20461,-0.878099,-0.0959764,-0.468755,0.0807577,-0.995349,0.0525152,-0.471616,0.0082579,0.881766}}},["24"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,5.36443e-07,5.62343,7.0544e-05,0.249153,0.968464,-0.981979,0.183049,-0.047021,-0.188992,-0.951008,0.244676},{0,-5.36443e-07,5.62343,0.00923172,0.283005,0.959074,-0.981977,0.183633,-0.0447345,-0.188777,-0.941375,0.2796},{2.68221e-07,0,5.62343,0.0312775,0.386769,0.921646,-0.982006,0.183708,-0.0437672,-0.186242,-0.903693,0.385555},{2.68221e-07,0,5.62343,0.0564254,0.556328,0.829045,-0.98275,0.177425,-0.0521737,-0.176119,-0.8118,0.556743},{8.04661e-07,5.36443e-07,5.62343,0.0363728,0.680127,0.732191,-0.991934,0.113594,-0.0562405,-0.121423,-0.72424,0.678774},{-2.68221e-07,5.36443e-07,5.62343,-0.0354145,0.580687,0.813357,-0.99741,0.0304376,-0.0651591,-0.0625936,-0.813558,0.578105},{2.68221e-07,0,5.62343,-0.0392988,0.572049,0.819277,-0.997433,0.0266641,-0.0664625,-0.0598651,-0.819786,0.569533},{0,5.36443e-07,5.62343,-0.0171531,0.444195,0.895766,-0.99351,0.0931841,-0.0652332,-0.112447,-0.891071,0.439713},{0,5.36443e-07,5.62343,7.0544e-05,0.249153,0.968464,-0.981979,0.183049,-0.047021,-0.188992,-0.951008,0.244676}}},["25"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.10272,0.777037,-0.621017,-0.867391,0.375575,0.32646,0.48691,0.505131,0.712574},{1.67638e-08,-6.70554e-08,3.7976,0.115549,0.770988,-0.626279,-0.880676,0.371132,0.2944,0.459411,0.517531,0.721875},{-6.70554e-08,2.01166e-07,3.7976,0.122371,0.76239,-0.635442,-0.907027,0.345818,0.240233,0.402899,0.546966,0.733826},{-3.35276e-08,0,3.7976,0.0698188,0.762468,-0.643247,-0.930011,0.282997,0.234503,0.360838,0.581855,0.728863},{-1.67638e-08,2.68221e-07,3.7976,-0.153457,0.751782,-0.641307,-0.889193,0.178032,0.421474,0.431029,0.634924,0.641159},{-6.70554e-08,-2.68221e-07,3.7976,-0.33965,0.727318,-0.596361,-0.799446,0.11079,0.590434,0.495504,0.677299,0.543821},{-1.3411e-07,0,3.7976,-0.260648,0.750737,-0.607006,-0.822648,0.15636,0.546628,0.505285,0.64183,0.576837},{-3.35276e-08,-1.3411e-07,3.7976,-0.0298321,0.778965,-0.626357,-0.864468,0.294481,0.407402,0.501802,0.553619,0.664605},{-3.35276e-08,-1.3411e-07,3.7976,0.10272,0.777037,-0.621017,-0.867391,0.375575,0.32646,0.48691,0.505131,0.712574}}},["26"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{2.68221e-07,-2.68221e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406},{-3.35276e-08,0,8.88873,0.318163,0.259985,0.911691,0.947785,-0.109367,-0.299572,0.021825,0.959399,-0.281207},{2.68221e-07,2.68221e-07,8.88873,0.19942,-0.191357,0.961048,0.979898,0.0446092,-0.194449,-0.0056625,0.980506,0.196406},{0,-5.36443e-07,8.88873,0.162993,-0.343645,0.924847,0.986232,0.0832898,-0.142864,-0.0279359,0.935399,0.35249},{6.70554e-08,0,8.88873,0.268569,0.0789435,0.96002,0.963096,-0.0404398,-0.266104,0.017816,0.996058,-0.0868909},{2.68221e-07,0,8.88873,0.379475,0.469117,0.797451,0.925123,-0.203658,-0.320423,0.012091,0.859333,-0.511274},{-2.68221e-07,5.36443e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406},{0,2.68221e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406},{2.68221e-07,-2.68221e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406}}},["27"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,-0.0321099,0.320768,0.946613,0.124315,0.941029,-0.314659,-0.991723,0.107574,-0.0700925},{1.67638e-08,-6.70554e-08,3.7976,0.018411,0.324813,0.945599,0.112119,0.939124,-0.324771,-0.993524,0.111999,-0.0191273},{-6.70554e-08,2.01166e-07,3.7976,0.106465,0.331294,0.937502,0.089563,0.935832,-0.340876,-0.990274,0.120257,0.0699613},{-3.35276e-08,0,3.7976,0.131877,0.328073,0.935402,0.0829007,0.936688,-0.340212,-0.987793,0.122412,0.0963302},{-1.67638e-08,2.68221e-07,3.7976,-0.0955254,0.184239,0.978229,0.126856,0.976963,-0.171613,-0.987311,0.107701,-0.116697},{-6.70554e-08,-2.68221e-07,3.7976,-0.32168,0.0361076,0.94616,0.129956,0.991499,0.00634521,-0.937888,0.125,-0.323638},{-1.3411e-07,0,3.7976,-0.330534,0.030197,0.943311,0.129211,0.991525,0.0135347,-0.934907,0.126359,-0.331635},{-3.35276e-08,-1.3411e-07,3.7976,-0.207928,0.152574,0.966171,0.139572,0.98228,-0.12508,-0.968135,0.108843,-0.225538},{-3.35276e-08,-1.3411e-07,3.7976,-0.0321099,0.320768,0.946613,0.124315,0.941029,-0.314659,-0.991723,0.107574,-0.0700925}}},["28"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{6.70554e-08,1.3411e-07,4.8923,0.781743,-0.0502348,0.621574,0.622859,0.111511,-0.774346,-0.0304132,0.992493,0.118462},{3.35276e-07,-6.70554e-08,4.8923,0.864273,-0.0701698,0.498105,0.502925,0.140023,-0.852912,-0.00989763,0.987659,0.156309},{-1.3411e-07,-1.3411e-07,4.8923,0.962353,-0.0952738,0.254558,0.268818,0.19522,-0.9432,0.0401676,0.976121,0.213482},{1.3411e-07,0,4.8923,0.98019,-0.110196,0.16457,0.184994,0.212628,-0.959462,0.0707366,0.9709,0.228801},{6.70554e-08,1.3411e-07,4.8923,0.884407,-0.240423,0.400027,0.433488,0.105526,-0.89496,0.172955,0.964915,0.197548},{-4.02332e-07,2.68221e-07,4.8923,0.716107,-0.334622,0.612551,0.641224,-0.0312824,-0.766716,0.275722,0.941833,0.192166},{-8.04661e-07,-2.68221e-07,4.8923,0.707958,-0.337559,0.620362,0.648473,-0.0372831,-0.760324,0.279783,0.940566,0.192503},{-2.68221e-07,0,4.8923,0.75009,-0.220174,0.623609,0.643604,0.0261354,-0.764912,0.152116,0.97511,0.161309},{6.70554e-08,1.3411e-07,4.8923,0.781743,-0.0502348,0.621574,0.622859,0.111511,-0.774346,-0.0304132,0.992493,0.118462}}},["29"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,-5.36443e-07,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{-2.01166e-07,-5.36443e-07,4.20461,-0.884077,0.117018,0.452453,-0.162675,-0.984653,-0.0632014,0.438114,-0.129478,0.889546},{0,-5.36443e-07,4.20461,-0.754135,0.16193,0.636443,-0.294192,-0.949743,-0.106952,0.587138,-0.267893,0.763873},{0,-5.36443e-07,4.20461,-0.540039,0.135153,0.830717,-0.344443,-0.936071,-0.0716252,0.76793,-0.324815,0.552067},{-1.3411e-07,0,4.20461,-0.289259,0.0733235,0.954438,-0.212724,-0.977055,0.0105913,0.933315,-0.199968,0.29822},{2.68221e-07,5.36443e-07,4.20461,-0.130702,0.0536421,0.989969,-0.0699131,-0.996548,0.0447681,0.988954,-0.0633605,0.134002},{2.68221e-07,5.36443e-07,4.20461,-0.125125,0.0533441,0.990706,-0.0640079,-0.996907,0.0455938,0.990074,-0.0577081,0.128152},{-2.68221e-07,0,4.20461,-0.53647,0.0632887,0.841543,-0.0843186,-0.996214,0.0211691,0.839696,-0.0596011,0.539775},{0,-5.36443e-07,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866}}},["30"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-2.68221e-07,2.68221e-07,5.62343,0.109675,-0.351937,-0.929576,0.974209,0.223606,0.030284,0.197201,-0.908923,0.367384},{-2.68221e-07,-1.07288e-06,5.62343,0.0726662,-0.356594,-0.931429,0.974377,0.2247,-0.0100086,0.212861,-0.906836,0.363785},{4.02332e-07,-5.36443e-07,5.62343,0.007001,-0.387107,-0.922009,0.97133,0.221744,-0.0857238,0.237634,-0.894974,0.377561},{-6.70554e-07,5.36443e-07,5.62343,-0.015325,-0.476745,-0.878908,0.970751,0.203541,-0.127333,0.2396,-0.855152,0.459682},{5.36443e-07,-5.36443e-07,5.62343,0.105253,-0.80975,-0.577258,0.984118,0.168255,-0.0565841,0.142946,-0.562134,0.814599},{8.04661e-07,5.36443e-07,5.62343,0.178655,-0.965362,-0.190156,0.983887,0.176657,0.0275444,0.00700215,-0.192013,0.981367},{5.36443e-07,0,5.62343,0.180408,-0.968098,-0.173897,0.983591,0.177765,0.0307906,0.00110439,-0.176598,0.984282},{0,-5.36443e-07,5.62343,0.176166,-0.807404,-0.563086,0.980162,0.196658,0.0246656,0.0908203,-0.55626,0.826031},{-2.68221e-07,2.68221e-07,5.62343,0.109675,-0.351937,-0.929576,0.974209,0.223606,0.030284,0.197201,-0.908923,0.367384}}},["31"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535},{1.67638e-08,-6.70554e-08,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535},{-6.70554e-08,2.01166e-07,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535},{-3.35276e-08,0,3.7976,0.408719,-0.482071,0.774956,0.694827,0.714907,0.0782584,-0.591747,0.506474,0.627152},{-1.67638e-08,2.68221e-07,3.7976,0.0235773,-0.569332,0.82177,0.795155,0.508906,0.329762,-0.605947,0.645659,0.464706},{-6.70554e-08,-2.68221e-07,3.7976,-0.366877,-0.552814,0.748197,0.760656,0.284745,0.583372,-0.535541,0.783146,0.316034},{-1.3411e-07,0,3.7976,-0.227162,-0.571117,0.788811,0.78908,0.366764,0.492785,-0.570745,0.734377,0.367342},{-3.35276e-08,-1.3411e-07,3.7976,0.197005,-0.543365,0.816053,0.767269,0.603611,0.216684,-0.610318,0.583444,0.535821},{-3.35276e-08,-1.3411e-07,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535}}},["32"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-1.3411e-07,2.68221e-07,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.00929472,0.845387,-0.534073},{-1.3411e-07,2.68221e-07,8.88873,0.345995,-0.312726,-0.884584,-0.938236,-0.115212,-0.32625,0.000112027,0.94283,-0.333273},{-2.68221e-07,-5.36443e-07,8.88873,0.279124,0.0432673,-0.95928,-0.959417,0.0542881,-0.276716,0.0401047,0.997588,0.0566645},{1.3411e-07,5.36443e-07,8.88873,0.259868,0.169084,-0.950726,-0.963794,0.106331,-0.24453,0.059745,0.979849,0.190594},{6.70554e-08,0,8.88873,0.317105,-0.171284,-0.932795,-0.9483,-0.0436977,-0.314352,0.0130823,0.984252,-0.176285},{2.68221e-07,0,8.88873,0.384684,-0.478398,-0.789401,-0.923005,-0.207686,-0.323927,-0.00898164,0.85323,-0.521458},{0,5.36443e-07,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.00929466,0.845387,-0.534073},{0,0,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.0092946,0.845387,-0.534073},{-1.3411e-07,2.68221e-07,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.00929472,0.845387,-0.534073}}},["10"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.986045,0.0754987,-0.148375,-0.16117,0.656201,-0.737174,0.0417083,0.7508,0.659212},{1.67638e-08,-6.70554e-08,3.7976,0.986056,0.075697,-0.148201,-0.161115,0.657186,-0.736307,0.0416593,0.749918,0.660218},{-6.70554e-08,2.01166e-07,3.7976,0.986133,0.0770828,-0.146969,-0.160733,0.664071,-0.730188,0.0413131,0.743685,0.667252},{-3.35276e-08,0,3.7976,0.986384,0.0815987,-0.142788,-0.159486,0.686508,-0.709416,0.0401378,0.72253,0.690174},{-1.67638e-08,2.68221e-07,3.7976,0.987652,0.10442,-0.116794,-0.153188,0.79989,-0.580267,0.0328307,0.590993,0.806008},{-6.70554e-08,-2.68221e-07,3.7976,0.988574,0.121028,-0.0898512,-0.148604,0.882404,-0.446408,0.0252572,0.45466,0.890307},{-1.3411e-07,0,3.7976,0.988606,0.121598,-0.0887257,-0.148446,0.885237,-0.440817,0.0249408,0.448965,0.893201},{-3.35276e-08,-1.3411e-07,3.7976,0.987695,0.105201,-0.11572,-0.152972,0.803772,-0.574934,0.032529,0.585562,0.809975},{-3.35276e-08,-1.3411e-07,3.7976,0.986045,0.0754987,-0.148375,-0.16117,0.656201,-0.737174,0.0417083,0.7508,0.659212}}},["11"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{3.14321e-09,-8.38192e-08,5.59555,0.789192,-0.613322,-0.0318227,0.488446,0.65823,-0.572847,0.372287,0.436543,0.819044},{-2.09548e-09,-3.35276e-07,5.59555,0.787599,-0.61519,-0.0350669,0.459773,0.624608,-0.631248,0.41024,0.481047,0.774788},{-8.38192e-09,-2.68221e-07,5.59555,0.78702,-0.615868,-0.0361317,0.449362,0.6124,-0.650416,0.422697,0.495654,0.758718},{0,4.02332e-07,5.59555,0.788899,-0.613665,-0.0324573,0.483176,0.65205,-0.584271,0.37971,0.445248,0.81091},{1.67638e-08,3.35276e-07,5.59555,0.790571,-0.611705,-0.0285494,0.51327,0.687339,-0.513925,0.333994,0.39164,0.85736},{-2.51457e-08,-2.68221e-07,5.59555,0.789128,-0.613397,-0.0319619,0.487303,0.65689,-0.575353,0.373915,0.438452,0.81728},{0,-6.70554e-08,5.59555,0.789042,-0.613498,-0.0321501,0.485746,0.655065,-0.578741,0.376117,0.441034,0.814877},{-3.14321e-09,8.38192e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357}}},["12"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,-2.68221e-07,6.52923,0.991153,0.0405153,-0.126392,-0.0436665,0.998798,-0.0222602,0.125338,0.0275823,0.991731},{2.68221e-07,2.68221e-07,6.52923,0.989962,0.0199312,-0.139919,-0.0162957,0.999501,0.0270804,0.140389,-0.0245285,0.989793},{-5.36443e-07,0,6.52923,0.985235,-0.0252974,-0.169329,0.0462952,0.991544,0.121232,0.16483,-0.127281,0.978075},{5.36443e-07,0,6.52923,0.978464,-0.0740627,-0.19267,0.109548,0.977436,0.180604,0.174947,-0.197821,0.9645},{1.3411e-07,2.68221e-07,6.52923,0.990239,-0.118957,-0.0726351,0.129171,0.979015,0.157623,0.0523604,-0.165467,0.984824},{1.17347e-07,1.59256e-07,6.52923,0.991092,-0.12942,0.0314258,0.122633,0.97886,0.163688,-0.051946,-0.158376,0.986012},{1.00583e-07,1.67638e-07,6.52923,0.993216,-0.107692,0.0438584,0.0900226,0.950878,0.296186,-0.0736009,-0.290229,0.954123},{0,-2.68221e-07,6.52923,0.999449,-0.0261784,0.0203958,0.0197816,0.96343,0.267229,-0.0266455,-0.266679,0.963417},{0,-2.68221e-07,6.52923,0.991153,0.0405153,-0.126392,-0.0436665,0.998798,-0.0222602,0.125338,0.0275823,0.991731}}},["13"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-5.36443e-07,-5.36443e-07,6.20212,0.649888,0.661611,0.374055,-0.759687,0.550692,0.345853,0.0228313,-0.50893,0.860505},{0,5.36443e-07,6.20212,0.719077,0.639831,0.271191,-0.681684,0.573615,0.454173,0.135035,-0.511452,0.848636},{-1.07288e-06,0,6.20212,0.803944,0.592947,0.0456883,-0.486431,0.611434,0.624125,0.342138,-0.523986,0.779987},{-5.36443e-07,-5.36443e-07,6.20212,0.819872,0.558861,-0.124437,-0.326405,0.634791,0.700357,0.470394,-0.533586,0.702862},{-2.68221e-07,-2.68221e-07,6.20212,0.73524,0.591996,-0.330093,-0.563058,0.804566,0.188785,0.377341,0.0470598,0.924878},{0,0,6.20212,0.710543,0.5813,-0.396509,-0.6607,0.745023,-0.0917347,0.242083,0.327155,0.913436},{2.68221e-07,0,6.20212,0.780528,0.623983,0.0376971,-0.566134,0.680018,0.465905,0.265082,-0.384994,0.884031},{-1.3411e-07,1.3411e-07,6.20212,0.777464,0.591622,0.213387,-0.59331,0.577369,0.560918,0.208648,-0.562698,0.799898},{-5.36443e-07,-5.36443e-07,6.20212,0.649888,0.661611,0.374055,-0.759687,0.550692,0.345853,0.0228313,-0.50893,0.860505}}},["14"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,-5.36443e-07,5.60288,0.635823,0.768833,0.0680112,-0.581752,0.419463,0.696861,0.507241,-0.482646,0.713974},{2.68221e-07,-4.02332e-07,5.60288,0.557337,0.821832,-0.118186,-0.576076,0.485266,0.657763,0.597923,-0.298512,0.743895},{0,-1.3411e-07,5.60288,0.328165,0.816664,-0.47473,-0.607748,0.567269,0.555741,0.723153,0.106142,0.682484},{0,6.70554e-07,5.60288,0.0674971,0.731113,-0.678909,-0.683618,0.529519,0.502271,0.726713,0.430212,0.535543},{5.36443e-07,0,5.60288,0.0802175,0.907045,-0.413321,-0.995799,0.0545555,-0.0735415,-0.0441565,0.417484,0.907611},{2.68221e-07,0,5.60288,-0.00521572,0.98973,-0.142855,-0.909624,-0.0640394,-0.410467,-0.4154,0.127804,0.900616},{2.68221e-07,1.07288e-06,5.60288,0.212979,0.924311,-0.316686,-0.858306,0.331863,0.391378,0.466851,0.188459,0.864021},{2.68221e-07,0,5.60288,0.480384,0.84955,-0.217933,-0.581763,0.4946,0.645695,0.65634,-0.183396,0.731836},{0,-5.36443e-07,5.60288,0.635823,0.768833,0.0680112,-0.581752,0.419463,0.696861,0.507241,-0.482646,0.713974}}},["15"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,-0.00239779,-0.473524,-0.880778,0.557685,0.73046,-0.394228,0.830049,-0.492142,0.262326},{3.14321e-09,-8.38192e-08,5.59555,0.0238386,-0.441909,-0.896743,0.557119,0.750673,-0.355117,0.83009,-0.491127,0.264091},{-2.09548e-09,-3.35276e-07,5.59555,0.0696245,-0.384519,-0.920488,0.55335,0.782644,-0.285083,0.830034,-0.489503,0.267265},{-8.38192e-09,-2.68221e-07,5.59555,0.0833696,-0.36405,-0.92764,0.552654,0.791502,-0.260955,0.829231,-0.490908,0.267181},{0,4.02332e-07,5.59555,-0.0149538,-0.420173,-0.907321,0.588969,0.729593,-0.347576,0.808017,-0.539581,0.236559},{1.67638e-08,3.35276e-07,5.59555,-0.115436,-0.467152,-0.876609,0.613855,0.660269,-0.432698,0.780933,-0.588059,0.210545},{-2.51457e-08,-2.68221e-07,5.59555,-0.119566,-0.468866,-0.875139,0.614622,0.657293,-0.436125,0.779708,-0.590025,0.209586},{0,-6.70554e-08,5.59555,-0.070813,-0.472554,-0.878452,0.592308,0.688673,-0.418211,0.802594,-0.549929,0.231131},{-3.14321e-09,8.38192e-08,5.59555,-0.00239779,-0.473524,-0.880778,0.557685,0.73046,-0.394228,0.830049,-0.492142,0.262326}}},["16"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{2.68221e-07,0,4.04298,0.788188,0.225403,-0.572671,-0.555192,0.661933,-0.503594,0.265559,0.71487,0.646869},{0,2.68221e-07,4.04298,0.660927,0.27853,-0.696847,-0.681532,0.61149,-0.401988,0.314149,0.740609,0.593977},{-5.36443e-07,-2.68221e-07,4.04298,0.382938,0.344043,-0.857317,-0.846301,0.50269,-0.176287,0.370315,0.793056,0.483663},{5.36443e-07,2.68221e-07,4.04298,0.264081,0.361047,-0.894375,-0.886169,0.456883,-0.077221,0.380744,0.81296,0.440603},{0,0,4.04298,0.359069,0.428142,-0.829315,-0.861906,0.492986,-0.118672,0.358032,0.757403,0.546034},{-1.3411e-07,2.68221e-07,4.04298,0.639918,0.442815,-0.628028,-0.726839,0.614056,-0.307636,0.249418,0.653337,0.714801},{-1.3411e-07,1.3411e-07,4.04298,0.653781,0.4415,-0.614531,-0.717232,0.620385,-0.317335,0.241143,0.648228,0.722254},{-2.68221e-07,1.3411e-07,4.04298,0.715291,0.352705,-0.603289,-0.653027,0.644741,-0.397322,0.248828,0.678165,0.691504},{2.68221e-07,0,4.04298,0.788188,0.225403,-0.572671,-0.555192,0.661933,-0.503594,0.265559,0.71487,0.646869}}},["17"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,0,4.30251,0.861801,0.100392,0.497213,-0.022361,0.986785,-0.160484,-0.506753,0.127187,0.852657},{0,-5.36443e-07,4.30251,0.85152,0.0948784,0.515667,-0.0150589,0.987511,-0.156827,-0.524106,0.125776,0.842314},{0,5.36443e-07,4.30251,0.817782,0.0752169,0.570591,0.00742119,0.989962,-0.141136,-0.57548,0.119653,0.809016},{1.07288e-06,5.36443e-07,4.30251,0.752076,0.035897,0.658098,0.0441577,0.993528,-0.104657,-0.657596,0.10777,0.745623},{-5.36443e-07,0,4.30251,0.688878,-4.7639e-05,0.724877,0.0718899,0.995075,-0.0682543,-0.721304,0.0991302,0.685489},{0,0,4.30251,0.981884,0.185998,0.0361811,-0.172841,0.957416,-0.231259,-0.077654,0.220816,0.972219},{2.68221e-07,5.36443e-07,4.30251,0.981015,0.193719,-0.00908101,-0.190422,0.953338,-0.23428,-0.036727,0.231561,0.972127},{5.36443e-07,-2.68221e-07,4.30251,0.964087,0.162079,0.210396,-0.116169,0.969741,-0.214725,-0.238832,0.182572,0.953744},{0,0,4.30251,0.861801,0.100392,0.497213,-0.022361,0.986785,-0.160484,-0.506753,0.127187,0.852657}}},["18"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,0,5.37487,0.0344749,0.382786,-0.923193,0.994184,0.0811702,0.0707818,0.10203,-0.920264,-0.377761},{0,0,5.37487,0.0181752,0.267294,-0.963444,0.995408,0.0857365,0.0425647,0.0939796,-0.959793,-0.264509},{0,5.36443e-07,5.37487,-0.0144894,0.0555863,-0.998349,0.99572,0.0919546,-0.00933128,0.0912841,-0.994211,-0.0566806},{0,-5.36443e-07,5.37487,-0.0301189,0.00211152,-0.999544,0.992635,0.117461,-0.0296625,0.117344,-0.993075,-0.00563369},{-5.36443e-07,5.36443e-07,5.37487,-0.0234171,0.371167,-0.928271,0.978481,0.198914,0.0548515,0.205005,-0.907011,-0.367838},{5.36443e-07,0,5.37487,-0.0123252,0.291122,-0.956607,0.984875,0.168887,0.0387075,0.172827,-0.941661,-0.2888},{0,-5.36443e-07,5.37487,-0.0112318,0.267157,-0.963588,0.986069,0.162894,0.0336689,0.165957,-0.949786,-0.265265},{0,-5.36443e-07,5.37487,0.0069342,0.316568,-0.948545,0.99032,0.12933,0.0504025,0.138631,-0.939712,-0.312607},{0,0,5.37487,0.0344749,0.382786,-0.923193,0.994184,0.0811702,0.0707818,0.10203,-0.920264,-0.377761}}},["19"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},{3.14321e-09,-8.38192e-08,5.59555,-0.0199665,0.501648,0.864842,-0.557275,0.712597,-0.426204,-0.830088,-0.490465,0.265328},{-2.09548e-09,-3.35276e-07,5.59555,0.0576436,0.40771,0.911291,-0.555094,0.771788,-0.310184,-0.829788,-0.487972,0.270806},{-8.38192e-09,-2.68221e-07,5.59555,0.081863,0.372904,0.924252,-0.553218,0.78838,-0.269085,-0.829004,-0.489285,0.270836},{0,4.02332e-07,5.59555,-0.0599099,0.452377,0.889812,-0.583148,0.70762,-0.399014,-0.810154,-0.542797,0.22141},{1.67638e-08,3.35276e-07,5.59555,-0.203201,0.515008,0.832752,-0.590515,0.613954,-0.523787,-0.781026,-0.598186,0.179363},{-2.51457e-08,-2.68221e-07,5.59555,-0.209014,0.517174,0.829967,-0.590329,0.6099,-0.528709,-0.779631,-0.600461,0.177825},{0,-6.70554e-08,5.59555,-0.149109,0.533774,0.832377,-0.576594,0.636926,-0.511727,-0.803309,-0.556247,0.2128},{-3.14321e-09,8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325}}},["20"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-5.36443e-07,-1.3411e-07,4.04298,0.896552,-0.18038,0.404545,0.407723,0.692959,-0.594617,-0.173076,0.698047,0.69482},{-5.36443e-07,-1.3411e-07,4.04298,0.868158,-0.143387,0.475124,0.448595,0.636225,-0.627678,-0.212285,0.758062,0.616666},{0,-2.68221e-07,4.04298,0.80771,-0.0680035,0.585645,0.527197,0.528003,-0.66579,-0.263946,0.846515,0.462325},{0,2.68221e-07,4.04298,0.782223,-0.0519409,0.62083,0.56441,0.480979,-0.670896,-0.263759,0.875193,0.405548},{5.36443e-07,5.36443e-07,4.04298,0.828709,-0.185921,0.527897,0.532818,0.55078,-0.642454,-0.17131,0.81368,0.555498},{0,-1.3411e-07,4.04298,0.752657,-0.336818,0.56574,0.638826,0.581599,-0.50363,-0.159402,0.74047,0.652913},{1.3411e-07,1.3411e-07,4.04298,0.613587,-0.364007,0.700721,0.748789,0.549915,-0.370011,-0.25065,0.751726,0.609985},{2.68221e-07,1.3411e-07,4.04298,0.751408,-0.295675,0.589884,0.62066,0.620179,-0.47975,-0.223984,0.726605,0.64952},{-5.36443e-07,-1.3411e-07,4.04298,0.896552,-0.18038,0.404545,0.407723,0.692959,-0.594617,-0.173076,0.698047,0.69482}}},["21"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{0,0,4.30251,0.909555,-0.11628,-0.398984,0.0479311,0.983003,-0.177221,0.41281,0.142068,0.89967},{0,0,4.30251,0.881177,-0.110087,-0.459792,0.0347272,0.984957,-0.169272,0.47151,0.133191,0.871745},{5.36443e-07,5.36443e-07,4.30251,0.821963,-0.0978161,-0.561078,0.0129754,0.988102,-0.153253,0.569392,0.118688,0.813453},{1.07288e-06,-5.36443e-07,4.30251,0.79557,-0.0927539,-0.598719,0.00517835,0.989217,-0.146369,0.605839,0.113347,0.787472},{5.36443e-07,-2.68221e-07,4.30251,0.801657,-0.0998417,-0.589387,0.0120674,0.988456,-0.15103,0.597662,0.113962,0.793608},{-5.36443e-07,2.68221e-07,4.30251,0.8288,-0.113024,-0.548011,0.0256384,0.986029,-0.164588,0.558957,0.122361,0.820119},{5.36443e-07,0,4.30251,0.915002,-0.129835,-0.381987,0.0591962,0.979761,-0.191219,0.399083,0.152353,0.904169},{0,0,4.30251,0.915563,-0.124643,-0.382372,0.0557729,0.980926,-0.18621,0.398288,0.149161,0.905051},{0,0,4.30251,0.909555,-0.11628,-0.398984,0.0479311,0.983003,-0.177221,0.41281,0.142068,0.89967}}},["22"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833},["poses"]={{-1.07288e-06,1.07288e-06,5.37487,-0.00271533,-0.356721,0.934207,-0.997549,0.0662763,0.0224076,-0.0699091,-0.931857,-0.356027},{5.36443e-07,0,5.37487,-0.00369887,-0.376571,0.92638,-0.997301,0.0693136,0.0241936,-0.0733214,-0.923791,-0.375812},{-1.07288e-06,5.36443e-07,5.37487,-0.00559506,-0.410887,0.911669,-0.99684,0.0745332,0.027474,-0.0792384,-0.908635,-0.410006},{5.36443e-07,1.07288e-06,5.37487,-0.00508683,-0.404892,0.91435,-0.996978,0.0729293,0.0267478,-0.0775129,-0.911452,-0.404039},{1.07288e-06,0,5.37487,0.00212666,0.0258196,0.999664,-0.999948,-0.00993982,0.00238384,0.00999797,-0.999617,0.0257972},{0,0,5.37487,-0.00223695,-0.157443,0.987525,-0.999654,0.0262103,0.00191419,-0.0261847,-0.98718,-0.157447},{1.07288e-06,0,5.37487,-0.0144862,-0.393193,0.919342,-0.997352,0.0712142,0.014742,-0.0712667,-0.916694,-0.393183},{5.36443e-07,0,5.37487,-0.00951782,-0.378464,0.925567,-0.99744,0.0691991,0.0180384,-0.0708754,-0.923026,-0.378154},{-1.07288e-06,1.07288e-06,5.37487,-0.00271533,-0.356721,0.934207,-0.997549,0.0662763,0.0224076,-0.0699091,-0.931857,-0.356027}}}}}
]====])
-- Source: src/client/world/dragon/Die.luau
addModule(modules,{"world","dragon","Die"},[====[
-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.
return {["duration"]=2.5,["tracks"]={["5"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,-4.94982,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-6.28643e-09,-5.22543,-4.58586,0.985758,-0.07649,0.14977,-0.0670503,0.637973,0.767134,-0.154228,-0.76625,0.623759},{8.38192e-09,-5.57294,-4.58586,0.940522,0.0795622,0.330286,-0.302709,0.637598,0.708404,-0.154228,-0.76625,0.623759},{-4.19094e-09,-5.48811,-4.58586,0.952874,0.0515675,0.298951,-0.261237,0.64047,0.722187,-0.154228,-0.76625,0.623759},{2.09548e-09,-5.20931,-4.58586,0.982844,-0.0543509,0.176247,-0.101147,0.64024,0.761487,-0.154228,-0.76625,0.623759},{-8.90579e-09,-4.97723,-4.58586,0.985329,-0.165974,0.0397389,0.0730777,0.620736,0.780606,-0.154228,-0.76625,0.623759},{0,-4.95189,-4.58586,0.974096,-0.223538,-0.0341693,0.165618,0.602343,0.780867,-0.153971,-0.766299,0.623762},{-5.23868e-10,-4.98913,-4.58586,0.96662,-0.24611,-0.0712408,0.208165,0.59227,0.778385,-0.149374,-0.767233,0.623732},{-2.09547e-09,-5.11852,-4.58586,0.937279,-0.302348,-0.173477,0.321994,0.560332,0.763117,-0.133522,-0.771112,0.622541},{0,-5.56127,-4.58586,0.76735,-0.459667,-0.447079,0.631661,0.421884,0.650399,-0.110352,-0.781486,0.614087},{3.35276e-08,-7.14692,-4.58586,0.061961,-0.623002,-0.779762,0.988681,-0.0686464,0.133408,-0.136641,-0.779202,0.611697},{0,-8.16718,-4.58586,-0.404495,-0.527016,-0.747421,0.901442,-0.36758,-0.228664,-0.154228,-0.76625,0.623759},{0,-8.16718,-4.58586,-0.404495,-0.527016,-0.747421,0.901442,-0.36758,-0.228664,-0.154228,-0.76625,0.623759}}},["2"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.969565,-0.157427,0.187514,-0.109396,0.406618,0.907025,-0.219037,-0.899932,0.377021},{0,0,3.7976,0.976068,-0.183611,0.116527,-0.0145774,0.479392,0.87748,-0.216977,-0.858179,0.465242},{-1.3411e-07,0,3.7976,0.97091,-0.239345,-0.00695825,0.149364,0.582676,0.798861,-0.187149,-0.776661,0.601475},{0,0,3.7976,0.965997,-0.247065,-0.0762185,0.212485,0.590647,0.778451,-0.14731,-0.768176,0.623061},{0,0,3.7976,0.980747,-0.143381,-0.132582,0.186281,0.483112,0.855513,-0.0586119,-0.863739,0.50052},{-3.35276e-08,0,3.7976,0.987285,-0.0319323,-0.155723,0.15664,0.362273,0.918816,0.0270743,-0.931525,0.362669},{3.35276e-08,-2.68221e-07,3.7976,0.992753,-0.0482161,-0.110073,0.120049,0.356799,0.926435,-0.00539517,-0.932936,0.360002},{5.02913e-08,0,3.7976,0.975166,-0.184503,0.122518,-0.0345836,0.419549,0.907074,-0.21876,-0.888784,0.402749},{-3.35276e-08,1.3411e-07,3.7976,0.859209,-0.316856,0.4017,-0.197267,0.519268,0.831532,-0.472066,-0.793702,0.383655},{0,0,3.7976,0.748082,-0.370985,0.550222,-0.271864,0.585036,0.764083,-0.605363,-0.721182,0.336797},{-3.35276e-08,2.68221e-07,3.7976,0.832525,-0.321239,0.45134,-0.236678,0.530373,0.814057,-0.500885,-0.784544,0.365519},{-4.02332e-07,2.68221e-07,3.7976,0.958438,-0.180519,0.220931,-0.127767,0.420805,0.898108,-0.255095,-0.889008,0.380251},{-4.02332e-07,2.68221e-07,3.7976,0.969565,-0.157427,0.187514,-0.109396,0.406618,0.907025,-0.219037,-0.899932,0.377021}}},["6"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{6.70554e-08,2.68221e-07,5.10035,0.220169,-0.957095,-0.188399,0.90994,0.271104,-0.313867,0.351476,-0.102328,0.930588},{2.68221e-07,0,5.10035,0.209483,-0.959708,-0.187287,0.912022,0.260841,-0.31651,0.35261,-0.104506,0.929917},{0,0,5.10035,0.190814,-0.965218,-0.17873,0.911816,0.241717,-0.331911,0.363569,-0.0996349,0.926224},{-2.68221e-07,-2.68221e-07,5.10035,0.181872,-0.970843,-0.15616,0.898047,0.228681,-0.375788,0.400542,-0.0718938,0.913454},{0,-2.68221e-07,5.10035,0.177503,-0.97581,-0.127626,0.855043,0.217126,-0.470911,0.48723,-0.0255372,0.8729},{1.3411e-07,2.68221e-07,5.10035,0.19326,-0.97602,-0.10018,0.806879,0.216194,-0.549734,0.558209,0.0254085,0.829311},{-3.35276e-08,-2.68221e-07,5.10035,0.279894,-0.95732,-0.0720952,0.809071,0.27564,-0.519063,0.516782,0.0869525,0.85169},{1.84402e-07,5.36443e-07,5.10035,0.507346,-0.860904,0.0380166,0.827907,0.47471,-0.298699,0.239104,0.183018,0.95359},{-2.01166e-07,-2.68221e-07,5.10035,0.668664,-0.683988,0.291631,0.727294,0.683228,-0.0651357,-0.154699,0.255656,0.95431},{-2.01166e-07,0,5.10035,0.63826,-0.515242,0.57197,0.644227,0.764227,-0.0304611,-0.42142,0.387921,0.819709},{-8.04661e-07,1.3411e-07,5.10035,0.319335,-0.498331,0.806035,0.881122,0.469194,-0.0590048,-0.348783,0.729057,0.58892},{-4.02332e-07,-2.68221e-07,5.10035,0.589222,-0.741711,0.320439,0.803287,0.58041,-0.133623,-0.0868766,0.336138,0.937797},{8.04661e-07,-1.3411e-07,5.10035,0.553876,-0.815955,0.165646,0.832474,0.546169,-0.0932028,-0.0144211,0.189519,0.981771}}},["1"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-5.36443e-07,-6.70554e-08,4.80781,0.465714,-0.397752,0.790508,0.65583,0.75488,-0.0065457,-0.594135,0.521487,0.612416},{-2.68221e-07,-1.3411e-07,4.80781,0.365259,-0.558328,0.744887,0.812356,0.581933,0.0378434,-0.454603,0.59129,0.666117},{-2.68221e-07,-2.68221e-07,4.80781,0.155724,-0.756563,0.635109,0.971834,0.232478,0.0386486,-0.176889,0.611201,0.771455},{4.02332e-07,0,4.80781,0.176116,-0.806599,0.564253,0.98399,0.160169,-0.0781637,-0.0273293,0.568986,0.821893},{-2.68221e-07,-3.35276e-08,4.80781,0.358406,-0.784612,0.505896,0.930764,0.258365,-0.2587,0.0722731,0.563589,0.822888},{-2.68221e-07,-2.68221e-07,4.80781,0.626309,-0.664044,0.408391,0.779061,0.514107,-0.35883,0.0283219,0.5429,0.83932},{0,-2.68221e-07,4.8078,0.907988,-0.287695,0.304613,0.364004,0.901673,-0.233423,-0.207506,0.322825,0.923431},{5.36443e-07,0,4.80781,0.958021,0.0615145,0.280021,-0.0387071,0.99552,-0.086267,-0.284073,0.0718066,0.95611},{5.36443e-07,-2.68221e-07,4.80781,0.93956,0.136792,0.31387,-0.0713092,0.9748,-0.211377,-0.334875,0.17622,0.925638},{0,0,4.80781,0.910729,0.208887,0.356285,-0.0674427,0.926305,-0.37069,-0.407461,0.313569,0.857701},{-3.18512e-07,0,4.80781,0.912482,0.0470419,0.406403,0.118287,0.920605,-0.372148,-0.391643,0.387651,0.834472},{0,0,4.8078,0.963645,-0.0139572,0.266821,0.0521136,0.989273,-0.136465,-0.262054,0.145408,0.954036},{-8.04661e-07,-2.68221e-07,4.80781,0.483723,-0.85803,0.172616,0.853347,0.506188,0.124791,-0.194451,0.0869368,0.977052}}},["7"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-5.36443e-07,5.36443e-07,3.87696,0.220576,-0.810685,0.542343,0.875768,-0.0801763,-0.476029,0.429392,0.579967,0.692286},{0,1.07288e-06,3.87696,0.265517,-0.820644,0.506007,0.930366,0.0804634,-0.357695,0.252825,0.565746,0.784864},{2.68221e-07,2.68221e-07,3.87696,0.357404,-0.829477,0.429221,0.932878,0.339075,-0.12152,-0.0447402,0.443843,0.894987},{0,0,3.87696,0.378227,-0.869214,0.318453,0.922118,0.384052,-0.0469349,-0.081506,0.311403,0.946776},{6.70554e-08,0,3.87696,0.130871,-0.974965,0.179766,0.985151,0.107564,-0.133821,0.111135,0.19461,0.974565},{-5.36443e-07,0,3.87696,-0.17239,-0.980194,0.0974717,0.946573,-0.192226,-0.258937,0.272545,0.0476259,0.960964},{0,0,3.87696,-0.256251,-0.965453,0.0472826,0.933058,-0.259836,-0.248773,0.252465,-0.0196309,0.967407},{0,0,3.87696,-0.302201,-0.953239,-0.0032911,0.945013,-0.299137,-0.132162,0.124997,-0.0430494,0.991223},{5.36443e-07,5.36443e-07,3.87696,-0.282316,-0.940079,0.191179,0.953989,-0.296098,-0.0472277,0.101006,0.16905,0.980418},{0,0,3.87696,-0.238851,-0.870008,0.431318,0.964488,-0.264122,0.0013465,0.112749,0.416323,0.902199},{2.68221e-07,-1.07288e-06,3.87696,-0.236769,-0.865687,0.441053,0.964936,-0.262471,0.00283185,0.113312,0.426258,0.897477},{-5.36443e-07,5.36443e-07,3.87696,-0.236769,-0.865686,0.441053,0.964936,-0.262471,0.00283188,0.113312,0.426258,0.897477},{-1.07288e-06,2.68221e-07,3.87696,-0.228251,-0.923346,0.308761,0.941379,-0.290219,-0.171985,0.24841,0.251405,0.935461}}},["8"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{1.10288,-0.968026,3.25436,0.812169,-0.164631,0.559713,0.485193,0.723352,-0.491274,-0.32399,0.670566,0.667362},{1.10288,-0.968025,3.25436,0.813292,-0.146262,0.563172,0.483662,0.708001,-0.514594,-0.323461,0.6909,0.646553},{1.10288,-0.968026,3.25436,0.814736,-0.119558,0.567371,0.483828,0.679453,-0.551593,-0.319555,0.723913,0.611421},{1.10979,-0.957561,3.27459,0.812213,-0.144532,0.565173,0.502752,0.664827,-0.552491,-0.29589,0.732882,0.612645},{1.16994,-0.8777,3.44046,0.7796,-0.329988,0.532289,0.599685,0.638367,-0.48256,-0.180557,0.69541,0.695561},{1.24836,-0.813868,3.61989,0.720179,-0.49956,0.481437,0.689397,0.593224,-0.415711,-0.0779273,0.631288,0.771623},{1.29526,-0.843925,3.66885,0.710347,-0.484165,0.510873,0.693898,0.60336,-0.393018,-0.117955,0.633673,0.764556},{1.29665,-0.904171,3.64078,0.685741,-0.317883,0.654759,0.642874,0.686338,-0.340079,-0.341281,0.654133,0.675009},{1.24074,-0.996654,3.51132,0.604773,-0.128393,0.78598,0.556342,0.77429,-0.301593,-0.569854,0.619669,0.5397},{1.14146,-1.03137,3.34776,0.5315,0.0142598,0.846938,0.505229,0.797199,-0.330481,-0.679891,0.603549,0.416506},{1.07001,-0.932527,3.22268,0.572585,-0.0581263,0.817782,0.677634,0.595018,-0.432164,-0.461475,0.801607,0.380087},{1.06091,-0.882878,3.16518,0.586205,-0.181816,0.789497,0.775767,0.406903,-0.482302,-0.233559,0.895194,0.379576},{1.08946,-0.871412,3.16759,0.524301,-0.25317,0.813027,0.828479,0.372326,-0.418326,-0.196804,0.892904,0.404957}}},["9"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0.177817,-0.156074,2.85685,0.822607,0.0610726,0.565321,0.279987,0.821825,-0.496197,-0.494899,0.566457,0.658939},{0.15539,-0.0014661,3.06055,0.824169,0.0361026,0.565192,0.279146,0.842425,-0.460866,-0.49277,0.537602,0.684223},{0.186458,0.186529,3.47419,0.834852,-0.0148904,0.550273,0.274075,0.878167,-0.392053,-0.477393,0.478122,0.737221},{0.404873,0.0236013,3.82857,0.862013,-0.0699768,0.502032,0.276565,0.894941,-0.350133,-0.424788,0.440664,0.790804},{0.724411,-0.393446,4.13594,0.885466,-0.2094,0.414851,0.372415,0.853718,-0.363969,-0.27795,0.476779,0.833922},{0.95318,-0.726241,4.33086,0.873427,-0.347413,0.341219,0.465996,0.799682,-0.378624,-0.141328,0.489707,0.860357},{0.979411,-0.74137,4.35842,0.858245,-0.390391,0.333183,0.491678,0.811579,-0.315583,-0.147203,0.434666,0.88848},{1.01826,-0.640668,4.36582,0.804781,-0.365896,0.467384,0.49901,0.843454,-0.198931,-0.321428,0.393325,0.861382},{1.13643,-0.539568,4.32207,0.625282,-0.260157,0.735758,0.454441,0.88784,-0.0722743,-0.634433,0.379551,0.673377},{1.22175,-0.478045,4.2682,0.439025,-0.160293,0.88406,0.404356,0.913928,-0.0350947,-0.802342,0.372882,0.466053},{1.06203,-0.668493,4.19606,0.691843,-0.048716,0.720403,0.424958,0.834094,-0.351706,-0.58375,0.549466,0.597764},{1.02247,-0.701412,4.15931,0.729179,-0.0323412,0.683558,0.396084,0.834507,-0.383035,-0.558046,0.550048,0.621315},{0.994906,-0.712917,4.1619,0.641628,-0.0833622,0.762473,0.507015,0.792018,-0.340065,-0.575543,0.60478,0.550446}}},["23"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,-0.0777039,0.0682742,-0.994636,-0.10221,0.99185,0.0760679,0.991723,0.107573,-0.0700925},{0,0,3.7976,-0.0957966,0.0562851,-0.993808,-0.0975881,0.993059,0.0656495,0.990606,0.103273,-0.0896391},{-1.3411e-07,0,3.7976,-0.134757,0.030763,-0.990401,-0.0882919,0.995169,0.0429244,0.986937,0.0932287,-0.13139},{0,0,3.7976,-0.171404,0.0071235,-0.985175,-0.0803649,0.99654,0.0211879,0.981917,0.0828051,-0.170239},{0,0,3.7976,-0.178915,0.00240685,-0.983862,-0.0780367,0.996812,0.0166295,0.980765,0.0797527,-0.178156},{-3.35276e-08,0,3.7976,-0.093684,0.0580409,-0.993908,-0.0898131,0.993736,0.0664965,0.991543,0.0954956,-0.0878845},{3.35276e-08,-2.68221e-07,3.7976,-0.0921644,0.0602402,-0.99392,-0.130871,0.988777,0.0720639,0.987106,0.136716,-0.0832466},{5.02913e-08,0,3.7976,-0.161427,0.0207696,-0.986666,-0.203456,0.977601,0.0538659,0.965685,0.209439,-0.153586},{-3.35276e-08,1.3411e-07,3.7976,-0.260466,-0.0459161,-0.964391,-0.294229,0.95513,0.0339909,0.919558,0.292605,-0.262289},{0,0,3.7976,-0.358618,-0.126729,-0.924842,-0.385193,0.922551,0.0229476,0.850306,0.364472,-0.379659},{-3.35276e-08,2.68221e-07,3.7976,-0.432508,-0.200695,-0.87901,-0.457753,0.8888,0.022302,0.776788,0.412015,-0.476282},{-4.02332e-07,2.68221e-07,3.7976,-0.47041,-0.244737,-0.847831,-0.497204,0.867258,0.0255234,0.729042,0.433552,-0.529651},{-4.02332e-07,2.68221e-07,3.7976,-0.474042,-0.249223,-0.844495,-0.50107,0.865017,0.0259866,0.724026,0.43547,-0.534933}}},["4"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-2.01166e-07,0,4.8923,0.910719,0.0547092,-0.409387,-0.413005,0.1106,-0.903988,-0.00417811,0.992358,0.123321},{-2.68221e-07,0,4.8923,0.910346,0.0384043,-0.412063,-0.413831,0.0937953,-0.905509,0.00387418,0.99485,0.101279},{-2.68221e-07,-6.70554e-08,4.8923,0.909091,0.00317872,-0.416586,-0.416063,0.0575941,-0.90751,0.0211082,0.998335,0.0536808},{2.68221e-07,1.3411e-07,4.8923,0.90735,-0.0300882,-0.419298,-0.418728,0.0235356,-0.907806,0.0371828,0.99927,0.0087562},{-1.3411e-07,1.3411e-07,4.8923,0.906905,-0.0380331,-0.419616,-0.419363,0.0147674,-0.907698,0.0407193,0.999167,-0.00255705},{-4.02332e-07,-2.68221e-07,4.8923,0.910473,0.028714,-0.412571,-0.413529,0.0771761,-0.907214,0.00579097,0.996604,0.0821408},{-2.68221e-07,-1.3411e-07,4.8923,0.905674,-0.0043787,-0.423953,-0.41424,0.203921,-0.88703,0.0903368,0.978978,0.182872},{6.03497e-07,0,4.8923,0.421473,-0.230948,-0.87694,-0.622175,0.629884,-0.464913,0.659741,0.741559,0.121789},{2.68221e-07,0,4.8923,0.264516,-0.0932629,-0.959861,-0.623129,0.74311,-0.243923,0.736031,0.662638,0.13845},{1.3411e-07,0,4.8923,0.448923,0.0670934,-0.891048,-0.653453,0.704799,-0.276149,0.609482,0.706228,0.360242},{0,-5.36443e-07,4.8923,0.618361,0.240785,-0.748099,-0.683276,0.635021,-0.360392,0.388281,0.734011,0.557195},{2.68221e-07,0,4.8923,0.694826,0.35395,-0.626048,-0.686704,0.585152,-0.431317,0.213669,0.7296,0.649638},{2.68221e-07,-1.3411e-07,4.8923,0.701157,0.365888,-0.611968,-0.686124,0.579698,-0.439526,0.193939,0.728063,0.657504}}},["3"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-2.34693e-07,5.36443e-07,4.20461,-0.878099,-0.0959764,-0.468755,0.0807577,-0.995349,0.0525152,-0.471616,0.0082579,0.881766},{-2.68221e-07,-5.36443e-07,4.20461,-0.88079,-0.0530944,-0.470521,0.045442,-0.998585,0.0276171,-0.471322,0.00294344,0.881957},{0,2.68221e-07,4.20461,-0.881845,0.0394976,-0.469882,-0.0308155,-0.999183,-0.0261574,-0.470532,-0.00858712,0.882342},{2.01166e-07,-2.68221e-07,4.20461,-0.877482,0.12622,-0.462703,-0.102356,-0.991806,-0.0764432,-0.46856,-0.0197169,0.883211},{1.00583e-07,-2.68221e-07,4.20461,-0.879,0.150776,-0.452356,-0.123368,-0.9883,-0.0896892,-0.460587,-0.0230304,0.887316},{3.35276e-08,0,4.20461,-0.912524,0.0278444,-0.408075,-0.0134163,-0.999181,-0.0381767,-0.408803,-0.0293623,0.91215},{1.3411e-07,5.36443e-07,4.20461,-0.711866,-0.174852,-0.680201,0.344457,-0.930948,-0.121184,-0.612042,-0.320567,0.722939},{-8.04661e-07,5.36443e-07,4.20461,-0.209107,-0.944256,-0.254274,0.971137,-0.170009,-0.1673,0.114746,-0.281919,0.952552},{-2.68221e-07,-5.36443e-07,4.20461,-0.0956997,-0.992951,0.0699243,0.950719,-0.11199,-0.289124,0.294917,0.0388092,0.954735},{-2.68221e-07,0,4.20461,-0.547623,-0.835808,-0.0391517,0.833806,-0.54121,-0.108897,0.0698274,-0.0922793,0.993282},{5.36443e-07,5.36443e-07,4.20461,-0.895158,-0.338471,-0.290052,0.346598,-0.937692,0.0245531,-0.28029,-0.0785528,0.956696},{0,2.01166e-07,4.20461,-0.887676,0.0426783,-0.458486,-0.0564265,-0.998273,0.0163231,-0.456998,0.0403604,0.888552},{2.68221e-07,-4.02332e-07,4.20461,-0.876738,0.0802899,-0.474219,-0.0973008,-0.99519,0.0113948,-0.471023,0.0561321,0.880333}}},["24"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,5.36443e-07,5.62343,7.0544e-05,0.249153,0.968464,-0.981979,0.183049,-0.047021,-0.188992,-0.951008,0.244676},{2.68221e-07,-5.36443e-07,5.62343,0.00562626,0.275911,0.961167,-0.985205,0.166169,-0.0419334,-0.171286,-0.94671,0.272764},{2.01166e-07,-5.36443e-07,5.62343,0.0158707,0.333015,0.942788,-0.991054,0.130206,-0.0293087,-0.132517,-0.933888,0.332102},{0,0,5.62343,0.0233354,0.385907,0.922243,-0.995168,0.0969711,-0.0153964,-0.0953724,-0.917427,0.386305},{-1.3411e-07,-2.68221e-07,5.62343,0.00922087,0.394557,0.918825,-0.995791,0.0874214,-0.0275468,-0.0911937,-0.914704,0.393702},{6.70554e-08,0,5.62343,-0.286179,0.237991,0.92815,-0.929013,0.168249,-0.329587,-0.234599,-0.956584,0.172947},{-2.68221e-07,2.68221e-07,5.62343,0.0254328,0.247341,0.968595,-0.797849,0.588805,-0.129408,-0.602321,-0.769501,0.212315},{-5.36443e-07,5.36443e-07,5.62343,0.758573,0.0732958,0.647452,-0.56157,0.577489,0.592575,-0.330464,-0.813101,0.479229},{0,5.36443e-07,5.62343,0.760926,0.194993,0.618844,-0.639424,0.387243,0.664214,-0.110126,-0.901122,0.419347},{0,0,5.62343,0.53713,0.391908,0.746926,-0.843287,0.269349,0.465099,-0.018908,-0.879693,0.475166},{-8.04661e-07,8.04661e-07,5.62343,0.230885,0.556785,0.797923,-0.972747,0.15006,0.176761,-0.0213185,-0.81699,0.576258},{-6.70554e-08,1.40816e-06,5.62343,0.0247018,0.636376,0.770984,-0.997625,0.0652976,-0.0219339,-0.0643016,-0.768611,0.636477},{-6.70554e-08,5.36443e-07,5.62343,0.00320329,0.643601,0.765354,-0.997489,0.0562001,-0.0430851,-0.0707426,-0.763295,0.642165}}},["25"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.10272,0.777037,-0.621017,-0.867391,0.375575,0.32646,0.48691,0.505131,0.712574},{0,0,3.7976,0.101391,0.759125,-0.643001,-0.867176,0.384203,0.316849,0.487571,0.525469,0.697249},{-1.3411e-07,0,3.7976,0.0968849,0.713123,-0.694312,-0.867184,0.402848,0.292755,0.488472,0.573733,0.657439},{0,0,3.7976,0.0886151,0.651321,-0.75361,-0.868432,0.42106,0.261792,0.487826,0.63126,0.60294},{0,0,3.7976,0.0762268,0.589337,-0.804283,-0.871834,0.430808,0.233045,0.483834,0.683437,0.546643},{-3.35276e-08,0,3.7976,0.0591108,0.545831,-0.835808,-0.878056,0.426741,0.216588,0.474894,0.721083,0.504495},{3.35276e-08,-2.68221e-07,3.7976,0.00673643,0.646457,-0.762921,-0.891844,0.348964,0.287818,0.452294,0.678467,0.578889},{5.02913e-08,0,3.7976,-0.174594,0.969967,-0.169353,-0.873997,-0.0734518,0.480348,0.453482,0.23188,0.860573},{-3.35276e-08,1.3411e-07,3.7976,-0.293112,0.814875,0.500064,-0.785788,-0.503274,0.359517,0.544631,-0.287565,0.787835},{0,0,3.7976,-0.294818,0.75555,0.585002,-0.77199,-0.54912,0.320155,0.563129,-0.357228,0.745167},{-3.35276e-08,2.68221e-07,3.7976,-0.207666,0.92311,0.323641,-0.828856,-0.341757,0.442943,0.519492,-0.176268,0.836097},{-4.02332e-07,2.68221e-07,3.7976,-0.103237,0.994203,0.0300237,-0.861791,-0.104478,0.496388,0.496647,0.0253715,0.867581},{-4.02332e-07,2.68221e-07,3.7976,-0.089836,0.995935,-0.00654155,-0.864011,-0.0746656,0.497906,0.495394,0.0503819,0.867206}}},["26"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{2.68221e-07,-2.68221e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406},{-1.3411e-07,2.68221e-07,8.88873,0.366121,0.486483,0.793278,0.930567,-0.191643,-0.311959,0.000263274,0.852413,-0.522869},{-3.35276e-08,-4.02332e-07,8.88873,0.316845,0.491257,0.811342,0.948189,-0.14295,-0.283732,-0.0234044,0.859204,-0.511098},{-3.35276e-08,-2.68221e-07,8.88873,0.240469,0.485799,0.840341,0.969409,-0.0763021,-0.233292,-0.0492134,0.870734,-0.489286},{-1.3411e-07,5.36443e-07,8.88873,0.141601,0.459319,0.876913,0.987619,-0.00513768,-0.156787,-0.0675097,0.888257,-0.454359},{-1.3411e-07,0,8.88873,0.0241701,0.402756,0.914988,0.997238,0.0545824,-0.0503687,-0.0702286,0.913678,-0.400325},{-2.68221e-07,2.68221e-07,8.88873,-0.107465,0.280213,0.953904,0.992794,0.0814203,0.0879284,-0.0530284,0.956479,-0.286944},{-2.01166e-07,-2.68221e-07,8.88873,-0.232685,0.0309331,0.97206,0.971755,0.0478641,0.231089,-0.0393784,0.998375,-0.0411966},{6.70554e-08,-1.3411e-07,8.88873,-0.315608,-0.186127,0.930456,0.94805,-0.0206107,0.317453,-0.039909,0.98231,0.182962},{6.70554e-08,0,8.88873,-0.323098,-0.232129,0.917455,0.946035,-0.0535788,0.319606,-0.0250338,0.971208,0.236913},{-2.68221e-07,5.36443e-07,8.88873,-0.242362,-0.234596,0.941396,0.970182,-0.0558609,0.235852,-0.00274286,0.970487,0.241139},{-1.3411e-07,2.68221e-07,8.88873,-0.158908,-0.236117,0.958643,0.987218,-0.0499866,0.151333,0.0121873,0.970438,0.241042},{-2.68221e-07,0,8.88873,-0.148404,-0.236233,0.960297,0.988831,-0.0489937,0.140761,0.0137961,0.97046,0.240865}}},["27"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,-0.0321099,0.320768,0.946613,0.124315,0.941029,-0.314659,-0.991723,0.107574,-0.0700925},{0,0,3.7976,0.144353,0.145286,0.978803,0.0942472,0.982647,-0.159756,-0.985028,0.115311,0.128155},{-1.3411e-07,0,3.7976,0.362766,-0.078494,0.928569,0.0977337,0.994156,0.0458564,-0.926741,0.0741174,0.368317},{0,0,3.7976,0.333314,-0.0435508,0.94181,0.0940494,0.995486,0.012748,-0.938114,0.0843276,0.335905},{0,0,3.7976,0.202874,0.098876,0.9742,0.0903767,0.988752,-0.119174,-0.975025,0.112222,0.191655},{-3.35276e-08,0,3.7976,0.0326314,0.265697,0.963504,0.110526,0.957146,-0.267686,-0.993337,0.115227,0.00186665},{3.35276e-08,-2.68221e-07,3.7976,-0.116468,0.385799,0.915202,0.145986,0.918114,-0.368449,-0.982407,0.090694,-0.163252},{5.02913e-08,0,3.7976,-0.224246,0.460683,0.858769,0.178344,0.885729,-0.428575,-0.958075,0.0570498,-0.280782},{-3.35276e-08,1.3411e-07,3.7976,-0.298333,0.503687,0.810738,0.201788,0.863504,-0.462215,-0.932887,0.025703,-0.35925},{0,0,3.7976,-0.346501,0.525128,0.777289,0.215601,0.851021,-0.47883,-0.912937,0.00166929,-0.408098},{-3.35276e-08,2.68221e-07,3.7976,-0.374516,0.533208,0.758569,0.221594,0.845875,-0.485172,-0.900352,-0.0136104,-0.43495},{-4.02332e-07,2.68221e-07,3.7976,-0.386434,0.534548,0.751617,0.222856,0.844892,-0.486306,-0.894988,-0.0204232,-0.445622},{-4.02332e-07,2.68221e-07,3.7976,-0.387409,0.534506,0.751144,0.222856,0.844904,-0.486285,-0.894567,-0.0209941,-0.446441}}},["28"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{6.70554e-08,1.3411e-07,4.8923,0.781743,-0.0502348,0.621574,0.622859,0.111511,-0.774346,-0.0304132,0.992493,0.118462},{1.3411e-07,-1.3411e-07,4.8923,0.78246,0.034876,0.621724,0.621172,0.0262178,-0.783236,-0.0436163,0.999048,-0.00114959},{-2.68221e-07,1.3411e-07,4.8923,0.781746,0.141253,0.607388,0.620664,-0.081897,-0.779788,-0.0604044,0.98658,-0.151694},{2.68221e-07,0,4.89229,0.782086,0.11556,0.612362,0.62062,-0.0556271,-0.782136,-0.0563198,0.991742,-0.115224},{2.68221e-07,0,4.8923,0.782449,0.0298935,0.621997,0.621239,0.0312402,-0.782998,-0.0428378,0.999065,0.00587291},{-1.3411e-07,0,4.8923,0.781864,-0.0418,0.622045,0.622641,0.103106,-0.775685,-0.0317127,0.993792,0.106641},{1.3411e-07,-1.3411e-07,4.8923,0.781756,-0.0492096,0.621639,0.62283,0.110624,-0.774497,-0.0306558,0.992643,0.117131},{2.01166e-07,0,4.8923,0.781823,-0.0438111,0.621959,0.622682,0.105954,-0.775268,-0.0319338,0.993405,0.110118},{6.70554e-08,-2.68221e-07,4.8923,0.781911,-0.0355594,0.622374,0.622468,0.0988087,-0.776383,-0.0338883,0.994471,0.0993943},{-1.3411e-07,1.3411e-07,4.8923,0.78199,-0.0264885,0.622728,0.622248,0.090944,-0.777519,-0.0360381,0.995503,0.0875998},{1.3411e-07,0,4.8923,0.782042,-0.018637,0.622947,0.622072,0.0841284,-0.778427,-0.0379001,0.996281,0.0773855},{0,0,4.89229,0.782065,-0.0140449,0.623038,0.621975,0.0801386,-0.778925,-0.0389896,0.996685,0.0714093},{6.70554e-08,0,4.8923,0.782068,-0.0135775,0.623045,0.621965,0.0797325,-0.778975,-0.0391004,0.996724,0.0708009}}},["29"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,-5.36443e-07,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{1.3411e-07,-5.36443e-07,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{0,0,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{-2.68221e-07,0,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{1.3411e-07,0,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{-1.3411e-07,0,4.20461,-0.923971,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{0,-2.68221e-07,4.20461,-0.924588,0.0776073,0.37298,-0.0983247,-0.994473,-0.0368156,0.368062,-0.0707124,0.927109},{-1.3411e-07,2.68221e-07,4.20461,-0.927639,0.0838127,0.363952,-0.133576,-0.984489,-0.113745,0.348774,-0.15413,0.924446},{-1.3411e-07,2.68221e-07,4.20461,-0.931579,0.094881,0.350938,-0.184422,-0.955245,-0.231292,0.313287,-0.280187,0.907385},{-1.3411e-07,5.36443e-07,4.20461,-0.934776,0.108984,0.338107,-0.2346,-0.904092,-0.357183,0.266753,-0.413206,0.870691},{0,-5.36443e-07,4.20461,-0.936512,0.122492,0.328545,-0.272038,-0.845004,-0.460396,0.221227,-0.520542,0.824678},{0,-6.70554e-08,4.20461,-0.937075,0.130807,0.323697,-0.291039,-0.804787,-0.517315,0.192839,-0.578971,0.792215},{-2.68221e-07,-2.68221e-07,4.20461,-0.937114,0.131666,0.323236,-0.292847,-0.800481,-0.522945,0.18989,-0.584717,0.7887}}},["30"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-2.68221e-07,2.68221e-07,5.62343,0.109675,-0.351937,-0.929576,0.974209,0.223606,0.030284,0.197201,-0.908923,0.367384},{2.68221e-07,2.68221e-07,5.62343,0.11393,-0.297305,-0.947961,0.95772,0.286593,0.0252203,0.264181,-0.910755,0.317387},{2.68221e-07,2.68221e-07,5.62343,0.113607,-0.227016,-0.967242,0.930919,0.364449,0.0238026,0.347106,-0.903128,0.252738},{-5.36443e-07,2.68221e-07,5.62343,0.106644,-0.235296,-0.966055,0.937969,0.346186,0.0192252,0.329911,-0.90818,0.257619},{0,-5.36443e-07,5.62343,0.0924138,-0.273625,-0.957387,0.958652,0.284358,0.0112653,0.269158,-0.918842,0.28859},{-5.36443e-07,0,5.62343,0.0962648,-0.327862,-0.939808,0.972848,0.23065,0.0191845,0.210477,-0.916137,0.341164},{-2.68221e-07,-2.68221e-07,5.62343,0.147588,-0.389654,-0.909058,0.972316,0.225512,0.0611958,0.181159,-0.892924,0.41215},{0,-1.3411e-07,5.62343,0.24713,-0.453642,-0.856234,0.958695,0.242885,0.148019,0.140819,-0.857447,0.494929},{0,-7.37608e-07,5.62343,0.367279,-0.510085,-0.777766,0.926308,0.276131,0.256328,0.0840166,-0.814595,0.573913},{0,2.68221e-07,5.62343,0.479849,-0.550869,-0.682853,0.877147,0.317985,0.359859,0.0189021,-0.77164,0.635778},{0,5.36443e-07,5.62343,0.563545,-0.573902,-0.594184,0.825146,0.356766,0.438009,-0.0393896,-0.737126,0.674606},{0,8.04661e-07,5.62343,0.606737,-0.582808,-0.54056,0.791482,0.379915,0.478769,-0.0736635,-0.718331,0.691791},{-2.68221e-07,0,5.62343,0.610887,-0.583516,-0.535095,0.787953,0.382267,0.482703,-0.0771157,-0.716506,0.693305}}},["31"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535},{0,0,3.7976,0.430966,-0.509838,0.744535,0.682327,0.724056,0.100857,-0.590506,0.46455,0.659921},{-1.3411e-07,0,3.7976,0.448683,-0.585717,0.674996,0.667455,0.721882,0.182731,-0.594296,0.368541,0.714836},{0,0,3.7976,0.467315,-0.668005,0.579126,0.647113,0.704773,0.290759,-0.60238,0.238884,0.761625},{0,0,3.7976,0.47753,-0.730544,0.488129,0.622863,0.673315,0.398357,-0.619682,0.11381,0.776557},{-3.35276e-08,0,3.7976,0.468742,-0.764428,0.44264,0.593878,0.643668,0.482701,-0.653903,0.0366119,0.755691},{3.35276e-08,-2.68221e-07,3.7976,0.386261,-0.758212,0.525278,0.580925,0.642311,0.499963,-0.716469,0.112031,0.688564},{5.02913e-08,0,3.7976,0.119697,-0.598873,0.791848,0.658567,0.644742,0.388067,-0.742941,0.475035,0.471572},{-3.35276e-08,1.3411e-07,3.7976,-0.112742,-0.311272,0.94361,0.756594,0.588703,0.284595,-0.644092,0.746015,0.169135},{0,0,3.7976,-0.152487,-0.28751,0.945561,0.760198,0.577257,0.298116,-0.631543,0.764273,0.130541},{-3.35276e-08,2.68221e-07,3.7976,-0.0405045,-0.665281,0.745494,0.634088,0.559501,0.533752,-0.772199,0.494328,0.399184},{-4.02332e-07,2.68221e-07,3.7976,0.14091,-0.898621,0.415482,0.528949,0.423084,0.735672,-0.836874,0.116105,0.534941},{-4.02332e-07,2.68221e-07,3.7976,0.165308,-0.91398,0.370558,0.518929,0.400118,0.755393,-0.838681,0.0674209,0.540433}}},["32"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-1.3411e-07,2.68221e-07,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.00929472,0.845387,-0.534073},{2.68221e-07,0,8.88873,0.383605,-0.464947,-0.797917,-0.923465,-0.200348,-0.32722,-0.00772071,0.862372,-0.506217},{-2.68221e-07,-2.68221e-07,8.88873,0.372306,-0.403406,-0.835854,-0.928103,-0.165483,-0.333528,-0.00377283,0.899933,-0.436012},{0,0,8.88873,0.353903,-0.323184,-0.87767,-0.935281,-0.120607,-0.332722,0.00167757,0.938619,-0.34495},{0,-2.68221e-07,8.88873,0.32835,-0.246837,-0.911733,-0.944528,-0.0783776,-0.318941,0.0072673,0.965882,-0.25888},{2.68221e-07,-2.68221e-07,8.88873,0.294895,-0.199946,-0.934376,-0.955475,-0.0512645,-0.290584,0.0102007,0.978465,-0.206161},{0,0,8.88873,0.255443,-0.208656,-0.94404,-0.966313,-0.0868621,-0.24227,-0.0314502,0.974124,-0.223815},{-2.68221e-07,5.36443e-07,8.88873,0.220933,-0.272077,-0.93657,-0.952397,-0.267028,-0.147094,-0.21007,0.924484,-0.31812},{0,8.04661e-07,8.88873,0.181483,-0.349499,-0.919192,-0.903865,-0.427523,-0.0159024,-0.387418,0.833711,-0.393488},{5.36443e-07,0,8.88873,0.0969105,-0.401792,-0.910588,-0.897333,-0.431072,0.0947087,-0.430583,0.807923,-0.402317},{0,-5.36443e-07,8.88873,-0.0200685,-0.437355,-0.899065,-0.929507,-0.323059,0.177902,-0.368258,0.839258,-0.400041},{2.68221e-07,1.67638e-07,8.88873,-0.104698,-0.449459,-0.887144,-0.949287,-0.220756,0.223874,-0.296465,0.865595,-0.403553},{-6.70554e-07,-1.07288e-06,8.88873,-0.114164,-0.450024,-0.885689,-0.951056,-0.208181,0.228368,-0.287155,0.868412,-0.404232}}},["11"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{0,-8.38192e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{0,-3.35276e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{-1.3411e-07,6.70554e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{0,1.50874e-07,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{-1.67638e-08,-2.01166e-07,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{0,1.50874e-07,5.59555,0.79245,-0.609018,-0.0334693,0.505346,0.686299,-0.523085,0.341539,0.397605,0.851623},{3.35276e-08,-8.38192e-09,5.59555,0.803348,-0.593538,-0.0484164,0.511415,0.729274,-0.454549,0.305101,0.3404,0.889405},{-6.70554e-08,-1.00583e-07,5.59555,0.814516,-0.576835,-0.0618541,0.514377,0.767374,-0.382824,0.268291,0.28,0.921748},{4.02332e-07,4.02332e-07,5.59555,0.812163,-0.578175,-0.0781391,0.513387,0.771847,-0.375081,0.277174,0.264511,0.923693},{-3.01748e-07,-2.68221e-07,5.59555,0.763317,-0.619589,-0.182912,0.497444,0.744359,-0.445511,0.412186,0.249077,0.876392},{-1.3411e-07,2.68221e-07,5.59555,0.698934,-0.658243,-0.279656,0.470863,0.717845,-0.512822,0.538311,0.226749,0.811668},{-1.3411e-07,2.68221e-07,5.59555,0.689932,-0.662806,-0.291001,0.466852,0.714651,-0.520887,0.553211,0.223522,0.802493}}},["12"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,-2.68221e-07,6.52923,0.991153,0.0405153,-0.126392,-0.0436665,0.998798,-0.0222602,0.125338,0.0275823,0.991731},{-2.68221e-07,-5.36443e-07,6.52923,0.991542,0.0185491,-0.128457,0.00273985,0.986523,0.163601,0.12976,-0.162569,0.978128},{0,5.36443e-07,6.52923,0.989975,-0.0153103,-0.140411,0.0777277,0.889094,0.451076,0.117933,-0.457468,0.881371},{-2.68221e-07,0,6.52923,0.989265,-0.0194761,-0.144829,0.0888534,0.866996,0.49033,0.116016,-0.497935,0.859419},{-2.68221e-07,2.68221e-07,6.52923,0.989472,0.00888404,-0.14445,0.0290793,0.965553,0.258575,0.141771,-0.260053,0.95513},{2.68221e-07,2.68221e-07,6.52923,0.98981,0.0366273,-0.137606,-0.0356552,0.999319,0.00952443,0.137861,-0.00452095,0.990441},{5.36443e-07,-2.68221e-07,6.52923,0.9966,0.0415388,-0.0711539,-0.0434289,0.998738,-0.0252253,0.0700163,0.0282296,0.997146},{0,0,6.52923,0.99162,0.0326094,0.125009,-0.030616,0.999372,-0.0178346,-0.125512,0.0138579,0.991995},{0,0,6.52923,0.935029,-0.0230256,0.353822,0.00613579,0.998791,0.0487831,-0.354518,-0.0434426,0.93404},{2.68221e-07,0,6.52923,0.856995,-0.168291,0.48707,0.0592841,0.971094,0.23122,-0.511903,-0.169279,0.842199},{8.04661e-07,0,6.52923,0.809244,-0.347213,0.473885,0.0878258,0.869088,0.486799,-0.58087,-0.35232,0.733799},{5.36443e-07,5.36443e-07,6.52923,0.801517,-0.387165,0.455711,0.0915124,0.832538,0.546357,-0.590928,-0.396211,0.702724},{-2.68221e-07,5.36443e-07,6.52923,0.801517,-0.387165,0.455711,0.0915124,0.832538,0.546357,-0.590928,-0.396211,0.702724}}},["13"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-5.36443e-07,-5.36443e-07,6.20212,0.649888,0.661611,0.374055,-0.759687,0.550692,0.345853,0.0228313,-0.50893,0.860505},{5.36443e-07,0,6.20212,0.652825,0.653013,0.383918,-0.756786,0.540096,0.3682,0.0330864,-0.530914,0.84678},{-2.68221e-07,-3.68802e-07,6.20212,0.657844,0.638558,0.399355,-0.751528,0.521721,0.403748,0.0494643,-0.56573,0.823106},{5.36443e-07,2.68221e-07,6.20212,0.658936,0.63641,0.400983,-0.750352,0.518792,0.409668,0.0526899,-0.570822,0.819381},{-5.36443e-07,-5.36443e-07,6.20212,0.656619,0.648845,0.384516,-0.752928,0.534046,0.38457,0.0441771,-0.542029,0.839198},{5.36443e-07,-5.36443e-07,6.20212,0.652236,0.66042,0.372067,-0.757441,0.548715,0.35383,0.0295182,-0.512599,0.858121},{5.36443e-07,-5.36443e-07,6.20212,0.644578,0.66097,0.384236,-0.764465,0.55021,0.335952,0.0106437,-0.510282,0.859942},{0,0,6.20212,0.612056,0.659679,0.436132,-0.789842,0.53728,0.295769,-0.0392124,-0.525503,0.849888},{0,-5.36443e-07,6.20212,0.500583,0.652674,0.568712,-0.850097,0.494733,0.180487,-0.163561,-0.573809,0.80249},{-5.36443e-07,6.70554e-08,6.20212,0.198615,0.616126,0.762195,-0.912153,0.400683,-0.0862039,-0.358511,-0.678117,0.641582},{2.68221e-07,-4.02332e-07,6.20212,-0.19616,0.553541,0.809391,-0.885498,0.254566,-0.388702,-0.421206,-0.792962,0.440224},{-2.68221e-07,1.07288e-06,6.20212,0.351731,0.447625,0.822142,-0.836035,0.545299,0.0607803,-0.421106,-0.708718,0.566029},{1.00583e-07,0,6.20212,0.351731,0.447625,0.822142,-0.836035,0.545299,0.0607804,-0.421106,-0.708718,0.566029}}},["14"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,-5.36443e-07,5.60288,0.635823,0.768833,0.0680112,-0.581752,0.419463,0.696861,0.507241,-0.482646,0.713974},{-4.02332e-07,0,5.60288,0.672218,0.735751,-0.0824226,-0.63517,0.630327,0.44637,0.38037,-0.247706,0.891044},{-1.07288e-06,0,5.60288,0.765715,0.582908,-0.271844,-0.621476,0.779413,-0.0792656,0.165674,0.229639,0.959072},{0,0,5.60288,0.782413,0.546991,-0.297708,-0.606771,0.777206,-0.166676,0.14021,0.31105,0.939994},{-2.68221e-07,-5.36443e-07,5.60288,0.705418,0.671176,-0.227832,-0.633371,0.741191,0.222435,0.31816,-0.0126068,0.947953},{-4.02332e-07,2.68221e-07,5.60288,0.641508,0.766726,-0.0244608,-0.588545,0.512378,0.625367,0.492018,-0.386782,0.779947},{0,-2.68221e-07,5.60288,0.634334,0.750349,0.186002,-0.600004,0.326154,0.730493,0.487459,-0.574978,0.657102},{0,0,5.60288,0.633274,0.706197,0.316623,-0.649251,0.262091,0.71399,0.421234,-0.657719,0.624474},{0,-1.07288e-06,5.60288,0.651579,0.654853,0.382899,-0.678197,0.276747,0.680779,0.339844,-0.703262,0.624442},{5.36443e-07,1.07288e-06,5.60288,0.716588,0.573739,0.396642,-0.642737,0.322298,0.694991,0.270907,-0.752959,0.599719},{-5.36443e-07,0,5.60288,0.806385,0.452408,0.380881,-0.558972,0.37275,0.740681,0.193116,-0.810176,0.553463},{-1.87755e-06,0,5.60288,0.826954,0.419687,0.374181,-0.535179,0.38343,0.752705,0.172429,-0.822706,0.541686},{2.68221e-07,-1.07288e-06,5.60288,0.826954,0.419687,0.374181,-0.535179,0.38343,0.752705,0.172429,-0.822706,0.541686}}},["15"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,-0.00239779,-0.473524,-0.880778,0.557685,0.73046,-0.394228,0.830049,-0.492142,0.262326},{0,-8.38192e-08,5.59555,-0.0413705,-0.519509,-0.853463,0.556408,0.697506,-0.451547,0.829878,-0.493555,0.260203},{0,-3.35276e-08,5.59555,-0.0902548,-0.574221,-0.81371,0.551132,0.651737,-0.52105,0.829523,-0.495489,0.257649},{-1.3411e-07,6.70554e-08,5.59555,-0.0808,-0.560987,-0.823872,0.55602,0.660644,-0.504373,0.827232,-0.498843,0.25854},{0,1.50874e-07,5.59555,-0.0459566,-0.51648,-0.855065,0.566353,0.691634,-0.448204,0.822881,-0.504866,0.260725},{-1.67638e-08,-2.01166e-07,5.59555,-0.0108338,-0.478123,-0.878226,0.564628,0.721938,-0.400002,0.825274,-0.500205,0.26214},{0,1.50874e-07,5.59555,0.00349699,-0.485445,-0.87426,0.540024,0.73674,-0.406925,0.841642,-0.470699,0.264728},{3.35276e-08,-8.38192e-09,5.59555,-0.00267802,-0.522769,-0.85247,0.489406,0.742718,-0.457002,0.872052,-0.418428,0.253857},{-6.70554e-08,-1.00583e-07,5.59555,-0.0371332,-0.529626,-0.847418,0.404237,0.767564,-0.497432,0.9139,-0.361029,0.185592},{4.02332e-07,4.02332e-07,5.59555,-0.0925534,-0.529791,-0.843063,0.294557,0.794232,-0.531442,0.951141,-0.297517,0.0825449},{-3.01748e-07,-2.68221e-07,5.59555,-0.147596,-0.531251,-0.834259,0.190997,0.81231,-0.551066,0.970431,-0.240676,-0.0184265},{-1.3411e-07,2.68221e-07,5.59555,-0.181695,-0.533063,-0.826336,0.127918,0.82037,-0.557342,0.974999,-0.206969,-0.0808693},{-1.3411e-07,2.68221e-07,5.59555,-0.185267,-0.533284,-0.8254,0.121395,0.821087,-0.557745,0.975161,-0.203531,-0.0873824}}},["16"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{2.68221e-07,0,4.04298,0.788188,0.225403,-0.572671,-0.555192,0.661933,-0.503594,0.265559,0.71487,0.646869},{-2.68221e-07,-1.3411e-07,4.04298,0.829935,0.148694,-0.537678,-0.506068,0.606242,-0.613487,0.234742,0.781256,0.578391},{0,2.68221e-07,4.04298,0.876768,0.0578315,-0.477423,-0.435213,0.517799,-0.736529,0.204615,0.853545,0.479159},{5.36443e-07,2.68221e-07,4.04298,0.8673,0.0661888,-0.493366,-0.447421,0.538077,-0.714344,0.218188,0.840293,0.496288},{0,1.3411e-07,4.04298,0.832384,0.114318,-0.54228,-0.491597,0.604068,-0.627244,0.255869,0.788691,0.559015},{-5.36443e-07,-4.02332e-07,4.04298,0.796606,0.191051,-0.573515,-0.538532,0.655259,-0.529734,0.274595,0.730845,0.62487},{2.68221e-07,1.3411e-07,4.04298,0.818182,0.295589,-0.493158,-0.551143,0.647516,-0.526274,0.163767,0.702389,0.692698},{5.36443e-07,5.36443e-07,4.04298,0.875184,0.421552,-0.237376,-0.468417,0.61565,-0.633688,-0.120992,0.665784,0.736269},{2.68221e-07,2.68221e-07,4.04298,0.875302,0.440083,-0.200432,-0.463911,0.647187,-0.604926,-0.136501,0.622475,0.770644},{5.36443e-07,2.68221e-07,4.04298,0.871904,0.410314,-0.267257,-0.489565,0.718767,-0.493659,-0.0104599,0.561263,0.827571},{5.36443e-07,-4.02332e-07,4.04298,0.854483,0.374289,-0.360231,-0.497562,0.788985,-0.360464,0.149299,0.487248,0.860406},{0,-6.70554e-08,4.04298,0.833318,0.35309,-0.425332,-0.489276,0.829207,-0.27023,0.257273,0.433292,0.863753},{0,2.01166e-07,4.04298,0.830545,0.350952,-0.432467,-0.487722,0.833232,-0.260485,0.268928,0.427268,0.863203}}},["17"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,0,4.30251,0.861801,0.100392,0.497213,-0.022361,0.986785,-0.160484,-0.506753,0.127187,0.852657},{0,0,4.30251,0.939075,0.0898616,0.331756,-0.0428765,0.988306,-0.146332,-0.341026,0.123192,0.931947},{0,0,4.30251,0.99117,0.0779268,0.107279,-0.0644876,0.990247,-0.123497,-0.115857,0.115488,0.986529},{0,2.68221e-07,4.30251,0.985262,0.0803454,0.151012,-0.0613417,0.990063,-0.126542,-0.159678,0.115414,0.980399},{0,-5.36443e-07,4.30251,0.947164,0.0889016,0.308183,-0.0475314,0.989116,-0.139248,-0.317208,0.117243,0.941081},{0,2.68221e-07,4.30251,0.882504,0.0978564,0.460011,-0.029073,0.987594,-0.154312,-0.469405,0.122807,0.874401},{-2.68221e-07,-5.36443e-07,4.30251,0.845062,0.108806,0.52348,-0.00266398,0.979919,-0.199378,-0.534661,0.167092,0.828383},{5.36443e-07,0,4.30251,0.840601,0.129613,0.525918,0.0420842,0.952384,-0.301981,-0.540017,0.275979,0.795121},{5.36443e-07,-5.36443e-07,4.30251,0.84322,0.130811,0.52141,0.0463613,0.948632,-0.312966,-0.535566,0.288073,0.793841},{0,5.36443e-07,4.30251,0.852616,0.122966,0.507864,0.0370241,0.955258,-0.293449,-0.521225,0.269002,0.809915},{0,6.03497e-07,4.30251,0.864098,0.113567,0.490345,0.0257845,0.962945,-0.268462,-0.502663,0.244621,0.82915},{0,-2.01166e-07,4.30251,0.871824,0.107367,0.477907,0.0183361,0.967843,-0.250886,-0.489476,0.227492,0.84182},{5.36443e-07,-4.35859e-07,4.30251,0.872665,0.106699,0.47652,0.0175316,0.968362,-0.248934,-0.488005,0.22559,0.843184}}},["18"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,0,5.37487,0.0344749,0.382786,-0.923193,0.994184,0.0811702,0.0707818,0.10203,-0.920264,-0.377761},{0,0,5.37488,0.0617846,0.286257,-0.956159,0.995662,0.0490974,0.0790362,0.0695696,-0.956894,-0.281982},{1.07288e-06,0,5.37487,0.0911987,0.15919,-0.983027,0.995523,0.0100556,0.0939865,0.0248466,-0.987197,-0.15756},{-1.07288e-06,0,5.37487,0.0918054,0.167065,-0.981662,0.995468,0.00915237,0.0946542,0.0247978,-0.985904,-0.165467},{0,5.36443e-07,5.37487,0.0839488,0.223815,-0.97101,0.995686,0.0198158,0.0906498,0.03953,-0.97443,-0.221186},{5.36443e-07,5.36443e-07,5.37487,0.0556448,0.327932,-0.943061,0.995384,0.0557573,0.0781207,0.0782008,-0.943055,-0.323316},{5.36443e-07,0,5.37487,-0.158538,0.469286,-0.868698,0.985319,0.131644,-0.108705,0.0633447,-0.873179,-0.483266},{5.36443e-07,1.07288e-06,5.37487,-0.625386,0.534093,-0.568891,0.759001,0.24712,-0.60237,-0.181137,-0.808503,-0.559922},{5.36443e-07,0,5.37487,-0.652071,0.5189,-0.552762,0.737474,0.264976,-0.621225,-0.175886,-0.81273,-0.555458},{0,1.3411e-07,5.37487,-0.473291,0.44847,-0.758201,0.880851,0.250541,-0.40166,0.00982815,-0.857965,-0.513615},{-1.3411e-07,-2.68221e-07,5.37487,-0.165769,0.349221,-0.922261,0.962737,0.259943,-0.0746149,0.213678,-0.900264,-0.379298},{6.70554e-08,-6.70554e-07,5.37487,0.0669111,0.282916,-0.956808,0.946627,0.285046,0.150484,0.315309,-0.91581,-0.248743},{2.68221e-07,1.3411e-07,5.37487,0.0922322,0.276062,-0.956704,0.941514,0.288555,0.174032,0.324105,-0.916802,-0.233302}}},["19"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},{0,-8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262326},{0,-3.35276e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262326},{-1.3411e-07,6.70554e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},{0,1.50874e-07,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},{-1.67638e-08,-2.01166e-07,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},{0,1.50874e-07,5.59555,-0.066396,0.562471,0.824147,-0.556633,0.664619,-0.498439,-0.828101,-0.491841,0.268962},{3.35276e-08,-8.38192e-09,5.59555,-0.0789669,0.618504,0.781803,-0.570015,0.61538,-0.544417,-0.817831,-0.488631,0.303962},{-6.70554e-08,-1.00583e-07,5.59555,-0.100502,0.697879,0.709129,-0.588472,0.533006,-0.607952,-0.802247,-0.478403,0.357115},{4.02332e-07,4.02332e-07,5.59555,-0.126999,0.774628,0.619534,-0.605558,0.434136,-0.666952,-0.785602,-0.459866,0.413947},{-3.01748e-07,-2.68221e-07,5.59555,-0.151848,0.830848,0.535383,-0.617344,0.343291,-0.70784,-0.771899,-0.437999,0.460791},{-1.3411e-07,2.68221e-07,5.59555,-0.167006,0.858985,0.483998,-0.622878,0.288606,-0.727138,-0.764285,-0.422908,0.486844},{-1.3411e-07,2.68221e-07,5.59555,-0.16857,0.861646,0.478696,-0.623384,0.282994,-0.728908,-0.763529,-0.421283,0.489433}}},["20"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-5.36443e-07,-1.3411e-07,4.04298,0.896552,-0.18038,0.404545,0.407723,0.692959,-0.594617,-0.173076,0.698047,0.69482},{-5.36443e-07,-2.68221e-07,4.04298,0.771153,-0.459342,0.440827,0.552624,0.826759,-0.105239,-0.316117,0.324767,0.891401},{5.36443e-07,-2.68221e-07,4.04298,0.783803,-0.608757,0.122751,0.533999,0.761589,0.367189,-0.317015,-0.222254,0.922011},{0,2.68221e-07,4.04298,0.783803,-0.608757,0.122751,0.533999,0.761589,0.367189,-0.317015,-0.222254,0.922011},{-2.68221e-07,-2.68221e-07,4.04298,0.801606,-0.538691,0.259305,0.533238,0.840346,0.0973388,-0.270342,0.0602438,0.960878},{0,-2.68221e-07,4.04298,0.870713,-0.254304,0.420938,0.455822,0.738632,-0.496637,-0.184622,0.624301,0.759054},{2.68221e-07,-2.68221e-07,4.04298,0.926537,-0.123452,0.355372,0.338957,0.683752,-0.646212,-0.16321,0.719195,0.675367},{0,0,4.04298,0.959139,-0.0517272,0.278165,0.240773,0.665561,-0.70644,-0.148593,0.744549,0.65082},{5.36443e-07,-1.3411e-07,4.04298,0.977085,-0.0043656,0.212803,0.164588,0.649442,-0.742385,-0.134962,0.760399,0.635279},{5.36443e-07,-1.3411e-07,4.04298,0.98636,0.0241561,0.162823,0.110126,0.638345,-0.761832,-0.12234,0.769371,0.626977},{8.04661e-07,-2.68221e-07,4.04298,0.990791,0.0388592,0.129703,0.0760912,0.632553,-0.77077,-0.111995,0.773541,0.623771},{0,0,4.04298,0.992505,0.0441279,0.113961,0.0607839,0.630741,-0.77361,-0.106018,0.774738,0.623331},{0,-1.3411e-07,4.04298,0.992648,0.0444855,0.112562,0.0594813,0.630652,-0.773783,-0.10541,0.77479,0.623369}}},["21"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{0,0,4.30251,0.909555,-0.11628,-0.398984,0.0479311,0.983003,-0.177221,0.41281,0.142068,0.89967},{-2.68221e-07,0,4.30251,0.721332,-0.214971,-0.658382,-0.239089,0.814882,-0.528019,0.650012,0.538289,0.536403},{0,-5.36443e-07,4.30251,0.758688,-0.210086,-0.616649,-0.152148,0.863253,-0.481296,0.633437,0.458975,0.622976},{0,2.68221e-07,4.30251,0.667214,-0.35345,-0.655666,-0.0696284,0.846798,-0.527338,0.741605,0.3975,0.540385},{5.36443e-07,1.07288e-06,4.30251,0.747026,-0.285026,-0.600594,-0.00771165,0.899651,-0.436542,0.664751,0.33074,0.669864},{0,0,4.30251,0.892086,-0.143982,-0.428312,0.0561112,0.975837,-0.211171,0.448368,0.164349,0.87861},{-5.36443e-07,0,4.30251,0.911436,-0.0933631,-0.400709,0.0198638,0.982763,-0.183797,0.410962,0.15956,0.897581},{0,-5.36443e-07,4.30251,0.909769,-0.0606101,-0.410666,-0.0343379,0.974905,-0.219957,0.413692,0.214211,0.884858},{5.36443e-07,0,4.30251,0.903552,-0.0355578,-0.427,-0.0919247,0.95726,-0.274232,0.418501,0.287035,0.861666},{0,0,4.30251,0.894999,-0.018803,-0.445671,-0.145606,0.932069,-0.331732,0.421634,0.361793,0.831463},{5.36443e-07,-5.36443e-07,4.30251,0.886812,-0.00968914,-0.462028,-0.187729,0.906019,-0.379325,0.422281,0.423126,0.80165},{1.07288e-06,2.68221e-07,4.30251,0.881819,-0.00632728,-0.471545,-0.210798,0.889166,-0.406137,0.421851,0.457541,0.78275},{-1.07288e-06,-1.3411e-07,4.30251,0.881307,-0.00608473,-0.472506,-0.213061,0.887393,-0.408824,0.421786,0.460972,0.78077}}},["22"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.5},["poses"]={{-1.07288e-06,1.07288e-06,5.37487,-0.00271533,-0.356721,0.934207,-0.997549,0.0662763,0.0224076,-0.0699091,-0.931857,-0.356027},{5.36443e-07,0,5.37487,-0.0785788,-0.524844,0.847564,-0.994807,0.096443,-0.0325089,-0.0646796,-0.845717,-0.529697},{1.07288e-06,-1.07288e-06,5.37487,0.192691,-0.495637,0.846885,-0.736356,0.497411,0.458651,-0.648575,-0.711987,-0.269119},{-5.36443e-07,1.07288e-06,5.37488,0.23049,-0.500693,0.834375,-0.714752,0.494741,0.494329,-0.660306,-0.710309,-0.243839},{5.36443e-07,-1.07288e-06,5.37488,0.197731,-0.460784,0.865206,-0.830307,0.39043,0.397687,-0.52105,-0.797021,-0.305392},{5.36443e-07,0,5.37487,0.0586056,-0.384844,0.921119,-0.985381,0.125556,0.115151,-0.159967,-0.914402,-0.37186},{0,0,5.37487,-0.0809019,-0.307772,0.948014,-0.99672,0.026676,-0.0763982,-0.00177601,-0.951086,-0.308921},{-5.36443e-07,0,5.37488,-0.184835,-0.209944,0.960083,-0.980064,-0.0330658,-0.195912,0.0728763,-0.977154,-0.199647},{0,0,5.37488,-0.259468,-0.100839,0.960473,-0.959691,-0.0843211,-0.26811,0.108024,-0.991323,-0.0748956},{-1.07288e-06,0,5.37487,-0.308048,0.0053722,0.951356,-0.944191,-0.124351,-0.305026,0.116663,-0.992224,0.0433784},{2.68221e-07,5.36443e-07,5.37488,-0.334406,0.0917832,0.937949,-0.935751,-0.150607,-0.318885,0.111993,-0.984324,0.13625},{-8.04661e-07,5.36443e-07,5.37487,-0.34405,0.140519,0.928377,-0.932983,-0.162463,-0.321167,0.105697,-0.976657,0.186998},{5.36443e-07,0,5.37487,-0.344711,0.145393,0.927381,-0.932829,-0.163454,-0.321111,0.104897,-0.975778,0.191972}}}}}
]====])
-- Source: src/client/world/dragon/Geometry.luau
addModule(modules,{"world","dragon","Geometry"},[====[
-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.
return {["positions"]={{-1.03091,9.04277,-8.16286},{-1.15374,8.94686,-6.68291},{-1.23349,7.34346,-6.36696},{-1.27961,5.92887,-6.19577},{-1.34678,4.73052,-6.39399},{-1.42565,3.34297,-6.92559},{-1.64748,1.58059,-7.39952},{-1.87472,0.196634,-7.77794},{-2.2561,-1.24138,-7.4752},{-2.60622,-2.54441,-6.99263},{-1.1553,9.5934,-11.0743},{-1.00011,9.65258,-9.61601},{-1.56037,9.26334,-8.16286},{-1.72321,9.67852,-6.51508},{-1.38198,10.4228,-6.60677},{-0.909728,9.09882,-5.16314},{-1.21807,8.1522,-5.28562},{-1.38641,6.8537,-5.21037},{-1.61402,4.06677,-5.09412},{-2.38657,2.02313,-4.35654},{-0.455868,11.3925,-11.5969},{-1.19078,8.92089,-12.002},{-0.936187,8.37596,-13.4681},{-1.194,8.13254,-12.0761},{-1.71388,6.70743,-10.362},{-0.424637,9.81396,-13.5005},{-0.500918,10.8519,-12.3717},{-0.370473,9.01387,-14.1384},{-1.25942,9.09672,-9.95946},{-0.879698,7.48071,-12.8946},{-0.778933,9.59989,-12.8129},{-1.37306,10.5751,-11.5608},{-1.27837,10.5894,-10.0605},{-1.02845,7.36438,-11.2179},{-1.09115,7.79729,-10.3205},{-2.25928,8.68216,-11.0937},{-1.92197,12.0036,-11.2365},{-1.94136,8.8638,-10.6656},{-1.94136,8.52646,-11.6257},{-1.39542,10.3494,-10.865},{-2.09616,15.376,-5.76063},{-1.6519,13.4176,-9.15342},{-1.07198,11.4384,-9.14367},{-0.875436,11.6842,-11.2797},{-2.21094,14.6235,-6.16284},{-1.88997,13.089,-8.53588},{-1.66286,11.4966,-10.172},{-1.19307,10.4804,-8.29859},{-1.19307,11.6222,-6.70013},{-0.701992,11.3108,-6.53145},{-0.645251,11.6155,-8.59684},{-0.525372,8.61469,-9.91176},{-1.4142,10.6621,-8.31156},{-0.358073,6.55563,-13.0248},{-0.786891,7.09623,-12.0841},{-1.4902,8.90705,-10.5781},{-1.44013,8.44249,-11.6706},{-0.949285,11.7034,-10.0938},{-1.42247,12.8085,-8.08494},{-1.84421,14.224,-6.31072},{-1.22369,13.2392,-8.90047},{-0.302405,-1.33339,11.8803},{-0.30071,-2.51423,13.9687},{-0.451626,-3.40206,15.6368},{-1.6614,-0.169091,7.19789},{-2.56748,-0.869332,7.28134},{-3.93769,-0.348661,-5.23573},{-4.07099,0.73111,-2.76536},{-2.27711,1.04024,-0.284134},{-0.535734,1.84946,2.74004},{-2.67934,-4.14748,7.00282},{-2.48181,-0.0425377,3.88185},{-4.00764,-0.981744,-0.687684},{-2.94612,-3.49054,-6.10032},{-3.2407,-4.27075,-4.91653},{-3.38403,-4.76596,-3.53434},{-3.26226,-4.78193,-1.93018},{-3.0968,-4.5667,-0.880919},{-2.53052,-4.21694,0.921652},{-2.74771,-5.56835,4.63424},{-1.44804,-4.11755,8.48768},{-3.81066,-2.70031,-5.98099},{-3.86025,-3.40444,-0.940108},{-2.55577,-2.07459,2.10468},{-2.64266,-3.38524,1.52615},{-4.24291,3.11632,1.66581},{-2.51745,0.461057,1.71499},{-2.58316,-0.547844,0.388472},{-1.43628,1.33305,1.10831},{-3.62663,1.63604,2.78998},{-2.51113,-1.26529,1.64773},{-1.72433,0.73926,3.06636},{-2.48151,0.792771,-6.84784},{-2.78061,-0.0462413,-6.84099},{-2.36549,2.66111,-7.53342},{-1.80287,2.54012,-6.38068},{-2.53181,0.826064,-8.00135},{-2.92761,-0.604703,-7.96098},{-1.25756,2.0755,-2.14066},{-2.05053,1.8245,-3.28754},{-1.06988,1.94246,-0.647464},{-0.384875,-3.32433,18.0265},{-0.382605,-3.24499,18.4625},{-0.569978,-2.53714,24.656},{-0.759655,-3.17785,21.0737},{-0.60355,-1.57158,22.8124},{-0.743227,-4.28391,15.6032},{-0.743227,-4.09334,14.8558},{-0.976288,-4.80704,15.0464},{-0.811844,-4.70989,18.2562},{-0.743227,-4.23533,17.834},{-0.743227,-4.17555,18.7868},{-0.716117,-1.77709,21.4485},{-0.883801,-0.742036,23.393},{-0.790385,0.152525,22.5882},{-2.0128,-1.37727,23.9857},{-1.38808,-1.99706,9.89726},{-1.19998,-3.81309,12.0757},{-1.2006,-2.60988,11.17},{-0.743227,-2.87892,12.3224},{-1.40699,-3.34226,9.77769},{-2.80186,1.23093,22.4761},{-1.7304,-3.34227,8.90704},{-1.77691,-1.99706,8.42127},{-2.1795,-1.99706,11.5907},{-1.95391,-2.60988,12.2999},{-2.4685,-1.90364,9.69175},{-1.47188,-4.09334,15.7713},{-1.30373,-4.23533,18.5066},{-5.39781,-0.55826,-4.65421},{-6.10451,-2.27199,-3.60918},{-4.33591,-6.3978,-4.27123},{-4.25075,-9.07976,-5.57946},{-5.84094,-0.99149,-2.4068},{-6.96988,1.23207,0.501107},{-5.61703,-0.666381,-0.81976},{-6.62339,-0.964162,-0.00537408},{-6.20295,-2.11878,-1.96878},{-4.98417,-2.94832,-0.780522},{-6.42482,0.578469,-1.28088},{-6.55587,2.49007,-0.533545},{-5.428,0.795826,-2.49169},{-5.48988,-0.68135,-7.91713},{-5.60885,-2.86744,-9.01713},{-5.35761,-2.94822,-6.49799},{-5.67882,-2.37661,-5.17859},{-5.03681,-4.32776,-6.50255},{-5.69288,-4.69507,-3.11221},{-4.32246,-2.89217,-6.68482},{-4.29794,-4.02823,-6.40796},{-5.66295,-4.159,-1.07198},{-4.91643,-4.43178,-0.45543},{-5.0336,-7.30693,-1.41321},{-5.39562,-7.95711,-2.10471},{-4.71604,-8.49519,-1.54773},{-5.40228,-8.51388,-2.27856},{-5.80767,-10.3785,-2.71419},{-6.16871,-5.53772,-2.21542},{-6.33851,-9.45925,-3.21429},{-4.81967,-9.45863,-6.76058},{-4.92618,-10.6689,-7.95454},{-5.47694,-10.6351,-6.85358},{-6.13022,-10.5568,-7.87656},{-6.26746,-10.6351,-6.68677},{-6.99208,-10.5568,-7.22045},{-6.87838,-10.6351,-6.097},{-4.50467,-10.6351,-6.88484},{-3.77376,-10.6689,-7.62337},{-3.69205,-10.6351,-6.52056},{-5.80354,-9.55377,-6.62046},{-6.58906,-9.5676,-6.36387},{-3.98216,-9.51434,-6.64854},{-6.45984,-10.6774,-3.60387},{-3.83376,-6.59449,-3.07985},{-3.62508,-9.53055,-4.15445},{-4.02223,-6.38427,-1.94906},{-3.58018,-9.68749,-2.91687},{-4.22496,-7.89732,-2.07087},{-4.21897,-8.55124,-2.2577},{-3.97727,-3.94602,-1.09066},{-4.46635,-10.3785,-2.71419},{-4.04904,-10.6774,-3.61944},{-6.10398,-10.7152,-3.64865},{-4.62699,-10.7152,-3.75735},{-4.95413,0.44338,-1.82842},{-5.83689,-9.07976,-5.57946},{-5.49571,-6.3978,-4.12628},{-3.65253,4.57108,3.95601},{-3.82152,-0.71109,2.28709},{-3.82189,-0.829257,1.20908},{-3.84812,-2.19218,0.28493},{-3.65226,-3.8564,0.952688},{-3.13282,-4.97574,2.61161},{-3.66036,-5.84498,2.14932},{-4.29805,-6.55157,4.35376},{-4.93673,-8.41626,5.94614},{-3.91631,4.76873,6.88161},{-3.80302,-0.394864,6.1763},{-3.69909,1.75044,9.83933},{-3.9431,-2.85175,7.06193},{-3.90335,-2.02589,9.69581},{-4.03172,-4.69353,7.18791},{-4.0001,-4.35421,9.23814},{-3.27498,-5.75425,7.71246},{-3.3095,-6.00576,8.42993},{-5.36907,-6.68781,8.58216},{-4.61812,-6.72889,9.74925},{-5.39943,-7.31895,8.81984},{-5.6024,-9.49574,9.236},{-6.29739,-10.4815,8.24865},{-6.2979,-10.4011,6.08052},{-5.38648,-9.14483,6.07971},{-5.58774,-10.3779,5.08482},{-5.54207,-2.77778,2.86765},{-5.24053,-0.974195,3.35721},{-5.27028,-1.70585,4.90766},{-4.97537,-4.3686,6.20226},{-5.32377,-3.91646,4.92047},{-5.37582,-5.59634,5.886},{-6.06729,-8.55803,6.47795},{-5.36319,-5.33382,7.1511},{-6.09098,-9.05047,8.30165},{-5.35647,-4.59619,4.70381},{-5.16228,-10.446,5.51838},{-4.74028,-10.4154,4.75074},{-4.29132,-10.4835,5.45104},{-3.81304,-10.4592,4.73727},{-3.55556,-10.5215,5.39437},{-3.07146,-10.4987,4.98397},{-2.54134,-10.5647,5.69893},{-4.57967,-9.18329,5.74417},{-3.68524,-9.26718,5.81289},{-2.97101,-9.43948,5.97897},{-3.54445,-8.45866,5.96912},{-3.04214,-6.6353,4.48068},{-3.76888,-7.12979,8.65993},{-4.04418,-9.46502,9.1922},{-2.91545,-8.59711,7.38644},{-2.7575,-5.75522,6.32897},{-2.66663,-10.5491,7.96771},{-2.40537,3.63749,-2.01445},{-2.8884,4.16412,-2.1983},{-2.53998,4.65772,-1.36241},{-3.15062,5.18963,-1.8061},{-3.01807,5.61161,-1.05917},{-3.69493,6.37933,-1.67539},{-3.62425,6.75897,-0.7597},{-4.70808,8.61899,-0.373385},{-3.53771,7.44735,2.66486},{-3.31561,6.88732,5.67271},{-2.88568,5.77077,6.94249},{-2.99458,6.21252,4.73483},{-2.8214,5.04554,2.54475},{-2.10475,3.27183,2.65948},{-2.30708,4.04402,0.828023},{-1.63347,3.31766,-0.460838},{-2.3768,6.26788,0.667791},{-1.55457,4.96143,-0.548556},{-2.69574,6.01808,0.967451},{-2.82984,6.46563,4.69728},{-0.378324,8.20246,-12.1293},{1.07288e-05,8.23438,-9.82468},{1.12653e-05,8.15437,-8.55642},{1.12653e-05,7.43579,-7.80774},{1.12653e-05,7.47332,-7.64256},{1.12653e-05,6.66241,-7.31218},{1.12653e-05,6.4747,-7.08693},{1.12653e-05,5.24932,-7.38426},{1.12653e-05,4.97001,-7.25812},{1.12653e-05,4.01494,-7.76269},{1.12653e-05,3.78068,-7.58249},{1.12653e-05,2.60035,-8.37538},{1.12653e-05,2.35708,-8.2132},{1.12653e-05,1.08665,-8.76282},{1.12653e-05,0.834368,-8.46548},{1.07288e-05,-0.765828,-9.11421},{1.12653e-05,-0.949635,-8.89797},{1.12653e-05,-2.44171,-8.99528},{1.12653e-05,-2.54983,-8.80066},{1.12653e-05,-4.02028,-8.44386},{1.12653e-05,-3.97703,-8.20599},{1.12653e-05,-5.43667,-7.47076},{1.12653e-05,-5.25287,-7.25452},{1.12653e-05,-6.31246,-6.08681},{1.12653e-05,-6.12865,-5.92463},{1.15335e-05,-7.02606,-4.23794},{1.15335e-05,-6.74494,-4.05413},{1.15335e-05,-6.78819,-2.16201},{1.15335e-05,-6.46383,-2.11876},{1.1567e-05,-6.09621,-0.410438},{1.1567e-05,-5.86916,-0.410438},{1.16006e-05,-5.95565,0.876205},{1.16006e-05,-5.76104,0.887015},{1.18017e-05,-5.65479,5.11456},{1.18017e-05,-4.89209,8.59767},{1.03094,9.04277,-8.16286},{1.15376,8.94686,-6.68291},{1.23352,7.34346,-6.36696},{1.27964,5.92887,-6.19577},{1.3468,4.73052,-6.39399},{1.42567,3.34297,-6.92559},{1.6475,1.58059,-7.39952},{1.87475,0.196634,-7.77794},{2.25612,-1.24138,-7.4752},{2.60624,-2.54441,-6.99263},{1.15532,9.5934,-11.0743},{1.00013,9.65258,-9.61601},{1.5604,9.26334,-8.16286},{1.72323,9.67852,-6.51508},{1.15335e-05,11.3674,-4.25318},{1.12653e-05,10.2364,-4.49106},{1.12653e-05,11.3051,-5.76342},{1.12653e-05,12.1225,-5.75045},{1.12653e-05,11.7099,-6.36285},{1.382,10.4228,-6.60677},{1.15335e-05,9.43201,-3.02233},{1.15335e-05,8.65353,-3.72556},{0.909751,9.09882,-5.16314},{1.15335e-05,7.81278,-3.08721},{1.15335e-05,7.06545,-3.74113},{1.15335e-05,6.16242,-2.97822},{1.15335e-05,5.69533,-3.58543},{1.15335e-05,5.07255,-3.62435},{1.2181,8.1522,-5.28562},{1.38643,6.8537,-5.21037},{1.61405,4.06677,-5.09412},{1.15335e-05,4.80787,-3.23512},{1.15335e-05,4.09168,-3.67106},{1.15335e-05,3.54675,-2.98341},{1.15335e-05,2.71637,-3.07423},{2.38659,2.02313,-4.35654},{1.12653e-05,12.971,-6.04627},{1.12653e-05,12.0836,-7.69663},{0.45589,11.3925,-11.5969},{1.07288e-05,11.4488,-13.4616},{1.07288e-05,10.6184,-12.9426},{1.07288e-05,10.2032,-13.3448},{1.07288e-05,10.5016,-14.6553},{1.07288e-05,9.68206,-14.0498},{1.07288e-05,9.29066,-14.4455},{1.07288e-05,9.11118,-15.3278},{1.07288e-05,8.8625,-14.4455},{1.07288e-05,8.15539,-13.8184},{1.1908,8.92089,-12.002},{0.936209,8.37596,-13.4681},{1.19402,8.13254,-12.0761},{1.07288e-05,7.34578,-13.4914},{1.07288e-05,6.30262,-13.4759},{1.07288e-05,4.90137,-14.0519},{1.07288e-05,6.55952,-12.6066},{1.07288e-05,11.4488,-12.056},{1.71391,6.70743,-10.362},{1.07288e-05,7.6416,-10.2686},{0.424658,9.81396,-13.5005},{0.50094,10.8519,-12.3717},{1.07288e-05,12.0347,-9.07732},{0.370494,9.01387,-14.1384},{1.25944,9.09672,-9.95946},{0.879719,7.48071,-12.8946},{0.778954,9.59989,-12.8129},{1.37308,10.5751,-11.5608},{1.27839,10.5894,-10.0605},{1.02848,7.36438,-11.2179},{1.09118,7.79729,-10.3205},{2.2593,8.68216,-11.0937},{1.92199,12.0036,-11.2365},{1.94138,8.8638,-10.6656},{1.94138,8.52646,-11.6257},{1.39545,10.3494,-10.865},{2.09618,15.376,-5.76063},{1.65192,13.4176,-9.15342},{1.072,11.4384,-9.14367},{0.875458,11.6842,-11.2797},{2.21097,14.6235,-6.16284},{1.88999,13.089,-8.53588},{1.66289,11.4966,-10.172},{1.1931,10.4804,-8.29859},{1.1931,11.6222,-6.70013},{0.702015,11.3108,-6.53145},{0.645273,11.6155,-8.59684},{0.525393,8.61469,-9.91176},{1.41422,10.6621,-8.31156},{0.358096,6.55563,-13.0248},{0.786915,7.09623,-12.0841},{1.49023,8.90705,-10.5781},{1.44015,8.44249,-11.6706},{0.949307,11.7034,-10.0938},{1.07288e-05,8.90359,-13.4378},{1.07288e-05,10.3199,-9.4157},{1.07288e-05,8.47363,-10.0543},{1.07288e-05,6.98336,-12.8021},{1.42249,12.8085,-8.08494},{1.84423,14.224,-6.31072},{1.22372,13.2392,-8.90047},{1.15335e-05,2.1185,-1.97191},{1.1567e-05,2.04377,-0.290408},{1.16676e-05,2.39917,1.82345},{1.18017e-05,5.25731,4.73542},{1.18017e-05,1.93391,3.74072},{1.18017e-05,0.948541,5.74311},{1.18017e-05,0.884652,8.07228},{1.18017e-05,0.324152,8.16196},{1.18017e-05,-0.683109,10.567},{1.18017e-05,0.418317,12.9464},{0.302431,-1.33339,11.8803},{1.18017e-05,-1.86853,12.6505},{1.18017e-05,-1.19593,14.7221},{0.300736,-2.51423,13.9687},{1.18017e-05,-2.96561,14.5666},{1.18017e-05,-2.11066,15.9597},{0.451652,-3.40206,15.6368},{1.18017e-05,-2.89088,16.7399},{1.18017e-05,-3.50967,16.8744},{1.66143,-0.169091,7.19789},{2.5675,-0.869332,7.28134},{3.93772,-0.348661,-5.23573},{4.07101,0.73111,-2.76536},{2.27713,1.04024,-0.284134},{0.535757,1.84946,2.74004},{2.67937,-4.14748,7.00282},{2.48183,-0.0425377,3.88185},{4.00766,-0.981744,-0.687684},{2.94614,-3.49054,-6.10032},{3.24072,-4.27075,-4.91653},{3.38406,-4.76596,-3.53434},{3.26228,-4.78193,-1.93018},{3.09682,-4.5667,-0.880919},{2.53054,-4.21694,0.921652},{2.74774,-5.56835,4.63424},{1.44806,-4.11755,8.48768},{3.81068,-2.70031,-5.98099},{3.86028,-3.40444,-0.940108},{2.5558,-2.07459,2.10468},{2.64269,-3.38524,1.52615},{4.24293,3.11632,1.66581},{2.51747,0.461057,1.71499},{2.58318,-0.547844,0.388472},{1.4363,1.33305,1.10831},{3.62665,1.63604,2.78998},{2.51115,-1.26529,1.64773},{1.72436,0.73926,3.06636},{1.07288e-05,6.70899,-11.8779},{1.07288e-05,7.32554,-11.0559},{2.48153,0.792771,-6.84784},{2.78063,-0.0462413,-6.84099},{2.36551,2.66111,-7.53342},{1.80289,2.54012,-6.38068},{2.53183,0.826064,-8.00135},{2.92763,-0.604703,-7.96098},{1.25758,2.0755,-2.14066},{2.05055,1.8245,-3.28754},{1.06991,1.94246,-0.647464},{1.28746e-05,-1.26766,18.2134},{0.384901,-3.32433,18.0265},{0.382631,-3.24499,18.4625},{1.28746e-05,-1.20538,19.5679},{1.28746e-05,-2.88689,19.7236},{1.28746e-05,1.2384,21.2706},{1.28746e-05,-0.17406,21.719},{1.28746e-05,4.13059,24.1628},{1.28746e-05,3.12169,24.5439},{1.28746e-05,0.341602,23.5799},{1.28746e-05,1.20253,24.5484},{1.28746e-05,-0.626946,24.3332},{1.28746e-05,0.583739,25.8936},{1.28746e-05,-1.29955,25.6515},{0.570003,-2.53714,24.656},{1.28746e-05,-3.37116,25.4363},{1.28746e-05,-3.72091,23.553},{1.28746e-05,-3.1223,22.775},{1.28746e-05,-3.96305,22.3961},{1.28746e-05,-5.19167,18.903},{0.759681,-3.17785,21.0737},{0.603576,-1.57158,22.8124},{1.18017e-05,-4.94814,11.1648},{1.18017e-05,-5.61283,15.0042},{0.743253,-4.28391,15.6032},{0.743253,-4.09334,14.8558},{0.976313,-4.80704,15.0464},{0.81187,-4.70989,18.2562},{0.743253,-4.23533,17.834},{0.743253,-4.17555,18.7868},{0.716143,-1.77709,21.4485},{0.883826,-0.742036,23.393},{0.790408,0.152525,22.5882},{2.01283,-1.37727,23.9857},{1.3881,-1.99706,9.89726},{1.2,-3.81309,12.0757},{1.20062,-2.60988,11.17},{0.743253,-2.87892,12.3224},{1.40702,-3.34226,9.77769},{2.80188,1.23093,22.4761},{1.73042,-3.34227,8.90704},{1.77694,-1.99706,8.42127},{2.17953,-1.99706,11.5907},{1.95394,-2.60988,12.2999},{2.46852,-1.90364,9.69175},{1.4719,-4.09334,15.7713},{1.30376,-4.23533,18.5066},{5.39783,-0.55826,-4.65421},{6.10453,-2.27199,-3.60918},{4.33593,-6.3978,-4.27123},{4.25077,-9.07976,-5.57946},{5.84096,-0.99149,-2.4068},{6.9699,1.23207,0.501107},{5.61705,-0.666381,-0.81976},{6.62342,-0.964162,-0.00537462},{6.20298,-2.11878,-1.96878},{4.9842,-2.94832,-0.780522},{6.42484,0.578469,-1.28088},{6.55589,2.49007,-0.533545},{5.42802,0.795826,-2.49169},{5.48991,-0.68135,-7.91713},{5.60887,-2.86744,-9.01713},{5.35764,-2.94822,-6.49799},{5.67884,-2.37661,-5.17859},{5.03683,-4.32776,-6.50255},{5.6929,-4.69507,-3.11221},{4.32248,-2.89217,-6.68482},{4.29796,-4.02823,-6.40796},{5.66297,-4.159,-1.07198},{4.91646,-4.43178,-0.45543},{5.03362,-7.30693,-1.41321},{5.39564,-7.95711,-2.10471},{4.71606,-8.49519,-1.54773},{5.4023,-8.51388,-2.27856},{5.8077,-10.3785,-2.71419},{6.16873,-5.53772,-2.21542},{6.33853,-9.45925,-3.21429},{4.81969,-9.45863,-6.76058},{4.9262,-10.6689,-7.95454},{5.47695,-10.6351,-6.85358},{6.13025,-10.5568,-7.87656},{6.26748,-10.6351,-6.68677},{6.9921,-10.5568,-7.22045},{6.8784,-10.6351,-6.097},{4.50469,-10.6351,-6.88484},{3.77378,-10.6689,-7.62337},{3.69207,-10.6351,-6.52056},{5.80356,-9.55377,-6.62046},{6.58908,-9.5676,-6.36387},{3.98218,-9.51434,-6.64854},{6.45987,-10.6774,-3.60387},{3.83378,-6.59449,-3.07985},{3.6251,-9.53055,-4.15445},{4.02225,-6.38427,-1.94906},{3.5802,-9.68749,-2.91687},{4.22499,-7.89732,-2.07087},{4.21899,-8.55124,-2.2577},{3.97729,-3.94602,-1.09066},{4.46637,-10.3785,-2.71419},{4.04907,-10.6774,-3.61944},{6.104,-10.7152,-3.64865},{4.62702,-10.7152,-3.75735},{4.95415,0.44338,-1.82842},{5.83691,-9.07976,-5.57946},{5.49574,-6.3978,-4.12628},{3.65256,4.57108,3.95601},{3.82154,-0.71109,2.28709},{3.82191,-0.829257,1.20908},{3.84814,-2.19218,0.28493},{3.65228,-3.8564,0.952688},{3.13284,-4.97574,2.61161},{3.66038,-5.84498,2.14932},{4.29808,-6.55157,4.35376},{4.93675,-8.41626,5.94614},{3.91634,4.76873,6.88161},{3.80305,-0.394864,6.17631},{3.69912,1.75044,9.83932},{3.94312,-2.85175,7.06193},{3.90338,-2.02589,9.69581},{4.03175,-4.69353,7.18791},{4.00013,-4.35421,9.23814},{3.275,-5.75425,7.71246},{3.30952,-6.00576,8.42993},{5.36909,-6.68781,8.58216},{4.61814,-6.72889,9.74925},{5.39946,-7.31895,8.81984},{5.60243,-9.49574,9.236},{6.29742,-10.4815,8.24865},{6.29792,-10.4011,6.08052},{5.3865,-9.14483,6.07971},{5.58776,-10.3779,5.08482},{5.54209,-2.77778,2.86765},{5.24055,-0.974195,3.35721},{5.2703,-1.70585,4.90766},{4.97539,-4.3686,6.20226},{5.32379,-3.91646,4.92047},{5.37584,-5.59634,5.886},{6.06731,-8.55803,6.47795},{5.36321,-5.33382,7.1511},{6.091,-9.05047,8.30165},{5.35649,-4.59619,4.70381},{5.1623,-10.446,5.51838},{4.7403,-10.4154,4.75074},{4.29135,-10.4835,5.45104},{3.81307,-10.4592,4.73727},{3.55558,-10.5215,5.39437},{3.07148,-10.4987,4.98397},{2.54136,-10.5647,5.69893},{4.57969,-9.18329,5.74417},{3.68527,-9.26718,5.81289},{2.97104,-9.43948,5.97897},{3.54447,-8.45866,5.96912},{3.04217,-6.6353,4.48068},{3.76891,-7.12979,8.65993},{4.04421,-9.46502,9.19219},{2.91547,-8.59711,7.38644},{2.75752,-5.75522,6.32897},{2.66666,-10.5491,7.96771},{2.4054,3.63749,-2.01445},{2.88843,4.16412,-2.1983},{2.54,4.65772,-1.36241},{3.15065,5.18963,-1.8061},{3.01809,5.61161,-1.05917},{3.69496,6.37933,-1.67539},{3.62427,6.75897,-0.7597},{4.7081,8.61899,-0.373385},{3.53773,7.44735,2.66486},{3.31563,6.88732,5.67271},{2.8857,5.77077,6.94249},{2.9946,6.21252,4.73483},{2.82143,5.04554,2.54475},{2.10477,3.27183,2.65948},{2.3071,4.04402,0.828023},{1.63349,3.31766,-0.460838},{2.37683,6.26788,0.667791},{1.55459,4.96143,-0.548556},{2.69577,6.01808,0.967451},{2.82986,6.46563,4.69728},{0.378346,8.20246,-12.1293},{1.07288e-05,8.48123,-12.2609},{1.07288e-05,7.58209,-14.474}},["triangles"]={{273,6,272},{271,5,270},{269,4,268},{267,3,266},{265,2,264},{275,7,274},{277,8,276},{279,9,278},{10,279,280},{9,277,278},{8,275,276},{7,273,274},{6,271,272},{5,269,270},{4,267,268},{3,265,266},{264,1,263},{14,311,310},{2,13,1},{1,13,12},{313,15,312},{14,312,15},{317,316,16},{320,319,17},{322,321,18},{320,18,321},{317,17,319},{316,311,16},{311,2,16},{17,3,18},{3,4,18},{19,18,4},{322,19,323},{19,327,323},{327,19,328},{4,5,19},{6,19,5},{339,26,338},{338,26,337},{356,51,333},{336,27,335},{341,28,340},{342,28,341},{28,339,340},{336,26,27},{343,28,342},{27,31,32},{22,31,23},{28,23,31},{29,12,33},{32,44,27},{33,11,29},{29,11,22},{32,31,11},{39,25,36},{38,36,25},{53,43,33},{48,53,33},{37,36,38},{37,39,36},{39,34,25},{25,35,38},{33,47,40},{46,43,59},{45,42,46},{47,42,44},{44,40,47},{11,40,32},{40,11,33},{48,49,53},{51,43,53},{333,49,332},{332,49,314},{50,314,49},{48,15,50},{314,50,313},{15,313,50},{33,12,48},{13,48,12},{51,49,333},{48,13,15},{353,262,52},{29,52,12},{52,263,1},{1,12,52},{349,54,348},{350,54,349},{347,54,30},{54,55,30},{55,24,30},{39,37,57},{35,56,38},{56,35,29},{52,35,353},{29,35,52},{39,57,34},{57,24,34},{38,56,37},{57,37,56},{56,24,57},{347,30,391},{23,343,388},{22,23,388},{329,19,20},{24,391,30},{29,390,24},{29,632,261},{29,22,389},{389,22,388},{25,34,35},{351,27,21},{351,335,27},{16,2,17},{2,3,17},{13,14,15},{22,11,31},{42,41,61},{59,43,58},{41,45,60},{46,60,45},{351,21,356},{44,42,61},{58,44,61},{28,31,26},{69,100,68},{330,329,20},{68,100,20},{89,101,69},{70,92,399},{400,65,401},{397,70,398},{399,398,70},{96,6,95},{69,68,73},{281,10,280},{74,281,282},{283,74,282},{284,74,283},{285,75,284},{286,75,285},{287,76,286},{288,76,287},{289,77,288},{290,77,289},{291,78,290},{79,291,292},{293,79,292},{294,80,293},{295,80,294},{87,86,88},{83,79,91},{75,82,74},{77,83,76},{78,83,77},{86,69,88},{96,95,7},{9,10,94},{76,82,75},{82,67,10},{79,83,78},{92,70,89},{66,65,72},{80,85,79},{74,82,10},{80,81,71},{402,401,65},{87,89,86},{86,89,69},{90,87,91},{91,84,90},{84,92,90},{90,92,87},{399,72,400},{89,87,92},{397,396,89},{84,72,92},{88,91,87},{73,88,69},{84,91,85},{91,79,85},{91,88,83},{83,88,73},{27,44,21},{356,21,58},{58,21,44},{55,443,34},{55,350,442},{54,350,55},{35,443,353},{6,7,95},{8,97,7},{93,7,97},{93,97,8},{94,8,98},{9,98,8},{9,94,98},{96,7,93},{94,93,8},{94,10,67},{6,96,19},{20,19,96},{96,93,67},{94,67,93},{96,67,20},{68,20,67},{99,101,395},{395,101,396},{89,396,101},{395,330,99},{330,20,100},{460,459,115},{106,122,113},{106,113,105},{461,115,462},{463,462,114},{464,463,114},{114,462,115},{114,115,106},{459,458,113},{458,457,113},{105,113,457},{471,470,105},{105,470,116},{106,105,116},{464,104,465},{465,104,466},{104,464,114},{116,470,106},{114,106,104},{106,470,104},{470,469,104},{104,469,468},{107,110,111},{110,476,472},{110,472,112},{476,118,475},{105,472,471},{108,118,109},{81,475,118},{119,121,118},{402,117,403},{118,121,81},{123,127,124},{403,119,62},{404,403,62},{406,62,120},{63,406,120},{108,64,409},{409,63,108},{407,406,63},{410,409,64},{412,64,413},{107,64,108},{107,413,64},{111,413,107},{413,111,102},{103,102,111},{111,112,103},{103,112,457},{115,113,122},{113,115,459},{115,122,106},{124,127,117},{117,127,123},{121,125,117},{121,119,125},{119,117,125},{119,118,126},{120,126,118},{119,126,120},{71,124,66},{121,117,123},{121,123,81},{71,81,123},{117,65,124},{66,124,65},{108,128,107},{109,128,108},{109,107,128},{112,111,129},{111,110,129},{112,129,110},{136,134,137},{137,134,138},{138,139,137},{135,134,136},{142,134,140},{135,140,134},{141,142,140},{134,142,130},{131,134,130},{130,67,143},{68,130,142},{143,146,130},{131,130,146},{148,131,146},{146,145,148},{144,147,145},{144,145,149},{147,144,150},{149,150,144},{145,82,149},{150,82,76},{146,143,82},{76,147,150},{159,187,186},{152,151,158},{148,132,187},{187,133,186},{170,186,160},{171,186,170},{170,164,171},{170,160,162},{163,170,162},{164,170,163},{165,171,164},{166,171,165},{161,162,160},{161,160,167},{172,167,160},{168,167,172},{169,168,172},{157,159,173},{173,171,166},{155,154,156},{159,156,154},{159,154,158},{153,158,154},{157,156,159},{153,152,158},{132,175,133},{137,139,136},{141,140,185},{142,141,185},{136,140,135},{185,140,136},{136,73,185},{73,139,83},{174,177,175},{178,155,179},{177,178,179},{155,178,154},{154,178,153},{178,176,153},{153,176,152},{83,180,76},{152,180,151},{151,83,139},{139,138,151},{83,151,180},{76,176,174},{176,180,152},{160,133,172},{133,175,172},{172,175,169},{156,179,155},{181,156,157},{179,181,177},{181,182,177},{182,175,177},{168,169,167},{162,161,167},{163,162,164},{165,164,166},{173,183,157},{157,184,181},{181,184,182},{166,183,173},{184,169,182},{183,162,184},{167,184,162},{162,183,164},{82,143,67},{142,185,68},{73,68,185},{147,148,145},{159,186,171},{76,174,132},{456,103,457},{453,413,102},{187,158,148},{186,133,160},{158,151,148},{138,131,148},{151,138,148},{189,215,188},{72,188,215},{198,197,216},{199,198,216},{66,199,216},{202,201,217},{201,200,217},{218,200,216},{197,72,216},{215,216,72},{84,214,215},{216,214,218},{84,215,190},{190,215,189},{191,214,84},{85,214,191},{196,219,195},{217,200,218},{203,202,221},{204,203,221},{221,217,219},{207,206,208},{220,221,219},{222,210,209},{209,208,222},{206,222,208},{220,196,212},{222,211,210},{212,211,220},{212,213,211},{217,221,202},{205,204,221},{206,205,221},{193,223,192},{194,223,193},{195,223,194},{192,214,85},{223,214,192},{218,214,223},{223,217,218},{219,223,195},{213,212,224},{231,224,212},{224,231,225},{226,225,231},{232,226,231},{226,232,227},{228,227,232},{233,228,232},{228,233,229},{230,229,233},{234,195,235},{196,231,212},{234,232,231},{234,231,196},{233,232,234},{195,194,235},{194,193,235},{192,85,193},{199,66,198},{200,201,71},{202,71,201},{198,66,72},{197,198,72},{189,72,84},{189,84,190},{189,188,72},{84,85,191},{193,85,80},{235,193,80},{200,71,66},{207,236,206},{207,208,236},{206,236,205},{237,208,209},{203,204,202},{71,202,204},{236,238,205},{237,238,236},{205,238,204},{204,239,71},{80,71,239},{80,239,235},{239,234,235},{234,238,233},{238,237,240},{238,240,233},{233,240,230},{210,237,209},{213,224,211},{225,226,224},{227,228,226},{229,230,228},{240,210,226},{226,210,224},{210,211,224},{228,240,226},{230,240,228},{249,248,259},{253,252,249},{248,247,259},{259,255,253},{243,241,256},{254,253,255},{249,252,250},{244,243,245},{259,253,249},{101,241,100},{259,247,245},{242,241,243},{245,243,255},{251,250,252},{256,258,255},{243,258,242},{242,258,241},{256,101,258},{257,247,248},{247,257,246},{246,257,245},{257,258,245},{245,258,244},{244,258,243},{245,247,246},{255,259,245},{255,243,256},{100,241,99},{241,258,99},{99,258,101},{250,251,260},{252,260,251},{248,249,257},{257,249,260},{249,250,260},{255,257,254},{257,255,258},{254,257,253},{253,260,252},{257,260,253},{103,454,102},{105,457,112},{108,63,120},{120,62,119},{238,239,204},{261,632,633},{216,200,66},{100,99,330},{79,293,80},{80,295,81},{58,43,356},{61,59,58},{51,356,43},{60,61,41},{273,272,301},{271,270,300},{269,268,299},{267,266,298},{265,264,297},{275,274,302},{277,276,303},{279,278,304},{279,305,280},{277,304,278},{275,303,276},{273,302,274},{271,301,272},{269,300,270},{267,299,268},{265,298,266},{264,296,297},{311,309,310},{297,308,309},{296,307,308},{313,312,315},{309,312,310},{317,318,316},{320,324,319},{322,325,321},{320,325,324},{317,324,318},{316,318,311},{311,318,297},{324,325,298},{298,325,299},{326,299,325},{326,322,323},{326,323,327},{327,328,326},{299,326,300},{301,300,326},{339,338,354},{338,337,354},{356,333,380},{336,335,355},{341,340,357},{342,341,357},{339,357,340},{336,354,337},{343,357,345},{355,360,354},{344,345,360},{357,360,345},{358,362,307},{361,355,373},{362,358,306},{358,344,306},{361,306,360},{368,365,352},{367,352,365},{382,362,372},{377,362,382},{366,367,365},{366,365,368},{368,352,363},{352,367,364},{362,376,372},{375,372,376},{374,371,370},{371,376,373},{373,369,361},{306,361,369},{369,362,306},{378,377,382},{380,382,372},{333,332,378},{332,314,378},{379,378,314},{377,379,315},{314,313,379},{315,379,313},{362,377,307},{308,307,377},{378,380,333},{377,315,308},{353,381,262},{358,307,381},{263,381,296},{296,381,307},{349,348,383},{350,349,383},{347,383,348},{383,359,384},{346,384,359},{368,386,366},{364,367,385},{385,358,364},{381,353,364},{358,381,364},{368,363,386},{386,363,346},{367,366,385},{386,385,366},{346,385,386},{347,391,359},{345,388,343},{344,388,345},{329,326,328},{391,346,359},{358,346,390},{358,632,389},{358,389,344},{389,388,344},{352,364,363},{351,334,355},{351,355,335},{318,324,297},{297,324,298},{308,315,309},{344,360,306},{371,394,370},{392,387,372},{370,393,374},{393,375,374},{351,356,334},{373,394,371},{387,394,373},{357,354,360},{418,451,452},{330,331,329},{417,331,451},{438,418,452},{419,399,441},{400,414,421},{397,398,419},{399,419,398},{447,446,301},{418,422,417},{281,280,305},{281,423,282},{283,282,423},{284,423,424},{285,284,424},{286,424,425},{287,286,425},{288,425,426},{289,288,426},{290,426,427},{291,290,427},{291,428,292},{293,292,428},{294,293,429},{295,294,429},{436,437,435},{432,440,428},{424,423,431},{426,425,432},{427,426,432},{435,437,418},{447,302,446},{304,445,305},{425,424,431},{431,305,416},{428,427,432},{441,438,419},{415,421,414},{429,428,434},{423,305,431},{429,420,430},{402,414,401},{436,435,438},{435,418,438},{439,440,436},{440,439,433},{433,439,441},{439,436,441},{399,421,441},{438,441,436},{70,397,89},{433,441,421},{437,436,440},{422,418,437},{433,434,440},{440,434,428},{440,432,437},{432,422,437},{355,334,373},{356,387,334},{387,373,334},{443,384,363},{384,442,350},{383,384,350},{443,364,353},{301,446,302},{303,302,448},{444,448,302},{444,303,448},{445,449,303},{304,303,449},{304,449,445},{447,444,302},{445,303,444},{445,416,305},{301,326,447},{331,447,326},{447,416,444},{445,444,416},{447,331,416},{417,416,331},{450,395,452},{395,396,452},{438,452,396},{395,450,330},{330,451,331},{460,485,459},{474,483,492},{474,473,483},{461,485,460},{463,484,462},{464,484,463},{484,485,462},{484,474,485},{459,483,458},{458,483,457},{473,457,483},{471,473,470},{473,486,470},{474,486,473},{464,465,467},{465,466,467},{467,484,464},{486,474,470},{484,467,474},{474,467,470},{470,467,469},{467,468,469},{477,480,479},{476,480,472},{480,482,472},{488,476,475},{472,473,471},{478,488,490},{430,475,295},{489,488,491},{487,402,403},{488,430,491},{493,494,497},{489,403,405},{404,405,403},{406,490,405},{408,490,406},{478,409,411},{409,478,408},{407,408,406},{410,411,409},{412,413,411},{477,478,411},{477,411,413},{481,477,413},{413,454,481},{455,481,454},{481,455,482},{455,457,482},{485,492,483},{483,459,485},{485,474,492},{494,487,497},{487,493,497},{491,487,495},{491,495,489},{489,495,487},{489,496,488},{490,488,496},{489,490,496},{420,494,493},{491,493,487},{491,430,493},{420,493,430},{487,494,414},{415,414,494},{478,477,498},{479,478,498},{479,498,477},{482,499,481},{481,499,480},{482,480,499},{506,507,504},{507,508,504},{508,507,509},{505,506,504},{512,510,504},{505,504,510},{511,510,512},{504,500,512},{501,504,508},{500,513,416},{417,500,416},{513,500,516},{501,516,500},{518,516,501},{516,518,515},{514,515,517},{514,519,515},{517,520,514},{519,514,520},{515,431,516},{431,520,425},{516,431,513},{425,517,518},{557,529,556},{522,528,521},{518,502,425},{557,503,502},{540,530,556},{541,540,556},{540,541,534},{540,532,530},{533,532,540},{534,533,540},{535,534,541},{536,535,541},{531,530,532},{531,537,530},{542,530,537},{538,542,537},{539,542,538},{527,543,529},{541,543,536},{525,526,524},{529,524,526},{529,528,524},{523,524,528},{527,529,526},{523,528,522},{545,502,503},{507,506,509},{511,555,510},{512,555,511},{506,505,510},{555,506,510},{506,555,422},{509,422,432},{547,544,545},{548,549,525},{547,548,546},{525,524,548},{524,523,548},{548,523,546},{523,522,546},{432,425,550},{522,521,550},{521,509,432},{509,521,508},{432,550,521},{425,546,550},{546,522,550},{530,542,503},{503,542,545},{542,539,545},{526,525,549},{551,526,549},{549,547,551},{551,547,552},{545,552,547},{538,537,539},{532,537,531},{533,534,532},{535,536,534},{543,527,553},{554,527,551},{551,552,554},{536,553,534},{539,554,552},{553,554,532},{537,532,554},{532,534,553},{431,416,513},{512,417,555},{422,555,417},{517,515,518},{529,541,556},{425,502,544},{456,457,455},{453,454,413},{557,518,528},{556,530,503},{528,518,521},{508,518,501},{521,518,508},{559,558,585},{421,585,558},{568,586,567},{569,586,568},{415,586,569},{572,587,571},{571,587,570},{588,586,570},{567,586,421},{585,421,586},{433,585,584},{584,586,588},{433,560,585},{560,559,585},{561,433,584},{434,561,584},{566,589,590},{587,588,570},{573,591,572},{574,591,573},{591,589,587},{577,578,576},{590,591,592},{592,579,580},{579,592,578},{592,576,578},{590,582,566},{592,581,590},{582,590,581},{582,581,583},{587,572,591},{575,591,574},{576,591,575},{563,562,593},{564,563,593},{565,564,593},{562,434,584},{593,562,584},{588,593,584},{587,593,588},{589,565,593},{583,594,582},{601,582,594},{594,595,601},{596,601,595},{602,601,596},{596,597,602},{598,602,597},{603,602,598},{598,599,603},{600,603,599},{565,604,605},{566,582,601},{604,601,602},{604,566,601},{603,604,602},{565,605,564},{564,605,563},{562,563,434},{569,568,415},{570,420,571},{572,571,420},{568,421,415},{567,421,568},{559,433,421},{559,560,433},{559,421,558},{433,561,434},{563,429,434},{605,429,563},{570,415,420},{577,576,606},{577,606,578},{576,575,606},{578,607,579},{573,572,574},{420,574,572},{606,575,608},{607,606,608},{575,574,608},{574,420,609},{429,609,420},{429,605,609},{604,609,605},{604,603,608},{608,610,607},{608,603,610},{603,600,610},{580,607,610},{583,581,594},{595,594,596},{597,596,598},{599,598,600},{610,596,580},{596,594,580},{580,594,581},{598,596,610},{600,598,610},{619,629,618},{623,619,622},{618,629,617},{629,623,625},{613,626,611},{624,625,623},{619,620,622},{614,615,613},{629,619,623},{452,611,626},{629,615,617},{612,613,611},{615,625,613},{621,622,620},{626,625,628},{613,612,628},{612,611,628},{626,628,452},{627,618,617},{617,616,627},{616,615,627},{627,615,628},{615,614,628},{614,613,628},{615,616,617},{625,615,629},{625,626,613},{451,450,611},{611,450,628},{450,452,628},{620,630,621},{622,621,630},{618,627,619},{627,630,619},{619,630,620},{625,624,627},{627,628,625},{624,623,627},{623,622,630},{627,623,630},{406,405,62},{62,405,404},{409,408,63},{63,408,407},{412,411,64},{64,411,410},{456,455,103},{102,454,453},{473,482,457},{478,490,408},{468,467,104},{104,467,466},{490,489,405},{608,574,609},{631,633,632},{586,415,570},{451,330,450},{428,429,293},{429,430,295},{387,356,372},{394,387,392},{380,372,356},{394,393,370},{633,631,261},{390,261,631},{29,261,390},{358,390,631},{397,438,396},{419,438,397},{10,9,279},{9,8,277},{8,7,275},{7,6,273},{6,5,271},{5,4,269},{4,3,267},{3,2,265},{264,2,1},{14,2,311},{2,14,13},{14,310,312},{320,17,18},{317,16,17},{322,18,19},{28,26,339},{336,337,26},{343,23,28},{27,26,31},{33,43,47},{46,47,43},{45,41,42},{47,46,42},{44,32,40},{48,50,49},{51,53,49},{52,262,263},{347,348,54},{55,34,24},{56,29,24},{329,328,19},{24,390,391},{29,389,632},{46,59,60},{69,101,100},{400,72,65},{74,10,281},{284,75,74},{286,76,75},{288,77,76},{290,78,77},{79,78,291},{399,92,72},{55,442,443},{35,34,443},{461,460,115},{107,109,110},{110,109,476},{476,109,118},{105,112,472},{108,120,118},{81,295,475},{402,65,117},{403,117,119},{71,123,124},{131,138,134},{68,67,130},{145,146,82},{150,149,82},{76,148,147},{159,158,187},{148,76,132},{187,132,133},{173,159,171},{132,174,175},{73,136,139},{174,176,177},{177,176,178},{76,180,176},{181,179,156},{182,169,175},{157,183,184},{166,164,183},{184,167,169},{216,215,214},{196,220,219},{220,222,221},{206,221,222},{222,220,211},{223,219,217},{234,196,195},{237,236,208},{239,238,234},{210,240,237},{101,256,241},{103,455,454},{60,59,61},{279,304,305},{277,303,304},{275,302,303},{273,301,302},{271,300,301},{269,299,300},{267,298,299},{265,297,298},{264,263,296},{311,297,309},{297,296,308},{309,315,312},{320,321,325},{317,319,324},{326,325,322},{339,354,357},{336,355,354},{343,342,357},{355,361,360},{362,369,376},{375,392,372},{374,375,371},{371,375,376},{373,376,369},{378,379,377},{378,382,380},{263,262,381},{347,359,383},{346,363,384},{346,358,385},{329,331,326},{391,390,346},{358,631,632},{393,392,375},{418,417,451},{400,401,414},{281,305,423},{284,283,423},{286,285,424},{288,287,425},{290,289,426},{291,427,428},{399,400,421},{443,442,384},{443,363,364},{461,462,485},{477,481,480},{476,479,480},{488,479,476},{472,482,473},{478,479,488},{430,488,475},{487,414,402},{489,487,403},{420,415,494},{501,500,504},{417,512,500},{515,519,431},{431,519,520},{425,520,517},{557,528,529},{518,557,502},{557,556,503},{541,529,543},{545,544,502},{509,506,422},{547,546,544},{547,549,548},{425,544,546},{551,527,526},{545,539,552},{554,553,527},{536,543,553},{539,537,554},{584,585,586},{566,565,589},{590,589,591},{592,591,576},{592,580,581},{587,589,593},{565,566,604},{578,606,607},{604,608,609},{580,579,607},{452,451,611},{394,392,393}},["colors"]={{82,72,70},{76,60,55},{78,65,60},{101,83,83},{24,23,23},{72,59,54},{69,63,58},{31,29,28},{93,80,81},{76,61,58},{46,40,35},{77,63,57},{83,67,61},{27,27,27},{95,80,79},{46,35,31},{35,35,35},{96,81,83},{69,63,58},{54,50,45},{110,92,97},{80,62,55},{36,35,35},{97,81,81},{36,35,35},{80,62,55},{118,101,103},{36,35,35},{69,63,58},{97,81,81},{54,50,45},{46,35,31},{110,92,97},{35,35,35},{82,72,70},{96,81,83},{76,60,55},{101,83,83},{78,65,60},{24,23,23},{69,63,58},{72,59,54},{31,29,28},{76,61,58},{93,80,81},{46,40,35},{83,67,61},{77,63,57},{95,80,79},{25,25,25},{77,58,53},{35,35,35},{19,19,19},{66,66,66},{27,27,27},{43,43,43},{25,25,25},{25,25,25},{43,43,43},{47,46,45},{46,46,46},{25,25,25},{25,25,25},{35,35,35},{25,25,25},{25,25,25},{27,27,27},{83,83,83},{43,43,43},{30,30,30},{69,69,69},{27,27,27},{16,16,16},{47,47,47},{50,50,50},{30,30,30},{50,50,50},{47,47,47},{27,27,27},{27,27,27},{69,69,69},{83,83,83},{19,19,19},{43,43,43},{19,19,19},{27,27,27},{43,43,43},{27,27,27},{46,40,35},{50,50,50},{46,40,35},{31,29,28},{50,50,50},{47,47,47},{50,50,50},{31,29,28},{16,16,16},{47,47,47},{43,43,43},{47,47,47},{43,43,43},{43,43,43},{43,43,43},{47,47,47},{17,17,17},{31,29,28},{24,23,23},{47,47,47},{76,60,55},{47,47,47},{24,23,23},{71,71,71},{68,68,68},{75,75,75},{75,75,75},{68,68,68},{94,94,94},{65,65,65},{38,38,38},{35,35,35},{43,43,43},{57,57,57},{91,91,91},{106,106,106},{43,43,43},{82,82,82},{49,49,49},{43,43,43},{106,106,106},{43,43,43},{71,71,71},{82,82,82},{43,43,43},{68,68,68},{57,57,57},{57,57,57},{43,43,43},{49,49,49},{57,57,57},{53,53,53},{64,64,64},{27,27,27},{53,53,53},{46,46,46},{43,43,43},{46,46,46},{53,53,53},{97,79,77},{47,46,45},{21,21,21},{64,64,64},{64,64,64},{57,57,57},{21,21,21},{43,43,43},{97,79,77},{97,79,77},{43,43,43},{27,27,27},{64,64,64},{53,53,53},{43,43,43},{84,73,77},{106,89,92},{96,84,92},{91,83,89},{96,84,92},{106,89,92},{69,69,69},{21,21,21},{21,21,21},{21,21,21},{69,69,69},{21,21,21},{142,133,137},{96,84,92},{91,83,89},{142,133,137},{84,73,77},{96,84,92},{84,73,77},{104,86,90},{106,89,92},{106,89,92},{115,101,105},{91,83,89},{21,21,21},{53,53,53},{53,53,53},{85,85,85},{21,21,21},{25,25,25},{62,62,62},{83,83,83},{85,85,85},{53,53,53},{83,83,83},{64,64,64},{64,64,64},{53,53,53},{53,53,53},{43,43,43},{53,53,53},{64,64,64},{53,53,53},{43,43,43},{21,21,21},{21,21,21},{82,82,82},{69,69,69},{38,38,38},{21,21,21},{69,69,69},{35,35,35},{82,82,82},{55,55,55},{55,55,55},{82,82,82},{27,27,27},{27,27,27},{27,27,27},{82,82,82},{21,21,21},{25,25,25},{27,27,27},{27,27,27},{27,27,27},{46,46,46},{25,25,25},{46,46,46},{27,27,27},{21,21,21},{47,46,45},{21,21,21},{43,43,43},{21,21,21},{47,46,45},{38,38,38},{82,82,82},{35,35,35},{21,21,21},{43,43,43},{25,25,25},{85,71,70},{65,47,41},{97,80,78},{97,79,77},{97,80,78},{47,46,45},{97,80,78},{77,58,53},{25,25,25},{25,25,25},{47,46,45},{97,80,78},{120,121,124},{129,107,109},{122,101,105},{116,98,102},{129,107,109},{120,121,124},{124,103,105},{129,107,109},{99,85,90},{129,107,109},{125,104,106},{99,85,90},{125,104,106},{101,94,100},{99,85,90},{84,73,77},{142,133,137},{92,81,84},{115,101,105},{90,80,81},{91,83,89},{96,78,77},{92,80,81},{97,79,77},{97,80,78},{92,80,81},{85,71,70},{97,79,77},{92,80,81},{97,80,78},{84,73,77},{92,81,84},{104,86,90},{91,75,72},{101,94,100},{95,79,78},{91,83,89},{90,80,81},{142,133,137},{92,81,84},{142,133,137},{100,98,105},{96,78,77},{101,94,100},{91,75,72},{106,75,68},{68,49,44},{79,52,45},{54,46,42},{114,61,52},{92,57,46},{52,46,42},{54,46,42},{92,57,46},{43,43,43},{47,47,47},{49,49,49},{59,47,43},{79,52,45},{68,49,44},{60,46,42},{135,71,54},{59,47,43},{60,46,42},{111,60,48},{131,70,56},{60,46,42},{52,46,42},{114,65,53},{114,65,53},{52,46,42},{92,57,46},{106,89,92},{104,86,90},{115,101,105},{78,78,78},{57,57,57},{73,73,73},{78,78,78},{91,91,91},{57,57,57},{43,43,43},{27,27,27},{27,27,27},{27,27,27},{46,40,35},{27,27,27},{43,43,43},{35,35,35},{25,25,25},{27,27,27},{43,43,43},{53,53,53},{83,83,83},{101,101,101},{89,89,89},{25,25,25},{21,21,21},{43,43,43},{101,101,101},{62,62,62},{40,40,40},{85,85,85},{40,40,40},{62,62,62},{78,78,78},{73,73,73},{65,65,65},{64,64,64},{83,83,83},{89,89,89},{43,43,43},{64,64,64},{89,89,89},{43,43,43},{53,53,53},{68,68,68},{39,39,38},{41,41,41},{30,30,30},{23,23,23},{43,43,43},{49,49,49},{30,30,30},{41,41,41},{49,49,49},{81,78,78},{49,49,48},{39,39,38},{27,27,27},{40,40,40},{59,55,50},{45,44,43},{43,43,43},{82,73,74},{55,52,49},{27,27,27},{68,63,58},{59,55,50},{68,63,58},{27,27,27},{36,36,36},{76,60,55},{152,138,134},{39,39,38},{30,30,30},{33,33,32},{60,45,37},{36,35,35},{118,101,103},{19,19,19},{60,45,37},{95,79,75},{64,50,43},{19,19,19},{95,79,75},{92,79,75},{19,19,19},{64,50,43},{60,43,36},{21,21,20},{92,79,75},{92,80,77},{21,21,20},{60,43,36},{61,49,43},{30,30,30},{92,80,77},{82,65,59},{30,30,30},{61,49,43},{67,56,48},{21,21,21},{82,65,59},{83,67,58},{21,21,21},{67,56,48},{82,64,56},{19,19,19},{83,67,58},{17,17,17},{82,64,56},{80,60,53},{68,55,48},{17,17,17},{80,60,53},{87,70,65},{97,81,79},{68,55,48},{76,64,58},{97,81,79},{87,70,65},{58,52,46},{86,84,87},{58,56,54},{19,19,19},{17,17,17},{62,56,50},{21,21,20},{43,43,43},{19,19,19},{21,21,21},{19,19,19},{30,30,30},{19,19,19},{19,19,19},{21,21,21},{86,84,87},{39,39,38},{58,56,54},{36,36,36},{152,138,134},{35,35,35},{36,35,35},{36,35,35},{32,32,32},{30,30,30},{43,43,43},{21,21,20},{43,43,43},{43,43,43},{36,35,35},{17,17,17},{19,19,19},{19,19,19},{40,40,40},{27,27,27},{81,78,78},{19,19,19},{43,43,43},{43,43,43},{97,81,79},{22,22,22},{17,17,17},{19,19,19},{43,43,43},{36,35,35},{97,81,79},{19,19,19},{21,21,21},{35,35,33},{82,73,74},{43,43,43},{58,52,46},{81,78,78},{86,84,87},{86,84,87},{81,78,78},{39,39,38},{69,63,58},{58,52,46},{62,56,50},{62,56,50},{39,35,32},{69,63,58},{39,35,32},{40,40,40},{69,63,58},{69,63,58},{40,40,40},{58,52,46},{59,55,50},{43,43,43},{45,44,43},{81,78,78},{58,52,46},{40,40,40},{55,52,49},{32,32,32},{81,78,78},{39,35,32},{43,43,43},{40,40,40},{58,56,54},{62,56,50},{58,52,46},{33,33,32},{58,56,54},{39,39,38},{39,35,32},{62,56,50},{22,22,22},{62,56,50},{17,17,17},{22,22,22},{62,56,50},{58,56,54},{19,19,19},{19,19,19},{58,56,54},{33,33,32},{57,57,57},{64,64,64},{73,73,73},{65,65,65},{73,73,73},{43,43,43},{43,43,43},{73,73,73},{64,64,64},{125,104,106},{93,78,78},{95,79,78},{125,104,106},{116,98,102},{114,93,98},{129,107,109},{116,98,102},{125,104,106},{92,80,81},{93,78,78},{85,71,70},{76,60,55},{35,35,35},{152,138,134},{54,50,45},{155,141,138},{35,35,35},{38,38,38},{35,35,35},{155,141,138},{38,38,38},{155,141,138},{54,50,45},{32,32,32},{54,50,45},{160,147,143},{36,35,35},{160,147,143},{54,50,45},{36,35,35},{32,32,32},{160,147,143},{36,36,36},{35,35,35},{38,38,38},{32,32,32},{38,38,38},{54,50,45},{32,32,32},{36,35,35},{43,43,43},{76,60,55},{36,36,36},{47,47,47},{49,49,49},{47,47,47},{36,36,36},{36,36,36},{38,38,38},{43,43,43},{32,32,32},{43,43,43},{38,38,38},{36,36,36},{43,43,43},{49,49,49},{30,30,30},{49,49,49},{43,43,43},{36,36,36},{49,49,48},{40,40,40},{40,40,40},{49,49,48},{32,32,32},{81,78,78},{32,32,32},{49,49,48},{40,40,40},{23,23,23},{36,36,36},{23,23,23},{49,49,49},{41,41,41},{98,100,105},{83,81,83},{66,60,55},{16,16,16},{23,22,22},{19,19,19},{16,16,16},{19,19,19},{25,25,25},{70,66,60},{66,60,55},{29,26,24},{50,50,50},{29,26,24},{41,41,41},{46,46,46},{50,50,50},{41,41,41},{41,41,41},{29,26,24},{66,60,55},{41,41,41},{66,60,55},{16,16,16},{83,81,83},{82,80,81},{19,19,19},{82,80,81},{32,32,32},{19,19,19},{25,25,25},{19,19,19},{32,32,32},{25,25,25},{17,17,17},{25,25,25},{25,25,25},{17,17,17},{50,50,50},{16,16,16},{25,25,25},{50,50,50},{46,46,46},{25,25,25},{46,46,46},{46,46,46},{25,25,25},{32,32,32},{25,25,25},{46,46,46},{41,41,41},{50,50,50},{17,17,17},{16,16,16},{41,41,41},{16,16,16},{25,25,25},{16,16,16},{17,17,17},{25,25,25},{17,17,17},{32,32,32},{25,25,25},{25,25,25},{32,32,32},{40,40,40},{19,19,19},{19,19,19},{46,46,46},{19,19,19},{67,57,53},{38,38,38},{19,19,19},{38,38,38},{55,55,55},{67,57,53},{38,38,38},{77,68,64},{25,25,25},{38,38,38},{25,25,25},{28,28,28},{38,38,38},{35,35,35},{19,19,19},{77,68,64},{38,38,38},{43,43,43},{16,16,16},{38,38,38},{35,35,33},{19,19,19},{53,48,44},{38,38,38},{16,16,16},{19,19,19},{43,43,43},{49,49,49},{25,25,25},{53,48,44},{43,43,43},{26,23,23},{81,75,74},{53,48,44},{26,23,23},{44,43,41},{26,23,23},{34,34,34},{62,58,53},{44,43,41},{34,34,34},{28,28,28},{32,32,32},{50,49,47},{50,49,47},{62,58,53},{28,28,28},{82,80,79},{44,43,41},{62,58,53},{80,70,69},{50,49,47},{32,32,32},{77,66,61},{32,32,32},{36,36,36},{19,19,19},{32,32,32},{28,28,28},{19,19,19},{36,36,36},{32,32,32},{46,46,46},{36,36,36},{19,19,19},{36,36,36},{46,46,46},{30,30,29},{55,55,55},{30,30,29},{46,46,46},{46,46,46},{55,55,55},{55,55,55},{55,55,55},{55,55,55},{32,32,32},{66,60,55},{19,19,19},{23,22,22},{19,19,19},{66,60,55},{83,81,83},{66,60,55},{23,22,22},{16,16,16},{25,25,25},{49,49,49},{19,19,19},{19,19,19},{49,49,49},{43,43,43},{16,16,16},{49,49,49},{19,19,19},{16,16,16},{43,43,43},{49,49,49},{43,43,43},{19,19,19},{49,49,49},{43,43,43},{38,38,38},{55,55,55},{34,34,34},{55,55,55},{38,38,38},{43,43,43},{55,55,55},{34,34,34},{21,21,21},{25,25,25},{19,19,19},{16,16,16},{19,19,19},{43,43,43},{16,16,16},{43,43,43},{19,19,19},{21,21,21},{19,19,19},{43,43,43},{19,19,19},{43,43,43},{25,25,25},{19,19,19},{25,25,25},{43,43,43},{28,28,28},{59,59,59},{19,19,19},{35,35,35},{59,59,59},{28,28,28},{35,35,35},{19,19,19},{59,59,59},{55,55,55},{46,46,46},{50,50,50},{46,46,46},{19,19,19},{50,50,50},{55,55,55},{50,50,50},{19,19,19},{61,56,49},{38,37,35},{91,91,95},{91,91,95},{38,37,35},{58,56,55},{58,56,55},{17,17,17},{91,91,95},{102,104,110},{38,37,35},{61,56,49},{75,75,75},{38,37,35},{60,58,53},{102,104,110},{60,58,53},{38,37,35},{99,101,106},{75,75,75},{60,58,53},{38,37,35},{75,75,75},{27,27,27},{38,38,38},{38,37,35},{27,27,27},{27,27,27},{46,46,46},{66,66,66},{38,38,38},{27,27,27},{75,75,75},{66,66,66},{34,34,34},{27,27,27},{38,38,38},{27,27,27},{34,34,34},{28,28,28},{38,38,38},{34,34,34},{34,34,34},{81,81,81},{28,28,28},{27,27,27},{40,40,40},{81,81,81},{27,27,27},{81,81,81},{32,32,32},{40,40,40},{27,27,27},{64,64,64},{73,73,73},{25,25,25},{75,75,75},{81,81,81},{30,30,30},{32,32,32},{25,25,25},{25,25,25},{28,28,28},{34,34,34},{66,66,66},{30,30,30},{28,28,28},{40,40,40},{64,64,64},{19,19,19},{20,20,20},{25,25,25},{59,59,59},{25,25,25},{30,30,30},{28,28,28},{41,41,41},{20,20,20},{20,20,20},{36,36,36},{25,25,25},{56,48,43},{25,25,25},{43,39,35},{27,27,26},{25,25,25},{56,48,43},{56,48,43},{82,69,65},{27,27,26},{56,48,43},{43,39,35},{35,32,28},{101,94,101},{56,48,43},{35,32,28},{82,69,65},{56,48,43},{101,94,101},{110,104,110},{27,27,26},{82,69,65},{35,35,35},{27,27,26},{110,104,110},{112,114,117},{35,32,28},{43,39,35},{112,114,117},{43,39,35},{85,72,68},{39,38,35},{85,72,68},{43,39,35},{115,109,114},{85,72,68},{39,38,35},{123,115,118},{115,109,114},{39,38,35},{20,20,20},{19,19,19},{28,28,28},{28,28,28},{27,27,26},{35,35,35},{40,40,40},{32,32,32},{20,20,20},{19,19,19},{20,20,20},{32,32,32},{19,19,19},{32,32,32},{30,30,30},{36,36,36},{30,30,30},{32,32,32},{20,20,20},{20,20,20},{19,19,19},{36,36,36},{59,59,59},{30,30,30},{38,38,38},{21,21,21},{34,34,34},{64,58,53},{38,35,32},{31,28,24},{68,62,57},{59,54,48},{50,49,48},{75,75,75},{99,101,106},{38,38,38},{31,28,24},{59,54,48},{54,49,43},{50,49,48},{59,54,48},{31,28,24},{31,28,24},{38,38,38},{50,49,48},{38,38,38},{38,35,32},{23,23,23},{25,25,25},{28,28,28},{21,21,21},{27,27,27},{43,43,43},{28,28,28},{28,28,28},{27,27,27},{28,28,28},{40,40,40},{25,25,25},{32,32,32},{32,32,32},{25,25,25},{36,36,36},{27,27,27},{34,34,34},{32,32,32},{32,32,32},{34,34,34},{46,46,46},{23,23,23},{62,62,62},{25,25,25},{46,46,46},{62,62,62},{41,41,41},{41,41,41},{23,23,23},{38,35,32},{17,17,17},{58,56,55},{25,25,25},{23,23,23},{41,41,41},{62,62,62},{25,25,25},{34,34,34},{25,25,25},{34,34,34},{62,62,62},{46,46,46},{43,39,35},{36,36,36},{39,38,35},{36,36,36},{25,25,25},{39,38,35},{39,38,35},{25,25,25},{123,115,118},{20,20,20},{27,27,27},{40,40,40},{20,20,20},{20,20,20},{20,20,20},{28,28,28},{32,32,32},{28,28,28},{32,32,32},{27,27,27},{28,28,28},{27,27,27},{21,21,21},{28,28,28},{84,73,58},{87,80,71},{101,91,78},{76,67,55},{119,113,102},{101,91,78},{105,95,81},{76,67,55},{49,40,28},{111,102,89},{49,40,28},{111,99,86},{75,55,51},{65,46,42},{52,43,41},{52,43,41},{63,46,42},{40,31,27},{40,31,27},{63,46,42},{48,35,31},{111,99,86},{65,46,42},{75,55,51},{63,46,42},{87,80,71},{48,35,31},{65,46,42},{76,67,55},{63,46,42},{101,91,78},{63,46,42},{76,67,55},{76,67,55},{65,46,42},{49,40,28},{25,25,25},{57,57,57},{43,43,43},{75,75,75},{38,38,38},{38,38,38},{38,38,38},{36,36,36},{50,49,48},{40,40,40},{28,28,28},{81,81,81},{19,19,19},{25,25,25},{27,27,26},{25,25,25},{25,25,25},{38,38,38},{73,69,65},{55,55,55},{32,32,32},{80,72,70},{36,36,36},{30,30,29},{20,20,20},{30,30,30},{28,28,28},{25,25,25},{36,36,36},{43,39,35},{30,30,30},{25,25,25},{28,28,28},{58,56,55},{38,38,38},{28,28,28},{25,25,25},{58,56,55},{28,28,28},{59,59,59},{43,43,43},{89,88,92},{34,34,34},{89,88,92},{43,43,43},{58,56,55},{77,72,70},{71,71,71},{97,99,105},{58,56,55},{71,71,71},{22,21,20},{97,99,105},{71,71,71},{22,21,21},{81,79,79},{43,43,43},{81,79,79},{36,35,35},{43,43,43},{21,21,21},{36,35,35},{71,71,71},{77,72,70},{34,34,34},{71,71,71},{43,43,43},{71,71,71},{34,34,34},{35,35,35},{58,58,58},{43,43,43},{71,71,71},{58,58,58},{21,21,21},{35,35,35},{43,43,43},{73,73,73},{73,73,73},{43,43,43},{59,59,59},{53,53,53},{58,58,58},{35,35,35},{19,19,19},{58,58,58},{53,53,53},{43,43,43},{43,43,43},{23,23,23},{43,43,43},{36,35,35},{21,21,21},{70,66,60},{22,21,21},{54,54,54},{28,27,26},{70,66,60},{54,54,54},{54,54,54},{43,43,43},{43,43,43},{58,49,45},{43,43,43},{25,25,25},{23,23,23},{54,54,54},{43,43,43},{43,43,43},{32,32,32},{43,43,43},{43,43,43},{25,25,25},{43,43,43},{43,43,43},{43,43,43},{25,25,25},{23,23,23},{43,43,43},{47,46,46},{43,43,43},{41,40,40},{32,32,32},{47,46,46},{41,40,40},{23,23,23},{47,46,46},{111,106,112},{41,40,40},{43,43,43},{54,54,54},{22,21,21},{54,54,53},{28,27,26},{54,54,54},{43,43,43},{54,54,53},{54,54,54},{19,19,19},{28,28,28},{81,81,81},{50,50,50},{28,28,28},{19,19,19},{23,23,23},{28,28,28},{50,50,50},{81,81,81},{58,58,58},{19,19,19},{28,28,28},{58,58,58},{81,81,81},{21,21,21},{58,58,58},{28,28,28},{28,28,28},{43,43,43},{21,21,21},{43,43,43},{28,28,28},{23,23,23},{111,106,112},{47,46,46},{76,63,58},{39,38,38},{76,63,58},{47,46,46},{76,63,58},{39,38,38},{123,115,119},{101,92,93},{123,115,119},{39,38,38},{45,44,41},{101,92,93},{39,38,38},{101,92,93},{45,44,41},{110,106,110},{80,67,60},{110,106,110},{45,44,41},{27,27,27},{80,67,60},{45,44,41},{80,67,60},{27,27,27},{114,106,112},{76,69,64},{114,106,112},{27,27,27},{27,27,27},{23,23,23},{41,41,41},{43,43,43},{39,38,38},{47,46,46},{27,27,27},{45,44,41},{39,38,38},{27,27,27},{39,38,38},{43,43,43},{27,27,27},{45,44,41},{27,27,27},{23,23,23},{50,50,50},{41,41,41},{34,34,34},{55,55,55},{32,32,32},{41,41,41},{69,69,69},{55,55,55},{87,86,90},{26,24,23},{42,38,34},{36,35,35},{81,79,79},{27,25,23},{25,23,23},{43,43,43},{73,68,64},{42,38,34},{26,24,23},{89,89,89},{84,81,83},{42,38,34},{89,89,89},{45,45,44},{44,44,43},{55,55,55},{45,45,44},{55,55,55},{64,64,64},{45,45,44},{91,90,95},{44,44,43},{30,30,30},{32,32,32},{43,43,43},{55,55,55},{69,69,69},{32,32,32},{32,32,32},{55,55,55},{32,32,32},{36,35,35},{27,25,23},{22,21,20},{58,49,45},{53,53,53},{43,43,43},{65,59,54},{36,36,36},{38,38,38},{43,43,43},{53,53,53},{54,54,53},{43,43,43},{36,36,36},{43,43,43},{46,41,35},{21,21,21},{25,23,23},{43,43,43},{25,23,23},{21,21,21},{38,38,38},{28,28,28},{27,27,27},{43,43,43},{28,28,28},{38,38,38},{27,27,27},{28,28,28},{21,21,21},{21,21,21},{43,43,43},{43,43,43},{32,32,32},{43,43,43},{43,43,43},{32,32,32},{43,43,43},{32,32,32},{43,43,43},{25,25,25},{32,32,32},{25,25,25},{28,28,28},{32,32,32},{28,28,28},{43,43,43},{38,38,38},{28,28,28},{38,38,38},{32,32,32},{32,32,32},{38,38,38},{20,20,20},{65,46,42},{45,35,33},{52,43,41},{111,102,89},{63,55,45},{111,100,87},{106,97,82},{76,67,55},{63,55,45},{119,113,102},{101,91,78},{76,67,55},{84,73,58},{87,80,71},{101,91,78},{48,35,31},{65,46,42},{76,67,55},{76,67,55},{65,46,42},{63,55,45},{65,46,42},{111,100,87},{63,55,45},{101,91,78},{48,35,31},{76,67,55},{87,80,71},{48,35,31},{101,91,78},{64,64,64},{53,53,53},{43,43,43},{41,41,41},{50,50,50},{64,64,64},{53,53,53},{40,40,40},{43,43,43},{43,43,43},{64,64,64},{41,41,41},{32,32,32},{35,35,35},{71,71,71},{38,38,38},{41,41,41},{64,64,64},{64,64,64},{50,50,50},{77,77,77},{43,43,43},{32,32,32},{27,27,27},{43,43,43},{41,41,41},{64,64,64},{19,19,19},{35,35,35},{46,46,46},{43,43,43},{40,40,40},{27,27,27},{68,68,68},{35,35,35},{32,32,32},{27,27,27},{32,32,32},{64,64,64},{49,49,49},{77,77,77},{50,50,50},{46,46,46},{30,30,30},{36,36,36},{27,27,27},{30,30,30},{69,69,69},{69,69,69},{30,30,30},{47,47,47},{46,46,46},{41,41,41},{30,30,30},{49,49,49},{27,27,27},{30,30,30},{27,27,27},{49,49,49},{71,71,71},{71,71,71},{49,49,49},{55,55,55},{49,49,49},{30,30,30},{55,55,55},{55,55,55},{30,30,30},{46,46,46},{46,46,46},{30,30,30},{27,27,27},{27,27,27},{40,40,40},{101,101,101},{64,64,64},{43,43,43},{27,27,27},{64,64,64},{32,32,32},{71,71,71},{44,44,44},{47,47,47},{30,30,30},{47,47,47},{30,30,30},{30,30,30},{30,30,30},{30,30,30},{41,41,41},{69,69,69},{50,50,50},{44,44,44},{69,69,69},{44,44,44},{50,50,50},{30,30,30},{73,73,73},{49,49,49},{49,49,49},{73,73,73},{44,44,44},{73,73,73},{69,69,69},{44,44,44},{36,36,36},{49,49,49},{34,34,34},{49,49,49},{36,36,36},{30,30,30},{34,34,34},{49,49,49},{25,25,25},{25,25,25},{44,44,44},{69,69,69},{49,49,49},{44,44,44},{25,25,25},{55,55,55},{30,30,29},{30,30,29},{25,25,25},{32,32,32},{55,55,55},{28,28,28},{62,58,53},{34,34,34},{34,34,34},{26,23,23},{43,43,43},{28,28,28},{43,43,43},{21,21,21},{131,70,56},{111,60,48},{81,58,49},{71,71,71},{36,35,35},{22,21,20},{41,41,41},{36,36,36},{23,23,23},{17,17,17},{68,55,48},{97,81,79},{97,81,79},{76,64,58},{19,19,19},{43,43,43},{21,21,21},{65,65,65},{89,89,89},{25,25,25},{43,43,43},{38,38,38},{65,65,65},{21,21,21},{40,40,40},{89,89,89},{101,101,101},{82,72,70},{78,65,60},{76,60,55},{101,83,83},{72,59,54},{24,23,23},{69,63,58},{93,80,81},{31,29,28},{76,61,58},{77,63,57},{46,40,35},{83,67,61},{95,80,79},{27,27,27},{46,35,31},{96,81,83},{35,35,35},{69,63,58},{110,92,97},{54,50,45},{80,62,55},{97,81,81},{36,35,35},{80,62,55},{36,35,35},{118,101,103},{69,63,58},{36,35,35},{97,81,81},{46,35,31},{54,50,45},{110,92,97},{82,72,70},{35,35,35},{96,81,83},{101,83,83},{76,60,55},{78,65,60},{69,63,58},{24,23,23},{72,59,54},{76,61,58},{31,29,28},{93,80,81},{83,67,61},{46,40,35},{77,63,57},{95,80,79},{25,25,25},{27,27,27},{19,19,19},{35,35,35},{66,66,66},{27,27,27},{43,43,43},{35,35,35},{25,25,25},{47,46,45},{43,43,43},{46,46,46},{25,25,25},{25,25,25},{35,35,35},{25,25,25},{66,66,66},{27,27,27},{43,43,43},{83,83,83},{30,30,30},{27,27,27},{69,69,69},{16,16,16},{50,50,50},{47,47,47},{30,30,30},{50,50,50},{27,27,27},{27,27,27},{27,27,27},{43,43,43},{83,83,83},{43,43,43},{19,19,19},{19,19,19},{43,43,43},{27,27,27},{27,27,27},{50,50,50},{46,40,35},{46,40,35},{50,50,50},{31,29,28},{47,47,47},{31,29,28},{50,50,50},{47,47,47},{16,16,16},{43,43,43},{47,47,47},{43,43,43},{43,43,43},{43,43,43},{17,17,17},{47,47,47},{31,29,28},{47,47,47},{24,23,23},{76,60,55},{24,23,23},{47,47,47},{71,71,71},{75,75,75},{68,68,68},{75,75,75},{94,94,94},{68,68,68},{65,65,65},{35,35,35},{38,38,38},{43,43,43},{91,91,91},{57,57,57},{106,106,106},{82,82,82},{43,43,43},{49,49,49},{106,106,106},{43,43,43},{71,71,71},{43,43,43},{82,82,82},{43,43,43},{68,68,68},{94,94,94},{57,57,57},{43,43,43},{46,46,46},{57,57,57},{53,53,53},{68,68,68},{27,27,27},{46,46,46},{53,53,53},{43,43,43},{53,53,53},{46,46,46},{97,79,77},{21,21,21},{47,46,45},{64,64,64},{57,57,57},{64,64,64},{21,21,21},{97,79,77},{43,43,43},{97,79,77},{27,27,27},{43,43,43},{64,64,64},{43,43,43},{53,53,53},{84,73,77},{96,84,92},{106,89,92},{91,83,89},{106,89,92},{96,84,92},{69,69,69},{21,21,21},{21,21,21},{21,21,21},{21,21,21},{69,69,69},{142,133,137},{91,83,89},{96,84,92},{142,133,137},{96,84,92},{84,73,77},{84,73,77},{106,89,92},{104,86,90},{106,89,92},{91,83,89},{115,101,105},{21,21,21},{53,53,53},{21,21,21},{85,85,85},{21,21,21},{53,53,53},{62,62,62},{83,83,83},{101,101,101},{83,83,83},{53,53,53},{64,64,64},{64,64,64},{53,53,53},{64,64,64},{43,43,43},{64,64,64},{53,53,53},{53,53,53},{21,21,21},{43,43,43},{82,82,82},{21,21,21},{69,69,69},{38,38,38},{69,69,69},{21,21,21},{35,35,35},{55,55,55},{82,82,82},{55,55,55},{27,27,27},{82,82,82},{27,27,27},{82,82,82},{27,27,27},{21,21,21},{27,27,27},{25,25,25},{27,27,27},{46,46,46},{27,27,27},{25,25,25},{27,27,27},{46,46,46},{21,21,21},{21,21,21},{47,46,45},{43,43,43},{47,46,45},{21,21,21},{82,82,82},{38,38,38},{35,35,35},{21,21,21},{25,25,25},{43,43,43},{85,71,70},{97,80,78},{65,47,41},{97,79,77},{47,46,45},{97,80,78},{77,58,53},{97,80,78},{25,25,25},{25,25,25},{97,80,78},{47,46,45},{120,121,124},{122,101,105},{129,107,109},{116,98,102},{120,121,124},{129,107,109},{124,103,105},{129,107,109},{122,101,105},{129,107,109},{99,85,90},{125,104,106},{101,94,100},{125,104,106},{99,85,90},{84,73,77},{92,81,84},{142,133,137},{115,101,105},{91,83,89},{90,80,81},{96,78,77},{97,79,77},{92,80,81},{97,80,78},{85,71,70},{92,80,81},{97,79,77},{97,80,78},{92,80,81},{84,73,77},{104,86,90},{92,81,84},{91,75,72},{95,79,78},{101,94,100},{91,83,89},{142,133,137},{90,80,81},{92,81,84},{100,98,105},{142,133,137},{101,94,100},{96,78,77},{91,75,72},{106,75,68},{79,52,45},{68,49,44},{54,46,42},{92,57,46},{114,61,52},{52,46,42},{92,57,46},{54,46,42},{43,43,43},{47,47,47},{17,17,17},{79,52,45},{59,47,43},{68,49,44},{60,46,42},{59,47,43},{135,71,54},{60,46,42},{111,60,48},{114,65,53},{60,46,42},{114,65,53},{52,46,42},{114,65,53},{92,57,46},{52,46,42},{106,89,92},{115,101,105},{104,86,90},{78,78,78},{73,73,73},{57,57,57},{78,78,78},{57,57,57},{91,91,91},{43,43,43},{27,27,27},{27,27,27},{27,27,27},{27,27,27},{46,40,35},{43,43,43},{25,25,25},{35,35,35},{27,27,27},{53,53,53},{43,43,43},{83,83,83},{89,89,89},{101,101,101},{25,25,25},{43,43,43},{21,21,21},{101,101,101},{40,40,40},{62,62,62},{40,40,40},{85,85,85},{62,62,62},{78,78,78},{65,65,65},{73,73,73},{64,64,64},{89,89,89},{83,83,83},{43,43,43},{89,89,89},{64,64,64},{43,43,43},{68,68,68},{53,53,53},{39,39,38},{41,41,41},{49,49,48},{23,23,23},{49,49,49},{43,43,43},{30,30,30},{49,49,49},{41,41,41},{81,78,78},{39,39,38},{49,49,48},{27,27,27},{59,55,50},{40,40,40},{45,44,43},{43,43,43},{43,43,43},{55,52,49},{68,63,58},{27,27,27},{59,55,50},{27,27,27},{68,63,58},{36,36,36},{152,138,134},{76,60,55},{39,39,38},{33,33,32},{30,30,30},{60,45,37},{118,101,103},{36,35,35},{60,45,37},{19,19,19},{95,79,75},{64,50,43},{95,79,75},{19,19,19},{92,79,75},{19,19,19},{21,21,20},{60,43,36},{92,79,75},{21,21,20},{92,80,77},{21,21,20},{30,30,30},{61,49,43},{92,80,77},{30,30,30},{82,65,59},{30,30,30},{21,21,21},{67,56,48},{82,65,59},{21,21,21},{83,67,58},{21,21,21},{19,19,19},{82,64,56},{83,67,58},{19,19,19},{82,64,56},{17,17,17},{80,60,53},{68,55,48},{80,60,53},{17,17,17},{87,70,65},{68,55,48},{97,81,79},{76,64,58},{87,70,65},{97,81,79},{58,52,46},{58,56,54},{86,84,87},{19,19,19},{62,56,50},{17,17,17},{21,21,20},{19,19,19},{43,43,43},{21,21,21},{30,30,30},{19,19,19},{19,19,19},{21,21,21},{19,19,19},{86,84,87},{58,56,54},{39,39,38},{36,36,36},{35,35,35},{152,138,134},{36,35,35},{32,32,32},{36,35,35},{30,30,30},{21,21,20},{43,43,43},{43,43,43},{36,35,35},{43,43,43},{17,17,17},{19,19,19},{19,19,19},{40,40,40},{81,78,78},{27,27,27},{19,19,19},{43,43,43},{43,43,43},{97,81,79},{17,17,17},{22,22,22},{19,19,19},{36,35,35},{43,43,43},{97,81,79},{21,21,21},{19,19,19},{35,35,33},{43,43,43},{82,73,74},{58,52,46},{86,84,87},{81,78,78},{86,84,87},{39,39,38},{81,78,78},{69,63,58},{62,56,50},{58,52,46},{62,56,50},{69,63,58},{39,35,32},{39,35,32},{69,63,58},{40,40,40},{69,63,58},{58,52,46},{40,40,40},{59,55,50},{43,43,43},{40,40,40},{81,78,78},{40,40,40},{58,52,46},{27,27,27},{55,52,49},{81,78,78},{39,35,32},{40,40,40},{43,43,43},{58,56,54},{58,52,46},{62,56,50},{33,33,32},{39,39,38},{58,56,54},{39,35,32},{22,22,22},{62,56,50},{62,56,50},{22,22,22},{17,17,17},{62,56,50},{19,19,19},{58,56,54},{19,19,19},{33,33,32},{58,56,54},{57,57,57},{73,73,73},{64,64,64},{65,65,65},{43,43,43},{73,73,73},{43,43,43},{64,64,64},{73,73,73},{93,78,78},{125,104,106},{95,79,78},{125,104,106},{114,93,98},{116,98,102},{129,107,109},{125,104,106},{116,98,102},{93,78,78},{92,80,81},{85,71,70},{76,60,55},{152,138,134},{35,35,35},{54,50,45},{35,35,35},{155,141,138},{38,38,38},{155,141,138},{35,35,35},{38,38,38},{54,50,45},{155,141,138},{32,32,32},{160,147,143},{54,50,45},{36,35,35},{54,50,45},{160,147,143},{36,35,35},{160,147,143},{32,32,32},{36,36,36},{38,38,38},{35,35,35},{32,32,32},{54,50,45},{38,38,38},{32,32,32},{43,43,43},{36,35,35},{76,60,55},{47,47,47},{36,36,36},{49,49,49},{36,36,36},{47,47,47},{36,36,36},{43,43,43},{38,38,38},{32,32,32},{38,38,38},{43,43,43},{36,36,36},{49,49,49},{43,43,43},{30,30,30},{43,43,43},{49,49,49},{36,36,36},{40,40,40},{49,49,48},{40,40,40},{32,32,32},{49,49,48},{81,78,78},{49,49,48},{32,32,32},{40,40,40},{36,36,36},{23,23,23},{23,23,23},{41,41,41},{49,49,49},{98,100,105},{66,60,55},{83,81,83},{16,16,16},{19,19,19},{23,22,22},{16,16,16},{25,25,25},{19,19,19},{70,66,60},{66,60,55},{98,100,105},{50,50,50},{41,41,41},{29,26,24},{46,46,46},{41,41,41},{50,50,50},{41,41,41},{66,60,55},{29,26,24},{41,41,41},{16,16,16},{66,60,55},{83,81,83},{19,19,19},{82,80,81},{82,80,81},{19,19,19},{32,32,32},{25,25,25},{32,32,32},{19,19,19},{25,25,25},{25,25,25},{17,17,17},{25,25,25},{50,50,50},{17,17,17},{16,16,16},{50,50,50},{25,25,25},{46,46,46},{46,46,46},{25,25,25},{46,46,46},{32,32,32},{25,25,25},{25,25,25},{41,41,41},{46,46,46},{50,50,50},{16,16,16},{17,17,17},{41,41,41},{25,25,25},{16,16,16},{16,16,16},{25,25,25},{17,17,17},{17,17,17},{25,25,25},{32,32,32},{25,25,25},{40,40,40},{32,32,32},{19,19,19},{19,19,19},{35,35,35},{67,57,53},{19,19,19},{38,38,38},{19,19,19},{55,55,55},{38,38,38},{38,38,38},{67,57,53},{77,68,64},{38,38,38},{25,25,25},{25,25,25},{28,28,28},{38,38,38},{34,34,34},{19,19,19},{77,68,64},{76,64,58},{43,43,43},{38,38,38},{16,16,16},{19,19,19},{35,35,33},{53,48,44},{38,38,38},{19,19,19},{16,16,16},{43,43,43},{25,25,25},{49,49,49},{43,43,43},{53,48,44},{26,23,23},{81,75,74},{26,23,23},{53,48,44},{44,43,41},{34,34,34},{26,23,23},{62,58,53},{34,34,34},{44,43,41},{28,28,28},{50,49,47},{32,32,32},{50,49,47},{28,28,28},{62,58,53},{82,80,79},{62,58,53},{44,43,41},{80,70,69},{32,32,32},{50,49,47},{77,66,61},{36,36,36},{32,32,32},{19,19,19},{28,28,28},{32,32,32},{19,19,19},{32,32,32},{36,36,36},{46,46,46},{19,19,19},{36,36,36},{36,36,36},{30,30,29},{46,46,46},{55,55,55},{46,46,46},{30,30,29},{46,46,46},{55,55,55},{55,55,55},{55,55,55},{32,32,32},{55,55,55},{66,60,55},{23,22,22},{19,19,19},{19,19,19},{83,81,83},{66,60,55},{66,60,55},{16,16,16},{23,22,22},{25,25,25},{19,19,19},{49,49,49},{19,19,19},{43,43,43},{49,49,49},{16,16,16},{19,19,19},{49,49,49},{16,16,16},{49,49,49},{43,43,43},{43,43,43},{49,49,49},{19,19,19},{43,43,43},{55,55,55},{38,38,38},{34,34,34},{38,38,38},{55,55,55},{43,43,43},{34,34,34},{55,55,55},{21,21,21},{25,25,25},{43,43,43},{16,16,16},{43,43,43},{19,19,19},{16,16,16},{19,19,19},{43,43,43},{21,21,21},{43,43,43},{19,19,19},{19,19,19},{25,25,25},{43,43,43},{19,19,19},{43,43,43},{25,25,25},{28,28,28},{19,19,19},{59,59,59},{35,35,35},{28,28,28},{59,59,59},{35,35,35},{59,59,59},{19,19,19},{55,55,55},{50,50,50},{46,46,46},{46,46,46},{50,50,50},{19,19,19},{55,55,55},{19,19,19},{50,50,50},{61,56,49},{91,91,95},{38,37,35},{91,91,95},{58,56,55},{38,37,35},{58,56,55},{91,91,95},{17,17,17},{102,104,110},{61,56,49},{38,37,35},{75,75,75},{60,58,53},{38,37,35},{102,104,110},{38,37,35},{60,58,53},{99,101,106},{60,58,53},{75,75,75},{38,37,35},{27,27,27},{75,75,75},{38,38,38},{38,37,35},{58,56,55},{27,27,27},{66,66,66},{46,46,46},{38,38,38},{27,27,27},{46,46,46},{66,66,66},{27,27,27},{34,34,34},{38,38,38},{34,34,34},{27,27,27},{28,28,28},{34,34,34},{38,38,38},{34,34,34},{28,28,28},{81,81,81},{27,27,27},{81,81,81},{40,40,40},{27,27,27},{32,32,32},{81,81,81},{40,40,40},{64,64,64},{27,27,27},{73,73,73},{75,75,75},{25,25,25},{81,81,81},{30,30,30},{34,34,34},{25,25,25},{25,25,25},{28,28,28},{34,34,34},{30,30,30},{66,66,66},{28,28,28},{40,40,40},{28,28,28},{20,20,20},{19,19,19},{25,25,25},{59,59,59},{30,30,30},{25,25,25},{28,28,28},{41,41,41},{28,28,28},{20,20,20},{36,36,36},{41,41,41},{56,48,43},{43,39,35},{25,25,25},{27,27,26},{56,48,43},{25,25,25},{56,48,43},{27,27,26},{82,69,65},{56,48,43},{35,32,28},{43,39,35},{101,94,101},{35,32,28},{56,48,43},{82,69,65},{101,94,101},{56,48,43},{110,104,110},{82,69,65},{27,27,26},{35,35,35},{110,104,110},{27,27,26},{112,114,117},{43,39,35},{35,32,28},{112,114,117},{85,72,68},{43,39,35},{39,38,35},{43,39,35},{85,72,68},{115,109,114},{39,38,35},{85,72,68},{123,115,118},{39,38,35},{115,109,114},{20,20,20},{28,28,28},{19,19,19},{27,27,26},{28,28,28},{35,35,35},{40,40,40},{20,20,20},{32,32,32},{19,19,19},{32,32,32},{20,20,20},{19,19,19},{30,30,30},{32,32,32},{36,36,36},{32,32,32},{30,30,30},{20,20,20},{19,19,19},{20,20,20},{36,36,36},{30,30,30},{59,59,59},{21,21,21},{38,38,38},{34,34,34},{64,58,53},{31,28,24},{38,35,32},{68,62,57},{50,49,48},{59,54,48},{75,75,75},{38,38,38},{99,101,106},{31,28,24},{54,49,43},{59,54,48},{50,49,48},{31,28,24},{59,54,48},{31,28,24},{50,49,48},{38,38,38},{38,35,32},{38,38,38},{23,23,23},{28,28,28},{25,25,25},{21,21,21},{27,27,27},{28,28,28},{43,43,43},{28,28,28},{27,27,27},{34,34,34},{40,40,40},{32,32,32},{25,25,25},{32,32,32},{36,36,36},{25,25,25},{27,27,27},{32,32,32},{34,34,34},{32,32,32},{46,46,46},{34,34,34},{23,23,23},{25,25,25},{62,62,62},{46,46,46},{41,41,41},{62,62,62},{41,41,41},{38,35,32},{23,23,23},{17,17,17},{25,25,25},{58,56,55},{23,23,23},{62,62,62},{41,41,41},{25,25,25},{34,34,34},{62,62,62},{34,34,34},{46,46,46},{62,62,62},{43,39,35},{39,38,35},{36,36,36},{36,36,36},{39,38,35},{25,25,25},{39,38,35},{123,115,118},{25,25,25},{20,20,20},{40,40,40},{27,27,27},{20,20,20},{20,20,20},{27,27,27},{28,28,28},{28,28,28},{32,32,32},{32,32,32},{28,28,28},{27,27,27},{21,21,21},{27,27,27},{28,28,28},{84,73,58},{101,91,78},{87,80,71},{76,67,55},{101,91,78},{119,113,102},{105,95,81},{49,40,28},{76,67,55},{111,102,89},{111,99,86},{49,40,28},{75,55,51},{52,43,41},{65,46,42},{63,46,42},{52,43,41},{40,31,27},{40,31,27},{48,35,31},{63,46,42},{111,99,86},{65,46,42},{49,40,28},{87,80,71},{63,46,42},{48,35,31},{65,46,42},{63,46,42},{76,67,55},{101,91,78},{76,67,55},{63,46,42},{76,67,55},{49,40,28},{65,46,42},{25,25,25},{43,43,43},{57,57,57},{75,75,75},{38,38,38},{38,38,38},{38,38,38},{50,49,48},{36,36,36},{40,40,40},{81,81,81},{28,28,28},{19,19,19},{27,27,26},{25,25,25},{25,25,25},{38,38,38},{25,25,25},{73,69,65},{32,32,32},{55,55,55},{80,72,70},{30,30,29},{36,36,36},{20,20,20},{28,28,28},{30,30,30},{25,25,25},{43,39,35},{36,36,36},{30,30,30},{28,28,28},{25,25,25},{58,56,55},{28,28,28},{38,38,38},{25,25,25},{28,28,28},{58,56,55},{59,59,59},{89,88,92},{43,43,43},{34,34,34},{43,43,43},{89,88,92},{58,56,55},{71,71,71},{77,72,70},{97,99,105},{71,71,71},{58,56,55},{22,21,20},{71,71,71},{97,99,105},{22,21,21},{43,43,43},{81,79,79},{81,79,79},{43,43,43},{36,35,35},{21,21,21},{71,71,71},{36,35,35},{77,72,70},{71,71,71},{34,34,34},{43,43,43},{34,34,34},{71,71,71},{35,35,35},{43,43,43},{58,58,58},{58,58,58},{71,71,71},{21,21,21},{35,35,35},{73,73,73},{43,43,43},{73,73,73},{59,59,59},{43,43,43},{53,53,53},{35,35,35},{58,58,58},{19,19,19},{53,53,53},{58,58,58},{43,43,43},{43,43,43},{23,23,23},{43,43,43},{21,21,21},{36,35,35},{70,66,60},{54,54,54},{22,21,21},{28,27,26},{54,54,54},{70,66,60},{54,54,54},{43,43,43},{43,43,43},{58,49,45},{25,25,25},{43,43,43},{23,23,23},{54,54,54},{43,43,43},{43,43,43},{43,43,43},{32,32,32},{43,43,43},{43,43,43},{25,25,25},{43,43,43},{43,43,43},{25,25,25},{23,23,23},{47,46,46},{43,43,43},{43,43,43},{41,40,40},{23,23,23},{47,46,46},{23,23,23},{41,40,40},{47,46,46},{41,40,40},{111,106,112},{43,43,43},{22,21,21},{54,54,54},{54,54,53},{54,54,54},{28,27,26},{43,43,43},{54,54,54},{54,54,53},{19,19,19},{81,81,81},{28,28,28},{50,50,50},{19,19,19},{28,28,28},{23,23,23},{50,50,50},{28,28,28},{81,81,81},{19,19,19},{58,58,58},{28,28,28},{81,81,81},{58,58,58},{21,21,21},{28,28,28},{58,58,58},{43,43,43},{28,28,28},{21,21,21},{43,43,43},{23,23,23},{28,28,28},{111,106,112},{76,63,58},{47,46,46},{39,38,38},{47,46,46},{76,63,58},{76,63,58},{123,115,119},{39,38,38},{101,92,93},{39,38,38},{123,115,119},{45,44,41},{39,38,38},{101,92,93},{101,92,93},{110,106,110},{45,44,41},{80,67,60},{45,44,41},{110,106,110},{27,27,27},{45,44,41},{80,67,60},{80,67,60},{114,106,112},{27,27,27},{76,69,64},{27,27,27},{114,106,112},{23,23,23},{27,27,27},{41,41,41},{43,43,43},{47,46,46},{39,38,38},{27,27,27},{39,38,38},{45,44,41},{27,27,27},{43,43,43},{39,38,38},{27,27,27},{27,27,27},{45,44,41},{23,23,23},{41,41,41},{50,50,50},{34,34,34},{32,32,32},{55,55,55},{41,41,41},{55,55,55},{69,69,69},{87,86,90},{42,38,34},{26,24,23},{36,35,35},{27,25,23},{81,79,79},{25,23,23},{73,68,64},{43,43,43},{42,38,34},{89,89,89},{26,24,23},{84,81,83},{89,89,89},{42,38,34},{45,45,44},{55,55,55},{44,44,43},{45,45,44},{64,64,64},{55,55,55},{45,45,44},{44,44,43},{91,90,95},{30,30,30},{43,43,43},{32,32,32},{55,55,55},{32,32,32},{69,69,69},{32,32,32},{32,32,32},{55,55,55},{36,35,35},{22,21,20},{27,25,23},{58,49,45},{43,43,43},{53,53,53},{65,59,54},{38,38,38},{36,36,36},{43,43,43},{54,54,53},{53,53,53},{36,36,36},{43,43,43},{43,43,43},{46,41,35},{25,23,23},{21,21,21},{43,43,43},{21,21,21},{25,23,23},{38,38,38},{27,27,27},{28,28,28},{43,43,43},{38,38,38},{28,28,28},{27,27,27},{21,21,21},{28,28,28},{21,21,21},{43,43,43},{43,43,43},{32,32,32},{43,43,43},{43,43,43},{32,32,32},{32,32,32},{43,43,43},{25,25,25},{43,43,43},{32,32,32},{25,25,25},{32,32,32},{28,28,28},{28,28,28},{38,38,38},{43,43,43},{28,28,28},{32,32,32},{38,38,38},{32,32,32},{20,20,20},{38,38,38},{65,46,42},{45,35,33},{48,35,31},{111,102,89},{111,100,87},{63,55,45},{106,97,82},{63,55,45},{76,67,55},{119,113,102},{76,67,55},{101,91,78},{84,73,58},{101,91,78},{87,80,71},{48,35,31},{76,67,55},{65,46,42},{76,67,55},{63,55,45},{65,46,42},{65,46,42},{63,55,45},{111,100,87},{101,91,78},{76,67,55},{48,35,31},{87,80,71},{101,91,78},{48,35,31},{64,64,64},{43,43,43},{53,53,53},{41,41,41},{64,64,64},{50,50,50},{53,53,53},{43,43,43},{40,40,40},{43,43,43},{41,41,41},{64,64,64},{32,32,32},{71,71,71},{35,35,35},{38,38,38},{64,64,64},{41,41,41},{64,64,64},{77,77,77},{50,50,50},{43,43,43},{27,27,27},{32,32,32},{43,43,43},{64,64,64},{41,41,41},{19,19,19},{35,35,35},{71,71,71},{43,43,43},{27,27,27},{40,40,40},{68,68,68},{32,32,32},{35,35,35},{27,27,27},{64,64,64},{32,32,32},{49,49,49},{50,50,50},{77,77,77},{46,46,46},{36,36,36},{30,30,30},{27,27,27},{69,69,69},{30,30,30},{69,69,69},{47,47,47},{30,30,30},{46,46,46},{30,30,30},{41,41,41},{49,49,49},{30,30,30},{27,27,27},{27,27,27},{71,71,71},{49,49,49},{71,71,71},{55,55,55},{49,49,49},{49,49,49},{55,55,55},{30,30,30},{55,55,55},{46,46,46},{30,30,30},{46,46,46},{27,27,27},{30,30,30},{27,27,27},{101,101,101},{40,40,40},{64,64,64},{27,27,27},{43,43,43},{64,64,64},{71,71,71},{32,32,32},{44,44,44},{30,30,30},{47,47,47},{47,47,47},{30,30,30},{30,30,30},{30,30,30},{41,41,41},{30,30,30},{69,69,69},{44,44,44},{50,50,50},{69,69,69},{50,50,50},{44,44,44},{30,30,30},{49,49,49},{73,73,73},{49,49,49},{44,44,44},{73,73,73},{73,73,73},{44,44,44},{69,69,69},{36,36,36},{34,34,34},{49,49,49},{49,49,49},{30,30,30},{36,36,36},{34,34,34},{25,25,25},{49,49,49},{25,25,25},{69,69,69},{44,44,44},{49,49,49},{25,25,25},{44,44,44},{44,43,41},{26,23,23},{26,23,23},{26,23,23},{26,23,23},{81,75,74},{50,49,47},{62,58,53},{62,58,53},{62,58,53},{62,58,53},{82,80,79},{77,66,61},{32,32,32},{32,32,32},{32,32,32},{32,32,32},{80,70,69},{73,69,65},{55,55,55},{55,55,55},{30,30,29},{30,30,29},{80,72,70},{25,25,25},{55,55,55},{32,32,32},{28,28,28},{34,34,34},{62,58,53},{40,40,40},{25,25,25},{25,25,25},{25,25,25},{25,25,25},{32,32,32},{34,34,34},{43,43,43},{26,23,23},{28,28,28},{21,21,21},{43,43,43},{131,70,56},{81,58,49},{111,60,48},{71,71,71},{22,21,20},{36,35,35},{41,41,41},{23,23,23},{36,36,36},{17,17,17},{97,81,79},{68,55,48},{97,81,79},{19,19,19},{76,64,58},{43,43,43},{65,65,65},{21,21,21},{89,89,89},{43,43,43},{25,25,25},{38,38,38},{21,21,21},{65,65,65},{89,89,89},{40,40,40},{101,101,101},{81,58,49},{131,70,56},{131,70,56},{106,60,48},{131,70,56},{131,70,56},{60,46,42},{131,70,56},{106,60,48},{60,46,42},{106,60,48},{131,70,56},{55,52,49},{81,78,78},{32,32,32},{27,27,27},{81,78,78},{55,52,49},{36,35,35},{36,35,35},{80,62,55},{36,35,35},{54,50,45},{69,63,58},{54,50,45},{35,35,35},{46,35,31},{35,35,35},{76,60,55},{82,72,70},{76,60,55},{24,23,23},{101,83,83},{24,23,23},{31,29,28},{69,63,58},{31,29,28},{46,40,35},{76,61,58},{46,40,35},{27,27,27},{83,67,61},{95,80,79},{27,27,27},{25,25,25},{35,35,35},{27,27,27},{19,19,19},{27,27,27},{35,35,35},{43,43,43},{35,35,35},{66,66,66},{25,25,25},{30,30,30},{27,27,27},{50,50,50},{27,27,27},{43,43,43},{27,27,27},{16,16,16},{50,50,50},{47,47,47},{43,43,43},{68,68,68},{71,71,71},{43,43,43},{94,94,94},{68,68,68},{57,57,57},{46,46,46},{43,43,43},{57,57,57},{68,68,68},{53,53,53},{21,21,21},{21,21,21},{53,53,53},{85,85,85},{53,53,53},{21,21,21},{62,62,62},{101,101,101},{83,83,83},{53,53,53},{85,85,85},{83,83,83},{64,64,64},{64,64,64},{53,53,53},{21,21,21},{27,27,27},{82,82,82},{38,38,38},{69,69,69},{82,82,82},{97,80,78},{65,47,41},{77,58,53},{124,103,105},{122,101,105},{129,107,109},{125,104,106},{95,79,78},{101,94,100},{96,78,77},{97,79,77},{101,94,100},{43,43,43},{17,17,17},{47,47,47},{59,47,43},{135,71,54},{79,52,45},{60,46,42},{114,65,53},{111,60,48},{85,85,85},{25,25,25},{40,40,40},{39,39,38},{49,49,48},{41,41,41},{45,44,43},{43,43,43},{43,43,43},{19,19,19},{36,35,35},{60,45,37},{92,79,75},{21,21,20},{19,19,19},{92,80,77},{30,30,30},{21,21,20},{82,65,59},{21,21,21},{30,30,30},{83,67,58},{19,19,19},{21,21,21},{17,17,17},{19,19,19},{82,64,56},{59,55,50},{40,40,40},{43,43,43},{125,104,106},{114,93,98},{93,78,78},{92,80,81},{95,79,78},{93,78,78},{70,66,60},{98,100,105},{66,60,55},{19,19,19},{35,35,35},{19,19,19},{19,19,19},{35,35,35},{67,57,53},{67,57,53},{35,35,35},{38,38,38},{25,25,25},{55,55,55},{38,38,38},{28,28,28},{34,34,34},{38,38,38},{19,19,19},{76,64,58},{77,68,64},{35,35,33},{43,43,43},{19,19,19},{53,48,44},{19,19,19},{43,43,43},{21,21,21},{43,43,43},{25,25,25},{38,38,38},{58,56,55},{38,37,35},{38,38,38},{46,46,46},{27,27,27},{81,81,81},{34,34,34},{30,30,30},{25,25,25},{73,73,73},{25,25,25},{28,28,28},{28,28,28},{40,40,40},{19,19,19},{30,30,30},{20,20,20},{28,28,28},{28,28,28},{41,41,41},{20,20,20},{41,41,41},{36,36,36},{28,28,28},{19,19,19},{27,27,26},{38,38,38},{25,25,25},{21,21,21},{38,38,38},{31,28,24},{38,35,32},{25,25,25},{34,34,34},{28,28,28},{28,28,28},{34,34,34},{27,27,27},{25,25,25},{62,62,62},{34,34,34},{20,20,20},{27,27,27},{20,20,20},{27,27,27},{25,25,25},{21,21,21},{52,43,41},{65,46,42},{63,46,42},{111,99,86},{49,40,28},{65,46,42},{63,46,42},{101,91,78},{87,80,71},{71,71,71},{43,43,43},{58,58,58},{43,43,43},{23,23,23},{43,43,43},{23,23,23},{43,43,43},{54,54,54},{43,43,43},{54,54,54},{43,43,43},{43,43,43},{23,23,23},{41,40,40},{28,28,28},{43,43,43},{43,43,43},{27,27,27},{43,43,43},{23,23,23},{43,43,43},{38,38,38},{36,36,36},{43,43,43},{28,28,28},{25,25,25},{65,46,42},{48,35,31},{45,35,33},{19,19,19},{71,71,71},{35,35,35},{55,55,55},{55,55,55},{30,30,29},{40,40,40},{25,25,25},{89,89,89},{80,62,55},{36,35,35},{36,35,35},{69,63,58},{54,50,45},{36,35,35},{46,35,31},{35,35,35},{54,50,45},{82,72,70},{76,60,55},{35,35,35},{101,83,83},{24,23,23},{76,60,55},{69,63,58},{31,29,28},{24,23,23},{76,61,58},{46,40,35},{31,29,28},{83,67,61},{27,27,27},{46,40,35},{95,80,79},{77,58,53},{25,25,25},{19,19,19},{27,27,27},{35,35,35},{27,27,27},{25,25,25},{43,43,43},{35,35,35},{25,25,25},{25,25,25},{30,30,30},{47,47,47},{50,50,50},{27,27,27},{69,69,69},{27,27,27},{47,47,47},{50,50,50},{16,16,16},{71,71,71},{68,68,68},{43,43,43},{43,43,43},{57,57,57},{68,68,68},{57,57,57},{49,49,49},{43,43,43},{57,57,57},{64,64,64},{53,53,53},{21,21,21},{53,53,53},{53,53,53},{85,85,85},{25,25,25},{21,21,21},{62,62,62},{85,85,85},{83,83,83},{83,83,83},{85,85,85},{53,53,53},{64,64,64},{53,53,53},{53,53,53},{82,82,82},{27,27,27},{21,21,21},{82,82,82},{69,69,69},{38,38,38},{77,58,53},{65,47,41},{97,80,78},{124,103,105},{99,85,90},{129,107,109},{101,94,100},{95,79,78},{125,104,106},{101,94,100},{97,79,77},{96,78,77},{43,43,43},{49,49,49},{47,47,47},{79,52,45},{135,71,54},{59,47,43},{60,46,42},{131,70,56},{111,60,48},{40,40,40},{25,25,25},{85,85,85},{39,39,38},{30,30,30},{41,41,41},{45,44,43},{82,73,74},{43,43,43},{60,45,37},{36,35,35},{19,19,19},{92,79,75},{64,50,43},{19,19,19},{92,80,77},{60,43,36},{21,21,20},{82,65,59},{61,49,43},{30,30,30},{83,67,58},{67,56,48},{21,21,21},{82,64,56},{19,19,19},{17,17,17},{59,55,50},{45,44,43},{43,43,43},{93,78,78},{114,93,98},{125,104,106},{93,78,78},{95,79,78},{92,80,81},{70,66,60},{29,26,24},{66,60,55},{19,19,19},{46,46,46},{19,19,19},{67,57,53},{35,35,35},{19,19,19},{38,38,38},{35,35,35},{67,57,53},{38,38,38},{55,55,55},{25,25,25},{28,28,28},{35,35,35},{38,38,38},{19,19,19},{38,38,38},{77,68,64},{19,19,19},{43,43,43},{35,35,33},{43,43,43},{19,19,19},{53,48,44},{21,21,21},{19,19,19},{25,25,25},{38,38,38},{27,27,27},{38,37,35},{38,38,38},{75,75,75},{27,27,27},{81,81,81},{32,32,32},{30,30,30},{25,25,25},{73,73,73},{25,25,25},{28,28,28},{64,64,64},{40,40,40},{20,20,20},{30,30,30},{19,19,19},{28,28,28},{20,20,20},{41,41,41},{20,20,20},{25,25,25},{36,36,36},{27,27,26},{19,19,19},{28,28,28},{21,21,21},{25,25,25},{38,38,38},{38,35,32},{31,28,24},{38,38,38},{28,28,28},{34,34,34},{25,25,25},{28,28,28},{28,28,28},{27,27,27},{25,25,25},{25,25,25},{34,34,34},{20,20,20},{20,20,20},{20,20,20},{21,21,21},{25,25,25},{27,27,27},{63,46,42},{65,46,42},{52,43,41},{111,99,86},{75,55,51},{65,46,42},{87,80,71},{101,91,78},{63,46,42},{58,58,58},{43,43,43},{71,71,71},{43,43,43},{23,23,23},{43,43,43},{23,23,23},{43,43,43},{54,54,54},{43,43,43},{54,54,54},{43,43,43},{43,43,43},{32,32,32},{41,40,40},{43,43,43},{43,43,43},{28,28,28},{23,23,23},{43,43,43},{27,27,27},{36,36,36},{38,38,38},{43,43,43},{25,25,25},{28,28,28},{43,43,43},{65,46,42},{52,43,41},{45,35,33},{19,19,19},{46,46,46},{35,35,35},{89,89,89},{25,25,25},{40,40,40}},["weights"]={{{1,0.705613},{8,0.253069},{6,0.0413183}},{{1,0.788719},{6,0.211281}},{{6,0.885881},{1,0.114119}},{{6,0.912362},{2,0.0876377}},{{6,0.713535},{2,0.286465}},{{2,0.825566},{6,0.170257},{23,0.00417739}},{{2,0.999399},{6,0.000601489}},{{2,1}},{{2,1}},{{2,1}},{{7,1}},{{8,0.36427},{7,0.328412},{1,0.307319}},{{1,0.819388},{8,0.151936},{6,0.0286762}},{{1,0.899811},{6,0.100189}},{{1,0.934322},{6,0.0656776}},{{6,0.838163},{1,0.161837}},{{6,0.926664},{1,0.0733356}},{{6,0.989579},{2,0.0104214}},{{2,0.714235},{6,0.285765}},{{2,0.768797},{6,0.13533},{25,0.095873}},{{7,0.960287},{1,0.0397133}},{{7,1}},{{7,1}},{{8,0.992722},{9,0.00727755}},{{8,1}},{{7,1}},{{7,1}},{{7,1}},{{8,0.836081},{7,0.163919}},{{8,1}},{{7,1}},{{7,1}},{{7,0.867546},{1,0.132454}},{{8,1}},{{8,0.971385},{9,0.0180457},{7,0.0105688}},{{8,0.949962},{7,0.0500379}},{{8,0.928829},{7,0.0711705}},{{8,0.93954},{7,0.0604596}},{{8,0.969506},{7,0.0304938}},{{7,0.962503},{1,0.037497}},{{7,0.697793},{1,0.302207}},{{7,0.717823},{1,0.282177}},{{7,0.662452},{1,0.337548}},{{7,0.920259},{1,0.0797408}},{{7,0.701293},{1,0.298707}},{{7,0.707494},{1,0.292506}},{{7,0.848398},{1,0.151602}},{{1,0.921705},{7,0.0782949}},{{1,1}},{{1,0.946278},{6,0.0537216}},{{1,0.648978},{7,0.351022}},{{8,0.996588},{1,0.00341153}},{{1,0.879119},{7,0.120881}},{{8,1}},{{8,1}},{{8,0.927913},{7,0.0720869}},{{8,0.97582},{7,0.0241804}},{{7,0.779544},{1,0.220456}},{{7,0.7028},{1,0.2972}},{{7,0.701126},{1,0.298874}},{{7,0.713289},{1,0.286711}},{{12,0.973763},{11,0.0262367}},{{12,0.681179},{13,0.318821}},{{13,0.707732},{12,0.292268}},{{11,0.923957},{15,0.0727407},{12,0.00330269}},{{16,0.92996},{11,0.0573148},{12,0.0127249}},{{4,0.540123},{23,0.360038},{2,0.0998391}},{{2,0.688106},{23,0.311893}},{{10,0.899548},{25,0.0664749},{15,0.0339776}},{{10,0.723845},{15,0.178397},{19,0.0977575}},{{16,0.787269},{12,0.212731}},{{16,1}},{{23,1}},{{23,1}},{{23,1}},{{4,1}},{{23,1}},{{10,1}},{{10,0.755753},{15,0.212087},{28,0.0321596}},{{11,1}},{{11,0.755671},{12,0.244329}},{{4,0.997246},{2,0.00275445}},{{4,1}},{{16,0.68194},{15,0.169487},{10,0.148574}},{{16,0.763737},{10,0.132935},{15,0.103328}},{{10,0.817688},{15,0.165958},{25,0.0163536}},{{10,0.748687},{15,0.239296},{16,0.0120174}},{{10,0.82741},{15,0.127596},{16,0.0449946}},{{10,0.91063},{15,0.0859833},{25,0.0033868}},{{10,1}},{{10,0.515781},{15,0.291575},{16,0.192644}},{{15,0.870199},{10,0.129801}},{{2,0.991468},{6,0.00853181}},{{2,0.996662},{6,0.00333756}},{{2,1}},{{2,0.941595},{6,0.0584048}},{{2,1}},{{2,1}},{{25,0.899604},{2,0.0620397},{31,0.0279038},{10,0.0104524}},{{25,0.748241},{2,0.244619},{6,0.00714028}},{{25,0.98941},{31,0.0105898}},{{13,0.737345},{14,0.262655}},{{13,0.656923},{14,0.343077}},{{14,1}},{{14,0.932732},{13,0.0672685}},{{14,1}},{{13,0.642514},{12,0.357486}},{{12,0.5},{13,0.5}},{{12,0.5},{13,0.5}},{{13,0.765536},{14,0.234464}},{{13,0.82848},{14,0.17152}},{{13,0.728029},{14,0.271971}},{{14,0.978751},{13,0.0212491}},{{14,1}},{{14,1}},{{14,1}},{{12,0.876114},{11,0.123886}},{{12,0.692555},{13,0.307445}},{{12,0.88957},{13,0.091021},{11,0.0194085}},{{12,0.748081},{13,0.251919}},{{12,0.74653},{11,0.25347}},{{14,1}},{{11,0.662356},{12,0.337644}},{{11,0.741797},{12,0.258203}},{{12,0.987055},{13,0.0129446}},{{12,0.767038},{13,0.232962}},{{12,0.715037},{11,0.27942},{16,0.00554323}},{{13,0.68012},{12,0.31988}},{{13,0.770279},{14,0.229721}},{{4,1}},{{4,1}},{{3,1}},{{3,0.676524},{24,0.323476}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{4,1}},{{3,0.682554},{4,0.317446}},{{4,1}},{{4,1}},{{4,0.86775},{3,0.13225}},{{4,0.790119},{3,0.209881}},{{3,1}},{{3,1}},{{3,0.99827},{24,0.0017299}},{{3,0.966261},{24,0.0337387}},{{3,0.618582},{24,0.381418}},{{3,0.875416},{4,0.124584}},{{3,0.821309},{24,0.178691}},{{24,1}},{{24,1}},{{24,1}},{{24,1}},{{24,1}},{{24,0.980914},{3,0.0190861}},{{24,0.931974},{3,0.0680255}},{{24,1}},{{24,0.959834},{3,0.0401661}},{{24,0.92218},{3,0.0778199}},{{24,1}},{{24,0.996273},{3,0.00372654}},{{24,0.988143},{3,0.011857}},{{3,0.527509},{24,0.472491}},{{3,1}},{{3,0.813677},{24,0.186323}},{{3,1}},{{3,0.928158},{24,0.0718421}},{{3,1}},{{3,0.987729},{24,0.0122707}},{{4,0.956514},{3,0.0434858}},{{3,0.811172},{24,0.188828}},{{3,0.559637},{24,0.440363}},{{3,0.504395},{24,0.495605}},{{3,0.511527},{24,0.488473}},{{4,0.927973},{23,0.0720267}},{{3,0.843557},{24,0.156},{4,0.00044303}},{{3,1}},{{16,1}},{{16,1}},{{16,0.741938},{10,0.258062}},{{16,0.714988},{10,0.285012}},{{16,0.979537},{17,0.0204633}},{{16,0.94306},{10,0.0358218},{15,0.0211186}},{{16,1}},{{17,0.882016},{16,0.117984}},{{17,0.903343},{18,0.0966566}},{{16,1}},{{16,1}},{{16,0.987343},{12,0.0126566}},{{16,1}},{{16,1}},{{16,1}},{{17,0.780035},{16,0.204923},{11,0.0150419}},{{17,0.887082},{16,0.112918}},{{17,0.924192},{16,0.0689042},{18,0.00690353}},{{17,0.929348},{18,0.0518958},{16,0.0187558}},{{17,0.93351},{18,0.0658016},{16,0.000687958}},{{17,0.922959},{18,0.0770412}},{{17,0.5},{18,0.5}},{{18,0.855275},{17,0.144725}},{{18,0.928791},{17,0.0712087}},{{18,0.774674},{17,0.225326}},{{18,0.98689},{17,0.0131099}},{{16,1}},{{16,1}},{{16,1}},{{16,0.83192},{17,0.16808}},{{16,0.969387},{17,0.0306132}},{{17,0.883479},{16,0.116521}},{{17,0.874549},{18,0.125451}},{{17,0.891989},{16,0.108011}},{{17,0.868968},{18,0.131032}},{{16,0.894649},{17,0.105351}},{{18,0.950037},{17,0.0499626}},{{18,0.871421},{17,0.128579}},{{18,0.816453},{17,0.183548}},{{18,0.79037},{17,0.20963}},{{18,0.766701},{17,0.233299}},{{18,0.760108},{17,0.239892}},{{18,0.755306},{17,0.244694}},{{18,0.739115},{17,0.260885}},{{18,0.646747},{17,0.353253}},{{18,0.691225},{17,0.308775}},{{17,0.84633},{18,0.144825},{16,0.00884491}},{{17,0.803716},{16,0.196284}},{{17,0.935179},{18,0.0648214}},{{17,0.5},{18,0.5}},{{17,0.871289},{18,0.128712}},{{17,0.88537},{16,0.11463}},{{18,0.666201},{17,0.333799}},{{25,1}},{{25,1}},{{25,1}},{{25,1}},{{25,1}},{{25,1}},{{25,0.998092},{26,0.00190836}},{{25,0.532598},{26,0.467402}},{{26,1}},{{26,1}},{{26,1}},{{26,1}},{{26,0.642042},{25,0.357958}},{{25,0.515238},{26,0.484762}},{{25,0.825459},{26,0.174541}},{{25,1}},{{25,0.812402},{26,0.187598}},{{25,1}},{{25,0.718223},{26,0.281777}},{{26,1}},{{9,1}},{{8,1}},{{1,0.492014},{8,0.455626},{6,0.0523599}},{{1,0.479216},{6,0.351211},{8,0.169572}},{{1,0.473235},{6,0.391306},{8,0.135459}},{{6,0.811208},{1,0.128076},{8,0.0483232},{2,0.0123929}},{{6,0.853919},{1,0.0894127},{2,0.0427908},{8,0.0138777}},{{6,0.843534},{2,0.155218},{1,0.00124848}},{{6,0.786522},{2,0.213478}},{{6,0.564884},{2,0.435116}},{{6,0.5123},{2,0.4877}},{{2,0.790304},{6,0.209696}},{{2,0.801125},{6,0.198875}},{{2,0.929902},{6,0.0700975}},{{2,1}},{{2,1}},{{2,1}},{{2,1}},{{2,1}},{{2,1}},{{2,1}},{{2,1}},{{2,1}},{{2,0.998009},{10,0.00199145}},{{2,0.803764},{10,0.196236}},{{2,0.529161},{10,0.470839}},{{10,0.618614},{2,0.381386}},{{10,1}},{{10,1}},{{10,1}},{{10,1}},{{10,0.891101},{11,0.108899}},{{10,0.863593},{11,0.136407}},{{11,0.971853},{12,0.0281465}},{{11,0.7501},{12,0.191771},{16,0.0290647},{20,0.0290639}},{{1,0.705613},{8,0.253069},{6,0.0413176}},{{1,0.788722},{6,0.211278}},{{6,0.885882},{1,0.114118}},{{6,0.912364},{2,0.0876364}},{{6,0.713537},{2,0.286463}},{{2,0.825566},{6,0.170257},{27,0.0041768}},{{2,0.999399},{6,0.000601489}},{{2,1}},{{2,1}},{{2,1}},{{7,1}},{{8,0.375885},{1,0.31711},{7,0.307005}},{{1,0.819389},{8,0.151936},{6,0.0286747}},{{1,0.899814},{6,0.100186}},{{1,0.563882},{6,0.436118}},{{6,0.540078},{1,0.459922}},{{1,0.88012},{6,0.11988}},{{1,0.920128},{6,0.0798722}},{{1,0.949907},{6,0.0500928}},{{1,0.934324},{6,0.0656758}},{{6,0.829736},{1,0.170264}},{{6,0.91702},{1,0.0829801}},{{6,0.838166},{1,0.161834}},{{6,0.970814},{1,0.0291861}},{{6,0.9963},{2,0.0036999}},{{6,0.906081},{2,0.0939187}},{{6,0.854803},{2,0.145197}},{{6,0.726534},{2,0.273466}},{{6,0.926666},{1,0.0733337}},{{6,0.98958},{2,0.0104199}},{{2,0.714235},{6,0.285765}},{{2,0.50699},{6,0.49301}},{{2,0.860638},{6,0.139362}},{{2,0.968683},{6,0.0313167}},{{2,0.843285},{10,0.05654},{31,0.0500879},{25,0.0500867}},{{2,0.768797},{6,0.13533},{31,0.0958738}},{{1,1}},{{7,0.507244},{1,0.492756}},{{7,0.960222},{1,0.0397779}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{7,1}},{{8,0.992724},{9,0.00727618}},{{8,1}},{{8,1}},{{8,1}},{{8,1}},{{7,1}},{{8,1}},{{8,1}},{{7,1}},{{7,1}},{{7,0.646165},{1,0.353835}},{{7,1}},{{8,0.873722},{7,0.126278}},{{8,1}},{{7,1}},{{7,1}},{{7,0.894477},{1,0.105523}},{{8,1}},{{8,0.971389},{9,0.0180444},{7,0.0105669}},{{8,0.949964},{7,0.0500364}},{{8,0.928831},{7,0.0711687}},{{8,0.939542},{7,0.060458}},{{8,0.969509},{7,0.0304913}},{{7,0.962643},{1,0.0373569}},{{7,0.698081},{1,0.301919}},{{7,0.717822},{1,0.282178}},{{7,0.661383},{1,0.338617}},{{7,0.914985},{1,0.0850151}},{{7,0.701293},{1,0.298707}},{{7,0.708162},{1,0.291838}},{{7,0.851665},{1,0.148335}},{{1,0.921708},{7,0.0782922}},{{1,1}},{{1,0.946279},{6,0.0537208}},{{1,0.597135},{7,0.402865}},{{8,0.996591},{1,0.00340867}},{{1,0.879121},{7,0.120879}},{{8,1}},{{8,1}},{{8,0.927915},{7,0.072085}},{{8,0.975822},{7,0.0241781}},{{7,0.780023},{1,0.219976}},{{7,1}},{{7,0.935148},{8,0.0648518}},{{8,0.549769},{9,0.234814},{6,0.127117},{7,0.0882999}},{{8,1}},{{7,0.702799},{1,0.297201}},{{7,0.701126},{1,0.298874}},{{7,0.713804},{1,0.286196}},{{31,0.366044},{25,0.366042},{10,0.206789},{2,0.0611259}},{{10,0.811846},{31,0.0940774},{25,0.0940766}},{{10,0.845664},{15,0.077168},{19,0.0771679}},{{10,0.295474},{15,0.263971},{19,0.263971},{11,0.176584}},{{10,0.389011},{19,0.288356},{15,0.288356},{11,0.0342782}},{{11,0.867462},{15,0.0580465},{19,0.0580464},{10,0.016445}},{{11,0.899548},{12,0.100453}},{{11,0.841415},{12,0.158585}},{{12,0.912464},{11,0.0875363}},{{12,0.833073},{11,0.166927}},{{12,0.973763},{11,0.0262367}},{{12,0.986722},{13,0.0132775}},{{12,0.710438},{13,0.289562}},{{12,0.681179},{13,0.318821}},{{12,0.5},{13,0.5}},{{13,0.501815},{12,0.498185}},{{13,0.707732},{12,0.292268}},{{13,0.844841},{12,0.1441},{14,0.0110587}},{{13,0.986498},{12,0.00711882},{14,0.00638276}},{{11,0.923959},{19,0.0727396},{12,0.00330156}},{{20,0.931221},{11,0.0573925},{12,0.0113861}},{{28,0.540123},{27,0.360038},{2,0.0998391}},{{2,0.688106},{27,0.311894}},{{10,0.89955},{31,0.0664747},{19,0.0339757}},{{10,0.723845},{19,0.178397},{15,0.0977574}},{{20,0.787269},{12,0.212731}},{{20,1}},{{27,1}},{{27,1}},{{27,1}},{{28,1}},{{27,1}},{{10,1}},{{10,0.755752},{19,0.212087},{4,0.0321614}},{{11,1}},{{11,0.755672},{12,0.244328}},{{28,0.997246},{2,0.00275433}},{{28,1}},{{20,0.713362},{19,0.155951},{10,0.130687}},{{20,0.767269},{10,0.130948},{19,0.101783}},{{10,0.81769},{19,0.165957},{31,0.0163533}},{{10,0.748689},{19,0.239294},{20,0.0120167}},{{10,0.827413},{19,0.127594},{20,0.0449937}},{{10,0.910632},{19,0.0859817},{31,0.00338632}},{{10,1}},{{10,0.515784},{19,0.291573},{20,0.192643}},{{19,0.870201},{10,0.129799}},{{8,1}},{{8,1}},{{2,0.991468},{6,0.00853181}},{{2,0.996662},{6,0.00333756}},{{2,1}},{{2,0.941595},{6,0.0584048}},{{2,1}},{{2,1}},{{31,0.899619},{2,0.0620338},{25,0.0278952},{10,0.0104524}},{{31,0.748242},{2,0.244618},{6,0.00714028}},{{31,0.989412},{25,0.0105877}},{{13,0.915809},{14,0.0841914}},{{13,0.737346},{14,0.262654}},{{13,0.656912},{14,0.343088}},{{13,0.564913},{14,0.435087}},{{13,0.613611},{14,0.386389}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{14,1}},{{13,0.739415},{14,0.260585}},{{14,0.932734},{13,0.0672663}},{{14,1}},{{12,0.779857},{13,0.156138},{11,0.0640055}},{{12,0.568},{13,0.432}},{{13,0.642514},{12,0.357486}},{{12,0.5},{13,0.5}},{{12,0.5},{13,0.5}},{{13,0.765536},{14,0.234464}},{{13,0.828481},{14,0.171519}},{{13,0.728029},{14,0.271971}},{{14,0.978753},{13,0.0212472}},{{14,1}},{{14,1}},{{14,1}},{{12,0.876117},{11,0.123883}},{{12,0.692555},{13,0.307445}},{{12,0.889573},{13,0.091021},{11,0.0194065}},{{12,0.748081},{13,0.251919}},{{12,0.746532},{11,0.253468}},{{14,1}},{{11,0.662357},{12,0.337643}},{{11,0.7418},{12,0.2582}},{{12,0.987055},{13,0.0129446}},{{12,0.767038},{13,0.232962}},{{12,0.715039},{11,0.279419},{20,0.00554174}},{{13,0.68012},{12,0.31988}},{{13,0.770279},{14,0.229721}},{{28,1}},{{28,1}},{{29,0.895952},{30,0.0645348},{28,0.0395135}},{{30,0.551989},{29,0.448011}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,1}},{{28,0.544301},{29,0.455699}},{{28,1}},{{28,1}},{{28,0.894471},{29,0.105528}},{{28,0.78607},{29,0.21393}},{{29,0.983842},{28,0.0161583}},{{29,0.995577},{30,0.00442344}},{{29,0.99827},{30,0.00172955}},{{29,0.945337},{30,0.0546626}},{{30,0.617825},{29,0.382175}},{{29,0.875417},{28,0.124583}},{{29,0.821311},{30,0.178689}},{{30,1}},{{30,1}},{{30,1}},{{30,1}},{{30,1}},{{30,0.981273},{29,0.0187267}},{{30,0.936308},{29,0.0636917}},{{30,1}},{{30,0.961383},{29,0.0386166}},{{30,0.927798},{29,0.072202}},{{30,1}},{{30,0.99629},{29,0.00371015}},{{30,0.98814},{29,0.0118595}},{{30,0.654661},{29,0.345339}},{{29,1}},{{29,0.813674},{30,0.186326}},{{29,0.97387},{28,0.02613}},{{29,0.928156},{30,0.071844}},{{29,1}},{{29,0.987728},{30,0.0122715}},{{28,0.952217},{29,0.0477832}},{{30,0.552129},{29,0.447871}},{{30,0.641174},{29,0.358826}},{{30,0.664719},{29,0.335281}},{{30,0.661583},{29,0.338417}},{{28,0.927973},{27,0.0720267}},{{30,0.512275},{29,0.487282},{28,0.00044303}},{{29,0.850953},{30,0.111792},{28,0.0372549}},{{20,1}},{{20,1}},{{20,0.946666},{10,0.0533342}},{{20,0.869273},{10,0.130727}},{{20,0.979536},{21,0.0204639}},{{20,0.943059},{10,0.0358227},{19,0.0211185}},{{20,1}},{{21,0.882014},{20,0.117986}},{{21,0.903344},{22,0.0966555}},{{20,1}},{{20,1}},{{20,0.990383},{12,0.00961715}},{{20,1}},{{20,1}},{{20,1}},{{21,0.780034},{20,0.204923},{11,0.0150428}},{{21,0.887082},{20,0.112918}},{{21,0.924191},{20,0.0689047},{22,0.00690383}},{{21,0.929349},{22,0.0518955},{20,0.0187558}},{{21,0.93351},{22,0.0658014},{20,0.000688155}},{{21,0.922959},{22,0.0770407}},{{21,0.5},{22,0.5}},{{22,0.855278},{21,0.144722}},{{22,0.928793},{21,0.0712072}},{{22,0.774673},{21,0.225327}},{{22,0.986889},{21,0.013111}},{{20,1}},{{20,1}},{{20,1}},{{20,0.83192},{21,0.16808}},{{20,0.96939},{21,0.0306104}},{{21,0.883481},{20,0.116519}},{{21,0.874552},{22,0.125448}},{{21,0.891989},{20,0.108011}},{{21,0.86897},{22,0.13103}},{{20,0.894652},{21,0.105348}},{{22,0.950035},{21,0.049965}},{{22,0.87142},{21,0.12858}},{{22,0.816451},{21,0.183549}},{{22,0.790369},{21,0.209631}},{{22,0.7667},{21,0.2333}},{{22,0.760107},{21,0.239893}},{{22,0.755305},{21,0.244695}},{{22,0.739113},{21,0.260887}},{{22,0.646747},{21,0.353253}},{{22,0.691224},{21,0.308776}},{{21,0.846328},{22,0.144826},{20,0.00884599}},{{21,0.803715},{20,0.196285}},{{21,0.935178},{22,0.0648217}},{{21,0.5},{22,0.5}},{{21,0.871287},{22,0.128713}},{{21,0.88537},{20,0.11463}},{{22,0.666201},{21,0.333799}},{{31,1}},{{31,1}},{{31,1}},{{31,1}},{{31,1}},{{31,1}},{{31,0.998095},{32,0.00190538}},{{31,0.532597},{32,0.467403}},{{32,1}},{{32,1}},{{32,1}},{{32,1}},{{32,0.64204},{31,0.35796}},{{31,0.515239},{32,0.484761}},{{31,0.825458},{32,0.174542}},{{31,1}},{{31,0.812403},{32,0.187597}},{{31,1}},{{31,0.718221},{32,0.281779}},{{32,1}},{{9,1}},{{9,1}},{{9,1}}}}
]====])
-- Source: src/client/world/dragon/Idle.luau
addModule(modules,{"world","dragon","Idle"},[====[
-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.
return {["duration"]=4.25,["tracks"]={["5"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,-4.94982,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.02485,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.20768,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{4.19094e-09,-5.43491,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.6431,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{8.38192e-09,-5.76887,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{8.38192e-09,-5.7779,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.75482,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-8.38192e-09,-5.71387,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.65815,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.59071,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{4.19094e-09,-5.51466,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{4.19094e-09,-5.43306,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.34899,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.26554,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-4.19094e-09,-5.18579,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.11281,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{2.09548e-09,-5.04969,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-1.57161e-08,-4.99951,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-2.75031e-09,-4.96534,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{-1.28143e-08,-4.95027,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-4.94982,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759}}},["2"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.969565,-0.157427,0.187514,-0.109396,0.406618,0.907025,-0.219037,-0.899932,0.377021},{-6.70554e-08,1.3411e-07,3.7976,0.969851,-0.156483,0.186823,-0.108604,0.408748,0.906162,-0.218162,-0.899132,0.37943},{-3.35276e-08,1.3411e-07,3.7976,0.970596,-0.154009,0.184997,-0.106534,0.414333,0.903869,-0.215854,-0.897,0.385743},{0,0,3.7976,0.97163,-0.150549,0.1824,-0.103648,0.422165,0.900574,-0.212584,-0.89393,0.394584},{0,1.3411e-07,3.7976,0.972785,-0.146643,0.179405,-0.100402,0.431038,0.89673,-0.20883,-0.890338,0.404584},{3.35276e-08,0,3.7976,0.973902,-0.142816,0.176407,-0.0972351,0.439761,0.892836,-0.205088,-0.886687,0.414397},{-6.70554e-08,0,3.7976,0.974835,-0.139581,0.173821,-0.0945689,0.447158,0.889441,-0.201875,-0.883497,0.422706},{-6.70554e-08,0,3.7976,0.975448,-0.137439,0.172083,-0.0928087,0.452069,0.887141,-0.199721,-0.881331,0.428214},{0,0,3.7976,0.975612,-0.136861,0.17161,-0.0923343,0.453396,0.886513,-0.199136,-0.880739,0.429702},{0,0,3.7976,0.975466,-0.137376,0.172032,-0.092757,0.452214,0.887073,-0.199657,-0.881266,0.428376},{-6.70554e-08,0,3.7976,0.975137,-0.138528,0.17297,-0.0937035,0.44957,0.888317,-0.200819,-0.882438,0.425412},{-3.35276e-08,1.3411e-07,3.7976,0.974659,-0.140195,0.174316,-0.0950742,0.445753,0.890093,-0.202488,-0.88411,0.421128},{-6.70554e-08,1.3411e-07,3.7976,0.974065,-0.142252,0.17596,-0.0967698,0.441049,0.892251,-0.204531,-0.886138,0.415844},{0,0,3.7976,0.97339,-0.144575,0.177793,-0.0986895,0.435747,0.894642,-0.206816,-0.888382,0.409884},{-3.35276e-08,1.3411e-07,3.7976,0.972668,-0.147038,0.179712,-0.10073,0.430138,0.897126,-0.209213,-0.890708,0.403571},{0,1.3411e-07,3.7976,0.971938,-0.149513,0.181612,-0.102786,0.424517,0.899567,-0.211594,-0.89299,0.397236},{-3.35276e-08,-1.3411e-07,3.7976,0.971238,-0.151867,0.183395,-0.104747,0.419179,0.901841,-0.213836,-0.895112,0.391215},{-3.35276e-08,0,3.7976,0.970608,-0.153969,0.184968,-0.106501,0.414423,0.903832,-0.215817,-0.896966,0.385844},{0,1.3411e-07,3.7976,0.970092,-0.155684,0.186236,-0.107936,0.410549,0.905428,-0.21742,-0.89845,0.381467},{3.35276e-08,-1.3411e-07,3.7976,0.969731,-0.156877,0.187111,-0.108935,0.40786,0.906523,-0.218527,-0.899467,0.378425},{-3.35276e-08,0,3.7976,0.969569,-0.157411,0.187502,-0.109383,0.406655,0.90701,-0.219022,-0.899919,0.377062},{-3.35276e-08,-1.3411e-07,3.7976,0.969565,-0.157427,0.187514,-0.109396,0.406618,0.907025,-0.219037,-0.899932,0.377021}}},["1"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-5.36443e-07,-6.70554e-08,4.80781,0.465714,-0.397752,0.790508,0.65583,0.75488,-0.0065457,-0.594135,0.521487,0.612416},{0,-3.35276e-08,4.80781,0.463615,-0.397728,0.791753,0.660249,0.750989,-0.00936118,-0.590875,0.527094,0.610769},{0,0,4.80781,0.457972,-0.397582,0.795104,0.672012,0.740348,-0.0168709,-0.581946,0.542046,0.606238},{0,1.00583e-07,4.80781,0.449774,-0.397153,0.799983,0.68881,0.724415,-0.0276318,-0.568546,0.563464,0.599386},{0,-3.35276e-08,4.80781,0.44002,-0.396309,0.805805,0.708343,0.704722,-0.0402047,-0.551935,0.588477,0.590815},{0,3.35276e-08,4.80781,0.429712,-0.395019,0.811977,0.728444,0.683036,-0.0532143,-0.533589,0.614346,0.581258},{-5.36443e-07,1.3411e-07,4.80781,0.419848,-0.393396,0.817904,0.747153,0.661427,-0.0653961,-0.515257,0.638556,0.571626},{0,0,4.80781,0.411399,-0.391699,0.822996,0.762761,0.642244,-0.0756176,-0.498945,0.658859,0.562992},{0,0,4.80781,0.405309,-0.390298,0.826676,0.773771,0.628022,-0.0828626,-0.48683,0.673243,0.556544},{5.36443e-07,6.70554e-08,4.8078,0.402499,-0.3896,0.828376,0.778781,0.62135,-0.0861692,-0.48114,0.679806,0.553506},{0,0,4.80781,0.40335,-0.389815,0.827861,0.777269,0.623378,-0.0851703,-0.482869,0.677823,0.55443},{0,1.3411e-07,4.8078,0.406863,-0.39067,0.825736,0.77098,0.631684,-0.081023,-0.489951,0.669591,0.558208},{0,-6.70554e-08,4.80781,0.412475,-0.391931,0.822347,0.760795,0.644722,-0.0743266,-0.501054,0.656295,0.564111},{0,0,4.80781,0.419645,-0.393359,0.818026,0.747532,0.660974,-0.0656439,-0.514872,0.639048,0.571423},{0,1.00583e-07,4.8078,0.42782,-0.394737,0.813113,0.732073,0.678956,-0.0555717,-0.530132,0.619032,0.579447},{5.36443e-07,0,4.80781,0.436433,-0.395907,0.807951,0.715401,0.697279,-0.0447639,-0.545644,0.597545,0.587548},{-5.36443e-07,-6.70554e-08,4.80781,0.444904,-0.396777,0.802888,0.698624,0.714683,-0.0339407,-0.560343,0.576017,0.595164},{5.36443e-07,6.70554e-08,4.80781,0.452646,-0.397332,0.798272,0.682965,0.730061,-0.0238822,-0.573298,0.556002,0.601823},{1.07288e-06,0,4.80781,0.459072,-0.39762,0.79445,0.669731,0.742444,-0.0154131,-0.583706,0.539144,0.607134},{-1.07288e-06,-3.35276e-08,4.80781,0.4636,-0.397728,0.791762,0.66028,0.750961,-0.00938086,-0.590852,0.527133,0.610758},{-5.36443e-07,6.70554e-08,4.80781,0.465652,-0.397752,0.790545,0.655962,0.754765,-0.00662977,-0.594039,0.521655,0.612368},{-5.36443e-07,-6.70554e-08,4.80781,0.465714,-0.397752,0.790508,0.65583,0.75488,-0.0065457,-0.594135,0.521487,0.612416}}},["8"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{1.10288,-0.968026,3.25436,0.812169,-0.164631,0.559713,0.485193,0.723352,-0.491274,-0.32399,0.670566,0.667362},{1.10288,-0.968025,3.25436,0.812003,-0.164496,0.559993,0.485419,0.723068,-0.491469,-0.324068,0.670906,0.666983},{1.10288,-0.968026,3.25436,0.811541,-0.164122,0.560773,0.486048,0.722276,-0.492011,-0.324283,0.671849,0.665928},{1.10288,-0.968025,3.25436,0.810835,-0.163549,0.561959,0.487007,0.721068,-0.492834,-0.324608,0.673285,0.664317},{1.10288,-0.968026,3.25436,0.809939,-0.162819,0.563461,0.488224,0.719533,-0.493872,-0.325017,0.675102,0.66227},{1.10288,-0.968025,3.25436,0.808907,-0.161974,0.565185,0.489624,0.717763,-0.495061,-0.325483,0.677186,0.65991},{1.10288,-0.968026,3.25436,0.807791,-0.161055,0.567041,0.491134,0.715849,-0.496335,-0.325978,0.679427,0.657356},{1.10288,-0.968026,3.25436,0.806645,-0.160108,0.568937,0.492681,0.713883,-0.497631,-0.326479,0.681716,0.654733},{1.10288,-0.968026,3.25436,0.805524,-0.159177,0.570783,0.494193,0.711958,-0.498888,-0.326962,0.683943,0.652164},{1.10288,-0.968026,3.25436,0.804484,-0.158308,0.57249,0.495594,0.710169,-0.500046,-0.327404,0.686002,0.649776},{1.10288,-0.968026,3.25436,0.803577,-0.157548,0.573971,0.496812,0.708611,-0.501047,-0.327783,0.687786,0.647695},{1.10288,-0.968026,3.25436,0.802861,-0.156946,0.575137,0.497773,0.707379,-0.501833,-0.328079,0.68919,0.646051},{1.10288,-0.968026,3.25436,0.802391,-0.156549,0.5759,0.498404,0.70657,-0.502347,-0.328272,0.690109,0.644971},{1.10288,-0.968025,3.25436,0.802222,-0.156407,0.576175,0.49863,0.70628,-0.502531,-0.328341,0.690439,0.644582},{1.10288,-0.968025,3.25436,0.812329,-0.164808,0.559429,0.486512,0.720469,-0.494198,-0.321604,0.67362,0.665438},{1.10288,-0.968025,3.25436,0.812414,-0.164714,0.559333,0.485825,0.721665,-0.493127,-0.322426,0.672361,0.666313},{1.10288,-0.968025,3.25436,0.812415,-0.164658,0.559348,0.485412,0.722473,-0.492349,-0.323045,0.671506,0.666875},{1.10288,-0.968025,3.25436,0.812362,-0.164631,0.559433,0.485208,0.722971,-0.49182,-0.323485,0.670977,0.667194},{1.10288,-0.968026,3.25436,0.812284,-0.164624,0.559548,0.485146,0.723232,-0.491496,-0.323772,0.670697,0.667336},{1.10288,-0.968026,3.25436,0.81221,-0.164626,0.559654,0.485163,0.723334,-0.491329,-0.323931,0.670586,0.66737},{1.10288,-0.968026,3.25436,0.81217,-0.164631,0.559711,0.485191,0.723352,-0.491275,-0.323989,0.670566,0.667362},{1.10288,-0.968026,3.25436,0.812169,-0.164631,0.559713,0.485193,0.723352,-0.491274,-0.32399,0.670566,0.667362}}},["23"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,-0.0777039,0.0682742,-0.994636,-0.10221,0.99185,0.0760679,0.991723,0.107573,-0.0700925},{-6.70554e-08,1.3411e-07,3.7976,-0.0676216,0.0784357,-0.994623,-0.10377,0.990945,0.0852007,0.9923,0.108974,-0.0588702},{-3.35276e-08,1.3411e-07,3.7976,-0.0436043,0.102703,-0.993756,-0.107865,0.988403,0.106883,0.993209,0.111851,-0.0320208},{0,0,3.7976,-0.0150337,0.131684,-0.991178,-0.113434,0.984665,0.132539,0.993432,0.114425,0.000134043},{0,1.3411e-07,3.7976,0.00877392,0.155928,-0.987729,-0.118662,0.98095,0.153804,0.992896,0.115856,0.0271093},{3.35276e-08,0,3.7976,0.0187115,0.166074,-0.985936,-0.121004,0.979236,0.162649,0.992475,0.116259,0.0384184},{-6.70554e-08,0,3.7976,0.0175268,0.164864,-0.98616,-0.12072,0.979445,0.161596,0.992532,0.116217,0.0370687},{-6.70554e-08,0,3.7976,0.0141877,0.161453,-0.986778,-0.119926,0.980028,0.158625,0.992681,0.11609,0.0332666},{0,0,3.7976,0.00901448,0.156174,-0.987688,-0.118717,0.98091,0.154018,0.992887,0.115867,0.0273827},{0,0,3.7976,0.00232691,0.149354,-0.988781,-0.117193,0.982011,0.148056,0.993106,0.115533,0.0197881},{-6.70554e-08,0,3.7976,-0.0055543,0.141327,-0.989947,-0.115451,0.983252,0.141019,0.993298,0.115073,0.0108548},{-3.35276e-08,1.3411e-07,3.7976,-0.0143057,0.132424,-0.99109,-0.113585,0.98456,0.133191,0.993425,0.114479,0.000956403},{-6.70554e-08,1.3411e-07,3.7976,-0.0236008,0.122981,-0.992128,-0.111683,0.985868,0.124861,0.993464,0.113751,-0.00953263},{0,0,3.7976,-0.0331101,0.113334,-0.993005,-0.109821,0.987121,0.116324,0.9934,0.112905,-0.0202374},{-3.35276e-08,1.3411e-07,3.7976,-0.0425011,0.10382,-0.993687,-0.108065,0.988274,0.107876,0.993235,0.111968,-0.0307836},{0,1.3411e-07,3.7976,-0.0514401,0.0947761,-0.994169,-0.10647,0.989293,0.0998202,0.992984,0.110984,-0.0407986},{-3.35276e-08,-1.3411e-07,3.7976,-0.0595922,0.086539,-0.994464,-0.10508,0.990156,0.0924609,0.992677,0.110008,-0.0499123},{-3.35276e-08,0,3.7976,-0.0666231,0.0794429,-0.99461,-0.10393,0.99085,0.0861042,0.992351,0.109106,-0.0577572},{0,1.3411e-07,3.7976,-0.0721988,0.0738207,-0.994654,-0.103051,0.991368,0.0810569,0.992052,0.108352,-0.0639685},{3.35276e-08,-1.3411e-07,3.7976,-0.0759864,0.070004,-0.994648,-0.102469,0.991703,0.0776249,0.99183,0.107819,-0.0681828},{-3.35276e-08,0,3.7976,-0.077654,0.0683244,-0.994636,-0.102218,0.991846,0.0761132,0.991726,0.10758,-0.070037},{-3.35276e-08,-1.3411e-07,3.7976,-0.0777039,0.0682742,-0.994636,-0.10221,0.99185,0.0760679,0.991723,0.107573,-0.0700925}}},["4"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-2.01166e-07,0,4.8923,0.910719,0.0547092,-0.409387,-0.413005,0.1106,-0.903988,-0.00417811,0.992358,0.123321},{-1.3411e-07,1.3411e-07,4.8923,0.911503,0.0531261,-0.407847,-0.411274,0.108137,-0.905075,-0.00397969,0.992715,0.120417},{-1.3411e-07,1.3411e-07,4.8923,0.913359,0.0493679,-0.404151,-0.40714,0.102248,-0.907625,-0.00348403,0.993533,0.113488},{1.3411e-07,0,4.8923,0.915548,0.0449133,-0.399693,-0.402199,0.0951894,-0.910591,-0.00285107,0.994445,0.105215},{0,-1.3411e-07,4.8923,0.917359,0.0412078,-0.395922,-0.398054,0.0892523,-0.91301,-0.00228614,0.995156,0.0982794},{2.68221e-07,0,4.8923,0.918113,0.0396611,-0.39433,-0.396314,0.0867564,-0.914007,-0.00203986,0.99544,0.0953705},{1.3411e-07,0,4.8923,0.918023,0.0398456,-0.39452,-0.396522,0.0870546,-0.913888,-0.00206955,0.995406,0.0957178},{2.68221e-07,-1.3411e-07,4.8923,0.91777,0.0403653,-0.395056,-0.397107,0.087894,-0.913554,-0.00215274,0.995312,0.0966958},{1.3411e-07,1.3411e-07,4.8923,0.917377,0.0411704,-0.395883,-0.398012,0.0891921,-0.913034,-0.00228025,0.995163,0.0982091},{-2.68221e-07,0,4.8923,0.91687,0.0422111,-0.396949,-0.399179,0.0908657,-0.912359,-0.00244258,0.994968,0.100162},{0,1.3411e-07,4.8923,0.91627,0.0434376,-0.398198,-0.400552,0.0928322,-0.911559,-0.0026303,0.994734,0.102458},{-1.3411e-07,-1.3411e-07,4.8923,0.915604,0.0448,-0.399579,-0.402072,0.0950087,-0.910665,-0.00283431,0.994468,0.105003},{-1.3411e-07,-1.3411e-07,4.8923,0.914893,0.0462478,-0.401037,-0.403684,0.0973128,-0.909708,-0.00304593,0.994179,0.1077},{0,0,4.8923,0.914165,0.0477301,-0.402521,-0.405328,0.0996624,-0.908722,-0.00325711,0.993876,0.110454},{-2.68221e-07,0,4.8923,0.913444,0.0491956,-0.40398,-0.406949,0.101976,-0.907741,-0.00346049,0.99357,0.11317},{-2.68221e-07,-1.3411e-07,4.8923,0.912756,0.0505923,-0.405361,-0.40849,0.104173,-0.906799,-0.00364933,0.993272,0.115751},{-1.3411e-07,0,4.8923,0.912126,0.0518679,-0.406616,-0.409893,0.106172,-0.905933,-0.0038176,0.992994,0.118102},{-1.3411e-07,0,4.8923,0.911581,0.0529696,-0.407695,-0.411102,0.107893,-0.905182,-0.00395973,0.99275,0.120129},{2.68221e-07,1.3411e-07,4.8923,0.911148,0.0538444,-0.408547,-0.41206,0.109256,-0.904583,-0.00407047,0.992554,0.121735},{0,1.3411e-07,4.8923,0.910853,0.0544393,-0.409125,-0.41271,0.110181,-0.904174,-0.00414472,0.99242,0.122826},{1.3411e-07,1.3411e-07,4.8923,0.910723,0.0547013,-0.40938,-0.412997,0.110588,-0.903993,-0.00417715,0.99236,0.123306},{-2.01166e-07,0,4.8923,0.910719,0.0547092,-0.409387,-0.413005,0.1106,-0.903988,-0.00417811,0.992358,0.123321}}},["3"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-2.34693e-07,5.36443e-07,4.20461,-0.878099,-0.0959764,-0.468755,0.0807577,-0.995349,0.0525152,-0.471616,0.0082579,0.881766},{-4.02332e-07,5.36443e-07,4.20461,-0.877627,-0.0887692,-0.471052,0.0830339,-0.996,0.0329928,-0.472097,-0.010158,0.881488},{2.68221e-07,-5.36443e-07,4.20461,-0.876566,-0.071388,-0.475958,0.0885138,-0.995982,-0.0136294,-0.473072,-0.0540759,0.879363},{0,0,4.20461,-0.875417,-0.0503487,-0.480739,0.0951292,-0.993055,-0.069224,-0.473915,-0.106332,0.874127},{-1.3411e-07,5.36443e-07,4.20461,-0.874557,-0.032544,-0.483829,0.100713,-0.988179,-0.115578,-0.474349,-0.149808,0.867497},{2.01166e-07,1.07288e-06,4.20461,-0.874225,-0.0250449,-0.484874,0.103061,-0.985483,-0.134916,-0.474457,-0.167918,0.864115},{4.69386e-07,0,4.20461,-0.874264,-0.0259408,-0.484758,0.102781,-0.985825,-0.132611,-0.474446,-0.165761,0.864537},{-2.01166e-07,0,4.20461,-0.874374,-0.0284633,-0.484417,0.101991,-0.986759,-0.126114,-0.474413,-0.159677,0.865699},{0,-5.36443e-07,4.20461,-0.874549,-0.0323629,-0.483856,0.10077,-0.988119,-0.116046,-0.474352,-0.150246,0.867419},{2.68221e-07,0,4.20461,-0.874781,-0.0373884,-0.483074,0.0991951,-0.98972,-0.103028,-0.474256,-0.138045,0.869497},{3.35276e-07,1.07288e-06,4.20461,-0.875064,-0.0432877,-0.482068,0.0973453,-0.991381,-0.0876822,-0.474117,-0.123655,0.871735},{3.35276e-07,0,4.20461,-0.87539,-0.0498079,-0.480846,0.0952991,-0.992939,-0.0706414,-0.473932,-0.107663,0.873955},{2.68221e-07,-5.36443e-07,4.20461,-0.875748,-0.0566968,-0.479427,0.0931352,-0.994266,-0.0525447,-0.473699,-0.0906674,0.876007},{2.34693e-07,0,4.20461,-0.876129,-0.063704,-0.477848,0.0909321,-0.995275,-0.0340385,-0.473422,-0.0732739,0.877783},{2.01166e-07,0,4.20461,-0.876519,-0.0705827,-0.476164,0.0887673,-0.995927,-0.015774,-0.473111,-0.056094,0.879215},{-1.3411e-07,0,4.20461,-0.876903,-0.0770907,-0.474445,0.0867173,-0.996232,0.0015966,-0.472781,-0.0397426,0.880283},{-3.35276e-08,-5.36443e-07,4.20461,-0.877263,-0.0829911,-0.472781,0.0848571,-0.996241,0.0174225,-0.47245,-0.0248347,0.881008},{-1.67638e-07,0,4.20461,-0.877582,-0.0880525,-0.471272,0.0832602,-0.996044,0.0310575,-0.472142,-0.0119827,0.881441},{-2.01166e-07,0,4.20461,-0.877839,-0.0920479,-0.470027,0.0819987,-0.995753,0.0418597,-0.471884,-0.00179546,0.881659},{0,5.36443e-07,4.20461,-0.878017,-0.0947525,-0.469156,0.0811444,-0.995488,0.0491921,-0.471701,0.00512206,0.881744},{2.34693e-07,0,4.20461,-0.878096,-0.0959408,-0.468767,0.080769,-0.995354,0.0524186,-0.471618,0.00816674,0.881765},{-2.34693e-07,5.36443e-07,4.20461,-0.878099,-0.0959764,-0.468755,0.0807577,-0.995349,0.0525152,-0.471616,0.0082579,0.881766}}},["24"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,5.36443e-07,5.62343,7.0544e-05,0.249153,0.968464,-0.981979,0.183049,-0.047021,-0.188992,-0.951008,0.244676},{1.3411e-07,0,5.62343,0.000142816,0.249056,0.968489,-0.981825,0.183842,-0.0471318,-0.189787,-0.95088,0.244555},{4.02332e-07,-5.36443e-07,5.62343,0.000314854,0.248822,0.968549,-0.981457,0.185731,-0.0473956,-0.191682,-0.950574,0.244267},{0,0,5.62343,0.000519583,0.248543,0.96862,-0.981012,0.187984,-0.0477097,-0.193943,-0.950204,0.243922},{1.3411e-07,0,5.62343,0.000690592,0.248309,0.968681,-0.980636,0.189872,-0.0479722,-0.195837,-0.94989,0.243632},{0,0,5.62343,0.000762178,0.248211,0.968706,-0.980477,0.190663,-0.0480821,-0.196631,-0.949758,0.24351},{0,0,5.62343,0.000753619,0.248222,0.968703,-0.980496,0.190569,-0.048069,-0.196536,-0.949773,0.243525},{-1.3411e-07,5.36443e-07,5.62343,0.000729557,0.248255,0.968694,-0.98055,0.190303,-0.0480321,-0.196269,-0.949818,0.243565},{2.68221e-07,0,5.62343,0.000692312,0.248307,0.968681,-0.980632,0.189891,-0.0479748,-0.195856,-0.949887,0.243629},{1.3411e-07,5.36443e-07,5.62343,0.000644224,0.248372,0.968664,-0.980739,0.18936,-0.047901,-0.195323,-0.949976,0.24371},{4.02332e-07,0,5.62343,0.000587614,0.24845,0.968644,-0.980863,0.188735,-0.0478141,-0.194696,-0.95008,0.243806},{-2.68221e-07,-5.36443e-07,5.62343,0.000524823,0.248536,0.968622,-0.981001,0.188042,-0.0477177,-0.194001,-0.950195,0.243913},{2.68221e-07,0,5.62343,0.00045817,0.248627,0.968599,-0.981147,0.187307,-0.0476154,-0.193264,-0.950316,0.244025},{2.68221e-07,0,5.62343,0.000390019,0.24872,0.968575,-0.981294,0.186557,-0.0475109,-0.192512,-0.950439,0.24414},{0,0,5.62343,0.000322755,0.248811,0.968552,-0.98144,0.185817,-0.0474077,-0.191769,-0.95056,0.244253},{1.3411e-07,5.36443e-07,5.62343,0.000258753,0.248898,0.96853,-0.981578,0.185114,-0.0473095,-0.191064,-0.950675,0.244361},{0,-5.36443e-07,5.62343,0.000200337,0.248978,0.968509,-0.981703,0.184473,-0.04722,-0.19042,-0.950778,0.244459},{-1.3411e-07,5.36443e-07,5.62343,0.000149971,0.249046,0.968492,-0.98181,0.18392,-0.0471428,-0.189866,-0.950868,0.244543},{-1.3411e-07,0,5.62343,0.000110023,0.2491,0.968478,-0.981895,0.183482,-0.0470815,-0.189426,-0.950938,0.24461},{-2.68221e-07,0,5.62343,8.28691e-05,0.249137,0.968468,-0.981952,0.183184,-0.0470399,-0.189128,-0.950986,0.244656},{0,0,5.62343,7.08941e-05,0.249153,0.968464,-0.981978,0.183053,-0.0470216,-0.188996,-0.951007,0.244675},{0,5.36443e-07,5.62343,7.0544e-05,0.249153,0.968464,-0.981979,0.183049,-0.047021,-0.188992,-0.951008,0.244676}}},["25"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.10272,0.777037,-0.621017,-0.867391,0.375575,0.32646,0.48691,0.505131,0.712574},{-6.70554e-08,1.3411e-07,3.7976,0.102178,0.7793,-0.618265,-0.867351,0.374125,0.328227,0.487096,0.502715,0.714153},{-3.35276e-08,1.3411e-07,3.7976,0.100686,0.785485,-0.610635,-0.867233,0.370094,0.333072,0.487616,0.496027,0.718462},{0,0,3.7976,0.0984498,0.79465,-0.599032,-0.867037,0.363938,0.340289,0.488421,0.485881,0.72482},{0,1.3411e-07,3.7976,0.0956759,0.805835,-0.584359,-0.86676,0.356108,0.349162,0.489462,0.473093,0.732537},{3.35276e-08,0,3.7976,0.0925705,0.818114,-0.567557,-0.866407,0.347081,0.358991,0.490683,0.458503,0.740949},{-6.70554e-08,0,3.7976,0.0893359,0.830622,-0.549624,-0.865988,0.337379,0.369107,0.49202,0.442993,0.749449},{-6.70554e-08,0,3.7976,0.0861695,0.842582,-0.53163,-0.865527,0.327577,0.378888,0.493394,0.427492,0.757504},{0,0,3.7976,0.083261,0.853312,-0.51471,-0.865057,0.318302,0.387763,0.494715,0.412968,0.764666},{0,0,3.7976,0.0807927,0.862221,-0.500047,-0.864623,0.31022,0.395209,0.495882,0.400422,0.77056},{-6.70554e-08,0,3.7976,0.0789407,0.868785,-0.488857,-0.864276,0.304026,0.400744,0.496785,0.390873,0.774869},{-3.35276e-08,1.3411e-07,3.7976,0.0778777,0.872504,-0.482361,-0.864068,0.30042,0.4039,0.497315,0.385338,0.777298},{-6.70554e-08,1.3411e-07,3.7976,0.0778425,0.872626,-0.482146,-0.864061,0.3003,0.404004,0.497333,0.385154,0.777378},{0,0,3.7976,0.0794014,0.867162,-0.491656,-0.864364,0.305578,0.399371,0.496559,0.393259,0.773806},{-3.35276e-08,1.3411e-07,3.7976,0.0823053,0.856783,-0.509066,-0.864893,0.315196,0.390655,0.495162,0.408135,0.766968},{0,1.3411e-07,3.7976,0.0861267,0.842741,-0.531384,-0.865521,0.327443,0.37902,0.493413,0.42728,0.757611},{-3.35276e-08,-1.3411e-07,3.7976,0.0904212,0.826457,-0.55569,-0.866135,0.340668,0.365727,0.491564,0.448233,0.746627},{-3.35276e-08,0,3.7976,0.0947199,0.809643,-0.579229,-0.866656,0.353358,0.3522,0.489831,0.468632,0.735152},{0,1.3411e-07,3.7976,0.0985321,0.794315,-0.599463,-0.867044,0.364167,0.340024,0.488391,0.486258,0.724588},{3.35276e-08,-1.3411e-07,3.7976,0.101354,0.782723,-0.614062,-0.867287,0.371907,0.330906,0.487381,0.499029,0.716539},{-3.35276e-08,0,3.7976,0.102679,0.777209,-0.620808,-0.867388,0.375465,0.326594,0.486924,0.504947,0.712694},{-3.35276e-08,-1.3411e-07,3.7976,0.10272,0.777037,-0.621017,-0.867391,0.375575,0.32646,0.48691,0.505131,0.712574}}},["26"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{2.68221e-07,-2.68221e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406},{0,0,8.88873,0.371989,0.459828,0.806339,0.928212,-0.177844,-0.326794,-0.00686645,0.870017,-0.492974},{-1.3411e-07,2.68221e-07,8.88873,0.346359,0.402086,0.847562,0.936743,-0.0996318,-0.335537,-0.050471,0.910165,-0.41116},{1.3411e-07,0,8.88873,0.320143,0.328696,0.88852,0.941636,-0.00737879,-0.336551,-0.104067,0.944407,-0.311874},{1.3411e-07,-2.68221e-07,8.88873,0.302592,0.267212,0.914897,0.941606,0.0649427,-0.330394,-0.147701,0.961447,-0.231957},{1.3411e-07,0,8.88873,0.297843,0.248062,0.921821,0.940926,0.08666,-0.327336,-0.161085,0.96486,-0.207597},{2.68221e-07,-5.36443e-07,8.88873,0.298901,0.252443,0.920288,0.941108,0.0817235,-0.328081,-0.158031,0.964155,-0.213149},{0,0,8.88873,0.30136,0.262368,0.916703,0.941463,0.0704705,-0.329669,-0.151095,0.962391,-0.225773},{2.68221e-07,2.68221e-07,8.88873,0.305119,0.276899,0.911169,0.941834,0.0538161,-0.331742,-0.140895,0.959391,-0.244372},{-2.68221e-07,0,8.88873,0.310093,0.295069,0.903757,0.942042,0.0326826,-0.3339,-0.12806,0.954917,-0.267833},{0,2.68221e-07,8.88873,0.316184,0.315897,0.894559,0.941916,0.00801903,-0.335754,-0.113237,0.94876,-0.295013},{1.3411e-07,-2.68221e-07,8.88873,0.323259,0.338404,0.883734,0.941318,-0.0191872,-0.336975,-0.0970776,0.940805,-0.324748},{0,-8.04661e-07,8.88873,0.331133,0.361637,0.871533,0.940167,-0.0479126,-0.337329,-0.0802334,0.931087,-0.355864},{1.3411e-07,-2.68221e-07,8.88873,0.339563,0.384692,0.858318,0.938448,-0.0771108,-0.336703,-0.0633412,0.919819,-0.387197},{1.3411e-07,0,8.88873,0.348244,0.406739,0.844565,0.936225,-0.105732,-0.335119,-0.0470089,0.907405,-0.417619},{1.3411e-07,-2.68221e-07,8.88873,0.356822,0.427042,0.830851,0.933631,-0.132743,-0.332735,-0.031802,0.894435,-0.446065},{-1.3411e-07,-2.68221e-07,8.88873,0.364897,0.444959,0.81784,0.93087,-0.157149,-0.329827,-0.0182368,0.881655,-0.471542},{0,-2.68221e-07,8.88873,0.372044,0.45994,0.80625,0.928191,-0.178001,-0.326769,-0.00678089,0.869926,-0.493136},{0,5.36443e-07,8.88873,0.377825,0.471502,0.796827,0.925875,-0.194393,-0.323987,0.00213686,0.860173,-0.509998},{0,2.68221e-07,8.88873,0.381807,0.479192,0.790315,0.924207,-0.205449,-0.32192,0.00810736,0.853326,-0.521314},{-1.3411e-07,-5.36443e-07,8.88873,0.383572,0.482534,0.787422,0.923449,-0.210293,-0.320966,0.0107122,0.850257,-0.526258},{2.68221e-07,-2.68221e-07,8.88873,0.383625,0.482634,0.787335,0.923426,-0.210438,-0.320937,0.0107899,0.850165,-0.526406}}},["27"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,-0.0321099,0.320768,0.946613,0.124315,0.941029,-0.314659,-0.991723,0.107574,-0.0700925},{-6.70554e-08,1.3411e-07,3.7976,-0.0220501,0.310891,0.95019,0.121814,0.944175,-0.306096,-0.992308,0.108997,-0.0586899},{-3.35276e-08,1.3411e-07,3.7976,0.00206444,0.287151,0.957883,0.116216,0.951326,-0.285436,-0.993222,0.111911,-0.0314076},{0,0,3.7976,0.0310275,0.25852,0.965507,0.110223,0.959196,-0.260373,-0.993422,0.1145,0.00126649},{0,1.3411e-07,3.7976,0.0553932,0.234336,0.970576,0.10579,0.96522,-0.23908,-0.992845,0.11592,0.0286763},{3.35276e-08,0,3.7976,0.0656263,0.224152,0.972342,0.104092,0.967588,-0.230082,-0.9924,0.116312,0.0401669},{-6.70554e-08,0,3.7976,0.0644044,0.225369,0.972143,0.104289,0.967311,-0.231158,-0.992459,0.116272,0.0387955},{-6.70554e-08,0,3.7976,0.0609633,0.228794,0.971564,0.104853,0.966521,-0.234186,-0.992617,0.116149,0.0349325},{0,0,3.7976,0.0556404,0.23409,0.970622,0.105747,0.965278,-0.238863,-0.992835,0.115931,0.0289541},{0,0,3.7976,0.0487742,0.240914,0.96932,0.10694,0.963637,-0.244883,-0.993069,0.115603,0.0212374},{-6.70554e-08,0,3.7976,0.0407038,0.248926,0.967667,0.108396,0.961653,-0.251939,-0.993274,0.115147,0.0121602},{-3.35276e-08,1.3411e-07,3.7976,0.0317694,0.257785,0.96568,0.11008,0.959387,-0.259727,-0.993415,0.114554,0.00210212},{-6.70554e-08,1.3411e-07,3.7976,0.0223109,0.26715,0.963397,0.111944,0.956909,-0.267944,-0.993464,0.113824,-0.00855627},{0,0,3.7976,0.0126678,0.276684,0.960877,0.11393,0.954297,-0.276292,-0.993408,0.112973,-0.0194339},{-3.35276e-08,1.3411e-07,3.7976,0.00317714,0.286054,0.958208,0.115971,0.951642,-0.284478,-0.993247,0.112029,-0.0301505},{0,1.3411e-07,3.7976,-0.00582638,0.294929,0.955501,0.117986,0.949046,-0.292217,-0.992998,0.111034,-0.0403272},{-3.35276e-08,-1.3411e-07,3.7976,-0.0140118,0.302988,0.952892,0.119886,0.94662,-0.299231,-0.992689,0.110046,-0.0495878},{-3.35276e-08,0,3.7976,-0.0210517,0.30991,0.950533,0.121571,0.944482,-0.305245,-0.992359,0.109131,-0.057559},{0,1.3411e-07,3.7976,-0.0266217,0.315381,0.948592,0.122938,0.942757,-0.309992,-0.992057,0.108366,-0.0638702},{3.35276e-08,-1.3411e-07,3.7976,-0.0303989,0.319089,0.947237,0.123882,0.941571,-0.313205,-0.991831,0.107825,-0.0681522},{-3.35276e-08,0,3.7976,-0.0320602,0.320719,0.946632,0.124302,0.941045,-0.314616,-0.991726,0.107582,-0.0700361},{-3.35276e-08,-1.3411e-07,3.7976,-0.0321099,0.320768,0.946613,0.124315,0.941029,-0.314659,-0.991723,0.107574,-0.0700925}}},["28"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{6.70554e-08,1.3411e-07,4.8923,0.781743,-0.0502348,0.621574,0.622859,0.111511,-0.774346,-0.0304132,0.992493,0.118462},{4.02332e-07,0,4.8923,0.780868,-0.0485975,0.622803,0.623989,0.10809,-0.773921,-0.0297083,0.992953,0.114728},{-1.3411e-07,1.3411e-07,4.8923,0.778781,-0.0446714,0.625704,0.626671,0.0999351,-0.77285,-0.0280055,0.993991,0.105822},{0,2.68221e-07,4.8923,0.776288,-0.0399461,0.629112,0.629845,0.0902067,-0.771465,-0.0259331,0.995122,0.0951862},{-2.68221e-07,1.3411e-07,4.8923,0.774198,-0.0359546,0.631921,0.632482,0.0820614,-0.770216,-0.0241635,0.995978,0.0862725},{0,0,4.8923,0.773322,-0.0342721,0.633086,0.633581,0.0786474,-0.769668,-0.0234125,0.996313,0.082534},{-1.3411e-07,1.3411e-07,4.8923,0.773427,-0.0344732,0.632948,0.63345,0.0790549,-0.769735,-0.0235024,0.996274,0.0829803},{0,2.68221e-07,4.8923,0.773721,-0.0350393,0.632556,0.633081,0.0802027,-0.76992,-0.0237553,0.996162,0.0842373},{1.3411e-07,0,4.8923,0.774177,-0.035914,0.631949,0.632508,0.0819789,-0.770203,-0.0241454,0.995987,0.0861821},{0,1.3411e-07,4.8923,0.774766,-0.0370408,0.631163,0.631768,0.0842715,-0.770563,-0.0246468,0.995754,0.0886919},{2.68221e-07,1.3411e-07,4.8923,0.775457,-0.0383631,0.630233,0.630895,0.0869686,-0.770978,-0.0252334,0.995472,0.0916436},{0,0,4.8923,0.776224,-0.0398248,0.629198,0.629926,0.0899582,-0.771428,-0.0258796,0.995149,0.0949144},{1.3411e-07,1.3411e-07,4.8923,0.777037,-0.0413699,0.628094,0.628894,0.0931282,-0.771893,-0.0265602,0.994794,0.0983814},{-1.3411e-07,0,4.8923,0.777867,-0.0429433,0.626961,0.627838,0.0963663,-0.772355,-0.0272504,0.994419,0.101922},{-1.3411e-07,1.3411e-07,4.8923,0.778685,-0.0444901,0.625836,0.626794,0.0995602,-0.772799,-0.0279264,0.994036,0.105412},{4.02332e-07,0,4.8923,0.779462,-0.0459566,0.624761,0.625798,0.102597,-0.773208,-0.0285648,0.993661,0.10873},{2.68221e-07,0,4.8923,0.780171,-0.0472891,0.623777,0.624887,0.105365,-0.773572,-0.0291428,0.993309,0.111753},{1.3411e-07,0,4.8923,0.780781,-0.048435,0.622924,0.624101,0.107751,-0.773878,-0.0296381,0.992997,0.114359},{2.68221e-07,1.3411e-07,4.8923,0.781265,-0.0493415,0.622246,0.623476,0.109643,-0.774116,-0.030029,0.992745,0.116424},{0,0,4.8923,0.781594,-0.0499563,0.621784,0.623051,0.110928,-0.774275,-0.0302935,0.992572,0.117826},{1.3411e-07,-1.3411e-07,4.8923,0.781739,-0.0502267,0.62158,0.622864,0.111494,-0.774344,-0.0304097,0.992495,0.118443},{6.70554e-08,1.3411e-07,4.8923,0.781743,-0.0502348,0.621574,0.622859,0.111511,-0.774346,-0.0304132,0.992493,0.118462}}},["29"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,-5.36443e-07,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866},{0,5.36443e-07,4.20461,-0.924318,0.0745405,0.374273,-0.0973236,-0.994353,-0.0423178,0.369005,-0.0755408,0.926352},{1.3411e-07,-5.36443e-07,4.20461,-0.925189,0.0698465,0.373022,-0.111026,-0.989729,-0.0900502,0.362901,-0.124729,0.923442},{1.3411e-07,5.36443e-07,4.20461,-0.926308,0.0643427,0.371232,-0.126964,-0.980988,-0.146777,0.35473,-0.183094,0.916866},{1.3411e-07,0,4.20461,-0.927306,0.0598342,0.36949,-0.139911,-0.970994,-0.193894,0.347171,-0.231495,0.90878},{0,5.36443e-07,4.20461,-0.927741,0.0579757,0.368695,-0.145218,-0.966091,-0.213496,0.343815,-0.25161,0.904701},{1.3411e-07,-5.36443e-07,4.20461,-0.927688,0.0581965,0.368792,-0.144589,-0.966698,-0.211162,0.344222,-0.249216,0.905209},{0,0,4.20461,-0.927542,0.0588199,0.369062,-0.14281,-0.968377,-0.204578,0.345358,-0.242461,0.906609},{-1.3411e-07,0,4.20461,-0.927317,0.059789,0.369471,-0.140041,-0.970881,-0.194369,0.347091,-0.231983,0.908687},{1.3411e-07,0,4.20461,-0.92703,0.0610475,0.369984,-0.136437,-0.973945,-0.181155,0.349285,-0.218416,0.911205},{2.68221e-07,0,4.20461,-0.926698,0.0625385,0.370566,-0.132158,-0.977305,-0.16556,0.351802,-0.202398,0.913931},{0,1.07288e-06,4.20461,-0.926338,0.0642037,0.371182,-0.127365,-0.980719,-0.148221,0.354509,-0.184578,0.916654},{0,5.36443e-07,4.20461,-0.925963,0.0659831,0.371803,-0.122229,-0.98398,-0.129782,0.357284,-0.165618,0.919195},{4.02332e-07,0,4.20461,-0.92559,0.067814,0.372403,-0.116928,-0.986929,-0.110901,0.360015,-0.146193,0.921421},{0,0,4.20461,-0.925231,0.0696323,0.372959,-0.111649,-0.989457,-0.0922424,0.362604,-0.126986,0.923251},{0,0,4.20461,-0.924898,0.0713717,0.373456,-0.106584,-0.99151,-0.0744766,0.36497,-0.108688,0.924653},{0,-5.36443e-07,4.20461,-0.924602,0.0729651,0.373881,-0.101933,-0.993083,-0.0582737,0.367043,-0.091991,0.925644},{1.3411e-07,0,4.20461,-0.924353,0.0743442,0.374226,-0.0978984,-0.99421,-0.0443019,0.368766,-0.0775867,0.926279},{-1.3411e-07,5.36443e-07,4.20461,-0.924159,0.0754411,0.374486,-0.0946835,-0.994953,-0.0332249,0.370089,-0.0661626,0.926637},{2.68221e-07,0,4.20461,-0.924029,0.0761878,0.374655,-0.0924921,-0.995382,-0.0257022,0.370966,-0.0584022,0.926808},{-1.3411e-07,0,4.20461,-0.923972,0.0765169,0.374727,-0.0915255,-0.995551,-0.022391,0.371347,-0.0549857,0.926865},{0,-5.36443e-07,4.20461,-0.92397,0.0765268,0.374729,-0.0914965,-0.995556,-0.0222919,0.371358,-0.0548835,0.926866}}},["30"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-2.68221e-07,2.68221e-07,5.62343,0.109675,-0.351937,-0.929576,0.974209,0.223606,0.030284,0.197201,-0.908923,0.367384},{-2.68221e-07,-5.36443e-07,5.62343,0.110457,-0.35146,-0.929664,0.973535,0.226557,0.0300194,0.200071,-0.908377,0.367184},{-2.68221e-07,5.36443e-07,5.62343,0.112315,-0.350314,-0.929874,0.971892,0.233585,0.0293912,0.206909,-0.907038,0.366702},{-2.68221e-07,5.36443e-07,5.62343,0.114522,-0.348928,-0.930126,0.969864,0.241959,0.0286464,0.215057,-0.905376,0.366122},{2.68221e-07,0,5.62343,0.116362,-0.347751,-0.930338,0.968108,0.248961,0.0280266,0.221872,-0.903929,0.365631},{0,5.36443e-07,5.62343,0.117131,-0.347254,-0.930427,0.967356,0.251894,0.0277678,0.224726,-0.903307,0.365423},{2.68221e-07,2.68221e-07,5.62343,0.117039,-0.347314,-0.930417,0.967447,0.251544,0.0277987,0.224385,-0.903382,0.365448},{0,0,5.62343,0.11678,-0.347481,-0.930387,0.9677,0.250558,0.0278856,0.223426,-0.903592,0.365518},{2.68221e-07,-2.68221e-07,5.62343,0.11638,-0.347739,-0.93034,0.96809,0.249032,0.0280203,0.221941,-0.903914,0.365626},{0,8.04661e-07,5.62343,0.115863,-0.348072,-0.93028,0.968589,0.247062,0.0281944,0.220023,-0.904327,0.365764},{0,5.36443e-07,5.62343,0.115254,-0.348462,-0.93021,0.969172,0.244743,0.0283996,0.217767,-0.904807,0.365927},{0,5.36443e-07,5.62343,0.114578,-0.348892,-0.930133,0.969811,0.242173,0.0286275,0.215265,-0.905332,0.366107},{-5.36443e-07,5.36443e-07,5.62343,0.113861,-0.349346,-0.93005,0.970481,0.239445,0.0288696,0.212611,-0.905883,0.366297},{-2.68221e-07,-5.36443e-07,5.62343,0.113126,-0.349807,-0.929966,0.971156,0.236658,0.0291174,0.209899,-0.906437,0.36649},{-2.68221e-07,-5.36443e-07,5.62343,0.1124,-0.350261,-0.929884,0.971815,0.233908,0.0293624,0.207223,-0.906975,0.36668},{-5.36443e-07,-5.36443e-07,5.62343,0.111709,-0.350689,-0.929805,0.972434,0.231292,0.0295959,0.204677,-0.907481,0.36686},{-2.68221e-07,0,5.62343,0.111079,-0.351079,-0.929734,0.972992,0.228906,0.0298091,0.202356,-0.907935,0.367023},{-5.36443e-07,2.68221e-07,5.62343,0.110534,-0.351413,-0.929673,0.973468,0.226849,0.0299932,0.200355,-0.908322,0.367164},{-5.36443e-07,-2.68221e-07,5.62343,0.110102,-0.351677,-0.929624,0.973842,0.225217,0.0301394,0.198768,-0.908626,0.367275},{-2.68221e-07,-5.36443e-07,5.62343,0.109808,-0.351856,-0.929591,0.974095,0.224108,0.0302388,0.197689,-0.90883,0.36735},{0,-8.04661e-07,5.62343,0.109679,-0.351935,-0.929577,0.974206,0.22362,0.0302826,0.197215,-0.90892,0.367383},{-2.68221e-07,2.68221e-07,5.62343,0.109675,-0.351937,-0.929576,0.974209,0.223606,0.030284,0.197201,-0.908923,0.367384}}},["31"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.35276e-08,-1.3411e-07,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535},{-6.70554e-08,1.3411e-07,3.7976,0.421662,-0.480012,0.769278,0.6915,0.719014,0.069618,-0.586539,0.502601,0.635109},{-3.35276e-08,1.3411e-07,3.7976,0.417757,-0.489392,0.765489,0.70053,0.710019,0.0716224,-0.578564,0.506328,0.63945},{0,0,3.7976,0.41164,-0.503383,0.759709,0.713925,0.696248,0.0745009,-0.566448,0.511707,0.645981},{0,1.3411e-07,3.7976,0.403608,-0.520616,0.752369,0.730296,0.678679,0.0778572,-0.551151,0.518029,0.654124},{3.35276e-08,0,3.7976,0.394024,-0.539735,0.743929,0.74829,0.658369,0.081325,-0.533674,0.52463,0.663291},{-6.70554e-08,0,3.7976,0.383368,-0.559436,0.734888,0.766632,0.636489,0.0846017,-0.515077,0.530955,0.672891},{-6.70554e-08,0,3.7976,0.372258,-0.578495,0.725788,0.784173,0.614347,0.0874669,-0.496485,0.536583,0.682335},{0,0,3.7976,0.361451,-0.595786,0.717211,0.799902,0.593375,0.0897902,-0.479071,0.541244,0.691047},{0,0,3.7976,0.351822,-0.610287,0.709768,0.81295,0.575097,0.0915231,-0.464041,0.544806,0.698465},{-6.70554e-08,0,3.7976,0.344317,-0.621057,0.704084,0.82255,0.56109,0.0926755,-0.452611,0.547235,0.704043},{-3.35276e-08,1.3411e-07,3.7976,0.339899,-0.627194,0.700783,0.827985,0.552938,0.0932786,-0.445993,0.548532,0.70725},{-6.70554e-08,1.3411e-07,3.7976,0.339751,-0.627396,0.700673,0.828164,0.552667,0.0932978,-0.445773,0.548574,0.707356},{0,0,3.7976,0.346206,-0.618387,0.705506,0.820178,0.564598,0.0924009,-0.455467,0.54665,0.702654},{-3.35276e-08,1.3411e-07,3.7976,0.357774,-0.60142,0.714347,0.804988,0.58635,0.0904875,-0.473278,0.542667,0.693916},{0,1.3411e-07,3.7976,0.372103,-0.578751,0.725663,0.784407,0.614043,0.0875033,-0.496231,0.536655,0.682463},{-3.35276e-08,-1.3411e-07,3.7976,0.387021,-0.552851,0.73795,0.760525,0.643913,0.0835411,-0.521361,0.528897,0.669664},{-3.35276e-08,0,3.7976,0.400725,-0.526522,0.749796,0.735874,0.672499,0.0789577,-0.54581,0.520115,0.656941},{0,1.3411e-07,3.7976,0.411871,-0.502869,0.759924,0.713435,0.696761,0.0743976,-0.566898,0.511514,0.64574},{3.35276e-08,-1.3411e-07,3.7976,0.419523,-0.485197,0.767193,0.696496,0.714066,0.0707332,-0.582145,0.504672,0.637505},{-3.35276e-08,0,3.7976,0.422942,-0.476854,0.770539,0.688451,0.722,0.0689299,-0.589198,0.501325,0.633655},{-3.35276e-08,-1.3411e-07,3.7976,0.423047,-0.476594,0.770642,0.6882,0.722245,0.0688729,-0.589417,0.501219,0.633535}}},["32"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-1.3411e-07,2.68221e-07,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.00929472,0.845387,-0.534073},{-1.3411e-07,5.36443e-07,8.88873,0.380223,-0.46726,-0.798184,-0.924809,-0.20378,-0.321249,-0.0125468,0.860315,-0.509608},{-2.68221e-07,-2.68221e-07,8.88873,0.362714,-0.413304,-0.835235,-0.9317,-0.179415,-0.315825,-0.019322,0.892743,-0.450151},{-2.68221e-07,-2.68221e-07,8.88873,0.341652,-0.347376,-0.873272,-0.939478,-0.151532,-0.307277,-0.0255883,0.925401,-0.378124},{-1.3411e-07,0,8.88873,0.324671,-0.293471,-0.899146,-0.945375,-0.130098,-0.2989,-0.0292585,0.947074,-0.31968},{0,2.68221e-07,8.88873,0.319467,-0.276826,-0.90626,-0.947118,-0.123708,-0.296082,-0.0301484,0.952924,-0.301708},{1.3411e-07,0,8.88873,0.320654,-0.28063,-0.90467,-0.946722,-0.125159,-0.296735,-0.0299547,0.951621,-0.305812},{0,5.36443e-07,8.88873,0.323351,-0.289256,-0.900985,-0.945819,-0.12847,-0.298197,-0.0294943,0.948592,-0.315125},{0,-2.68221e-07,8.88873,0.327316,-0.301912,-0.895384,-0.944477,-0.133379,-0.300289,-0.0287644,0.943959,-0.328806},{0,-2.68221e-07,8.88873,0.332307,-0.317791,-0.888021,-0.942763,-0.139625,-0.302825,-0.0277551,0.937824,-0.346},{-6.70554e-08,-2.68221e-07,8.88873,0.338077,-0.336081,-0.879064,-0.940746,-0.146944,-0.30562,-0.0264604,0.930299,-0.365846},{-1.3411e-07,0,8.88873,0.344381,-0.355978,-0.868724,-0.9385,-0.155062,-0.308502,-0.0248861,0.92154,-0.387485},{1.3411e-07,0,8.88873,0.350975,-0.376691,-0.857275,-0.936101,-0.163691,-0.311321,-0.0230568,0.911762,-0.410073},{-6.70554e-08,5.36443e-07,8.88873,0.357622,-0.397462,-0.845062,-0.93363,-0.172536,-0.313953,-0.0210189,0.901252,-0.432785},{1.3411e-07,2.68221e-07,8.88873,0.364089,-0.417569,-0.832511,-0.931173,-0.181287,-0.316308,-0.0188434,0.890377,-0.454834},{1.3411e-07,5.36443e-07,8.88873,0.370156,-0.436335,-0.82012,-0.928821,-0.189632,-0.318326,-0.0166247,0.879575,-0.47547},{1.3411e-07,-5.36443e-07,8.88873,0.375612,-0.453129,-0.808448,-0.926664,-0.197252,-0.319978,-0.0144771,0.869348,-0.493989},{0,8.04661e-07,8.88873,0.380258,-0.467366,-0.798105,-0.924795,-0.203829,-0.321259,-0.0125318,0.860245,-0.509726},{0,5.36443e-07,8.88873,0.383902,-0.478491,-0.789725,-0.923309,-0.209046,-0.32218,-0.0109286,0.852846,-0.522049},{-2.68221e-07,-2.68221e-07,8.88873,0.386357,-0.485963,-0.783944,-0.922297,-0.21259,-0.322759,-0.00980976,0.84773,-0.530338},{-2.68221e-07,0,8.88873,0.387431,-0.489229,-0.781378,-0.921851,-0.214149,-0.323001,-0.00930965,0.845456,-0.533964},{-1.3411e-07,2.68221e-07,8.88873,0.387464,-0.489326,-0.781301,-0.921838,-0.214196,-0.323009,-0.00929472,0.845387,-0.534073}}},["11"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357},{5.23868e-09,8.38192e-08,5.59555,0.790202,-0.61214,-0.0294224,0.503796,0.67618,-0.53756,0.348957,0.409958,0.842712},{5.23868e-09,8.38192e-08,5.59555,0.790675,-0.61159,-0.0281198,0.504475,0.676843,-0.536086,0.346898,0.409684,0.843695},{9.42962e-09,8.38192e-08,5.59555,0.791386,-0.610758,-0.0261419,0.505499,0.677847,-0.533848,0.343772,0.409265,0.845176},{-3.14321e-09,-5.02913e-08,5.59555,0.792271,-0.609711,-0.0236464,0.506777,0.679111,-0.531023,0.339829,0.408731,0.847027},{-3.14321e-09,-5.02913e-08,5.59555,0.793268,-0.608518,-0.0207915,0.50822,0.680552,-0.52779,0.335319,0.408112,0.84912},{-3.14321e-09,-5.02913e-08,5.59555,0.794315,-0.607247,-0.0177367,0.509741,0.682088,-0.524329,0.330495,0.407441,0.851331},{5.23868e-09,2.1793e-07,5.59555,0.795357,-0.605964,-0.0146427,0.511259,0.683637,-0.520821,0.325609,0.406752,0.85354},{-3.14321e-09,-5.02913e-08,5.59555,0.796338,-0.604738,-0.0116714,0.512695,0.685119,-0.517451,0.320919,0.406082,0.855633},{-3.14321e-09,2.1793e-07,5.59555,0.79721,-0.603635,-0.00898659,0.513974,0.686454,-0.514404,0.316681,0.405469,0.857501},{5.23868e-09,-5.02913e-08,5.59555,0.797924,-0.60272,-0.00675264,0.515025,0.687561,-0.511868,0.313156,0.404954,0.859037},{1.04774e-09,-5.02913e-08,5.59555,0.798435,-0.60206,-0.00513472,0.515779,0.688361,-0.510031,0.310604,0.404578,0.860141},{9.42962e-09,8.38192e-08,5.59555,0.798697,-0.601719,-0.00429792,0.516166,0.688774,-0.50908,0.309283,0.404382,0.860708},{-3.14321e-09,2.1793e-07,5.59555,0.798585,-0.601864,-0.00465505,0.516001,0.688598,-0.509486,0.309847,0.404466,0.860466},{5.23868e-09,8.38192e-08,5.59555,0.797833,-0.602838,-0.00703942,0.514891,0.687419,-0.512194,0.313609,0.40502,0.858841},{1.04774e-09,-5.02913e-08,5.59555,0.796584,-0.604429,-0.0109207,0.513054,0.685493,-0.516599,0.319734,0.405911,0.856158},{5.23868e-09,-5.02913e-08,5.59555,0.795025,-0.606376,-0.0156367,0.510774,0.68314,-0.521948,0.327179,0.406975,0.852834},{7.33417e-09,8.38192e-08,5.59555,0.793358,-0.608409,-0.0205309,0.50835,0.680683,-0.527495,0.334908,0.408055,0.84931},{6.28643e-09,-5.02913e-08,5.59555,0.791808,-0.61026,-0.0249554,0.506109,0.678449,-0.532505,0.341897,0.409012,0.846059},{-1.41445e-08,-5.02913e-08,5.59555,0.79062,-0.611654,-0.0282707,0.504397,0.676766,-0.536257,0.347136,0.409716,0.843581},{1.04774e-09,8.38192e-08,5.59555,0.790049,-0.612317,-0.0298426,0.503576,0.675966,-0.538035,0.349621,0.410046,0.842394},{-3.14321e-09,8.38192e-08,5.59555,0.790031,-0.612338,-0.0298919,0.50355,0.675941,-0.538091,0.349699,0.410056,0.842357}}},["12"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,-2.68221e-07,6.52923,0.991153,0.0405153,-0.126392,-0.0436665,0.998798,-0.0222602,0.125338,0.0275823,0.991731},{-2.68221e-07,0,6.52923,0.991286,0.0416603,-0.12497,-0.0449171,0.998718,-0.0233551,0.123837,0.0287649,0.991886},{2.68221e-07,5.36443e-07,6.52923,0.991633,0.0448195,-0.121063,-0.0483493,0.998482,-0.0263774,0.119697,0.0320101,0.992294},{2.68221e-07,2.68221e-07,6.52923,0.992103,0.0495854,-0.115211,-0.0534777,0.99809,-0.0309399,0.113457,0.0368568,0.992859},{5.36443e-07,0,6.52923,0.992602,0.0555513,-0.107958,-0.0598143,0.997536,-0.0366558,0.105655,0.042842,0.993479},{2.68221e-07,0,6.52923,0.993051,0.0623032,-0.0998423,-0.0668768,0.996829,-0.0431308,0.0968384,0.0495082,0.994068},{0,-2.68221e-07,6.52923,0.993392,0.0694155,-0.0913989,-0.0741937,0.995992,-0.0499584,0.0875647,0.0564094,0.99456},{0,0,6.52923,0.9936,0.0764487,-0.0831531,-0.0813088,0.995074,-0.0567169,0.0784076,0.063115,0.994922},{-2.68221e-07,0,6.52923,0.99368,0.0829508,-0.0756198,-0.0877819,0.994147,-0.062971,0.0699537,0.0692112,0.995146},{-2.68221e-07,0,6.52923,0.993666,0.0884595,-0.0693038,-0.0931892,0.993305,-0.0682739,0.0628003,0.0742998,0.995257},{0,-2.68221e-07,6.52923,0.993608,0.0925061,-0.064702,-0.097117,0.992653,-0.072172,0.0575502,0.0779943,0.995291},{2.68221e-07,-2.68221e-07,6.52923,0.993561,0.0946216,-0.062309,-0.0991556,0.992301,-0.0742107,0.0548073,0.0799112,0.995294},{0,2.68221e-07,6.52923,0.993574,0.09408,-0.0629209,-0.0986345,0.992392,-0.0736887,0.0555095,0.0794213,0.995294},{-2.68221e-07,5.36443e-07,6.52923,0.993649,0.0899677,-0.067585,-0.0946573,0.993065,-0.0697265,0.0608431,0.075681,0.995274},{0,-2.68221e-07,6.52923,0.993681,0.0831438,-0.0753975,-0.0879726,0.994119,-0.0631567,0.0697029,0.0693906,0.995152},{2.68221e-07,2.68221e-07,6.52923,0.993559,0.0746273,-0.0852788,-0.0794775,0.99532,-0.054966,0.0807777,0.0613897,0.99484},{0,-2.68221e-07,6.52923,0.993217,0.0654204,-0.0961286,-0.0700989,0.996473,-0.0461223,0.0927723,0.052548,0.9943},{0,-5.36443e-07,6.52923,0.992672,0.0564946,-0.106818,-0.0608078,0.997443,-0.03756,0.104423,0.04378,0.993569},{0,-8.04661e-07,6.52923,0.992028,0.048784,-0.116192,-0.0526195,0.998159,-0.0301726,0.114506,0.0360459,0.992768},{0,-2.68221e-07,6.52923,0.991457,0.0431896,-0.123076,-0.0465818,0.998606,-0.0248181,0.121832,0.0303391,0.992087},{2.68221e-07,-5.36443e-07,6.52923,0.991162,0.0405957,-0.126292,-0.0437544,0.998793,-0.022337,0.125233,0.0276653,0.991742},{0,-2.68221e-07,6.52923,0.991153,0.0405153,-0.126392,-0.0436665,0.998798,-0.0222602,0.125338,0.0275823,0.991731}}},["13"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-5.36443e-07,-5.36443e-07,6.20212,0.649888,0.661611,0.374055,-0.759687,0.550692,0.345853,0.0228313,-0.50893,0.860505},{-5.36443e-07,0,6.20212,0.650863,0.66532,0.365685,-0.758815,0.554858,0.341075,0.0240208,-0.499481,0.865992},{-5.36443e-07,0,6.20212,0.653676,0.674123,0.3439,-0.75626,0.565134,0.329689,0.0279014,-0.475587,0.879226},{0,0,6.20212,0.658079,0.684483,0.313712,-0.752136,0.578237,0.316121,0.0349797,-0.443987,0.895351},{-5.36443e-07,-5.36443e-07,6.20212,0.663781,0.693366,0.280425,-0.746528,0.591287,0.305082,0.045721,-0.411853,0.910103},{-1.07288e-06,5.36443e-07,6.20212,0.670544,0.6986,0.249659,-0.739402,0.601909,0.301644,0.0604568,-0.386864,0.920153},{5.36443e-07,0,6.20212,0.678307,0.698789,0.227141,-0.730484,0.607944,0.311122,0.0793202,-0.376959,0.922827},{-5.36443e-07,-1.07288e-06,6.20212,0.687084,0.694151,0.214642,-0.719429,0.608621,0.334666,0.101673,-0.384363,0.917566},{0,0,6.20212,0.696148,0.686777,0.209083,-0.706972,0.605214,0.365933,0.124774,-0.402559,0.906851},{5.36443e-07,0,6.20212,0.70455,0.678197,0.208946,-0.694564,0.598603,0.399068,0.145571,-0.426289,0.892797},{5.36443e-07,5.36443e-07,6.20212,0.711277,0.669881,0.212941,-0.684151,0.590238,0.428434,0.161314,-0.450419,0.878123},{-5.36443e-07,0,6.20212,0.715213,0.663373,0.220014,-0.678026,0.582197,0.448695,0.169561,-0.470088,0.86618},{-2.68221e-07,5.36443e-07,6.20212,0.715247,0.659837,0.230299,-0.678354,0.576206,0.455876,0.168104,-0.482288,0.859732},{0,-5.36443e-07,6.20212,0.711462,0.657977,0.246754,-0.684944,0.570814,0.452794,0.157078,-0.491159,0.856791},{5.36443e-07,0,6.20212,0.704492,0.657262,0.267765,-0.695978,0.565937,0.441961,0.138946,-0.497716,0.856138},{1.07288e-06,0,6.20212,0.695024,0.657388,0.291175,-0.709533,0.561663,0.425556,0.116213,-0.50237,0.856808},{0,0,6.20212,0.683947,0.658088,0.314858,-0.723783,0.558033,0.40588,0.0914034,-0.50549,0.857978},{0,-5.36443e-07,6.20212,0.672418,0.659111,0.33679,-0.737126,0.555075,0.385406,0.0670818,-0.50741,0.85909},{1.07288e-06,-5.36443e-07,6.20212,0.661845,0.660208,0.355086,-0.748237,0.552827,0.366774,0.0458459,-0.508436,0.859879},{5.36443e-07,1.07288e-06,6.20212,0.653824,0.661126,0.368004,-0.756039,0.551347,0.352733,0.0303028,-0.508851,0.860321},{-5.36443e-07,0,6.20212,0.650007,0.661596,0.373875,-0.759579,0.55071,0.346062,0.0230562,-0.50893,0.860499},{-5.36443e-07,-5.36443e-07,6.20212,0.649888,0.661611,0.374055,-0.759687,0.550692,0.345853,0.0228313,-0.50893,0.860505}}},["14"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,-5.36443e-07,5.60288,0.635823,0.768833,0.0680112,-0.581752,0.419463,0.696861,0.507241,-0.482646,0.713974},{6.70554e-08,-5.36443e-07,5.60288,0.630355,0.774015,0.0596036,-0.586398,0.424432,0.689924,0.508714,-0.469848,0.721424},{0,-1.07288e-06,5.60288,0.615244,0.787499,0.0363392,-0.598876,0.436909,0.671162,0.512662,-0.434691,0.74042},{-1.3411e-07,-8.04661e-07,5.60288,0.592351,0.80568,0.000962809,-0.617046,0.452895,0.643538,0.518049,-0.381795,0.765413},{-1.3411e-07,-2.68221e-07,5.60288,0.563576,0.82492,-0.043466,-0.63868,0.468502,0.610405,0.523899,-0.316248,0.790896},{-2.68221e-07,0,5.60288,0.530923,0.842284,-0.093164,-0.661385,0.48059,0.57585,0.529803,-0.244115,0.81223},{4.02332e-07,-2.68221e-07,5.60288,0.496446,0.856106,-0.14361,-0.682631,0.487213,0.544646,0.536243,-0.172355,0.826279},{-2.01166e-07,5.36443e-07,5.60288,0.459721,0.865722,-0.197946,-0.691694,0.488854,0.531584,0.55697,-0.107463,0.823551},{-7.12462e-08,-2.68221e-07,5.60288,0.420174,0.87066,-0.255744,-0.684185,0.489093,0.540999,0.596109,-0.0523373,0.801196},{-1.67638e-08,-5.36443e-07,5.60288,0.381237,0.871733,-0.3078,-0.666655,0.4899,0.561756,0.640492,-0.00896595,0.767912},{-3.35276e-08,-1.3411e-07,5.60288,0.348726,0.870689,-0.346828,-0.646635,0.491393,0.583435,0.67842,0.0208122,0.73438},{6.70554e-08,-6.70554e-07,5.60288,0.330059,0.869531,-0.367391,-0.633062,0.492601,0.59714,0.70021,0.0354901,0.713055},{1.3411e-07,0,5.60288,0.332808,0.869986,-0.363817,-0.630681,0.492177,0.600003,0.701057,0.0297668,0.712484},{2.01166e-07,-6.03497e-07,5.60288,0.358322,0.872314,-0.332676,-0.62577,0.488851,0.607813,0.692833,-0.00961368,0.721034},{-2.34693e-07,-5.36443e-07,5.60288,0.400369,0.872636,-0.279664,-0.617934,0.482464,0.620795,0.676656,-0.0757332,0.732394},{1.17347e-07,-1.3411e-07,5.60288,0.451912,0.866606,-0.211587,-0.608796,0.472977,0.636914,0.65203,-0.159016,0.74133},{-2.01166e-07,0,5.60288,0.505779,0.851818,-0.136358,-0.599865,0.460875,0.654031,0.619959,-0.248999,0.744077},{0,2.68221e-07,5.60288,0.555427,0.829198,-0.0626946,-0.592289,0.447402,0.670094,0.58369,-0.335055,0.739624},{-2.68221e-07,5.36443e-07,5.60288,0.595738,0.803179,0.000797123,-0.586696,0.434489,0.683379,0.548529,-0.407582,0.730063},{-1.3411e-07,-5.36443e-07,5.60288,0.623242,0.780651,0.0464155,-0.583228,0.424447,0.692596,0.520975,-0.458726,0.71983},{-1.3411e-07,6.70554e-07,5.60288,0.635451,0.769197,0.0673647,-0.581795,0.419615,0.696734,0.507659,-0.481933,0.714159},{0,-5.36443e-07,5.60288,0.635823,0.768833,0.0680112,-0.581752,0.419463,0.696861,0.507241,-0.482646,0.713974}}},["15"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,-0.00239779,-0.473524,-0.880778,0.557685,0.73046,-0.394228,0.830049,-0.492142,0.262326},{5.23868e-09,8.38192e-08,5.59555,0.00349345,-0.466505,-0.884512,0.557658,0.735118,-0.38551,0.830063,-0.491909,0.262719},{5.23868e-09,8.38192e-08,5.59555,0.0179847,-0.449043,-0.893329,0.557346,0.746282,-0.363908,0.830086,-0.491348,0.263694},{9.42962e-09,8.38192e-08,5.59555,0.0362853,-0.426588,-0.903718,0.556446,0.759781,-0.336303,0.830091,-0.490667,0.264942},{-3.14321e-09,-5.02913e-08,5.59555,0.0535964,-0.404933,-0.912774,0.555074,0.771933,-0.309858,0.830072,-0.49005,0.266141},{-3.14321e-09,-5.02913e-08,5.59555,0.0651599,-0.390241,-0.918404,0.553874,0.779713,-0.292012,0.830047,-0.489653,0.26695},{-3.14321e-09,-5.02913e-08,5.59555,0.067227,-0.387595,-0.919375,0.553636,0.781075,-0.288807,0.830041,-0.489583,0.267096},{5.23868e-09,2.1793e-07,5.59555,0.0655876,-0.389694,-0.918606,0.553826,0.779995,-0.291349,0.830045,-0.489639,0.26698},{-3.14321e-09,-5.02913e-08,5.59555,0.0623666,-0.393806,-0.917075,0.554185,0.777858,-0.296336,0.830054,-0.489748,0.266754},{-3.14321e-09,2.1793e-07,5.59555,0.0578291,-0.399576,-0.914874,0.554662,0.774812,-0.303343,0.830064,-0.489903,0.266436},{5.23868e-09,-5.02913e-08,5.59555,0.05224,-0.406644,-0.912092,0.5552,0.771002,-0.311942,0.830075,-0.490098,0.266046},{1.04774e-09,-5.02913e-08,5.59555,0.0458657,-0.414654,-0.908823,0.555749,0.766581,-0.321708,0.830084,-0.490322,0.265603},{9.42962e-09,8.38192e-08,5.59555,0.0389738,-0.423252,-0.905173,0.556266,0.761708,-0.332218,0.83009,-0.490569,0.265127},{-3.14321e-09,2.1793e-07,5.59555,0.0318335,-0.432092,-0.901267,0.556716,0.756559,-0.343052,0.830092,-0.49083,0.264637},{5.23868e-09,8.38192e-08,5.59555,0.0247154,-0.440837,-0.897247,0.55708,0.751325,-0.353797,0.830091,-0.491094,0.264151},{1.04774e-09,-5.02913e-08,5.59555,0.0178905,-0.449158,-0.893273,0.557349,0.746211,-0.364049,0.830086,-0.491352,0.263687},{5.23868e-09,-5.02913e-08,5.59555,0.0116301,-0.456735,-0.889527,0.557526,0.741438,-0.373409,0.830078,-0.491592,0.263265},{7.33417e-09,8.38192e-08,5.59555,0.006205,-0.463259,-0.886201,0.557627,0.737239,-0.381485,0.830069,-0.491802,0.2629},{6.28643e-09,-5.02913e-08,5.59555,0.00188552,-0.468425,-0.883501,0.557671,0.733854,-0.387893,0.83006,-0.491972,0.262611},{-1.41445e-08,-5.02913e-08,5.59555,-0.00105881,-0.471933,-0.881634,0.557684,0.731525,-0.39225,0.830053,-0.492088,0.262415},{1.04774e-09,8.38192e-08,5.59555,-0.0023588,-0.473477,-0.880803,0.557685,0.730491,-0.394171,0.830049,-0.49214,0.262328},{-3.14321e-09,8.38192e-08,5.59555,-0.00239779,-0.473524,-0.880778,0.557685,0.73046,-0.394228,0.830049,-0.492142,0.262326}}},["16"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{2.68221e-07,0,4.04298,0.788188,0.225403,-0.572671,-0.555192,0.661933,-0.503594,0.265559,0.71487,0.646869},{2.68221e-07,-1.3411e-07,4.04298,0.783417,0.221261,-0.580776,-0.560658,0.654839,-0.506802,0.268179,0.722654,0.637064},{-2.68221e-07,-1.3411e-07,4.04298,0.771479,0.210637,-0.600376,-0.574121,0.637171,-0.514196,0.274234,0.74138,0.612496},{0,0,4.04298,0.756003,0.196337,-0.624429,-0.591147,0.61443,-0.522515,0.281078,0.764152,0.580575},{0,0,4.04298,0.740965,0.181916,-0.646434,-0.607259,0.592498,-0.529323,0.286718,0.784763,0.549491},{2.68221e-07,-1.3411e-07,4.04298,0.730712,0.171804,-0.660714,-0.618016,0.577631,-0.533291,0.290027,0.798014,0.528259},{2.68221e-07,0,4.04298,0.728862,0.169956,-0.663231,-0.619938,0.574955,-0.53395,0.29058,0.800338,0.524425},{5.36443e-07,1.3411e-07,4.04298,0.73033,0.171423,-0.661236,-0.618414,0.577078,-0.533428,0.290143,0.798496,0.527467},{5.36443e-07,-1.3411e-07,4.04298,0.733204,0.174282,-0.657296,-0.615418,0.581237,-0.532375,0.289262,0.794852,0.533422},{0,-1.3411e-07,4.04298,0.737231,0.178259,-0.6517,-0.611197,0.587076,-0.53083,0.287972,0.789662,0.541762},{2.68221e-07,2.68221e-07,4.04298,0.742157,0.183078,-0.644737,-0.605996,0.594231,-0.528828,0.286306,0.783181,0.551957},{-2.68221e-07,0,4.04298,0.747728,0.188463,-0.636698,-0.600064,0.602341,-0.526411,0.284301,0.775672,0.563477},{-2.68221e-07,-1.3411e-07,4.04298,0.753693,0.194155,-0.627895,-0.593649,0.61105,-0.52364,0.282008,0.767413,0.575804},{0,-2.68221e-07,4.04298,0.759808,0.199906,-0.618651,-0.587004,0.620005,-0.520597,0.279496,0.758704,0.58843},{0,1.3411e-07,4.04298,0.765839,0.205491,-0.609315,-0.580381,0.628862,-0.517389,0.276856,0.749871,0.60087},{5.36443e-07,-1.3411e-07,4.04298,0.771558,0.210707,-0.60025,-0.574033,0.637287,-0.51415,0.274197,0.741261,0.612657},{8.04661e-07,-1.3411e-07,4.04298,0.77675,0.215372,-0.59184,-0.568214,0.644957,-0.511041,0.271647,0.733243,0.623348},{0,-1.3411e-07,4.04298,0.781205,0.21932,-0.58448,-0.563175,0.651557,-0.50824,0.269354,0.726204,0.632516},{0,0,4.04298,0.784724,0.222402,-0.578572,-0.559165,0.656781,-0.505938,0.267473,0.720539,0.639751},{2.68221e-07,-4.02332e-07,4.04298,0.787108,0.22447,-0.57452,-0.556433,0.660325,-0.504333,0.266162,0.716647,0.64465},{0,2.68221e-07,4.04298,0.788157,0.225376,-0.572725,-0.555228,0.661886,-0.503616,0.265576,0.714921,0.646805},{2.68221e-07,0,4.04298,0.788188,0.225403,-0.572671,-0.555192,0.661933,-0.503594,0.265559,0.71487,0.646869}}},["17"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,0,4.30251,0.861801,0.100392,0.497213,-0.022361,0.986785,-0.160484,-0.506753,0.127187,0.852657},{0,5.36443e-07,4.30251,0.853102,0.097833,0.51249,-0.0186366,0.98735,-0.15746,-0.521412,0.124778,0.844133},{5.36443e-07,0,4.30251,0.830546,0.0913479,0.549407,-0.00969259,0.988679,-0.149732,-0.556865,0.119034,0.822029},{0,0,4.30251,0.79976,0.0827859,0.594584,0.0011369,0.990235,-0.139403,-0.600318,0.112165,0.791857},{5.36443e-07,5.36443e-07,4.30251,0.768346,0.0743255,0.635704,0.0108711,0.991576,-0.129073,-0.639942,0.106083,0.761065},{2.68221e-07,5.36443e-07,4.30251,0.746159,0.0684896,0.662235,0.017082,0.992398,-0.121882,-0.665548,0.102256,0.739317},{-2.68221e-07,0,4.30251,0.742094,0.0674315,0.666895,0.0181668,0.992538,-0.120573,-0.670049,0.101592,0.735332},{2.68221e-07,0,4.30251,0.745321,0.0682711,0.663201,0.017307,0.992427,-0.121612,-0.666481,0.102118,0.738495},{0,0,4.30251,0.751605,0.0699124,0.655898,0.0156037,0.992204,-0.12364,-0.659428,0.103163,0.744655},{2.68221e-07,0,4.30251,0.760335,0.072206,0.645505,0.0131722,0.991884,-0.126467,-0.649398,0.10466,0.753213},{0,0,4.30251,0.770886,0.0750005,0.632542,0.010127,0.991475,-0.129901,-0.636892,0.106545,0.763555},{2.68221e-07,0,4.30251,0.782645,0.0781456,0.617543,0.00658731,0.990993,-0.133751,-0.622433,0.108748,0.775081},{0,0,4.30251,0.795026,0.0814944,0.601076,0.00268203,0.990452,-0.137834,-0.60657,0.111193,0.787216},{5.36443e-07,5.36443e-07,4.30251,0.807482,0.0849057,0.58375,-0.00144778,0.989869,-0.141973,-0.589891,0.113795,0.799425},{2.68221e-07,0,4.30251,0.819519,0.0882461,0.566217,-0.00564749,0.989268,-0.146006,-0.573025,0.116457,0.811222},{0,1.07288e-06,4.30251,0.830698,0.091391,0.549171,-0.00974967,0.988671,-0.149783,-0.556638,0.11907,0.822178},{-8.04661e-07,5.36443e-07,4.30251,0.840638,0.0942246,0.533338,-0.0135758,0.988106,-0.15317,-0.541427,0.121521,0.831919},{-2.68221e-07,0,4.30251,0.849006,0.09664,0.519471,-0.0169392,0.987605,-0.156045,-0.528112,0.123683,0.840119},{0,5.36443e-07,4.30251,0.855503,0.0985359,0.508335,-0.0196481,0.987197,-0.158292,-0.517424,0.125431,0.846486},{-2.68221e-07,0,4.30251,0.859848,0.0998143,0.500698,-0.0215101,0.986915,-0.159802,-0.510097,0.126636,0.850743},{-2.68221e-07,0,4.30251,0.861745,0.100375,0.497314,-0.0223361,0.986789,-0.160464,-0.506851,0.127171,0.852602},{0,0,4.30251,0.861801,0.100392,0.497213,-0.022361,0.986785,-0.160484,-0.506753,0.127187,0.852657}}},["18"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,0,5.37487,0.0344749,0.382786,-0.923193,0.994184,0.0811702,0.0707818,0.10203,-0.920264,-0.377761},{0,0,5.37487,0.030126,0.394569,-0.918372,0.994056,0.0843395,0.0688444,0.104619,-0.914988,-0.389683},{5.36443e-07,0,5.37487,0.0192827,0.423225,-0.905819,0.993662,0.0922397,0.0642497,0.110745,-0.901317,-0.418764},{0,0,5.37487,0.00530276,0.458718,-0.888566,0.993002,0.102421,0.0588006,0.117981,-0.88266,-0.454965},{-1.07288e-06,5.36443e-07,5.37487,-0.00820134,0.491536,-0.870819,0.992211,0.112252,0.0540164,0.124302,-0.863593,-0.488627},{1.07288e-06,5.36443e-07,5.37487,-0.0173667,0.513026,-0.858197,0.991592,0.118922,0.0510252,0.128236,-0.850095,-0.510777},{0,-1.07288e-06,5.37487,-0.0190168,0.51683,-0.855877,0.991473,0.120123,0.0505079,0.128914,-0.847619,-0.514707},{5.36443e-07,0,5.37487,-0.0177078,0.513814,-0.857719,0.991568,0.119171,0.0509177,0.128377,-0.849584,-0.511591},{0,0,5.37487,-0.0151423,0.507867,-0.861302,0.991748,0.117304,0.0517326,0.127307,-0.853411,-0.505452},{1.07288e-06,0,5.37487,-0.011543,0.499443,-0.86627,0.991993,0.114684,0.0529023,0.125769,-0.858723,-0.496767},{0,0,5.37487,-0.00713373,0.488992,-0.872259,0.992278,0.111475,0.0543781,0.123826,-0.865136,-0.486011},{1.60933e-06,0,5.37487,-0.00213799,0.476974,-0.878915,0.992584,0.107839,0.0561079,0.121543,-0.872277,-0.473667},{-5.36443e-07,0,5.37487,0.00322305,0.463864,-0.8859,0.99289,0.103935,0.0580337,0.118996,-0.879788,-0.460231},{-1.07288e-06,-5.36443e-07,5.37487,0.00873213,0.450158,-0.892906,0.993179,0.099924,0.0600894,0.116272,-0.88734,-0.446215},{5.36443e-07,-5.36443e-07,5.37487,0.0141774,0.436371,-0.899655,0.99344,0.0959583,0.0621994,0.113471,-0.894635,-0.432148},{-5.36443e-07,0,5.37487,0.0193538,0.42304,-0.905904,0.993665,0.0921879,0.0642788,0.110706,-0.901409,-0.418576},{-5.36443e-07,5.36443e-07,5.37487,0.0240628,0.410717,-0.911445,0.993849,0.0887574,0.0662344,0.108101,-0.907432,-0.406055},{5.36443e-07,-5.36443e-07,5.37487,0.0281127,0.399967,-0.916098,0.993991,0.0858066,0.0679661,0.105791,-0.912504,-0.395151},{5.36443e-07,0,5.37487,0.0313164,0.391361,-0.919704,0.994093,0.083472,0.0693692,0.103918,-0.916444,-0.386435},{5.36443e-07,0,5.37487,0.0334895,0.385471,-0.922112,0.994156,0.0818883,0.0703379,0.102623,-0.919079,-0.380476},{0,5.36443e-07,5.37487,0.0344462,0.382864,-0.923162,0.994183,0.0811911,0.0707688,0.102047,-0.92023,-0.377841},{0,0,5.37487,0.0344749,0.382786,-0.923193,0.994184,0.0811702,0.0707818,0.10203,-0.920264,-0.377761}}},["19"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-3.14321e-09,8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},{5.23868e-09,8.38192e-08,5.59555,-0.0572228,0.54387,0.837216,-0.554722,0.679906,-0.479594,-0.830065,-0.491866,0.262791},{5.23868e-09,8.38192e-08,5.59555,-0.0399886,0.524571,0.850427,-0.556195,0.695375,-0.455083,-0.830089,-0.491201,0.263957},{9.42962e-09,8.38192e-08,5.59555,-0.0178207,0.499159,0.866327,-0.557351,0.714395,-0.423084,-0.830086,-0.490388,0.265476},{-3.14321e-09,-5.02913e-08,5.59555,0.00382974,0.473703,0.880676,-0.557682,0.732024,-0.39132,-0.830045,-0.489639,0.266979},{-3.14321e-09,-5.02913e-08,5.59555,0.0194926,0.454897,0.890331,-0.557432,0.744195,-0.368027,-0.829994,-0.489125,0.26808},{-3.14321e-09,-5.02913e-08,5.59555,0.0240154,0.449405,0.893005,-0.557283,0.747618,-0.361252,-0.829975,-0.488981,0.2684},{5.23868e-09,2.1793e-07,5.59555,0.02233,0.451455,0.892015,-0.557343,0.746347,-0.363779,-0.829982,-0.489034,0.268281},{-3.14321e-09,-5.02913e-08,5.59555,0.0185159,0.456079,0.889747,-0.55746,0.74345,-0.369487,-0.829998,-0.489156,0.268011},{-3.14321e-09,2.1793e-07,5.59555,0.0129258,0.462822,0.886357,-0.557587,0.739151,-0.377825,-0.830018,-0.489338,0.267618},{5.23868e-09,-5.02913e-08,5.59555,0.005913,0.471221,0.881996,-0.557673,0.733671,-0.388237,-0.83004,-0.489569,0.267125},{1.04774e-09,-5.02913e-08,5.59555,-0.00216769,0.480818,0.876818,-0.557669,0.727234,-0.40017,-0.83006,-0.489842,0.266561},{9.42962e-09,8.38192e-08,5.59555,-0.0109596,0.49116,0.871001,-0.557541,0.720083,-0.413072,-0.830077,-0.490146,0.26595},{-3.14321e-09,2.1793e-07,5.59555,-0.0201047,0.501808,0.864746,-0.55727,0.712481,-0.426405,-0.830088,-0.49047,0.265318},{5.23868e-09,8.38192e-08,5.59555,-0.0292445,0.512337,0.858286,-0.556859,0.704716,-0.43964,-0.830092,-0.490801,0.26469},{1.04774e-09,-5.02913e-08,5.59555,-0.0380215,0.522343,0.851888,-0.556331,0.697103,-0.452265,-0.83009,-0.491127,0.264091},{5.23868e-09,-5.02913e-08,5.59555,-0.04608,0.531438,0.845843,-0.555732,0.689976,-0.463783,-0.830083,-0.491433,0.263543},{7.33417e-09,8.38192e-08,5.59555,-0.0530669,0.539253,0.84047,-0.555124,0.683691,-0.473713,-0.830073,-0.491703,0.263071},{6.28643e-09,-5.02913e-08,5.59555,-0.058632,0.54543,0.836103,-0.55458,0.678615,-0.481583,-0.830062,-0.491922,0.262696},{-1.41445e-08,-5.02913e-08,5.59555,-0.0624267,0.549618,0.83308,-0.554179,0.675118,-0.486931,-0.830054,-0.492073,0.262441},{1.04774e-09,8.38192e-08,5.59555,-0.064103,0.551462,0.831733,-0.553994,0.673564,-0.489288,-0.830049,-0.49214,0.262329},{-3.14321e-09,8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325}}},["20"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-5.36443e-07,-1.3411e-07,4.04298,0.896552,-0.18038,0.404545,0.407723,0.692959,-0.594617,-0.173076,0.698047,0.69482},{-2.68221e-07,-4.02332e-07,4.04298,0.891176,-0.177135,0.417646,0.416266,0.685288,-0.597581,-0.180356,0.706401,0.684448},{-5.36443e-07,-1.3411e-07,4.04298,0.877039,-0.168303,0.449973,0.437743,0.665876,-0.604144,-0.197947,0.726831,0.657673},{-8.04661e-07,-5.36443e-07,4.04298,0.857222,-0.155314,0.490966,0.465846,0.640209,-0.610836,-0.21945,0.752337,0.621153},{0,0,4.04298,0.835858,-0.140671,0.530615,0.494034,0.614162,-0.615414,-0.239313,0.776541,0.582849},{-2.68221e-07,-2.68221e-07,4.04298,0.818436,-0.128326,0.560084,0.515694,0.593945,-0.617486,-0.25342,0.794205,0.552283},{-2.68221e-07,-4.02332e-07,4.04298,0.81124,-0.123134,0.571601,0.524337,0.585828,-0.617962,-0.258768,0.801027,0.53981},{0,-4.02332e-07,4.04298,0.812627,-0.124139,0.569409,0.522684,0.587382,-0.617886,-0.257757,0.799732,0.542208},{-5.36443e-07,2.68221e-07,4.04298,0.816491,-0.126928,0.563233,0.518047,0.591738,-0.617635,-0.254891,0.796075,0.548903},{-2.68221e-07,0,4.04298,0.822362,-0.131136,0.553647,0.510908,0.598428,-0.617136,-0.250389,0.790372,0.559122},{-2.68221e-07,-2.68221e-07,4.04298,0.829753,-0.136382,0.541212,0.50175,0.606981,-0.616297,-0.244453,0.782927,0.572074},{-5.36443e-07,-2.68221e-07,4.04298,0.83818,-0.14229,0.526504,0.491063,0.616922,-0.615032,-0.237299,0.774054,0.586966},{-5.36443e-07,-2.68221e-07,4.04298,0.84718,-0.148505,0.51013,0.47934,0.627777,-0.613293,-0.229171,0.764095,0.603025},{2.68221e-07,-1.3411e-07,4.04298,0.856316,-0.154705,0.492736,0.467082,0.639073,-0.611081,-0.220356,0.753427,0.619509},{-2.68221e-07,0,4.04298,0.865196,-0.160617,0.475015,0.45479,0.650343,-0.608458,-0.211194,0.742467,0.63572},{-2.68221e-07,-2.68221e-07,4.04298,0.87347,-0.166013,0.4577,0.442964,0.661131,-0.605549,-0.202071,0.731673,0.651016},{-5.36443e-07,-2.68221e-07,4.04298,0.880842,-0.170718,0.441558,0.432096,0.670997,-0.602541,-0.19342,0.721539,0.664809},{-5.36443e-07,0,4.04298,0.887051,-0.174601,0.427381,0.422673,0.679516,-0.599671,-0.185709,0.712581,0.676565},{-5.36443e-07,-1.3411e-07,4.04298,0.891875,-0.17756,0.415971,0.415168,0.686276,-0.597211,-0.179429,0.705335,0.68579},{-5.36443e-07,-2.68221e-07,4.04298,0.895101,-0.179511,0.40813,0.410051,0.690871,-0.595445,-0.175077,0.700337,0.692009},{-2.68221e-07,-1.3411e-07,4.04298,0.89651,-0.180355,0.404649,0.407791,0.692899,-0.594641,-0.173135,0.698114,0.694738},{-5.36443e-07,-1.3411e-07,4.04298,0.896552,-0.18038,0.404545,0.407723,0.692959,-0.594617,-0.173076,0.698047,0.69482}}},["21"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{0,0,4.30251,0.909555,-0.11628,-0.398984,0.0479311,0.983003,-0.177221,0.41281,0.142068,0.89967},{5.36443e-07,2.68221e-07,4.30251,0.897884,-0.113516,-0.425345,0.0420647,0.983885,-0.173781,0.438218,0.138144,0.88819},{0,0,4.30251,0.8648,-0.105959,-0.49081,0.0275882,0.986031,-0.164261,0.501359,0.128513,0.855642},{0,5.36443e-07,4.30251,0.813298,-0.0947641,-0.574079,0.00938526,0.988656,-0.149903,0.581772,0.116528,0.804962},{5.36443e-07,0,4.30251,0.75125,-0.0818684,-0.654921,-0.00801782,0.991072,-0.133086,0.659969,0.105232,0.743886},{0,0,4.30251,0.693146,-0.0701957,-0.717371,-0.0212341,0.992826,-0.117666,0.720485,0.0967926,0.686683},{-2.68221e-07,0,4.30251,0.657598,-0.0632022,-0.750714,-0.0281891,0.993713,-0.108353,0.752842,0.0924144,0.651682},{2.68221e-07,5.36443e-07,4.30251,0.655732,-0.0628379,-0.752374,-0.0285333,0.993756,-0.107866,0.754454,0.0921991,0.649845},{5.36443e-07,5.36443e-07,4.30251,0.666018,-0.0648497,-0.743111,-0.0266103,0.993514,-0.110552,0.745461,0.0934038,0.659973},{-5.36443e-07,0,4.30251,0.683873,-0.0683616,-0.726391,-0.0231233,0.99307,-0.115229,0.729235,0.0955985,0.677553},{0,0,4.30251,0.707397,-0.0730289,-0.703034,-0.0182203,0.992433,-0.121424,0.706582,0.0987045,0.700714},{0,5.36443e-07,4.30251,0.734642,-0.0784978,-0.673898,-0.0120575,0.991617,-0.128651,0.678348,0.102638,0.727537},{0,1.07288e-06,4.30251,0.763708,-0.0844173,-0.640019,-0.00483254,0.990638,-0.13643,0.645544,0.107286,0.75615},{0,0,4.30251,0.79284,-0.090453,-0.60268,0.00319473,0.989527,-0.14431,0.609422,0.112489,0.784826},{0,-5.36443e-07,4.30251,0.820519,-0.0963021,-0.563448,0.0116947,0.988328,-0.151891,0.571499,0.11804,0.812069},{0,0,4.30251,0.845537,-0.101706,-0.524141,0.0202717,0.987097,-0.158837,0.533532,0.123677,0.836689},{0,2.68221e-07,4.30251,0.86702,-0.106456,-0.486768,0.028478,0.9859,-0.164892,0.497459,0.129102,0.857827},{5.36443e-07,0,4.30251,0.884416,-0.110395,-0.453454,0.0358323,0.984815,-0.16987,0.465321,0.133987,0.874942},{0,5.36443e-07,4.30251,0.897419,-0.113406,-0.426355,0.0418403,0.983919,-0.173645,0.439192,0.137994,0.887732},{-5.36443e-07,-2.68221e-07,4.30251,0.905841,-0.115394,-0.407598,0.0460117,0.983293,-0.176121,0.421112,0.140783,0.896016},{0,2.68221e-07,4.30251,0.909448,-0.116255,-0.399236,0.0478749,0.983012,-0.177189,0.413052,0.142031,0.899564},{0,0,4.30251,0.909555,-0.11628,-0.398984,0.0479311,0.983003,-0.177221,0.41281,0.142068,0.89967}}},["22"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.70833,1.91667,2.125,2.33333,2.54167,2.75,2.95833,3.16667,3.375,3.58333,3.79167,4,4.20833,4.25},["poses"]={{-1.07288e-06,1.07288e-06,5.37487,-0.00271533,-0.356721,0.934207,-0.997549,0.0662763,0.0224076,-0.0699091,-0.931857,-0.356027},{-1.07288e-06,-5.36443e-07,5.37487,-0.00291406,-0.357705,0.93383,-0.997546,0.0663641,0.0223078,-0.0699525,-0.931473,-0.357021},{5.36443e-07,0,5.37488,-0.00341807,-0.360197,0.93287,-0.997537,0.0665871,0.0220553,-0.0700615,-0.930497,-0.359538},{0,-5.36443e-07,5.37487,-0.00408892,-0.363508,0.931582,-0.997524,0.0668849,0.0217203,-0.0702043,-0.929187,-0.362882},{-5.36443e-07,0,5.37487,-0.00478806,-0.366951,0.930228,-0.997511,0.0671962,0.0213726,-0.0703505,-0.92781,-0.366359},{-5.36443e-07,0,5.37487,-0.00537655,-0.369842,0.929079,-0.997499,0.067459,0.021081,-0.0704715,-0.926643,-0.36928},{-5.36443e-07,5.36443e-07,5.37487,-0.00571494,-0.371502,0.928415,-0.997493,0.0676105,0.0209138,-0.0705401,-0.925967,-0.370957},{-5.36443e-07,0,5.37487,-0.00573233,-0.371587,0.92838,-0.997492,0.0676183,0.0209052,-0.0705436,-0.925932,-0.371043},{5.36443e-07,0,5.37488,-0.00563598,-0.371115,0.92857,-0.997494,0.0675751,0.0209527,-0.0705242,-0.926125,-0.370566},{1.07288e-06,-5.36443e-07,5.37487,-0.00546616,-0.370282,0.928903,-0.997497,0.0674991,0.0210367,-0.0704897,-0.926464,-0.369724},{-1.60933e-06,5.36443e-07,5.37487,-0.00523671,-0.369155,0.929353,-0.997502,0.0673965,0.0211502,-0.0704429,-0.926921,-0.368586},{0,0,5.37487,-0.00496157,-0.367804,0.92989,-0.997507,0.0672736,0.0212865,-0.0703864,-0.927467,-0.367221},{-1.60933e-06,0,5.37487,-0.00465464,-0.366294,0.930487,-0.997513,0.0671367,0.0214388,-0.0703228,-0.928074,-0.365696},{0,0,5.37487,-0.0043298,-0.364695,0.931117,-0.99752,0.066992,0.0216003,-0.070255,-0.928714,-0.36408},{5.36443e-07,5.36443e-07,5.37488,-0.00400092,-0.363074,0.931751,-0.997526,0.0668458,0.0217641,-0.0701857,-0.929359,-0.362443},{1.07288e-06,5.36443e-07,5.37487,-0.00368185,-0.3615,0.932365,-0.997532,0.0667041,0.0219234,-0.0701179,-0.929983,-0.360853},{5.36443e-07,0,5.37487,-0.00338642,-0.360041,0.93293,-0.997537,0.0665731,0.0220711,-0.0700547,-0.930558,-0.35938},{-5.36443e-07,0,5.37488,-0.00312846,-0.358766,0.933422,-0.997542,0.0664589,0.0222003,-0.069999,-0.931059,-0.358092},{0,0,5.37487,-0.00292172,-0.357743,0.933815,-0.997546,0.0663675,0.0223039,-0.0699542,-0.931459,-0.357059},{5.36443e-07,-5.36443e-07,5.37487,-0.00278006,-0.357042,0.934084,-0.997548,0.0663049,0.0223751,-0.0699233,-0.931732,-0.356351},{-5.36443e-07,0,5.37487,-0.00271723,-0.356731,0.934203,-0.997549,0.0662772,0.0224066,-0.0699095,-0.931853,-0.356037},{-1.07288e-06,1.07288e-06,5.37487,-0.00271533,-0.356721,0.934207,-0.997549,0.0662763,0.0224076,-0.0699091,-0.931857,-0.356027}}}}}
]====])
-- Source: src/client/world/dragon/Rig.luau
addModule(modules,{"world","dragon","Rig"},[====[
-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.
return {["bones"]={{["index"]=5,["name"]="base",["parent"]=0,["rest"]={0,-4.94982,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},["inverse"]={-0.394392,-1.95941,5.31303,0.980339,0.123079,-0.154228,-0.197319,0.611495,-0.76625,0,0.781617,0.623759}},{["index"]=2,["name"]="neck1",["parent"]=5,["rest"]={-3.35276e-08,-1.3411e-07,3.7976,0.97169,-0.151083,0.181638,-0.103674,0.418168,0.902434,-0.212298,-0.895717,0.390666},["inverse"]={-0.501811,-2.11717,-1.24784,0.973043,-0.109736,-0.202844,-0.230625,-0.462996,-0.855831,0,0.879541,-0.475822}},{["index"]=6,["name"]="neck2",["parent"]=2,["rest"]={-1.3411e-07,-8.04661e-07,5.10035,0.20717,-0.974792,-0.0828375,0.909986,0.223098,-0.349505,0.359175,-0.00297412,0.933266},["inverse"]={-4.31067,0.0357058,-5.14301,-0.00828016,-0.128144,-0.991721,-0.999966,0.00106108,0.00821185,0,0.991755,-0.128149}},{["index"]=1,["name"]="neck3",["parent"]=6,["rest"]={0,0,4.80781,0.428849,-0.365394,0.826182,0.656135,0.754612,-0.0068411,-0.620947,0.545021,0.563362},["inverse"]={4.35373,-3.82136,-9.16756,-0.659664,-0.670085,-0.340337,-0.751561,0.588151,0.298722,0,0.45284,-0.891592}},{["index"]=7,["name"]="jaw_upper",["parent"]=1,["rest"]={-2.68221e-07,-2.68221e-07,3.87696,0.220576,-0.810685,0.542343,0.875768,-0.0801763,-0.476029,0.429392,0.579967,0.692286},["inverse"]={-7.98751,-10.7885,-4.85024,-0.803698,0.561724,-0.196302,0.595037,0.758704,-0.265139,0,-0.329898,-0.944016}},{["index"]=8,["name"]="jaw_lower",["parent"]=1,["rest"]={1.10288,-0.968026,3.25436,0.753414,-0.0430251,0.656138,0.536763,0.616615,-0.575909,-0.379806,0.786088,0.487661},["inverse"]={5.63558,-11.664,-2.28141,-0.90041,-0.361145,0.24256,-0.435042,0.747465,-0.50203,0,-0.557557,-0.830139}},{["index"]=9,["name"]="tongue",["parent"]=1,["rest"]={1.01566,-0.891467,3.63548,0.822607,0.0610726,0.565321,0.279987,0.821825,-0.496197,-0.494899,0.566458,0.658939},["inverse"]={8.2618,-9.45638,-5.09553,-0.753072,-0.610652,0.244923,-0.657939,0.698948,-0.280337,0,-0.372258,-0.928129}},{["index"]=23,["name"]="leg_front_shoulder_L",["parent"]=5,["rest"]={-3.35276e-08,-1.3411e-07,3.7976,-0.0777039,0.0682742,-0.994636,-0.10221,0.99185,0.0760679,0.991723,0.107573,-0.0700925},["inverse"]={1.73381,-1.80734,0.137007,-0.0560084,0.703083,0.708899,-0.128779,0.698995,-0.703436,-0.990091,-0.130689,0.0513926}},{["index"]=4,["name"]="leg_front_upper_L",["parent"]=23,["rest"]={-2.01166e-07,0,4.8923,0.781742,0.0502348,-0.621575,-0.62286,0.111511,-0.774346,0.0304132,0.992493,0.118462},["inverse"]={2.33649,-4.83403,-0.241504,0.00631511,0.110279,0.993881,-0.999832,-0.0164433,0.00817752,0.0172446,-0.993765,0.110156}},{["index"]=3,["name"]="leg_front_lower_L",["parent"]=4,["rest"]={1.3411e-07,0,4.20461,-0.853688,-0.0971089,-0.511651,0.0824775,-0.995273,0.0512845,-0.514212,0.00158132,0.857661},["inverse"]={-0.107082,4.57725,-5.25664,-0.0967221,0.415506,-0.904433,0.994519,0.00408506,-0.104479,-0.039717,-0.909581,-0.413624}},{["index"]=24,["name"]="leg_front_foot_L",["parent"]=3,["rest"]={-2.68221e-07,0,5.62343,0.0883552,0.491026,0.866653,-0.980069,0.198268,-0.0124162,-0.177926,-0.848283,0.498757},["inverse"]={-2.55963,10.0843,-5.57615,-0.976177,0.194547,0.0960802,0.18338,0.976416,-0.113945,-0.115982,-0.0936111,-0.98883}},{["index"]=25,["name"]="wing_lower_L",["parent"]=5,["rest"]={-3.35276e-08,-1.3411e-07,3.7976,0.0329521,0.942233,-0.333333,-0.900359,0.172775,0.399378,0.433899,0.286959,0.854041},["inverse"]={2.40872,-0.275278,0.643163,0.209962,-0.207366,0.955466,0.889617,0.445912,-0.0987145,-0.405584,0.870725,0.278101}},{["index"]=26,["name"]="wing_upper_L",["parent"]=25,["rest"]={-6.70554e-08,0,8.88873,0.109553,-0.0440498,0.993004,0.993713,-0.0183415,-0.110445,0.0230783,0.998861,0.0417636},["inverse"]={-0.19996,-8.33723,2.0779,0.897665,0.440486,0.0129982,-0.430688,0.870689,0.237507,0.0933009,-0.2188,0.971299}},{["index"]=27,["name"]="leg_front_shoulder_R",["parent"]=5,["rest"]={-3.35276e-08,-1.3411e-07,3.7976,-0.0321099,0.320768,0.946613,0.124315,0.941029,-0.314659,-0.991723,0.107574,-0.0700925},["inverse"]={-1.73381,-1.80734,0.136986,-0.0560082,-0.703082,-0.7089,0.128779,0.698997,-0.703434,0.99009,-0.130689,0.0513924}},{["index"]=28,["name"]="leg_front_upper_R",["parent"]=27,["rest"]={6.70554e-08,1.3411e-07,4.8923,0.781743,-0.0502348,0.621574,0.622859,0.111511,-0.774346,-0.0304132,0.992493,0.118462},["inverse"]={-2.33649,-4.83405,-0.241504,0.00631511,-0.110279,-0.993881,0.999831,-0.0164433,0.00817746,-0.0172445,-0.993765,0.110156}},{["index"]=29,["name"]="leg_front_lower_R",["parent"]=28,["rest"]={0,-5.36443e-07,4.20461,-0.853688,0.0971089,0.511651,-0.0824774,-0.995273,0.0512845,0.514212,0.00158134,0.857661},["inverse"]={0.107084,4.57727,-5.25664,-0.0967221,-0.415506,0.904433,-0.994519,0.00408506,-0.104479,0.0397171,-0.909581,-0.413624}},{["index"]=30,["name"]="leg_front_foot_R",["parent"]=29,["rest"]={0,0,5.62343,0.0883551,-0.491026,-0.866653,0.980069,0.198268,-0.0124163,0.177926,-0.848283,0.498757},["inverse"]={2.55965,10.0843,-5.57616,-0.976176,-0.194547,-0.0960801,-0.18338,0.976416,-0.113945,0.115982,-0.0936111,-0.98883}},{["index"]=31,["name"]="wing_lower_R",["parent"]=5,["rest"]={-3.35276e-08,-1.3411e-07,3.7976,0.378715,-0.802019,0.461887,0.8175,0.523851,0.23932,-0.433899,0.286959,0.854041},["inverse"]={-2.40872,-0.275259,0.643153,0.209962,0.207366,-0.955466,-0.889617,0.445912,-0.0987145,0.405584,0.870725,0.278101}},{["index"]=32,["name"]="wing_upper_R",["parent"]=31,["rest"]={3.35276e-08,0,8.88873,0.109553,0.0440499,-0.993004,-0.993713,-0.0183416,-0.110445,-0.0230784,0.998861,0.0417635},["inverse"]={0.19994,-8.33724,2.07791,0.897665,-0.440486,-0.0129982,0.430688,0.870689,0.237507,-0.0933008,-0.2188,0.971299}},{["index"]=10,["name"]="back1",["parent"]=5,["rest"]={-3.35276e-08,-1.3411e-07,3.7976,0.986045,0.0754987,-0.148375,-0.16117,0.656201,-0.737174,0.0417083,0.7508,0.659212},["inverse"]={-0.009886,-0.177751,2.50193,0.998461,0.055407,-0.00256312,-0.0554663,0.997394,-0.0461401,0,0.0462111,0.998932}},{["index"]=11,["name"]="back2",["parent"]=10,["rest"]={-3.14321e-09,8.38192e-08,5.59555,0.792523,-0.609416,-0.0228003,0.548415,0.72855,-0.410434,0.266736,0.312774,0.911605},["inverse"]={-0.930495,-1.09108,-2.74697,0.760885,0.603224,0.239116,-0.648888,0.707339,0.280387,0,-0.368501,0.929628}},{["index"]=12,["name"]="tail1",["parent"]=11,["rest"]={0,2.68221e-07,6.52923,0.994707,0.0957446,0.0372931,-0.0973439,0.99429,0.0437298,-0.0328932,-0.0471285,0.998347},["inverse"]={-0.514235,-0.736762,-9.34329,0.820022,0.543297,0.179978,-0.572332,0.778422,0.257868,0,-0.314464,0.94927}},{["index"]=13,["name"]="tail2",["parent"]=12,["rest"]={0,0,6.20212,0.686543,0.686697,0.238967,-0.72134,0.60203,0.342386,0.0912502,-0.40744,0.908662},["inverse"]={-1.24011,5.53713,-14.5007,0.975827,-0.217205,0.0241734,0.218546,0.969839,-0.107936,0,0.11061,0.993864}},{["index"]=14,["name"]="tail3",["parent"]=13,["rest"]={-6.70554e-08,-2.68221e-07,5.60288,0.509687,0.850137,-0.132235,-0.648402,0.480579,0.590439,0.565503,-0.215198,0.796176},["inverse"]={-15.591,5.933,-12.5726,0.35566,-0.677002,0.64434,0.934616,0.257627,-0.245198,0,0.689418,0.724364}},{["index"]=15,["name"]="leg_back_hip_L",["parent"]=10,["rest"]={-3.14321e-09,8.38192e-08,5.59555,-0.00239779,-0.473524,-0.880778,0.557685,0.73046,-0.394228,0.830049,-0.492142,0.262326},["inverse"]={-2.66696,1.39734,-0.732752,-0.0333269,0.594456,0.803437,-0.513311,0.679577,-0.524106,-0.857556,-0.42988,0.282493}},{["index"]=16,["name"]="leg_back_upper_L",["parent"]=15,["rest"]={2.68221e-07,0,4.04298,0.917774,0.168137,-0.359752,-0.368244,0.69941,-0.612554,0.14862,0.694662,0.703816},["inverse"]={-3.672,-2.78862,-3.25774,0.0309866,0.231437,0.972356,-0.96033,0.276632,-0.0352398,-0.277141,-0.932691,0.230828}},{["index"]=17,["name"]="leg_back_lower_L",["parent"]=16,["rest"]={-5.36443e-07,0,4.30251,0.925738,0.122198,0.357878,-0.0587312,0.981329,-0.183153,-0.373577,0.148533,0.91563},["inverse"]={-0.411193,-4.30821,-7.72577,0.18862,0.546435,0.815985,-0.979777,0.161213,0.118523,-0.0667818,-0.821839,0.565792}},{["index"]=18,["name"]="leg_back_foot_L",["parent"]=17,["rest"]={5.36443e-07,5.36443e-07,5.37487,-0.00618386,0.519768,-0.854285,0.994559,0.0920401,0.0488003,0.103993,-0.849335,-0.517509},["inverse"]={-5.64461,10.5166,6.92074,-0.982557,0.071491,0.171671,0.0645802,0.996874,-0.0455152,-0.174388,-0.0336347,-0.984102}},{["index"]=19,["name"]="leg_back_hip_R",["parent"]=10,["rest"]={-3.14321e-09,8.38192e-08,5.59555,-0.0641533,0.551517,0.831693,-0.553988,0.673517,-0.489359,-0.830049,-0.492142,0.262325},["inverse"]={2.66696,1.39733,-0.732771,-0.0333268,-0.594456,-0.803437,0.513311,0.679577,-0.524106,0.857556,-0.42988,0.282493}},{["index"]=20,["name"]="leg_back_upper_R",["parent"]=19,["rest"]={-5.36443e-07,-1.3411e-07,4.04298,0.917774,-0.168138,0.359752,0.368244,0.69941,-0.612554,-0.14862,0.694662,0.703816},["inverse"]={3.672,-2.78865,-3.25774,0.0309866,-0.231437,-0.972356,0.960329,0.276632,-0.0352398,0.277141,-0.932691,0.230828}},{["index"]=21,["name"]="leg_back_lower_R",["parent"]=20,["rest"]={0,0,4.30251,0.925738,-0.122198,-0.357878,0.058731,0.981329,-0.183153,0.373577,0.148533,0.91563},["inverse"]={0.411191,-4.30824,-7.72577,0.18862,-0.546435,-0.815985,0.979777,0.161213,0.118523,0.066782,-0.821839,0.565792}},{["index"]=22,["name"]="leg_back_foot_R",["parent"]=21,["rest"]={0,0,5.37487,-0.00618371,-0.519768,0.854285,-0.994559,0.0920403,0.0488003,-0.103994,-0.849335,-0.517509},["inverse"]={5.64463,10.5166,6.92073,-0.982557,-0.0714908,-0.171671,-0.0645802,0.996874,-0.0455152,0.174389,-0.0336348,-0.984102}}},["armature"]={1.1567e-05,2.04377,-0.29041,1,0,0,0,1,0,0,0,1},["groundOffset"]=11.1152}
]====])
-- Source: src/client/world/dragon/Walk.luau
addModule(modules,{"world","dragon","Walk"},[====[
-- Generated from Cethiel/Drummyfish CC0 dragon. See assets/dragon/manifest.json.
return {["duration"]=1.66667,["tracks"]={["5"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{4.19094e-09,-5.43821,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-4.80058,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{4.19094e-09,-4.90504,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.28274,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.41893,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{2.61935e-09,-4.99197,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{4.19094e-09,-4.7656,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{2.09548e-09,-5.14071,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759},{0,-5.42218,-4.58586,0.980339,-0.197319,0,0.123079,0.611495,0.781617,-0.154228,-0.76625,0.623759}}},["2"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,1.3411e-07,3.7976,0.967081,-0.170528,0.188876,-0.126572,0.321557,0.938392,-0.220757,-0.931408,0.289388},{-3.35276e-08,1.3411e-07,3.7976,0.98273,-0.135375,0.126161,-0.079681,0.305762,0.948768,-0.167014,-0.942435,0.289695},{-6.70554e-08,1.3411e-07,3.7976,0.985812,-0.122467,0.114789,-0.0734851,0.29996,0.951117,-0.150912,-0.946058,0.286705},{-3.35276e-08,1.3411e-07,3.7976,0.977367,-0.146959,0.152177,-0.100482,0.310534,0.945236,-0.186167,-0.939133,0.288739},{-3.35276e-08,0,3.7976,0.96469,-0.175374,0.196512,-0.131949,0.323931,0.936834,-0.227953,-0.929684,0.289353},{3.35276e-08,1.3411e-07,3.7976,0.955902,-0.191702,0.22249,-0.150106,0.332237,0.931175,-0.252428,-0.923509,0.28881},{0,0,3.7976,0.952043,-0.198261,0.23304,-0.157416,0.335721,0.928715,-0.262365,-0.92086,0.288411},{0,0,3.7976,0.952214,-0.197315,0.233143,-0.157949,0.335218,0.928806,-0.261421,-0.921247,0.288033},{-3.35276e-08,0,3.7976,0.964137,-0.173155,0.201139,-0.137415,0.322691,0.936476,-0.227061,-0.930531,0.287324}}},["6"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,-5.36443e-07,5.10035,0.221582,-0.974911,-0.0212138,0.970794,0.222594,-0.0895043,0.0919807,-0.000761628,0.995761},{0,-2.68221e-07,5.10035,0.222184,-0.974916,-0.0131698,0.973331,0.222573,-0.0555655,0.057103,-0.000472818,0.998368},{0,5.36443e-07,5.10035,0.222553,-0.974919,0.00181262,0.974889,0.22256,0.00764778,-0.00785941,6.50808e-05,0.999969},{0,-5.36443e-07,5.10035,0.222348,-0.974917,0.00987638,0.974026,0.222567,0.0416701,-0.0428231,0.000354599,0.999083},{-6.70554e-08,-2.68221e-07,5.10035,0.222348,-0.974917,0.00987638,0.974027,0.222567,0.0416701,-0.0428231,0.000354597,0.999083},{0,-5.36443e-07,5.10035,0.222348,-0.974917,0.00987638,0.974026,0.222567,0.0416701,-0.0428231,0.000354599,0.999083},{0,0,5.10035,0.222553,-0.974919,0.00181258,0.974889,0.22256,0.00764769,-0.00785929,6.50771e-05,0.999969},{-1.3411e-07,0,5.10035,0.222184,-0.974916,-0.0131699,0.973331,0.222573,-0.0555657,0.057103,-0.000472855,0.998368},{6.70554e-08,2.68221e-07,5.10035,0.221618,-0.974911,-0.0208192,0.970946,0.222593,-0.0878394,0.0902699,-0.000747478,0.995917}}},["1"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-5.36443e-07,4.19094e-09,4.80781,0.539296,-0.462337,0.70385,0.655221,0.755415,-0.00582812,-0.529004,0.46432,0.710325},{-1.07288e-06,0,4.8078,0.535018,-0.458582,0.709547,0.655256,0.755384,-0.00587531,-0.533286,0.468079,0.704633},{0,0,4.80781,0.526983,-0.451529,0.720007,0.655323,0.755325,-0.00596192,-0.541148,0.474979,0.693941},{-1.60933e-06,-3.35276e-08,4.80781,0.522608,-0.447689,0.725572,0.655359,0.755294,-0.006008,-0.54533,0.47865,0.68812},{0,-8.38192e-09,4.80781,0.539058,-0.462128,0.704169,0.655223,0.755413,-0.00583076,-0.529244,0.464531,0.710009},{-5.36443e-07,3.35276e-08,4.80781,0.555008,-0.476127,0.682106,0.655091,0.755529,-0.00564808,-0.512662,0.449976,0.731232},{5.36443e-07,0,4.80781,0.550982,-0.472594,0.687804,0.655124,0.7555,-0.00569527,-0.516944,0.453735,0.725875},{5.36443e-07,0,4.80781,0.543417,-0.465954,0.698273,0.655187,0.755445,-0.00578196,-0.524813,0.460641,0.715808},{0,-1.67638e-08,4.80781,0.5395,-0.462515,0.703577,0.655219,0.755416,-0.00582585,-0.528799,0.46414,0.710596}}},["7"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{8.04661e-07,-1.3411e-07,3.87696,0.250418,-0.770378,0.586352,0.849574,-0.115555,-0.514656,0.464235,0.627029,0.625556},{-2.68221e-07,-2.68221e-07,3.87696,0.264681,-0.784598,0.560669,0.851681,-0.0825088,-0.517524,0.452309,0.61449,0.646389},{-2.68221e-07,0,3.87696,0.288681,-0.808114,0.513435,0.857124,-0.02082,-0.51469,0.426618,0.588658,0.686643},{2.68221e-07,-2.68221e-07,3.87696,0.292757,-0.81968,0.492359,0.868294,0.0122489,-0.495898,0.400447,0.57269,0.71531},{0,0,3.87696,0.208233,-0.829725,0.517875,0.885436,-0.0650145,-0.460191,0.415502,0.554373,0.721131},{0,-2.68221e-07,3.87696,0.131081,-0.822172,0.553941,0.887769,-0.15134,-0.434698,0.44123,0.548752,0.710061},{-4.02332e-07,2.68221e-07,3.87696,0.162205,-0.799727,0.578036,0.87866,-0.149521,-0.453431,0.44905,0.581446,0.678435},{-8.04661e-07,-1.3411e-07,3.87696,0.219718,-0.779672,0.586375,0.860484,-0.128322,-0.493052,0.459664,0.612899,0.642701},{0,-2.68221e-07,3.87696,0.248916,-0.770812,0.586421,0.850129,-0.116203,-0.513592,0.464027,0.626375,0.626366}}},["8"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{1.09426,-0.960459,3.17968,0.797914,-0.0699888,0.598695,0.474703,0.685066,-0.552578,-0.371471,0.725111,0.579847},{1.08046,-0.978441,3.20035,0.815322,-0.0634044,0.575525,0.447064,0.700591,-0.556154,-0.367945,0.710741,0.599553},{1.05584,-1.00908,3.24459,0.845768,-0.0535036,0.530862,0.394938,0.73177,-0.555461,-0.358749,0.679449,0.640038},{1.04551,-1.01742,3.28577,0.861471,-0.0586463,0.504408,0.36726,0.757942,-0.539114,-0.350695,0.649681,0.674484},{1.10039,-0.962743,3.28857,0.831625,-0.136259,0.538362,0.446298,0.740892,-0.501893,-0.330481,0.657657,0.676956},{1.15266,-0.915298,3.27598,0.793549,-0.201711,0.574102,0.522742,0.708913,-0.47348,-0.311482,0.675837,0.668},{1.13752,-0.927006,3.25101,0.79445,-0.167936,0.583649,0.511171,0.703834,-0.493277,-0.327953,0.690228,0.645005},{1.1094,-0.94875,3.20465,0.797157,-0.104452,0.594668,0.487486,0.692454,-0.53185,-0.356227,0.71386,0.602914},{1.095,-0.959883,3.18091,0.797888,-0.0716856,0.598528,0.475331,0.685449,-0.551561,-0.370721,0.724583,0.580987}}},["9"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0.432243,-0.0659752,2.93841,0.788334,0.100301,0.607016,0.310069,0.787393,-0.532793,-0.5314,0.608236,0.589629},{0.445986,-0.0748024,2.93109,0.805115,0.111269,0.582589,0.278933,0.795818,-0.537467,-0.523438,0.595226,0.609688},{0.471511,-0.0911951,2.91749,0.833798,0.12893,0.536803,0.220356,0.81381,-0.537733,-0.506185,0.566648,0.650143},{0.485256,-0.100022,2.91017,0.848334,0.127933,0.513772,0.188739,0.83355,-0.519204,-0.494678,0.537427,0.682983},{0.473478,-0.0979739,2.9127,0.84058,0.0445508,0.539853,0.265609,0.834683,-0.482449,-0.472099,0.548926,0.689784},{0.452275,-0.0914502,2.91918,0.814312,-0.0283666,0.579733,0.350809,0.819785,-0.452644,-0.462416,0.571969,0.677512},{0.438704,-0.0808671,2.92768,0.797556,0.00503117,0.603223,0.348582,0.812274,-0.467655,-0.492336,0.583254,0.646081},{0.433247,-0.0705912,2.93518,0.790463,0.0670498,0.608829,0.324687,0.796975,-0.509322,-0.519371,0.600279,0.608209},{0.432262,-0.0661882,2.93827,0.788415,0.0986714,0.607179,0.310815,0.787887,-0.531627,-0.530845,0.607863,0.590514}}},["23"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,1.3411e-07,3.7976,-0.323176,0.33572,-0.884787,0.00522673,0.935577,0.353083,0.946324,0.109484,-0.304112},{-3.35276e-08,1.3411e-07,3.7976,-0.250459,0.253301,-0.934403,-0.0364031,0.962019,0.270545,0.967442,0.101776,-0.231726},{-6.70554e-08,1.3411e-07,3.7976,-0.0755082,0.0660054,-0.994958,-0.102792,0.991975,0.0736086,0.991833,0.107832,-0.0681177},{-3.35276e-08,1.3411e-07,3.7976,0.0991716,-0.108605,-0.989126,-0.131016,0.983947,-0.121173,0.986407,0.141608,0.0833504},{-3.35276e-08,0,3.7976,0.152888,-0.160032,-0.9752,-0.13273,0.974535,-0.180732,0.979289,0.15707,0.127754},{3.35276e-08,1.3411e-07,3.7976,0.0568306,-0.0673229,-0.996111,-0.127374,0.989082,-0.0741148,0.990225,0.131091,0.0476347},{0,0,3.7976,-0.11271,0.104707,-0.988095,-0.092128,0.989047,0.115317,0.989348,0.104029,-0.101829},{0,0,3.7976,-0.262906,0.267189,-0.927087,-0.0299529,0.958166,0.28464,0.964356,0.102603,-0.243905},{-3.35276e-08,0,3.7976,-0.320511,0.332641,-0.886918,0.00352183,0.936725,0.350048,0.947238,0.109071,-0.301402}}},["4"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-1.3411e-07,4.02332e-07,4.8923,0.403314,0.291848,-0.867273,-0.8765,-0.149027,-0.457755,-0.262842,0.944783,0.1957},{0,0,4.8923,0.507653,0.270979,-0.817838,-0.829692,-0.102031,-0.548818,-0.232163,0.957162,0.173033},{0,2.68221e-07,4.8923,0.657637,0.170531,-0.733779,-0.748635,0.0393136,-0.661815,-0.0840128,0.984568,0.15352},{2.68221e-07,1.3411e-07,4.8923,0.764208,0.0367901,-0.64392,-0.636259,0.206538,-0.743315,0.105647,0.977747,0.181246},{-1.3411e-07,4.02332e-07,4.8923,0.885062,-0.0192023,-0.465076,-0.444432,0.26214,-0.856599,0.138364,0.964839,0.223476},{-1.3411e-07,2.68221e-07,4.8923,0.981726,0.0477455,-0.184214,-0.190223,0.218456,-0.957127,-0.00545597,0.974678,0.223546},{2.68221e-07,0,4.8923,0.963902,0.20097,-0.174652,-0.20517,0.142565,-0.968287,-0.169698,0.969168,0.178651},{4.02332e-07,2.68221e-07,4.8923,0.695837,0.30572,-0.649882,-0.672946,-0.0385864,-0.738684,-0.250907,0.951339,0.178884},{-4.02332e-07,5.36443e-07,4.8923,0.419615,0.293773,-0.858848,-0.868823,-0.143961,-0.473731,-0.262811,0.944972,0.194828}}},["3"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-5.36443e-07,5.36443e-07,4.20461,-0.962952,0.0142394,-0.269296,-0.00340952,-0.999168,-0.0406408,-0.26965,-0.038217,0.9622},{2.68221e-07,-5.36443e-07,4.20461,-0.979192,0.0311405,-0.200531,-0.0235095,-0.99891,-0.0403241,-0.201568,-0.0347707,0.978857},{0,0,4.20461,-0.951197,0.0490921,-0.304655,-0.0382783,-0.99841,-0.0413712,-0.306201,-0.0276905,0.951564},{-1.3411e-07,5.36443e-07,4.20461,-0.841418,0.0683247,-0.536048,-0.0431026,-0.9973,-0.059459,-0.538663,-0.0269248,0.842091},{2.01166e-07,0,4.20461,-0.623038,0.0847029,-0.777592,-0.0376968,-0.996216,-0.0783135,-0.781283,-0.0194795,0.623873},{-2.01166e-07,0,4.20461,-0.408553,0.0764086,-0.909531,-0.00433747,-0.996641,-0.0817784,-0.912724,-0.0294658,0.407513},{-2.01166e-07,5.36443e-07,4.20461,-0.36411,0.0587143,-0.929503,0.0207021,-0.997254,-0.0711034,-0.931126,-0.0451321,0.361895},{2.68221e-07,0,4.20461,-0.584877,0.0268295,-0.810678,0.0179052,-0.998782,-0.0459727,-0.810925,-0.0414037,0.583684},{0,0,4.20461,-0.926771,0.0157218,-0.375298,-0.00138541,-0.99926,-0.0384395,-0.375625,-0.0351046,0.926107}}},["24"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{1.07288e-06,-8.04661e-07,5.62343,0.159341,0.698534,0.697611,-0.978914,0.203287,0.0200374,-0.127818,-0.686094,0.716197},{-5.36443e-07,5.36443e-07,5.62343,0.132294,0.484347,0.864816,-0.977734,0.207146,0.0335542,-0.162891,-0.85,0.500966},{5.36443e-07,-5.36443e-07,5.62343,0.125316,0.479333,0.86864,-0.978046,0.206624,0.0270807,-0.166501,-0.852963,0.494703},{5.36443e-07,0,5.62343,0.130296,0.529481,0.838256,-0.97934,0.200603,0.0255159,-0.154646,-0.824262,0.54468},{5.36443e-07,-5.36443e-07,5.62343,0.134928,0.566752,0.812764,-0.979856,0.198199,0.0244597,-0.147226,-0.799693,0.582079},{5.36443e-07,0,5.62343,0.15714,0.65472,0.739357,-0.978206,0.206074,0.0254193,-0.13572,-0.727238,0.672833},{-8.04661e-07,-5.36443e-07,5.62343,0.22544,0.922685,0.312776,-0.973324,0.227348,0.030873,-0.0426228,-0.311393,0.949325},{5.36443e-07,-5.36443e-07,5.62343,0.22544,0.922685,0.312776,-0.973324,0.227348,0.030873,-0.0426228,-0.311393,0.949325},{-5.36443e-07,2.68221e-07,5.62343,0.165358,0.774704,0.61032,-0.979126,0.203119,0.00745356,-0.118193,-0.598812,0.79212}}},["25"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,1.3411e-07,3.7976,-0.132414,0.888207,-0.439949,-0.976534,-0.040842,0.211458,0.169849,0.457625,0.872771},{-3.35276e-08,1.3411e-07,3.7976,-0.105647,0.867244,-0.486545,-0.979131,-0.00529921,0.20316,0.173611,0.497855,0.849706},{-6.70554e-08,1.3411e-07,3.7976,-0.106681,0.859879,-0.499226,-0.979499,-0.0045965,0.201396,0.170881,0.510476,0.842741},{-3.35276e-08,1.3411e-07,3.7976,-0.226654,0.879615,-0.418216,-0.96462,-0.143358,0.221262,0.13467,0.45357,0.880987},{-3.35276e-08,0,3.7976,-0.392556,0.870205,-0.29773,-0.914428,-0.334576,0.22777,0.0985931,0.361665,0.92708},{3.35276e-08,1.3411e-07,3.7976,-0.504567,0.837338,-0.21042,-0.859261,-0.463263,0.21693,0.084164,0.290261,0.953239},{0,0,3.7976,-0.467919,0.852409,-0.233347,-0.879166,-0.422041,0.221244,0.0901085,0.308675,0.94689},{0,0,3.7976,-0.262785,0.893901,-0.363159,-0.955675,-0.189349,0.22546,0.132775,0.406309,0.904037},{-3.35276e-08,0,3.7976,-0.139034,0.889067,-0.436152,-0.975969,-0.0483943,0.212466,0.167789,0.455211,0.874431}}},["26"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,2.68221e-07,8.88873,-0.368681,-0.350584,0.86091,0.912747,0.0387974,0.406679,-0.175976,0.935728,0.30569},{-1.3411e-07,2.68221e-07,8.88873,-0.271835,-0.146127,0.951185,0.958466,0.0475301,0.281218,-0.0863034,0.988123,0.127138},{-1.3411e-07,0,8.88873,-0.221504,-0.0528746,0.973725,0.973724,0.0421742,0.223794,-0.0528991,0.99771,0.0421435},{2.68221e-07,2.68221e-07,8.88873,-0.24104,-0.0908162,0.966257,0.968373,0.0436051,0.245667,-0.0644442,0.994913,0.0774334},{-1.3411e-07,2.68221e-07,8.88873,-0.273479,-0.15514,0.949285,0.958002,0.0445822,0.283276,-0.0862685,0.986886,0.136432},{0,1.3411e-07,8.88873,-0.309166,-0.227856,0.923308,0.944065,0.0435707,0.326869,-0.114708,0.97272,0.20164},{0,-1.3411e-07,8.88873,-0.340019,-0.291492,0.894103,0.929333,0.0414056,0.366915,-0.143974,0.955677,0.256815},{1.3411e-07,-2.68221e-07,8.88873,-0.360946,-0.334677,0.870465,0.917544,0.0395268,0.395665,-0.166827,0.941504,0.292814},{0,0,8.88873,-0.36835,-0.349909,0.861326,0.912958,0.0388255,0.406203,-0.175575,0.935979,0.305151}}},["27"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,1.3411e-07,3.7976,0.195333,0.527177,0.827,0.0619868,0.834921,-0.546867,-0.978776,0.158084,0.13041},{-3.35276e-08,1.3411e-07,3.7976,0.114781,0.456491,0.882293,0.0914849,0.879531,-0.466964,-0.989169,0.134315,0.0591911},{-6.70554e-08,1.3411e-07,3.7976,-0.0702109,0.284233,0.956181,0.128745,0.953112,-0.273867,-0.989189,0.103875,-0.103512},{-3.35276e-08,1.3411e-07,3.7976,-0.244986,0.109765,0.963293,0.12795,0.988541,-0.0801014,-0.961047,0.10363,-0.256223},{-3.35276e-08,0,3.7976,-0.296915,0.0556606,0.95328,0.120753,0.992474,-0.0203387,-0.947238,0.109072,-0.301402},{3.35276e-08,1.3411e-07,3.7976,-0.203457,0.152263,0.967172,0.131336,0.98315,-0.12715,-0.970235,0.101155,-0.220026},{0,0,3.7976,-0.0317751,0.321086,0.946517,0.124269,0.940916,-0.315015,-0.99174,0.107613,-0.0697986},{0,0,3.7976,0.128393,0.468635,0.874012,0.0871101,0.872571,-0.480659,-0.98789,0.137848,0.0712089},{-3.35276e-08,0,3.7976,0.192334,0.524598,0.82934,0.0632466,0.836735,-0.543943,-0.979289,0.157072,0.127753}}},["28"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,-2.68221e-07,4.8923,0.857662,0.0191292,0.513858,0.491427,0.263688,-0.830041,-0.151376,0.964418,0.216755},{-1.3411e-07,0,4.8923,0.979386,-0.0634314,0.191783,0.200971,0.210271,-0.956763,0.0203626,0.975583,0.218684},{0,0,4.8923,0.937402,-0.241643,0.250771,0.283486,0.111243,-0.952502,0.202269,0.963968,0.172782},{0,2.68221e-07,4.8923,0.60839,-0.313704,0.729007,0.749058,-0.0765569,-0.658067,0.262248,0.94643,0.188406},{0,0,4.8923,0.407456,-0.289894,0.865991,0.874747,-0.148465,-0.461276,0.262291,0.945473,0.193091},{1.3411e-07,0,4.8923,0.507555,-0.266966,0.819217,0.831026,-0.0994336,-0.547274,0.227561,0.958562,0.171387},{0,-1.3411e-07,4.8923,0.680851,-0.180058,0.709945,0.725631,0.0341346,-0.687237,0.0995085,0.983064,0.153896},{2.68221e-07,1.3411e-07,4.8923,0.814975,-0.050847,0.577261,0.575096,0.193488,-0.794875,-0.0712759,0.979784,0.186929},{-1.3411e-07,0,4.8923,0.855966,0.0157424,0.516792,0.4955,0.260473,-0.828634,-0.147655,0.965353,0.215155}}},["29"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,0,4.20461,-0.671108,-0.0827375,0.736728,0.0401264,-0.99635,-0.0753417,0.740272,-0.0210001,0.671979},{3.35276e-07,0,4.20461,-0.425821,-0.072517,0.901897,0.000492174,-0.996802,-0.0799154,0.904807,-0.0335857,0.424495},{-2.68221e-07,5.36443e-07,4.20461,-0.376952,-0.053599,0.924681,-0.0211719,-0.997565,-0.0664547,0.925991,-0.0446274,0.374899},{2.68221e-07,-5.36443e-07,4.20461,-0.694333,-0.0194712,0.71939,-0.0166354,-0.998933,-0.0430933,0.719462,-0.0418885,0.693268},{-5.36443e-07,5.36443e-07,4.20461,-0.96413,-0.0196399,0.264704,0.00936898,-0.999155,-0.0400088,0.265266,-0.0360937,0.963499},{-2.68221e-07,0,4.20461,-0.966233,-0.0365623,0.255062,0.0277549,-0.998891,-0.038046,0.25617,-0.0296821,0.966176},{-2.68221e-07,0,4.20461,-0.943497,-0.0491559,0.327714,0.0372364,-0.9984,-0.0425516,0.329282,-0.0279444,0.943818},{-6.70554e-08,-5.36443e-07,4.20461,-0.798353,-0.0712409,0.597961,0.0418527,-0.997141,-0.0629206,0.600733,-0.0252066,0.799052},{6.70554e-08,0,4.20461,-0.678149,-0.0821933,0.730314,0.0402878,-0.99639,-0.0747287,0.733819,-0.0212544,0.679012}}},["30"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{5.36443e-07,5.36443e-07,5.62343,0.154558,-0.658021,-0.736967,0.983126,0.176313,0.0487569,0.0978537,-0.732067,0.674168},{2.68221e-07,5.36443e-07,5.62343,0.184131,-0.780013,-0.59806,0.979336,0.197376,0.0440943,0.0836483,-0.59382,0.800238},{2.68221e-07,0,5.62343,0.212191,-0.899992,-0.380775,0.975997,0.214724,0.0363667,0.0490318,-0.379352,0.923952},{5.36443e-07,5.36443e-07,5.62343,0.229446,-0.904809,-0.358712,0.971701,0.234199,0.0307965,0.0561452,-0.355627,0.93294},{0,-2.68221e-07,5.62343,0.188786,-0.553248,-0.811343,0.966701,0.250055,0.0544247,0.17277,-0.7946,0.582032},{5.36443e-07,-5.36443e-07,5.62343,0.162761,-0.477279,-0.863548,0.971997,0.227916,0.0572336,0.1695,-0.848681,0.50101},{-5.36443e-07,0,5.62343,0.154218,-0.516998,-0.84198,0.977826,0.202062,0.0550286,0.141682,-0.831796,0.536696},{0,5.36443e-07,5.62343,0.154057,-0.60922,-0.777893,0.981706,0.183533,0.0506844,0.111891,-0.77147,0.62635},{-2.68221e-07,5.36443e-07,5.62343,0.154525,-0.655653,-0.739081,0.983065,0.176626,0.0488475,0.0985144,-0.734113,0.671843}}},["31"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-6.70554e-08,1.3411e-07,3.7976,0.469693,-0.791329,0.391391,0.844884,0.531496,0.0606876,-0.256047,0.302176,0.918221},{-3.35276e-08,1.3411e-07,3.7976,0.512596,-0.711124,0.481195,0.81063,0.585556,0.00182343,-0.283063,0.389136,0.876612},{-6.70554e-08,1.3411e-07,3.7976,0.513244,-0.678461,0.525615,0.799787,0.600252,-0.00616178,-0.311321,0.423542,0.8507},{-3.35276e-08,1.3411e-07,3.7976,0.420979,-0.755976,0.501276,0.852962,0.517939,0.0647748,-0.308598,0.4003,0.86286},{-3.35276e-08,0,3.7976,0.288523,-0.846535,0.447362,0.910395,0.387257,0.145646,-0.296539,0.365254,0.882414},{3.35276e-08,1.3411e-07,3.7976,0.19036,-0.896624,0.399785,0.93829,0.285947,0.194539,-0.288746,0.338081,0.895727},{0,0,3.7976,0.22011,-0.891354,0.396281,0.933108,0.310818,0.180836,-0.28436,0.329969,0.900144},{0,0,3.7976,0.377637,-0.836472,0.397122,0.886365,0.450622,0.106286,-0.267857,0.311858,0.911591},{-3.35276e-08,0,3.7976,0.46512,-0.793825,0.391797,0.84722,0.527495,0.0629923,-0.256676,0.302639,0.917893}}},["32"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,0,8.88873,-0.0940544,0.308571,-0.946539,-0.993957,0.0249499,0.1069,0.0566022,0.950874,0.30436},{-1.3411e-07,-5.36443e-07,8.88873,-0.0377626,0.38878,-0.920556,-0.998353,0.0251439,0.0515731,0.043197,0.920988,0.38719},{-2.68221e-07,0,8.88873,0.041838,0.41684,-0.908016,-0.999058,0.00695488,-0.04284,-0.0115421,0.908953,0.416739},{-6.70554e-08,-2.68221e-07,8.88873,0.110603,0.331287,-0.937025,-0.993839,0.0436777,-0.101867,0.00717992,0.942519,0.334077},{-6.70554e-08,-2.68221e-07,8.88873,0.153299,0.204625,-0.966762,-0.986885,0.0817713,-0.139182,0.0505732,0.975419,0.214477},{2.68221e-07,2.68221e-07,8.88873,0.169411,0.11073,-0.979305,-0.981788,0.105647,-0.157895,0.085977,0.988219,0.126611},{0,-2.68221e-07,8.88873,0.131366,0.1363,-0.981919,-0.990823,0.0498613,-0.125636,0.0318355,0.989412,0.141599},{0,2.68221e-07,8.88873,-0.0327309,0.251215,-0.967378,-0.992507,-0.122171,0.00185509,-0.11772,0.96019,0.253332},{1.3411e-07,0,8.88873,-0.1041,0.305705,-0.946418,-0.99427,-0.0552195,0.0915265,-0.0242806,0.950524,0.309702}}},["11"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{1.04774e-09,8.38192e-08,5.59555,0.744467,-0.644827,-0.17311,0.54771,0.738108,-0.393968,0.381815,0.198482,0.902675},{-3.14321e-09,8.38192e-08,5.59555,0.758058,-0.638497,-0.132929,0.543894,0.731389,-0.411399,0.359899,0.239565,0.90171},{1.04774e-09,8.38192e-08,5.59555,0.78413,-0.618851,-0.0465122,0.537272,0.71445,-0.448219,0.310612,0.326472,0.892713},{5.23868e-09,8.38192e-08,5.59555,0.804451,-0.593051,0.0338953,0.533086,0.695582,-0.481647,0.262064,0.405531,0.875709},{5.23868e-09,8.38192e-08,5.59555,0.8099,-0.583637,0.058562,0.532196,0.689176,-0.491737,0.246636,0.429424,0.868772},{7.85804e-09,8.38192e-08,5.59555,0.799914,-0.599939,0.0145394,0.533916,0.700404,-0.473675,0.273993,0.386662,0.880579},{-7.33417e-09,8.38192e-08,5.59555,0.779172,-0.623523,-0.0641101,0.538444,0.718177,-0.440795,0.320888,0.308935,0.895315},{7.33417e-09,-5.02913e-08,5.59555,0.755879,-0.639664,-0.13956,0.544492,0.732549,-0.408535,0.36356,0.232814,0.90201},{5.23868e-09,2.1793e-07,5.59555,0.745005,-0.644617,-0.171568,0.547555,0.737863,-0.39464,0.380986,0.200066,0.902675}}},["12"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,0,6.52923,0.995235,0.0965004,0.013997,-0.0967255,0.995176,0.0164128,-0.0123456,-0.0176885,0.999767},{0,0,6.52923,0.995114,0.0970681,-0.0180334,-0.0974317,0.995031,-0.0205182,0.0159521,0.0221749,0.999627},{-2.68221e-07,2.68221e-07,6.52923,0.994088,0.0963585,-0.0500447,-0.0991818,0.993414,-0.0573793,0.044186,0.0620036,0.997097},{2.68221e-07,2.68221e-07,6.52923,0.995197,0.0970622,-0.0127151,-0.0972421,0.995157,-0.0143896,0.0112569,0.0155569,0.999816},{5.36443e-07,2.68221e-07,6.52923,0.995235,0.0965004,0.013997,-0.0967254,0.995176,0.0164128,-0.0123456,-0.0176886,0.999767},{5.36443e-07,0,6.52923,0.995235,0.0965004,0.013997,-0.0967256,0.995176,0.0164129,-0.0123456,-0.0176885,0.999767},{2.68221e-07,2.68221e-07,6.52923,0.995235,0.0965003,0.013997,-0.0967255,0.995176,0.0164129,-0.0123456,-0.0176885,0.999767},{0,2.68221e-07,6.52923,0.995235,0.0965004,0.013997,-0.0967255,0.995176,0.0164129,-0.0123456,-0.0176885,0.999767},{2.68221e-07,1.3411e-07,6.52923,0.995235,0.0965003,0.013997,-0.0967255,0.995176,0.0164129,-0.0123456,-0.0176885,0.999767}}},["13"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,-2.68221e-07,6.20212,0.601205,0.724623,0.336858,-0.779424,0.624713,0.0472361,-0.176211,-0.290954,0.94037},{-2.68221e-07,-5.36443e-07,6.20212,0.642096,0.719831,0.263737,-0.76339,0.631928,0.133801,-0.0703488,-0.287247,0.95527},{0,0,6.20212,0.694993,0.709489,0.116666,-0.707311,0.645459,0.288262,0.129215,-0.282859,0.950418},{0,1.07288e-06,6.20212,0.710021,0.703346,0.0342762,-0.664037,0.65255,0.365012,0.234363,-0.281927,0.930372},{-2.68221e-07,1.07288e-06,6.20212,0.705148,0.705846,0.0674327,-0.682406,0.649736,0.334912,0.192583,-0.282179,0.939833},{0,0,6.20212,0.687288,0.711603,0.145793,-0.720668,0.642872,0.259527,0.0909537,-0.283438,0.954668},{-2.68221e-07,0,6.20212,0.65471,0.717972,0.236369,-0.755205,0.634539,0.164399,-0.0319516,-0.286141,0.957655},{1.07288e-06,-2.68221e-07,6.20212,0.618566,0.722775,0.308176,-0.774208,0.627587,0.0820756,-0.134085,-0.289362,0.947782},{0,-5.36443e-07,6.20212,0.602011,0.724543,0.335589,-0.779225,0.624842,0.0488026,-0.174331,-0.290879,0.940743}}},["14"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,-2.68221e-07,5.60288,0.593572,0.781142,0.19362,-0.773684,0.487644,0.404496,0.221551,-0.389898,0.893809},{0,-5.36443e-07,5.60287,0.53081,0.846905,-0.0314873,-0.756318,0.490143,0.433293,0.382392,-0.206182,0.900703},{1.3411e-07,-2.68221e-07,5.60288,0.37259,0.859211,-0.35062,-0.724778,0.505385,0.468278,0.579547,0.0796462,0.811038},{5.36443e-07,2.68221e-07,5.60288,0.357943,0.855973,-0.373079,-0.722207,0.50705,0.470443,0.591856,0.101048,0.799685},{1.3411e-07,-2.68221e-07,5.60288,0.414042,0.865397,-0.282236,-0.73229,0.500843,0.461418,0.540666,0.0156324,0.841092},{-2.68221e-07,0,5.60288,0.487499,0.862141,-0.138049,-0.746738,0.493624,0.445778,0.452468,-0.11423,0.884435},{0,-6.70554e-07,5.60288,0.548478,0.835934,0.0196784,-0.760605,0.489,0.427035,0.34735,-0.249187,0.904021},{-2.68221e-07,6.70554e-07,5.60288,0.583091,0.799537,0.144034,-0.770193,0.487629,0.411121,0.258471,-0.350655,0.90013},{0,-5.36443e-07,5.60288,0.593152,0.781999,0.191439,-0.773535,0.487636,0.40479,0.223193,-0.388187,0.894145}}},["15"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{1.04774e-09,8.38192e-08,5.59555,0.0427571,-0.502212,-0.863687,0.555149,0.73068,-0.397388,0.830651,-0.462483,0.310044},{-3.14321e-09,8.38192e-08,5.59555,-0.0108233,-0.467984,-0.883671,0.558171,0.7304,-0.39365,0.829655,-0.4975,0.25331},{1.04774e-09,8.38192e-08,5.59555,-0.125612,-0.386552,-0.913674,0.565212,0.729,-0.386127,0.815326,-0.564921,0.126912},{5.23868e-09,8.38192e-08,5.59555,-0.230528,-0.30196,-0.925028,0.572356,0.726715,-0.379862,0.786935,-0.617014,0.00530036},{5.23868e-09,8.38192e-08,5.59555,-0.2621,-0.274446,-0.925193,0.574649,0.725823,-0.3781,0.775295,-0.630761,-0.0325283},{7.85804e-09,8.38192e-08,5.59555,-0.205525,-0.323051,-0.923795,0.570588,0.727352,-0.381299,0.795103,-0.605473,0.0348399},{-7.33417e-09,8.38192e-08,5.59555,-0.102349,-0.403964,-0.909031,0.563722,0.729374,-0.387597,0.819599,-0.552111,0.153073},{7.33417e-09,-5.02913e-08,5.59555,-0.00198015,-0.473797,-0.880632,0.557661,0.730463,-0.394257,0.830067,-0.491875,0.262771},{5.23868e-09,2.1793e-07,5.59555,0.0407019,-0.500943,-0.864523,0.555261,0.730673,-0.397242,0.830679,-0.463868,0.307894}}},["16"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,0,4.04298,0.882543,0.207408,-0.422019,-0.441168,0.675837,-0.590437,0.162755,0.707267,0.687957},{0,0,4.04298,0.833179,0.236166,-0.500038,-0.515596,0.658664,-0.548017,0.199934,0.714414,0.670552},{2.68221e-07,-1.3411e-07,4.04298,0.699674,0.291692,-0.652206,-0.660064,0.613283,-0.43382,0.273445,0.73403,0.621633},{0,-1.3411e-07,4.04298,0.5461,0.333359,-0.768535,-0.769545,0.562139,-0.302985,0.331021,0.756883,0.563519},{-5.36443e-07,2.68221e-07,4.04298,0.494287,0.343867,-0.798396,-0.797417,0.545053,-0.258928,0.346132,0.764639,0.543617},{0,-4.02332e-07,4.04298,0.585327,0.324334,-0.743101,-0.745714,0.575125,-0.336366,0.318281,0.751025,0.578497},{0,2.68221e-07,4.04298,0.729716,0.281197,-0.623252,-0.632662,0.623399,-0.45947,0.259333,0.72959,0.632807},{0,0,4.04298,0.841905,0.231531,-0.487432,-0.503584,0.661678,-0.555505,0.193906,0.713145,0.673666},{-2.68221e-07,0,4.04298,0.880805,0.208539,-0.425081,-0.444092,0.675227,-0.588941,0.164208,0.707517,0.687354}}},["17"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-5.36443e-07,5.36443e-07,4.30251,0.703668,0.0555576,0.708354,0.0311472,0.993568,-0.108869,-0.709847,0.0986705,0.697411},{0,0,4.30251,0.60375,0.0264775,0.796734,0.0889225,0.990974,-0.100316,-0.792198,0.131414,0.595946},{0,-2.68221e-07,4.30251,0.399579,-0.013188,0.916604,0.185507,0.980372,-0.0667634,-0.897732,0.196714,0.394183},{0,0,4.30251,0.326701,-0.0224532,0.944861,0.215201,0.975225,-0.0512344,-0.920302,0.220073,0.323439},{0,-2.68221e-07,4.30251,0.585782,0.0238954,0.810116,0.104467,0.989001,-0.10471,-0.803708,0.145968,0.576843},{0,2.68221e-07,4.30251,0.68532,0.0504554,0.726492,0.0464059,0.992544,-0.112709,-0.726762,0.110955,0.677869},{-2.68221e-07,5.36443e-07,4.30251,0.698292,0.054014,0.713772,0.0356554,0.993287,-0.110048,-0.714924,0.102295,0.691678},{0,5.36443e-07,4.30251,0.702998,0.0553632,0.709033,0.0317101,0.993534,-0.109018,-0.710484,0.099123,0.696697},{0,0,4.30251,0.703662,0.055556,0.70836,0.0311517,0.993568,-0.10887,-0.709852,0.0986741,0.697405}}},["18"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-2.68221e-07,0,5.37487,-0.0404103,0.42978,-0.902029,0.998792,0.0426226,-0.0244372,0.0279441,-0.901927,-0.430984},{2.68221e-07,0,5.37487,-0.0448352,0.642932,-0.76461,0.980942,0.17318,0.0880999,0.189057,-0.746088,-0.638444},{0,0,5.37487,0.0320014,0.778833,-0.626415,0.925351,0.213789,0.313081,0.377758,-0.589673,-0.713852},{-2.68221e-07,-5.36443e-07,5.37487,0.279842,0.76702,-0.577382,0.879937,0.0355863,0.473757,0.383927,-0.640636,-0.66497},{2.68221e-07,0,5.37487,0.366969,0.673352,-0.641819,0.872919,-0.0108268,0.487745,0.321475,-0.739243,-0.591755},{2.68221e-07,0,5.37487,0.0893042,0.39063,-0.916206,0.984832,0.102764,0.139808,0.148766,-0.914794,-0.375528},{1.07288e-06,1.07288e-06,5.37487,-0.0107941,0.403944,-0.91472,0.996758,0.0772888,0.0223689,0.0797334,-0.911513,-0.403469},{-5.36443e-07,5.36443e-07,5.37487,-0.0400193,0.421401,-0.905991,0.998389,0.0533636,-0.0192798,0.0402224,-0.905303,-0.422858},{0,0,5.37487,-0.0406166,0.429387,-0.902207,0.998771,0.0431223,-0.0244406,0.0284107,-0.902091,-0.430611}}},["19"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{1.04774e-09,8.38192e-08,5.59555,-0.326051,0.351458,0.877592,-0.542011,0.69109,-0.478141,-0.774542,-0.631563,-0.0348369},{-3.14321e-09,8.38192e-08,5.59555,-0.249068,0.416692,0.874261,-0.545083,0.685848,-0.482179,-0.800531,-0.59664,0.0563092},{1.04774e-09,8.38192e-08,5.59555,-0.100136,0.527568,0.843591,-0.552096,0.675889,-0.488225,-0.827746,-0.514632,0.223587},{5.23868e-09,8.38192e-08,5.59555,-0.0189953,0.580053,0.814357,-0.556469,0.670558,-0.490607,-0.830651,-0.462483,0.310044},{5.23868e-09,8.38192e-08,5.59555,-0.0678633,0.549098,0.832998,-0.553789,0.673761,-0.489248,-0.829887,-0.494507,0.258361},{7.85804e-09,8.38192e-08,5.59555,-0.175235,0.474072,0.862872,-0.548391,0.680883,-0.485454,-0.817655,-0.55826,0.140663},{-7.33417e-09,8.38192e-08,5.59555,-0.28003,0.391145,0.876692,-0.543799,0.687949,-0.480634,-0.791117,-0.611336,0.020058},{7.33417e-09,-5.02913e-08,5.59555,-0.326051,0.351458,0.877592,-0.542011,0.69109,-0.478141,-0.774542,-0.631563,-0.0348369},{5.23868e-09,2.1793e-07,5.59555,-0.326051,0.351458,0.877592,-0.542011,0.69109,-0.478141,-0.774542,-0.631563,-0.0348369}}},["20"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{0,-1.3411e-07,4.04298,0.468969,-0.295338,0.832372,0.82331,0.487353,-0.290943,-0.319732,0.821744,0.471708},{0,0,4.04298,0.598079,-0.285597,0.748823,0.745725,0.540595,-0.389425,-0.293591,0.791323,0.536295},{0,-1.3411e-07,4.04298,0.800705,-0.242516,0.547775,0.558499,0.63294,-0.536159,-0.216682,0.735236,0.642243},{0,0,4.04298,0.882543,-0.207408,0.422019,0.441168,0.675837,-0.590437,-0.162755,0.707267,0.687957},{0,2.68221e-07,4.04298,0.808498,-0.244431,0.535335,0.547936,0.644534,-0.533238,-0.214702,0.724451,0.655037},{0,0,4.04298,0.623344,-0.297773,0.72303,0.723683,0.569926,-0.389188,-0.296184,0.765843,0.570754},{2.68221e-07,-1.3411e-07,4.04298,0.488593,-0.311087,0.81517,0.809008,0.511435,-0.289724,-0.326777,0.801036,0.501556},{0,4.02332e-07,4.04298,0.471334,-0.300755,0.82909,0.820952,0.493154,-0.287814,-0.322308,0.8163,0.479346},{0,1.3411e-07,4.04298,0.468982,-0.2956,0.832272,0.823254,0.487578,-0.290726,-0.319859,0.821516,0.472019}}},["21"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{-1.3411e-07,2.68221e-07,4.30251,0.676767,-0.0482323,-0.734616,-0.0533983,0.992007,-0.114325,0.734258,0.116599,0.668782},{-2.68221e-07,0,4.30251,0.683859,-0.0500687,-0.727895,-0.0476058,0.992455,-0.112992,0.72806,0.111923,0.676315},{2.68221e-07,0,4.30251,0.696812,-0.053596,-0.715249,-0.0368915,0.993206,-0.110365,0.716305,0.10329,0.690101},{0,0,4.30251,0.703667,-0.0555574,-0.708354,-0.0311474,0.993568,-0.108869,0.709847,0.0986706,0.697411},{-2.68221e-07,0,4.30251,0.589537,-0.0229558,-0.807415,-0.0964729,0.99044,-0.0985993,0.80196,0.136022,0.581686},{-2.68221e-07,-5.36443e-07,4.30251,0.372479,0.016947,-0.927886,-0.19669,0.978561,-0.0610844,0.906958,0.205259,0.367827},{0,-2.68221e-07,4.30251,0.343294,0.020428,-0.939006,-0.208877,0.976387,-0.0551229,0.915707,0.21506,0.339455},{0,2.68221e-07,4.30251,0.552414,-0.0156642,-0.833423,-0.119459,0.988015,-0.09775,0.824966,0.153558,0.543922},{-1.3411e-07,0,4.30251,0.670744,-0.0463974,-0.740236,-0.0568966,0.991882,-0.113726,0.739503,0.118398,0.662659}}},["22"]={["times"]={0.0416666,0.25,0.458333,0.666667,0.875,1.08333,1.29167,1.5,1.66667},["poses"]={{5.36443e-07,0,5.37487,0.512102,-0.359451,0.780094,-0.843098,-0.0368167,0.536498,-0.164124,-0.932437,-0.321906},{-5.36443e-07,-5.36443e-07,5.37487,0.378843,-0.375995,0.845639,-0.915624,-0.0194083,0.401566,-0.134575,-0.926418,-0.351623},{-5.36443e-07,-5.36443e-07,5.37487,0.107823,-0.404294,0.908251,-0.991813,0.0191295,0.126258,-0.0684199,-0.914429,-0.398921},{5.36443e-07,5.36443e-07,5.37488,-0.0404102,-0.42978,0.902029,-0.998792,0.0426228,-0.0244372,-0.0279445,-0.901927,-0.430983},{8.04661e-07,-5.36443e-07,5.37488,0.0645697,-0.565287,0.822363,-0.997693,-0.0192569,0.0650987,-0.0209634,-0.824669,-0.565227},{8.04661e-07,0,5.37487,0.217993,-0.664146,0.715115,-0.973699,-0.0982637,0.205558,-0.066251,-0.741117,-0.668099},{1.07288e-06,2.68221e-07,5.37488,0.279223,-0.62017,0.733091,-0.947982,-0.0565098,0.313266,-0.152852,-0.782429,-0.60369},{1.3411e-06,8.04661e-07,5.37487,0.40743,-0.47656,0.779033,-0.893722,-0.0326634,0.44743,-0.187781,-0.878535,-0.43922},{0,-2.68221e-07,5.37487,0.506578,-0.36592,0.780693,-0.846039,-0.0365037,0.53187,-0.166124,-0.92993,-0.328075}}}}}
]====])
entry.Parent=game.StarterPlayer.StarterPlayerScripts
end
print("Summoner Survival installed. Save your place and press Play.")
