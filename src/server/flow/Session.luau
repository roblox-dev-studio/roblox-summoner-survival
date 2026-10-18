-- Join, death, victory and full-round restart.
return function(deps)
	local Players = deps.players or game:GetService("Players")
	local world, states, enemies, gems, rng = deps.world, deps.states, deps.enemies, deps.gems, deps.rng
	local creature, finishDash, clearIceShots, sync = deps.creature, deps.finishDash, deps.clearIceShots, deps.sync
	local clock, resetSpawn = deps.clock, deps.resetSpawn
	local loadouts=require(script.Parent.Loadout)
	local results=require(script.Parent.RunSummary)({loadouts=loadouts,augments=require(script.Parent.Augments)})
	local lastResults={}
	local saved={}
	local savedActive={}
	local starting = false
	local STARTING_HEALTH = 150 -- Pattern-review tuning; applies on join and restart.
	local function endPlayer(s,result)
		if states[s.player]~=s or s.over then return end
		s.over=true; s.result=result; s.offers=nil
		local newBest=deps.scoreRecord and deps.scoreRecord(s,result)
		s.runResult=results.Capture(s,clock,deps.scoreBest and deps.scoreBest(s.player),newBest)
		lastResults[s.player]=s.runResult
		finishDash(s)
		clearIceShots(s)
		local c=s.player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
		if h then h.WalkSpeed=0 end
		if not s.returning then sync(s)end
	end
	local function addPlayer(player)
		local s={player=player,level=1,xp=0,kills=0,fire=0,lightning=0,ice=0,meteor=0,blades=0,frost=0,ward=0,missile=0,skyLances=0,lightRing=0,weaponId="starlightWand",golem=1,vitality=0,agility=0,magnet=0,cooldown=0,fireClock=0,lightningClock=0,iceClock=0,golemClock=0,over=false}
		s.augments={};s.rerolls=2;s.offerRevision=0
		s.lastRun=lastResults[player]
		s.activeSkill=savedActive[player] or 'iceRush';s.activeName=loadouts.ActiveNames[s.activeSkill]
		s.lobby=true;s.loadout=table.clone(saved[player] or loadouts.Defaults)
		states[player]=s
		if deps.scoreAdd then deps.scoreAdd(player)end
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
		humanoid.WalkSpeed=18; humanoid.MaxHealth=STARTING_HEALTH; humanoid.Health=STARTING_HEALTH
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
  local bossTest,fieldTest
  for _,state in pairs(states)do
   if bossTest==nil then bossTest=state.bossTestQueued==true elseif bossTest~=(state.bossTestQueued==true)then return end
  end
  for _,state in pairs(states)do
   if fieldTest==nil then fieldTest=state.fieldBossTestQueued==true elseif fieldTest~=(state.fieldBossTestQueued==true)then return end
  end
  if bossTest then clock.elapsed=clock.roundLength elseif fieldTest then clock.elapsed=60 end
  for p,state in pairs(states)do
   state.runStartedAt=clock.elapsed
   state.bossTest=bossTest;state.bossTestQueued=nil;state.fieldBossTest=fieldTest;state.fieldBossTestQueued=nil
   state.lobby=false;state.queued=false;state.lobbyMessage=nil
   for _,id in ipairs(state.loadout)do state[id]=bossTest and 5 or(fieldTest and 3 or 1) end
   if bossTest then state.golem=5;state.level=21 elseif fieldTest then state.golem=3;state.level=11 end
   saved[p]=table.clone(state.loadout);savedActive[p]=state.activeSkill
   local c=p.Character;local r=c.HumanoidRootPart;local h=c:FindFirstChildOfClass('Humanoid')
   r.CFrame=CFrame.new(rng:NextNumber(-4,4),4,rng:NextNumber(-4,4));r.AssemblyLinearVelocity=Vector3.zero
   h.WalkSpeed=22;state.pet:PivotTo(CFrame.new(r.Position+Vector3.new(5,0,4)))
   sync(state)
  end
 end
 local function startRound(s,ids,activeId,bossTest,fieldTest)
  if not s.lobby or not s.loaded or starting then return end
  if (bossTest or fieldTest) and deps.allowBossTest~=true then return end
  local now=os.clock();if now-(s.lastLobbyRequest or -10)<.5 then return end;s.lastLobbyRequest=now
  activeId=activeId or s.activeSkill or 'iceRush'
  if not loadouts.ValidateActive(activeId) then s.lobbyMessage='사용할 Q 스킬을 선택해 주세요.';sync(s);return end
  local valid=loadouts.Validate(ids)
  if not valid then s.lobbyMessage='서로 다른 마법을 정확히 4개 골라 주세요.';sync(s);return end
  for _,other in pairs(states)do
   if not other.lobby then s.lobbyMessage='진행 중인 전투가 끝난 뒤 함께 출발할 수 있어요.';sync(s);return end
  end
  for _,other in pairs(states)do
   if other~=s and other.queued and((other.bossTestQueued==true)~=(bossTest==true)or(other.fieldBossTestQueued==true)~=(fieldTest==true))then s.lobbyMessage='전원이 일반 전투 또는 보스전 테스트 중 같은 모드를 선택해 주세요.';sync(s);return end
  end
  s.fieldBossTestQueued=fieldTest==true
  s.bossTestQueued=bossTest==true
  s.activeSkill=activeId;s.activeName=loadouts.ActiveNames[activeId];s.loadout=valid;s.queued=true;s.lobbyMessage=nil;sync(s);tryStart()
 end
 local function cancelReady(s)
  if s.lobby and s.queued then s.queued=false;s.bossTestQueued=nil;s.fieldBossTestQueued=nil;sync(s)end
 end
 local function returnToLobby(s)
  if states[s.player]~=s or s.lobby or s.returning or starting then return end
  s.returning=true
  saved[s.player]=table.clone(s.loadout);savedActive[s.player]=s.activeSkill
  endPlayer(s,'retreat')
  s.lastRun=s.runResult or s.lastRun
  s.lobby=true;s.queued=false;s.loaded=false;s.over=false;s.result=nil;s.offers=nil;s.previewSkills=nil;s.previewDragon=nil
  sync(s)
  -- A teammate's active run continues; only the departing player's objects are cleared.
  local anotherActive=false
  for _,other in pairs(states)do if other~=s and not other.over and not other.lobby then anotherActive=true;break end end
  if not anotherActive then restart();return end
  if s.pet then s.pet:Destroy()end
  local player=s.player;states[player]=nil
  task.spawn(addPlayer,player)
 end
 local function removePlayer(p)
		saved[p]=nil;savedActive[p]=nil;lastResults[p]=nil
		if deps.scoreRemove then deps.scoreRemove(p)end
		local s=states[p]; if s and s.pet then s.pet:Destroy() end; states[p]=nil
		if s then clearIceShots(s) end
		tryStart()
		if next(states)==nil then world:ClearAllChildren(); table.clear(enemies); table.clear(gems); clock.elapsed=0; resetSpawn(); if deps.resetBoss then deps.resetBoss() end end
	end


 local function stepLobby()
  local spawn=deps.lobbySpawn or CFrame.new(0,4,150)
  local center=deps.lobbyCenter or Vector3.new(0,0,178)
  local radius=deps.lobbyRadius or 58
  for _,s in pairs(states)do
   if s.lobby and s.loaded and not s.returning then
    local character=s.player.Character
    local root=character and character:FindFirstChild('HumanoidRootPart')
    local humanoid=character and character:FindFirstChildOfClass('Humanoid')
    if root and humanoid and humanoid.Health>0 then
     local pos=root.Position;local offset=Vector3.new(pos.X-center.X,0,pos.Z-center.Z)
     if offset.Magnitude>radius or pos.Y< -10 then
      root.CFrame=spawn;root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
      if s.pet and s.pet.Parent then s.pet:PivotTo(CFrame.new(spawn.Position+Vector3.new(5,0,4)))end
     end
    end
   end
  end
 end

	return {
        StepLobby = stepLobby,
		AddPlayer = addPlayer,
		RemovePlayer = removePlayer,
		EndPlayer = endPlayer,
		Restart = restart,
		StartRound = function(s,ids,activeId)return startRound(s,ids,activeId,false)end,
        StartFieldBossTest = function(s,ids,activeId)return startRound(s,ids,activeId,false,true)end,
        StartBossTest = function(s,ids,activeId)return startRound(s,ids,activeId,true)end,
		CancelReady = cancelReady,
        ReturnToLobby = returnToLobby,
	}
end
