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
local clock = {elapsed = 0, roundLength = 180}
local actors = require(modules.shared.Actors)({world = world})
local players = require(modules.shared.PlayerState)({states = states})
local movement = require(modules.combat.Movement)({
    world = world, rootOf = players.RootOf, paused = players.Paused, effect = net.Effect,
})
local progression = require(modules.flow.Progression)({
    world = world, states = states, gems = gems, rng = rng, block = actors.Block,
    rootOf = players.RootOf, paused = players.Paused, finishDash = movement.FinishDash,
    update = net.State, clock = clock,
})
local combat = require(modules.combat.Combat)({
    world = world, enemies = enemies, rng = rng, block = actors.Block,
    rootOf = players.RootOf, paused = players.Paused, effect = net.Effect, drop = progression.Drop,
})
local waves = require(modules.world.Waves)({
    states = states, enemies = enemies, rng = rng, creature = actors.Create,
    rootOf = players.RootOf, roundLength = clock.roundLength,
})
local session = require(modules.flow.Session)({
    world = world, states = states, enemies = enemies, gems = gems, rng = rng,
    creature = actors.Create, finishDash = movement.FinishDash,
    clearIceShots = combat.ClearProjectiles, sync = progression.Sync,
    clock = clock, resetSpawn = waves.ResetSpawn,
})
net.Action.OnServerEvent:Connect(function(player,kind,id)
    local s = states[player]
    if not s then return end
    if kind == "ready" then progression.Sync(s); return end
    if kind == "restart" then if s.over then session.Restart() end; return end
    if s.over then return end
    if kind == "choose" then progression.Choose(s,id)
    elseif kind == "dash" then
        if movement.RequestDash(s,id) then progression.Sync(s) end
    elseif kind == "fireWave" then
        if combat.RequestWave(s) then progression.Sync(s) end
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
        if clock.elapsed >= clock.roundLength then
            for _,s in pairs(states) do if not s.over then session.EndPlayer(s,"victory") end end
        end
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
    end
    sendClock += dt
    if sendClock >= .2 then
        sendClock = 0
        for _,s in pairs(states) do progression.Sync(s) end
    end
end)
print("[Summoner] Survival server ready")
