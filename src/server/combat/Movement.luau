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
