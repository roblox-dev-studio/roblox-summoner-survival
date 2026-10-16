-- Join, death, victory and full-round restart.
return function(deps)
	local Players = game:GetService("Players")
	local world, states, enemies, gems, rng = deps.world, deps.states, deps.enemies, deps.gems, deps.rng
	local creature, finishDash, clearIceShots, sync = deps.creature, deps.finishDash, deps.clearIceShots, deps.sync
	local clock, resetSpawn = deps.clock, deps.resetSpawn
	local starting = false
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
		local s={player=player,level=1,xp=0,kills=0,fire=1,lightning=0,ice=0,golem=1,vitality=0,agility=0,magnet=0,cooldown=0,fireClock=0,lightningClock=0,iceClock=0,golemClock=0,over=false}
		states[player]=s
		s.pet=creature(player.Name.."_Golem",Color3.fromRGB(95,112,120),true)
		s.petRig={}
		for _,part in ipairs(s.pet:GetChildren()) do if part:IsA("BasePart") then s.petRig[part]=s.pet:GetPivot():ToObjectSpace(part.CFrame) end end
		player:LoadCharacterAsync()
		local character=player.Character
		if states[player]~=s or not character then return end
		local root=character:WaitForChild("HumanoidRootPart")
		root.CFrame=CFrame.new(rng:NextNumber(-4,4),4,rng:NextNumber(-4,4))
		s.pet:PivotTo(CFrame.new(root.Position.X+5,3.6,root.Position.Z+4))
		local humanoid=character:WaitForChild("Humanoid")
		humanoid.WalkSpeed=22; humanoid.MaxHealth=100; humanoid.Health=100
		humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
		humanoid.Died:Connect(function() if states[player]==s then endPlayer(s,"defeat") end end)
		sync(s)
	end
	local function restart()
		if starting then return end
		starting=true
		for _,s in pairs(states) do if not s.over then starting=false; return end end
		world:ClearAllChildren(); table.clear(enemies); table.clear(gems); table.clear(states)
		clearIceShots()
		clock.elapsed=0; resetSpawn()
		for _,p in ipairs(Players:GetPlayers()) do task.spawn(addPlayer,p) end
		starting=false
	end
	local function removePlayer(p)
		local s=states[p]; if s and s.pet then s.pet:Destroy() end; states[p]=nil
		if s then clearIceShots(s) end
		if next(states)==nil then world:ClearAllChildren(); table.clear(enemies); table.clear(gems); clock.elapsed=0 end
	end

	return {
		AddPlayer = addPlayer,
		RemovePlayer = removePlayer,
		EndPlayer = endPlayer,
		Restart = restart,
	}
end
