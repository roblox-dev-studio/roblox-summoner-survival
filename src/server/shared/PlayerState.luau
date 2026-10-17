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
